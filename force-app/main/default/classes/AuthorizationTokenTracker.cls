/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class AuthorizationTokenTracker {

    private class RestMockRequest implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"type":"Bank","token":"test","success":"success","error":null, "status":"success"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest     
    static void unitTest1(){ 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockRequest());
            Map<String, Object> mapOfResponse = AuthorizationToken.getCashFreeAuthorizationToken('Bank');
            System.debug(mapOfResponse);
            System.assertEquals('test', (String)mapOfResponse.get('token'),'Token is missing');
        Test.stopTest();
    }
}