/**
 * @File Name          : DeleteZoomMeetingsTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 05-13-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    12/8/2019, 12:55:11 PM   @BK     Initial Version
**/
@isTest
public class DeleteZoomMeetingsTracker {

    private class RestMock implements HttpCalloutMock {
        public String method;

        RestMock() {
            method ='';
        }

        public HTTPResponse respond(HTTPRequest req) {
            Integer StatusCode = 204;
            String fullJson = '';
            if(method == 'failed') {
                StatusCode = 404;
            }
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(StatusCode);
            return res;
        }
    }

    static testmethod void testQueueable() {
        
        List<String> listMeetingId = new List<String>{'795089021','461468847','787378155','514979179'};
        String token = 'hfhfhjdkjf';

        // Create our Queueable instance
        DeleteZoomMeetings updater = new DeleteZoomMeetings(listMeetingId,token);
        // startTest/stopTest block to force async processes to run
        Test.startTest();      
        // To set test Mock callouts.
        Test.setMock(HttpCalloutMock.class, new RestMock());

        System.enqueueJob(updater);
        Test.stopTest();        
    }

}