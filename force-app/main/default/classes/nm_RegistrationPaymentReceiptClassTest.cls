@istest
public class nm_RegistrationPaymentReceiptClassTest {
     private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
        
     static testMethod void TestMethod1() 
    {    
        Lead objLead = new Lead();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
         ApexPages.currentPage().getParameters().put('id',objLead.id);
         nm_RegistrationPaymentReceiptClass objRe=new nm_RegistrationPaymentReceiptClass();
         objRe.getobjLead();
    }
}