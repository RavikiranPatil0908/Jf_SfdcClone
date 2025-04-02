/**
 * @File Name          : EmailTemplateControllerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 16/3/2020, 3:55:52 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/3/2020   shubhranshu     Initial Version
**/
@isTest
public without sharing class EmailTemplateControllerTracker {
   
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
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        NM_Payment_Form_Configuration__c nmpay = nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');
        nmpay.Cancellation_from_date_1__c = '13/3/2020';
        nmpay.Cancellation_from_date_2__c = '14/3/2020';
        nmpay.Cancellation_from_date_3__c = '15/3/2020';
        nmpay.Cancellation_to_date_1__c = '19/3/2020';
        nmpay.Cancellation_to_date_2__c = '20/3/2020';
        nmpay.Cancellation_to_date_3__c = '21/3/2020';
        update nmpay;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',false);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'PGAllSemFee');
        objOpp.nm_Session__c = 'January';
        objOpp.nm_Year__c =2019;
        update objOpp;

    }

    static testMethod void testUpdateDocumentSubmittedStatusOnAccountAtApproved(){
    
        Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account limit 1];
        nm_LinksForDocuments__c nmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c where nm_DocumentName__c='Defence Document'];
        Map<Id,nm_LinksForDocuments__c> mapofDocs = new Map<Id,nm_LinksForDocuments__c>();
        mapofDocs.put(nmlinkDoc.id, nmlinkDoc);
        nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
        nmlinkDoc.nm_Status__c = 'Approved';
        update nmlinkDoc;
        List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
        lstofDocs.add(nmlinkDoc);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        EmailTemplateController obj = new EmailTemplateController();
        obj.getAccountId();
        obj.setAccountId(acc.Id);
        obj.getApprovalId();
        obj.setApprovalId(null);
        obj.getLstlinkDocs();
        List<nm_LinksForDocuments__c> lstlinkdocs = mapofDocs.values();
        obj.setLstlinkDocs(lstlinkdocs);
        obj.queryAllDocumnets();
        Test.stopTest();
    }

    static testMethod void testGetPaymentConfigCancellationDates(){
    
        Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account limit 1];
        Opportunity opp = [select Id,ChooseProgram__c, nm_Session__c , nm_Year__c, Specialisation__c from Opportunity LIMIT 1];
        NM_Payment_Form_Configuration__c nmpayConfog = [select Id ,Cancellation_from_date_1__c, Cancellation_from_date_2__c , Cancellation_from_date_3__c , Cancellation_to_date_1__c , Cancellation_to_date_2__c , Cancellation_to_date_3__c  from NM_Payment_Form_Configuration__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        EmailTemplateController obj = new EmailTemplateController();
        obj.getChooseProgram();
        obj.setChooseProgram(opp.ChooseProgram__c);
        obj.getSession();
        obj.setSession(opp.nm_Session__c);
        obj.getYear();
        obj.setYear(Integer.valueOf(opp.nm_Year__c));
        obj.getProgramType();
        obj.setProgramType(opp.Specialisation__c);
        obj.getMapofCancellationDates();
        Map<String,String> mapofcanceldatestest = new Map<String,String>();
        mapofcanceldatestest.put('Dates', '13/3/2020');
        obj.setMapofCancellationDates(mapofcanceldatestest);
        obj.getOpportunityId();
        obj.setOpportunityId(opp.Id);
        obj.getPaymentConfigCancellationDates();
        Test.stopTest();
    }


}