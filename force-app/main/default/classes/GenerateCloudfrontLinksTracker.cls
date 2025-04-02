/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-09-2024
 * @last modified by  : @BK
**/
@isTest
private class GenerateCloudfrontLinksTracker {

    @TestSetup
    static void setupTestData() {
        // Creating a test Lead to use its ID in test methods
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    @isTest
    static void testGenerateLinksSuccess() {
        Test.startTest();
            List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
            // Setup
            List<String> lstUrls = new List<String>{'https://example.com/file1', 'https://example.com/file2'};
            Id recordId = lst[0].Id; // Use a valid record Id or generate a mock Id

            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(200);
            mockResponse.setBody('{"id":"TestUser","links":[{"fileUrl":"www.google.com","awsUrl":"www.google.com"},{"fileUrl":"www.google.com","awsUrl":"www.google.com"}],"message":null,"error":false}');

            // Mocking the HTTP callout
            HttpCalloutMock mock = new GenerateCloudfrontLinksTracker.MockHttpResponseGenerator(mockResponse);
            Test.setMock(HttpCalloutMock.class, mock);

            // Act
            CloudfrontUrlOnFileUpload response = GenerateCloudfrontLinks.generateLinks(lstUrls, recordId);

            // Assert
            System.assertNotEquals(null, response, 'Response should not be null');
            // Add more assertions based on the expected behavior of CloudfrontUrlOnFileUpload.parse() and the mock response
        Test.stopTest();
    }

    @isTest
    static void testGenerateLinksFailure() {
        Test.startTest();
            List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
            // Setup
            List<String> lstUrls = new List<String>{'https://example.com/file1', 'https://example.com/file2'};
            Id recordId = lst[0].Id; // Use a valid record Id or generate a mock Id

            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setStatusCode(400);
            // mockResponse.setBody('{"id":"TestUser","links":[{"fileUrl":"www.google.com","awsUrl":"www.google.com"},{"fileUrl":"www.google.com","awsUrl":"www.google.com"}],"message":null,"error":true}');

            // Mocking the HTTP callout
            HttpCalloutMock mock = new GenerateCloudfrontLinksTracker.MockHttpResponseGenerator(mockResponse);
            Test.setMock(HttpCalloutMock.class, mock);

            // Act
            CloudfrontUrlOnFileUpload response = GenerateCloudfrontLinks.generateLinks(lstUrls, recordId);

            // Assert
            System.assertEquals(null, response, 'Response should be null when HTTP response is not 200');
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