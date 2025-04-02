/**
 * @File Name          : EduvanzTrackLoanApplicationAPI_Tracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 30-04-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/10/2019, 12:58:23 PM   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class EduvanzTrackLoanApplicationAPI_Tracker{
    
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
        Test.startTest();
            generateDummyData();
        Test.stopTest();
    }
    
     // test method for 200 errorCode : Loan Application Data updated.
	 static testMethod void testTrackEduVanzLoanStaus1(){
        Opportunity op=[select Id,Loan_Order_Id__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();     
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "Documents Pending", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		EduvanzTrackLoanApplicationAPI.createAdditionalPaymentRecord(100,op.Id,'Opportunity','100');
		Test.stopTest();
	}

    // test method for 501 errorCode : meta data is missing..
    static testMethod void testTrackEduVanzLoanStaus2(){
        Opportunity op=[select Loan_Order_Id__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "Documents Pending" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
      
    // test method for 501 errorCode : Current stage name is missing.
    static testMethod void testTrackEduVanzLoanStaus3(){
        Opportunity op=[select Loan_Order_Id__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest(); 
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
    // test method for 501 errorCode :Current stage code is missing..
    static testMethod void testTrackEduVanzLoanStaus4(){
        Opportunity op=[select Loan_Order_Id__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "", "lead_id": "45454546", "current_stage_name": "Documents Pending", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}

    // test method for 501 errorCode :lead ID is missing..
    static testMethod void testTrackEduVanzLoanStaus5(){
        Opportunity op=[select Loan_Order_Id__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "", "current_stage_name": "Documents Pending", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}

    // test method for 500 errorCode : Meta data not matched.
	static testMethod void testTrackEduVanzLoanStaus6(){
		Test.startTest();     
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "Documents Pending", "meta_data": "0725444464" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}

	// test method for Disbursed stage at Opportunity level
	 static testMethod void testTrackEduVanzLoanStaus7(){
        Opportunity op=[select Loan_Order_Id__c,Specialisation__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Disbursed", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport" }] }';
		RequestData(myJSON,'POST');
		//EduvanzTrackLoanApplicationAPI.checkSubventionSchemePrograms(op.Specialisation__c);
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
	// test method for Approved
	static testMethod void testTrackEduVanzLoanStaus8(){
		Opportunity op=[select Loan_Order_Id__c,Specialisation__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Approved", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport","final_sanction_loan_amount":"5000","sanctioned_amount":"5000","IPA_status":"TEST","loan_tenure":"9" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}

	// test method for Rejected
	static testMethod void testTrackEduVanzLoanStaus9(){
		Opportunity op=[select Loan_Order_Id__c,Specialisation__c from Opportunity where Loan_Order_Id__c='07181977381'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Rejected", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport"}] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
	
	// For master's programs
	static testMethod void testTrackEduVanzLoanStausforMasters(){
		Opportunity op=[select Loan_Order_Id__c,Specialisation__c from Opportunity where Loan_Order_Id__c='07181977382'];
        loanId = op.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Disbursed", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"92000", "document_list":"aadhar card,pan card,passport","final_sanction_loan_amount":"5000","sanctioned_amount":"5000","IPA_status":"TEST","loan_tenure":"9" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
    // test method for 200 errorCode : Loan Application Data updated.
	static testMethod void testTrackEduVanzLoanStausAtLeadLevel1(){
        Lead ld=[select Loan_Order_Id__c from Lead where Loan_Order_Id__c='07181977382'];
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();     
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "Documents Pending", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
        
		Test.stopTest();
	}
    
    // test method for 501 errorCode : meta data is missing..
    static testMethod void testTrackEduVanzLoanStausAtLeadLevel2(){
       Lead ld=[select Loan_Order_Id__c from Lead where Loan_Order_Id__c='07181977382'];
        loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "Documents Pending"}] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
      
    // test method for 501 errorCode : Current stage name is missing.
    static testMethod void testTrackEduVanzLoanStausAtLeadLevel3(){
        Lead ld=[select Loan_Order_Id__c from Lead where Loan_Order_Id__c='07181977382'];
        loanId = ld.Loan_Order_Id__c;
		Test.startTest(); 
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
    // test method for 501 errorCode :Current stage code is missing..
    static testMethod void testTrackEduVanzLoanStausAtLeadLevel4(){
        Lead ld=[select Loan_Order_Id__c from Lead where Loan_Order_Id__c='07181977382'];
        ld.Loan_Order_Id__c = '07181977382000';
		update ld;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "", "lead_id": "45454546", "current_stage_name": "Documents Pending", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}

    // test method for 501 errorCode :Lead Id is missing..
    static testMethod void testTrackEduVanzLoanStausAtLeadLevel5(){
        Lead ld=[select Loan_Order_Id__c from Lead where Loan_Order_Id__c='07181977382'];
		ld.Loan_Order_Id__c = '07181977382000';
		update ld;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "", "current_stage_name": "Documents Pending", "meta_data": \"'+loanId+'\" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
		Test.stopTest();
	}
    // test method for 500 errorCode : Meta data not matched.
	static testMethod void testTrackEduVanzLoanStausAtLeadLevel6(){
		Test.startTest();     
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "45454546", "current_stage_name": "Documents Pending", "meta_data": "071285454" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();
        
		Test.stopTest();
	}

	// test method for Disbursed stage at Lead level
	static testMethod void testTrackEduVanzLoanStausAtLeadLevel7(){
        Lead ld=[select Loan_Order_Id__c,Program_Type__c from Lead where Loan_Order_Id__c='07181977382'];
        loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Disbursed", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport" }] }';
		RequestData(myJSON,'POST');
		// EduvanzTrackLoanApplicationAPI.checkSubventionSchemePrograms(ld.Program_Type__c);
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}

	// test method for Approved
	static testMethod void testTrackEduVanzLoanStausAtLeadLevel8(){
        Lead ld=[select Loan_Order_Id__c,Program_Type__c from Lead where Loan_Order_Id__c='07181977482'];
        loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Approved", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport","final_sanction_loan_amount":"5000","sanctioned_amount":"5000","IPA_status":"TEST","loan_tenure":"9" }] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}

	// For master's program
	static testMethod void testTrackEduVanzLoanStausAtLeadLevelforMasterProg(){
        Lead ld=[select Loan_Order_Id__c,Program_Type__c from Lead where Loan_Order_Id__c='07181977482'];
        loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Disbursed", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport" }] }';
		RequestData(myJSON,'POST');
		// EduvanzTrackLoanApplicationAPI.checkSubventionSchemePrograms(ld.Program_Type__c);
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}
	// test method for Rejected
	static testMethod void testTrackEduVanzLoanStausAtLeadLevel9(){
		Lead ld=[select Loan_Order_Id__c,EduVanz_lead_id__c,Program_Type__c from Lead where Loan_Order_Id__c='07181977382'];
		ld.EduVanz_lead_id__c = 'Edu54545485';
		ld.Loan_Order_Id__c = '07181977302';
		update ld;
		nm_Payment__c payment = [select Id,nm_PaymentType__c,nm_Installment_Payment_Ref__c,nm_Lead__r.EduVanz_lead_id__c FROM nm_Payment__c LIMIT 1];
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		String myJSON = '{ "els_response": [{ "current_stage_code": "ELS101", "lead_id": "Edu54545485", "current_stage_name": "Rejected", "meta_data": \"'+loanId+'\" , "URL_Post_approval_process":"https://eduvanz.com/sign", "UTRN_number":"EDU445645", "disbursal_amount":"100000", "tranch_amount":"25000", "document_list":"aadhar card,pan card,passport"}] }';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}
	//test method for 2nd Tranch
	static testMethod void testTrackEduVanzLoanForTranch1(){
		Test.startTest();
		String myJSON = '{"els_response": [{"lead_id": "33074","meta_data": "07181977381","application_id": "A22021500006","current_stage_code": "ELS302","current_stage_name": "Tranch Disbursed","tranch_number": "2","UTRN_number": "454646546","disbursal_amount": "50000","discount_rate": "0","final_sanction_loan_amount": "50000","tranch_amount": "5000","disbursal_date": "2022-02-25","roi_reducing": "1"}]}';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}
	static testMethod void testTrackEduVanzLoanForTranch2(){
		nm_Payment__c objPay = [SELECT Id FROM nm_Payment__c WHERE nm_PaymentType__c = 'Additional Charge' LIMIT 1];
		objPay.nm_Amount__c = 10000;
		update objPay;
		Test.startTest();
		String myJSON = '{"els_response": [{"lead_id": "33074","meta_data": "07181977381","application_id": "A22021500006","current_stage_code": "ELS302","current_stage_name": "Tranch Disbursed","tranch_number": "2","UTRN_number": "454646546","disbursal_amount": "50000","discount_rate": "0","final_sanction_loan_amount": "50000","tranch_amount": "5000","disbursal_date": "2022-02-25","roi_reducing": "1"}]}';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}
	static testMethod void testTrackEduVanzLoanForTranch3(){
		nm_Payment__c objPay = [SELECT Id FROM nm_Payment__c WHERE nm_PaymentType__c = 'Additional Charge' LIMIT 1];
		objPay.nm_PaymentType__c = 'Additional';
		update objPay;
		Test.startTest();
		String myJSON = '{"els_response": [{"lead_id": "33074","meta_data": "07181977381","application_id": "A22021500006","current_stage_code": "ELS302","current_stage_name": "Tranch Disbursed","tranch_number": "2","UTRN_number": "454646546","disbursal_amount": "50000","discount_rate": "0","final_sanction_loan_amount": "50000","tranch_amount": "5000","disbursal_date": "2022-02-25","roi_reducing": "1"}]}';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}
	static testMethod void testTrackEduVanzLoanForTranch4(){
		Test.startTest();
		String myJSON = '{"els_response": [{"lead_id": "33074","meta_data": "07181977381","application_id": "A22021500006","current_stage_code": "ELS302","current_stage_name": "Tranch Disbursed","tranch_number": "1","UTRN_number": "454646546","disbursal_amount": "50000","discount_rate": "0","final_sanction_loan_amount": "50000","tranch_amount": "5000","disbursal_date": "2022-02-25","roi_reducing": "1"}]}';
		RequestData(myJSON,'POST');
		EduvanzTrackLoanApplicationAPI.TrackEduVanzLoanStaus();

		Test.stopTest();
	}

	
	static testMethod void testTrackEduVanzLoanStausAtLeadLevel10(){
		Test.setMock(HttpCalloutMock.class, new RestMock());
		Lead ld=[select id,Loan_Order_Id__c,EduVanz_lead_id__c,Program_Type__c from Lead where Loan_Order_Id__c='07181977382'];
		ld.EduVanz_lead_id__c = 'Edu54545485';
		ld.Loan_Order_Id__c = '07181977302';
		update ld;
		loanId = ld.Loan_Order_Id__c;
		Test.startTest();
		EduvanzTrackLoanApplicationAPI.EducancelLoan('1234',loanId,ld.id,'Lead');
		Test.stopTest();
	}

	
    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/eduvanzTrackLoanApp/V1.1/';
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

	@future (callout=true)
    public static void generateDummyData() { 
		Test.setMock(HttpCalloutMock.class, new RestMock());
		nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Loan_Order_Id__c ='07181977382';
        objLead.Loan_Type__c ='EduVanz';
		objLead.nm_Fee_Type__c = 'Admission';
		update objLead;
		
		nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
		nm_Payment__c objpayment =  nmGenericTracker.CreatePaymentRecords(objLead.id,'EduVanz-DownPayment','Lead','DownPayment-Admission');
	
		objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
		objAccount.nm_StudentNo__c = '77214000953';
		update objAccount;
		objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        objOpp.Loan_Order_Id__c ='07181977381';
        objOpp.Loan_Type__c = 'EduVanz';
        update objOpp;

		nm_Payment__c waivedOff = objpayment.clone();
		waivedOff.nm_PaymentType__c = 'Additional Charge';
		waivedOff.nm_PaymentStatus__c = 'Waived Off';
		waivedOff.nm_Amount__c = 5000;
		waivedOff.nm_Lead__c = null;
		waivedOff.nm_OpportunityNew__c = objOpp.Id;
		insert waivedOff;

		NM_Payment_Form_Configuration__c paymentConfig = nmGenericTracker.createPaymentFOrmConfiguration('Master Programs','Admission','1');
		paymentConfig.allow_tenure_for_zero_percent__c ='9,12';
		paymentConfig.Program_Type__c = 'MBA (WX)';
		update paymentConfig;
		// For master's program

		objLeadformaster = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
		objLeadformaster.Loan_Order_Id__c='07181977482';
		objLeadformaster.Loan_Type__c ='EduVanz';
		objLeadformaster.Loan_Amount__c = '50000';
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
        objOppforMaster.Loan_Type__c = 'EduVanz';
		objOppforMaster.Loan_Amount__c ='50000';
		objOppforMaster.Tenure__c = '9';
        update objOppforMaster;
		insertTenures('9','EduVanz','Admission','Master Programs','MBA (WX)');
		insertTenures('9','EduVanz',null,'Master Programs','MBA (WX)');
		insertTenures('9','LiquiLoans','FullFee','MBA (Distance) Programs',null);
	}
}