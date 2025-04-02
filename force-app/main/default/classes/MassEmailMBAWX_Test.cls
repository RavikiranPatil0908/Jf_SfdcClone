@isTest
private class MassEmailMBAWX_Test
{

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

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.InterviewScore_DT__c = system.now();
        objAccount.Interview_Status__c = 'Selected';
        objAccount.Selection_InitialDate__c = system.today();
        objAccount.Selection_AdmissionDate__c =  system.today();
        objAccount.nmCaptureOpportuntiyStage__c ='Registration Done';
        update objAccount;
        
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
        nm_Payment__c objPayment =  nmGenericTracker.CreatePaymentRecords(objopp.id,'Initial Payment','Opportunity','Initial Payment');
         
    }
   
    static MassEmailMBAWX instance = null;
    static void SetUp(){
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        instance = new MassEmailMBAWX();
    }
    
    static void TearDown(){
        test.StopTest();
    }
    
    public static testmethod void Test_sendmail(){
        SetUp();
    
      Account  accToUpdate = [select id,Program_Type__c,PersonEmail,PersonMobilePhone,nm_AccountEmail__c,LC_email_id__c,ICemailaddress__c,
                                                         Name,Last_Date_for_Initial_Payment__c,Total_amount_received__c,nmStudent_Program__c,
                                                         Last_Date_for_Admission_Payment__c,DaysSinceForInitialPayment__c 
                                                        from Account Limit 1];
        MassEmailMBAWX.getEmail(accToUpdate);
        MassEmailMBAWX.sendmail();

        TearDown();
    }
     public static testmethod void Test_sendmail2(){
        SetUp();
    
      Account  accToUpdate = [select id,Program_Type__c,PersonEmail,PersonMobilePhone,nm_AccountEmail__c,LC_email_id__c,ICemailaddress__c,
                                                         Name,Last_Date_for_Initial_Payment__c,Total_amount_received__c,nmStudent_Program__c,
                                                         Last_Date_for_Admission_Payment__c,DaysSinceForInitialPayment__c 
                                                        from Account Limit 1];
        nm_Payment__c objPayment = [select id ,nm_Amount__c , nm_PaymentStatus__c from nm_Payment__c limit 1];
         Opportunity objOpps = [select id,Down_Payment_Made__c from Opportunity limit 1];
        objPayment.nm_Amount__c =26000;
        objPayment.nm_PaymentStatus__c = 'Payment Approved';
        update objPayment;
        MassEmailMBAWXProgramFee.getEmail2();
        MassEmailMBAWXProgramFee.getEmail(accToUpdate);
        MassEmailMBAWXProgramFee.sendmail2();

        TearDown();
    }
    
}