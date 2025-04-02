/**
 * @description       : 
 * @author            : Suyog
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-10-2021   @BK   Initial Version
**/
public class SendCourseListBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Set<String> lstFailedRecords;
    public Set<String> lstSuccessRecords;
    public List<String> lstOpportunityId;
    public List<API_Request__c> lstAPIRequests = new List<API_Request__c>();
    public Map<String,String> mapOfOppIdVsCourse = new Map<String,String>();
    public Map<String,String> mapOfCourseIdVsName = new Map<String,String>();

    public void execute(SchedulableContext sc) {
        SendCourseListBatch b = new SendCourseListBatch();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Update course list Batch started');
        String query = 'SELECT id, CourseList__c,BacklogList__c, Student_Number__c, nm_Year__c, nm_Session__c FROM Opportunity WHERE (CourseList__c != null OR BacklogList__c != null) AND Update_Course_List_Batch__c=false And StageName = \'Closed Won\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if(scope.size() > 0) { 
            map<String, Object> result = new Map<String, Object>(); 
            for(SObject sc : scope){
                Opportunity opp = (Opportunity)sc;
                String year = String.valueOf(Integer.valueOf(opp.nm_Year__c));
                result.put('sapId', opp.Student_Number__c);
                result.put('acadYear', year);
                result.put('acadMonth', opp.nm_Session__c);
                List<Integer> courseList = new List<Integer>();
                List<String> newLis = String.isNotBlank(opp.CourseList__c) ? opp.CourseList__c.split(',') : new List<String>();
                List<String> newBackLis = String.isNotBlank(opp.BacklogList__c) ? opp.BacklogList__c.split(','):  new List<String>();
                if(newLis.size() > 0) {
                    for(String s: newLis) {
                        courseList.add(Integer.valueOf(s));
                    }
                }
                if(newBackLis.size() > 0) {
                    for(String s: newBackLis) {
                        courseList.add(Integer.valueOf(s));
                    }
                }
                mapOfOppIdVsCourse.put(opp.id,opp.CourseList__c);
                result.put('courseIds', courseList);
                String jsonstring = System.JSON.serialize(result);
                postResult(jsonstring, opp.id);
            }
        } else {
            System.debug('No records found.');
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(lstOpportunityId!=null && lstOpportunityId.size() > 0) {
            List<nm_Courses__c> lstCourses = [SELECT id,Name,Student_Zone_Course_Id__c FROM nm_Courses__c WHERE Student_Zone_Course_Id__c!=null];
            if(lstCourses.size() > 0) {
                for (nm_Courses__c objCourse : lstCourses) {
                    mapOfCourseIdVsName.put(String.valueOf(objCourse.Student_Zone_Course_Id__c), objCourse.Name);
                }
            }
            List<Opportunity> opplsts = new List<Opportunity>();
            for (String ids : lstOpportunityId) {
                Opportunity oppe = new Opportunity();
                oppe.id = ids;
                oppe.Update_Course_List_Batch__c = true;
                oppe.Course_Name_List__c = getCourseNames(ids);
                opplsts.add(oppe);
            }
            updateProgram(opplsts);
        }
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
            sendErrorMail();
        }
        if(lstAPIRequests.size() > 0) {
            insert lstAPIRequests;
        }
        System.debug('Finished');
    }

    public HttpResponse postResult(String jsonstring, String idd) {
        if(String.isNotBlank(jsonstring)) {
            lstOpportunityId = lstOpportunityId == null ? new List<String>() : lstOpportunityId;
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String Uri = System.Label.DOCUMENT_SERVER.trim() + 'm/createStudentSessionCourses';
            req.setEndpoint(Uri);
            req.setMethod('POST');
            req.setHeader('content-type', 'application/json');
            System.debug('jsonstring ==>');
            System.debug(jsonstring);
            req.setBody(jsonstring);
            try {
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('statusCode = '+statusCode);
                if(statusCode == 200) {
                    Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                    String message = (String)responseBody.get('message');
                    if (responseBody.get('status') == 'success' || message.contains('Duplicate entry')) {
                        lstOpportunityId.add(idd);
                    } else {
                        lstFailedRecords = lstFailedRecords==null ? new Set<String>() : lstFailedRecords;
                        lstFailedRecords.add(idd);
                        System.debug(resp.getBody());
                    }
                    API_Request__c apiReq = new API_Request__c();
                    apiReq.Opportunity__c = idd;
                    apiReq.API_Name__c = 'Live Lecture Sync';
                    apiReq.Request__c = jsonstring;
                    apiReq.Response__c = resp.getBody();
                    apiReq.Success__c = responseBody.get('status') == 'success' ? true : false;
                    lstAPIRequests.add(apiReq);
                }
                return resp;
            }catch (Exception e) {
                System.debug(e);
                return null;
            }
        }
        return null;
    }

    public void updateProgram(List<Opportunity> opportunityUpdate) {
        try {
            lstFailedRecords = new Set<String>();
            lstSuccessRecords = new Set<String>();
            Database.SaveResult[] srList = Database.update(opportunityUpdate, false);
            for (Integer i = 0; i < opportunityUpdate.size(); i++) {
                Database.SaveResult sr = srList[i];
                Opportunity origRecord = opportunityUpdate[i];
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    lstSuccessRecords.add(origRecord.Id);
                    System.debug('Successfully updated Opportunity. Opportunity ID: ' + sr.getId());

                } else {
                    System.debug('sr.getId() -->'+origRecord.id);
                    lstFailedRecords.add(origRecord.id);
                    // Operation failed, so get all errors.                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Opportunity fields that affected this error: ' + err.getFields());
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }

    public void sendErrorMail() {
        String recordList = '';
        for(String s:lstFailedRecords) {
            recordList += (recordList==''?'':',\n')+s;
        }
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('Course Sync Error Mail');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below SendCourseListBatch Class Error:\n'+
        'Here are the lists of failed records List:\n'+
        recordList +'\n\n'+
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public String getCourseNames(String oppId) {
        String courseNameList = null;
        String courseList = mapOfOppIdVsCourse.containsKey(oppId) ? mapOfOppIdVsCourse.get(oppId) : null;
        System.debug('courseList ==>'+courseList);
        if(String.isNotBlank(courseList)) {
            List<String> newLis = courseList.split(',');
            String[] NameLis = New String[]{};
            for(String s: newLis) {
                if(mapOfCourseIdVsName.containsKey(s)) {
                    NameLis.add(mapOfCourseIdVsName.get(s));
                }
            }
            System.debug('NameLis ==>');
            System.debug(NameLis);
            courseNameList = String.join(NameLis, ',');
        } 
        return courseNameList;
    }
}