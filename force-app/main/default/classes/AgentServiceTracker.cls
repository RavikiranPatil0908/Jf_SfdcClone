/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 25-01-2025
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class AgentServiceTracker {

    @TestSetup
    static void makeData(){ 
        nmGenericTracker.CreateCalender();
    }

    // Test the filterVoiceCallActive method with valid response
    @isTest
    static void testFilterVoiceCallActiveValidResponse() {
        Test.startTest();

            List<Calender__c> lstCal = [SELECT Id FROM Calender__c];
            // Create a mock response from the API
            String mockResponse = '{"status": "success", "data": [{"AgentName": "John Doe", "AgentId": "JohnDoe", "AgentState": "Available"}]}';
            
            // Set up the mock HTTP response
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse));
            
            // Prepare input data (Map of Name -> Id)
            Map<String, Id> agentNameToIdMap = new Map<String, Id>{
                'JohnDoe' => lstCal[0].Id,
                'Jane Smith' => lstCal[1].Id
            };
            
            // Call the method under test
            Set<Id> result = AgentService.filterVoiceCallActive(agentNameToIdMap);
        Test.stopTest();
        
        // Verify the result contains the correct agent ID
        System.assert(result.contains(lstCal[0].Id), 'John Doe should be available');
        System.assert(result.contains(lstCal[1].Id), 'Jane Smith should be included because she was not in the API response');
    }

    // Test the filterVoiceCallActive method when no response is returned (i.e., API callout error or no data)
    @isTest
    static void testFilterVoiceCallActiveNoResponse() {
        Test.startTest();

            List<Calender__c> lstCal = [SELECT Id FROM Calender__c];
            // Set up the mock to return an empty response or simulate an error
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"status": "failure", "data": []}'));

            // Prepare input data (Map of Name -> Id)
            Map<String, Id> agentNameToIdMap = new Map<String, Id>{
                'JohnDoe' => lstCal[0].Id,
                'Jane Smith' => lstCal[1].Id
            };
            
            // Call the method under test
            Set<Id> result = AgentService.filterVoiceCallActive(agentNameToIdMap);
        Test.stopTest();
        
        // Verify that the result is the same as the input (fallback behavior)
        System.assert(result.contains(lstCal[0].Id), 'John Doe should be returned as fallback');
        System.assert(result.contains(lstCal[1].Id), 'Jane Smith should be returned as fallback');
    }

    // Test the filterVoiceCallActive method with agent states that should not be included (Busy, ACW)
    @isTest
    static void testFilterVoiceCallActiveBusyOrACWState() {
        Test.startTest();

            List<Calender__c> lstCal = [SELECT Id FROM Calender__c];
            // Create a mock response from the API where agent states are Busy or ACW
            String mockResponse = '{"status": "success", "data": [{"AgentName": "John Doe", "AgentId": "JohnDoe", "AgentState": "Busy"}, {"AgentName": "Jane Smith", "AgentId": "JaneSmith", "AgentState": "BUSY"}]}';
            
            // Set up the mock HTTP response
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockResponse));
            
            // Prepare input data (Map of Name -> Id)
            Map<String, Id> agentNameToIdMap = new Map<String, Id>{
                'JohnDoe' => lstCal[0].Id,
                'JaneSmith' => lstCal[1].Id,
                'Mike Johnson' => lstCal[2].Id
            };
            
            // Call the method under test
            Set<Id> result = AgentService.filterVoiceCallActive(agentNameToIdMap);
        Test.stopTest();
        
        // Verify that the result contains only the IDs that are not Busy or ACW
        System.assert(!result.contains(lstCal[0].Id), 'John Doe should not be included as they are Busy');
        System.assert(!result.contains(lstCal[1].Id), 'Jane Smith should not be included as they are in BUSY');
        System.assert(result.contains(lstCal[2].Id), 'Mike Johnson should be included as they are not in the API response');
    }

    // Mock HTTP response class to simulate the API response
    class MockHttpResponse implements HttpCalloutMock {
        private String responseBody;

        public MockHttpResponse(String responseBody) {
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}