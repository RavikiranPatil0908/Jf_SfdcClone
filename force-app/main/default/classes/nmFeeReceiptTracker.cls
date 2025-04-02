@isTest
public class nmFeeReceiptTracker
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
    static testmethod void UnitTest1()
    {
        Test.startTest(); 
          //  Test.setMock(HttpCalloutMock.class, new RestMock());
        LoadData();
        PageReference pg = new PageReference('/apex/nmFeeReceipt');
        apexpages.currentpage().getparameters().put('id',objPayment.id);
        apexpages.currentpage().getparameters().put('objdate',String.ValueOf(system.today()));
        nmFeeReceiptController obj =new nmFeeReceiptController(); 
         Test.stopTest();      
    }
        
   static testmethod void UnitTest2()
    {
       Test.startTest(); 
           Test.setMock(HttpCalloutMock.class, new RestMock());
    //   LoadData();
      objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');   
         objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission');
        nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.nm_OpportunityNew__c = objopp.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_ActualPaymentAmmount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Approved';
        objPayment2.nm_PaymentType__c = 'Admission';
        objPayment2.nm_ModeOfPayment__c='Demand Draft';
        objPayment2.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment2;
     //   update objPayment;


     Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Program Change Fee';
        product2.isActive = true;
        insert product2;
     PriceBookEntry objPriceBookEntry=  nmGenericTracker.CreatePriceBookEntry(product2, 100);

     OpportunityLineItem objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice=500;
        objLineItem.Quantity=1;
        objLineItem.OpportunityId = objopp.id;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        objLineItem.ActualSalePrice__c =1000;
        insert objLineItem ;

        PageReference pg = new PageReference('/apex/nmFeeReceipt');
        apexpages.currentpage().getparameters().put('id',objPayment2.id);
        apexpages.currentpage().getparameters().put('objdate',String.ValueOf(system.today()));
        nmFeeReceiptController obj =new nmFeeReceiptController(); 
         Test.stopTest();       
    }
     
/*    static testmethod void UnitTest3()
    {  
        Test.startTest(); 
        LoadData();
        objPayment.nm_ModeOfPayment__c='Online';
        objPayment.nm_DemandDraftDate__c=null;
        objPayment.nm_PaymentStatus__c ='Payment Approved';
        update objPayment;
        PageReference pg = new PageReference('/apex/nmFeeReceipt');
        apexpages.currentpage().getparameters().put('id',objPayment.id);
        apexpages.currentpage().getparameters().put('objdate',String.ValueOf(system.today()));
        nmFeeReceiptController obj =new nmFeeReceiptController(); 
        Test.stopTest();
    }   */ 
        
   static void LoadData()
    {
         Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');   
         objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission');
       //  nmGenericTracker.CreatelateProduct(objopp);
      //  objPayment = nmGenericTracker.CreatePaymentRecordForOpportunity(objopp,'Late Fees');
       objPayment = nmGenericTracker.CreatePaymentRecords(objopp.id,'Admission','Opportunity','Admission');
    //    nmGenericTracker.CreateOpportunityLineItem(objopp);
       // nmGenericTracker.CreateLateFeePaymentRecordForOppty(objopp);
     }   
         

 }