/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-30-2021
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class ArchiveLinkForDocumentsTracker {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{}');
            response.setStatusCode(200);
            return response; 
        }
    }

    @testSetup
    public static void setUpData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2021;
        objCal.Session_End_Date__c = system.today()+1;
        insert objCal;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_Year__c = 2021;
        update objLead;

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c =system.today();
        objAccount.Pass_Out__c = true;
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        objopp.CourseList__c = '120,110,109,108';
        update objopp;
    }
    
    @isTest
    static void unitTest1() {
        Test.startTest();
        RestMock rest = new RestMock();
            Test.setMock(HttpCalloutMock.class, rest);           
            ArchiveLinkForDocuments instance = new ArchiveLinkForDocuments();
            Database.executeBatch(instance,50);
        Test.stopTest();
    }
}