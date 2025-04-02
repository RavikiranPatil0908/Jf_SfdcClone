@isTest(SeeAllData=false)
public with sharing class GenericEmailControllerTracker {
    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status": "success","response": [{"parentId": "001In000005GmDZ","createdDate": "Wed Nov 13 15:39:57 IST 2024","subject": "TERM 1","fromEmailId": "donotreply.cdoe@nmims.edu","mailId": "patilravikiran088@gmail.com","body": "<!doctype html><html><head><meta charset="utf-8"><meta http-equiv="Content-Type" content="text/html charset=UTF-8"/><title>Untitled Document</title><link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" type="text/css"/></head><body><table width="700" border="0" align="center" cellpadding="0" cellspacing="0" style="border: 1px solid #A09999; display:table"><tbody><tr><td width="700"><table width="700" border="0" align="left" cellpadding="0" style="font-family:Helvetica, Arial, sans-serif"><tbody><tr><td width="5" height="100" align="left"><a href="http://studentzone-ngasce.nmims.edu/studentportal/" style="color: #aa1f24"><img WIDTH=720 HEIGHT=100  src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAV&oid=00D90000000s6BL" style=" display: table"></a></td></tr></tbody></table></td></tr><tr><td>&nbsp;</td><td >&nbsp;</td><td>&nbsp;</td></tr><tr><td><table id="templateBody" ><tbody><tr><td><table><tbody><tr><td ><img  src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000"></td><td >Dear Ravi Patill,<br><br>Greetings,</td><td >< src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAk&oid=00D90000000s6BL&lastMod=1603954131000"></td></tr><tr><td>&nbsp;</td><td >&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >Your de-registration request for TERM 1 in the July2024 academic cycle has been successfully processed.</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td ><i>In case you have any queries, please feel free to reach out to us on <a href="tel:18001025136" > 18001025136</a> and a student advisor will assist you</i></td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >This is a system generated email, please do not reply to this mail ID as it isn’t monitored. For any query, you may write to us at ngasce@nmims.edu</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >Thanks and Regards,<br><span><b>Student Counsellor</b><br> NMIMS Center For Distance And Online Education</span></td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td >&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td ><img src="https://c.ap19.content.force.com/servlet/servlet.ImageServer?id=0152j000000PdAp&oid=00D90000000s6BL&lastMod=1603954244000" ></td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td ><div >You are receiving this email because you had signed up to receive emails from NMIMS Center For Distance And Online Education. If you prefer not to receive future emails of this type, you can unsubscribe<a href="http://ngasce.force.com/UnsubscribeEmail?l=&cid=&e=&ei=" target="_blank" style="color: #aa1f24">here</a><br></div></td><td>&nbsp;</td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></body></html>"}]}';
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
            // Create a mock HTTP response
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"status":"success"}');
            mockResponse.setStatusCode(200);
            Test.startTest();
            GenericEmailController.getEmailMessage('001In000005G3Ka');
            Test.stopTest();
        
    }
}