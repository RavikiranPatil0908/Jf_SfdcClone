/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-27-2021
 * @last modified by  : @BK
**/
public  class TeleVerificationBatchClassClone implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    

    
     public void execute(SchedulableContext sc) {
        TeleVerificationBatchClassClone b = new TeleVerificationBatchClassClone();
        Database.executebatch(b, 50);
    }
    public String phoneId = '';
    public String orderId = '';
    public Boolean isOrderIdAlreadyNotPresent= false ;
    public DateTime myDateTime = DateTime.now();
    public DateTime morningStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 08, 30, 0);
    public DateTime morningEndTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 12, 55, 0);

    public DateTime afternoonStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 12, 55, 0);
    public DateTime afternoonEndTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 16, 55, 0);

    public DateTime eveningStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 16, 55, 0);
    public DateTime eveningEndTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 22, 0, 0);

    // public DateTime nextDayForStartTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() -1 , 21, 0, 0);
    // public DateTime nextDayForEndTimeTime = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 08, 59, 59);

    

    // value To insert in campaign call object
    public DateTime CampaignStartDate;
    public DateTime CampaignEndDate;
    public String CampaignPhonebookName;
    public String CampaignOrderId;
    public String campaignCallId;
    

    
    KnowlarityAPI__c objKnowlarityAPI =  new KnowlarityAPI__c();
    List<API_Request__c> lstAPIRequests = new List<API_Request__c>();

    List<Integer> lstOfNumberOFLeadFound = new List<Integer>();
    List<Integer> lstOfNumberOFActualLeadFound = new List<Integer>();

    public TeleVerificationBatchClassClone() {
        objKnowlarityAPI =  KnowlarityAPI__c.getValues('KnowlarityAPIData');
        system.debug('objKnowlarityAPI ------> ' + objKnowlarityAPI);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Tele Verification Batch Class Started');
        DateTime myDateTime = DateTime.now();
        system.debug( 'KnowlarityAPI__c --> ' + KnowlarityAPI__c.getValues('KnowlarityAPIData'));

        List<Campaign_Call__c> lstCampaignCall = [Select Id, Order_Id__c, Phone_Id__c From Campaign_Call__c WHERE (Order_End_Date__c >= :myDateTime OR Order_End_Date__c = Null ) AND Type_Of_Object__c = 'Knowlarity'  order by CreatedDate desc LIMIT 1 ];

        if(lstCampaignCall.size() > 0) {
            isOrderIdAlreadyNotPresent = false;
            campaignCallId = lstCampaignCall[0].Id;
            orderId = lstCampaignCall[0].Order_Id__c;
            phoneId = lstCampaignCall[0].Phone_Id__c;

            //
        } else {
            isOrderIdAlreadyNotPresent = true;
        }

        DateTime last3DayLead = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() -2 , 20, 0, 0);
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
        
        Map<String, String> mapOfLeadIdVsKnowlarityAttempt = new Map<String, String>();
        String phoneNumbers = '';
        Boolean IsBatchPassed = false; 
        String currentSession = getCurrentSession();
        
        if(scope.size() > 0) { 
            lstOfNumberOFLeadFound.add(scope.size());
            system.debug('started ---> ');
            map<String, Object> resultPhoneBookAPI = new Map<String, Object>(); 
            map<String, Object> resultAddCallToOrder = new Map<String, Object>();
            for(SObject sc : scope){
                Lead lead = (Lead)sc;
                if( notToBeCalledInSameSession(lead.Knowlarity_Attempt__c, currentSession) 
                    && ToSkip3rdAttempt(lead.Knowlarity_Attempt__c, currentSession) 
                    && nextAttemptAfter3Call(lead.Knowlarity_Attempt__c)) {
                    mapOfLeadIdVsKnowlarityAttempt.put(lead.Id, lead.Knowlarity_Attempt__c);
                    phoneNumbers = phoneNumbers +'+91' + lead.MobilePhone + ';';
                }
            }
        if(String.isNotBlank(phoneNumbers) && String.isNotBlank(orderId) && !isOrderIdAlreadyNotPresent && String.isNotBlank(phoneId)) {
            resultAddCallToOrder.put('order_id', orderId);
            resultAddCallToOrder.put('phone_numbers', phoneNumbers.removeEnd(';'));
            // resultAddCallToOrder.put('call_times_retry',1);
            // resultAddCallToOrder.put('retry_timedelta',15 );
            String jsonAddCallToOrder= System.JSON.serialize(resultAddCallToOrder);
            if(Test.isRunningTest()) {
                IsBatchPassed = true;
            } else {
                IsBatchPassed = putAddCallToOrder(jsonAddCallToOrder) == 'success' ? true : false;
            } 
        }
        List<Lead> lstLeadToUpdate = new List<Lead>();

        lstOfNumberOFActualLeadFound.add(mapOfLeadIdVsKnowlarityAttempt.size());

        if(IsBatchPassed && mapOfLeadIdVsKnowlarityAttempt.size() > 0) {
            for (String leadId : mapOfLeadIdVsKnowlarityAttempt.keySet() ){
                Lead objLead = new Lead();
                objLead.Id = leadId;
                objLead.Knowlarity_Attempt__c = String.isNotBlank(mapOfLeadIdVsKnowlarityAttempt.get(leadId)) ? mapOfLeadIdVsKnowlarityAttempt.get(leadId) + ',' + getCurrentSessionWithNumberOfDayAttempt(mapOfLeadIdVsKnowlarityAttempt.get(leadId), currentSession) : getCurrentSessionWithNumberOfDayAttempt(mapOfLeadIdVsKnowlarityAttempt.get(leadId), currentSession) ;
                lstLeadToUpdate.add(objLead);
            }
        }
        
        if(lstLeadToUpdate.size() > 0) {
            update lstLeadToUpdate;
        }
            
        } else {
            System.debug('No records found.');
        }
    }

    public void finish(Database.BatchableContext bc) {
        map<String, Object> resultAddCallToOrder = new Map<String, Object>();
        if(String.isBlank(orderId) && !isOrderIdAlreadyNotPresent && String.isNotBlank(phoneId) ) {
            map<String, Object> resultOutBoundAPI = new Map<String, Object>(); 
            Datetime currentDateTime = Datetime.now();
            CampaignStartDate = DateTime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day(), currentDateTime.hour(), currentDateTime.minute() + 15, 0);
            CampaignEndDate =  DateTime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day() + 1, 21, 0, 0);
            resultOutBoundAPI.put('ivr_id',String.valueOf(objKnowlarityAPI.IVR_ID__c) );
            // resultOutBoundAPI.put('phonebook', '782321');
            resultOutBoundAPI.put('phonebook', phoneId);
            resultOutBoundAPI.put('timezone', 'Asia/Kolkata');
            resultOutBoundAPI.put('priority', 8);
            resultOutBoundAPI.put('order_throttling', 10);
            resultOutBoundAPI.put('retry_duration', 15);
            resultOutBoundAPI.put('start_time',CampaignStartDate.format('yyyy-MM-dd HH:mm'));
            resultOutBoundAPI.put('end_time', CampaignEndDate.format('yyyy-MM-dd HH:mm'));
            resultOutBoundAPI.put('max_retry', 3);
            resultOutBoundAPI.put('call_scheduling', '[1, 1, 1, 1, 1, 1, 1]');
            resultOutBoundAPI.put('call_scheduling_start_time', '09:00');
            resultOutBoundAPI.put('call_scheduling_stop_time', '21:00');
            resultOutBoundAPI.put('k_number',String.valueOf( objKnowlarityAPI.k_number__c));
            resultOutBoundAPI.put('is_transactional', 'True');
            String jsonstringOutbound = System.JSON.serialize(resultOutBoundAPI);
            postOutBoundApiResult(jsonstringOutbound);     
            
        }

        system.debug('lstOfNumberOFLeadFound ---> ' + lstOfNumberOFLeadFound.toString());
        system.debug('lstOfNumberOFActualLeadFound ---> ' + lstOfNumberOFActualLeadFound.toString());

        DateTime dateToDelete = Datetime.now();
        DateTime last5DayLead = DateTime.newInstance(dateToDelete.year(), dateToDelete.month(), dateToDelete.day() -5 , 0, 0, 0);
         List<API_Request__c> lstApiRequestToDelete = [SELECT Id FROM API_Request__c WHERE CreatedDate <= :last5DayLead AND Type_of_Request__c='Knowlarity' AND Success__c = true  LIMIT 999 ];
         if(lstApiRequestToDelete.size() > 0) {
            delete lstApiRequestToDelete;
         }
        
        System.debug('Finished');
    }

    public String postOutBoundApiResult(String jsonstring) {
        String completeStatusForOutBoundResult = '';
        orderId ='';
        if(String.isNotBlank(jsonstring)) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String Uri = objKnowlarityAPI.OutboundAPI_URL__c;
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
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                system.debug('responseBody ---> ' + responseBody);
                Boolean orderSuccessResponse = false;
                if(statusCode == 200) {
                    system.debug(resp.getBody());
                    String orderStatus = (String)responseBody.get('result');
                    orderSuccessResponse = orderStatus == 'placed order successfully' ? true : false;
                    if ( orderSuccessResponse) {
                        orderId = String.valueOf(responseBody.get('order_id')); 
                        CampaignOrderId = orderId;
                        createCampaignCallOrder(campaignCallId, CampaignOrderId, CampaignStartDate, CampaignEndDate);
                        completeStatusForOutBoundResult= 'success';
                    } else {
                        System.debug(resp.getBody());
                        completeStatusForOutBoundResult='failed';
                    }
                } else {
                    completeStatusForOutBoundResult = 'failed';
                }
                API_Request__c apiReq = new API_Request__c();
                apiReq.API_Name__c = 'OutBound API';
                apiReq.Request__c = jsonstring;
                apiReq.Response__c = resp.getBody();
                apiReq.Type_of_Request__c = 'Knowlarity';
                apiReq.Success__c =orderSuccessResponse;
                insert apiReq;
                // return resp;
            }catch (Exception e) {
                System.debug(e);
                completeStatusForOutBoundResult = 'failed';
            }
        }
        return completeStatusForOutBoundResult;
    }

        public String putAddCallToOrder(String jsonstring) {
        String completeStatus = '';
        if(String.isNotBlank(jsonstring)) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String Uri = objKnowlarityAPI.Add_Call_To_Order_URL__c;
            req.setEndpoint(Uri);
            req.setMethod('PUT');
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
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                Boolean addOrderResponse = false;
                if(statusCode == 200) {
                    system.debug(resp.getBody());
                    system.debug(responseBody);
                    String msg = (String)responseBody.get('result');
                    addOrderResponse = msg == 'call added successfully' ? true : false;
                    if (addOrderResponse) {
                        completeStatus= 'success';
                    } else {
                        System.debug(resp.getBody());
                        completeStatus='failed';
                    }
                } else {
                    completeStatus = 'failed';
                }
                API_Request__c apiReq = new API_Request__c();
                apiReq.API_Name__c = 'AddCallToOrder API';
                apiReq.Request__c = jsonstring;
                apiReq.Type_of_Request__c = 'Knowlarity';
                apiReq.Response__c = resp.getBody();
                apiReq.Success__c = addOrderResponse;
                insert apiReq;
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

    public void createCampaignCallOrder(String campaignId, String OrderId, DateTime StartDate, DateTime EndDate) {
        Campaign_Call__c campaignCall = new Campaign_Call__c();
        campaignCall.Id = campaignId;
        campaignCall.Order_Id__c = OrderId;
        campaignCall.Order_Start_Date__c = StartDate;
        campaignCall.Order_End_Date__c = EndDate;
        update campaignCall;
    } 


    
}