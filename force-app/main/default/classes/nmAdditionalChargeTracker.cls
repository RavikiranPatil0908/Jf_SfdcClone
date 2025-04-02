/**
 * @File Name          : nmAdditionalChargeTracker.cls
 * @Description        : 
 * @Author             : Bala
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-20-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/4/2019, 7:23:36 PM   Bala     Initial Version
**/
@isTest(SeeAllData=true)
private class nmAdditionalChargeTracker{
    
    private static Opportunity objopp;
    private static nm_Payment__c objPayment;
    private static nm_Program__c objprogram;
    private static Account objAccount;
    public  static User user ;

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Code":0,"Message":"SUCCESS","Errors":[{"Location":"body","Param":"FirstName","Msg":"FirstName should be present","Code":1,"Message":"Failed Creation"}],"Event":"application.loan.disbursed","Entities":["Application","Loan","Borrowers","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"5362179f-d56f-40d3-949a-99cf6888cdee","Status":"APPROVED","CourseId":541,"CourseName":"Artificial Intelligence","Notes":null,"ReferenceNumber":""},"Loan":{"LoanAmount":50000,"TotalTenor":12,"MoratoriumPeriod":6,"DiscountedCourseFee":65000},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999999","Email":"john.doe@test.com"}]},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":50000,"DisbursementDate":"2019-08-20","DisbursementReference":"AIASDO311144141"}],"RedirectionUrl":"www.google.com","QuoteId":"5362179f-d56f-40d3-949a-99cf6888cdee"},"CreatedOn":"2019-08-06 18:00:00"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static testmethod void manuallyCreatedAdditionalChargePayment(){
        LoadData();
        Counsellor_Profile__c co = new Counsellor_Profile__c();
        insert co;
        ApexPages.currentPage().getParameters().put('id',objPayment.id);
        String cj = '{"' + co.Id +'":"User"}';
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController ();
        controller.IsReregistartion=TRUE;
        Controller.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
        Controller.MakeOnlinePayment();
        Controller.getMapOfActiveCalender();
        Controller.getBalanceAmountToPay(100,50);
        Controller.MakePaymentAfterResponse(paymentResponse('5444563', 'Additional Charge', 'CAPTURED'));
        // Controller.MakePaymentAfterResponse('12345','CC','5444563','cccc','CAPTURED','eeee','E00','Additional Charge','response','null_null_null_false',0,0);
        Controller.insertContactsandSendMail(cj,objPayment.id);
    }

    public static testmethod void manuallyCreatedAdditionalChargePaymentForHDFC(){
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objPayment.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController ();
        Controller.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
        Controller.paymentGatewayName = 'HDFC GateWay';
        Controller.MakeOnlinePayment();
        Controller.MakePaymentAfterResponse(paymentResponse('5444563', 'Additional Charge', 'CAPTURED'));
    }

    public static testmethod void manuallyCreatedAdditionalChargePaymentForBillDesk(){
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objPayment.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController ();
        Controller.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
        Controller.paymentGatewayName = 'BillDesk GateWay';
        Controller.MakeOnlinePayment();
        Controller.MakePaymentAfterResponse(paymentResponse('5444563', 'Additional Charge', 'CAPTURED'));
    }
    public static testmethod void manuallyCreatedAdditionalChargePaymentForRazorPay(){
        LoadData();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ApexPages.currentPage().getParameters().put('id',objPayment.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController ();
        Controller.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
        Controller.paymentGatewayName = 'Razorpay GateWay';
        Controller.MakeOnlinePayment();
        Controller.MakePaymentAfterResponse(paymentResponse('5444563', 'Additional Charge', 'CAPTURED'));
    }

    public static testmethod void manuallyCreatedAdditionalChargePaymentForICICI(){
        LoadData();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ApexPages.currentPage().getParameters().put('id',objPayment.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController ();
        Controller.showMakePaymentButtonAfterWindowClosedDateAndShowDDMessgae();
        Controller.paymentGatewayName = 'ICICI GateWay';
        Controller.MakeOnlinePayment();
        Controller.MakePaymentAfterResponse(paymentResponse('5444563', 'Additional Charge', 'CAPTURED'));
    }

    public static testmethod void validityExtensionPaymentTest(){
        LoadData();
        Validity_Extension__c objVal = new Validity_Extension__c();
        objVal.Related_Account__c = objAccount.id;
        objVal.Student_Program_Validity__c = 'Post Graduate Diploma in Human Resource Management';
        insert objVal;
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
    }

    public static testmethod void careerServicePaymentTest(){
        LoadData();
        List<Career_Service_Package__c> lstCSP = [SELECT Id FROM Career_Service_Package__c LIMIT 1];
        Career_Service_Program__c objVal = new Career_Service_Program__c();
        objVal.Account__c = objAccount.id;
        objVal.CareerServiceProgram__c = lstCSP[0].Id;
        insert objVal;
        ApexPages.currentPage().getParameters().put('id',objVal.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
    }
    public static testmethod void aepMerch(){
        LoadData();
        List<nm_Centers__c> lstCSP = [SELECT Id FROM nm_Centers__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('aepCenId',lstCSP[0].id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Map<String,Decimal> paymentTypevsamount = new Map<String,Decimal>();
        Controller.putLicenseFee(231,256,596, paymentTypevsamount);
    }

    public static testmethod void seminarPaymentTest(){
        Referral__c objVal = new Referral__c();
        objVal.Name__c = 'Test';
        objVal.Email__c = 'test@gmail.com';
        objVal.Mobile_Number__c = '7845123698';
        objVal.City__c = 'Mumbai';
        insert objVal;
        ApexPages.currentPage().getParameters().put('id',objVal.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
    }
    
    public static testmethod void opportunityPendingPaymentTest(){
        LoadData();
        Test.StartTest();
        nm_Payment__c objAdmissionPayment = objPayment.clone();
        objAdmissionPayment.nm_PaymentType__c = 'Admission';
        objAdmissionPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdmissionPayment;
        
        nm_Payment__c objLateFeePayment = objPayment.clone();
        objLateFeePayment.nm_PaymentType__c = 'Late Fees';
        objLateFeePayment.nm_PaymentStatus__c ='Payment Made';
        insert objLateFeePayment;
        
        nm_Payment__c objAdditionalChargeICPSPayment = objPayment.clone();
        objAdditionalChargeICPSPayment.nm_PaymentType__c = 'Additional Charge - ProgramChange - ICChange - StudentKit';
        objAdditionalChargeICPSPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdditionalChargeICPSPayment;
        
        ApexPages.currentPage().getParameters().put('id',objopp.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Test.StopTest();
    }
    
    public static testmethod void pendingPaymentTest(){
        LoadData();
        Test.StartTest();
        nm_Payment__c objAdditionalChargeICPPayment = objPayment.clone();
        objAdditionalChargeICPPayment.nm_PaymentType__c = 'Additional Charge - ProgramChange - ICChange';
        objAdditionalChargeICPPayment.nm_PaymentStatus__c ='Payment Made';
        
        insert objAdditionalChargeICPPayment;
        
        nm_Payment__c objAdditionalChargePSPayment = objPayment.clone();
        objAdditionalChargePSPayment.nm_PaymentType__c = 'Additional Charge - ProgramChange - StudentKit';
        objAdditionalChargePSPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdditionalChargePSPayment;
        
     /*   nm_Payment__c objAdditionalChargeICSPayment = objPayment.clone();
        objAdditionalChargeICSPayment.nm_PaymentType__c = 'Additional Charge - ICChange - StudentKit';
        objAdditionalChargeICSPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdditionalChargeICSPayment;
        
        nm_Payment__c objAdditionalChargePPayment = objPayment.clone();
        objAdditionalChargePPayment.nm_PaymentType__c = 'Additional Charge - ProgramChange';
        objAdditionalChargePPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdditionalChargePPayment;
        
        nm_Payment__c objAdditionalChargeICPayment = objPayment.clone();
        objAdditionalChargeICPayment.nm_PaymentType__c = 'Additional Charge - ICChange';
        objAdditionalChargeICPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdditionalChargeICPayment;
        
        nm_Payment__c objAdditionalChargeSPayment = objPayment.clone();
        objAdditionalChargeSPayment.nm_PaymentType__c = 'Additional Charge - StudentKit';
        objAdditionalChargeSPayment.nm_PaymentStatus__c ='Payment Made';
        insert objAdditionalChargeSPayment;
        */
        ApexPages.currentPage().getParameters().put('id',objopp.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Test.StopTest();
    }
    
    public static testmethod void saveDDTest(){
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objPayment.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Controller.objPayment.nm_DemandDraftNumber__c ='123';
        Controller.objPayment.nm_DemandDraftDate__c = System.today();
        Controller.objPayment.nm_NameoftheBank__c = '123';
        Controller.objPayment.nm_BankLocation__c = 'Mumbai';
        Controller.objPayment.nm_DispatchDate__c = System.today();
        Controller.SaveDD();
        Controller.objPayment.nm_DemandDraftNumber__c =null;
        Controller.SaveDD();
    }
    @IsTest
    static void methodName1(){
        LoadData();
         //objPriceBookEntry.Product2Id;
         Product2 pr = [SELECT Id FROM Product2 WHERE Name = 'Tshirt' LIMIT 1];
        nm_Centers__c objCenter1 = nmGenericTracker.CreateCenter('Pune-Road');
        objCenter1.AEP_Merchen__c = '[{"ProductName":"Tshirt","selectedSize":"S","NumberOfProduct":1,"TotalPrice":2362.5}]';
        update objCenter1;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('aepCenId',objCenter1.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Controller.clearOrderDetailsFromCenter(objCenter1.id);
        Test.stopTest();
        
    }
    @IsTest
    static void methodName2(){
        nm_Centers__c objCenter1 = nmGenericTracker.CreateCenter('Pune-Road');
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',objCenter1.id);
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Test.stopTest();
        
    }
    @IsTest
    static void methodName3(){
        LoadData();
        Opportunity opp = [SELECT Id From Opportunity LIMIT 1];
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.currentPage().getParameters().put('pyt','coursera');
        nmAdditonalChargePaymentController  Controller = new nmAdditonalChargePaymentController();
        Controller.checkGSTApplicable(100,200,100);
        Test.stopTest();
        
    }
    
    public static Void LoadData(){
        Profile profile = [SELECT Id FROM Profile WHERE Name=:'Super Admin' limit 1];
       
        user = new User(Alias = 'standt1', Email='standar1duser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standard11user@testorg.com');
        insert user;

        PriceBook2 priceBook =  nmGenericTracker.CreatePriceBook();
        
        System.runAs(user){
            objAccount = new Account();
            objAccount = CommonTrackerClass.createAccount(objAccount);  
            objAccount.PersonEmail = 'Praveen.p@saasfocus.in';
            objAccount.Phone = '963210'; 
            // objAccount.nm_Tagged_Pricebook__c =String.valueOf(priceBook.Id).substring(0, 15);
            update objAccount;
        }
       
        /*objprogram = new nm_Program__c ();
        objProgram.nm_ProgramCode__c='001';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c ='Certificate Programs';        
        objProgram.nm_ProgramName__c='MCA';      
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;        
        insert objProgram;*/
        objprogram = nmGenericTracker.CreatePGDiplomaProgram();
        // insert objprogram;
        
        objopp = new opportunity();
        objopp.accountId = objAccount.id;
        objOPP.nm_Semester__c = '1';
        objOpp.name ='test opp';
        objOPP.StageName ='Registration done';
        objopp.nm_Program__c =objprogram.id;
        objopp.nm_Session__c = 'July';
        objopp.nm_year__c=2014;
        objOpp.CloseDate =System.today();
        insert objopp;
        
        objPayment = new nm_Payment__c();
        objPayment.nm_OpportunityNew__c =objopp.id;
        objPayment.nm_PaymentType__c='Additional Charge';
        objPayment.nm_Amount__c = 25;
        objPayment.nm_ModeOfPayment__c='Online';
        objPayment.nm_DemandDraftNumber__c ='123';
        objPayment.nm_DemandDraftDate__c =System.today();
        objPayment.nm_NameoftheBank__c ='SBI';
        objPayment.nm_BankLocation__c  ='Chembur';
        objPayment.nm_DispatchDate__c = System.today();
        objPayment.nm_PaymentStatus__c='Pending Extra Fees' ;
        insert objPayment;
        
        nm_Payment_Initiated__c objPaymentIntialted=new nm_Payment_Initiated__c();
        objPaymentIntialted.nm_PaymentGatewayName__c='sffdf';
        objPaymentIntialted.nm_Merchant_Track_Id__c='5444563'; 
        insert  objPaymentIntialted;
        
        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = System.Today().AddDays(-1);
        objCal.Session__c = 'January';
        objCal.Year__c = 2018;
        objCal.Session_End_Date__c = System.Today();
        objCal.Closed_Date__c = System.Today().AddDays(1);
        objCal.Category__c = 'Admission';
        objCal.nm_Semester__c = null;
        objCal.nm_Type__c = null;
        insert objCal;

        
        nmGenericTracker.createProductAndPricebookEntry('Coursera',null,null,priceBook.Id);
        nmGenericTracker.createProductAndPricebookEntry('Tshirt',null,null,priceBook.Id);
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

    
}