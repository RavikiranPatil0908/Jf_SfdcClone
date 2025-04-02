/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public class UpdateLeadOwnerBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Set<String> lstFailedRecords;
    public Set<String> lstSuccessRecords;
    public Integer successCount = 0;
    public Integer failedCount = 0;
    public Integer totalCount = 0;
    public List<nm_UserMapping__c> lstUserCenterMapping= new List<nm_UserMapping__c>();
    public Map<Id,nm_UserMapping__c> mapOfCenterIdVsCenterUserMappinghead = new Map<Id,nm_UserMapping__c>();
    public Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = new Map<String,List<nm_UserMapping__c>>();
    public   Map<id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = new Map<id,Counsellor_Profile__c>();
    public List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
    
    public UpdateLeadOwnerBatchClass() {
        
    }
    public void execute(SchedulableContext sc) {
        UpdateLeadOwnerBatchClass b = new UpdateLeadOwnerBatchClass();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
        mapOfCounseloridVsCounselorProfile = getMapAllCounsellor();
        System.debug('Update course list Batch started');
        // String leadId = '00QO0000008ZKfM';
        String query = 'SELECT id, nm_InformationCenter__c,Counselor_Profile__c,OwnerId FROM Lead WHERE Is_AEP_Match_With_Owner__c= True AND IsConverted=false AND ( Counselor_Profile__c = Null OR Counselor_Profile__r.IsActive__c = false)  Order by CreatedDate DESC LIMIT 9999';
        if(Test.isRunningTest()) {
            query =  'SELECT id, nm_InformationCenter__c,Counselor_Profile__c,OwnerId FROM Lead';
        }
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<nm_UserMapping__c> lstALLUserMapping = new List<nm_UserMapping__c>();
        List <Lead> leadToUpdate = new List<Lead>();
        if(scope.size() > 0) { 
            for(SObject sc : scope){
                Lead objLead = (Lead)sc;
                if(objLead.nm_InformationCenter__c != null){
                    lstALLUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                    if(objLead.Counselor_Profile__c != null
                    &&  mapOfCounseloridVsCounselorProfile.containsKey(objLead.Counselor_Profile__c)
                    && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c
                    && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).UserIsActive__c)
                    {
                        if(objLead.OwnerId != mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId) {
                            Lead upLead = new Lead();
                            upLead.Id = objLead.Id;
                            upLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;
                            leadToUpdate.add(upLead);     
                            totalCount++;                 

                        }
                    } else if(lstALLUserMapping != null && objLead.Counselor_Profile__c != null && mapOfCounseloridVsCounselorProfile.containsKey(objLead.Counselor_Profile__c) && objLead.nm_InformationCenter__c != mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c){
                        String userMap = AssignCenterHead(lstALLUserMapping, objLead.OwnerId);
                        if(String.isNotBlank(userMap) ) {
                            Lead upLead = new Lead(Id = objLead.Id, OwnerId = userMap);
                            leadToUpdate.add(upLead);  
                            totalCount++;
                        }
                    } else if(String.isBlank(objLead.Counselor_Profile__c) && lstALLUserMapping != null) {
                        String userMap = AssignCenterHead(lstALLUserMapping, objLead.OwnerId);
                        if(String.isNotBlank(userMap) ) {
                            Lead upLead = new Lead(Id = objLead.Id, OwnerId = userMap);
                            leadToUpdate.add(upLead);  
                            totalCount++;
                        }
                    }
                }

            }
        } else {
            System.debug('No records found.');
        }
        if(leadToUpdate.size() > 0) {
            try {
                lstFailedRecords = new Set<String>();
                lstSuccessRecords = new Set<String>();
                Database.SaveResult[] srList = Database.update(leadToUpdate, false);
                for (Integer i = 0; i < leadToUpdate.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Lead origRecord = leadToUpdate[i];
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        lstSuccessRecords.add(origRecord.Id);
                        System.debug('Successfully updated Lead ID: ' + sr.getId());
                         successCount++;
        
                    } else {
                        System.debug('sr.getId() -->'+origRecord.id);
                        lstFailedRecords.add(origRecord.id);
                        failedCount++;
                        // Operation failed, so get all errors.                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Lead fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
         catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
             }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
            sendErrorMail();
        }
        system.debug('Finished ===> ');
    }

    public String AssignCenterHead(List<nm_UserMapping__c> lstUserMapping, String ownerId) {
        String leadNewOwner = '';
        Boolean isOwnerAlreadyMatched = false;
        if(lstUserMapping.size() > 0) {
            for(nm_UserMapping__c objUserMapping : lstUserMapping) {
                if(objUserMapping.nm_Head__c && objUserMapping.User_Active__c) {
                    if(objUserMapping.nm_User__c == ownerId ) {
                        isOwnerAlreadyMatched = true;
                        break;
                    }
                    leadNewOwner = objUserMapping.nm_User__c;
                }
                
            }

        }
        if(isOwnerAlreadyMatched) {
            return '';
        } else {
            return leadNewOwner;
        }
    }
    public Map<String,List<nm_UserMapping__c>> getMapOfCenterIdVsCenterUserMapping(){
        Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = new Map<String,List<nm_UserMapping__c>>();
             for(nm_UserMapping__c objCenteruserMapping : DataBase.query(getlstUserCenterMapping())){
                 if(!mapOfCenterIdVsCenterUserMapping.containsKey(objCenteruserMapping.nm_Centers__c)){
                     mapOfCenterIdVsCenterUserMapping.put(objCenteruserMapping.nm_Centers__c,new List<nm_UserMapping__c>());
                 }
                 if(objCenteruserMapping.nm_Head__c)
                 {
                   mapOfCenterIdVsCenterUserMappinghead.put(objCenteruserMapping.nm_Centers__c,objCenteruserMapping);
                 }
                 mapOfCenterIdVsCenterUserMapping.get(objCenteruserMapping.nm_Centers__c).add(objCenteruserMapping);
             }
     return mapOfCenterIdVsCenterUserMapping;
    }

    public String getlstUserCenterMapping(){
           return getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null and nm_Centers__r.RegistrationClosed__c =false','nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name');
    }

    public Map<id,Counsellor_Profile__c> getMapAllCounsellor (){
        String CounsellorProfile = getQueryAllFieldSql('Counsellor_Profile__c','Name!=null and IsActive__c=false and UserIsActive__c =true',null);
        return new Map<id,Counsellor_Profile__c>((List<Counsellor_Profile__c>)DataBase.query(CounsellorProfile));
    }

    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }

    public void sendErrorMail() {
        String recordList = '';
        if(lstFailedRecords!=null && lstFailedRecords.size()>0) {
            for(String s: lstFailedRecords) {
                recordList += (recordList==''?'':',\n')+s;
            }
        }
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('UpdateLeadOwnerBatchClass Error Mail');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below UpdateLeadOwnerBatchClass Class Error:\n'+
        'Here are the lists of failed records List:\n'+
          recordList +'\n\n'+
        'Total Records Processed: ' +totalCount +'\n'+
        'Sucess Records: '+ successCount +'\n'+
        'Error Records: '+ failedCount +'\n\n'+
       
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

     
    }
}