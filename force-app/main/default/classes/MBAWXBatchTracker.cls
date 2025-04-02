@isTest
public with sharing class MBAWXBatchTracker {
    
     @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.Selection_AdmissionDate__c= system.today();
          objAccount.Selection_InitialDate__c= system.today();
        objAccount.Interview_Status__c = 'Selected';
        objAccount.nmCaptureOpportuntiyStage__c ='Registration Done';
        update objAccount;
        
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
        nm_Payment__c objPayment =  nmGenericTracker.CreatePaymentRecords(objopp.id,'Initial Payment','Opportunity','Initial Payment');
         
    }
    
  /*  static testmethod void testSuccessBatch(){
        Test.startTest();
        RestMock rest = new RestMock();
        rest.method='Test1';
        Test.setMock(HttpCalloutMock.class,rest);
        MBAWXBatch batchClass = new MBAWXBatch();
        Database.executeBatch(batchClass,100);
        test.stopTest();
        
    }*/
    
     static testmethod void testFailureBatch(){
        Account objAccount =[select id, Program_Type__c ,PersonEmail,IC_Name__c, PersonMobilePhone, nm_AccountEmail__c,ICemailaddress__c,LC_email_id__c, Name, Last_Date_for_Initial_Payment__c,       Last_Date_for_Admission_Payment__c, DaysSinceForInitialPayment__c from Account limit 1];
        Test.startTest();
        RestMock rest = new RestMock();
        rest.method='Test2';
        Test.setMock(HttpCalloutMock.class,rest);
        MBAWXBatch batchClass = new MBAWXBatch();
        Database.executeBatch(batchClass,100);
        MBAWXBatch.getEmail(objaccount);
        test.stopTest();
       
    }
    
    public class RestMock implements HttpCalloutMock
    {
        public String method;
        RestMock(){
        method ='';
        }
        
        public HttpResponse respond(HttpRequest req)
        {
            String fullJson ='0130|NMIMS|201782316555409980|JCMP5606086518|0|1.00|CMP|NA|00|INR|6EMI|NA|NA|00.00|23-08-2017 16:53:36|0399|NA|xcbxc@gmail.c0m|3325325355|LeadRegistrationAdmission-0-NA|00QO00000056ZKQMA2|20000.00|NA|NA|NA|Canceled By User|N|NA|0.00|NA|NA|Y|147767BEEBE61F96EE014FE79CD75D5C692F8831122724796763615A6360FC20';
            if(method =='Test1')
            {
                fullJson = '0130|NMIMS|201782316555409980|JCMP5606086518|0|1.00|CMP|NA|00|INR|6EMI|NA|NA|00.00|23-08-2017 16:53:36|0399|NA|xcbxc@gmail.c0m|3325325355|LeadRegistrationAdmission-0-NA|00QO00000056ZKQMA2|20000.00|NA|NA|NA|Canceled By User|N|NA|0.00|NA|NA|Y|147767BEEBE61F96EE014FE79CD75D5C692F8831122724796763615A6360FC20';
            }
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type','application/x-form-urlencoded');
            resp.setBody(fullJson );
            resp.setStatusCode(200);
            return resp;
        }
    }
}