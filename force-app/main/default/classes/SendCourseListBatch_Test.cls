/**
 * @description       : 
 * @author            : Suyog
 * @group             : 
 * @last modified on  : 04-30-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-10-2021   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class SendCourseListBatch_Test {


    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"sapId": "11900900900","acadYear": "2021","acadMonth": "Jan","courseIds": [1111,2222],"status": "success","message": "Success."}');
            response.setStatusCode(200);
            return response; 
        }
    }

    private class RestMockII implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"sapId": "11900900900","acadYear": "2021","acadMonth": "Jan","courseIds": [1111,2222],"status": "error","message": "Error"}');
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
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        objopp.CourseList__c = '120,110,109,108';
        update objopp;
    }

    @isTest
    static void testPostCallout() {
        Test.startTest();
            RestMock rest = new RestMock();
            Test.setMock(HttpCalloutMock.class, rest);
            SendCourseListBatch instance = new SendCourseListBatch();
            Database.executeBatch(instance,50);
        Test.stopTest();
    }

    @isTest
    static void testPostCallout2() {
        Test.startTest();
            RestMockII rest = new RestMockII();
            Test.setMock(HttpCalloutMock.class, rest);
            SendCourseListBatch instance = new SendCourseListBatch();
            Database.executeBatch(instance,50);
        Test.stopTest();
    }















    // @testSetup
    // static void setup() {
    //     // List<Account> acc = new List<Account>{
    //         // new Account(
    //         //             Name= 'Test Account'
    //         //         )
    //         //     };
    //         //     insert acc;

    //         // Opportunity opp = new Opportunity(Name='test opp', StageName='Closed Won');
    //         // opp.AccountId= acc[0].Id;
    //         // opp.nm_Year__c = 2019;
    //         // opp.CloseDate = system.today();
    //         // opp.nm_Session__c= 'March';
    //         // // opp.nm_Session__c= 'March';
    //         // opp.CourseList__c = '5,4,5,4,54,54';
    //         // insert opp;

    //     Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
    //     Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
    //     objopp.CourseList__c = '1,2,3,3';
    //     update objopp;
    // }

    // @isTest
    // static void unitTest1() {
    //     Test.startTest();
    //     SendCourseListBatch batchClass = new SendCourseListBatch();
    //         Database.executeBatch(batchClass,50);
    //     Test.stopTest();
    // }
}