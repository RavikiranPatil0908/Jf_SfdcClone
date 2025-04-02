@isTest
public with sharing class InterviewApprovalBatchClassTracker {
    @TestSetup
    static void makeData(){

        Interview_Slot__c objInterviewSlot = new Interview_Slot__c();
        objInterviewSlot.Meeting_UserId_1__c = 'www.google.com';
        insert objInterviewSlot;
        objInterviewSlot.Faculty_name_2__c = 'ghjghj';
        update objInterviewSlot;
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.Interview_Slot__c = objInterviewSlot.Id;
        objAccount.Interview_Status__c = 'Approval Pending';
        objAccount.Program_Type__c = 'MBA (WX)';
        update objAccount;
        Student_Rating__c objStudentRating = new Student_Rating__c();
        objStudentRating.Student__c = objAccount.Id;
        objStudentRating.Question_1_Student_Rating__c = '8';
        objStudentRating.Question_2_Student_Rating__c = '8';
        objStudentRating.Question_5_Student_Rating__c = 'Yes';
        objStudentRating.Question_3_Student_Rating__c = '8';
        objStudentRating.Question_4_Student_Rating__c = '4';
        objStudentRating.Q5_text__c = 'objAccount.Id';
        objStudentRating.imageUpload__c = 'www.google.com';
        insert objStudentRating;
        objStudentRating.imageUpload__c = 'www.google1.com';
        update objStudentRating;
    }

    @IsTest
    static void methodName(){
        
        Test.startTest();
        InterviewApprovalBatchClass instance = new InterviewApprovalBatchClass();
        Database.executeBatch(instance,1);
        Test.stopTest();
        
    }
}