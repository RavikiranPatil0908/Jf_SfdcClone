@istest (SeeAllData=false)
public class nmCareerServiceProgramTriggerHTracker {
   
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
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
       
         nmSerialNo__c objSerial = new nmSerialNo__c();
        objSerial.nm_MaxGenratedNo__c=122355;
        objSerial.nm_name__c= 'Reference Number';
        insert objSerial;

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');      
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        
        Career_Service_Package__c CP = new Career_Service_Package__c();
        CP.Package_Name__c = 'Career Development';
        CP.Group_Name__c ='Normal';
        insert CP;

        Career_Service_Program__c csp = new Career_Service_Program__c();
        csp.Account__c = objAccount.Id;
        csp.Opportunity__c = objopp.id;
        csp.CareerServiceProgram__c =CP.id;
        csp.Stage__c = 'Register';
        insert csp;
        
         nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.CareerServiceProgram__c = csp.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_ActualPaymentAmmount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Approved';
        objPayment2.nm_PaymentType__c = 'Career Service';
        objPayment2.nm_Merchant_Track_Id__c = '1234';
        objPayment2.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment2;


    }


    public static testMethod void testForCareerService(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        Career_Service_Program__c objcsp =[select id,Account__c,Opportunity__c, CareerServiceProgram__c , IC_Name__c , Credit_Transaction__c, Debit_Transaction__c , Stage__c from Career_Service_Program__c limit 1];
        
        nm_Payment__c  objpayment = [select id,CareerServiceProgram__c , nm_Amount__c ,nm_PaymentType__c,nm_PaymentStatus__c   from nm_Payment__c  limit 1];
        Test.startTest();
        nmCareerServiceProgramTriggerHandler objcontroller = new nmCareerServiceProgramTriggerHandler();
        objcsp.Stage__c ='Payment Done';
        update objcsp;
        
        objcsp.Stage__c ='Cancelled';
        update objcsp;
        

        Test.stopTest();
       
    }
  
  
            public static testMethod void testForCareerService2(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Opportunity ObjOpp = [select id,nm_Program__c ,Program_Name__c,
        ChooseProgram__c,Total_Sem__c,nm_StudentProgram__c ,Specialisation__c,
        StageName,PVM__c,Account.nm_StudentNo__c from Opportunity limit 1];
        Career_Service_Program__c objcsp =[select id,Account__c,Opportunity__c, CareerServiceProgram__c , IC_Name__c , Credit_Transaction__c, Debit_Transaction__c , Stage__c from Career_Service_Program__c limit 1];
        
        Test.startTest();
        nmCareerServiceProgramTriggerHandler objcontroller = new nmCareerServiceProgramTriggerHandler();
        objcsp.Stage__c ='Cancelled';
        update objcsp;
        
        
        Test.stopTest();
       
    }


   
}