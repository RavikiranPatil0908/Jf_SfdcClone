/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : @vickysahu
**/
@isTest
public with sharing class AEPMerchandiseControllerTracker {
    
    @IsTest
    static void methodName1(){
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Tshirt';
        product2.Family = 'AEP Merchandise';
        product2.Product_Size__c = 'S;M;L;XL;XXL';
        product2.isActive = true;
        insert product2;
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product2.Id, UnitPrice = 450, IsActive = true);
        insert standardPriceBookEntry;
        
        Pricebook2 customPB = CreatePriceBook();
        customPB.nmSession_Start_Date__c = Date.today();
        update customPB;
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product2.Id, UnitPrice = 450, IsActive = true);
        insert objPriceBookEntry;

        nm_Centers__c center = nmGenericTracker.CreateCenter('Mumbai');

        nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.AEP__c =center.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.Receipt_Number__c = '70021548889';
        objPayment2.nm_PaymentStatus__c ='Payment Made';
         objPayment2.nm_PaymentType__c ='Tshirt';
         objPayment2.Merchendise__c ='[{"ProductName":"Tshirt","ProductId":"' + product2.Id +'","selectedSize":"XXL","NumberOfProduct":1,"TotalPrice":472.5},{"TotalCartPrice":472.5}]';
        insert objPayment2;
        Test.startTest();
        AEPMerchandiseController.getAllProducts();
        AEPMerchandiseEmailController AEPMerchandiseEmailController = new AEPMerchandiseEmailController();
        AEPMerchandiseEmailController.getRecordOfPayment(objPayment2.Id);
        
        Test.stopTest();
        
    }

    @IsTest
    static void methodName2(){
        nm_Centers__c center = nmGenericTracker.CreateCenter('Mumbai');
        center.AEP_email_id__c = 'test@test.com';
        update center;
        nm_UserMapping__c usermapping = new nm_UserMapping__c();
        usermapping.nm_User__c = UserInfo.getUserId();
        usermapping.nm_Centers__c = center.id;
        usermapping.nm_Head__c  = true;
        insert usermapping;

        nm_Payment__c objPay = new nm_Payment__c();
        objPay.nm_Amount__c = 1000;
        objPay.nm_ActualPaymentAmmount__c = 1000;
        objPay.AEP__c = center.Id;
        objPay.nm_PaymentStatus__c ='Payment Made';
        objPay.nm_PaymentType__c = 'Tshirt';
        insert objPay;

        Case objCase = new Case();
        objCase.Subject= 'Test';
        objCase.SuppliedEmail= 'test@test.com';
        insert objCase;
        List<Case> lstCase = [SELECT id,CaseNumber,Case_Id__c,Owner_update__c,Tech_Issue__c,Mass_Email_Case_status__c,status,ContactEmail,SuppliedEmail,Description,Subject,Reference__c FROM Case  ];
        Test.startTest();
        AEPMerchandiseController.getCenterUserData(UserInfo.getUserId());
        AEPMerchandiseController.placeOrder(center.Id, '123');
        AEPMerchandiseController.SendMailForAEPMerchandise(objPay.Id);
        AEPMerchandiseController.searchCase('pha', '{"1":{"apiName":"Status","extra":"","value":["Closed","Escalated"],"fieldType":"MultiplePickList"},"2":{"apiName":"nm_Category__c","extra":"","value":["Examinations"],"fieldType":"MultiplePickList"}}');
        AEPMerchandiseController.updateStatusAndSendMailForCase('{"caseNumbers":"' + lstCase[0].CaseNumber   +'","caseStatus":"Closed","caseSubject":"testestset","caseSubjectType":"New Subject","caseDescription":"estsetstt","isNewSubjectNeeded":true, "isEmailToSent":true}');
        Test.stopTest();
        
    }

    @IsTest
    static void methodName3(){
        Calender__c objCal = new Calender__c(Name = 'January 2023', Session_Start_Date__c = Date.today().addYears(-3), Session_End_Date__c = Date.today().addYears(+3), Session__c = 'January', Year__c = 2023, Category__c = 'Admission');
        insert objCal;
        insert new Calender__c(Name = 'January 2023', Session_Start_Date__c = Date.today().addYears(-3), Session_End_Date__c = Date.today().addYears(+3), Session__c = 'January', Year__c = 2023, Category__c = 'Live Lectures', nm_Type__c = 'MBA (Distance) Programs');

        NM_Payment_Form_Configuration__c objPayConf = new NM_Payment_Form_Configuration__c(Semester__c = '1', Program_Category__c = 'MBA (Distance) Programs', Payment_Type__c = 'Admission', Current_Admission_Year__c = '2023', Session__c = 'January', Loan_Window_EndDate__c = Datetime.now().addYears(+3), Payment_Window_StartDate__c = Datetime.now().addYears(-3), Payment_Window_EndDate__c = Datetime.now().addYears(+3) );
        insert objPayConf;

        insert new Late_Fee__c(Name = 'Late Fees for Admission January 2023 slab 1', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(+120), nm_Type__c = 'MBA (Distance) Programs', Category__c = 'Admission', Late_Fees__c = 500, Session__c = 'January', Year__c = '2023');
        insert new Late_Fee__c(Name = 'Late Fees for Registration January 2023 slab 1', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(+120), nm_Type__c = 'MBA (Distance) Programs', Category__c = 'Registration', Late_Fees__c = 500, Session__c = 'January', Year__c = '2023');
        insert new Late_Fee__c(Name = 'Late Fees for Admission January 2023 slab 1', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(+120), nm_Type__c = 'MBA (Distance) Programs', Category__c = 'Admission', Late_Fees__c = 1000, Session__c = 'January', Year__c = '2023');
        insert new Late_Fee__c(Name = 'Late Fees for Registration January 2023 slab 1', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(+120), nm_Type__c = 'MBA (Distance) Programs', Category__c = 'Registration', Late_Fees__c = 1000, Session__c = 'January', Year__c = '2023');
        insert new Late_Fee__c(Name = 'Late Fees for Admission January 2023 slab 1', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(+120), nm_Type__c = 'MBA (Distance) Programs', Category__c = 'Admission', Late_Fees__c = 1500, Session__c = 'January', Year__c = '2023');
        insert new Late_Fee__c(Name = 'Late Fees for Registration January 2023 slab 1', Start_Date__c = Date.today().addDays(-10), End_Date__c = Date.today().addDays(+120), nm_Type__c = 'MBA (Distance) Programs', Category__c = 'Registration', Late_Fees__c = 1500, Session__c = 'January', Year__c = '2023');

        String st =' [{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"15/12/2021","newValue":"13/12/2021","label":"Application Start Date","name":"ApplicationStartDate"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"12/12/2023","newValue":"12/12/2024","label":"Application End Date","name":"ApplicationEndDate"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"10/04/2018, 11:45 am","newValue":"23/04/2018, 11:45 am","label":"Payment Start Date","name":"paymentStartDate"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"29/09/2023, 12:00 pm","newValue":"04/10/2023, 12:00 pm","label":"Payment End Date","name":"paymentEndDate"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"28/09/2023, 12:45 pm","newValue":"06/10/2023, 12:45 pm","label":"Loan Window End Date","name":"loanWindowEndDate"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"-","newValue":"22/05/2023","label":"Late Fee Start Date Slab 1","name":"LateFeeStartDateSlab1"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"-","newValue":"31/05/2023","label":"Late Fee End Date Slab 1","name":"LateFeeEndDateSlab1"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"-","newValue":"21/05/2023","label":"Late Fee Start Date Slab 2","name":"LateFeeStartDateSlab2"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"-","newValue":"07/06/2023","label":"Late Fee End Date Slab 2","name":"LateFeeEndDateSlab2"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"-","newValue":"21/05/2023","label":"Late Fee Start Date Slab 3","name":"LateFeeStartDateSlab3"},{"admissionCategory":"Admission","ApplicationEndDate":"12/12/2023","ApplicationStartDate":"15/12/2021","CalenderId":"'+objCal.Id+'","loanWindowEndDate":"28/09/2023, 12:45 pm","paymentConfigId":"'+objPayConf.Id+'","paymentEndDate":"29/09/2023, 12:00 pm","paymentStartDate":"10/04/2018, 11:45 am","programType":"MBA (Distance) Programs","semester":"1","session":"January","year":"2023","loanWindowStartDate":"10/04/2018, 11:45 am","LateFeeStartDateSlab1":"-","LateFeeStartDateSlab2":"-","LateFeeStartDateSlab3":"-","LateFeeEndDateSlab1":"-","LateFeeEndDateSlab2":"-","LateFeeEndDateSlab3":"-","paymentStartDateUTC":"2018-04-10T06:15:00.000Z","paymentEndDateUTC":"2023-09-29T06:30:00.000Z","loanWindowStartDateUTC":"2018-04-10T06:15:00.000Z","loanWindowEndDateUTC":"2023-09-28T07:15:00.000Z","ApplicationStartDateUTC":"2021-12-15T00:00:00.000Z","ApplicationEndDateUTC":"2023-12-12T00:00:00.000Z","LateFeeStartDateSlab1UTC":"","LateFeeStartDateSlab2UTC":"","LateFeeStartDateSlab3UTC":"","LateFeeEndDateSlab1UTC":"","LateFeeEndDateSlab2UTC":"","LateFeeEndDateSlab3UTC":"","key":4,"oldValue":"-","newValue":"07/06/2023","label":"Late Fee End Date Slab 3","name":"LateFeeEndDateSlab3"}]';
        Test.startTest();
        AEPMerchandiseController.getProgramDates();
        AEPMerchandiseController.saveChangedDated(st);
        Test.stopTest();
        
    }
    public Static PriceBook2 CreatePriceBook()
    {
        Pricebook2 priceBook = new Pricebook2(Name='NMIMS New Price Book', isActive=true , nmSession_Start_Date__c = System.today().addDays(-1), nmSession_End_Date__c = System.today().addDays(2) );
        insert priceBook;
        return priceBook;
    }

    @isTest
    static void testMethod4() {
       nm_Program__c program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.BookCChargeapplicable__c = true ;
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = 'Master of Business Administration in Human Resources';
       program.nm_ProgramValidity__c = 4.0;
       program.nm_TotalSemesters__c = 4.0;
       program.nm_Type__c = 'MBA (Online) Programs';
       program.prgst__c ='Jul2024';
       program.PVM__c = 48;
       program.Specialisation__c = 'MBA';          
       insert program; 

       NM_Payment_Form_Configuration__c objPayConf = new NM_Payment_Form_Configuration__c(Semester__c = '1', Program_Category__c = 'MBA (Online) Programs', Payment_Type__c = 'Admission', Current_Admission_Year__c = '2024', Session__c = 'January', Loan_Window_EndDate__c = Datetime.now().addYears(+3), Payment_Window_StartDate__c = Datetime.now().addYears(-3), Payment_Window_EndDate__c = Datetime.now().addYears(+3) );
       insert objPayConf;

       List<Cancelation_Date__c> lstCancel = new List<Cancelation_Date__c>();
       Cancelation_Date__c objCancel1 = new Cancelation_Date__c(Admission_Fee__c=true,Amount__c=2000.56,From_Date__c=Date.today(),To_Date__c=Date.today().addDays(5),NM_Payment_Form_Configuration__c=objPayConf.Id);
       lstCancel.add(objCancel1);
       insert lstCancel;

       List<Map<String,Object>> lstOfCancelationDates = new List<Map<String,Object>>();
       Map<String,Object> mapOfInputAndValues = new Map<String,Object> ();
       mapOfInputAndValues.put('From_Date__c', String.valueOf(Date.today()));
       mapOfInputAndValues.put('To_Date__c', String.valueOf(Date.today().addDays(5)));
       mapOfInputAndValues.put('Percentage__c', '60.76');
       mapOfInputAndValues.put('Amount__c', '500.89');
       mapOfInputAndValues.put('Admission_Fee__c', false);
       lstOfCancelationDates.add(mapOfInputAndValues);

       Test.startTest();
            AEPMerchandiseController.getProgramDetails();
            AEPMerchandiseController.getCancelDates(objPayConf.Id,'test');
            AEPMerchandiseController.saveCancelationDateRecord(lstOfCancelationDates,objPayConf.Id);
            AEPMerchandiseController.updateCancelationDateChanges(objCancel1.Id,mapOfInputAndValues);
            AEPMerchandiseController.deleteCancelationDateByRecordId(objCancel1.Id);
        Test.stopTest();
    }
}