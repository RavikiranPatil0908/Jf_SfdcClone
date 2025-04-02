/**
 * @File Name          : nmLeadWebServiceTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 4/7/2019, 7:47:11 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    4/7/2019, 7:47:11 PM   @BK     Initial Version
**/
@isTest(SeeAllData=true)
public class nmLeadWebServiceTracker 
{

      public static Account objAccount;
      public static Lead objLead;
      public static Opportunity objopp;
      public static nm_Payment__c objPayment;
      public static Validity_Extension__c objValEx;

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
   static testMethod void ApprovedRereg()
   {
            LoadDatamock();
            objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
            objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
            objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
            objPayment.nm_PaymentType__c='Admission';
            objPayment.nm_PaymentStatus__c='Payment Made';
            objPayment.nm_Amount__c=63000;
            objPayment.nm_ActualPaymentAmmount__c=63000;
            update objPayment;
         
         nmLeadWebService  objnmLead=new nmLeadWebService();
         nmLeadWebService.ApproveReRegistrationAdmissionPayment(objPayment.id);
   }
   
   static testMethod void ApprovedAdmission()
   {
        LoadDatamock();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objPayment.nm_PaymentType__c='Admission';
        objPayment.nm_ModeOfPayment__c='Payment Made';
        objPayment.nm_Amount__c=63000;
        objPayment.nm_ActualPaymentAmmount__c=63000;

        update objPayment;
         
         nmLeadWebService  objnmLead=new nmLeadWebService();
         nmLeadWebService.ApprovePayment(objPayment.id);
   }
   
   static testMethod void ApprovedRegistration()
   {
      LoadDatamock();
            objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
            objPayment =  nmGenericTracker.CreateRegistrationPaymentRecordForLead(objLead);
         objPayment.nm_PaymentType__c='Registration';
         update objPayment;
         nmLeadWebService  objnmLead=new nmLeadWebService();
         nmLeadWebService.ApprovePayment(objPayment.id);
        
   }
   
   static testMethod void ApprovedInstallment()
   {
        LoadDatamock();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objPayment.nm_PaymentType__c='Installment';
        objPayment.nm_PaymentStatus__c='Payment Made';
        update objPayment;
        nmLeadWebService  objnmLead=new nmLeadWebService();
        nmLeadWebService.ApprovePayment(objPayment.id);
   }
   
  /* static testMethod void ApprovedLateFees()
   {
        LoadDatamock();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateLateFeePaymentRecordForOppty(objopp);
        objPayment.nm_PaymentType__c='Late Fees';
        objPayment.nm_PaymentStatus__c='Payment Made';
        update objPayment;
        
        nmLeadWebService  objnmLead=new nmLeadWebService();
        nmLeadWebService.ApprovePayment(objPayment.id);
        
        
   }*/
   static testMethod void ApprovedChangeIC()
   {
        LoadDatamock();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objPayment.nm_PaymentType__c='Change of IC';
        objPayment.nm_PaymentStatus__c='Payment Made';
        update objPayment;
        nmLeadWebService  objnmLead=new nmLeadWebService();
        nmLeadWebService.ApprovePayment(objPayment.id);
        
   }
   
   static testMethod void ApprovedAdditionalCharge()
   {
        LoadDatamock();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objPayment.nm_PaymentType__c='Additional Charge';
        objPayment.nm_ModeOfPayment__c='Demand Draft';
        objPayment.nm_Amount__c=63000;
        objPayment.nm_ActualPaymentAmmount__c=63000;
        
        // objPayment.nm_PaymentStatus__c='Payment Made';
         update objPayment;
         nmLeadWebService  objnmLead=new nmLeadWebService();
         nmLeadWebService.ApprovePayment(objPayment.id);
        
   }
   
   static testMethod void ApprovedValidity()
   {
        LoadDatamock();
        
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objValEx = nmGenericTracker.CreateValidity();      
        
        objPayment.Validity_Extension__c =objValEx.id;
        update objPayment;
        nmLeadWebService  objnmLead=new nmLeadWebService();
        nmLeadWebService.ApprovePaymnetWhenItIsAValidationExtension(objPayment.id);
        
   } 

     static testMethod void ApprovedCareerService()
     {
          LoadDatamock();
          objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
          objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
          Career_Service_Program__c objCSProgram = new Career_Service_Program__c(Account__c=objAccount.id);
          insert objCSProgram;
          objPayment = new nm_Payment__c(
               CareerServiceProgram__c=objCSProgram.id,
               nm_Amount__c = 4272,
               Receipt_Number__c = '70021548889',
               nm_PaymentStatus__c ='Payment Made',
               nm_PaymentType__c='Career Service');
          insert objPayment;
  
          nmLeadWebService  objnmLead=new nmLeadWebService();
          nmLeadWebService.ApprovePayment(objPayment.id);
     } 
   
    public static void LoadData()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission'); 
        objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        objValEx = nmGenericTracker.CreateValidity();               
    }   
    public static void LoadDatamock()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
                       
    }   

}