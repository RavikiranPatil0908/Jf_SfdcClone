/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 09-30-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
private class nmICPaymentTriggerTracker {
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

        List<PaymentShareConfig__c> lstConfig = new List<PaymentShareConfig__c>();
        PaymentShareConfig__c obj1 = new PaymentShareConfig__c(
                                        Percentage__c = 60,
                                        Order__c = 1,
                                        Is_Active__c = true
                                    );
        lstConfig.add(obj1);
        PaymentShareConfig__c obj2 = new PaymentShareConfig__c(
                                        Percentage__c = 20,
                                        Order__c = 2,
                                        Is_Active__c = true
                                    );
        lstConfig.add(obj2);
        PaymentShareConfig__c obj3 = new PaymentShareConfig__c(
                                        Percentage__c = 20,
                                        Order__c = 3,
                                        Is_Active__c = true
                                    );
        lstConfig.add(obj3);
        insert lstConfig;

        nmGenericTracker.InsertSerialNo();
        // nm_Centers__c objcenter =nmGenericTracker.CreateCenter('Mumbaitrdgdf');
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

        nm_Centers__c objcenter = [SELECT Id FROM nm_Centers__c LIMIT 1];
        
         IC_Payment__c iOne = new IC_Payment__c();
        iOne.Payment_Month__c='12';
        iOne.Payment_Year__c='2015';
        iOne.Centers__c=objcenter.id;
        iOne.Amount__c = 1000 * 0.60;
        iOne.Payment_Due_Date__c = System.Today();
                      
        insert iOne;
        
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c (); 
        ip.Amount__c = 500;
        ip.Narration__c = objopp.Account.Name +' - Admission Cancellation';
        ip.IC_Payment__c = iOne.Id;
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
        ip2.Transaction_Type__c = 'Admission Commision - Credit';
        ip2.Due_Date__c = Date.ValueOf(String.valueOf(2015)+'-'+String.valueOf(12)+'-'+'20 1:00:00');
        ip2.Date__c = system.today();
        ip2.Opportunity__c = objopp.ID;
        ip2.Account__c = objopp.AccountId;
        insert ip2;  
        
