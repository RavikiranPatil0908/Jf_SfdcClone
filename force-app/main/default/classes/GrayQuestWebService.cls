/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-01-2025
 * @last modified by  : @BK
**/
global without sharing class GrayQuestWebService {

    private static final String API_KEY_HEADER = 'GQ-API-Key';
    private static final String AUTHORIZATION_HEADER = 'Authorization';
    
    /**
    * @description Helper method to build the authorization header
    * @author @BK | 16-11-2024 
    * @param String clientId 
    * @param String clientSecret 
    * @return String 
    **/
    private static String buildAuthorizationHeader(String clientId, String clientSecret) {
        Blob headerValue = Blob.valueOf(clientId + ':' + clientSecret);
        return 'Basic ' + EncodingUtil.base64Encode(headerValue);
    }

    
    /**
    * @description Generalized method to perform HTTP requests
    * @author @BK | 16-11-2024 
    * @param String endpoint 
    * @param String method 
    * @param String body 
    * @param Map<String String> headers 
    * @return HttpResponse 
    **/
    private static HttpResponse sendHttpRequest(String endpoint, String method, String body, Map<String, String> headers) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Cache-Control', 'no-cache');

        // Add other headers
        for (String headerKey : headers.keySet()) {
            req.setHeader(headerKey, headers.get(headerKey));
        }

        if (body != null) {
            System.debug('body---->' + body);
            req.setBody(body);
        }

        Http http = new Http();
        try {
            return http.send(req);
        } catch (Exception e) {
            System.debug('HTTP Request failed: ' + e.getMessage());
            throw new CalloutException('Failed to send HTTP request: ' + e.getMessage());
        }
    }

    
    /**
    * @description General method to handle API request response
    * @author @BK | 16-11-2024 
    * @param API_Request__c apiReq 
    * @param HttpResponse resp 
    * @param String apiName 
    * @param String recordType 
    * @param String recordId 
    **/
    private static void handleApiResponse(API_Request__c apiReq, HttpResponse resp, String apiName, String recordType, String recordId) {
        String result = resp.getBody();
        Integer statusCode = resp.getStatusCode();
        apiReq = setApiRequest(apiReq, result, apiName, recordType, recordId);

        if (statusCode == 200 || statusCode == 201) {
            apiReq.Success__c = true;
        }
        apiRequestsInsertion(apiReq);
    }

    
    /**
    * @description Create Loan Request
    * @author @BK | 16-11-2024 
    * @param String jsonString 
    * @param String recordId 
    * @param String recordType 
    * @return String 
    **/
    webservice static String createGQLoanRequest(String jsonString, String recordId, String recordType) {
        API_Request__c apiReq = new API_Request__c(Request__c = jsonString);
        GrayQuestAPI__c objGrayQuest = GrayQuestAPI__c.getValues('GrayQuestLoanData');

        String authorizationHeader = buildAuthorizationHeader(objGrayQuest.Client_id__c, objGrayQuest.Client_Secret__c);
        Map<String, String> headers = new Map<String, String>{
            AUTHORIZATION_HEADER => authorizationHeader,
            API_KEY_HEADER => objGrayQuest.API_KEY__c
        };

        String endpoint = objGrayQuest.Grayquest_APILink__c + '/v1/pp/redirect/' + objGrayQuest.Slug__c;
        
        // Handling exception with try-catch block
        HttpResponse resp;
        try {
            resp = sendHttpRequest(endpoint, 'POST', jsonString, headers);
        } catch (CalloutException e) {
            System.debug('Error during callout: ' + e.getMessage());
            // Return an appropriate response or handle the error
            return null;
        }

        handleApiResponse(apiReq, resp, 'CreateLeadAPI', recordType, recordId);

        Map<String, Object> mapOfResponseParameters = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        if (mapOfResponseParameters != null && mapOfResponseParameters.containsKey('success')) {
            Boolean loanRecordCreated = Boolean.valueOf(mapOfResponseParameters.get('success'));
            if (loanRecordCreated) {
                return resp.getBody();
            }
        }
        return null;
    }

    
    /**
    * @description Cancel Loan
    * @author @BK | 16-11-2024 
    * @param String applicationId 
    * @param String recordId 
    * @param String recordType 
    * @return String 
    **/
    webservice static String cancelLoan(String referenceId, String studentId, String recordId, String recordType) {
        return processLoanAction(referenceId, studentId, recordId, recordType, 'institute-reject', 'CancelLoanAPI');
    }

    
    /**
    * @description Approve Loan
    * @author @BK | 16-11-2024 
    * @param String applicationId 
    * @param String recordId 
    * @param String recordType 
    * @return String 
    **/
    webservice static String approvedLoan(String applicationId, String recordId, String recordType) {
        return processLoanAction(applicationId,'', recordId, recordType, 'institute-approval', 'Approved/DisburseLoanAPI');
    }

    
    /**
    * @description General method to handle both cancel and approve loan actions
    * @author @BK | 16-11-2024 
    * @param String applicationId 
    * @param String recordId 
    * @param String recordType 
    * @param String action 
    * @param String apiName 
    * @return String 
    **/
    private static String processLoanAction(String applicationId, String studentId, String recordId, String recordType, String action, String apiName) {
        GrayQuestAPI__c objGrayQuest = GrayQuestAPI__c.getValues('GrayQuestLoanData');
        String authorizationHeader = buildAuthorizationHeader(objGrayQuest.Client_id__c, objGrayQuest.Client_Secret__c);
        Map<String, String> headers = new Map<String, String>{
            AUTHORIZATION_HEADER => authorizationHeader,
            API_KEY_HEADER => objGrayQuest.API_KEY__c
        };

        String formDataURL = '';
        if(action == 'institute-approval') {
            formDataURL = '{"application_id" : ' + applicationId + ', "comment": "Application Approved", "institute_deviation": true}';
        } else {
            formDataURL = '{"reference_id":"' + applicationId + '","student_id":"' + studentId + '","comment":"Application Rejected"}';
        }
        String endpoint = objGrayQuest.Grayquest_APILink__c + '/v1/applications/approval/' + action;

        HttpResponse resp;
        try {
            resp = sendHttpRequest(endpoint, 'POST', formDataURL, headers);
        } catch (CalloutException e) {
            System.debug('Error during callout: ' + e.getMessage());
            // Return an appropriate response or handle the error
            return null;
        }

        API_Request__c apiReq = new API_Request__c(Request__c = formDataURL);
        handleApiResponse(apiReq, resp, apiName, recordType, recordId);

        return resp.getBody();
    }

    
    /**
    * @description Check Application Status
    * @author @BK | 16-11-2024 
    * @param String applicationId 
    * @param String requestKey 
    * @param String recordId 
    * @param String recordType 
    * @return String 
    **/
    webservice static String checkApplicationStatus(String applicationId, String requestKey, String recordId, String recordType) {
        GrayQuestAPI__c objGrayQuest = GrayQuestAPI__c.getValues('GrayQuestLoanData');
        String authorizationHeader = buildAuthorizationHeader(objGrayQuest.Client_id__c, objGrayQuest.Client_Secret__c);
        Map<String, String> headers = new Map<String, String>{
            AUTHORIZATION_HEADER => authorizationHeader,
            API_KEY_HEADER => objGrayQuest.API_KEY__c
        };

        String endpoint = objGrayQuest.Grayquest_APILink__c + '/v1/applications/check-status?' + requestKey + '=' + applicationId;

        HttpResponse resp;
        try {
            resp = sendHttpRequest(endpoint, 'GET', null, headers);
        } catch (CalloutException e) {
            System.debug('Error during callout: ' + e.getMessage());
            // Return an appropriate response or handle the error
            return null;
        }

        API_Request__c apiReq = new API_Request__c();
        handleApiResponse(apiReq, resp, 'StatusCheck', recordType, recordId);

        GQStatusResponseWrapper respWrapper = GQStatusResponseWrapper.parse(resp.getBody());
        if (respWrapper != null && respWrapper.success) {
            return resp.getBody();
        }

        return null;
    }

    
    /**
    * @description Utility method to set API request details
    * @author @BK | 16-11-2024 
    * @param API_Request__c apiReq 
    * @param String result 
    * @param String apiName 
    * @param String recordType 
    * @param String recordId 
    * @return API_Request__c 
    **/
    public static API_Request__c setApiRequest(API_Request__c apiReq, String result, String apiName, String recordType, String recordId) {
        apiReq.Response__c = result;
        apiReq.API_Name__c = apiName;
        apiReq.Type_of_Request__c = 'GrayQuest';
        if (recordType == 'Lead') {
            apiReq.Lead__c = recordId;
        } else {
            apiReq.Opportunity__c = recordId;
        }
        return apiReq;
    }

    
    /**
    * @description Insert API Request record
    * @author @BK | 16-11-2024 
    * @param API_Request__c apiRequest 
    **/
    public static void apiRequestsInsertion(API_Request__c apiRequest) {
        if (apiRequest != null) {
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug('Error inserting API Request: ' + e.getMessage());
            }
        }
    }

    // Custom exception for handling callout failures
    public class CalloutException extends Exception {}

    webservice static String ProductRequest(String recordId,String recordType){
        //     API_Request__c apiReq = new API_Request__c();
        //     GrayQuestAPI__c objGrayQuest = GrayQuestAPI__c.getValues('GrayQuestLoanData');
            
        //     String client_id = objGrayQuest.Client_id__c;
        //     String client_secret = objGrayQuest.Client_Secret__c;
        //     Blob headerValue = Blob.valueOf(client_id+':'+client_secret);
        //     String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        //     nm_Centers__c objcenter = [select id ,Name,Email__c , IC_Company_Name__c,GrayQuest_Sync__c,Contact_No_1__c from nm_Centers__c where id=:recordId and GrayQuest_Sync__c =false];
        //     list<nm_Centers__c> lsttoupdate = new List<nm_Centers__c>();
            
        //     HttpRequest req = new HttpRequest();
        //     HttpResponse resp = new HttpResponse();
        //     Http http = new Http();
        //     Map<String,String> mapOfParametersToPass =new Map<String,String>();
        //     mapOfParametersToPass.put('group_name',objcenter.IC_Company_Name__c);
        //     mapOfParametersToPass.put('institute_name','NMIMS');
        //     mapOfParametersToPass.put('location',objcenter.Name);
        //     mapOfParametersToPass.put('board','NA');
        //     mapOfParametersToPass.put('user_name',objcenter.Name);
        //     mapOfParametersToPass.put('user_email',objcenter.Email__c);
        //     mapOfParametersToPass.put('user_mobile',objcenter.Contact_No_1__c);
        //     string jsonstring = JSON.serialize(mapOfParametersToPass);
        //     req.setEndpoint(objGrayQuest.Grayquest_APILink__c+'/v1/product/product-request');
        //     req.setMethod('POST');
        //     //req.setHeader('Content-Type','multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
        //     req.setHeader('Authorization', authorizationHeader);
        //     req.setHeader('GQ-API-Key', objGrayQuest.API_KEY__c);
        //     req.setHeader('content-type', 'application/json');
        //     req.setHeader('Cache-Control','no-cache');
        //     req.setBody(jsonString);
            
        //     try{
        //         resp = http.send(req);
        //             Integer statusCode = resp.getStatusCode();
        //             System.debug('Product API Request:statusCode = '+statusCode);
        //             if(statusCode == 201 || statusCode == 200 ){
        //                 String result = resp.getBody();
        //                 System.debug('result ==>'+result);
        //                 apiReq.Response__c = result;
        //                 apiReq.Request__c = jsonString;
        //                 apiReq.API_Name__c = 'Product Request';
        //                 apiReq.Type_of_Request__c = 'GrayQuest';
        //                 if(recordType == 'Center'){
        //                     apiReq.Centers__c = recordId;
        //                 }
                        
        //                 Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        //                 if(!mapOfResponseParameters.isEmpty()){
        //                     Boolean LoanRecordCreated = Boolean.valueOf(mapOfResponseParameters.get('success'));
        //                     System.debug('Product Request ==>'+LoanRecordCreated);
        //                     if(LoanRecordCreated){
        //                         apiReq.Success__c = true;
        //                         objcenter.GrayQuest_Sync__c =true;
        //                         lsttoupdate.add(objcenter);
        //                         System.debug('apiReq '+apiReq);
        //                         apiRequestsInsertion(apiReq);
        //                         if(lsttoupdate.size()>0)
        //                         {
        //                             update lsttoupdate;
        //                         }
        //                         return result;
        //                     }else {
        //                         System.debug('apiReq '+apiReq);
        //                         apiRequestsInsertion(apiReq);
        //                     }
        //                 }

        //             }else{
        //                 System.debug('Product Request Error :'+resp.getBody());
        //                 apiReq.Response__c = resp.getBody();
        //                 apiReq.API_Name__c = 'Product Request';
        //                 apiReq.Type_of_Request__c = 'GrayQuest';
        //                 if(recordType == 'Center'){
        //                      apiReq.Centers__c = recordId;
        //                 }
        //                 apiRequestsInsertion(apiReq);
        //             }
        //     }
        //     catch (Exception e){
        //         System.debug('Callout Exception LoanProductRequest_API__c :'+e.getMessage());
        //     }
        return null;
    }

    webservice static Integer CreateCustomer(String customer_mobile,String recordId,String recordType){
    
        //     API_Request__c apiReq = new API_Request__c();
        //     GrayQuestAPI__c objGrayQuest = GrayQuestAPI__c.getValues('GrayQuestLoanData');
            
        //     String client_id = objGrayQuest.Client_id__c;
        //     String client_secret = objGrayQuest.Client_Secret__c;
        //     Blob headerValue = Blob.valueOf(client_id+':'+client_secret);
        //     String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        //  //  String formDataURL = 'application_id='+application_id+'&institute-reject=Institute Reject';
        //   String formDataURL = 'customer_mobile='+customer_mobile;
        //     HttpRequest req = new HttpRequest();
        //     HttpResponse resp = new HttpResponse();
        //     Http http = new Http();
        //      System.debug('formDataURL --->'+formDataURL ); 
        //     req.setEndpoint(objGrayQuest.Grayquest_APILink__c+'/v1/customer/create-customer');
        //     //req.setEndpoint('https://erp-api.graydev.tech/v1/applications/approval/institute-reject');
        //     req.setMethod('POST');
        //     //req.setHeader('Content-Type','multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
        //     req.setHeader('Accept','application/json');
        //     req.setHeader('GQ-API-Key', objGrayQuest.API_KEY__c);
        //     req.setHeader('Authorization', authorizationHeader);
        //     req.setBody(formDataURL);
    
           
        //     try{
        //         resp = http.send(req);
        //             Integer statusCode = resp.getStatusCode();
        //             System.debug('LoanApplications_API__c:statusCode = '+statusCode);
        //             if(statusCode == 201 || statusCode == 200){
        //                 String result = resp.getBody();
        //                 System.debug('result ==>'+result);
        //                 apiReq.Response__c = result;
        //                 apiReq.API_Name__c = 'CreateCustomer';
        //                 apiReq.Type_of_Request__c = 'GrayQuest';
        //                 if(recordType == 'Lead'){
        //                     apiReq.Lead__c = recordId;
        //                 }else{
        //                     apiReq.Opportunity__c = recordId;
        //                 }
                        
        //                // Map<String,Object> mapOfResponseParameters = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        //                 GrayQuestWrapper respWrapper = GrayQuestWrapper.parse(result);
        //                  if(respWrapper!=null && respWrapper.success && respWrapper.data.customer_id>0) {
        //                     Boolean Customer = respWrapper.success;
        //                     System.debug('Customer ==>'+Customer);
        //                     if(Customer){
        //                         apiReq.Success__c = true;
        //                         System.debug('apiReq '+apiReq);
        //                        // apiRequestsInsertion(apiReq);
        //                        // system.debug('respWrapper.data.customer_id---->'+respWrapper.data.customer_id);
        //                         return respWrapper.data.customer_id;
        //                     }else {
        //                         System.debug('apiReq '+apiReq);
        //                        // apiRequestsInsertion(apiReq);
        //                     }
        //                 }
    
        //             }else{
        //                 System.debug('LoanApplications_API__c Error :'+resp.getBody());
        //                 apiReq.Response__c = resp.getBody();
        //                 apiReq.API_Name__c = 'CreateCustomer';
        //                 apiReq.Type_of_Request__c = 'GrayQuest';
        //                 if(recordType == 'Lead'){
        //                     apiReq.Lead__c = recordId;
        //                 }else{
        //                     apiReq.Opportunity__c = recordId;
        //                 }
        //              //   apiRequestsInsertion(apiReq);
        //             }
    
        //     }
        //     catch (Exception e){
        //         System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
        //     }
        return null;
    }
}