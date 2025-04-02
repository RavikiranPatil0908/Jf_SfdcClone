/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-20-2020
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-20-2020   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class CaptureLeadStatusTracker {
    
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

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Datetime newDate = Datetime.now().addDays(-7);
        Test.setCreatedDate(objLead.Id, newDate);
        System.debug(objLead.CreatedDate);
    }

    static testmethod void testSuccessBatch(){ 
        Test.startTest();
            CaptureLeadStatus batchClass = new CaptureLeadStatus();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }
}