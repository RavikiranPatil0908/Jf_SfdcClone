/**
 * @File Name          : nmPaymentNewTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 30-04-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    7/4/2019, 11:33:58 AM   shubhranshu     Initial Version
**/
@istest (SeeAllData=false)
public class nmPaymentNewTracker {
    
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
        Test.startTest();
            generateDummyData();
        Test.stopTest();
    }
    
    public static testmethod void leadPaymentTest_test1(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objLead.id);
            ApexPages.currentPage().getParameters().put('IsReRestration','false');
            ApexPages.currentPage().getParameters().put('IC','false');
            ApexPages.currentPage().getParameters().put('sem','1');
            ApexPages.currentPage().getParameters().put('amount','1800');
            ApexPages.currentPage().getParameters().put('payOpt','2');
            
            nmPaymentNew Controller = new nmPaymentNew();
            controller.objPayment.nm_DemandDraftNumber__c ='1234';
            controller.objPayment.nm_DemandDraftDate__c = System.today();
            controller.objPayment.nm_NameoftheBank__c ='PNG';
            controller.objPayment.nm_BankLocation__c ='Vile Parle';
            controller.objPayment.nm_DispatchDate__c = System.today();
            

            controller.generateRegistrationReceiptNo();
            controller.currentAdmissionSession = 'July';
            controller.currentAdmissionYear = '2017';
            controller.getMapOfActiveCalender();
            //alreadyPaidOptionAmount method to cover
            controller.AlreadyPaidAdmissionFee = true;
            controller.alreadyPaidOptionAmount('FullFee');
            controller.alreadyPaidOptionAmount('MultipleSemFee');
            controller.alreadyPaidOptionAmount('AnnualFee');
            
            //make online payment
            controller.ICName = 'Verizon';
            controller.paymentFor ='Admission';
            controller.paymentGateWayName = 'HDFC GateWay';
            controller.MakeOnlinePayment();
            controller.SaveDD();
            
            controller.paymentFor ='Registration';
            controller.MakeOnlinePayment();
            controller.SaveDD();
            
            //updateDetails
            controller.programName = objLead.nm_Program__c;
            controller.eligibility  = objLead.nm_EligiblityCriteria__c;
            controller.proceedToDirectLoan();
            
            //MakePaymentAfterResponse
            nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
            controller.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c,'Registration_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false'+objLead.id,'CAPTURED'));
            controller.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c,'Admission_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false'+objLead.id,'ERROR'));
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest_test2() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objLead.id);
            ApexPages.currentPage().getParameters().put('IsReRestration','false');
            ApexPages.currentPage().getParameters().put('IC','false');
            ApexPages.currentPage().getParameters().put('sem','1');
            ApexPages.currentPage().getParameters().put('amount','1800');
            ApexPages.currentPage().getParameters().put('payOpt','2');
            
            nmPaymentNew Controller = new nmPaymentNew();
            controller.objPayment.nm_DemandDraftNumber__c ='1234';
            controller.objPayment.nm_DemandDraftDate__c = System.today();
            controller.objPayment.nm_NameoftheBank__c ='PNG';
            controller.objPayment.nm_BankLocation__c ='Vile Parle';
            controller.objPayment.nm_DispatchDate__c = System.today();


            controller.currentAdmissionSession = 'July';
            controller.currentAdmissionYear = '2017';
            controller.getMapOfActiveCalender();
            //alreadyPaidOptionAmount method to cover
            controller.AlreadyPaidAdmissionFee = true;
            controller.alreadyPaidOptionAmount('FullFee');
            controller.alreadyPaidOptionAmount('MultipleSemFee');
            controller.alreadyPaidOptionAmount('AnnualFee');

            //make online payment
            controller.ICName = 'Verizon';
            controller.paymentFor ='Installment-Admission';
            controller.paymentGateWayName = 'BillDesk GateWay';
            controller.MakeOnlinePayment();
            controller.SaveDD();

            controller.paymentGateWayName = 'Paytm GateWay';
            controller.paymentFor ='InitialAdmissionFee';
            controller.MakeOnlinePayment();
            controller.SaveDD();

            //updateDetails
            controller.programName = objLead.nm_Program__c;
            controller.eligibility  = objLead.nm_EligiblityCriteria__c;
            controller.proceedToDirectLoan();

            nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
            controller.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c,'Installment-Admission_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false'+objLead.id,'CAPTURED'));
            controller.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c,'InitialAdmissionFee_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false'+objLead.id,'CAPTURED'));
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest_test3() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objLead.id);
            ApexPages.currentPage().getParameters().put('IsReRestration','false');
            ApexPages.currentPage().getParameters().put('IC','false');
            ApexPages.currentPage().getParameters().put('sem','1');
            ApexPages.currentPage().getParameters().put('amount','1800');
            ApexPages.currentPage().getParameters().put('payOpt','2');
            
            nmPaymentNew Controller = new nmPaymentNew();
            controller.objPayment.nm_DemandDraftNumber__c ='1234';
            controller.objPayment.nm_DemandDraftDate__c = System.today();
            controller.objPayment.nm_NameoftheBank__c ='PNG';
            controller.objPayment.nm_BankLocation__c ='Vile Parle';
            controller.objPayment.nm_DispatchDate__c = System.today();


            controller.currentAdmissionSession = 'July';
            controller.currentAdmissionYear = '2017';
            controller.getMapOfActiveCalender();
            //alreadyPaidOptionAmount method to cover
            controller.AlreadyPaidAdmissionFee = true;
            controller.alreadyPaidOptionAmount('FullFee');
            controller.alreadyPaidOptionAmount('MultipleSemFee');
            controller.alreadyPaidOptionAmount('AnnualFee');

            //make online payment
            controller.ICName = 'Emerson';
            controller.paymentFor ='DownPayment-Admission';
            controller.MakeOnlinePayment();
            controller.SaveDD();
            
            //controller.paymentFor ='EMI-Admission';
           // controller.MakeOnlinePayment();
          //  controller.SaveDD();

            //updateDetails
            controller.programName = objLead.nm_Program__c;
            controller.eligibility  = objLead.nm_EligiblityCriteria__c;
            controller.proceedToDirectLoan();

            nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
            controller.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c,'DownPayment-Admission_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false'+objLead.id,'CAPTURED'));
          //  controller.MakePaymentAfterResponse('1234','CC',objPaymentInitation.nm_Merchant_Track_Id__c ,'123456','CAPTURED',null,null,'EMI-Admission_00QO0000009ybqKMAQ_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null'+objLead.id,'ABDCTest','cs_1SemLecturesFee_null',null,0,0);
        Test.stopTest();
    }

    
    public static testmethod void AccountRegistrationPaymentTest(){
        Account objAccount = [select id,nm_LeadId__c,nm_Tagged_Pricebook__c from Account  limit 1];
        Opportunity objOpps = [select id,Down_Payment_Made__c from Opportunity limit 1];
        nm_StudentProgram__c objStudentProgram = [select id,nm_EligiblityCriteria__c,nm_Program__c  from nm_StudentProgram__c limit 1];
        
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Late Fee');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP );
        mapPricebook.put('Registration Fee',entryP );
        mapPricebook.put('Live Lectures',entryP );
        system.debug('mapPricebooktest--->'+mapPricebook);
             
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
            // ApexPages.currentPage().getParameters().put('OppsId',objOpps.id);
            ApexPages.currentPage().getParameters().put('IsReRestration','false');
            ApexPages.currentPage().getParameters().put('IC','false');
            ApexPages.currentPage().getParameters().put('sem','1');
            ApexPages.currentPage().getParameters().put('amount','1800');
            ApexPages.currentPage().getParameters().put('payOpt','2');
            ApexPages.currentPage().getParameters().put('oppId',objOpps.id);
            
            nmPaymentNew Controller = new nmPaymentNew();
            Controller.getBacklogDataFromStudentZone('77115001053');
            system.debug('mapPricebooktest--->'+mapPricebook);
            //updateDetails
            controller.programName = objStudentProgram.nm_Program__c;
            controller.eligibility  = objStudentProgram.nm_EligiblityCriteria__c;
            controller.objOpportunity = objOpps;
            controller.updateLoanDetails('Opportunity');
            controller.TagPriceBookId = null;
            
            //make online payment
            controller.ICName = 'Verizon';
            controller.paymentFor ='Admission';
            controller.paymentGateWayName = 'HDFC GateWay';
            // controller.MakeOnlinePayment();
            controller.SaveDD();
            controller.CreateDDRecord(new nm_Payment__c(), 'Admission', 2000 , 2000, 'Admission' ,'Admission' ,0 ,0 ,0);
            controller.proceedToDirectLoan();
            controller.updateOpportunityFeesType(objOpps.id,'Admission',500);
        Test.stopTest();
    }
    
    public static testmethod void AccountReRegistrationPaymentTest(){
        Account objAccount = [select id,nm_LeadId__c from Account  limit 1];
        Opportunity objOpps = [select id,AccountId,nm_StudentProgram__c,nm_Semester__c from Opportunity limit 1];
        nm_StudentProgram__c objStudentProgram = [select id,nm_Student__c,nm_EligiblityCriteria__c,nm_Program__c  from nm_StudentProgram__c limit 1];
        objOpps.nm_Semester__c = '2';
        objOpps.StageName = 'Pending Payment';
        objOpps.nm_StudentProgram__c = objStudentProgram.id;
        update objOpps;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.id);
           // ApexPages.currentPage().getParameters().put('OppsId',objOpps.id);
            ApexPages.currentPage().getParameters().put('IsReRestration','true');
            ApexPages.currentPage().getParameters().put('IC','false');
            ApexPages.currentPage().getParameters().put('sem','1');
            ApexPages.currentPage().getParameters().put('amount','1800');
            ApexPages.currentPage().getParameters().put('payOpt','2');
            ApexPages.currentPage().getParameters().put('oppId',objOpps.id);
            
            nmPaymentNew Controller = new nmPaymentNew();
            Controller.getBacklogDataFromStudentZone('77115001053');
            
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

    @future (callout=true)
    public static void generateDummyData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
           nmGenericTracker.CreateProduct('Live Lectures',1200);
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Initial Payment','Lead','Initial Payment');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Late Fees','Lead','Late Fees');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'AnnualFee','Lead','AnnualFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'FullFee','Lead','FullFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'MultipleSemFee','Lead','MultipleSemFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Admission','Lead','Admission');
        
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-Admission');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-AnnualFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-FullFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-MultipleSemFee');
        
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-3SemFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-4SemFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Installment','Lead','Installment-5SemFee');
        
        
        nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-Admission');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-AnnualFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-FullFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-MultipleSemFee');
        
         nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-3SemFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-4SemFee');
        nmGenericTracker.CreatePaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-5SemFee');
      
        
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
     //   objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
      objAccount.nm_LeadId__c = String.valueOf(objLead.id);
        update objAccount;
        
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
    // Opportunity objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Certificate Programs',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        
        Product2 lateFeeproduct = nmGenericTracker.CreatelateProduct(objopp);
        
            Product2 productvs1 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,1);
            nmGenericTracker.CreateCourseList(objopp,1,'Business Economics',productvs1.id,23);
            nmGenericTracker.CreateCourseList(objopp,1,'Economics',productvs1.id,45);
            nmGenericTracker.CreateCourseList(objopp,1,'Business science',productvs1.id,67);
             Product2 productvs2 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,2);
            nmGenericTracker.CreateCourseList(objopp,2,'Economics value',productvs2.id,673);
            nmGenericTracker.CreateCourseList(objopp,2,'Economics to resolved',productvs2.id,43);
            nmGenericTracker.CreateCourseList(objopp,2,'Business to overcome',productvs2.id,232);
            Product2 productvs3 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,3);
            nmGenericTracker.CreateCourseList(objopp,3,'Supply chain',productvs3.id,672);
            nmGenericTracker.CreateCourseList(objopp,3,'Disbursed chain',productvs3.id,345);
            Product2 productvs4 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,4);
            nmGenericTracker.CreateCourseList(objopp,4,'Trade head',productvs4.id,897);
            nmGenericTracker.CreateCourseList(objopp,4,'Stock market',productvs4.id,5667);
            
        Product2 registrationproduct = nmGenericTracker.CreateRegistrationProduct(objopp);
        //Product2 lateFeeproduct = nmGenericTracker.CreatelateProduct(objopp);
        Product2 Careerproduct = nmGenericTracker.CreateCareerProduct(objopp);
        nmGenericTracker.CreatePriceBookEntry(lateFeeproduct,1000);
        nmGenericTracker.CreatePriceBookEntry(registrationproduct,1200);
        nmGenericTracker.CreatePriceBookEntry(Careerproduct ,1200);
          Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objopp);
        //form COnfiguration
        NM_Payment_Form_Configuration__c objConfig1 = nmGenericTracker.createPaymentFOrmConfiguration('Certificate Programs','Admission','1');//lead registration
        NM_Payment_Form_Configuration__c objConfig2 = nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');//account registration
        NM_Payment_Form_Configuration__c objConfig3 = nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Re-Registration','1');//account reregistration
        
        objConfig1.MergeAdmissionFeeWithRegistration__c = true;
       
        objConfig1.PercentageAtoR__c = 0.20;
        objConfig2.MergeAdmissionFeeWithRegistration__c = true;
        objConfig2.PercentageAtoR__c = 0.20;
        objConfig2.ShowLiveLectures__c=true;
       
        List<NM_Payment_Form_Configuration__c> lstConfig = new List<NM_Payment_Form_Configuration__c>();
        lstConfig.add(objConfig1);
        lstConfig.add(objConfig2);
        update lstConfig;

        //custom setting
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
        objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
        objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
        insert objSystemConfiguration;
        
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        
        //Lead Product Sem1
        nmGenericTracker.createProductAndPricebookEntry('Semester','1',objLead.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','1',objOpp.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','2',objLead.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','2',objOpp.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Certificate_Annual',null,null,priceBooke2Id);
        nmGenericTracker.CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
        nmGenericTracker.CreateElegibilityCriteria();
        nmGenericTracker.CreateCalender();
        nmGenericTracker.createLateFeeRecord('Is Lateral','Certificate Programs');
    }
}