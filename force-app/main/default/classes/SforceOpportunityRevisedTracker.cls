/**
 * @File Name          : SforceOpportunityRevisedTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-01-2025
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/19/2019   shubhranshu     Initial Version
**/
@isTest
public without sharing class SforceOpportunityRevisedTracker {

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
        nm_Program__c program = nmGenericTracker.CreatePGDiplomaProgram();
        nmGenericTracker.CreateICAndUser(nmGenericTracker.CreateCenter('Mumbai'));

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
        nm_StudentProgram__c objSP = nmGenericTracker.CreatePGStudentProgram(objAccount);

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');

    }
    
    public static testMethod void sforceOpportunityTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
       nm_Centers__c center = [select Id,SAP_vendor_code__c,SAP_Customer_Code__c,Password__c,Email__c from nm_Centers__c where recordtype__c='Information Center' limit 1];
       center.SAP_vendor_code__c = '121346';
       center.SAP_Customer_Code__c = '154456';
       center.Allow_for_SforceOpportunity__c = true;
       center.Password__c = 'test@1234';
       update center;
       Opportunity opp = [select Id,Name,Account.Name,Account.nm_StudentNo__c,Account.nm_StudentStatus__c,Account.nm_Centers__c, Is_Re_Registration_Payment__c ,nm_Semester__c, nm_Session__c , nm_Year__c, StageName, ChooseProgram__c from Opportunity limit 1];
       opp.Account.nm_Centers__c = center.Id;
       opp.Account.nm_StudentStatus__c = 'Confirmed';
       opp.Is_Re_Registration_Payment__c = true;
       update opp;
       Test.startTest();
       SforceOpportunityRevisedController.searchVendor(center.Email__c,center.Password__c);
       String searchFields = '{"studentNo": "'+opp.Account.nm_StudentNo__c+'","studentName": "'+opp.Account.Name+'","name": "'+opp.Name+'","semester": "'+opp.nm_Semester__c+'","session": "'+opp.nm_Session__c+'","year": "'+opp.nm_Year__c+'","oppStage":"'+opp.nm_Year__c+'","chooseProgram":"'+opp.ChooseProgram__c+'"}';
       SforceOpportunityRevisedController.getOpportunityList(1,25,10,searchFields,center.Id);
       SforceOpportunityRevisedController.getOpportunityCount(searchFields,center.Id);
       SforceOpportunityRevisedController.updateOpportunity(opp,opp.Id);
       SforceOpportunityRevisedController.getToken(opp.Account.nm_StudentNo__c);
       Test.stopTest();
    }
}