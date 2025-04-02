/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 10-07-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-25-2021   shubhranshu   Initial Version
**/
@isTest
public class AEPInvoiceTriggerHandlerTracker {
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
        nm_Centers__c objcenter =nmGenericTracker.CreateCenter('Mumbai');
      //  Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
      //  nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
     //   objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        update objAccount;
        
      
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        nm_Payment__c  obj = nmGenericTracker.CreatePaymentRecords(objopp.id,'Admission','Opportunity','Admission');
        obj.nm_PaymentStatus__c = 'Payment Approved';
        update obj;
         Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
           
         //nmGenericTracker.createProductAndPricebookEntry('Semester','1',objLead.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','1',objOpp.nm_Program__c,priceBooke2Id);
        //nmGenericTracker.createProductAndPricebookEntry('Semester','2',objLead.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','2',objOpp.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Certificate_Annual',null,null,priceBooke2Id);
        nmGenericTracker.CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
        nmGenericTracker.CreateElegibilityCriteria();
        
         IC_Payment__c iOne = new IC_Payment__c();
        iOne.Payment_Month__c='5';
        iOne.Payment_Year__c='2022';
        iOne.Centers__c=objcenter.id;
        iOne.Amount__c = 1000 * 0.60;
        iOne.Payment_Due_Date__c = System.Today();
        iOne.Share_Processed__c = true;
       

        insert iOne;
       
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c (); 
        ip.Amount__c = 500;
        ip.Narration__c = objopp.Account.Name +' - Admission Cancellation';
        ip.IC_Payment__c = iOne.Id;
        ip.ProgramType__c = 'Taxable Program';
        ip.Transaction_Type__c = 'Adjustment - Debit';
        ip.Due_Date__c = Date.ValueOf(String.valueOf(2015)+'-'+String.valueOf(12)+'-'+'20 1:00:00');
        ip.Date__c = system.today();
        ip.Opportunity__c = objopp.ID;
        ip.Account__c = objopp.AccountId;
        insert ip; 
         
         IC_Payment_Transaction__c ip2 = new IC_Payment_Transaction__c (); 
        ip2.Amount__c = 1500;
        ip2.Narration__c = objopp.Account.Name ;
        ip2.IC_Payment__c = iOne.Id;
        ip2.ProgramType__c = 'Taxable Program';
        ip2.Transaction_Type__c = 'Adjustment - Debit';
        ip2.Due_Date__c = Date.ValueOf(String.valueOf(2015)+'-'+String.valueOf(12)+'-'+'20 1:00:00');
        ip2.Date__c = system.today();
        ip2.Opportunity__c = objopp.ID;
        ip2.Account__c = objopp.AccountId;
        insert ip2;  
        
        IC_Payment_Transaction__c ip3 = new IC_Payment_Transaction__c (); 
        ip3.Amount__c = 1100;
        ip3.Narration__c = objopp.Account.Name ;
        ip3.IC_Payment__c = iOne.Id;
        ip3.ProgramType__c = 'Taxable Program';
        ip3.Transaction_Type__c = 'Adjustment - Debit';
        ip3.Due_Date__c = Date.ValueOf(String.valueOf(2015)+'-'+String.valueOf(12)+'-'+'20 1:00:00');
        ip3.Date__c = system.today();
        ip3.Opportunity__c = objopp.ID;
        ip3.Account__c = objopp.AccountId;
        insert ip3;    
        
        // Taxable Program

        System.debug('center id '+objcenter.id);
        // AEPInvoice__c aepinv = new AEPInvoice__c();
        // aepinv.Pay_Month__c = 'May';
        // aepinv.Payment_Year__c = 2022;
        // aepinv.Invoice_Number__c = 'HFDHJS51512';
        // aepinv.AEP__c = objcenter.id;
        // aepinv.IC_Payment__c = iOne.Id;
        // insert aepinv;

        AEPInvoice__c objInvoice = new AEPInvoice__c();
        objInvoice.Invoice_Number__c = 'HFDHJS51512';
        objInvoice.Invoice_Date__c = System.today();
        objInvoice.Pay_Month__c = 'May';
        objInvoice.Payment_Year__c = 2022;
        objInvoice.Program_Type__c = ' Taxable Program';
        objInvoice.AEP__c = objcenter.id;
        objInvoice.IC_Payment__c = iOne.Id;
        system.debug(objInvoice);
        insert objInvoice;
    }

    public static testmethod void TestUpdateAEPandInvoice(){
        nm_Centers__c center = [SELECT ID from nm_Centers__c LIMIT 1];
        IC_Payment__c ipay = [Select ID,Centers__c,Share_Processed__c,NonTaxableCredit__c,Pay_Month__c,Payment_Month__c,Payment_Year__c from IC_Payment__c LIMIT 1];
        ipay.Centers__c = center.ID;
        ipay.Share_Processed__c = true;
        update ipay;

        System.debug(' center '+center);
        System.debug('ipay '+ipay);
        Test.startTest();
        AEPInvoice__c aepinv = new AEPInvoice__c();
        String month = ipay.Pay_Month__c;
        aepinv.Pay_Month__c = month;
        aepinv.Payment_Year__c = Integer.valueof(ipay.Payment_Year__c);
        aepinv.Invoice_Number__c = 'HFDHJS51512';
        aepinv.AEP__c = center.ID;
        aepinv.IC_Payment__c = ipay.Id;
        insert aepinv;

        Test.StopTest();
    }

    public static testmethod void TestUpdateAEPandInvoice2(){
        AEPInvoice__c aepinv = [select Pay_Month__c,Payment_Year__c,Invoice_Number__c from AEPInvoice__c LIMIT 1];
        aepinv.Invoice_Number__c = 'AGFGEKFKLF15';
        Test.startTest();
        update aepinv;
        Test.StopTest();
    }
}