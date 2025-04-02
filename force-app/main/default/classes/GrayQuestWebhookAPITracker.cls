/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : @vickysahu
 **/
@isTest(SeeAllData = false)
public with sharing class GrayQuestWebhookAPITracker {
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
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
        objLead.EduVanz_lead_id__c = '71839';
        objLead.Loan_Order_Id__c = '07183977381';

        objLead.Loan_Type__c = 'GrayQuest';
        objLead.Loan_Amount__c = '30000';
        objLead.nm_Fee_Type__c = 'Admission';
        update objLead;
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No', false, 'Confirmed');
        objAccount.nm_StudentNo__c = '77214000950';
        update objAccount;
        objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won', '1', objAccount, 'PGAllSemFee');
        objOpp.EduVanz_lead_id__c = '71819';
        objOpp.Loan_Order_Id__c = '07181977381';
        objOpp.Loan_Type__c = 'GrayQuest';
        objOpp.Loan_Amount__c = '30000';
        update objOpp;

        NM_Payment_Form_Configuration__c paymentConfig = nmGenericTracker.createPaymentFOrmConfiguration('Master Programs', 'Admission', '1');
        paymentConfig.allow_tenure_for_zero_percent__c = '9,12,15';
        paymentConfig.Program_Type__c = 'MBA (WX)';
        update paymentConfig;
        // For master's program

        objLeadformaster = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
        objLeadformaster.EduVanz_lead_id__c = '71882';
        objLeadformaster.Loan_Order_Id__c = '07188277381';
        objLeadformaster.Loan_Type__c = 'GrayQuest';
        objLeadformaster.Loan_Amount__c = '360000';
        objLeadformaster.Tenure__c = '9';
        //objLeadformaster.nm_Fee_Type__c = 'MBAallTermfee';
        update objLeadformaster;

        objAccountformaster = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No', false, 'Confirmed');
        program = [SELECT Id, nm_Type__c from nm_Program__c where Id =: objAccountformaster.nm_Program__c LIMIT 1];
        if (program != null) {
            program.nm_Type__c = 'Master Programs';
            update program;
        }
        objAccountformaster.nm_StudentNo__c = '77214000952';
        update objAccountformaster;

        objOppforMaster = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won', '1', 'Master Programs', objAccountformaster, 'AnnualFee');
        objOppforMaster.EduVanz_lead_id__c = '71829';
        objOppforMaster.Loan_Type__c = 'GrayQuest';
        objOppforMaster.Loan_Amount__c = '360000';
        objOppforMaster.Tenure__c = '9';
        objOppforMaster.nm_Fee_Type__c = 'MBAallTermfee';
        update objOppforMaster;

        List<Tenure__c> lstTenures = new List<Tenure__c>{
            insertTenures('9', 'GrayQuest', 'Admission', 'Master Programs', 'MBA (WX)'),
            insertTenures('9', 'GrayQuest', null, 'Master Programs', 'MBA (WX)'),
            insertTenures('15', 'GrayQuest', 'MBAallTermfee', 'Master Programs', 'MBA (WX)')
        };
        
        insert lstTenures;
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at opportunity level
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus1() {
        Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.process.completed","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at opportunity level without loan id check
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus2() {
        Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07181977381","application_details":{"ID":null},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":100000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at opportunity level without amount check
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus3() {
        Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891"},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at opportunity level without status check
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus4() {
        Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at opportunity level without urn check
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus5() {
        Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","disbursed_amount":45000},"notes":{"loan_amount":100000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at opportunity level without checksum check
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus6() {
        Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":100000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for disbursed at opportunity level for master programs
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStausforMasters() {
        Opportunity op = [select Loan_Order_Id__c, Specialisation__c from Opportunity where EduVanz_lead_id__c = '71829'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"NDI3001","application_details":{"ID":71829},"fee_details":{"amount":560000,"tenure":18,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":100000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":100000},"notes":{"loan_amount":560000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for disbursed at opportunity level for other programs
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus7() {
        Opportunity op = [select Loan_Order_Id__c, Loan_Amount__c from Opportunity where EduVanz_lead_id__c = '71819'];
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":100000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description
    call GrayQuestWebhookAPI for disbursed at opportunity level for master programs without utr check
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    // @isTest
    // static void testTrackGrayQuestStauswithoutUtr() {
    //     Opportunity op = [select Loan_Order_Id__c from Opportunity where EduVanz_lead_id__c = '71829'];
    //     
    //     Test.startTest();
    //     String myJSON = '{"application_id": 7181977381,"customer_id": 20107,"fee_details": {"loan_amount": 560000},"plan_details": {"plan_id": 514,"interest_rate": 0,"no_of_emi": 18,"processing_rate": 0,"emi_amount": 31111,"academic_year": "2021-2022"},"application_status": {"stage": "Disbursed","stage_slug": "loan-live"},"disbursement_details": [{"tranch_amount": 260400,"disbursal_date": "12-2-2021","reference_number": "9329DB","discount_percent": 1,"discount_amount": 720,"disbursed_amount": 71280,"retention_percent": 0,"retention_amount": 0}],"notes":{"master_application_id":""}}';
    //     RequestData(myJSON, 'POST');
    //     GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
    //     Test.stopTest();
    // }

    /**
    * @description call GrayQuestWebhookAPI for approved at lead level
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus8() {
        Lead ld = [select Loan_Order_Id__c, Program_Type__c from Lead where EduVanz_lead_id__c = '71839'];
       
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.process.completed","reference_id":"07183977381","application_details":{"ID":71839},"fee_details":{"amount":560000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for rejected at opportunity level for loan-execution
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus9() {
        Opportunity op = [select Loan_Order_Id__c, Loan_Amount__c from Opportunity where EduVanz_lead_id__c = '71819'];
        
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.rejected","reference_id":"07181977381","application_details":{"ID":71819},"fee_details":{"amount":560000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description
    call GrayQuestWebhookAPI for Loan Approved at lead level
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus10() {
        Lead ld = [select Loan_Order_Id__c, Program_Type__c from Lead where EduVanz_lead_id__c = '71839'];
       
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07183977381","application_details":{"ID":71839},"fee_details":{"amount":560000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for rejecetd at lead level
    * @author @BK | 13-11-2024 
    **/
    @isTest
    static void testTrackGrayQuestStaus11() {
        Lead ld = [select Loan_Order_Id__c, Program_Type__c from Lead where EduVanz_lead_id__c = '71839'];
       
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.rejected","reference_id":"07183977381","application_details":{"ID":71839},"fee_details":{"amount":560000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for disbursed at Lead level for master programs
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus12() {
        Lead ld = [select Loan_Order_Id__c, Program_Type__c from Lead where EduVanz_lead_id__c = '71882'];
       
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07188277381","application_details":{"ID":71882},"fee_details":{"amount":45000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":40000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        Test.stopTest();
    }

    /**
    * @description call GrayQuestWebhookAPI for approved at lead level for other programs
    * @author Suyog | 28/9/20
    * @return testMethod
    **/
    @isTest
    static void testTrackGrayQuestStaus13() {
        Lead ld = [select Loan_Order_Id__c, Program_Type__c from Lead where EduVanz_lead_id__c = '71839'];
        Test.startTest();
        String myJSON = '{"entity":"monthly-emi","event":"emi.disbursed","reference_id":"07183977381","application_details":{"ID":71839},"fee_details":{"amount":560000,"tenure":6,"interest_rate":0,"processing_rate":0,"discount_rate":3.5},"disbursement_details":{"amount":45000,"date":"04-05-2023","utr":"IFT23124061891","disbursed_amount":45000},"notes":{"loan_amount":45000}}';
        RequestData(myJSON, 'POST');
        GrayQuestWebhookAPI.TrackGrayQuestLoanStatus();
        GrayQuestWebhookAPI.createAdditionalPaymentRecord(1.00, ld.Id, 'Lead', 56000);
        Test.stopTest();
    }

    @isTest
    static void testTrackGrayQuestAdditionaPayment() {
        Test.startTest();
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        GrayQuestWebhookAPI.createAdditionalPaymentRecord(1.00, objOpp.id, 'Opportunity', 56000);
        Test.stopTest();
    }


    public static void RequestData(String myJson, String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url + 'services/apexrest/GrayQuestWebhookAPI/V1.1/';
        request.httpMethod = requestMethod;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }

    public static Tenure__c insertTenures(String Tenure, String LoanType, String FeeType, String ChooseProgram, String Type) {
        Tenure__c objTenures = new Tenure__c();
        objTenures.Tenure__c = Tenure;
        objTenures.Loan_Type__c = LoanType;
        objTenures.Fee_Type__c = FeeType;
        objTenures.Choose_Program__c = ChooseProgram;
        objTenures.IsActive__c = true;
        objTenures.Subvention_Value__c = 6.5;
        objTenures.Tranche_Payment__c = true;
        objTenures.Program_Type__c = Type;
        // insert objTenures;
        return objTenures;
    }
}