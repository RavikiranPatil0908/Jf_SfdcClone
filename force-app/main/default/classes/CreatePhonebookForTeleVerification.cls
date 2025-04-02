public with sharing class CreatePhonebookForTeleVerification implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Boolean IsNeedToCreateCampaignCall = false;
    public Boolean IsCampaignCreatedSuccessfully = false;
    public String CampaignPhonebookName = ''; 
    public String phoneId = ''; 
    public DateTime myDateTime = DateTime.now();
    public DateTime morningStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 0, 0, 0);
    public DateTime morningEndTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 12, 59, 59);

    public DateTime afternoonStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 13, 0, 0);
    public DateTime afternoonEndTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 16, 59, 59);

    public DateTime eveningStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 17, 0, 0);
    public DateTime eveningEndTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 20, 59, 59);

    public DateTime nextDayForStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() -1 , 21, 0, 0);
    public DateTime nextDayForEndTimeTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 08, 59, 59);

    public Map<String, String> mapOfLeadIdVsKnowlarityAttempt = new Map<String, String>();
    public List<API_Request__c> lstAPIRequests = new List<API_Request__c>();
    KnowlarityAPI__c objKnowlarityAPI =  new KnowlarityAPI__c();
    public String phoneNumbers = '';
    public Integer leadCount = 0;

    public CreatePhonebookForTeleVerification() {
        objKnowlarityAPI =  KnowlarityAPI__c.getValues('KnowlarityAPIData');
        system.debug('objKnowlarityAPI ------> ' + objKnowlarityAPI);
    }
     public void execute(SchedulableContext sc) {
        CreatePhonebookForTeleVerification b = new CreatePhonebookForTeleVerification();
        Database.executebatch(b, 50);
    }



    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('CreatePhonebookForTeleVerification Batch Class Started');
        objKnowlarityAPI =  KnowlarityAPI__c.getValues('KnowlarityAPIData');
        DateTime myDateTime = DateTime.now();
        List<Campaign_Call__c> lstCampaignCall = [Select Id, Order_Id__c From Campaign_Call__c WHERE Order_End_Date__c	 >= :myDateTime AND Type_Of_Object__c = 'Knowlarity' order by CreatedDate desc LIMIT 1];
        IsNeedToCreateCampaignCall = lstCampaignCall.size() == 0 ? True: False;

        system.debug('IsNeedToCreateCampaignCall --> ' + IsNeedToCreateCampaignCall);
        DateTime last3DayLead = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() -2 , 21, 0, 0);
        String query ='';

        // List<String> lstIds = new List<String>{'00QO000000Bvndn', '00QO000000Bvndo', '00QO000000Bvndp', '00QO000000Bvndq', '00QO000000Bvndr', '00QO000000Bvnds'};
        List<String> lstLeadStatus = new List<String>{'Not Connected', 'RNR', 'Dead on Arrival', 'Not Interested', 'Wrong No', 'Invalid No'};

        if(!Test.isRunningTest()) {
            query = 'SELECT id, MobilePhone, Name, Email,Knowlarity_Attempt__c  FROM Lead WHERE CreatedDate >= :last3DayLead AND LeadSource = \'Web\' AND Status IN :lstLeadStatus AND (User_Input__c = Null OR User_Input__c = \'None\') ' ;
            // query = 'SELECT id, MobilePhone, Name, Email,Knowlarity_Attempt__c  FROM Lead WHERE Id IN :lstIds' ;
            // query = 'SELECT id, MobilePhone, Name, Email,Knowlarity_Attempt__c  FROM Lead WHERE Id = \'00QO000000Bvndd\'' ;
        } else {
            query = 'SELECT id, MobilePhone, Name, Email,Knowlarity_Attempt__c FROM Lead' ;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if(IsNeedToCreateCampaignCall) {
            if(scope.size() > 0 ) { 
                system.debug('started ---> ');
                // String phoneNumbers = '';
                String currentSession = getCurrentSession();
                for(SObject sc : scope){
                    Lead lead = (Lead)sc;
                    if( notToBeCalledInSameSession(lead.Knowlarity_Attempt__c, currentSession) 
                    && ToSkip3rdAttempt(lead.Knowlarity_Attempt__c, currentSession) 
                    && nextAttemptAfter3Call(lead.Knowlarity_Attempt__c)
                    && leadCount < 48) {
                        leadCount = leadCount + 1;
                        mapOfLeadIdVsKnowlarityAttempt.put(lead.Id, lead.Knowlarity_Attempt__c);
                        phoneNumbers = phoneNumbers +'+91' + lead.MobilePhone + ';';
                    }
                }
                
                
            }

        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Lead> lstLeadToUpdate = new List<Lead>();
        map<String, Object> resultPhoneBookAPI = new Map<String, Object>(); 
        map<String, Object> resultOutBoundAPI = new Map<String, Object>(); 
        map<String, Object> resultAddCallToOrder = new Map<String, Object>(); 
        if(IsNeedToCreateCampaignCall) {
            phoneNumbers = String.isBlank(phoneNumbers) ? '+916127998185;' : phoneNumbers;
            if(String.isNotBlank(phoneNumbers)) { 
                CampaignPhonebookName = getUUID();
                resultPhoneBookAPI.put('phonebookname',CampaignPhonebookName);
                resultPhoneBookAPI.put('numbers', phoneNumbers.removeEnd(';'));
                String jsonstring = System.JSON.serialize(resultPhoneBookAPI);
                String msgFromRequest = '';
                if(Test.isRunningTest()) {
                    msgFromRequest = 'success';
                } else {
                  msgFromRequest = postPhoneBookApiResult(jsonstring);
    
                }
                if(msgFromRequest == 'success') {
                    IsCampaignCreatedSuccessfully = true;
                }
            }
        }
        if(IsCampaignCreatedSuccessfully && mapOfLeadIdVsKnowlarityAttempt.size() > 0) {
            String currentSession = getCurrentSession();
            for (String leadId : mapOfLeadIdVsKnowlarityAttempt.keySet() ){
                Lead objLead = new Lead();
                objLead.Id = leadId;
                objLead.Knowlarity_Attempt__c = String.isNotBlank(mapOfLeadIdVsKnowlarityAttempt.get(leadId)) ? mapOfLeadIdVsKnowlarityAttempt.get(leadId) + ',' + getCurrentSessionWithNumberOfDayAttempt(mapOfLeadIdVsKnowlarityAttempt.get(leadId), currentSession) : getCurrentSessionWithNumberOfDayAttempt(mapOfLeadIdVsKnowlarityAttempt.get(leadId), currentSession) ;
                lstLeadToUpdate.add(objLead);
            }
        } 
        if(lstAPIRequests.size() > 0) {
            insert lstAPIRequests;
        }
        if(lstLeadToUpdate.size() > 0) {
            update lstLeadToUpdate;
        }
        if(IsCampaignCreatedSuccessfully) {
            createCampaignCallOrder(CampaignPhonebookName, phoneId);
        }
        System.debug('Finished');
    }

    public String postPhoneBookApiResult(String jsonstring) {
        String completeStatus = '';
        phoneId ='';
        
        if(String.isNotBlank(jsonstring)) {
            system.debug('objKnowlarityAPI --> ' + objKnowlarityAPI);
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String Uri = objKnowlarityAPI.PhonebookAPI_URL__c;
            req.setEndpoint(Uri);
            req.setMethod('POST');
            req.setHeader('content-type', 'application/json');
            req.setHeader('authorization', objKnowlarityAPI.authorization__c);
            req.setHeader('x-api-key', objKnowlarityAPI.x_api_key__c);
            System.debug('jsonstring ==>');
            System.debug(jsonstring);
            req.setBody(jsonstring);
            try {
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('statusCode = '+statusCode);
                system.debug( 'resp.getBody() --> ' + resp.getBody());
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                system.debug(responseBody);
                Boolean successResponse = false;
                if(statusCode == 200) {
                    List<Object> message = responseBody.containsKey('msg') ? (List<Object>)responseBody.get('msg') : new List<Object>();
                    system.debug('message --> ' + message);
                    successResponse = message.size() > 0 && message.contains('Successfully added phonebook') ? true : false;
                    if (successResponse) {
                        phoneId = String.valueOf(responseBody.get('id'));
                        completeStatus= 'success';
                    } else {
                        System.debug(resp.getBody());
                        completeStatus='failed';
                    }
                } else {
                    completeStatus = 'failed';
                }
                API_Request__c apiReq = new API_Request__c();
                apiReq.API_Name__c = 'Phonebook API';
                apiReq.Request__c = jsonstring;
                apiReq.Type_of_Request__c = 'Knowlarity';
                apiReq.Response__c = resp.getBody();
                apiReq.Success__c = successResponse;
                lstAPIRequests.add(apiReq);
                // return resp;
            }catch (Exception e) {
                System.debug(e);
                completeStatus = 'failed';
            }
        }
        return completeStatus;
    }

        public Boolean ToSkip3rdAttempt(String strOfCallAttempt, String currentSession) {
        system.debug('ToSkip3rdAttempt --> ');
        system.debug('strOfCallAttempt --> ' + strOfCallAttempt);
        system.debug('currentSession --> ' + currentSession);
        List<String> lstOfCallAttempt = String.isNotBlank(strOfCallAttempt) ? strOfCallAttempt.split(',') : new List<String>();
        system.debug(lstOfCallAttempt.size());
        if(lstOfCallAttempt.size() <= 1) {
            return true;
        } else if(lstOfCallAttempt.size() == 2) {
            if(currentSession == 'morning' && lstOfCallAttempt[lstOfCallAttempt.size() - 2].contains('morning') && lstOfCallAttempt[lstOfCallAttempt.size() - 1].contains('afternoon')) {
                return true;
            } else if(currentSession == 'afternoon' && lstOfCallAttempt[lstOfCallAttempt.size() - 2].contains('afternoon') && lstOfCallAttempt[lstOfCallAttempt.size() - 1].contains('evening')) {
                return true;
            } else if (currentSession == 'evening' && lstOfCallAttempt[lstOfCallAttempt.size() - 2].contains('evening') && lstOfCallAttempt[lstOfCallAttempt.size() - 1].contains('morning')) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public String getCurrentSession() {
        if(Test.isRunningTest()) {
            myDateTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 11, 0, 0);
        }
        if(morningStartTime <= myDateTime && myDateTime <= morningEndTime) {
            return 'morning';
        } else if(afternoonStartTime <= myDateTime && myDateTime <= afternoonEndTime) {
            return 'afternoon';
        } else if(eveningStartTime <= myDateTime && myDateTime <= eveningEndTime) {
            return 'evening';
        } else {
            return '';
        }
    }

    public Boolean notToBeCalledInSameSession(String strOfCallAttempt, String currentSession) {
        List<String> lstOfCallAttempt = String.isNotBlank(strOfCallAttempt) ?  strOfCallAttempt.split(',') : new List<String>();
        if(lstOfCallAttempt.size() > 0) {
            String lastCallSessionWithExtraAttempt = lstOfCallAttempt[lstOfCallAttempt.size() -1].split('-')[1];
            String lastCallSession = lastCallSessionWithExtraAttempt.contains('#') ? lastCallSessionWithExtraAttempt.split('#')[0] : lastCallSessionWithExtraAttempt;
            if(currentSession == lastCallSession ) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    public Boolean nextAttemptAfter3Call(String strOfCallAttempt) {
        List<String> lstOfCallAttempt = String.isNotBlank(strOfCallAttempt) ?  strOfCallAttempt.split(',') : new List<String>();
        if(lstOfCallAttempt.size() > 3) {
            return false;
        } else {
            return true;
        }
    }

    public String getCurrentSessionWithNumberOfDayAttempt(String strOfCallAttempt, String currentSession) {
        List<String> lstOfCallAttempt = String.isNotBlank(strOfCallAttempt) ?  strOfCallAttempt.split(',') : new List<String>();
        Integer currentNumberOfAttempt = lstOfCallAttempt.size() / 3;
        return currentNumberOfAttempt + 1 + '-'+ currentSession;

    }

     public static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return 'NGASCE-'+ guid.left(13);
    }

    public void createCampaignCallOrder(String phoneBookName, String PhoneId) {
        Campaign_Call__c campaignCall = new Campaign_Call__c();
        campaignCall.Phone_Id__c = PhoneId;
        campaignCall.Phonebook_Name__c = phoneBookName;
        campaignCall.Type_Of_Object__c	 = 'Knowlarity';
        insert campaignCall;
    }
}