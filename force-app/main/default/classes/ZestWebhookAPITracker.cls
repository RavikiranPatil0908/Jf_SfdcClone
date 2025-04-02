/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class ZestWebhookAPITracker {
    
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
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Loan_Order_Id__c ='07181977383';
        objLead.EduVanz_lead_id__c = '07181977383';
        objLead.Loan_Type__c ='Zest';
        objLead.Loan_Amount__c = '30000';
        update objLead;
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccount.nm_StudentNo__c = '77214000953';
        update objAccount;
        objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        objOpp.Loan_Order_Id__c ='07181977381';
        objLead.EduVanz_lead_id__c = '07181977381';
        objOpp.Loan_Type__c = 'Zest';
        objOpp.Loan_Amount__c = '30000';
        update objOpp;

        NM_Payment_Form_Configuration__c paymentConfig = nmGenericTracker.createPaymentFOrmConfiguration('Master Programs','Admission','1');
        paymentConfig.allow_tenure_for_zero_percent__c ='9,12,15';
        paymentConfig.Program_Type__c = 'MBA (WX)';
        update paymentConfig;
        // For master's program

        objLeadformaster = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
        objLeadformaster.Loan_Order_Id__c='07181977482';
        objLeadformaster.Loan_Type__c ='Zest';
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
        objOppforMaster.Loan_Type__c = 'Zest';
        objOppforMaster.Loan_Amount__c ='360000';
        objOppforMaster.Tenure__c = '12';
        objOppforMaster.EduVanz_lead_id__c = '07181977382';
        update objOppforMaster;

        ZestMoneyAPI__c cs = new ZestMoneyAPI__c();
        cs.Name='test';
        cs.ZestToMerchant__c = 'test';
        insert cs;
    }

    @isTest
    static void testTrackZestStausError(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78769","zestTransactionId":"","zestLoanId":"07181977383","basketAmount":55000,"loanAmount":0,"tenure":0,"processingFee":0,"downpaymentAmount":0,"utr":"AXISCN0070280788","status":"Settled","settlementAmount":70534.57,"settledOnDate":"2021-02-24T11:48:11Z","key":"b2532b261f102ea4ca8b911f5d5b304e841583376b6dbdc4c1a063ee9399f9161b7562f32d33b6b84fa747ee92f5a33ad2c7bc2e53ad81617fc2c4dfd771750b"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar9@sabre.com","mobileNumber":"917783985582"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    // For Lead level

    @isTest
    static void testTrackZestStausApproved(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78770","zestTransactionId":"07181977382","ZestLoanId":"07181977382","basketAmount":55000,"loanAmount":49500,"tenure":3,"downpaymentAmount":5500,"status":"Approved","key":"64e9a844efa211cad61c49678b4e787161da1df2661a5b764e2055a85f5bb667695c3864552e7bb3ee028f5b6a0575e09e1ac1c57875e2c95b3a47c477584611"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar11@sabre.com","mobileNumber":"917783985585"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackZestStausApproved2(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78770","zestTransactionId":"07181977383","ZestLoanId":"07181977383","basketAmount":55000,"loanAmount":49500,"tenure":3,"downpaymentAmount":5500,"status":"Approved","key":"64e9a844efa211cad61c49678b4e787161da1df2661a5b764e2055a85f5bb667695c3864552e7bb3ee028f5b6a0575e09e1ac1c57875e2c95b3a47c477584611"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar11@sabre.com","mobileNumber":"917783985585"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackZestStausRejected(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78764","zestTransactionId":"07181977383","ZestLoanId":"07181977383","basketAmount":55000,"loanAmount":55000,"tenure":3,"downpaymentAmount":0,"status":"Declined","key":"3b80b57c9dfad4f25eef52a7ec531b23beb3f5bd683353f748742efcbdbf7d4b0f7ba5b081f15efd22a9c701bfca121f7d4bf07c290319d2a1a9c163ed378fed"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar8@sabre.com","mobileNumber":"917783985581"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackZestStausDisbursed(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78769","zestTransactionId":"07181977383","zestLoanId":"07181977383","basketAmount":55000,"loanAmount":0,"tenure":0,"processingFee":0,"downpaymentAmount":0,"utr":"AXISCN0070280788","status":"Settled","settlementAmount":70534.57,"settledOnDate":"2021-02-24T11:48:11Z","key":"b2532b261f102ea4ca8b911f5d5b304e841583376b6dbdc4c1a063ee9399f9161b7562f32d33b6b84fa747ee92f5a33ad2c7bc2e53ad81617fc2c4dfd771750b"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar9@sabre.com","mobileNumber":"917783985582"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    // for account level

    @isTest
    static void testTrackZestStausApproved1(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78769","zestTransactionId":"07181977383","ZestLoanId":"07181977383","basketAmount":55000,"loanAmount":0,"tenure":0,"downpaymentAmount":0,"status":"Cancelled","key":"b2532b261f102ea4ca8b911f5d5b304e841583376b6dbdc4c1a063ee9399f9161b7562f32d33b6b84fa747ee92f5a33ad2c7bc2e53ad81617fc2c4dfd771750b"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar9@sabre.com","mobileNumber":"917783985582"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    @isTest
    static void testTrackZestStausRejected1(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78764","zestTransactionId":"07181977382","ZestLoanId":"07181977382","basketAmount":55000,"loanAmount":55000,"tenure":3,"downpaymentAmount":0,"status":"Declined","key":"3b80b57c9dfad4f25eef52a7ec531b23beb3f5bd683353f748742efcbdbf7d4b0f7ba5b081f15efd22a9c701bfca121f7d4bf07c290319d2a1a9c163ed378fed"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar11@sabre.com","mobileNumber":"917783985585"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
            
        Test.stopTest();
    }

    @isTest
    static void testTrackZestStausDisbursed1(){
        Test.startTest();    
            String myJSON = '{"eventType":"StatusChange","payload":{"transaction":{"partnerTransactionId":"2021HB78769","zestTransactionId":"07181977382","ZestLoanId":"07181977382","basketAmount":55000,"loanAmount":0,"tenure":0,"downpaymentAmount":0,"utr":"AXISCN0070280788","status":"Settled","settlementAmount":70534.57,"settledOnDate":"2021-02-24T11:48:11Z","key":"b2532b261f102ea4ca8b911f5d5b304e841583376b6dbdc4c1a063ee9399f9161b7562f32d33b6b84fa747ee92f5a33ad2c7bc2e53ad81617fc2c4dfd771750b"},"customer":{"name":"MANOJ KUMAR N","email":"1manoj5.kumar11@sabre.com","mobileNumber":"917783985585"}}}';
            RequestData(myJSON,'POST');
            ZestWebhookAPI.TrackZestStaus();
        Test.stopTest();
    }

    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/ZestWebhookAPI/V1.1/';
        request.httpMethod = requestMethod;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }
}