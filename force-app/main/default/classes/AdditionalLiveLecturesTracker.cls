/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-01-2023
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   05-02-2021   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class AdditionalLiveLecturesTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"sapId": "77121900571","acadYear": "2021","acadMonth": "Jul","courseIds": [2040,2041,2043,2044,2045,2046],"status": "success","message": "Success.","payment_link":"www.google.com","id":"test","attempts","1"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        
        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = System.today()+60;
        objCal.Session__c = 'July';
        objCal.Year__c = 2020;
        objCal.LectureDeliveryStartRange__c = 7;
        objCal.Session_End_Date__c = System.today()+60;
        objCal.nm_Type__c = 'Post Graduate Diploma Programs';
        insert objCal;

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c =System.today();
        objAccount.nm_ProgramType__c = 'Post Graduate Diploma Programs';
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'FullFee');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;

        NM_Payment_Form_Configuration__c nmpay = nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');        
        nmpay.ShowLiveLectures__c = true;
        nmpay.Current_Admission_Year__c = '2020';
        nmpay.Session__c = 'July';
        nmpay.Program_Type__c = null;
        update nmpay;

        Product2 lateFeeproduct = nmGenericTracker.CreatelateProduct(objopp);
        nmGenericTracker.createProductAndPricebookEntry('Annual',null,null,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Live Lectures',null,null,priceBooke2Id);
         
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
        Product2 Careerproduct = nmGenericTracker.CreateCareerProduct(objopp);
        nmGenericTracker.CreatePriceBookEntry(lateFeeproduct,1000);
        nmGenericTracker.CreatePriceBookEntry(registrationproduct,1200);
        nmGenericTracker.CreatePriceBookEntry(Careerproduct ,1200);
        Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objopp);
        nm_Payment_Initiated__c objPaymentInitation = nmGenericTracker.CreatePaymentInitiatedRecordForOpportunity(objopp,'Live Lectures');
    }

    @isTest 
    static void unitTest1(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,nm_StudentNo__c,nm_DateOfBirth__c,nm_Tagged_Pricebook__c FROM Account LIMIT 1];
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Live Lectures');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP);
        mapPricebook.put('Registration Fee',entryP);
        mapPricebook.put('Live Lectures',entryP);
        System.debug('mapPricebooktest--->'+mapPricebook);
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objAccount.nm_StudentNo__c);
            ApexPages.currentPage().getParameters().put('dob',objAccount.nm_DateOfBirth__c.format());
            AdditionalLiveLectures obj = new AdditionalLiveLectures();
            obj.liveLecType = '4SemLecturesFee';
            obj.MakeOnlinePayment();
        Test.stopTest();
    }

    @isTest 
    static void unitTest2(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,Current_semester__c,nm_StudentNo__c,nm_DateOfBirth__c,nm_Tagged_Pricebook__c FROM Account LIMIT 1];
        Opportunity objOpp = [SELECT id,LiveLecturesType__c,Sem__c,CourseList__c,Student_Number__c,nm_Session__c,nm_Year__c FROM Opportunity WHERE AccountId=:objAccount.id LIMIT 1];
        objAccount.Current_semester__c = objOpp.Sem__c;
        update objAccount;
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
        System.debug('objAccount --->'+objAccount );
        System.debug('objOpp --->'+objOpp );
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Live Lectures');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP);
        mapPricebook.put('Registration Fee',entryP);
        mapPricebook.put('Live Lectures',entryP);
        System.debug('mapPricebooktest--->'+mapPricebook);

        objOpp.LiveLecturesType__c = 'Custom';
        objOpp.CourseList__c = '1,23';
        update objOpp;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.nm_StudentNo__c);
            ApexPages.currentPage().getParameters().put('dob',objAccount.nm_DateOfBirth__c.format());
            AdditionalLiveLectures obj = new AdditionalLiveLectures();
            obj.paymentFor ='Live Lectures';
            obj.paymentGateWayName = 'HDFC GateWay';
            obj.MakeOnlinePayment();
            obj.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c, 'Live Lectures_'+objAccount.id+'_6000.00_PostPaymentPage_false_'+objOpp.id, 'ERROR')); 
            obj.createStudentSessionCourses(objOpp);
            obj.getBacklogDataFromStudentZone('7567567');
        Test.stopTest();
    }

    @isTest 
    static void unitTest3(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,Current_semester__c,nm_StudentNo__c,nm_DateOfBirth__c,nm_Tagged_Pricebook__c FROM Account LIMIT 1];
        Opportunity objOpp = [SELECT id,LiveLecturesType__c,Sem__c,CourseList__c,Student_Number__c,nm_Session__c,nm_Year__c FROM Opportunity WHERE AccountId=:objAccount.id LIMIT 1];
        objAccount.Current_semester__c = objOpp.Sem__c;
        update objAccount;
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
        System.debug('objAccount --->'+objAccount );
        System.debug('objOpp --->'+objOpp );
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Live Lectures');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP);
        mapPricebook.put('Registration Fee',entryP);
        mapPricebook.put('Live Lectures',entryP);
        System.debug('mapPricebooktest--->'+mapPricebook);

        objOpp.LiveLecturesType__c = 'Custom';
        objOpp.CourseList__c = '1,23';
        update objOpp;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            AdditionalLiveLectures obj = new AdditionalLiveLectures();
            obj.recordId = objAccount.id;
            obj.paymentFor ='Live Lectures';
            obj.paymentGateWayName = 'ICICI GateWay';
            obj.QueryAccountOpportunityAndPaymentRelatedDetails();
            obj.MakeOnlinePayment();
            obj.paymentGateWayName = 'BillDesk GateWay';
            obj.MakeOnlinePayment();
            obj.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c, 'Live Lectures_'+objAccount.id+'_6000.00_PostPaymentPage_false_'+objOpp.id, 'ERROR'));
            obj.createStudentSessionCourses(objOpp);
            obj.getBacklogDataFromStudentZone('7567567');
            // to cover the Opportunity record.
            obj.recordId = objOpp.id;
            obj.QueryAccountOpportunityAndPaymentRelatedDetails();
            
        Test.stopTest();
    }

    @isTest 
    static void unitTest4(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,Current_semester__c,nm_StudentNo__c,nm_DateOfBirth__c,nm_Tagged_Pricebook__c FROM Account LIMIT 1];
        Opportunity objOpp = [SELECT id,LiveLecturesType__c,Sem__c,CourseList__c,Student_Number__c,nm_Session__c,nm_Year__c FROM Opportunity WHERE AccountId=:objAccount.id LIMIT 1];
        objAccount.Current_semester__c = objOpp.Sem__c;
        update objAccount;
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
        System.debug('objAccount --->'+objAccount );
        System.debug('objOpp --->'+objOpp );
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Live Lectures');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP);
        mapPricebook.put('Registration Fee',entryP);
        mapPricebook.put('Live Lectures',entryP);
        System.debug('mapPricebooktest--->'+mapPricebook);

        objOpp.LiveLecturesType__c = 'Custom';
        objOpp.CourseList__c = '1,23';
        update objOpp;
        Calender__c objCal = new Calender__c();
        objCal.Live_Lecture_Switch_Date__c = System.today().addDays(1);
        objCal.Session__c = objOpp.nm_Session__c;
        objCal.Year__c = objOpp.nm_Year__c;
        objCal.nm_Type__c = 'Admission';
        objCal.Session_End_Date__c = System.today().addDays(1);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.nm_StudentNo__c);
            ApexPages.currentPage().getParameters().put('dob',objAccount.nm_DateOfBirth__c.format());
            AdditionalLiveLectures obj = new AdditionalLiveLectures();
            obj.paymentFor ='Live Lectures';
            obj.paymentGateWayName = 'Paytm GateWay';
            obj.MakeOnlinePayment();
            obj.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c, 'Live Lectures_'+objAccount.id+'_6000.00_PostPaymentPage_false_'+objOpp.id, 'ERROR'));
            obj.createStudentSessionCourses(objOpp);
            obj.getBacklogDataFromStudentZone('7567567');
        Test.stopTest();
    }

    @isTest 
    static void unitTest5(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,Current_semester__c,nm_StudentNo__c,nm_DateOfBirth__c,nm_Tagged_Pricebook__c FROM Account LIMIT 1];
        Opportunity objOpp = [SELECT id,LiveLecturesType__c,Sem__c,CourseList__c,Student_Number__c,nm_Session__c,nm_Year__c FROM Opportunity WHERE AccountId=:objAccount.id LIMIT 1];
        objAccount.Current_semester__c = objOpp.Sem__c;
        update objAccount;
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
        System.debug('objAccount --->'+objAccount );
        System.debug('objOpp --->'+objOpp );
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Live Lectures');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP);
        mapPricebook.put('Registration Fee',entryP);
        mapPricebook.put('Live Lectures',entryP);
        System.debug('mapPricebooktest--->'+mapPricebook);

        objOpp.LiveLecturesType__c = 'Custom';
        objOpp.CourseList__c = '1,23';
        update objOpp;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('id',objAccount.nm_StudentNo__c);
            ApexPages.currentPage().getParameters().put('dob',objAccount.nm_DateOfBirth__c.format());
            AdditionalLiveLectures obj = new AdditionalLiveLectures();
            obj.paymentFor ='Live Lectures';
            obj.paymentGateWayName = 'Razorpay GateWay';
            obj.MakeOnlinePayment();
            obj.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c, 'Live Lectures_'+objAccount.id+'_6000.00_PostPaymentPage_false_'+objOpp.id, 'ERROR'));
            obj.createStudentSessionCourses(objOpp);
            obj.getBacklogDataFromStudentZone('7567567');
        Test.stopTest();
    }

    @isTest 
    static void unitTest6(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,Current_semester__c,nm_StudentNo__c,nm_DateOfBirth__c,nm_Tagged_Pricebook__c FROM Account LIMIT 1];
        Opportunity objOpp = [SELECT id,LiveLecturesType__c,Sem__c,CourseList__c,Student_Number__c,nm_Session__c,nm_Year__c FROM Opportunity WHERE AccountId=:objAccount.id LIMIT 1];
        objAccount.Current_semester__c = objOpp.Sem__c;
        update objAccount;
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        nm_Payment_Initiated__c objPaymentInitation = [select id,nm_Merchant_Track_Id__c from nm_Payment_Initiated__c  limit 1];
        System.debug('objAccount --->'+objAccount );
        System.debug('objOpp --->'+objOpp );
        ProductHelper productHelper = new ProductHelper();
        Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
        Map<String,PriceBookEntry> mapPricebook = mapPricebookIdVsPriceBook.get(objAccount.nm_Tagged_Pricebook__c );
        PriceBookEntry entryP = mapPricebook.get('Live Lectures');
        mapPricebook.put('PG_All_Sem',entryP);
        mapPricebook.put('MSAllSemFee',entryP);
        mapPricebook.put('Registration Fee',entryP);
        mapPricebook.put('Live Lectures',entryP);
        System.debug('mapPricebooktest--->'+mapPricebook);

        objOpp.LiveLecturesType__c = 'Custom';
        objOpp.CourseList__c = '1,23';
        update objOpp;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            AdditionalLiveLectures obj = new AdditionalLiveLectures();
            obj.recordId = objOpp.id;
            obj.paymentFor ='Live Lectures';
            obj.paymentGateWayName = 'BillDesk GateWay';
            obj.QueryAccountOpportunityAndPaymentRelatedDetails();
            obj.MakeOnlinePayment();
            obj.MakePaymentAfterResponse(paymentResponse(objPaymentInitation.nm_Merchant_Track_Id__c, 'Live Lectures_'+objAccount.id+'_6000.00_PostPaymentPage_false_'+objOpp.id, 'ERROR'));
            obj.createStudentSessionCourses(objOpp);
            obj.getBacklogDataFromStudentZone('7567567');
            
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
        objResponse.udf2 = 'hjk_Custom_456,584,846+-+45';
        objResponse.currencyCode = 'INR';
        objResponse.feeChrages = 0;
        objResponse.tax = 0;
        return objResponse;
    }
}