/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : @vickysahu
**/

@isTest(SeeAllData=false)
public class AvanseWebhookAPITracker {

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
        objLead.Loan_Order_Id__c ='7181977383';
        objLead.EduVanz_lead_id__c = 'AVTESTP8686';
        objLead.Loan_Type__c ='Avanse';
        objLead.Loan_Amount__c = '30000';
        update objLead;
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccount.nm_StudentNo__c = '77774000953';
        update objAccount;
        objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        objOpp.Loan_Order_Id__c ='7181977381';
        objLead.EduVanz_lead_id__c = 'AVTESTP8687';
        objOpp.Loan_Type__c = 'Avanse';
        objOpp.Loan_Amount__c = '30000';
        update objOpp;

        NM_Payment_Form_Configuration__c paymentConfig = nmGenericTracker.createPaymentFOrmConfiguration('Master Programs','Admission','1');
        paymentConfig.allow_tenure_for_zero_percent__c ='9,12,15';
        paymentConfig.Program_Type__c = 'MBA (WX)';
        update paymentConfig;
        // For master's program

        objLeadformaster = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
        objLeadformaster.Loan_Order_Id__c='7181977482';
        objLeadformaster.Loan_Type__c ='Avanse';
        objLeadformaster.Loan_Amount__c = '360000';
        objLeadformaster.Tenure__c = '9';
        objLeadformaster.EduVanz_lead_id__c = 'AVTESTP8688';
        update objLeadformaster;
    
        objAccountformaster = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        program = [SELECT Id,nm_Type__c from nm_Program__c WHERE Id=:objAccountformaster.nm_Program__c LIMIT 1];
        if(program != null){
            program.nm_Type__c = 'Master Programs';
            program.Specialisation__c = 'MBA (WX)';
            update program;
        }
        objAccountformaster.nm_StudentNo__c = '77774000952';
        update objAccountformaster;

        objOppforMaster = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','Master Programs',objAccountformaster,'AnnualFee');
        objOppforMaster.Loan_Order_Id__c ='7181977382';
        objOppforMaster.Loan_Type__c = 'Avanse';
        objOppforMaster.Loan_Amount__c ='360000';
        objOppforMaster.Tenure__c = '9';
        objOppforMaster.EduVanz_lead_id__c = 'AVTESTP8688';
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
        objLeadForMbaDistance.Loan_Order_Id__c ='7181979408';
        objLeadForMbaDistance.nm_EligiblityCriteria__c =objEc.Id;
        objLeadForMbaDistance.EduVanz_lead_id__c = 'AVTESTP8689';
        objLeadForMbaDistance.Loan_Type__c ='Avanse';
        objLeadForMbaDistance.Loan_Amount__c = '100000';
		objLeadForMbaDistance.Tenure__c = '9';
        insert objLeadForMbaDistance;

        Lead objLeadForMbaDistance1 = objLead.clone();
        objLeadForMbaDistance1.nm_Program__c=objMbaDistanceProgram.id;
        objLeadForMbaDistance1.nm_ChooseaProgram__c =objMbaDistanceProgram.nm_Type__c;
        objLeadForMbaDistance1.nm_Fee_Type__c ='FullFee';
        objLeadForMbaDistance1.Email = 'test1212@test.com';
        objLeadForMbaDistance1.MobilePhone = '8761459281';
        objLeadForMbaDistance1.Loan_Order_Id__c ='7181979481';
        objLeadForMbaDistance1.nm_EligiblityCriteria__c =objEc.Id;
        objLeadForMbaDistance1.EduVanz_lead_id__c = 'AVTESTP8690';
        objLeadForMbaDistance1.Loan_Type__c ='Avanse';
        objLeadForMbaDistance1.Loan_Amount__c = '100000';
		objLeadForMbaDistance1.Tenure__c = '9';
        objLeadForMbaDistance1.LiveLecturesType__c = '1SemLecturesFee';

        insert objLeadForMbaDistance1;

        Account objAccountForMbaDistance = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccountForMbaDistance.nm_Program__c = objMbaDistanceProgram.id;
        objAccountForMbaDistance.nm_StudentNo__c = '77774000219';
        update objAccountForMbaDistance;

