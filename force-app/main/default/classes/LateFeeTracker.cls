@isTest(SeeAllData=true)
public class LateFeeTracker
{
    public static Lead objLead;
    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_Program__c program; 
    public static User objUser;
    public static nm_UserMapping__c objUserMap;
    public static nm_EligiblityCriteria__c objEc;
    public static nm_Centers__c centerInformationCenter;
    public static nm_Centers__c centerLearningCenter;
    public static nm_Centers__c   objcen;
    public static Pricebook2 objPriceBook;
    public static nm_StudentProgram__c objSP ;
    public static nm_Payment__c objPayment;
     public static nm_Program__c objProgram; 
     public static nmSerialNo__c objSerial;
     public static Product2 objProduct;
     public static OpportunityLineItem objLineItem ; 
     public static nm_Payment__c objPayment2 ; 
  
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
    
      static testMethod void UnitTest()
     {
     
      loadData();
      PageReference pg = new PageReference('/apex/latefeespayment');
      Test.setCurrentPage(pg);
      //pexpages.currentpage().getparameters().put('id',objAccount.id);
      apexpages.currentpage().getparameters().put('id',objPayment2.id);
      ApexPages.StandardController sc = new ApexPages.standardController(objPayment2);
      LateFee controller =new LateFee(sc);
      controller.CheckPaymentPanel();
      controller.SavePayment();
       
     }
     static testMethod void UnitTest1()
     {
      loadData();
      objPayment2.nm_OpportunityNew__c =objopp.id;
      objPayment2.nm_ModeOfPayment__c='Demand Draft';
      objPayment2.nm_OpportunityNew__c =objopp.id;
      objPayment2.nm_ModeOfPayment__c='Online';
      objPayment2.nm_DemandDraftNumber__c = '255646';
      update objPayment2;
       PageReference pg = new PageReference('/apex/latefeespayment');
      Test.setCurrentPage(pg);
      //pexpages.currentpage().getparameters().put('id',objAccount.id);
      apexpages.currentpage().getparameters().put('id',objPayment2.id);
      ApexPages.StandardController sc = new ApexPages.standardController(objPayment2);
      LateFee controller =new LateFee(sc);
      controller.CheckPaymentPanel();
      controller.SavePayment();
       
     }
     
     static testMethod void UniteTest2()
     {
      loadData();
      objPayment2.nm_ModeOfPayment__c=null;
      update objPayment2;
       PageReference pg = new PageReference('/apex/latefeespayment');
      Test.setCurrentPage(pg);
      //pexpages.currentpage().getparameters().put('id',objAccount.id);
      apexpages.currentpage().getparameters().put('id',objPayment2.id);
      ApexPages.StandardController sc = new ApexPages.standardController(objPayment2);
      LateFee controller =new LateFee(sc);
      controller.CheckPaymentPanel();
      controller.SavePayment();
     }
     
   
     static testMethod void UniteTest3()
     {
      loadData();
      objopp.StageName='Pending Payment';
      update objopp;
      objPayment2.nm_OpportunityNew__c =objopp.id;
      objPayment2.nm_DemandDraftNumber__c = '255646';
      objPayment2.nm_ModeOfPayment__c='Demand Draft';
      objPayment2.nm_PaymentStatus__c='Pending Late Fees'; 
      objPayment2.nm_PaymentType__c='Late Fees' ;
      update objPayment2;
      PageReference pg = new PageReference('/apex/latefeespayment');
      Test.setCurrentPage(pg);
      //pexpages.currentpage().getparameters().put('id',objAccount.id);
      apexpages.currentpage().getparameters().put('id',objPayment2.id);
      ApexPages.StandardController sc = new ApexPages.standardController(objPayment2);
      LateFee controller =new LateFee(sc);
      controller.SavePayment();
       
     }
     
       static testMethod void UnitTest4()
     {
      loadData();
      objPayment2.nm_ModeOfPayment__c='Demand Draft';
      objPayment2.nm_DemandDraftNumber__c = '';
      update objPayment2;
       PageReference pg = new PageReference('/apex/latefeespayment');
      Test.setCurrentPage(pg);
      //pexpages.currentpage().getparameters().put('id',objAccount.id);
      apexpages.currentpage().getparameters().put('id',objPayment2.id);
      ApexPages.StandardController sc = new ApexPages.standardController(objPayment2);
      LateFee controller =new LateFee(sc);
      controller.SavePayment();
       
     }
     
    
     public static void loadData()
     {
         Test.setMock(HttpCalloutMock.class, new RestMock());
         nmGenericTracker.InsertSerialNo();
         objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',true,'Admission form & documents submitted');
         objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
         objPayment2 = nmGenericTracker.CreatePaymentRecordForOpportunity(objopp,'Admission');
     }
  
 }