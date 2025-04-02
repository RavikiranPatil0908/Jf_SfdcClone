/**
 * @File Name          : PostPaymentControllerTest.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 02-08-2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    6/20/2019, 11:54:45 AM   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class PostPaymentControllerTest {

    public static String LeadId='';
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"LogonUrl" :"https://staging-app.zestmoney.in/?LoanApplicationId=e9229f74-dbe5-4884-88d9-61ec1f8a9f5f&merchantid=93863917-d9c6-4e71-8bd4-1b0b3a41caec&basketamount=76000&returnurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&approvedurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&downpaymentamount=6200","access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlB1dnJEaTloWU1ucVlUSzQxb3gyYlNDbjlKbyIsImtpZCI6IlB1dnJEaTloWU1ucVlUSzQxb3gyYlNDbjlKbyJ9.eyJpc3MiOiJodHRwczovL2FwcC56ZXN0bW9uZXkuaW4iLCJhdWQiOiJodHRwczovL2FwcC56ZXN0bW9uZXkuaW4vcmVzb3VyY2VzIiwiZXhwIjoxNjQyNTc5NTE4LCJuYmYiOjE2NDI1NzU5MTgsImNsaWVudF9pZCI6IjkzNWM1NzZlLTIzM2YtNGI5My04N2E2LTU1N2Q2ZmZhYzVjNSIsImNsaWVudF9NZXJjaGFudElkIjoiOTM1YzU3NmUtMjMzZi00YjkzLTg3YTYtNTU3ZDZmZmFjNWM1Iiwic2NvcGUiOiJtZXJjaGFudF9hcGlfc2Vuc2l0aXZlIn0.iUALKB8urvpkb21T64T-vHbWKkmkq2NrqsLdfXJmkkp-uHLkaCONvqFAvPWd4j3caAWtJ94JjJtmH-XTPkh8O42G2h1fjG1D1ekscOXqIHqXSnBhng5GOpSivTXP4_Z8YUqR_29KX6XdrW83q9MK-OGMAQQucclQcX1wz7Y8m5BJCFKDIbBNEPv0gehr3IB5T35Qxo24qr6HHiLvvhuZo2MqrHP7uDEzvs66U2MW_Et5jR0w7JBW9nAP9hlxWMkgdBohFaw-ZY8XV4ce3lSUl-zYjen_R4UN6cMYrR7LErE3dzdNbN7x7HTYXR_LzGE9wtcjFBlWlcz_HhogDgO2SA","expires_in":3600,"token_type":"Bearer"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
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

    private class AvanseLoan implements HttpCalloutMock {
        AvanseLoan() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status":true,"information":{"code":"201","message":"Created successfully"},"data":{"application_no":"AVUPSKLNG388141","application_status":"In-Progress","link":"https://avansedev.kelltontech.net/create-user?ct=rKpFoHRrahTNPkX9ul10lnWcyqdZCLNcRP/N2/+cMaLQKjv3D/JZDzQtCHeyIgzr1rzipLpz26RKUImYtvD4rNT0cMioTgSN+NvArJpDOPEvuAdEDHj9Y7X+AICHC+rK79daItR5hP1tOiQ8L8p0fYNTB+Pa2qQTQqbw7r8t0s0=&iv=604f3e5a83e31e01f7a86b333179e6f5&s=b43ec8869bc350ca","applicant_data":{"loan_amount":20000,"discount":"9000","down_payment_value":10000}}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class AvanseProgramList implements HttpCalloutMock {
        AvanseProgramList() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status":true,"information":{"code":"200","message":"Data fetch successfully"},"data":[{"course_code":"UNKT0941","course_name":"Post Graduate Diploma in Business Management","course_fees":300000,"description":"NMIMS NMIMS","course_duration":12,"partner_name":"NMIMS"},{"course_code":"UNKT0942","course_name":"test course 1","course_fees":150000,"description":"NMIMS NMIMS","course_duration":12,"partner_name":"NMIMS"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class AvanseCancelLoan implements HttpCalloutMock {
        AvanseCancelLoan() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status":true,"information":{"code":"204","message":"Resource updated successfully"},"data":[]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_Centers__c objCenter1 = [SELECT Id FROM nm_Centers__c WHERE Id=:objLead.nm_InformationCenter__c LIMIT 1];
        objCenter1.Avanse_API_Code__c = '12234';
        update objCenter1;

        objLead.nm_RegistrationNo__c = '01773733828';
        update objLead;
        LeadId = objLead.id;
        System.debug('lead id-->'+LeadId);
        lstPaymentToInsert.add(createPaymentRecords(objLead.id,'Registration','Lead','Registration'));
        lstPaymentToInsert.add(createPaymentRecords(objLead.id,'Zest-DownPayment','Lead','DownPayment-Admission'));
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;
        
        nm_Centers__c objCenter = [SELECT Id FROM nm_Centers__c WHERE Id=:objAccount.nm_Centers__c LIMIT 1];
        objCenter.Avanse_API_Code__c = '12233';
        update objCenter;
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        lstPaymentToInsert.add(createPaymentRecords(objopp.id,'Zest-DownPayment','Opportunity','DownPayment-Admission'));
        objOpp.Loan_Type__c = 'Propelld';
        // objOpp.LiveLecturesType__c= '1SemLecturesFee';
        objOpp.Loan_Order_Id__c = '0';
        objOpp.Loan_Application_Cancelled__c = false;
        objOpp.Interest_Rate__c = '0.84';
        update objOpp;
        Career_Service_Program__c objCareerProgram = insertCSRecords(objOpp.Id,objAccount.Id);
        
        // Formconfigurations
        insertConfigs();
        //custom setting
        saveSystemCustomSettings();

        nm_Payment__c objPayment2 = new nm_Payment__c () ;
        objPayment2.nm_PaymentType__c = 'Career Service';
        objPayment2.CareerServiceProgram__c = objCareerProgram.id;
        objPayment2.nm_Merchant_Track_Id__c  = '1234';
        objPayment2.Online_Response_Error__c ='465477';
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_ActualPaymentAmmount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Made';
      
        lstPaymentToInsert.add(objPayment2);
        insert lstPaymentToInsert;

        // Insert Products and PriceBook Entries
        List<Map<String, String>> productDataList = new List<Map<String, String>>{
            new Map<String, String>{'productName' => 'Semester', 'semester' => '1', 'program' => objLead.nm_Program__c},
            new Map<String, String>{'productName' => 'Semester', 'semester' => '1', 'program' => objOpp.nm_Program__c},
            new Map<String, String>{'productName' => 'Semester', 'semester' => '2', 'program' => objLead.nm_Program__c},
            new Map<String, String>{'productName' => 'Semester', 'semester' => '2', 'program' => objOpp.nm_Program__c},
            new Map<String, String>{'productName' => 'Annual', 'semester' => null, 'program' => null},
            new Map<String, String>{'productName' => 'Live Lectures', 'semester' => null, 'program' => null}
        };
        
        Id priceBook2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        List<PriceBookEntry> priceBookEntries = createProductsAndPricebookEntries(productDataList, priceBook2Id);

        nmGenericTracker.CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
        nmGenericTracker.CreateElegibilityCriteria();
        nmGenericTracker.CreateCalender();
        nmGenericTracker.createLateFeeRecord('Is Lateral','Certificate Programs');

    }
    
    @isTest 
    static void leadPaymentTest(){
        
        Lead objLead = [select id,nm_Program__c,nm_RegistrationNo__c,nm_DateOfBirth__c ,nm_EligiblityCriteria__c ,
        nm_Program__r.Loan_API_Code__c,nm_InformationCenter__r.Loan_API_Code__c,nm_InformationCenter__r.nm_LearningCenter__r.Loan_API_Code__c from Lead limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_Lead__c!=null limit 1];
        //NM_Payment_Form_Configuration__c nmpay = [SELECT Id ,Name from NM_Payment_Form_Configuration__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            objLead.nm_Year__c = 2018;
            objLead.Loan_Type__c = 'Zest';
            //objLead.nm_DateOfBirth__c= date.newInstance(1991, 12, 9);
            update objLead;

            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.GetPaymentDetails();           
            obj.QueryLeadData();
            obj.createZestLoanApplicationRequest('Lead',null,objLead.nm_RegistrationNo__c);
            obj.EduVanzLoanApplicationRequest();
            obj.liquiLoansApplicationRequest();
            obj.cancelLoanApplication();
            obj.showDocuments();
            // obj.liquiLoansApplicationRequest();
        Test.stopTest();
    }

    @isTest 
    static void oppPaymentTest(){
        Account objAccount = [select id,nm_LeadId__c,Father_Name__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            objopp.nm_Year__c = 2018;
            objopp.Loan_Type__c = 'Zest';
            objopp.Tenure__c = '6';
            
            update objopp;
        
            EduVanzAPI__c eduvanz=new EduVanzAPI__c();
            eduvanz.name='Loan Application Data';
            eduvanz.Redirect_URL__c='https://www.google.com/';
            insert eduvanz;
            
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.paymentType ='EMI';
            obj.TagPriceBookId =null;
            obj.GetPaymentDetails();   
            obj.QueryOpportunityData();
            obj.downloadPaymentReceipt();
            obj.cancelLoanApplication();
            obj.createZestLoanApplicationRequest('Account',objAccount,objAccount.nm_StudentNo__c );
            Test.setMock(HttpCalloutMock.class, new RestMock());
            obj.ZestLoanApplicationRequest();
            // obj.propelldApplicationReqest();
            obj.EduVanzLoanApplicationRequest();
            obj.liquiLoansApplicationRequest();
            // obj.liquiLoansApplicationRequest();
            obj.QueryValidityExtension();
            obj.ProductPricing('AnnualFee',2,'Annual');
        Test.stopTest();
    }

    @isTest 
    static void opprtuPaymentTest2(){
      
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        objAccount.nm_StudentNo__c ='77116975114';
        update objAccount;
        Career_Service_Program__c  objCareerProgram =[select id ,CareerServiceProgram__c ,Student_Number_Of_Account__c,CS_Program_Record_Id__c from Career_Service_Program__c   limit 1 ];
        Map<String,String> mapOfParametersToPass = new Map<String,String>{
              'message'=>'dgfd',
              'sapid'=>objCareerProgram.Student_Number_Of_Account__c,
              'packageId'=>objCareerProgram.CareerServiceProgram__c,
              'status'=>'Payment made',
              'paymentTrackId'=>'8799735',
              'paymentInitializationId'=>objCareerProgram .CS_Program_Record_Id__c
          };
        
        nm_Payment__c objpayment2 = [select id ,nm_Merchant_Track_Id__c,Online_Response_Error__c ,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where CareerServiceProgram__c!=null limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment2.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.paymentType ='EMI';
            obj.TagPriceBookId =null;
            obj.downloadPaymentReceipt();
            obj.ValidateStudentNo();
            obj.logout();
            obj.IsDefence=False;
            obj.getTotalProductAmount();
            obj.QueryCareerServiceData();
            obj.CareerServiceRedirect();
            //obj.createZestLoanApplicationRequest('Account',objAccount,objAccount.nm_StudentNo__c );
            //obj.ZestLoanApplicationRequest();
            // obj.EduVanzLoanApplicationRequest();
            //obj.ProductPricing('AnnualFee',2,'Annual');
          
            // obj.QueryValidityExtension();
        Test.stopTest();
    }

    @isTest
    static void leadEduVanzTest() {
        Lead ld = [select id,Loan_Type__c,Tenure__c,nm_Year__c from Lead  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_Lead__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        ld.nm_Year__c = 2020;
        ld.Loan_Type__c = 'EduVanz';
        ld.Interest_Rate__c = '0.0';
        ld.Tenure__c = '12';
        update ld;
        objpayment.nm_Lead__c = ld.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='EduVanz-DownPayment';
        update objpayment;

        Test.startTest();
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.EduVanzLoanApplicationRequest();
        Test.stopTest();
    }

    @istest
    static void opportunityCancelAdmission() {
        Opportunity objopp = [select id,Loan_Type__c,Loan_Order_Id__c,Loan_Application_Cancelled__c,AccountId from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c!=null and nm_PaymentType__c='Zest-DownPayment' limit 1];
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        update objpayment;
        objopp.Loan_Type__c = 'Zest';
        update objopp;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.cancelLoanApplication();
        Test.stopTest();
    }

    @istest
    static void opportunityCancelAdmissionLiqioloans() {
        Opportunity objopp = [select id,Loan_Type__c,Loan_Order_Id__c,Loan_Application_Cancelled__c,AccountId from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c!=null and nm_PaymentType__c='Zest-DownPayment' limit 1];
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        update objpayment;
        objopp.Loan_Type__c = 'liquiLoans';
        update objopp;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.cancelLoanApplication();
        Test.stopTest();
    }

    @istest
    static void opportunityCancelAdmissionCF() {
        Opportunity objopp = [select id,Loan_Type__c,Loan_Order_Id__c,Loan_Application_Cancelled__c,AccountId from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c!=null and nm_PaymentType__c='Zest-DownPayment' limit 1];
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        update objpayment;
        objopp.Loan_Type__c = 'Capital Float';
        update objopp;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.cancelLoanApplication();
        Test.stopTest();
    }

    @istest
    static void opportunityCancelAdmissionEduvanz() {
        Opportunity objopp = [select id,Loan_Type__c,Loan_Order_Id__c,Loan_Application_Cancelled__c,AccountId from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c!=null and nm_PaymentType__c='Zest-DownPayment' limit 1];
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        update objpayment;
        objopp.Loan_Type__c = 'Eduvanz';
        update objopp;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.cancelLoanApplication();
        Test.stopTest();
    }

    @isTest
    static void propelldRedirect() {
        Test.startTest();
            try {
                Account objAccount = [select id,nm_LeadId__c,nm_Tagged_Pricebook__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
                BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
                nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
                Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c from Opportunity  limit 1];
                nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
                Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
                ProductHelper productHelper = new ProductHelper();
                // Map<String,Map<String,PriceBookEntry>> mapPricebookIdVsPriceBook = productHelper.getMapOfPriceBookIdProductVsPriceBookEntry();
                Map<String,PriceBookEntry> mapPricebook = productHelper.getMapOfProductVsPriceBookEntry(objAccount.nm_Tagged_Pricebook__c);
                PriceBookEntry entryP = mapPricebook.get('Late Fee');
                mapPricebook.put('PG_All_Sem',entryP);
                mapPricebook.put('MSAllSemFee',entryP );
                mapPricebook.put('Registration Fee',entryP );
                mapPricebook.put('Live Lectures',entryP );
                System.debug('mapPricebooktest--->'+mapPricebook);
                objopp.nm_Year__c = 2018;
                objopp.Loan_Type__c = 'Propelld';
                objopp.Tenure__c = '6';
                objopp.LiveLecturesType__c= '1SemLecturesFee';
                update objopp;
                objpayment.nm_OpportunityNew__c = objopp.id;
                objpayment.nm_Merchant_Track_Id__c = '11111111111';
                objpayment.nm_PaymentType__c='Propelld-DownPayment';
                update objpayment;
                
                Test.setMock(HttpCalloutMock.class, new RestMockII());
                ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
                PostPaymentController obj = new PostPaymentController();
                obj.propelldApplicationReqest();
                
            } catch (Exception error) {
                System.debug('Debug ==>'+error.getMessage());
                System.debug('Debug Line Number ==>'+error.getLineNumber());
            }
        Test.stopTest();
    }
     
    @isTest
    static void EzCredLoanTest() {
        
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'EzCred';
        objopp.LiveLecturesType__c= '2SemLecturesFee';
        objopp.Tenure__c = '6';
        update objopp;
        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='EzCred-DownPayment';
        update objpayment;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockEzcred());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.ezcredApplicationReqest();
        Test.stopTest();
    }

    @isTest
    static void EzCredLoanTest1() {
        
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c,Zest_Loan_Application_Request__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_OpportunityNew__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'EzCred';
        objopp.LiveLecturesType__c= '3SemLecturesFee';
        objopp.Tenure__c = '6';
        objopp.Zest_Loan_Application_Request__c='https://www.google.com/';
        update objopp;
        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='EzCred-DownPayment';
        update objpayment;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockEzcred());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.ezcredApplicationReqest();
        Test.stopTest();
    }
    
    @isTest
    static void EzCredLoanTest2() {
        
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c,Loan_Application_Cancelled__c,Loan_Application_Cancellations_Count__c,Down_Payment_Made__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_OpportunityNew__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'EzCred';
        objopp.LiveLecturesType__c= '4SemLecturesFee';
        objopp.Tenure__c = '6';
        objopp.Loan_Application_Cancelled__c = true;
        objopp.Loan_Application_Cancellations_Count__c =1;
        objopp.Down_Payment_Made__c = true;
        update objopp;
        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='EzCred-DownPayment';
        update objpayment;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockEzcred());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.ezcredApplicationReqest();
        Test.stopTest();
    }

    @isTest
    static void EzCredLoanTest3() {
        
        Lead ld = [select id,Loan_Type__c,Tenure__c,nm_Year__c from Lead  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_Lead__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        ld.nm_Year__c = 2020;
        ld.Loan_Type__c = 'EzCred';
        ld.Tenure__c = '6';
        update ld;
        objpayment.nm_Lead__c = ld.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='EzCred-DownPayment';
        update objpayment;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockEzcred());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.ezcredApplicationReqest();
        Test.stopTest();
    }

    @isTest
    static void LiquiloansLoanapplicationTest() {
        
        Lead ld = [select id,Loan_Type__c,Tenure__c,nm_Year__c from Lead  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_Lead__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        ld.nm_Year__c = 2020;
        ld.Loan_Type__c = 'liquiLoans';
        ld.Interest_Rate__c = '0.0';
        ld.Tenure__c = '12';
        update ld;
        objpayment.nm_Lead__c = ld.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='Liquiloan-DownPayment';
        update objpayment;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockEzcred());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.liquiLoansApplicationRequest();
        Test.stopTest();
    }

    @isTest
    static void LiquiloansLoanapplicationTest2() {
        
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c,Loan_Application_Cancelled__c,Loan_Application_Cancellations_Count__c,Down_Payment_Made__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_Lead__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'liquiLoans';
        objopp.Interest_Rate__c = '0.0';
        objopp.Tenure__c = '12';
        update objopp;
        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='Liquiloan-DownPayment';
        update objpayment;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockEzcred());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.liquiLoansApplicationRequest();
        Test.stopTest();
    }

    
    @isTest
    static void grayQuestLoanTestOpportunity() {
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,Zest_Loan_Application_Request__c,AccountId,Tenure__c,nm_Year__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        // Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'GrayQuest';
        objopp.Tenure__c = '6';
        objopp.Zest_Loan_Application_Request__c ='www.dsfs.com';
        update objopp;
        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='GrayQuest-DownPayment';
        update objpayment;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockGrayQuest());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.zestLaonApplicationRequest = null;
            obj.GrayQuestRequest();
        Test.stopTest();
    }

    @isTest
    static void grayQuestLoanTestLead() {
        Lead objLead = [SELECT id FROM Lead LIMIT 1];
        nm_Payment__c objpayment = [SELECT id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE nm_Lead__c!=null AND nm_Installment_Payment_Ref__c='DownPayment-Admission' LIMIT 1];
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='GrayQuest-DownPayment';
        update objpayment;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockGrayQuest());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.zestLaonApplicationRequest = null;
            obj.LeadId = objLead.id;
            obj.interestRate = '0.84';
            obj.tenure = '12';
            obj.GrayQuestRequest();
        Test.stopTest();
    }

    @isTest
    static void grayQuestLoanTestLead2() {
        Lead objLead = [SELECT id FROM Lead LIMIT 1];
        nm_Payment__c objpayment = [SELECT id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE nm_Lead__c!=null AND nm_Installment_Payment_Ref__c='DownPayment-Admission' LIMIT 1];
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='GrayQuest-DownPayment';
        update objpayment;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockGrayQuest());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.zestLaonApplicationRequest = null;
            obj.LeadId = objLead.id;
            obj.interestRate = '7.70';
            obj.tenure = '12';
            obj.GrayQuestRequest();
        Test.stopTest();
    }

    @isTest
    static void grayQuestLoanTestReOpen() {
        Opportunity objopp = [SELECT id,Loan_Type__c,Zest_Loan_Application_Request__c,AccountId,Tenure__c,nm_Year__c FROM Opportunity LIMIT 1];
        nm_Payment__c objpayment = [SELECT id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE nm_OpportunityNew__c!=null LIMIT 1];
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'GrayQuest';
        objopp.Tenure__c = '6';
        objopp.Zest_Loan_Application_Request__c ='www.dsfs.com';
        update objopp;

        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='GrayQuest-DownPayment';
        update objpayment;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockGrayQuest());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.zestLaonApplicationRequest = 'www.google.com';
            obj.GrayQuestRequest();
        Test.stopTest();
    }

    @isTest
    static void grayQuestLoanTestReApply() {
        Opportunity objopp = [SELECT id,Loan_Type__c,Zest_Loan_Application_Request__c,AccountId,Tenure__c,nm_Year__c,Loan_Application_Cancelled__c,Down_Payment_Made__c,Loan_Application_Cancellations_Count__c FROM Opportunity LIMIT 1];
        nm_Payment__c objpayment = [SELECT id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE nm_OpportunityNew__c!=null LIMIT 1];
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'GrayQuest';
        objopp.Tenure__c = '6';
        objopp.Zest_Loan_Application_Request__c ='www.dsfs.com';
        objopp.Loan_Application_Cancelled__c = true;
        objopp.Down_Payment_Made__c = true;
        objopp.Loan_Application_Cancellations_Count__c = 2;
        update objopp;

        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='GrayQuest-DownPayment';
        update objpayment;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockGrayQuest());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.GrayQuestRequest();
        Test.stopTest();
    }

    @isTest
    static void AvanseLoanLeadTest() {
        
        Lead ld = [select id,Loan_Type__c,Tenure__c,nm_Year__c from Lead  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_Lead__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        ld.nm_Year__c = 2020;
        ld.Loan_Type__c = 'Avanse';
        ld.Interest_Rate__c = '0.0';
        ld.Tenure__c = '12';
        update ld;
        objpayment.nm_Lead__c = ld.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='Avanse-DownPayment';
        update objpayment;

        Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new AvanseLoan());
            Test.setMock(HttpCalloutMock.class, new AvanseProgramList());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.avanseApplicationReqest();
        Test.stopTest();
    }

    @isTest
    static void AvanseLoanAccountTest() {
        
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
        BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
        nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
        Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c,nm_Program__r.nm_ProgramName__c from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        objopp.nm_Year__c = 2020;
        objopp.Loan_Type__c = 'Avanse';
        objopp.LiveLecturesType__c= '2SemLecturesFee';
        objopp.Tenure__c = '6';
        update objopp;
        objpayment.nm_OpportunityNew__c = objopp.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='Avanse-DownPayment';
        update objpayment;

        Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new AvanseLoan());
            Test.setMock(HttpCalloutMock.class, new AvanseProgramList());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.avanseApplicationReqest();
        Test.stopTest();
    }

    @istest
    static void leadCancelAdmissionavanse() {
        Lead ld = [select id,Loan_Type__c,Tenure__c,nm_Year__c from Lead  limit 1];
        nm_Payment__c objpayment = [select id,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c from nm_Payment__c where nm_OpportunityNew__c!=null and nm_PaymentType__c='Zest-DownPayment' limit 1];
        objpayment.nm_Lead__c = ld.id;
        objpayment.nm_Merchant_Track_Id__c = '11111111111';
        objpayment.nm_PaymentType__c='Avanse-DownPayment';
        update objpayment;
        ld.Loan_Type__c = 'Avanse';
        update ld;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AvanseCancelLoan());
            ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
            PostPaymentController obj = new PostPaymentController();
            obj.cancelLoanApplication();
        Test.stopTest();
    }

    // @isTest
    // static void AvanseLoanAccountTest2() {
        
    //     Account objAccount = [select id,nm_LeadId__c,PersonEmail,FirstName,nm_StudentNo__c,LastName,BillingPostalCode,nm_HouseNumber__c,nm_LocalityName__c,
    //     BillingStreet,Billingstate,BillingCountry,PersonMobilePhone,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c, 
    //     nm_Program__r.Loan_API_Code__c,nm_Centers__r.Loan_API_Code__c,nm_Centers__r.nm_LearningCenter__r.Loan_API_Code__c from Account limit 1];
    //     Opportunity objopp = [select id,Loan_Type__c,AccountId,Tenure__c,nm_Year__c,nm_Program__r.nm_ProgramName__c from Opportunity  limit 1];
    //     nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
    //     Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
    //     objopp.nm_Year__c = 2020;
    //     objopp.Loan_Type__c = 'Avanse';
    //     objopp.LiveLecturesType__c= '2SemLecturesFee';
    //     objopp.Tenure__c = '6';
    //     objopp.Loan_Application_Cancelled__c = true;
    //     objopp.Loan_Application_Cancellations_Count__c = 2;
    //     update objopp;
    //     objpayment.nm_OpportunityNew__c = objopp.id;
    //     objpayment.nm_Merchant_Track_Id__c = '11111111111';
    //     objpayment.nm_PaymentType__c='Avanse-DownPayment';
    //     update objpayment;

    //     Test.startTest();
    //         Test.setMock(HttpCalloutMock.class, new AvanseProgramList());
    //         ApexPages.currentPage().getParameters().put('ResTrackId',objpayment.nm_Merchant_Track_Id__c);
    //         PostPaymentController obj = new PostPaymentController();
    //         obj.avanseApplicationReqest();
    //     Test.stopTest();
    // }

    public class RestMockGrayQuest implements HttpCalloutMock{
        public Integer statusCode;
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"success":true,"status_code":201,"message":"Application Created successfully","data":{"redirection_url":"https://rapid.graydev.tech/anand-ay?sbdc=e756c865-51ca-40f4-a9a0-cf5efcc951ef&uid=6e898686-59c0-434e-875f-558c82e869e8","refernce_id":"07202441936"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockEzcred implements HttpCalloutMock{
        public Integer statusCode;
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"lead_number":"1934","loan_link":"https://web.uat.ezcred.in:443/#/?leadId\u003d1934\u0026mobile\u003d9992000135\u0026entity\u003dcustomer","lead_link":"https://web.uat.ezcred.in:443/#/?leadId\u003d1934\u0026mobile\u003d9992000135\u0026entity\u003dcustomer","return_status":{"status":"SUCCESS"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    /**
    * @description 
    * @author @BK | 13-11-2024 
    * @param String programCategory 
    * @param String programType 
    * @param String semester 
    * @return NM_Payment_Form_Configuration__c 
    **/
    public static NM_Payment_Form_Configuration__c createPaymentFormConfiguration(String programCategory,String programType,String semester){
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
        objpaymentconfig.Payment_Window_EndDate__c = System.now().addDays(-1);
        objpaymentconfig.Initial_Admission_Payment__c = 1200;
        objpaymentconfig.Registration_Fee__c = 12000;
        objpaymentconfig.Is_Late_Fee_Applicable__c = true;
        objpaymentconfig.DownPayment_Amount__c = 5000;
        return objpaymentconfig;
    }

    /**
    * @description 
    * @author @BK | 13-11-2024 
    **/
    private static void insertConfigs() {
        List<NM_Payment_Form_Configuration__c> lstConfig = new List<NM_Payment_Form_Configuration__c>();
        lstConfig.add(createPaymentFormConfiguration('Certificate Programs','Admission','1')); //lead registration
        lstConfig.add(createPaymentFormConfiguration('Post Graduate Diploma Programs','Re-Registration','1'));//account reregistration
        NM_Payment_Form_Configuration__c objConfig = createPaymentFormConfiguration('Post Graduate Diploma Programs','Admission','1');
        lstConfig.add(objConfig);//account registration
        NM_Payment_Form_Configuration__c objConfig2 = objConfig.clone();
        objConfig2.Current_Admission_Year__c = '2020';
        objConfig2.Program_Category__c = 'Post Graduate Diploma Programs';
        objConfig2.Payment_Type__c = 'Admission';
        lstConfig.add(objConfig2);//account registration
        insert lstConfig;
    }

    /**
    * @description 
    * @author @BK | 13-11-2024 
    **/
    private static void saveSystemCustomSettings() {
        //custom setting
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
        objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
        objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
        insert objSystemConfiguration;

        // Zest Money
        ZestMoneyAPI__c objZest = new ZestMoneyAPI__c() ;
        objZest.Authentication_API__c='http://staging-auth.zestmoney.in/connect/token';
        objZest.Name = 'Loan Application Data';
        objZest.LoanApplications_API__c ='http://staging-app.zestmoney.in/ApplicationFlow/LoanApplications';
        insert objZest ;
        
        // Eduvanz
        EduVanzAPI__c eduvanz=new EduVanzAPI__c();
        eduvanz.name='Loan Application Data';
        eduvanz.Redirect_URL__c='https://www.google.com/';
        insert eduvanz;
        
        // Grayquest
        GrayQuestAPI__c grayquest = new GrayQuestAPI__c();
        grayquest.Name ='GrayQuestLoanData';
        grayquest.API_KEY__c ='fedasds';
        grayquest.Client_id__c ='tetsst'; 
        grayquest.Client_Secret__c='tetsst';
        grayquest.Grayquest_APILink__c='https://www.google.com/';
        grayquest.Redirect_URL__c='https://www.google.com/';
        grayquest.Slug__c = 'ngasce';
        insert grayquest;
        
        // LiquiLoans
        LiquiloansTenureSchemes__c liquiLoans = new LiquiloansTenureSchemes__c();
        liquiLoans.name='Tenure12withInt0.0';
        liquiLoans.Interest_rate__c = '0.0';
        liquiLoans.schemeId__c = '897';
        liquiLoans.Tenure__c = '12';
        insert liquiLoans;
    }

    /**
    * @description 
    * @author @BK | 13-11-2024 
    * @param List<Map<String String>> productDataList 
    * @param Id priceBook2Id 
    * @return List<PriceBookEntry> 
    **/
    private static List<PriceBookEntry> createProductsAndPricebookEntries(List<Map<String, String>> productDataList, Id priceBook2Id) {
        List<Product2> productsToInsert = new List<Product2>();
        List<PriceBookEntry> priceBookEntriesToInsert = new List<PriceBookEntry>();
        
        // Iterate over the list of data and create Product2 and PriceBookEntry objects
        for (Map<String, String> data : productDataList) {
            String productName = data.get('productName');
            String semester = data.get('semester');
            String program = data.get('program');
            
            // Create the Product2 record
            Product2 product = new Product2();
            product.Name = productName;
            product.nm_Program__c = String.isNotBlank(program) ? program : null;
            product.nm_Semester__c = String.isNotBlank(semester) ? semester : null;
            product.isActive = true;
            productsToInsert.add(product);
        }
        
        // Insert Product2 records in bulk
        insert productsToInsert;
        
        // Now that Product2 records are inserted, create corresponding PriceBookEntry records
        for (Product2 product : productsToInsert) {
            // Create PriceBookEntry records for the standard pricebook and the provided pricebook
            PriceBookEntry standardPriceBookEntry = new PriceBookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), 
                Product2Id = product.Id, 
                UnitPrice = 12000, 
                IsActive = true
            );
            PriceBookEntry objPriceBookEntry = new PriceBookEntry(
                Pricebook2Id = priceBook2Id, 
                Product2Id = product.Id, 
                UnitPrice = 12000, 
                IsActive = true
            );
            
            // Add PriceBookEntry records to the list
            priceBookEntriesToInsert.add(standardPriceBookEntry);
            priceBookEntriesToInsert.add(objPriceBookEntry);
        }
        
        // Insert PriceBookEntry records in bulk
        insert priceBookEntriesToInsert;

        // Return the created PriceBookEntry records if needed
        return priceBookEntriesToInsert;
    }

    /**
    * @description 
    * @author @BK | 13-11-2024 
    * @param Id oppId 
    * @param Id accountId 
    * @return Career_Service_Program__c 
    **/
    private static Career_Service_Program__c insertCSRecords(Id oppId, Id accountId) {
        Career_Service_Package__c CP = new Career_Service_Package__c();
        CP.Package_Name__c = 'Career Assistance';
        CP.Group_Name__c = 'Normal';
        insert CP; 
        
        Career_Service_Program__c objCareerProgram = new Career_Service_Program__c();
        objCareerProgram.Opportunity__c = oppId;
        objCareerProgram.Account__c= accountId;
        objCareerProgram.CareerServiceProgram__c = CP.id;
        objCareerProgram.successURL__c='http://10.100.100.94:8080/careerservices/paymentResponseSuccessMobile';
        objCareerProgram.failureURL__c='http://10.100.100.94:8080/careerservices/paymentResponseFailureMobile';
        insert objCareerProgram;
        return objCareerProgram;
    }

    /**
    * @description 
    * @author @BK | 13-11-2024 
    * @param String recordId 
    * @param String TypeOfPayment 
    * @param String SObjectAPIName 
    * @param String installmentRef 
    * @return nm_Payment__c 
    **/
    private static nm_Payment__c createPaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef){
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

}