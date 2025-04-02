/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-28-2020
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-28-2020   @BK   Initial Version
**/
@isTest
private class SendOTPForCommunityUserTracker {
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String result ='Request accepted for Request ID=2025666354431232200 & Statuscode=200 & Info=Platform Accepted  & Time=2020-08-28 15:54:43';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/plain;charset=ISO-8859-1');
            res.setBody(result);
            res.setStatusCode(200);
            return res;
        }
    }

    public static testmethod void Test_calloutmethod(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest();
            SendOTPForCommunityUser.CommunityActionRequest requestParam = new SendOTPForCommunityUser.CommunityActionRequest();
            requestParam.MobilePhone = '0000000000';
            requestParam.Username = 'test@gmail.com';
            requestParam.VerificationCode = '00000';
            List<SendOTPForCommunityUser.CommunityActionRequest> requestParamlst = new List<SendOTPForCommunityUser.CommunityActionRequest>{requestParam};
            SendOTPForCommunityUser.sendSMSOtp(requestParamlst);
           
            // String jsonresults = JSON.serialize(requestParamlst);
            // SendOTPForCommunityUser.calloutmethod(jsonresults);
		Test.StopTest();
	}
}