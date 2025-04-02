@isTest(SeeAllData=false)
public class BatchClassForAverageAgentSummaryTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            DateTime startDate = System.now().addDays(-1);
            DateTime endDate = System.now().addDays(-1).addMinutes(5);
            String fullJson ='{ "status": "success", "message": [ { "CallDate": "2024-03-07", "AgentId": "AbishekhVitta", "AgentName": "Abishekh Vitta", "ModeType": "Blended", "TotalBusyTime": "00:40:32", "TotalWrapupTime": "00:01:01", "TotalPauseTime": "00:25:59", "TotalDialTime": "00:01:54", "TotalIdleTime": "05:51:01", "TotalLoginDuration": "07:00:27" }]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest 
    static void unitTest2() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            BatchClassForOzontelAverageAgentSummary batchClass = new BatchClassForOzontelAverageAgentSummary();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }
}