@istest(SeeAllData=true)
public class nmPrintPreviewControllerTracker 
{
   public static Account objAccount;
   public static Opportunity objopp; 
   
    private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
   static  testmethod  void unitTest1()
   {
       loadData();
       nm_WorkExperience__c objWrkExp = new  nm_WorkExperience__c ();
      objWrkExp.nm_Student__c=objAccount.Id;
      insert objWrkExp;
      
       apexpages.currentpage().getparameters().put('id',objAccount.id);
       apexpages.currentpage().getparameters().put('date',String.ValueOf(system.today()));
       apexpages.currentpage().getparameters().put('city','Anantapur');
       nmPrintPreviewController objnmPrint=new nmPrintPreviewController();
   }

   static void loadData()
   {
       Test.setMock(HttpCalloutMock.class, new RestMock());
       objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',true,'Admission form & documents submitted');
       objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
   }
}