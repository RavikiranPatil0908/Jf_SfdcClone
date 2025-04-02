@isTest(SeeAllData=false)
public with sharing class BankVerificationWebServiceTracker {
    @TestSetUp
    public static void setUpData(){
        nmSerialNo__c objSerial = new nmSerialNo__c();
        objSerial.nm_MaxGenratedNo__c=122355;
        objSerial.nm_name__c= 'Reference Number';
        insert objSerial;
         
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        objopp.nm_Year__c = 2017;
        objopp.nm_Session__c = 'January';
        update objOpp;
        nmRefund_Payment__c objRefund = new nmRefund_Payment__c();
        objRefund.nm_Amount__c = 200;
        objRefund.nm_Payment_Status__c = 'Refund Initiated';      
        objRefund.Opportunity__c = objopp.id;
        objRefund.Account__c = objAccount.id;
        objRefund.nm_Transaction_Date__c = system.today();
        objRefund.Reason_For_Refund__c = 'Test';
        objRefund.Refund_transfer_Mode__c = 'Same A/c from which payment was made';
        objRefund.Type_of_Refund__c = 'Admission Rejected';
        objRefund.Status__c = 'Application Send to Student';
        insert objRefund;
    }

    public static testMethod void unitTest31() {
        Test.startTest();
        nmRefund_Payment__c objRef = [SELECT Id FROM nmRefund_Payment__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        BankVerificationWebService.verifyBankDetailsByCashFree('a', 'b', 'c', String.valueOf(objRef.Id) );
        Test.stopTest();
    }

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"status":"SUCCESS","subCode":"200","message":"Bank Account details verified successfully","accountStatus":"VALID","accountStatusCode":"ACCOUNT_IS_VALID","data":{"nameAtBank":"NISHA JESWANI","refId":"647003964","bankName":"HDFC BANK","utr":"319317281654","city":"MUMBAI","branch":"TULSIANI CHMBRS - NARIMAN PT","micr":0,"nameMatchScore":"0","nameMatchResult":"-"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}