/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-25-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-25-2020   shubhranshu   Initial Version
**/
@isTest(SeeAllData=false)
public without sharing class EzcredWebhookAPITracker {
    public static Account objAccount;
    public static lead objLead;
    public static Opportunity objOpp;
    public static lead objLeadformaster;
    public static Account objAccountformaster;
    public static Opportunity objOppforMaster;
    public static nm_Program__c program;
    static String loanId='';

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

    @testSetup
    public static void setUpData(){
      Test.setMock(HttpCalloutMock.class, new RestMock());
      nmGenericTracker.InsertSerialNo();
      objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
      objLead.Loan_Order_Id__c ='07181977383';
      objLead.Loan_Type__c ='EzCred';
      objLead.Loan_Amount__c = '30000';
      objLead.EduVanz_lead_id__c = '1234';
      update objLead;
      objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
      objAccount.nm_StudentNo__c = '77214000953';
      update objAccount;
      objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
      objOpp.Loan_Order_Id__c ='07181977381';
      objOpp.Loan_Type__c = 'EzCred';
      objOpp.Loan_Amount__c = '30000';
      objOpp.EduVanz_lead_id__c = '123';
      update objOpp;

    }

    static testMethod void testTrackLiquiLoanStaus1(){
      Opportunity op=[select Loan_Order_Id__c,EduVanz_lead_id__c from Opportunity where Loan_Order_Id__c='07181977381'];
      loanId = op.Loan_Order_Id__c;
      Test.startTest();    
      String myJSON = '{"customer_account_number":"123","loan_account_number":"123","lead_number": \"'+op.EduVanz_lead_id__c+'\","partner_reference_id": \"'+loanId+'\","status":"DISBURSED","submitted_on_date":"29-10-2019","loan_detail":{"principal":50000,"number_of_repayments":12,"emi_amount":2450,"down_payment":1231},"merchant_information":{"merchant_id":"EDUCLASSPLUS123"},"customer_information":{"personal_information":{"type":"INDIVIDUAL","first_name":"First","middle_name":"Middle","last_name":"Last","date_of_birth":"25-10-2019","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"1234567890"}]},"approval_data":{"approval_date":"29-10-2019","approved_amount":50000},"agreement_sign_url":"<agreement sign url>","rejection_data":{"rejection_date":"29-10-2019","reason":"Low income"},"disbursal_data":{"disbursal_date":"29-10-2019","disbursal_amount":50000,"disbursal_utr":"KKBK123456"},"repayment_schedule":[{"due_date":"05-11-2018","amount":2500,"interest":300,"principal":2200},{"due_date":"05-12-2018","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-01-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-02-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-03-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-04-2019","amount":2500,"Interest":300,"principal":2200}],"transaction_data":[{"payment_details":{"receipt_number":"1234567890"},"transaction_amount":2500,"transaction_date":"21-02-2020","transaction_status":"PENDING","transaction_type":"DOWNPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":100,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"PROCESSING_FEE"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"EMI_REPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_type":"EMI_REPAYMENT"}]}';
      RequestData(myJSON,'POST');
      EzcredWebhookAPI.TrackEzcredLoanStaus();
      Test.stopTest();
    }

    static testMethod void testTrackLiquiLoanStaus2(){
      Opportunity op=[select Loan_Order_Id__c,EduVanz_lead_id__c from Opportunity where Loan_Order_Id__c='07181977381'];
      loanId = op.Loan_Order_Id__c;
      Test.startTest();    
      String myJSON = '{"customer_account_number":"123","loan_account_number":"123","lead_number": \"'+op.EduVanz_lead_id__c+'\","partner_reference_id": \"'+loanId+'\","status":"APPROVED","submitted_on_date":"29-10-2019","loan_detail":{"principal":50000,"number_of_repayments":12,"emi_amount":2450,"down_payment":1231},"merchant_information":{"merchant_id":"EDUCLASSPLUS123"},"customer_information":{"personal_information":{"type":"INDIVIDUAL","first_name":"First","middle_name":"Middle","last_name":"Last","date_of_birth":"25-10-2019","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"1234567890"}]},"approval_data":{"approval_date":"29-10-2019","approved_amount":50000},"agreement_sign_url":"<agreement sign url>","rejection_data":{"rejection_date":"29-10-2019","reason":"Low income"},"disbursal_data":{"disbursal_date":"29-10-2019","disbursal_amount":50000,"disbursal_utr":"KKBK123456"},"repayment_schedule":[{"due_date":"05-11-2018","amount":2500,"interest":300,"principal":2200},{"due_date":"05-12-2018","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-01-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-02-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-03-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-04-2019","amount":2500,"Interest":300,"principal":2200}],"transaction_data":[{"payment_details":{"receipt_number":"1234567890"},"transaction_amount":2500,"transaction_date":"21-02-2020","transaction_status":"PENDING","transaction_type":"DOWNPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":100,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"PROCESSING_FEE"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"EMI_REPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_type":"EMI_REPAYMENT"}]}';
      RequestData(myJSON,'POST');
      EzcredWebhookAPI.TrackEzcredLoanStaus();
      Test.stopTest();
    }

    static testMethod void testTrackLiquiLoanStaus3(){
      Opportunity op=[select Loan_Order_Id__c,EduVanz_lead_id__c from Opportunity where Loan_Order_Id__c='07181977381'];
      loanId = op.Loan_Order_Id__c;
      Test.startTest();    
      String myJSON = '{"customer_account_number":"123","loan_account_number":"123","lead_number": \"'+op.EduVanz_lead_id__c+'\","partner_reference_id": \"'+loanId+'\","status":"APPROVED","submitted_on_date":"29-10-2019","loan_detail":{"principal":50000,"number_of_repayments":12,"emi_amount":2450,"down_payment":1231},"merchant_information":{"merchant_id":"EDUCLASSPLUS123"},"customer_information":{"personal_information":{"type":"INDIVIDUAL","first_name":"First","middle_name":"Middle","last_name":"Last","date_of_birth":"25-10-2019","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"1234567890"}]},"approval_data":{"approval_date":"29-10-2019","approved_amount":50000},"agreement_sign_url":"<agreement sign url>","rejection_data":{"rejection_date":"29-10-2019","reason":"Low income"},"disbursal_data":{"disbursal_date":"29-10-2019","disbursal_amount":50000,"disbursal_utr":"KKBK123456"},"repayment_schedule":[{"due_date":"05-11-2018","amount":2500,"interest":300,"principal":2200},{"due_date":"05-12-2018","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-01-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-02-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-03-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-04-2019","amount":2500,"Interest":300,"principal":2200}],"transaction_data":[{"payment_details":{"receipt_number":"1234567890"},"transaction_amount":2500,"transaction_date":"21-02-2020","transaction_status":"PENDING","transaction_type":"DOWNPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":100,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"PROCESSING_FEE"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"EMI_REPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_type":"EMI_REPAYMENT"}]}';
      RequestData(myJSON,'POST');
      EzcredWebhookAPI.TrackEzcredLoanStaus();
      Test.stopTest();
    }

    static testMethod void testTrackLiquiLoanStaus4(){
      Opportunity op=[select Loan_Order_Id__c,EduVanz_lead_id__c from Opportunity where Loan_Order_Id__c='07181977381'];
      loanId = op.Loan_Order_Id__c;
      Test.startTest();    
      String myJSON = '{"customer_account_number":"123","loan_account_number":"123","lead_number": \"'+op.EduVanz_lead_id__c+'\","partner_reference_id": "","status":"REJECTED","submitted_on_date":"29-10-2019","loan_detail":{"principal":50000,"number_of_repayments":12,"emi_amount":2450,"down_payment":1231},"merchant_information":{"merchant_id":"EDUCLASSPLUS123"},"customer_information":{"personal_information":{"type":"INDIVIDUAL","first_name":"First","middle_name":"Middle","last_name":"Last","date_of_birth":"25-10-2019","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"1234567890"}]},"approval_data":{"approval_date":"29-10-2019","approved_amount":50000},"agreement_sign_url":"<agreement sign url>","rejection_data":{"rejection_date":"29-10-2019","reason":"Low income"},"disbursal_data":{"disbursal_date":"29-10-2019","disbursal_amount":50000,"disbursal_utr":"KKBK123456"},"repayment_schedule":[{"due_date":"05-11-2018","amount":2500,"interest":300,"principal":2200},{"due_date":"05-12-2018","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-01-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-02-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-03-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-04-2019","amount":2500,"Interest":300,"principal":2200}],"transaction_data":[{"payment_details":{"receipt_number":"1234567890"},"transaction_amount":2500,"transaction_date":"21-02-2020","transaction_status":"PENDING","transaction_type":"DOWNPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":100,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"PROCESSING_FEE"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"EMI_REPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_type":"EMI_REPAYMENT"}]}';
      RequestData(myJSON,'POST');
      EzcredWebhookAPI.TrackEzcredLoanStaus();
      Test.stopTest();
    }

    static testMethod void testTrackLiquiLoanStausLead1(){
      Lead ld=[select Loan_Order_Id__c,EduVanz_lead_id__c from Lead where Loan_Order_Id__c='07181977383'];
      loanId = ld.Loan_Order_Id__c;
      Test.startTest();    
      String myJSON = '{"customer_account_number":"123","loan_account_number":"123","lead_number": \"'+ld.EduVanz_lead_id__c+'\","partner_reference_id": \"'+loanId+'\","status":"DISBURSED","submitted_on_date":"29-10-2019","loan_detail":{"principal":50000,"number_of_repayments":12,"emi_amount":2450,"down_payment":1231},"merchant_information":{"merchant_id":"EDUCLASSPLUS123"},"customer_information":{"personal_information":{"type":"INDIVIDUAL","first_name":"First","middle_name":"Middle","last_name":"Last","date_of_birth":"25-10-2019","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"1234567890"}]},"approval_data":{"approval_date":"29-10-2019","approved_amount":50000},"agreement_sign_url":"<agreement sign url>","rejection_data":{"rejection_date":"29-10-2019","reason":"Low income"},"disbursal_data":{"disbursal_date":"29-10-2019","disbursal_amount":50000,"disbursal_utr":"KKBK123456"},"repayment_schedule":[{"due_date":"05-11-2018","amount":2500,"interest":300,"principal":2200},{"due_date":"05-12-2018","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-01-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-02-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-03-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-04-2019","amount":2500,"Interest":300,"principal":2200}],"transaction_data":[{"payment_details":{"receipt_number":"1234567890"},"transaction_amount":2500,"transaction_date":"21-02-2020","transaction_status":"PENDING","transaction_type":"DOWNPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":100,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"PROCESSING_FEE"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"EMI_REPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_type":"EMI_REPAYMENT"}]}';
      RequestData(myJSON,'POST');
      EzcredWebhookAPI.TrackEzcredLoanStaus();
      Test.stopTest();
    }

    static testMethod void testTrackLiquiLoanStausLead2(){
      Lead ld=[select Loan_Order_Id__c,EduVanz_lead_id__c from Lead where Loan_Order_Id__c='07181977383'];
      loanId = ld.Loan_Order_Id__c;
      Test.startTest();    
      String myJSON = '{"customer_account_number":"123","loan_account_number":"123","lead_number": \"'+ld.EduVanz_lead_id__c+'\","partner_reference_id": \"'+loanId+'\","status":"APPROVED","submitted_on_date":"29-10-2019","loan_detail":{"principal":50000,"number_of_repayments":12,"emi_amount":2450,"down_payment":1231},"merchant_information":{"merchant_id":"EDUCLASSPLUS123"},"customer_information":{"personal_information":{"type":"INDIVIDUAL","first_name":"First","middle_name":"Middle","last_name":"Last","date_of_birth":"25-10-2019","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"1234567890"}]},"approval_data":{"approval_date":"29-10-2019","approved_amount":50000},"agreement_sign_url":"<agreement sign url>","rejection_data":{"rejection_date":"29-10-2019","reason":"Low income"},"disbursal_data":{"disbursal_date":"29-10-2019","disbursal_amount":50000,"disbursal_utr":"KKBK123456"},"repayment_schedule":[{"due_date":"05-11-2018","amount":2500,"interest":300,"principal":2200},{"due_date":"05-12-2018","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-01-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-02-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-03-2019","amount":2500,"Interest":300,"principal":2200},{"due_date":"05-04-2019","amount":2500,"Interest":300,"principal":2200}],"transaction_data":[{"payment_details":{"receipt_number":"1234567890"},"transaction_amount":2500,"transaction_date":"21-02-2020","transaction_status":"PENDING","transaction_type":"DOWNPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":100,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"PROCESSING_FEE"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_status":"COMPLETED","transaction_type":"EMI_REPAYMENT"},{"payment_details":{"receipt_number":"123456790"},"transaction_amount":1000,"transaction_date":"21-02-2020","transaction_type":"EMI_REPAYMENT"}]}';
      RequestData(myJSON,'POST');
      EzcredWebhookAPI.TrackEzcredLoanStaus();
      Test.stopTest();
    }
  
    public static void RequestData(String myJson,String requestMethod) {
      RestResponse response = new RestResponse();
      RestRequest request = new RestRequest();
      request.requestURI = System.Label.Site_Url+'services/apexrest/EzcredWebhookAPI/V1.1/';
      request.httpMethod=requestMethod;
      request.requestBody = Blob.valueof(myJSON);
      RestContext.request = request;
      RestContext.response = response;
    }
}