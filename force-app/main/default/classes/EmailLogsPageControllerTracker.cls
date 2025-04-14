/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 08--04--2025
 * @last modified by  : @Ravi
**/

@isTest(SeeAllData=false)
public class EmailLogsPageControllerTracker {

    @TestSetup
    static void makeData(){
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
    }

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status": "success", "response": [' +
                '{"registrationNumber": "123456789","createdDate": "2024-11-13T15:39:57Z",' +
                '"subject": "TERM 1","fromEmailId": "donotreply.cdoe@nmims.edu",' +
                '"mailId": "test@gmail.com.invalid","body": "<html><body><p>Test Email</p></body></html>"}]}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockII implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500);
            res.setBody('{"status":"error", "message":"Internal Server Error"}');
            return res;
        }
    }

    @isTest
    static void unitTest1() { 
       
        Lead objLead = [select id, nm_RegistrationNo__c from Lead limit 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());

        EmailLogsPageController controller = new EmailLogsPageController();
        controller.setObjectType('Lead');
        controller.getObjectType();
        controller.getRecordId();
        Test.startTest();
        controller.setRecordId(objLead.id);
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        Account objAcc = [select id, nm_RegistrationNumber__c from Account limit 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        EmailLogsPageController controller = new EmailLogsPageController();
        Test.startTest();
        controller.setObjectType('Account');
        controller.setRecordId(objAcc.id);
        Integer firstPage = controller.currentPage;
        controller.nextPage();
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        Account objAcc = [select id, nm_RegistrationNumber__c from Account limit 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());

        EmailLogsPageController controller = new EmailLogsPageController();
        Test.startTest();
        controller.setRecordId(objAcc.id);
        controller.nextPage();
        Integer nextPage = controller.currentPage;
        controller.previousPage();
        Test.stopTest();
    }

    @isTest
    static void testAPIFailure() {
    Test.startTest();
    EmailLogsPageController.Responsedata responseData = new EmailLogsPageController.Responsedata();
    responseData.registrationNumber='123456789';
    responseData.parentId = '001In000005G3Ka';
    responseData.createdDate = '2024-11-13T15:39:57Z';
    responseData.subject = 'Test Subject';
    responseData.fromEmailId = 'test@example.com';
    responseData.mailId = 'test@gmail.com';
    responseData.body = '<html><body><p>Test Email</p></body></html>';
    responseData.serialNumber = 1;
    Test.stopTest();
}

}