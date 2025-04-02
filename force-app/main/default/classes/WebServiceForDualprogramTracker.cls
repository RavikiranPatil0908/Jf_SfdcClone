@isTest(SeeAllData=True)
public class WebServiceForDualprogramTracker
{
    public static Account objAccount;
    public static Lead objLead;
    public static Opportunity objopp ;
       
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
        LoadData();
         nm_EligiblityCriteria__c  objEc = nmGenericTracker.CreateElegibilityCriteria();
         nm_Program__c objProgram = nmGenericTracker.CreatePGDiplomaProgram();
       // WebServiceForClosedLost.MakeStudentClosedLost(objAccount.id,objopp.id);
       // WebServiceForClosedLost.MakeStudentClosedLostForOtherSem(objAccount.id,objopp.id);
        WebServiceForDualprogram.StudentInfo(objAccount.id,'9988776655','sadsa@gmail.comn','Post graduate program',objEc.id,objProgram.id);
   }
   
    public static void LoadData()
    { 
          Test.setMock(HttpCalloutMock.class, new RestMock());
          objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
          objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents Approved'); 
          objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed','1',objAccount,'admission');  
          
    }     
}