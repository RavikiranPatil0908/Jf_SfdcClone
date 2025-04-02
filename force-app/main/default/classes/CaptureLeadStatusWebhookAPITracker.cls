/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 09-12-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-11-2020   shubhranshu   Initial Version
**/
@isTest
public class CaptureLeadStatusWebhookAPITracker {

    public static Lead objLead;
    private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    /**
    * @description 
    set up the records for testing purpose
    * @author shubhranshu | 09-12-2020 
    **/
    @testSetup
    public static void setUpData(){
		Test.setMock(HttpCalloutMock.class, new RestMock());
		nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    /**
    * @description 
    testing for 7 days lead status capture
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'7','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 7 days lead status capture without header
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus1(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestDatawithoutHeader(ld.Id,'7','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    
    /**
    * @description 
    testing for 15 days lead status capture
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus2(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'15','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 30 days lead status capture 
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus3(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'30','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 60 days lead status capture 
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus4(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'60','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 90 days lead status capture 
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus5(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'90','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 180 days lead status capture
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus6(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'180','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 180 days lead status capture with invalid lead id
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus7(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData('123','180','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 180 days lead status capture without parameters
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus8(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestDataWithoutParameters(ld.Id,'180','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for 180 days lead status capture with Invalid headers
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus9(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestDataInvalidHeaders(ld.Id,'180','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }

    /**
    * @description 
    testing for invalid lead stage 
    * @author shubhranshu | 09-12-2020 
    * @return testMethod 
    **/
    static testMethod void testcaptureLeadStatus10(){
        Lead ld=[Select Id, Status,FirstName,LastName, Email,MobilePhone,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,
                 Status_after_60_days__c,Status_after_90_days__c,Status_after_180_days__c FROM Lead LIMIT 1];
        Test.startTest();     
        RequestData(ld.Id,'360','POST');
		CaptureLeadStatusWebhookAPI.captureLeadStatus();
		Test.stopTest();
    }
    
    /**
    * @description 
    returns the sample request and response for captureleadstatus API
    * @author shubhranshu | 09-12-2020 
    * @param leadId 
    * @param LeadSatge 
    * @param requestMethod 
    **/
    public static void RequestData(String leadId,String LeadSatge,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/getLeadStatus/V.1.0';
        request.httpMethod=requestMethod;
        request.headers.put('consumerkey','a9a2d99b5c7929f013632225f76d7d84');
        request.headers.put('consumersecret','5a1d22e803c015d11201ccaa2b929888');
        request.params.put('leadId',leadId);
        request.params.put('LeadStage',LeadSatge);
        RestContext.request = request;
		RestContext.response = response;
    }

    /**
    * @description 
    returns invalid headers request and response for captureleadstatus API
    * @author shubhranshu | 09-12-2020 
    * @param leadId 
    * @param LeadSatge 
    * @param requestMethod 
    **/
    public static void RequestDataInvalidHeaders(String leadId,String LeadSatge,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/getLeadStatus/V.1.0';
        request.httpMethod=requestMethod;
        request.headers.put('consumerkey','a9a2d99b5c7929f013632225f76d7d8');
        request.headers.put('consumersecret','5a1d22e803c015d11201ccaa2b92988');
        request.params.put('leadId',leadId);
        request.params.put('LeadStage',LeadSatge);
        RestContext.request = request;
		RestContext.response = response;
    }

    /**
    * @description 
    returns the invalid parameters request and reponse for captureleadstatus API
    * @author shubhranshu | 09-12-2020 
    * @param leadId 
    * @param LeadSatge 
    * @param requestMethod 
    **/
    public static void RequestDataWithoutParameters(String leadId,String LeadSatge,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/getLeadStatus/V.1.0';
        request.httpMethod=requestMethod;
        request.headers.put('consumerkey','a9a2d99b5c7929f013632225f76d7d84');
        request.headers.put('consumersecret','5a1d22e803c015d11201ccaa2b929888');
        request.params.put('leadId','');
        request.params.put('LeadStage','');
        RestContext.request = request;
		RestContext.response = response;
    }
    
    /**
    * @description 
    returns the invalid headers request and resposne for captureleadstatus API
    * @author shubhranshu | 09-12-2020 
    * @param leadId 
    * @param LeadSatge 
    * @param requestMethod 
    **/
    public static void RequestDatawithoutHeader(String leadId,String LeadSatge,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/getLeadStatus/V.1.0';
        request.httpMethod=requestMethod;
        request.headers.put('consumerkey','');
        request.headers.put('consumersecret','');
        request.params.put('leadId',leadId);
        request.params.put('LeadStage',LeadSatge);
        RestContext.request = request;
		RestContext.response = response;
	}
}