        // Opportunity objOppForMbaDistance = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','MBA (Distance) Programs',objAccountForMbaDistance,'FullFee');
        Opportunity objOppForMbaDistance = objOpp.clone();
        objOppForMbaDistance.AccountId = objAccountForMbaDistance.id; 
        objOppForMbaDistance.nm_Fee_Type__c = 'FullFee'; 
        objOppForMbaDistance.LiveLecturesType__c = 'No';
        objOppForMbaDistance.nm_Program__c = objMbaDistanceProgram.id;
        objOppForMbaDistance.Loan_Order_Id__c ='7181979408';
        objOppForMbaDistance.EduVanz_lead_id__c = 'AVTESTP8689';
        objOppForMbaDistance.Tenure__c = '9';
        objOppForMbaDistance.Loan_Type__c = 'Avanse';
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
        objTenure.Loan_Type__c = 'Avanse';
        objTenure.Tenure__c = '9';
        insert objTenure;

    }

    @isTest
    static void testTrackAvanseStausError(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"MUMDP00996457","disb_amount":49500,"kyc_details":[{"email":"Testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":100000,"utr_details":[],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"6 months No Cost","student_session":null,"admission_number":7181979408,"in_progress_timestamp":"2024-09-14 18:40:58","disbursement_timestamp":"2024-09-16T00:00:00","ops_approved_timestamp":"2024-09-16 10:44:49","ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-15 17:20:59","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-15 21:20:49","credit_under_approval_timestamp":"2024-09-14 19:03:52"},"status":"active","application_no":"","application_stage":"Pre-Disbursal","application_status":"Disbursed","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    // For Lead level

    @isTest
    static void testTrackAvanseStausApproved(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"DELDP00996029","disb_amount":30000,"kyc_details":[{"email":"testuser@gmail.com","status":"approval_pending","applicant_type":"APPLICANT"}],"loan_amount":30000,"utr_details":[],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"6 months No Cost","student_session":null,"admission_number":7181977383,"in_progress_timestamp":"2024-09-12 19:59:09","disbursement_timestamp":null,"ops_approved_timestamp":null,"ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-12 20:29:04","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-13 12:58:27","credit_under_approval_timestamp":"2024-09-12 20:29:04"},"status":"active","application_no":"AVTESTP8686","application_stage":"Payment details","application_status":"Ops Under Approval","application_sub_stage":"Payment details"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseStausRejected(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":6127,"roi":0,"fees":300000,"tenure":9,"adv_emi":6127,"lan_number":"DELDP00996029","disb_amount":30000,"kyc_details":[{"email":"Testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":30000,"utr_details":[],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"24 months No Cost","student_session":null,"admission_number":7181977383,"in_progress_timestamp":"2024-09-12 19:59:09","disbursement_timestamp":null,"ops_approved_timestamp":null,"ops_rejected_timestamp":"2024-09-13 14:44:50","credit_approved_timestamp":"2024-09-12 20:29:04","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-13 12:58:27","credit_under_approval_timestamp":"2024-09-12 20:29:04"},"status":"active","application_no":"AVTESTP8686","application_stage":"Pre-Disbursal","application_status":"Rejected","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseStausDisbursed(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"MUMDP00996457","disb_amount":30000,"kyc_details":[{"email":"Testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":30000,"utr_details": [{"utr_no":"AXISCN0744193575","utr_timestamp": "2024-09-14T17:52:07"}],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"6 months No Cost","student_session":null,"admission_number":7181977383,"in_progress_timestamp":"2024-09-14 18:40:58","disbursement_timestamp":"2024-09-16T00:00:00","ops_approved_timestamp":"2024-09-16 10:44:49","ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-15 17:20:59","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-15 21:20:49","credit_under_approval_timestamp":"2024-09-14 19:03:52"},"status":"active","application_no":"AVTESTP8686","application_stage":"Pre-Disbursal","application_status":"Disbursed","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    // for account level

    @isTest
    static void testTrackAvanseStausApproved1(){
        Test.startTest();    
			String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"DELDP00996029","disb_amount":360000,"kyc_details":[{"email":"testuser@gmail.com","status":"approval_pending","applicant_type":"APPLICANT"}],"loan_amount":360000,"utr_details":[],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"6 months No Cost","student_session":null,"admission_number":7181977382,"in_progress_timestamp":"2024-09-12 19:59:09","disbursement_timestamp":null,"ops_approved_timestamp":null,"ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-12 20:29:04","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-13 12:58:27","credit_under_approval_timestamp":"2024-09-12 20:29:04"},"status":"active","application_no":"AVTESTP8688","application_stage":"Payment details","application_status":"Ops Under Approval","application_sub_stage":"Payment details"}';
			RequestData(myJSON,'POST');
			AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseStausRejected1(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":6127,"roi":0,"fees":300000,"tenure":9,"adv_emi":6127,"lan_number":"DELDP00996029","disb_amount":360000,"kyc_details":[{"email":"Testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":360000,"utr_details":[],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"24 months No Cost","student_session":null,"admission_number":7181977382,"in_progress_timestamp":"2024-09-12 19:59:09","disbursement_timestamp":null,"ops_approved_timestamp":null,"ops_rejected_timestamp":"2024-09-13 14:44:50","credit_approved_timestamp":"2024-09-12 20:29:04","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-13 12:58:27","credit_under_approval_timestamp":"2024-09-12 20:29:04"},"status":"active","application_no":"AVTESTP8688","application_stage":"Pre-Disbursal","application_status":"Rejected","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseStausDisbursed1(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"MUMDP00996457","disb_amount":360000,"kyc_details":[{"email":"Testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":360000,"utr_details":[],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"12 months No Cost","student_session":null,"admission_number":7181977382,"in_progress_timestamp":"2024-09-14 18:40:58","disbursement_timestamp":"2024-09-16T00:00:00","ops_approved_timestamp":"2024-09-16 10:44:49","ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-15 17:20:59","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-15 21:20:49","credit_under_approval_timestamp":"2024-09-14 19:03:52"},"status":"active","application_no":"AVTESTP8688","application_stage":"Pre-Disbursal","application_status":"Disbursed","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseStausDisbursedForMBADistance(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"DELDP00996238","disb_amount":100000,"kyc_details":[{"email":"testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":100000,"utr_details":[{"utr_no":"AXISCN0744193573","utr_timestamp":"2024-09-14T17:52:07"}],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"18 months No Cost","student_session":null,"admission_number":7181979408,"in_progress_timestamp":"2024-09-13 17:54:34","disbursement_timestamp":"2024-09-14T00:00:00","ops_approved_timestamp":"2024-09-14 12:08:27","ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-13 18:15:25","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-13 19:37:25","credit_under_approval_timestamp":"2024-09-13 18:15:25"},"status":"active","application_no":"AVTESTP8689","application_stage":"Pre-Disbursal","application_status":"Disbursed","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseStausDisbursedForMBADistance2(){
        Test.startTest();    
            String myJSON = '{"data":{"emi":8666,"roi":0,"fees":300000,"tenure":9,"adv_emi":8666,"lan_number":"DELDP00996238","disb_amount":100000,"kyc_details":[{"email":"testuser@gmail.com","status":"approved","applicant_type":"APPLICANT"}],"loan_amount":100000,"utr_details":[{"utr_no":"AXISCN0744193570","utr_timestamp":"2024-09-14T17:52:07"}],"mode_of_course":null,"processing_fee":0,"subvention_fee":27843,"loan_plan_title":"9 months No Cost","student_session":null,"admission_number":7181979481,"in_progress_timestamp":"2024-09-13 17:54:34","disbursement_timestamp":"2024-09-14T00:00:00","ops_approved_timestamp":"2024-09-14 12:08:27","ops_rejected_timestamp":null,"credit_approved_timestamp":"2024-09-13 18:15:25","credit_rejected_timestamp":null,"partner_application_number":null,"ops_under_approval_timestamp":"2024-09-13 19:37:25","credit_under_approval_timestamp":"2024-09-13 18:15:25"},"status":"active","application_no":"AVTESTP8690","application_stage":"Pre-Disbursal","application_status":"Disbursed","application_sub_stage":"E-Sign Doc Status"}';
            RequestData(myJSON,'POST');
            AvanseWebhookAPI.trackAvanseLoansStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackAvanseAdditionaPayment(){
        Test.startTest();
            Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
            AvanseWebhookAPI.createAdditionalPaymentRecord(120000,objOpp.id,'Opportunity','1.00');
			Lead objLead = [SELECT id FROM Lead LIMIT 1];
			AvanseWebhookAPI.createAdditionalPaymentRecord(120000,objLead.id,'Lead','1.00');
        Test.stopTest();
    }

    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/AvanseWebhookAPI/V1/';
        request.httpMethod = requestMethod;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }
}