/**
 * @description       : Unit tests for the DocumentPageController class.
 * @author            : Ravi
 * @group             : Test
 * @last modified on  : 10-17-2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData = false)
public with sharing class DocumentPageControllerTracker {

    @TestSetup
    static void setupTestData() {
        // Create test data for Leads and Accounts
        Lead testLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
        Account testAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes', false, 'Confirmed');

        nmGenericTracker.CreatedDocumentForLead(testLead, 'Aadhaar Card');
        nmGenericTracker.CreateDocumentforAccount(testAccount, 'Photo ID proof');
    }

    /**
    * @description Test setting and retrieving object ID and type for Lead
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void testSetObjectIdForLead() {
        Lead leadRecord = [SELECT Id FROM Lead LIMIT 1];
        DocumentPageController controller = new DocumentPageController();

        Test.startTest();
        controller.setObjectType('Lead');
        controller.setObjectId(leadRecord.Id);
        Test.stopTest();

        // Validate that the object type and ID are set correctly
        System.assertEquals('Lead', controller.getObjectType(), 'Object Type should be Lead');
        System.assertEquals(leadRecord.Id, controller.getObjectId(), 'Object ID should match the lead record ID');
    }

    /**
    * @description Test setting and retrieving object ID and type for Account
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void testSetObjectIdForAccount() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        DocumentPageController controller = new DocumentPageController();

        Test.startTest();
        controller.setObjectType('Account');
        controller.setObjectId(accountRecord.Id);
        String objectType = controller.getObjectType();
        Id objectId = controller.getObjectId();
        Test.stopTest();

        // Validate that the object type and ID are set correctly
        System.assertEquals('Account', objectType, 'Object Type should be Account');
        System.assertEquals(accountRecord.Id, objectId, 'Object ID should match the account record ID');
    }

    /**
    * @description Test color code retrieval based on document status
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void testGetColorCode() {
        DocumentPageController controller = new DocumentPageController();

        Test.startTest();
        String colorForDisapproved = controller.getColorCode('Disapproved');
        String colorForSubmitted = controller.getColorCode('Submitted');
        String colorForApproved = controller.getColorCode('Approved');
        String colorForUnknownStatus = controller.getColorCode('Some Other Status');
        Test.stopTest();

        // Validate the color codes for different statuses
        System.assertEquals('#FF0000', colorForDisapproved, 'Color for Disapproved status should be red');
        System.assertEquals('#FFBF00', colorForSubmitted, 'Color for Submitted status should be yellow');
        System.assertEquals('#50C878', colorForApproved, 'Color for Approved status should be green');
        System.assertEquals('#555', colorForUnknownStatus, 'Color for unknown status should be white');
    }

    /**
    * @description Test the DocumentWrapper inner class
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void testDocumentWrapper() {
        Test.startTest();
        DocumentPageController.DocumentWrapper documentWrapper = new DocumentPageController.DocumentWrapper();
        Test.stopTest();

        // Validate the DocumentWrapper instance initialization
        System.assertNotEquals(null, documentWrapper, 'DocumentWrapper instance should be created');
    }

    @isTest
    static void unitTest() {
        List<Lead> lstLead = [SELECT Id,Name,Email,MobilePhone FROM Lead LIMIT 1];
        Test.startTest();

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"data":{"client_id":"digilocker_hsollJVewlulYVIjflMM","token":"test","url":"https://google.com","expiry_seconds":1200},"status_code":200,"message_code":"success","message":"Success","success":true}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DocumentPageControllerTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        nm_LinksForDocumentsLead__c leadDoc = [SELECT id FROM nm_LinksForDocumentsLead__c LIMIT 1]; 
        DocumentPageController objDocument = new DocumentPageController();
        DocumentPageController.FormDetails objDetails = new DocumentPageController.FormDetails();
        objDocument.getPickListValuesOfUploadMode();
        objDocument.jsonDocumentModeList = '[{"recordId":"'+leadDoc.Id+'","name":"Sample Name","objType":"Lead","modeOfUpload":"Upload via DigiLocker"},{"recordId":"'+leadDoc.Id+'","name":"Sample Name","objType":"Lead","modeOfUpload":"Upload Self-Attested Now"}]';
        objDocument.submitUploadMode();
        objDetails.studentName = lstLead[0].Name;
        objDetails.studentEmail = lstLead[0].Email;
        objDetails.studentMobile = lstLead[0].MobilePhone;
        objDetails.selectedDocuments = 'test';
        objDocument.objDocumentDetails = objDetails;
        objDocument.submitUploadMode();
        objDocument.jsonDocumentModeList ='';
        objDocument.submitUploadMode();
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        List<Lead> lstLead = [SELECT Id,Name,Email,MobilePhone FROM Lead LIMIT 1];
        List<Account> lstAccount = [SELECT Id FROM Account LIMIT 1];
        DocumentPageController.FormDetails objDetails = new DocumentPageController.FormDetails();
        Test.startTest();
        DocumentPageController objDocument = new DocumentPageController();
        //for Lead
        nm_LinksForDocumentsLead__c leadDoc = [SELECT id FROM nm_LinksForDocumentsLead__c LIMIT 1]; 
        objDocument.jsonDocumentModeList = '[{"recordId":"'+leadDoc.Id+'","name":"Sample Name","objType":"Lead","modeOfUpload":"Upload Self-Attested Now"}]';
        objDocument.objectType = 'Lead';
        objDocument.objectId = lstLead[0].Id;
        objDocument.objDocumentDetails = objDetails;
        objDocument.submitUploadMode();
        //for Account
        nm_LinksForDocuments__c accountDoc = [SELECT id FROM nm_LinksForDocuments__c LIMIT 1]; 
        objDocument.jsonDocumentModeList = '[{"recordId":"'+accountDoc.Id+'","name":"Sample Name","objType":"Lead","modeOfUpload":"Upload Self-Attested Now"}]';
        objDocument.objectType = 'Account';
        objDocument.objectId = lstAccount[0].Id;
        objDocument.objDocumentDetails = objDetails;
        objDocument.submitUploadMode();

        objDocument.isDocumentFetched = true;
        DigilockerListDocumentWrapper objWrapper = new DigilockerListDocumentWrapper();
        List<DigilockerListDocumentWrapper.Documents> lstDoc = new List<DigilockerListDocumentWrapper.Documents>();

        DigilockerListDocumentWrapper.Documents objDoc = new DigilockerListDocumentWrapper.Documents();
        objDoc.file_id = '12322';
        objdoc.name = 'doc1';
        DigilockerListDocumentWrapper.Data objData = new DigilockerListDocumentWrapper.Data();
        lstDoc.add(objDoc);
        objData.documents = lstDoc;
        objWrapper.data = objData;
        
        objDocument.objListDocuments = objWrapper;
        objDocument.getJsonMapOfFetchedFiles();
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        Test.startTest();
            List<Lead> lstLead = [SELECT Id,Name,Email,MobilePhone FROM Lead LIMIT 1];
            DocumentPageController objDocument = new DocumentPageController();
            objDocument.saveFileLinks();
            objDocument.jsonDocumentList = '[]';
            objDocument.saveFileLinks();
        Test.stopTest();
    }

    @isTest
    static void unitTest4() { 
        Test.startTest();
            List<Lead> lstLead = [SELECT Id,Name,Email,MobilePhone FROM Lead LIMIT 1];
            Id recordId = lstLead[0].Id;
            nm_LinksForDocumentsLead__c leadDoc = [SELECT id FROM nm_LinksForDocumentsLead__c LIMIT 1]; 
            ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP', '192.168.1.1');
            ApexPages.currentPage().getHeaders().put('USER-AGENT', 'TestUserAgent');
            ApexPages.currentPage().getCookies().put('JSESSIONID', new Cookie('JSESSIONID', 'oldSessionId', null, 0, true, 'None'));
            Map<String, String> mapOfUrlParams = new Map<String, String>{'client_id' => '1234','selectedDocment' =>'Student Photograph'};
            // Act
            SessionManager sessionManager = new SessionManager();
            Boolean result = sessionManager.loginSuccessFull(recordId, 'Lead', mapOfUrlParams);
            
            Test.setMock(HttpCalloutMock.class, new DocumentPageControllerTracker.SaveFileGenerator());

            DocumentPageController objDocument = new DocumentPageController();
            objDocument.clientId = '1234';
            objDocument.setObjectId(recordId);
            objDocument.jsonDocumentList = '[{"recordId":"'+leadDoc.Id+'","name":"Sample Name","objType":"Lead","fileId":"67890","link":"https://example.com/link","awsUrl":"https://aws.amazon.com/sampleurl"}]';
            objDocument.saveFileLinks();
        Test.stopTest();
    }

    @isTest
    static void unitTest5() { 
        Test.startTest();
            List<Account> lstAccount = [SELECT Id FROM Account LIMIT 1];
            Id recordId = lstAccount[0].Id;
            nm_LinksForDocuments__c leadDoc = [SELECT id FROM nm_LinksForDocuments__c LIMIT 1]; 
            ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP', '192.168.1.1');
            ApexPages.currentPage().getHeaders().put('USER-AGENT', 'TestUserAgent');
            ApexPages.currentPage().getCookies().put('JSESSIONID', new Cookie('JSESSIONID', 'oldSessionId', null, 0, true, 'None'));
            Map<String, String> mapOfUrlParams = new Map<String, String>{'client_id' => '1234','selectedDocment' =>'Student Photograph'};
            // Act
            SessionManager sessionManager = new SessionManager();
            Boolean result = sessionManager.loginSuccessFull(recordId, 'Account', mapOfUrlParams);
            
            Test.setMock(HttpCalloutMock.class, new DocumentPageControllerTracker.SaveFileGenerator());

            DocumentPageController objDocument = new DocumentPageController();
            objDocument.clientId = '1234';
            objDocument.setObjectId(recordId);
            objDocument.jsonDocumentList = '[{"recordId":"'+leadDoc.Id+'","name":"Sample Name","objType":"Account","fileId":"67890","link":"https://example.com/link","awsUrl":"https://aws.amazon.com/sampleurl"}]';
            objDocument.saveFileLinks();
        Test.stopTest();
    }
    
    @isTest 
    @testVisible
    static void unitTest6(){
        Test.startTest();
          DocumentPageController.SelectedDocumentData data =new DocumentPageController.SelectedDocumentData();
        Test.stopTest();
    }

    // Helper class to mock HTTP responses
    private class SaveFileGenerator implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);

            if (req.getEndpoint().contains('/api/v1/digilocker/download-document/')) {
                // Mock response for the first API call
                mockResponse.setBody('{"data":{"download_url":"www.google.com","mime_type":"application/pdf"},"status_code":200,"success":true,"message":"Success","message_code":"success"}');
            } else if (req.getEndpoint().contains('studentportal/m/getCloudfrontUrlOnFileUpload')) {
                // Mock response for the second API call
                mockResponse.setStatusCode(200);
                mockResponse.setBody('{"id":"TestUser","links":[{"fileUrl":"www.google.com","awsUrl":"www.google.com"}],"message":null,"error":false}');
            } else {
                // Default response in case no matching endpoint is found
                mockResponse.setStatusCode(404);
            }

            return mockResponse;
        }
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse response) {
            mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}