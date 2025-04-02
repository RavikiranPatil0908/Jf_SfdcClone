@isTest
public class RegistartionFeeReceiptControllerTracker
{                                                 
    public static Lead objLead;
    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_Payment__c objPayment;
    
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
     static testmethod void UnitTest3()
      {
          //loadPages();  
      LoadData();
      objPayment.nm_ModeOfPayment__c='Online';
      objPayment.nm_DemandDraftDate__c= system.today();
      objPayment.nm_PaymentStatus__c ='Payment Approved';
        update objPayment;
        PageReference pg = new PageReference('/apex/nmRegistartionFeeReceipt?');
        apexpages.currentpage().getparameters().put('id',objPayment.id);
         apexpages.currentpage().getparameters().put('date',String.ValueOf(system.today()));
        nmRegistartionFeeReceiptController obj =new nmRegistartionFeeReceiptController();        
      }    
       
    static void LoadData()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateDiplomaOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Approved','1',objAccount,'Admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);        
     }       

 }