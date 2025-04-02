/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 10-14-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class MigrateStudentRatingBatchClassTracker {

    @testSetup
    public static void setUpData() { 
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Registered');
        Opportunity objOpp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Closed','1','Post Graduate Diploma Programs',objAccount,'Admission');
        objOpp.Account = objAccount;
        
        String studentRecordTypeID = Schema.SObjectType.Student_Rating__c.getRecordTypeInfosByName().get('Video Verification').getRecordTypeId();
        Student_Rating__c objRating = new Student_Rating__c();
        objRating.Student__c = objAccount.Id;
        objRating.Does_Photo_Matched__c = 'Yes, the photo matches – Proceed with questionnaire';
        objRating.Confirm_Correct_DOB__c = 'Yes, it is correct';
        objRating.Confirm_Correct_Duration__c = 'No, the student is not aware and does not want to continue';
        objRating.Confirm_Correct_Program__c = 'Yes, it is correct';
        objRating.Confirm_Exam_Fee__c = 'Yes, the student is aware';
        objRating.Confirm_Passing_Marks__c = 'Yes, the student is aware';
        objRating.Confirm_Special_Case__c = 'Yes, the student is aware';
        objRating.Confirm_No_Placement_Service__c = 'Yes, continue, the student is aware';
        objRating.Confirm_Mandatory_Engagement__c = 'Yes, the student is aware';
        objRating.Confirm_Cancellation_date__c = 'Yes, the student is aware';
        objRating.Confirm_Session__c = 'Yes, the student is aware';
        objRating.Confirm_Examination_Component__c = 'Yes, the student is aware';
        objRating.Confirm_Exam_Evaluation__c = 'Yes, the student is aware';
        objRating.Confirm_Term_End_Examination__c = 'Yes, the student is aware';
        objRating.Confirm_Reexam_Process__c = 'Yes, the student is aware';
        objRating.Confirm_Loan_Details__c = 'Yes, I agree';
        objRating.Confirm_Validity_Of_Program__c = 'Yes, the student is aware';
        objRating.RecordTypeId = studentRecordTypeID;
        insert objRating;

        //task
        Task objTask = new Task(Subject='Video Call Scheduling', Call_date__c = System.today().addDays(-2), Time_Range__c = '9:00 AM - 10:00AM', WhatId = objAccount.Id, Status = 'Completed',Schedule_Call_Time__c = System.now().addDays(-2));
        objTask.StudentRating__c = objRating.Id;
        insert objTask;
    }

    @isTest
    static void testUnit1() {
        Test.startTest();
        MigrateStudentRatingBatchClass batchClass = new MigrateStudentRatingBatchClass();
            Database.executeBatch(batchClass,100);
        Test.stopTest();
    }
}