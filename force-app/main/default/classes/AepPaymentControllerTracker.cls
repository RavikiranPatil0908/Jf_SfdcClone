@isTest(SeeAllData=false)
public class AepPaymentControllerTracker{
    @TestSetup
    static void makeData(){
        AEP_site_inspection__c objAsi = new AEP_site_inspection__c();
        objAsi.Name_of_the_Centre__c = 'Test';
        objAsi.Entity__c = 'Pvt. Ltd.';
        objAsi.User_Email__c = 'test1234@test.com';
        objAsi.Contact_No_1__c = '8652101245';
        insert objAsi;

        nm_Centers__c objCen = nmGenericTracker.CreateCenter('Mumbai - vashi');
        AEP_site_inspection__c objAsi1 = new AEP_site_inspection__c();
        objAsi1.Name_of_the_Centre__c = 'Test';
        objAsi1.Entity__c = 'Pvt. Ltd.';
        objAsi1.User_Email__c = 'testf1234@test.com';
        objAsi1.Contact_No_1__c = '8650101245';
        objAsi1.Centers__c = objCen.Id;
        insert objAsi1;


        Pricebook2 customPB = nmGenericTracker.CreatePriceBook();
        createProductAndPricebookEntry('UG And PG License Fee', customPB.Id, true, 100000, 'AEP');
        createProductAndPricebookEntry('Application Fee', customPB.Id, true, 1000, 'AEP');
        
    }

    @IsTest
    static void paymentForHDFC(){
        List<AEP_site_inspection__c> lstAsi = [SELECT Id FROM AEP_site_inspection__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AepPayment; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',lstAsi[0].Id);
        ApexPages.currentPage().getParameters().put('pyt','UG And PG License Fee');
        system.debug(pageRef);
        AepPaymentController AepPaymentController = new AepPaymentController();
        AepPaymentController.paymentFor ='UG And PG License Fee';
        AepPaymentController.paymentGateWayName = 'HDFC GateWay';
        AepPaymentController.MakeOnlinePayment();
        nm_Payment_Initiated__c objPaymentInitation = CreatePaymentInitRecords(lstAsi[0].Id,'UG And PG License Fee','ASI','gdrgdfgdrgdfgdgfgdrgd', 'HDFC GateWay');
        AepPaymentController.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c,'UG And PG License Fee_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false'+lstAsi[0].Id,'CAPTURED'));
        Test.stopTest();
        
    }
    @IsTest
    static void paymentForBillDeskv1(){
        List<AEP_site_inspection__c> lstAsi = [SELECT Id,Centers__c  FROM AEP_site_inspection__c WHERE Centers__c != null LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AepPayment; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',lstAsi[0].Centers__c);
        ApexPages.currentPage().getParameters().put('pyt','UG And PG License Fee');
        AepPaymentController AepPaymentController = new AepPaymentController();
        AepPaymentController.paymentFor ='UG And PG License Fee';
        AepPaymentController.paymentGateWayName = 'BillDesk GateWay';
        AepPaymentController.MakeOnlinePayment();
        Test.stopTest();
        
    }
    @IsTest
    static void paymentForRazorpayGateWay(){
        List<AEP_site_inspection__c> lstAsi = [SELECT Id FROM AEP_site_inspection__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AepPayment; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',lstAsi[0].Id);
        ApexPages.currentPage().getParameters().put('pyt','UG And PG License Fee');
        system.debug(pageRef);
        AepPaymentController AepPaymentController = new AepPaymentController();
        AepPaymentController.paymentFor ='UG And PG License Fee';
        AepPaymentController.paymentGateWayName = 'Razorpay GateWay';
        AepPaymentController.MakeOnlinePayment();
        Test.stopTest();
        
    }
    @IsTest
    static void paymentForICICIGateWay(){
        List<AEP_site_inspection__c> lstAsi = [SELECT Id FROM AEP_site_inspection__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AepPayment; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',lstAsi[0].Id);
        ApexPages.currentPage().getParameters().put('pyt','UG And PG License Fee');
        system.debug(pageRef);
        AepPaymentController AepPaymentController = new AepPaymentController();
        AepPaymentController.paymentFor ='UG And PG License Fee';
        AepPaymentController.paymentGateWayName = 'ICICI GateWay';
        AepPaymentController.MakeOnlinePayment();
        Test.stopTest();
        
    }
    @IsTest
    static void paymentForPaytmGateway(){
        List<AEP_site_inspection__c> lstAsi = [SELECT Id FROM AEP_site_inspection__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.AepPayment; // Add your VF page Name here
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',lstAsi[0].Id);
        ApexPages.currentPage().getParameters().put('pyt','UG And PG License Fee');
        system.debug(pageRef);
        AepPaymentController AepPaymentController = new AepPaymentController();
        AepPaymentController.paymentFor ='UG And PG License Fee';
        AepPaymentController.paymentGateWayName = 'Paytm Gateway';
        AepPaymentController.MakeOnlinePayment();
        Test.stopTest();
        
    }

    public static PaymentHandler.PaymentResponseWrapper paymentResponse(String merchantId,String udf1,String status) {
        PaymentHandler.PaymentResponseWrapper objResponse = new PaymentHandler.PaymentResponseWrapper();
        objResponse.transactionId = '1234';
        objResponse.modeOfPayment = 'CC';
        objResponse.merchantId = merchantId;
        objResponse.BankTXNId = '123456';
        objResponse.status = status;
        objResponse.responseDescription = null;
        objResponse.responseCode = null;
        objResponse.udf1 = udf1;
        objResponse.detailedGatewayResponse = 'ABDCTest';
        objResponse.udf2 = 'cs_1SemLecturesFee_null_false';
        objResponse.currencyCode = 'INR';
        objResponse.feeChrages = 0;
        objResponse.tax = 0;
        return objResponse;
    }

    public static PriceBookEntry createProductAndPricebookEntry(String productName ,String priceBook2Id, Boolean gst, Decimal amount, String family){
        Product2 product = new Product2();
        product.Name = productName;
        product.isActive = true;
        product.GST__c = gst;
        product.Family = family;
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = amount, IsActive = true);
        insert standardPriceBookEntry;
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebook2Id, Product2Id = product.Id, UnitPrice = amount, IsActive = true);
        insert objPriceBookEntry;
        return objPriceBookEntry;
    }


    public static nm_Payment_Initiated__c CreatePaymentInitRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String orderid, String gateWay)
    {
    nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c ();
          if('ASI'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.AEP_site_inspection__c = recordId;
        }else if ('AEP'.equalsIgnoreCase(SObjectAPIName)) {
            objPayment.AEP__c  = recordId;
        }
        objPayment.nm_Merchant_Track_Id__c = orderid;
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Payment Made';
        objPayment.nm_PaymentGatewayName__c = gateWay;
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment;
        return objPayment;
    }


}