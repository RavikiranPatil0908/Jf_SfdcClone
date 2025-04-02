/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : @BK
**/
@IsTest(SeeAllData=false)
private class DigilockerWebServiceTracker {

    // Setup test data
    static Id testRecordId;

    @TestSetup
    static void setupTestData() {
        // Creating a test Lead to use its ID in test methods
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        testRecordId = objLead.id;

        // Insert a mock API_Request__c record
        API_Request__c apiRequest = new API_Request__c(
            API_Name__c = 'Test API',
            Request__c = 'Test Request',
            Response__c = 'Test Response',
            Success__c = true,
            Lead__c = testRecordId
        );
        insert apiRequest;
    }

    @IsTest
    static void testInitializeDigilockerSuccess() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Mocking an HTTP response for a successful initialize request
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"data":{"client_id":"digilocker_hsollJVewlulYVIjflMM","token":"test","url":"https://google.com","expiry_seconds":1200},"status_code":200,"message_code":"success","message":"Success","success":true}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DigilockerWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Calling the method
        DigilockerInitializeWrapper response = DigilockerWebService.initializeDigilocker('John Doe', '1234567890', 'john@example.com', lst[0].Id);

        // Asserting the response
        System.assertNotEquals(null, response, 'Response returned Blank');
        System.assertEquals('https://google.com', response.data.url, 'Return URL does not Match');
        Test.stopTest();
    }

    @IsTest
    static void testInitializeDigilockerError() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Mocking an HTTP response for an error scenario
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"data":null,"status_code":404,"success":false,"message":"Client not found","message_code":null}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DigilockerWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Calling the method
        DigilockerInitializeWrapper response = DigilockerWebService.initializeDigilocker('John Doe', '1234567890', 'john@example.com', lst[0].Id);

        // Asserting the response
        System.assertEquals(null, response, 'Response is not Blank');
        Test.stopTest();
    }

    @IsTest
    static void testGetDigilockerOauthStatusSuccess() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Mocking an HTTP response for a successful OAuth status request
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"data":{"error_description":null,"status":"completed","completed":true,"failed":false,"aadhaar_linked":true},"status_code":200,"success":true,"message":"Success","message_code":"success"}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DigilockerWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Calling the method
        Boolean isStatusRetrieved = DigilockerWebService.getDigilockerOauthStatus('client-id', lst[0].Id);

        // Asserting the response
        System.assertEquals(true, isStatusRetrieved, 'Return unverified');
        Test.stopTest();
    }

    @IsTest
    static void testGetDigilockerOauthStatusError() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Mocking an HTTP response for an error scenario
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"data":null,"status_code":404,"success":false,"message":"Client not found","message_code":null}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DigilockerWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Calling the method
        Boolean isStatusRetrieved = DigilockerWebService.getDigilockerOauthStatus('client-id', lst[0].Id);

        // Asserting the response
        System.assertEquals(false, isStatusRetrieved, 'Return verified');
        Test.stopTest();
    }

    @IsTest
    static void testGetListOfDocumentSuccess() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Mocking an HTTP response for a successful list document request
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"data":{"documents":[{"file_id":"digilocker_file_PjorZrpBQQSSbquyTPav","name":"PAN Verification Record","doc_type":"PANCR","downloaded":true,"issuer":"Income Tax Department","description":"PAN Verification Record"}]},"status_code":200,"success":true,"message":"Success","message_code":"success"}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DigilockerWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Calling the method
        DigilockerListDocumentWrapper response = DigilockerWebService.getListOfDocument('client-id', lst[0].Id);

        // Asserting the response
        System.assertNotEquals(null, response, 'Response returned null');
        System.assertEquals(1, response.data.documents.size(), 'Response did not return a filed');
        System.assertEquals('digilocker_file_PjorZrpBQQSSbquyTPav', response.data.documents[0].file_id, 'File id did not match');
        Test.stopTest();
    }

    @IsTest
    static void testGetDigilockerDownloadedDocumentSuccess() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Mocking an HTTP response for a successful document download request
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"data":{"download_url":"https://aadhaar-kyc-docs.s3.amazonaws.com/test/digilocker/digilocker_puWsFhgqyuEpEdEWkxzm","mime_type":"application/pdf"},"status_code":200,"success":true,"message":"Success","message_code":"success"}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DigilockerWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Calling the method
        DigilockerDocumentDownloadWrapper response = DigilockerWebService.getDigilockerDownloadedDocument('client-id', 'file-id', lst[0].Id);

        // Asserting the response
        System.assertNotEquals(null, response, 'Response returned null');
        System.assertNotEquals(null, response.data.download_url, 'Document Url returned null');
        Test.stopTest();
    }

    // Helper class to mock HTTP responses
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