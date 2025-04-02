/**
 * @File Name          : liquiLoansWebhookAPITracker.cls
 * @Description        :
 * @Author             : shubhranshu
 * @Group              :
 * @Last Modified By   : @BK
 * @Last Modified On   : 21-09-2024
 * @Modification Log   :
 * Ver       Date            Author              Modification
 * 1.0    12/7/2019   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class liquiLoansWebhookAPITracker {
   
    public static Account objAccount;
    public static lead objLead;
    public static Opportunity objOpp;
    public static lead objLeadformaster;
    public static Account objAccountformaster;
    public static Opportunity objOppforMaster;
    public static nm_Program__c program;
    static String loanId='';

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
		objLead.Loan_Type__c ='LiquiLoans';
		objLead.Loan_Amount__c = '30000';
		objLead.nm_Fee_Type__c = 'Admission';
		update objLead;
		objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
		objAccount.nm_StudentNo__c = '77214000953';
		update objAccount;
		objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
		objOpp.Loan_Order_Id__c ='07181977381';
		objOpp.Loan_Type__c = 'LiquiLoans';
		objOpp.Loan_Amount__c = '30000';
		update objOpp;

		NM_Payment_Form_Configuration__c paymentConfig = nmGenericTracker.createPaymentFOrmConfiguration('Master Programs','Admission','1');
		paymentConfig.allow_tenure_for_zero_percent__c ='9,12';
		paymentConfig.Program_Type__c = 'MBA (WX)';

		update paymentConfig;
		// For master's program

		objLeadformaster = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
		objLeadformaster.Loan_Order_Id__c='07181977482';
		objLeadformaster.Loan_Type__c ='LiquiLoans';
		objLeadformaster.Loan_Amount__c = '360000';
		objLeadformaster.Tenure__c = '9';
		objLeadformaster.nm_Fee_Type__c = 'MBAallTermfee';
		update objLeadformaster;
	
		objAccountformaster = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
		program = [SELECT Id , nm_Type__c from nm_Program__c where Id =: objAccountformaster.nm_Program__c LIMIT 1];
		if(program != null){
			program.nm_Type__c = 'Master Programs';
			update program;
		}
		objAccountformaster.nm_StudentNo__c = '77214000952';
		update objAccountformaster;

		objOppforMaster = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed Won','1','Master Programs',objAccountformaster,'AnnualFee');
		objOppforMaster.Loan_Order_Id__c ='07181977382';
		objOppforMaster.Loan_Type__c = 'LiquiLoans';
		objOppforMaster.Loan_Amount__c ='360000';
		objOppforMaster.Tenure__c = '9';
		update objOppforMaster;

		insertTenures('9','LiquiLoans','Admission','Master Programs','MBA (WX)');
		insertTenures('9','LiquiLoans',null,'Master Programs','MBA (WX)');
		insertTenures('9','LiquiLoans','FullFee','MBA (Distance) Programs',null);
    }

    /**
    * @description
    call liquiloansWebhookApi for approved at opportunity level
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus1(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();    
		String myJSON = '{ "loan_id": "30054","amount": "60000","product_amount": "60000","status": "Approved","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 11:36:05","checksum": "c42c1800e8b8149da797c113aa1bfcac76a1dc90003c357edb72c79778e04046"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for approved at opportunity level without loan id check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus2(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "","amount": "60000","product_amount": "60000","status": "Approved","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 11:36:05","checksum": "c42c1800e8b8149da797c113aa1bfcac76a1dc90003c357edb72c79778e04046"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }
     
    /**
    * @description
    call liquiloansWebhookApi for approved at opportunity level without amount check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus3(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30054","amount": "", "product_amount": "","status": "Approved","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 11:36:05","checksum": "c42c1800e8b8149da797c113aa1bfcac76a1dc90003c357edb72c79778e04046"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for approved at opportunity level without status check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus4(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30054","amount": "60000","product_amount": "60000","status": "","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 11:36:05","checksum": "c42c1800e8b8149da797c113aa1bfcac76a1dc90003c357edb72c79778e04046"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for approved at opportunity level without urn check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus5(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c  from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30054","amount": "60000","product_amount": "60000","status": "Approved","urn": "","utr":"","timestamp": "2019-12-07 11:36:05","checksum": "c42c1800e8b8149da797c113aa1bfcac76a1dc90003c357edb72c79778e04046"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for approved at opportunity level without checksum check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus6(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30054","amount": "60000","product_amount": "60000","status": "Approved","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 11:36:05","checksum": ""}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for disbursed at opportunity level for master programs
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStausforMasters(){
		Opportunity op=[select Loan_Order_Id__c,Specialisation__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977382'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30055","amount": "360000","product_amount": "360000","status": "Disbursed","urn": \"'+loanId+'\","utr":"TXN0112125525","disbursed_amount":"334580","timestamp": "2019-12-07 12:50:12","checksum": "a629935479004461a6502e580651b5eb9f1df1447c3d768892ae9715f3ec4124"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for disbursed at opportunity level for other programs
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus7(){
		Opportunity op=[select Loan_Order_Id__c,Loan_Amount__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		insert new API_Request__c(Request__c = '{ "loan_id": 2630634, "amount": 176400, "app_code": "CL02630634", "product_amount": 151200, "status": "Rejected", "tenure": 15, "emi": 13242, "roi": 0, "urn": "'+op.Loan_Order_Id__c+'", "utr": null, "disbursed_amount": 0, "timestamp": "2023-04-05 16:04:39", "checksum": "e9047acac868f9153eeb4a0d09dedc7d398bbf054ed135d25b18eaaff5f44321", "down_payment": null, "is_part_disbursal": "No" }',
		Response__c = 'MessageWrapper:[message=Webhook API Data updated., responseCode=200]', Type_of_Request__c = 'LiquiLoans', API_Name__c = 'liquiLoansWebhookAPI', Opportunity__c = op.Id);
		insert new API_Request__c(Request__c = '{"timestamp":"2023-04-05 04:27:52","application_status":"N","application_id":"2630274","checksum":"c10b1a96857d59defe667ae25e0f881a7538ba25234520201cebb3fe159d7022","sid":"S001881"}',
		Response__c = 'MessageWrapper:[message=Webhook API Data updated., responseCode=200]', Type_of_Request__c = 'LiquiLoans', Success__c= true, API_Name__c = 'liquiLoansStatusUpdateAPI', Opportunity__c = op.Id);
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30054","amount": "60000","product_amount": "60000","status": "Disbursed","urn": \"'+loanId+'\","utr":"TXN0112125525","disbursed_amount":"58000","timestamp": "2019-12-07 12:25:54","checksum": "ab0bcf91c47dcbe890b9aacec991ce8e22221c6cb3dceb8954fae3b30536baf1"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		liquiLoansWebhookAPI.checkForLoanApprovedAfterCancelled(loanId, op.Id, 'Opportunity');
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for disbursed at opportunity level for master programs without utr check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStauswithoutUtr(){
		Opportunity op=[select Loan_Order_Id__c,nm_Year__c,nm_Session__c from Opportunity where Loan_Order_Id__c='07181977381'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = op.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(op.nm_Year__c);
		update paymentConfig;
		loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30054","amount": "60000","product_amount": "60000","status": "Disbursed","urn": \"'+loanId+'\","utr":"","disbursed_amount":"","timestamp": "2019-12-07 12:25:54","checksum": "ab0bcf91c47dcbe890b9aacec991ce8e22221c6cb3dceb8954fae3b30536baf1"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for approved at lead level
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStaus8(){
		Lead ld=[select Loan_Order_Id__c,Program_Type__c,nm_Year__c,nm_Session__c from Lead where Loan_Order_Id__c='07181977383'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = ld.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(ld.nm_Year__c);
		update paymentConfig;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30055","amount": "60000","product_amount": "60000","status": "Approved","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 01:19:13","checksum": "40ca4d25cdc3ba2474cdf56ac5e758c8568ea948068daec24958dad823642f1e"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for disbursed at opportunity level for master programs
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStausAtLeadLevelforMasterProg(){
		Lead ld=[select Loan_Order_Id__c,Program_Type__c,nm_Year__c,nm_Session__c from Lead where Loan_Order_Id__c='07181977482'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = ld.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(ld.nm_Year__c);
		update paymentConfig;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30056","amount": "360000","product_amount": "360000","status": "Disbursed","urn": \"'+loanId+'\","utr":"TXN0112125525","disbursed_amount":"344580","timestamp": "2019-12-07 01:51:31","checksum": "6ddf41699ed37ed5a3e8945af8b4dc9be634301991e078cfa494553f505a7563"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for disbursed at lead level for other programs without utr check
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStausAtLeadLevelforMasterProgwithoutUtr(){
		Lead ld=[select Loan_Order_Id__c,Program_Type__c,nm_Year__c,nm_Session__c from Lead where Loan_Order_Id__c='07181977482'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = ld.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(ld.nm_Year__c);
		update paymentConfig;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30056","amount": "360000","product_amount": "360000","status": "Disbursed","urn": \"'+loanId+'\","utr":"","timestamp": "2019-12-07 01:51:31","checksum": "6ddf41699ed37ed5a3e8945af8b4dc9be634301991e078cfa494553f505a7563"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		Test.stopTest();
    }

    /**
    * @description
    call liquiloansWebhookApi for disbursed at lead level for other programs
    * @author shubhranshu | 12/7/2019
    * @return testMethod
    **/
    static testMethod void testTrackLiquiLoanStausAtLeadLevelforMasterProgInvalidChecksum(){
		Lead ld=[select Loan_Order_Id__c,Program_Type__c,nm_Year__c,nm_Session__c from Lead where Loan_Order_Id__c='07181977482'];
		NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
		paymentConfig.Session__c = ld.nm_Session__c;
		paymentConfig.Current_Admission_Year__c = String.valueOf(ld.nm_Year__c);
		update paymentConfig;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "loan_id": "30056","amount": "360000","product_amount": "360000","status": "Disbursed","urn": \"'+loanId+'\","utr":"TXN0112125525","disbursed_amount":"344580","timestamp": "2019-12-07 01:51:31","checksum": "6ddf1699ed37ed5a3e8945af8b4dc9be634301991e078cfa494553f505a7563"}';
		RequestData(myJSON,'POST');
		liquiLoansWebhookAPI.TrackLiquiLoansStaus();
		liquiLoansWebhookAPI.createAdditionalPaymentRecord(1.00,ld.Id,'Lead','56000');
		Test.stopTest();
    }

    
    @isTest
    static void testTrackLiquiloansAdditionaPayment(){
        Test.startTest();
            Opportunity objOpp = [SELECT id,nm_Year__c,nm_Session__c FROM Opportunity LIMIT 1];
			NM_Payment_Form_Configuration__c paymentConfig = [SELECT id,Session__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c LIMIT 1];
			paymentConfig.Session__c = objOpp.nm_Session__c;
			paymentConfig.Current_Admission_Year__c = String.valueOf(objOpp.nm_Year__c);
			update paymentConfig;
            liquiLoansWebhookAPI.createAdditionalPaymentRecord(1.00,objOpp.id,'Opportunity','56000');
        Test.stopTest();
    }


    public static void RequestData(String myJson,String requestMethod) {
      RestResponse response = new RestResponse();
      RestRequest request = new RestRequest();
      request.requestURI = System.Label.Site_Url+'services/apexrest/liquiLoansWebhookAPI/V1.1/';
      request.httpMethod=requestMethod;
      request.requestBody = Blob.valueof(myJSON);
      RestContext.request = request;
      RestContext.response = response;
    }

    public static void insertTenures(String Tenure, String LoanType, String FeeType,String ChooseProgram,String Type) {
      Tenure__c objTenures = new Tenure__c();
      objTenures.Tenure__c = Tenure;
      objTenures.Loan_Type__c = LoanType;
      objTenures.Fee_Type__c = FeeType;
      objTenures.Choose_Program__c = ChooseProgram;
      objTenures.IsActive__c = true;
      objTenures.Subvention_Value__c = 6.5;
      objTenures.Tranche_Payment__c = true;
      objTenures.Program_Type__c = Type;
      insert objTenures;
    }
}