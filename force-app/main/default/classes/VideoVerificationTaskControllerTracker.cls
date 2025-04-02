/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class VideoVerificationTaskControllerTracker {
    public VideoVerificationTaskControllerTracker() {
    }
    @testSetup
    public static void setUpData() {
        Date calld1 = Date.today();
        //Datetime dt = DateTime.parse('10/14/2024, 11:45 AM');
        datetime dt = datetime.now();
        Account acc = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Registered');
        VVC_Junction__c vvc1 = new VVC_Junction__c(Account__c = acc.Id, Status__c='In Progress', Call_Date__c = calld1,
        Schedule_Call_Time__c = dt, Call_Recording_Url__c ='https://abc.com', Student_Name__c = acc.name);
        insert vvc1;
    }
    @isTest
    static void doTest(){
        Date fromDate = Date.today();
        Date toDate = fromDate.addDays(1);
        Date dateNoValue;
        List<String> callStatus = new List<String>{'In Progress'};
        Test.startTest();
        VideoVerificationTaskController.findVideoCallByStatus(callStatus, fromDate, toDate);
        VideoVerificationTaskController.findVideoCallByStatus(callStatus, dateNoValue, dateNoValue);
        //VideoVerificationTaskController.getRecordData();
        Test.stopTest();
    }
}