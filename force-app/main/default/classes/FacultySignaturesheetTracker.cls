@isTest(SeeAllData=false)
public with sharing class FacultySignaturesheetTracker {

    // public static void setUpData(){

    // }
    static testmethod void unitTest1()
    {
        Test.startTest();
        Interview_Slot__c intr = new Interview_Slot__c();
        intr.Interview_Date__c =  date.today();
        intr.Meeting_UserId_1__c = 'ABCD';
        Insert intr;
        ApexPages.currentPage().getParameters().put('InterviewId',intr.id);
        FacultySignaturesheetController FacultySignaturesheetController = new FacultySignaturesheetController();
        Test.stopTest();
    }
   
}