/**
 * @File Name          : nmPaytmPayResponse_Test.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 30-04-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    30/3/2019, 1:24:40 PM   Balakrishnan     Initial Version
**/
@isTest(SeeAllData=false)
public class nmPaytmPayResponse_Test
{
    static nmPaytmPayResponse instance = null;
    static String recordId = 'NA';
    static String orderId = '2015101253010087';
    static String orderId2 = '2015101253010090';
    static String orderId3 = '2015101253010093'; 

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

    /**
    * @description setup data.
    * @author Bala | 3/4/2019
    * @return void
    */
    @testSetup
    public static void setUpData(){
        Test.startTest();
            generateDummyData();
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 3/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit1() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c,nm_Session__c,nm_Year__c from Lead limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objLead.id;
            String ResponseURl = Label.Site_Url+'postPaymentPage?ResTrackId='+orderId;
            String uniqueREF = 'Admission_'+recordId+'_100.12_postPaymentPage_false_NA_false_1SemLecturesFee_null_false';
            String jsonString = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"TXN_SUCCESS","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0","MERC_UNQ_REF":"'+uniqueREF+'"}';
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            Map<String,String> mapOfParams = new Map<String,String>();

            PageReference myVfPage = Page.nmPaytmPayResponse;
            Test.setCurrentPage(myVfPage);
            for(String key : mapOfRequestParameters.keySet()) {
                ApexPages.currentPage().getParameters().put(key,(String)mapOfRequestParameters.get(key));
            }
            mapOfParams = ApexPages.currentPage().getParameters();
            String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Label.Paytm_Encryption_Key, ApexPages.currentPage().getParameters());
            ApexPages.currentPage().getParameters().put('CHECKSUMHASH',checkSum);
            
            instance = new nmPaytmPayResponse();
           PageReference pageRef = instance.StorePaymentInSystem();

            //Beginning of System Asserts, verify pageRef and URL First
            System.assertNotEquals(null,pageRef);
            System.assertEquals(ResponseURl,pageRef.getUrl());

        Test.stopTest();
    }

    @isTest
    static void testUnit2() {
        Opportunity objOpp = [select id,nm_Session__c,nm_Year__c from Opportunity limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objOpp.id;
            System.debug('recordId  -->'+recordId);
            String ResponseURl = Label.Site_Url+'postPaymentPage?ResTrackId='+orderId;
            String uniqueREF = 'Additional Charge_'+recordId+'_100.12_postPaymentPage_false_'+recordId+'_false_1SemLecturesFee_nulll_false';
            String jsonString = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"TXN_SUCCESS","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0","MERC_UNQ_REF":"'+uniqueREF+'"}';
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            Map<String,String> mapOfParams = new Map<String,String>();

            PageReference myVfPage = Page.nmPaytmPayResponse;
            Test.setCurrentPage(myVfPage);
            for(String key : mapOfRequestParameters.keySet()) {
                ApexPages.currentPage().getParameters().put(key,(String)mapOfRequestParameters.get(key));
            }
            mapOfParams = ApexPages.currentPage().getParameters();
            String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Label.Paytm_Encryption_Key, ApexPages.currentPage().getParameters());
            ApexPages.currentPage().getParameters().put('CHECKSUMHASH',checkSum);
            
            instance = new nmPaytmPayResponse();
            PageReference pageRef = instance.StorePaymentInSystem();

            //Beginning of System Asserts, verify pageRef and URL First
            System.assertNotEquals(null,pageRef);
            System.assertEquals(ResponseURl,pageRef.getUrl()); 

        Test.stopTest();
    }

    @isTest
    static void testUnit3() {
        Referral__c objReferral = [select id from Referral__c limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objReferral.id;
            System.debug('recordId  -->'+recordId);
            String ResponseURl = Label.Site_Url+'postPaymentPage?ResTrackId='+orderId2;
            String uniqueREF = 'Seminar Fee_'+recordId+'_'+1000+(1000*Decimal.valueOf(Label.Service_Tax))+'_postPaymentPage_false_'+recordId+'_false_1SemLecturesFee_nulll_false';
            String jsonString = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId2+'","TXNAMOUNT":"100.12","STATUS":"TXN_SUCCESS","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0","MERC_UNQ_REF":"'+uniqueREF+'"}';
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            Map<String,String> mapOfParams = new Map<String,String>();

            PageReference myVfPage = Page.nmPaytmPayResponse;
            Test.setCurrentPage(myVfPage);
            for(String key : mapOfRequestParameters.keySet()) {
                ApexPages.currentPage().getParameters().put(key,(String)mapOfRequestParameters.get(key));
            }
            mapOfParams = ApexPages.currentPage().getParameters();
            String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Label.Paytm_Encryption_Key, ApexPages.currentPage().getParameters());
            ApexPages.currentPage().getParameters().put('CHECKSUMHASH',checkSum);
            
            instance = new nmPaytmPayResponse();
            PageReference pageRef = instance.StorePaymentInSystem();

            //Beginning of System Asserts, verify pageRef and URL First
            System.assertNotEquals(null,pageRef);
            System.assertEquals(ResponseURl,pageRef.getUrl());

        Test.stopTest();
    }

    @isTest
    static void testUnit4() {
        Referral__c objReferral = [select id from Referral__c limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objReferral.id;
            System.debug('recordId  -->'+recordId);
            String ResponseURl = Label.Site_Url+'postPaymentPage?ResTrackId='+orderId2;
            String uniqueREF = 'Seminar Fee_'+recordId+'_'+1000+(1000*Decimal.valueOf(Label.Service_Tax))+'_postPaymentPage_false_'+recordId+'_false_1SemLecturesFee_nulll_false';
            String jsonString = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId2+'","TXNAMOUNT":"100.12","STATUS":"PENDING","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0","MERC_UNQ_REF":"'+uniqueREF+'"}';
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            Map<String,String> mapOfParams = new Map<String,String>();

            PageReference myVfPage = Page.nmPaytmPayResponse;
            Test.setCurrentPage(myVfPage);
            for(String key : mapOfRequestParameters.keySet()) {
                ApexPages.currentPage().getParameters().put(key,(String)mapOfRequestParameters.get(key));
            }
            mapOfParams = ApexPages.currentPage().getParameters();
            String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Label.Paytm_Encryption_Key, ApexPages.currentPage().getParameters());
            ApexPages.currentPage().getParameters().put('CHECKSUMHASH',checkSum);
            
            instance = new nmPaytmPayResponse();
            PageReference pageRef = instance.StorePaymentInSystem();

            //Beginning of System Asserts, verify pageRef and URL First
            System.assertNotEquals(null,pageRef);
            System.assertEquals(ResponseURl,pageRef.getUrl());

        Test.stopTest();
    }

    @isTest
    static void testUnit5() {
        Referral__c objReferral = [select id from Referral__c limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objReferral.id;
            System.debug('recordId  -->'+recordId);
            String ResponseURl = Label.Site_Url+'postPaymentPage?ResTrackId='+orderId2;
            String uniqueREF = 'Seminar Fee_'+recordId+'_'+1000+(1000*Decimal.valueOf(Label.Service_Tax))+'_postPaymentPage_false_'+recordId+'_false_1SemLecturesFee_nulll_false';
            String jsonString = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId2+'","TXNAMOUNT":"100.12","STATUS":"FAILED","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0","MERC_UNQ_REF":"'+uniqueREF+'"}';
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            Map<String,String> mapOfParams = new Map<String,String>();

            PageReference myVfPage = Page.nmPaytmPayResponse;
            Test.setCurrentPage(myVfPage);
            for(String key : mapOfRequestParameters.keySet()) {
                ApexPages.currentPage().getParameters().put(key,(String)mapOfRequestParameters.get(key));
            }
            mapOfParams = ApexPages.currentPage().getParameters();
            String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Label.Paytm_Encryption_Key, ApexPages.currentPage().getParameters());
            ApexPages.currentPage().getParameters().put('CHECKSUMHASH',checkSum);
            
            instance = new nmPaytmPayResponse();
            PageReference pageRef = instance.StorePaymentInSystem();

            //Beginning of System Asserts, verify pageRef and URL First
            System.assertNotEquals(null,pageRef);
            System.assertEquals(ResponseURl,pageRef.getUrl());

        Test.stopTest();
    }

    public static PriceBookEntry createProductAndPricebookEntry(String productName , String semester , String program ,String priceBook2Id){
        Product2 product = new Product2();
        product.Name = productName;
        product.nm_Program__c = program;
        product.nm_Semester__c = semester;
        product.isActive = true;
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert standardPriceBookEntry;
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = priceBook2Id, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert objPriceBookEntry;
        return objPriceBookEntry;
    }
    
    public static nm_Payment__c CreatePaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef){
        nm_Payment__c objPayment = new nm_Payment__c ();
        if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.nm_OpportunityNew__c = recordId;
        }else{
            objPayment.nm_Lead__c  = recordId;
        }
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Payment Made';
        objPayment.nm_PaymentGatewayName__c ='Bill Desk';
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        objPayment.nm_Installment_Payment_Ref__c = installmentRef;
        insert objPayment;
        return objPayment;
    }
    
    public static NM_Payment_Form_Configuration__c  createPaymentFOrmConfiguration(String programCategory,String programType,String semester){
        NM_Payment_Form_Configuration__c objpaymentconfig = new NM_Payment_Form_Configuration__c();
        objpaymentconfig.Program_Category__c = programCategory;
        objpaymentconfig.Payment_Type__c =programType;
        objpaymentconfig.Semester__c= semester;
        objpaymentconfig.Current_Admission_Year__c = '2019';
        objpaymentconfig.No_Of_Applicable_Installment__c ='1';
        objpaymentconfig.Registration_Fee__c=1200;
        objpaymentconfig.Program_Type__c='';
        objpaymentconfig.Reg_No_Allowed_After_End_Date__c = '01723456';
        objpaymentconfig.Capital_Float_AEP_Available__c = 'Mumbai,Pune';
        objpaymentconfig.Show_Registration_Payment_Option__c = true;
        objpaymentconfig.Show_Admission_Payment_Option__c = true;
        objpaymentconfig.Payment_Window_EndDate__c = System.now().addDays(-1);
        objpaymentconfig.Registration_Fee__c = 12000;
        objpaymentconfig.Is_Late_Fee_Applicable__c = true;
        insert objpaymentconfig;
        return objpaymentconfig;
    }

    @future (callout=true)
    public static void generateDummyData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
        CreatePaymentRecords(objLead.id,'Initial Payment','Lead','Initial Payment');
        CreatePaymentRecords(objLead.id,'Late Fees','Lead','Late Fees');
        CreatePaymentRecords(objLead.id,'AnnualFee','Lead','AnnualFee');
        CreatePaymentRecords(objLead.id,'PGAllSemFee','Lead','PGAllSemFee');
        CreatePaymentRecords(objLead.id,'MultipleSemFee','Lead','MultipleSemFee');
        CreatePaymentRecords(objLead.id,'Admission','Lead','Admission');
        
        CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-Admission');
        CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-AnnualFee');
        CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-PGAllSemFee');
        CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-MultipleSemFee');

        
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        update objAccount;
        
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
       
        //form COnfiguration
        createPaymentFOrmConfiguration('Certificate Programs','Admission','1');//lead registration
        createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');//account registration
        createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Re-Registration','1');//account reregistration
        
        //custom setting
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
        objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
        objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
        insert objSystemConfiguration;
        
        Id priceBooke2Id = [SELECT id,pricebook2Id FROM Opportunity LIMIT 1].pricebook2Id;
        
        createProductAndPricebookEntry('Registration Fee',null,null,priceBooke2Id);
        //Lead Product Sem1
        createProductAndPricebookEntry('Semester','1',objLead.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Semester','1',objOpp.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Semester','2',objLead.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Semester','2',objOpp.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Certificate_Annual',null,null,priceBooke2Id);
        nmGenericTracker.CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
        nmGenericTracker.CreateElegibilityCriteria();
        nmGenericTracker.CreateCalender();
        nmGenericTracker.createLateFeeRecord('Is Lateral','Certificate Programs');

        Referral__c objReferral = new Referral__c();
        objReferral.Email__c = 'test@gmail.com';
        objReferral.Mobile_Number__c = '8520369741';
        insert objReferral;

        nm_Payment_Initiated__c initiatedPayment = new nm_Payment_Initiated__c();
        initiatedPayment.nm_Merchant_Track_Id__c = orderId;
        initiatedPayment.nm_PaymentGatewayName__c = 'Paytm GateWay';
        initiatedPayment.nm_PaymentStatus__c = 'Transaction Failed';
        insert initiatedPayment;

        nm_Payment_Initiated__c initiatedPayment2 = new nm_Payment_Initiated__c();
        initiatedPayment2.nm_Merchant_Track_Id__c = orderId2;
        initiatedPayment2.nm_PaymentGatewayName__c = 'Paytm GateWay';
        initiatedPayment2.nm_PaymentStatus__c = 'Transaction Failed';
        initiatedPayment2.Seminar__c = objReferral.id;
        initiatedPayment2.nm_PaymentType__c='Seminar Fee';
        insert initiatedPayment2;

        nm_Payment__c PaymentRecord = new nm_Payment__c();
        PaymentRecord.nm_PaymentType__c = 'Additional Charge';
        PaymentRecord.nm_PaymentStatus__c = 'Pending Extra Fees';
        PaymentRecord.nm_OpportunityNew__c = objopp.id;
        PaymentRecord.nm_Merchant_Track_Id__c = orderId;
        PaymentRecord.nm_ActualPaymentAmmount__c = 100.12;
        PaymentRecord.nm_Amount__c = 100.12;
        insert PaymentRecord;
    }

}