        IC_Payment_Transaction__c ip3 = new IC_Payment_Transaction__c (); 
        ip3.Amount__c = 1100;
        ip3.Narration__c = objopp.Account.Name ;
        ip3.IC_Payment__c = iOne.Id;
        ip3.Transaction_Type__c = 'Adjustment - Debit';
        ip3.Due_Date__c = Date.ValueOf(String.valueOf(2015)+'-'+String.valueOf(12)+'-'+'20 1:00:00');
        ip3.Date__c = system.today();
        ip3.Opportunity__c = objopp.ID;
        ip3.Account__c = objopp.AccountId;
        insert ip3;   
        
        
    }

    @isTest
    static void createAdhocDebitRecordTest(){
        List<IC_Payment_Transaction__c> iptransectionlist = new List<IC_Payment_Transaction__c>();
        Opportunity objopp =[select id,AccountId ,ChooseProgram__c, Specialisation__c,Account.Name ,CloseDate ,Account.nm_Centers__c,IC__c from Opportunity limit 1];
        decimal amount = 0.0;
        
        Integer year = 2015;
        Integer month = 11;
        Integer confyear = 2015;
        Integer confmonth = 12;
        Integer percent = 35;
        
        
        Test.startTest();
            nmICPaymentTriggerHandler instance = new nmICPaymentTriggerHandler ();
            
            IC_Payment__c icpayment = instance.getICPayment('2016', '13', objopp.IC__c );
            ID icpaymentid =   icpayment.id ;
            
            instance.createCourierDebitRecord(iptransectionlist, objopp, year, month, icpayment);
            instance.createAdhocDebitRecord(iptransectionlist, objopp, icpayment,124,false,'Book Courier Charges',date.newinstance(year,month,20));
            instance.createAdhocCreditRecord(iptransectionlist, objopp, icpayment,124,false,'Book Courier Charges',date.newinstance(year,month,20));
            instance.createAdhocCreditRecord(iptransectionlist, objopp, icpayment,124,false,'Book Courier Charges',date.newinstance(year,month,20),'Deregister');
            // instance.MonthYearCycleValue(date.newinstance(year,month,01));
            // instance.MonthYearCycleValue(date.newinstance(year,month,24));
            // instance.MonthYearCycleValue(date.newinstance(year,month,27));
            instance.createICTransactionDebitRecord(objopp, icpayment,date.newinstance(year,month,20),100);
            instance.createICTransactionRecord(iptransectionlist, icpaymentid, amount, objopp, percent,date.newinstance(confyear,confmonth,15));
            instance.createICShareDebitEntries(objopp,100);
            //instance.createICTransactionCreditRecord(objpayment, objopp, year,month, icpayment);
        Test.stopTest();
    }

    @isTest 
    static void createICTransactionCreditEntryTest(){
        nm_Centers__c objcenter =[select id,name from  nm_Centers__c limit 1];
        Opportunity objopp = [select id,AccountId ,Account.Name ,CloseDate,Account.nm_Centers__c from Opportunity limit 1];
        Integer excessyear = 2015;
        Integer excessmonth = 12;
        decimal amount = 0.0;
        string informationcenter = objcenter.name;
        string narration = '';
        
        Test.startTest();
            nmICPaymentTriggerHandler instance = new nmICPaymentTriggerHandler ();
            // TODO : Add extra code to validate the method call
            instance.createICTransactionCreditEntry(objopp, excessyear, excessmonth, amount, informationcenter, narration);
            instance.createICTransactionDebitEntry(objopp, excessyear, excessmonth, amount, informationcenter, narration);
            instance.createDebitEntry(objopp, excessyear, excessmonth, amount, informationcenter, narration,true,'de-register');
            instance.getICPayment('2016', '13', objcenter.name);
            instance.getMultipleNumber('AnnualFee');
            instance.getMultipleNumber('FullFee');
            instance.getMultipleNumber('3SemFee');
            instance.getMultipleNumberPP('AnnualFee',3);
            instance.getMultipleNumberPP('3SemFee',2);
            instance.getMultipleNumberPP('3SemFee',1);
            instance.getMultipleNumberPP('FullFee',1);
        Test.stopTest();
    }
   
    @isTest 
    static void createCourierDebitEntryForSme2OnwardsForFullFeeCaseTest(){
        // SetUp();
        Opportunity objopp = [select id,AccountId ,Account.Name ,BookCChargeapplicable__c,CloseDate,Account.nm_Centers__c,IC__c from Opportunity limit 1];
        List<IC_Payment_Transaction__c> iptransectionlist = [select id from IC_Payment_Transaction__c where Opportunity__c=: objopp.id];
        Map<string, IC_Payment__c > existingicpaymentmap = new Map<string,IC_Payment__c >();
        string accountconfirmmonthyear = '';
        Integer confyear = 2015;
        Integer confmonth = 12;
        // TODO : Add extra code to validate the method call
        Test.startTest();
        nmICPaymentTriggerHandler instance = new nmICPaymentTriggerHandler ();
        instance.getIcTranAdjustmentDebitAmount(objopp.AccountId);
        IC_Payment__c icpayment2 = instance.getICPayment('2016', '13', objopp.IC__c );
        existingicpaymentmap.put(String.valueOf(icpayment2.Centers__c)+icpayment2.Payment_Month__c+String.valueof(icpayment2.Payment_Year__c),icpayment2);
        nmICPaymentTriggerHandler.PaymentDate objConfig = new nmICPaymentTriggerHandler.PaymentDate();
        objConfig.confirmationMonthYear = accountconfirmmonthyear;
        objConfig.confMonth = confmonth;
        objConfig.confYear = confyear;
        instance.createCourierDebitEntryForFullFeeSEM2AndBeyond(existingicpaymentmap, objopp, iptransectionlist, objConfig);
        Test.stopTest();
    }
}