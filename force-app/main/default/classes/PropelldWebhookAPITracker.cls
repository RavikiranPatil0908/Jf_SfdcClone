/**
 * @File Name          : PropelldWebhookAPITracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 21-09-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    7/4/2020   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class PropelldWebhookAPITracker {

    public static Account objAccount;
    public static lead objLead;
    public static Opportunity objOpp;
    public static lead objLeadformaster;
    public static Account objAccountformaster;
    public static Opportunity objOppforMaster;
    public static nm_Program__c program;
    static String loanId = '';

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
        nmGenericTracker.CreateProduct('Live Lectures',1200);
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Loan_Order_Id__c ='07181977383';
        objLead.EduVanz_lead_id__c = '07181977383';
        objLead.Loan_Type__c ='Propelld';
        objLead.Loan_Amount__c = '30000';
        update objLead;
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccount.nm_StudentNo__c = '77214000953';
        update objAccount;
        objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        objOpp.Loan_Order_Id__c ='07181977381';
        objLead.EduVanz_lead_id__c = '07181977381';
        objOpp.Loan_Type__c = 'Propelld';
        objOpp.Loan_Amount__c = '30000';
        update objOpp;

        NM_Payment_Form_Configuration__c paymentConfig = nmGenericTracker.createPaymentFOrmConfiguration('Master Programs','Admission','1');
        paymentConfig.allow_tenure_for_zero_percent__c ='9,12,15';
        paymentConfig.Program_Type__c = 'MBA (WX)';
        update paymentConfig;
        // For master's program

        objLeadformaster = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
        objLeadformaster.Loan_Order_Id__c='07181977482';
        objLeadformaster.Loan_Type__c ='Propelld';
        objLeadformaster.Loan_Amount__c = '360000';
        objLeadformaster.Tenure__c = '12';
        objLeadformaster.EduVanz_lead_id__c = '07181977482';
        update objLeadformaster;
    
        objAccountformaster = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        program = [SELECT Id,nm_Type__c from nm_Program__c WHERE Id=:objAccountformaster.nm_Program__c LIMIT 1];
        if(program != null){
            program.nm_Type__c = 'Master Programs';
            program.Specialisation__c = 'MBA (WX)';
            update program;
        }
        objAccountformaster.nm_StudentNo__c = '77214000952';
        update objAccountformaster;

        objOppforMaster = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','Master Programs',objAccountformaster,'AnnualFee');
        objOppforMaster.Loan_Order_Id__c ='07181977382';
        objOppforMaster.Loan_Type__c = 'Propelld';
        objOppforMaster.Loan_Amount__c ='360000';
        objOppforMaster.Tenure__c = '12';
        objOppforMaster.EduVanz_lead_id__c = '07181977382';
        update objOppforMaster;

        // create loan for MBA(Distance) programs with interest rate 0%

        nm_Program__c objMbaDistanceProgram = nmGenericTracker.CreateProgram('MBA (Distance) Programs', 'MBA (Financial Management)', 4);

        nm_EligiblityCriteria__c  objEc = nmGenericTracker.CreateElegibilityCriteriaforMaster(objMbaDistanceProgram.nm_Type__c);

        Lead objLeadForMbaDistance = objLead.clone();
        objLeadForMbaDistance.nm_Program__c=objMbaDistanceProgram.id;
        objLeadForMbaDistance.nm_ChooseaProgram__c =objMbaDistanceProgram.nm_Type__c;
        objLeadForMbaDistance.nm_Fee_Type__c ='FullFee';
        objLeadForMbaDistance.Email = 'test121@test.com';
        objLeadForMbaDistance.MobilePhone = '8761459201';
        objLeadForMbaDistance.Loan_Order_Id__c ='07181979408';
        objLeadForMbaDistance.nm_EligiblityCriteria__c =objEc.Id;
        objLeadForMbaDistance.EduVanz_lead_id__c = '07181979408';
        objLeadForMbaDistance.Loan_Type__c ='Propelld';
        objLeadForMbaDistance.Loan_Amount__c = '100000';
        insert objLeadForMbaDistance;

        Lead objLeadForMbaDistance1 = objLead.clone();
        objLeadForMbaDistance1.nm_Program__c=objMbaDistanceProgram.id;
        objLeadForMbaDistance1.nm_ChooseaProgram__c =objMbaDistanceProgram.nm_Type__c;
        objLeadForMbaDistance1.nm_Fee_Type__c ='FullFee';
        objLeadForMbaDistance1.Email = 'test1212@test.com';
        objLeadForMbaDistance1.MobilePhone = '8761459281';
        objLeadForMbaDistance1.Loan_Order_Id__c ='07181979481';
        objLeadForMbaDistance1.nm_EligiblityCriteria__c =objEc.Id;
        objLeadForMbaDistance1.EduVanz_lead_id__c = '07181979481';
        objLeadForMbaDistance1.Loan_Type__c ='Propelld';
        objLeadForMbaDistance1.Loan_Amount__c = '100000';
        objLeadForMbaDistance1.LiveLecturesType__c = '1SemLecturesFee';
        insert objLeadForMbaDistance1;

        Account objAccountForMbaDistance = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccountForMbaDistance.nm_Program__c = objMbaDistanceProgram.id;
        objAccountForMbaDistance.nm_StudentNo__c = '77214000219';
        update objAccountForMbaDistance;

        // Opportunity objOppForMbaDistance = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','MBA (Distance) Programs',objAccountForMbaDistance,'FullFee');
        Opportunity objOppForMbaDistance = objOpp.clone();
        objOppForMbaDistance.AccountId = objAccountForMbaDistance.id; 
        objOppForMbaDistance.nm_Fee_Type__c = 'FullFee'; 
        objOppForMbaDistance.LiveLecturesType__c = 'No';
        objOppForMbaDistance.nm_Program__c = objMbaDistanceProgram.id;
        objOppForMbaDistance.Loan_Order_Id__c ='07181979408';
        objOppForMbaDistance.EduVanz_lead_id__c = '07181979408';
        objOppForMbaDistance.Tenure__c = '9';
        objOppForMbaDistance.Loan_Type__c = 'Propelld';
        objOppForMbaDistance.Loan_Amount__c = '100000';
        insert objOppForMbaDistance;

        NM_Payment_Form_Configuration__c paymentConfigForMbaDistance = nmGenericTracker.createPaymentFOrmConfiguration('MBA (Distance) Programs','Admission','1');
        paymentConfigForMbaDistance.allow_tenure_for_zero_percent__c ='3,6,9,12';
        update paymentConfigForMbaDistance;

        Tenure__c objTenure = new Tenure__c();
        objTenure.Subvention_Value__c = 6.50;
        objTenure.Choose_Program__c = 'MBA (Distance) Programs';
        objTenure.Fee_Type__c = 'FullFee';
        objTenure.Interest_Rate__c = 0;
        objTenure.IsActive__c = true;
        objTenure.Loan_Type__c = 'Propelld';
        objTenure.Tenure__c = '9';
        insert objTenure;

    }

    @isTest
    static void testTrackPropelldStausError(){
        Test.startTest();    
            String myJSON = '{"Event":"application.loan.disbursed","Entities":["Application","Borrowers","Loan","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"","Status":"DISBURSED","CourseId":510,"CourseName":"Diploma/Certification Course","Notes":null,"ReferenceNumber":"07181977383"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]},"Loan":{"LoanAmount":80000,"AppliedLoanAmount":80000 ,"TotalTenor":15,"MoratoriumPeriod":0,"DiscountedCourseFee":86000},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":20000,"DisbursementDate":"2020-01-31","DisbursementReference":"AXISCN0037824784"}]},"CreatedOn":"2020-04-09 05:45:52"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    // For Lead level

    @isTest
    static void testTrackPropelldStausApproved(){
        Test.startTest();    
            String myJSON = '{"Code":0,"Message":"SUCCESS","Errors":[{"Location":"body","Param":"FirstName","Msg":"FirstName should be present","Code":1,"Message":"Failed Creation"}],"Event":"application.loan.disbursed","Entities":["Application","Loan","Borrowers","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181977383","Status":"APPROVED","CourseId":541,"CourseName":"Artificial Intelligence","Notes":null,"ReferenceNumber":"07181977383"},"Loan":{"LoanAmount":50000,"AppliedLoanAmount":50000,"TotalTenor":12,"MoratoriumPeriod":6,"DiscountedCourseFee":65000},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999999","Email":"john.doe@test.com"}]},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":50000,"DisbursementDate":"2019-08-20","DisbursementReference":"AIASDO311144141"}]},"CreatedOn":"2019-08-06 18:00:00"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldStausRejected(){
        Test.startTest();    
            String myJSON = '{"Event":"application.status.change","Entities":["Application","Borrowers"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181977383","Status":"REJECTED","CourseId":510,"CourseName":"Diploma/Certification Course","Notes":null,"ReferenceNumber":"07181977383"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]}},"CreatedOn":"2020-04-09 05:42:14"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldStausDisbursed(){
        Test.startTest();    
            String myJSON = '{"Event":"application.loan.disbursed","Entities":["Application","Borrowers","Loan","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181977383","Status":"DISBURSED","CourseId":510,"CourseName":"Diploma/Certification Course","Notes":null,"ReferenceNumber":"07181977383"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]},"Loan":{"LoanAmount":80000,"AppliedLoanAmount":80000 ,"TotalTenor":15,"MoratoriumPeriod":0,"DiscountedCourseFee":86000},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":20000,"DisbursementDate":"2020-01-31","DisbursementReference":"AXISCN0037824784"}]},"CreatedOn":"2020-04-09 05:45:52"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    // for account level

    @isTest
    static void testTrackPropelldStausApproved1(){
        Test.startTest();    
            String myJSON = '{"Code":0,"Message":"SUCCESS","Errors":[{"Location":"body","Param":"FirstName","Msg":"FirstName should be present","Code":1,"Message":"Failed Creation"}],"Event":"application.loan.disbursed","Entities":["Application","Loan","Borrowers","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181977382","Status":"APPROVED","CourseId":541,"CourseName":"Artificial Intelligence","Notes":null,"ReferenceNumber":"07181977382"},"Loan":{"LoanAmount":50000,"AppliedLoanAmount":50000,"TotalTenor":12,"MoratoriumPeriod":6,"DiscountedCourseFee":65000},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999999","Email":"john.doe@test.com"}]},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":50000,"DisbursementDate":"2019-08-20","DisbursementReference":"AIASDO311144141"}]},"CreatedOn":"2019-08-06 18:00:00"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldStausRejected1(){
        Test.startTest();    
            String myJSON = '{"Event":"application.status.change","Entities":["Application","Borrowers"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181977382","Status":"REJECTED","CourseId":510,"CourseName":"Diploma/Certification Course","Notes":null,"ReferenceNumber":"07181977382"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]}},"CreatedOn":"2020-04-09 05:42:14"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
            
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldStausDisbursed1(){
        Test.startTest();    
            String myJSON = '{"Event":"application.loan.disbursed","Entities":["Application","Borrowers","Loan","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181977382","Status":"DISBURSED","CourseId":510,"CourseName":"Diploma/Certification Course","Notes":null,"ReferenceNumber":"07181977382"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]},"Loan":{"LoanAmount":80000,"AppliedLoanAmount":80000 ,"TotalTenor":15,"MoratoriumPeriod":0,"DiscountedCourseFee":86000},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":20000,"DisbursementDate":"2020-01-31","DisbursementReference":"AXISCN0037824784"}]},"CreatedOn":"2020-04-09 05:45:52"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldError(){
        Test.startTest();    
            String myJSON = '{"QuoteId": "5bc56066-0444-44c0-96a9-0963ada2b864","Approved": false}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
            String myString = 'StringToBlob';
            Blob myBlob = Blob.valueof(myString);
            PropelldWebhookAPI.verifyCheckSum(myBlob,'test');
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldStausDisbursedForMBADistance(){
        Test.startTest();    
            String myJSON = '{"Event":"application.loan.disbursed","Entities":["Application","Borrowers","Loan","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181979408","Status":"DISBURSED","CourseName":"MBA (Distance) Programs","Notes":null,"ReferenceNumber":"07181979408"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]},"Loan":{"LoanAmount":80000,"AppliedLoanAmount":80000 ,"TotalTenor":9,"MoratoriumPeriod":0,"DiscountedCourseFee":86000},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":20000,"DisbursementDate":"2020-01-31","DisbursementReference":"AXISCN0037824784"}]},"CreatedOn":"2020-04-09 05:45:52"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldStausDisbursedForMBADistance2(){
        Test.startTest();    
            String myJSON = '{"Event":"application.loan.disbursed","Entities":["Application","Borrowers","Loan","Disbursement"],"Payload":{"Application":{"ApplicationId":666,"QuoteId":"07181979481","Status":"DISBURSED","CourseName":"MBA (Distance) Programs","Notes":null,"ReferenceNumber":"07181979481"},"Borrowers":{"Applicant":{"Name":"Jane Doe","Mobile":"9999999999","Email":"jane.doe@test.com"},"CoApplicants":[{"Name":"John Doe","Mobile":"9999999998","Email":"john.doe@test.com"}]},"Loan":{"LoanAmount":80000,"AppliedLoanAmount":80000 ,"TotalTenor":9,"MoratoriumPeriod":0,"DiscountedCourseFee":86000},"Disbursement":[{"TranchNumber":1,"DisbursementAmount":20000,"DisbursementDate":"2020-01-31","DisbursementReference":"AXISCN0037824784"}]},"CreatedOn":"2020-04-09 05:45:52"}';
            RequestData(myJSON,'POST',generatedCheckSum(myJSON));
            PropelldWebhookAPI.TrackPropelldStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackPropelldAdditionaPayment(){
        Test.startTest();
            Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
            PropelldWebhookAPI.createAdditionalPaymentRecord(objOpp.id,'Opportunity',1.00);
        Test.stopTest();
    }

    public static String generatedCheckSum(String salt){
        Blob data = crypto.generateMac('HmacSHA256', Blob.valueOf(salt), Blob.valueOf(System.Label.Propelld_Api_Key));
        String generatedCheckSum = EncodingUtil.convertToHex(data);
        return generatedCheckSum;
    }

    public static void RequestData(String myJson,String requestMethod,String signature) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/PropelldWebhookAPI/V1.1/';
        request.addHeader('X-Propelld-Signature', signature);
        request.httpMethod = requestMethod;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }
}