@isTest
public with sharing class AnnualFeeToPGAllSemFeeWebService_Test {

    @TestSetup
    static void makeData(){
        nmGenericTracker.CreateCenter('Mumbai');
    }
    	private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @IsTest
    static void methodName(){

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        List<nm_Centers__c> ce = [SELECT Id from nm_Centers__c limit 1];
        AnnualFeeToPGAllSemFeeWebService.deleteRecord(ce[0].Id, 'Opportunity');
        Test.stopTest();
        
    }

}