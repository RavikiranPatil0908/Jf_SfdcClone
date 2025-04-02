@IsTest(SeeAllData=true)
public class Payment_Invoice_ControllerTracker{
    
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
    
    public static testmethod void LeadPaymentDoneTest(){
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_Payment__c objPayment = nmGenericTracker.CreateRegistrationPaymentRecordForLead(objLead);
        objPayment.nm_Merchant_Track_Id__c  = '1234';
        objPayment.nm_Installment_Payment_Ref__c ='PG';
        update objPayment;
        objLead.nm_Year__c = 2018;
        //objLead.nm_ChooseaProgram__c ='Certificate Programs';
        objLead.Loan_Type__c = 'Zest';
        objLead.EMI_Amount__c = '1000';
        update objLead;
        NM_Payment_Form_Configuration__c objConfig = new NM_Payment_Form_Configuration__c();
        objConfig.Current_Admission_Year__c = '2018';
        objConfig.Program_Category__c ='Certificate Programs';
        objConfig.Payment_Type__c ='Admission';
        insert objConfig;
        
        ApexPages.currentPage().getParameters().put('paymentId',objPayment.id);
        Payment_Invoice_Controller obj = new Payment_Invoice_Controller();
    }
    
    public static testmethod void OpportunityPaymentDoneTest(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
      nmSerialNo__c objSerial = new nmSerialNo__c();
     objSerial.nm_MaxGenratedNo__c=122355;
     objSerial.nm_name__c= 'Reference Number';
     insert objSerial;
     
       Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',true,'Admission form & documents submitted');
       Opportunity objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
       objopp.nm_Year__c = 2018;
       objopp.Loan_Type__c = 'Zest';
       objopp.EMI_Amount__c ='1000';
       objopp.Loan_Amount__c = '100';
       objopp.Capital_Float_Processing_Fee__c ='799';
       objopp.Tenure__c  ='3';
       update objopp;
       
        nm_Payment__c objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objPayment.nm_Merchant_Track_Id__c  = '1234';
        objPayment.nm_Installment_Payment_Ref__c ='PG';
        update objPayment;
        
       NM_Payment_Form_Configuration__c objConfig = new NM_Payment_Form_Configuration__c();
        objConfig.Current_Admission_Year__c = '2018';
        objConfig.Program_Category__c ='Post Graduate Diploma Programs';
        objConfig.Payment_Type__c ='Admission';
        insert objConfig;
        
        ApexPages.currentPage().getParameters().put('paymentId',objPayment.id);
        Payment_Invoice_Controller obj = new Payment_Invoice_Controller();
    }
    
}