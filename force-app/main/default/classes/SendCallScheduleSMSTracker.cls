/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 17-05-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)  
public class SendCallScheduleSMSTracker {
    public class RestMock implements HttpCalloutMock {
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

    @isTest  
    static void testCalloutMethod(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest();
            SendCallScheduleSMS.CallScheduleActionRequest requestParam = new SendCallScheduleSMS.CallScheduleActionRequest();
            requestParam.MobilePhone = '0000000000';
            requestParam.oldCallDateTime = System.now();
            requestParam.newCallDateTime = System.now();
            List<SendCallScheduleSMS.CallScheduleActionRequest> requestParamlst = new List<SendCallScheduleSMS.CallScheduleActionRequest>{requestParam};
            SendCallScheduleSMS.sendSMSNotification(requestParamlst);
		Test.StopTest();
	}
}