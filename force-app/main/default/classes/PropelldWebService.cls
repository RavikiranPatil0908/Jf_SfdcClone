/**
 * @File Name          : PropelldWebService.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-09-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/4/2020   @BK     Initial Version
**/
public without sharing class PropelldWebService {
    
    public String createNewLoanApplication(
        String orderId,
        String EmailAddress, 
        String firstName,
        String lastName,
        String mobileNumber,
        String callbackUrlBase, 
        decimal totalPrice,
        String tenure,
        String recordId,
        String recordType,
        Integer courseFee,
        String icCode,
        String progCode) {

        String url = nmCommon.getConfigSettings('Propelld_Quote_API__c');
        String propelldClientId = nmCommon.getConfigSettings('Propelld_ClientId__c');
        String propelldClientSecret = nmCommon.getConfigSettings('Propelld_Client_Secret__c');
        
        if(String.isBlank(icCode)) {
            icCode = nmCommon.getConfigSettings('Propelld_Center_Code__c');
        }
        if(String.isBlank(progCode)) {
            progCode = nmCommon.getConfigSettings('Propelld_Program_Code__c');
        }

        if(Test.isRunningTest()) {
            url = System.Label.Site_Url;
            propelldClientId = 'test';
            propelldClientSecret = 'test';
            icCode = '1';
            progCode = '1';
        }

        System.debug('url ==>'+url);
        System.debug('propelldClientId ==>'+propelldClientId);
        System.debug('propelldClientSecret ==>'+propelldClientSecret);
        System.debug('courseFee ==>'+courseFee);

        API_Request__c apiReq = new API_Request__c();
        // Geneartaing request
        Map<String,Object> mapOfRequestParam = new Map<String,Object>();
        mapOfRequestParam.put('CourseId',Integer.valueOf(progCode));
        mapOfRequestParam.put('InstituteId',Integer.valueOf(icCode));
        mapOfRequestParam.put('Email',EmailAddress);
        mapOfRequestParam.put('Mobile', mobileNumber);
        mapOfRequestParam.put('FirstName', firstName);
        mapOfRequestParam.put('LastName', lastName);
        mapOfRequestParam.put('DiscountedCourseFee', courseFee);
        mapOfRequestParam.put('LoanAmount', Integer.valueOf(totalPrice));
        mapOfRequestParam.put('Tenor',Integer.valueOf(tenure));
        mapOfRequestParam.put('ReferenceNumber', orderId);
        mapOfRequestParam.put('RedirectUrl', callbackUrlBase);
        string jsonString = JSON.serialize(mapOfRequestParam);
        apiReq.Request__c = jsonString;

        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setHeader('client-id', propelldClientId);
        req.setHeader('client-secret', propelldClientSecret);
        req.setHeader('Cache-Control','no-cache');
        req.setBody(jsonString);

        System.debug('jsonBody---'+jsonString);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('LoanApplications_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('result ==>'+result);
                apiReq.Response__c = result;
                apiReq.API_Name__c = 'PropelldQuoteAPI';
                apiReq.Type_of_Request__c = 'Propelld';
                if(recordType == 'Lead'){
                    apiReq.Lead__c = recordId;
                } else {
                    apiReq.Opportunity__c = recordId;
                }
                PropelledResponseWrapper responseWrapper = PropelledResponseWrapper.parse(result);
                if(responseWrapper.Code == 0) {
                    apiReq.Success__c = true;
                    System.debug('RedirectionUrl ==>'+responseWrapper.Payload.RedirectionUrl);
                    System.debug('QuoteId ==>'+responseWrapper.Payload.QuoteId);
                    result = JSON.serialize(responseWrapper.Payload);
                    System.debug('apiReq '+apiReq);
                    apiRequestsInsertion(apiReq);
                    return result;
                } else {
                    System.debug('apiReq '+apiReq);
                    apiRequestsInsertion(apiReq);
                }
            }else{
                System.debug('LoanApplications_API__c Error :'+resp.getBody());
                apiRequestsInsertion(apiReq);
            }
        }catch(Exception e){
            System.debug('Callout Exception LoanApplications_API__c :'+e.getMessage());
        }
        return null;
    }

    public String updateStatusByQuoteId(String quoteId, Boolean status, String recordId, String recordType){
        String url = nmCommon.getConfigSettings('Propelld_Status_API__c');
        String propelldClientId = nmCommon.getConfigSettings('Propelld_ClientId__c');
        String propelldClientSecret = nmCommon.getConfigSettings('Propelld_Client_Secret__c');

        if(Test.isRunningTest()) {
            url = System.Label.Site_Url;
            propelldClientId = 'test';
            propelldClientSecret = 'test';
        }
        
        API_Request__c apiReq = new API_Request__c();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setHeader('client-id',propelldClientId);
        req.setHeader('client-secret',propelldClientSecret);
        req.setHeader('Cache-Control','no-cache');
        
        Map<String,Object> mapOfRequestParam = new Map<String,Object>();
        mapOfRequestParam.put('QuoteId',quoteId);
        mapOfRequestParam.put('Approved',status);
        String jsonBody = JSON.serialize(mapOfRequestParam);
        apiReq.Request__c = jsonBody;
        req.setBody(jsonBody);
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Cancellation_API__c:statusCode = '+statusCode);
            if(statusCode == 200){
                System.debug('result ==>'+resp.getBody());
                apiReq.Response__c = resp.getBody();
                apiReq.API_Name__c = 'PropelldApprovalAPI';
                apiReq.Type_of_Request__c = 'Propelld';
                if(recordType == 'Opportunity'){
                    apiReq.Opportunity__c = recordId;
                }else if(recordType == 'Lead'){
                    apiReq.Lead__c = recordId;
                }
                PropelledResponseWrapper responseWrapper = PropelledResponseWrapper.parse(resp.getBody());
                if(responseWrapper.Code == 0 && responseWrapper.Payload.StatusUpdated) {
                    apiReq.Success__c = true;
                    String result = 'Loan application cancelled';
                    System.debug(result);
                    apiRequestsInsertion(apiReq);
                    return result;
                } else {
                    apiRequestsInsertion(apiReq);
                }
            }else{
                System.debug('Cancellation_API__c Error :'+resp.getBody());
                apiRequestsInsertion(apiReq);
            }
        }catch(Exception e){
            System.debug('Callout Exception Cancellation_API__c :'+e.getMessage());
        }
        return 'Loan application cancelled';
    }

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