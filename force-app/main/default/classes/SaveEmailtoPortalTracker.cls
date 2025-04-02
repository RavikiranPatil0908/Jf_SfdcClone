@isTest
public class SaveEmailtoPortalTracker {
	private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status":"success","message":[{"Response":"success"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
	@isTest
    static void testUnit1() {
        
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        SaveEmailToPortal.FlowInputs testFlowInput = new SaveEmailToPortal.FlowInputs();
        testFlowInput.subject = 'Test Subject';
        testFlowInput.toMailId = 'test@example.com';
        testFlowInput.body = 'Test email body';
        testFlowInput.sapId = '123456';

        List<SaveEmailToPortal.FlowInputs> testFlowInputsList = new List<SaveEmailToPortal.FlowInputs>();
        testFlowInputsList.add(testFlowInput);

        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"status":"success"}');
        mockResponse.setStatusCode(200);
        
        Test.startTest();
        SaveEmailToPortal.callSaveEmailToPortalAPI(testFlowInputsList);
        Test.stopTest();
    }
}