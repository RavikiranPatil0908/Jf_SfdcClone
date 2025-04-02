@IsTest
public with sharing class InterviewSlotApprovalControllerTracker {
    @TestSetup
    static void makeData(){
        Interview_Slot__c objInterviewSlot = new Interview_Slot__c();
        objInterviewSlot.Meeting_UserId_1__c = 'www.google.com';
        insert objInterviewSlot;
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.Interview_Slot__c = objInterviewSlot.Id;
        update objAccount;
    }

    @IsTest
    static void methodName(){
        
        Test.startTest();
        List<Interview_Slot__c> lstInterviewSlot =[SELECT Id FROM Interview_Slot__c LIMIT 1];
        InterviewSlotApprovalController instance = new InterviewSlotApprovalController();
        instance.setInterviewSlotID(lstInterviewSlot[0].Id);
        instance.getInterviewSlotID();
        Test.stopTest();
        
    }
}