/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-15-2020
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   12-01-2020   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class UpdateSelectionAdmisionDateBatchTracker {
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
    public static void setUpData() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        NM_Payment_Form_Configuration__c objcon = new NM_Payment_Form_Configuration__c();
        objcon.Payment_Type__c = 'Admission';
        objcon.Current_Admission_Year__c = '2019';
        objcon.Program_Type__c='MBA (WX)';
        objcon.Payment_Window_EndDate__c = System.now().addDays(5);
        objcon.Session__c = 'January';
        objcon.Update_Selection_Admision_Date__c = true;
        objcon.DownPayment_Amount__c = 5000;
        insert objcon;

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
        objAccount.Interview_Status__c = 'Selected';
        objAccount.nm_Drive_Name__c = 'January2019';
        objAccount.Program_Type__c = 'MBA (WX)';
        objAccount.Selection_InitialDate__c = System.today();
        objAccount.Selection_AdmissionDate__c = System.today();
        objAccount.Interview_status_update_date__c = System.today();
        update objAccount;
    }

    @isTest
    static void testUnit1() {
        Test.startTest();
            UpdateSelectionAdmisionDateBatch batchClass = new UpdateSelectionAdmisionDateBatch();
            Database.executeBatch(batchClass,5);
        Test.stopTest();
    }
}