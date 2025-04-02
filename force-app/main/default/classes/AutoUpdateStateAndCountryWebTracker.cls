/**
 * @File Name          : AutoUpdateStateAndCountryWebTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20-08-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    21/5/2020   shubhranshu     Initial Version
**/

@isTest(SeeAllData=false)
public class AutoUpdateStateAndCountryWebTracker {

    @testSetup
    public static void setUpData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes', false, 'Registered');
		objAccount.nm_StudentNo__c = '77216433684';
		objAccount.BillingPostalCode = '400071';
        objAccount.nm_PostalCode__c = '400071';

		update objAccount;

		Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');

		List<Case__c> lstTat = new List<Case__c>();
        Case__c objTAT = new Case__c();
        objTAT.Name = 'Admissions';
        objTAT.TAT__c = 3;
        lstTat.add(objTAT);

        Case__c objTAT2 = new Case__c();
        objTAT2.Name = 'Academics';
        objTAT2.TAT__c = 2;
        lstTat.add(objTAT2);
        
        Case__c objTAT3 = new Case__c();
        objTAT3.Name = 'Learner Support Center';
        objTAT3.TAT__c = 3;
        lstTat.add(objTAT3);
        insert lstTat;
    
		String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
        String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();

        List<Case> lstToInsert = new List<Case>();
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket, AccountId=objAccount.Id);
        lstToInsert.add(c1);
        Case c2 = new Case(Subject='Test', Status='Closed', Student_Purpose__c='Feedback', Tech_Issue__c='No', nm_Category__c='Admissions', sub_categories__c='Admission - Payment issue', Student_Category__c='Admissions', Student_No__c='77119958556', RecordTypeId=feedback, AccountId=objAccount.Id);
        lstToInsert.add(c2);
        Case c3 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=4, RecordTypeId=ticket, AccountId=objAccount.Id);
        lstToInsert.add(c3);
        insert lstToInsert;
    }

    @isTest
	static void myUnitTest1() {

        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new RestMock());

			AutoUpdateStateAndCountryWebService.getToken('777123456');
        Test.stopTest();

    }

    @isTest
	static void myUnitTest2() {
        Account objAccount = [select id, nm_PostalCode__c from Account limit 1];

        Test.startTest();
			Test.setMock(HttpCalloutMock.class, new RestMock());
			objAccount.nm_PostalCode__c = '400071';

			AutoUpdateStateAndCountryWebService.updateStateandCountyOnAccount(objAccount.id);
        Test.stopTest();

    }

    @isTest
	static void myUnitTest3() {
        Lead objLead = [select id, nm_Program__c, nm_EligiblityCriteria__c, PostalCode from Lead limit 1];
        Test.startTest();
			objLead.PostalCode = '400071';
			Test.setMock(HttpCalloutMock.class, new RestMock());

			AutoUpdateStateAndCountryWebService.updateStateandCountyOnLead(objLead.id);
        Test.stopTest();

    }

	@isTest
	static void myUnitTest4() {
        Case caseRecord = [select id,AccountId from Case WHERE AccountId != null limit 1 ];
        Test.startTest();
			AutoUpdateStateAndCountryWebService.getSapId(caseRecord.id);
			AutoUpdateStateAndCountryWebService.getSapId(caseRecord.AccountId);
        Test.stopTest();

    }

	private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"status": "OK", "results": [{"address_components": [{"long_name": "Mountain View", "types": ["locality"]}, {"long_name": "California", "types": ["administrative_area_level_1"]}, {"long_name": "United States", "types": ["country"]}], "formatted_address": "Mountain View, CA, USA"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

}