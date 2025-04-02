/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 31-01-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class UpdateCaseOwnerTracker {
    
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

    @testSetup
    public static void setUpData(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Case> lstCase = nmCaseTriggerHandlerTracker.loadData();
        insert lstCase;
    }

    @isTest 
    static void unitTest1(){ 
        List<Case> lstCase = [SELECT Id FROM Case WHERE FirstCaseAssigned__c!=null LIMIT 1];
        Test.startTest();
            Boolean isupdated = UpdateCaseOwner.caseTransfer(lstCase[0].Id);
            System.assert(isupdated, 'Case has been Transfered.');
        Test.stopTest();
    }

    @isTest 
    static void unitTest2(){ 
        Test.startTest();
            Boolean isupdated = UpdateCaseOwner.caseTransfer(null);
            System.assert(!isupdated, 'Case Record Does not exists.');
        Test.stopTest();
    }
}