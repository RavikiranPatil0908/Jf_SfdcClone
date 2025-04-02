/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 09-04-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-19-2020   shubhranshu   Initial Version
**/
global without sharing class EzcredWebService {
    /**
    * @description 
    create lead api for ezcred loan application 
    * @author shubhranshu | 08-21-2020 
    * @param jsonStringRequest 
    * @param recordId 
    * @param recordType 
    * @return String 
    **/
    webservice static String createLead(String jsonStringRequest,String recordId,String recordType){
            
            // to save the logs
            API_Request__c apiReq = new API_Request__c(); 
            apiReq.Request__c = jsonStringRequest;
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();

            req.setEndpoint(System.Label.Ezcred_API+'lead/v2');
            req.setMethod('POST');
            String client_id = System.Label.Ezcred_auth_username;
            String client_secret = System.Label.Ezcred_auth_password;
            Blob headerValue = Blob.valueOf(client_id+':'+client_secret);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Cache-Control','no-cache');
            req.setBody(jsonStringRequest);

            System.debug('jsonStringRequest---'+jsonStringRequest);
            try{
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('LoanApplications_API__c:statusCode = '+statusCode);
                if(statusCode == 200){
                    String result = resp.getBody();
                    System.debug('result ==>'+result);
                    apiReq.Response__c = result;
                    apiReq.API_Name__c = 'CreateLeadAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    
                    Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                    if(!mapOfResponseParameters.isEmpty()){
                    Map<String, Object> mapOfReturnStatus= (Map<String, Object>) mapOfResponseParameters.get('return_status');
                        if(!mapOfReturnStatus.isEmpty()){    
                            System.debug('mapOfReturnStatus '+mapOfReturnStatus);
                            if(mapOfReturnStatus.get('status') == 'SUCCESS'){
                                apiReq.Success__c = true;
                                System.debug('loan_link ==>'+mapOfResponseParameters.get('loan_link'));
                                System.debug('lead_number ==>'+mapOfResponseParameters.get('lead_number'));
                                System.debug('apiReq '+apiReq);
                                apiRequestsInsertion(apiReq);
                                return result;
                            }else {
                                System.debug('apiReq '+apiReq);
                                apiRequestsInsertion(apiReq);
                                }
                            }
                        }
                    }else{
                        System.debug('LoanApplications_API__c Error :'+resp.getBody());
                        apiReq.Response__c = resp.getBody();
                        apiReq.API_Name__c = 'CreateLeadAPI';
                        apiReq.Type_of_Request__c = 'EzCred';
                        if(recordType == 'Lead'){
                            apiReq.Lead__c = recordId;
                        }else{
                            apiReq.Opportunity__c = recordId;
                        }
                        apiRequestsInsertion(apiReq);
                    }
                }catch(Exception e){
                    System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
                }
            return null;
    }

    /**
    * @description 
    to cancel the ezcred loan application
    * @author shubhranshu | 08-21-2020 
    * @param loan_account_number 
    * @param recordId 
    * @param recordType 
    * @return String 
    **/
    webservice static String cancelLoan(String loan_account_number,String recordId,String recordType){
            
            // to save the logs
            API_Request__c apiReq = new API_Request__c(); 
            String jsonStringRequest = '{"partner_id": \"'+System.Label.Ezcred_Partner_Id+'\","merchant_id" : null , "cancellationReason":"Do not want to opt for loan"}';
            apiReq.Request__c = jsonStringRequest;
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();

            req.setEndpoint(System.Label.Ezcred_API+'loan/'+loan_account_number+'/cancel');
            req.setMethod('POST');
            String client_id = System.Label.Ezcred_auth_username;
            String client_secret = System.Label.Ezcred_auth_password;
            Blob headerValue = Blob.valueOf(client_id+':'+client_secret);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Cache-Control','no-cache');
            req.setBody(jsonStringRequest);

            System.debug('jsonStringRequest---'+jsonStringRequest);
            try{
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('LoanApplications_API__c:statusCode = '+statusCode);
                if(statusCode == 200){
                    String result = resp.getBody();
                    System.debug('result ==>'+result);
                    apiReq.Response__c = result;
                    apiReq.API_Name__c = 'CancelLoanAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    
                    Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                    if(!mapOfResponseParameters.isEmpty()){
                        Boolean LoanCancelled = Boolean.valueOf(mapOfResponseParameters.get('success'));
                        System.debug('LoanCancelled ==>'+LoanCancelled);
                        if(LoanCancelled){
                            apiReq.Success__c = true;
                            System.debug('apiReq '+apiReq);
                            apiRequestsInsertion(apiReq);
                            return 'success';
                        }else {
                            System.debug('apiReq '+apiReq);
                            apiRequestsInsertion(apiReq);
                        }
                    }
                }else{
                    System.debug('LoanApplications_API__c Error :'+resp.getBody());
                    apiReq.Response__c = resp.getBody();
                    apiReq.API_Name__c = 'CancelLoanAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    apiRequestsInsertion(apiReq);
                }
            }catch(Exception e){
                System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
            }
            return null;
    }

    /**
    * @description 
      Disbursed/approved Loan
    * @author shubhranshu | 08-28-2020 
    * @param loan_account_number 
    * @param recordId 
    * @param recordType 
    * @return String 
    **/
    webservice static String approvedLoan(String loan_account_number,String recordId,String recordType){
            
            // to save the logs
            API_Request__c apiReq = new API_Request__c(); 
            String jsonStringRequest = '{"partner_id": \"'+System.Label.Ezcred_Partner_Id+'\","merchant_id" : null}';
            apiReq.Request__c = jsonStringRequest;
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(System.Label.Ezcred_API+'loan/v2/'+loan_account_number+'/disburse');
            req.setMethod('POST');
            String client_id = System.Label.Ezcred_auth_username;
            String client_secret = System.Label.Ezcred_auth_password;
            Blob headerValue = Blob.valueOf(client_id+':'+client_secret);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Cache-Control','no-cache');
            req.setBody(jsonStringRequest);

            System.debug('jsonStringRequest---'+jsonStringRequest);
            try{
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('LoanApplications_API__c:statusCode = '+statusCode);
                if(statusCode == 200){
                    String result = resp.getBody();
                    System.debug('result ==>'+result);
                    apiReq.Response__c = result;
                    apiReq.API_Name__c = 'Approved/DisburseLoanAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    
                    Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                    if(!mapOfResponseParameters.isEmpty()){
                        Map<String,Object> mapOfStatusParameters = (Map<String,Object>)mapOfResponseParameters.get('return_status');
                        String status = String.valueOf(mapOfStatusParameters.get('status'));
                        System.debug('status ==>'+status);
                        if(status == 'SUCCESS'){
                            apiReq.Success__c = true;
                            System.debug('apiReq '+apiReq);
                            apiRequestsInsertion(apiReq);
                            return 'success';
                        }else {
                            System.debug('apiReq '+apiReq);
                            apiRequestsInsertion(apiReq);
                        }
                    }
                }else{
                    System.debug('LoanApplications_API__c Error :'+resp.getBody());
                    apiReq.Response__c = resp.getBody();
                    apiReq.API_Name__c = 'Approved/DisburseLoanAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    apiRequestsInsertion(apiReq);
                }
            }catch(Exception e){
                System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
            }
            return null;
    }

    /**
    * @description 
    To get the loan details for ezcred loan application
    * @author shubhranshu | 08-21-2020 
    * @param lead_number 
    * @param loan_account_number 
    * @param recordId 
    * @param recordType 
    * @return String 
    **/
    webservice static String getLoanDetails(String lead_number,String loan_account_number,String recordId,String recordType){
            
            // to save the logs
            API_Request__c apiReq = new API_Request__c(); 
            String jsonStringRequest = '{"partner_id": \"'+System.Label.Ezcred_Partner_Id+'\","merchant_id" : null , "loan_account_number": \"'+loan_account_number+'\","lead_id": \"'+lead_number+'\"}';
            apiReq.Request__c = jsonStringRequest;
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();

            req.setEndpoint(System.Label.Ezcred_API+'loan/details');
            req.setMethod('POST');
            String client_id = System.Label.Ezcred_auth_username;
            String client_secret = System.Label.Ezcred_auth_password;
            Blob headerValue = Blob.valueOf(client_id+':'+client_secret);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Cache-Control','no-cache');
            req.setBody(jsonStringRequest);

            System.debug('jsonStringRequest---'+jsonStringRequest);
            try{
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('LoanApplications_API__c:statusCode = '+statusCode);
                if(statusCode == 200){
                    String result = resp.getBody();
                    System.debug('result ==>'+result);
                    apiReq.Response__c = result;
                    apiReq.API_Name__c = 'GetLoanDetailsAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    
                    Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
                    if(!mapOfResponseParameters.isEmpty()){
                        List<Object> loans_details = (List<Object>)mapOfResponseParameters.get('loans_details');
                        Map<String,Object> mapOfReturnStatus = (Map<String,Object>)mapOfResponseParameters.get('return_status');
                        Map<String,Object> mapOfLoanDetails = (Map<String,Object>)loans_details[0];
                        if(!mapOfLoanDetails.isEmpty()){
                            System.debug('mapOfLoanDetails '+mapOfLoanDetails.get('status'));
                        }
                        if(mapOfReturnStatus.get('status') == 'SUCCESS' && !mapOfLoanDetails.isEmpty()){
                            System.debug('status ==>'+mapOfReturnStatus.get('status'));
                            apiReq.Success__c = true;
                            System.debug('apiReq '+apiReq);
                            apiRequestsInsertion(apiReq);
                            return string.valueOf(mapOfLoanDetails.get('status'));
                        }else {
                            System.debug('apiReq '+apiReq);
                            apiRequestsInsertion(apiReq);
                        }
                    }
                }else{
                    System.debug('LoanApplications_API__c Error :'+resp.getBody());
                    apiReq.Response__c = resp.getBody();
                    apiReq.API_Name__c = 'GetLoanDetailsAPI';
                    apiReq.Type_of_Request__c = 'EzCred';
                    if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }else{
                        apiReq.Opportunity__c = recordId;
                    }
                    apiRequestsInsertion(apiReq);
                }
            }catch(Exception e){
                System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
            }
            return null;
    }
    
    /**
    * @description 
    To insert the logs for Ezcred loan services
    * @author shubhranshu | 08-21-2020 
    * @param apiRequest 
    **/
    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                System.debug('apiRequest ==>'+apiRequest);
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }
}