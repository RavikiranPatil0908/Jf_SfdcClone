/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class PaymentPageControllerTracker {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status":"Success","message":null,"pendingSubjects":[{"sapid":null,"subjectId":"118","subject":"Business Statistics","sem":"2","courseId":"462"},{"sapid":null,"subjectId":"25","subject":"Corporate Finance","sem":"3","courseId":"475"},{"sapid":null,"subjectId":"80","subject":"Financial Accounting & Analysis","sem":"2","courseId":"490"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class BillDesk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'test|test|test';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class ICICI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"order_token":"test","order_currency":"INR","payment_link":"www.google.com","pendingSubjects":[{"sapid":null,"subjectId":"118","subject":"Business Statistics","sem":"2","courseId":"462"},{"sapid":null,"subjectId":"25","subject":"Corporate Finance","sem":"3","courseId":"475"},{"sapid":null,"subjectId":"80","subject":"Financial Accounting & Analysis","sem":"2","courseId":"490"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RazorPay implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"id":"test","amount":100,"currency":"INR","udf1":"test","udf2":"test","udf3":"test","return_url":"www.google.com"}';
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
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        List<nm_Payment__c> lstPayments = new List<nm_Payment__c>();
        lstPayments.add(createPaymentRecords(objLead.id,'Registration','Lead','Registration'));
        lstPayments.add(createPaymentRecords(objLead.id,'Initial Payment','Lead','Initial Payment'));
        lstPayments.add(createPaymentRecords(objLead.id,'Late Fees','Lead','Late Fees'));
        lstPayments.add(createPaymentRecords(objLead.id,'AnnualFee','Lead','AnnualFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'FullFee','Lead','FullFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'MultipleSemFee','Lead','MultipleSemFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'Admission','Lead','Admission'));
        
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-Admission'));
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-AnnualFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-FullFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-MultipleSemFee'));
        
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-3SemFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-4SemFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'Installment','Lead','Installment-5SemFee'));
        
        
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-Admission'));
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-AnnualFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-FullFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-MultipleSemFee'));
        
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-3SemFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-4SemFee'));
        lstPayments.add(createPaymentRecords(objLead.id,'DownPayment','Lead','DownPayment-5SemFee'));
        
        insert lstPayments;

        PriceBook2 objPriceBook = createPriceBook();

        //registration Account
        Account objAccount = nmGenericTracker.createAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = objPriceBook.Id;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id);
        update objAccount;
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        
        List<Product2> lstProducts = new List<Product2>();
        lstProducts.add(createSemesterProductvs2(objopp.nm_Program__c,1));
        lstProducts.add(createSemesterProductvs2(objopp.nm_Program__c,2));
        lstProducts.add(createSemesterProductvs2(objopp.nm_Program__c,3));
        lstProducts.add(createSemesterProductvs2(objopp.nm_Program__c,4));
        insert lstProducts;

        Map<String,Product2> semesterVsProductMap = semesterVsProductMap(lstProducts);
        List<nm_Courses__c> lstCourses = new List<nm_Courses__c>();
        Product2 productvs1 = semesterVsProductMap.get('1');
        lstCourses.add(createCourseList(objopp,1,'Business Economics',productvs1.id,23));
        lstCourses.add(createCourseList(objopp,1,'Economics',productvs1.id,45));
        lstCourses.add(createCourseList(objopp,1,'Business science',productvs1.id,67));
        Product2 productvs2 = semesterVsProductMap.get('2');
        lstCourses.add(createCourseList(objopp,1,'Economics value',productvs2.id,673));
        lstCourses.add(createCourseList(objopp,1,'Economics to resolved',productvs2.id,43));
        lstCourses.add(createCourseList(objopp,1,'Business to overcome',productvs2.id,232));
        Product2 productvs3 = semesterVsProductMap.get('3');
        lstCourses.add(createCourseList(objopp,1,'Supply chain',productvs3.id,672));
        lstCourses.add(createCourseList(objopp,1,'Disbursed chain',productvs3.id,345));
        Product2 productvs4 = semesterVsProductMap.get('4');
        lstCourses.add(createCourseList(objopp,1,'Trade head',productvs4.id,897));
        lstCourses.add(createCourseList(objopp,1,'Stock market',productvs4.id,5667));
        
        insert lstCourses;
        
        Map<String,Product2> mapProductsV2 = new Map<String,Product2>();
        mapProductsV2.put('Registration Fee',createProduct('Registration Fee'));
        mapProductsV2.put('Career Development',createProduct('Career Development'));
        mapProductsV2.put('Late Fee',createProduct('Late Fee'));
        insert mapProductsV2.values();

        
        List<PriceBookEntry> lstPriceBookEntryToInsert = new List<PriceBookEntry>();
        lstPriceBookEntryToInsert.addAll(createPriceBookEntry(mapProductsV2.get('Late Fee'),1000,objPriceBook.Id));
        lstPriceBookEntryToInsert.addAll(createPriceBookEntry(mapProductsV2.get('Registration Fee'),1200,objPriceBook.Id));
        lstPriceBookEntryToInsert.addAll(createPriceBookEntry(mapProductsV2.get('Career Development') ,1200, objPriceBook.Id));
        insert lstPriceBookEntryToInsert;

        Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objopp);
        //form COnfiguration
        List<NM_Payment_Form_Configuration__c> lst = new List<NM_Payment_Form_Configuration__c>();
        lst.add(createPaymentFormConfiguration('Certificate Programs','Admission','1', null));//lead registration
        lst.add(createPaymentFormConfiguration('Post Graduate Diploma Programs','Admission','1' , 0.20));//account registration
        lst.add(createPaymentFormConfiguration('Post Graduate Diploma Programs','Re-Registration','1', 0.20));//account reregistration

        for (NM_Payment_Form_Configuration__c objconfig : lst) {
            objconfig.Price_Book__c = objPriceBook.Id;
        }
        insert lst;

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

    @isTest
    static void leadPaymentTest1(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            
            PaymentPageController objController = new PaymentPageController();
            objController.setObjectId(objLead.id);
            objController.setObjectType('Lead');
            objController.getObjectType();
            objController.getObjectId();

            //make online payment
            objController.objDetails.ICName = 'Verizon';
            objController.paymentFor ='Admission';
            objController.paymentGateWayName = 'HDFC GateWay';
            objController.makeOnlinePayment();
            
            objController.paymentFor ='Registration';
            objController.makeOnlinePayment();
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest2(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BillDesk());
            PaymentPageController objController = new PaymentPageController();
            objController.setObjectId(objLead.id);
            objController.setObjectType('Lead');

            //make online payment
            objController.objDetails.ICName = 'Verizon';
            objController.paymentFor ='Admission';
            objController.paymentGateWayName = 'BillDesk GateWay';
            objController.makeOnlinePayment();
            objController.objDetails.liveLecType = '1SemLecturesFee';
            objController.updateLoanDetailsForSubvention('Lead',100);
            
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest3(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RazorPay());

            PaymentPageController objController = new PaymentPageController();
            objController.setObjectId(objLead.id);
            objController.setObjectType('Lead');

            //make online payment
            objController.objDetails.ICName = 'Verizon';
            objController.paymentFor ='Installment-Admission';
            objController.paymentGateWayName = 'Razorpay GateWay';
            objController.makeOnlinePayment();

            objController.getmultiplicationFactor('AnnualFee');
            objController.getmultiplicationFactor('3SemFee');
            objController.getmultiplicationFactor('4SemFee');
            objController.getmultiplicationFactor('5SemFee');
            objController.getmultiplicationFactor('FullFee');
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest4(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ICICI());
            PaymentPageController objController = new PaymentPageController();
            objController.setObjectId(objLead.id);
            objController.setObjectType('Lead');

            //make online payment
            objController.objDetails.ICName = 'Verizon';
            objController.paymentFor ='DownPayment-Admission';
            objController.paymentGateWayName = 'ICICI GateWay';
            objController.makeOnlinePayment();
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest5(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        Test.startTest();
            PaymentPageController objController = new PaymentPageController();
            objController.setObjectId(objLead.id);
            objController.setObjectType('Lead');

            //make online payment
            objController.objDetails.ICName = 'Verizon';
            objController.paymentFor ='Admission';
            objController.paymentGateWayName = 'Paytm GateWay';
            objController.makeOnlinePayment();
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest6(){
        Test.startTest();
            PaymentPageController objController = new PaymentPageController();
            objController.makeOnlinePayment();
        Test.stopTest();
    }

    @isTest
    static void leadPaymentTest7(){
        Test.startTest();
            PaymentPageController objController = new PaymentPageController();
            objController.objDetails.TagPriceBookId = null;
            objController.configurePaymentOption();
        Test.stopTest();
    }

    @isTest 
    static void accountRegistrationPaymentTest(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Account objAccount = [select id,nm_LeadId__c,nm_Tagged_Pricebook__c from Account  limit 1];
            Opportunity objOpps = [select id,Down_Payment_Made__c,nm_Fee_Type__c,Loan_Type__c,EMI_Amount__c,Tenure__c,Interest_Rate__c,
                DP_EMI_Processing_Fee__c,Loan_Cancellation_Reason__c,Loan_Application_Cancelled__c,LiveLecturesType__c,CourseList__c,BacklogList__c from Opportunity limit 1];
            nm_StudentProgram__c objStudentProgram = [select id,nm_EligiblityCriteria__c,nm_Program__c  from nm_StudentProgram__c limit 1];

            ProductHelper productHelper = new ProductHelper();
            Map<String,PriceBookEntry> mapPricebook = productHelper.getMapOfProductVsPriceBookEntry(objAccount.nm_Tagged_Pricebook__c);
            System.debug('objAccount.nm_Tagged_Pricebook__c ==>'+objAccount.nm_Tagged_Pricebook__c);
            System.debug('mapPricebook.get(\'Late Fee\') ==>'+mapPricebook.get('Late Fee'));
            PriceBookEntry entryP = mapPricebook.get('Late Fee');
            mapPricebook.put('PG_All_Sem',entryP);
            mapPricebook.put('MSAllSemFee',entryP );
            mapPricebook.put('Registration Fee',entryP );
            mapPricebook.put('Live Lectures',entryP );
            System.debug('mapPricebooktest--->'+mapPricebook);

            PaymentPageController objController = new PaymentPageController();
            objController.opportunityId = objOpps.Id;

            objController.setObjectId(objAccount.id);
            objController.setObjectType('Account');
            objController.getObjectType();
            objController.getObjectId();
            
            objController.getBacklogDataFromStudentZone('77115001053');
            System.debug('mapPricebooktest--->'+mapPricebook);
            //updateDetails
            objController.objDetails.programName = objStudentProgram.nm_Program__c;
            objController.objStudentDetails.eligibility  = objStudentProgram.nm_EligiblityCriteria__c;
            objController.objOpportunity = objOpps;
            objController.opportunityId = objOpps.Id;
            objController.updateLoanDetails('Opportunity');
            objController.objDetails.TagPriceBookId = objAccount.nm_Tagged_Pricebook__c;
            
            //make online payment
            objController.objDetails.ICName = 'Verizon';
            objController.paymentFor ='InitialAdmissionFee';
            objController.paymentGateWayName = 'HDFC GateWay';
            objController.objDownPayment = [SELECT id,nm_Merchant_Track_Id__c,nm_ActualPaymentAmmount__c,nm_Installment_Payment_Ref__c,nm_PaymentType__c FROM nm_Payment__c WHERE nm_PaymentType__c = 'DownPayment' LIMIT 1];
            objController.proceedToDirectLoan();
        Test.stopTest();
    }

    public static nm_Payment__c createPaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef){
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
        return objPayment;
    }

    public static Product2 createSemesterProductvs2(id programId,Integer sem) {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Semester';
        product2.nm_Program__c = programId;
        product2.nm_Semester__c = String.valueof(sem);
        product2.isActive = true;
        return product2;
    }

    public static Map<String,Product2> semesterVsProductMap(List<Product2> lstProducts) {
        Map<String,Product2> semesterVsProductMap = new Map<String,Product2>();
        for(Product2 product2 : lstProducts) {
            semesterVsProductMap.put(product2.nm_Semester__c, product2);
        }  
        return semesterVsProductMap;
    }

    public static nm_Courses__c createCourseList(Opportunity objOpp,Integer Sem,String CourseName,Id productid,Integer code) {
        nm_Courses__c courses = new nm_Courses__c();
        courses.Name = CourseName;
        courses.Program__c = objOpp.nm_Program__c;
        courses.Semester__c = Sem;
        //Product2 product2 = CreateSemesterProductSemwise(objOpp,String.valueof(Sem));
        courses.nm_Semester__c = productid;
        courses.ConsumerType__c='Retail';
        courses.IsActive__c = true;
        courses.Program_Structure__c ='Jul2019';
        courses.Student_Zone_Course_Id__c = code;
        courses.Student_Zone_Subject_Code__c = 'tesrt';
        courses.Student_Zone_Program_Code__c =objOpp.Program_Name__c;
        return courses;
    }

    public static List<PriceBookEntry> createPriceBookEntry(Product2 product, decimal productPrice, Id Pricebook2Id) {
        Id pricebookId = Test.getStandardPricebookId();
        List<PriceBookEntry> lst = new List<PriceBookEntry>();
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        lst.add(standardPriceBookEntry);
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = Pricebook2Id, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        lst.add(objPriceBookEntry);
        return lst;
    }

    public static Product2 createProduct(String type) {
        Product2 product2 = new Product2();
        product2.Name = type;
        product2.isActive = true;
        return product2;
    }

    public static PriceBook2 createPriceBook() {
        Pricebook2 priceBook = new Pricebook2(Name='NMIMS New Price Book', isActive=true , nmSession_Start_Date__c = System.today().addDays(-1), nmSession_End_Date__c = System.today().addDays(2) );
        insert priceBook;
        return priceBook;
    }

    public static NM_Payment_Form_Configuration__c createPaymentFormConfiguration(String programCategory,String programType,String semester, Decimal mergePercent){
        NM_Payment_Form_Configuration__c objpaymentconfig = new NM_Payment_Form_Configuration__c();
        objpaymentconfig.Program_Category__c = programCategory;
        objpaymentconfig.Payment_Type__c =programType;
        objpaymentconfig.Semester__c= semester;
        objpaymentconfig.Current_Admission_Year__c = '2017';
        objpaymentconfig.Session__c = 'July';
        objpaymentconfig.No_Of_Applicable_Installment__c ='1';
        objpaymentconfig.Registration_Fee__c=1200;
        objpaymentconfig.Program_Type__c='';
        objpaymentconfig.Reg_No_Allowed_After_End_Date__c = '01723456';
        objpaymentconfig.Capital_Float_AEP_Available__c = 'Mumbai,Pune';
        objpaymentconfig.Show_Registration_Payment_Option__c = true;
        objpaymentconfig.Show_Admission_Payment_Option__c = true;
        objpaymentconfig.ShowInitialAdmissionPayment__c = true;
        objpaymentconfig.Payment_Window_EndDate__c = System.now().addDays(1);
        objpaymentconfig.Initial_Admission_Payment__c = 1200;
        objpaymentconfig.Registration_Fee__c = 12000;
        objpaymentconfig.Is_Late_Fee_Applicable__c = true;
        objpaymentconfig.DownPayment_Amount__c = 5000;
        objpaymentconfig.ShowLiveLectures__c = true;
        if(mergePercent != null) {
            objpaymentconfig.MergeAdmissionFeeWithRegistration__c = true;
            objpaymentconfig.PercentageAtoR__c = mergePercent;
        }
        return objpaymentconfig;
    }
}