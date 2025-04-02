/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-16-2021
 * @last modified by  : @BK
**/
@istest (SeeAllData=false)
public class SurveyTracker {
    @TestSetup
    static void makeData(){
        List<Question_Bank__c> lstQBs = new List<Question_Bank__c>();
        // 1st Question
        Question_Bank__c objQB = new Question_Bank__c();
        objQB.Active__c = true;
        objQB.Function__c = 'Admissions';
        objQB.Activity__c = 'Validity Extension';
        objQB.Answer__c = 'Two years;Fours years';
        objQB.Program_Type__c = 'Bachelor\'s';
        objQB.Question__c = 'Duration of PG program';
        objQB.Type__c = 'Multiple Choice';
        objQB.Mark__c = 1;
        lstQBs.add(objQB);
        // 2nd Question
        Question_Bank__c objQB1 = new Question_Bank__c();
        objQB1.Active__c = true;
        objQB1.Function__c = 'Admissions';
        objQB1.Activity__c = 'Validity Extension';
        objQB1.Answer__c = 'Two years';
        objQB1.Program_Type__c = 'Bachelor\'s';
        objQB1.Question__c = 'Duration of PG program';
        objQB1.Type__c = 'Single Choice';
        objQB1.Mark__c = 1;
        lstQBs.add(objQB1);
        //3rd Question 
        Question_Bank__c objQB2 = new Question_Bank__c();
        objQB2.Active__c = true;
        objQB2.Function__c = 'Admissions';
        objQB2.Activity__c = 'Validity Extension';
        objQB2.Answer__c = 'Two years';
        objQB2.Program_Type__c = 'Bachelor\'s';
        objQB2.Question__c = 'Duration of PG program';
        objQB2.Type__c = 'Descriptive';
        objQB2.Mark__c = 1;
        lstQBs.add(objQB2);
        insert lstQBs;

        Survey__c objSurvey = new Survey__c();
        objSurvey.Name = 'Bachelor Admission Survey';
        objSurvey.Function__c = 'Admissions';
        objSurvey.Activity__c = 'Validity Extension';
        objSurvey.Program_Type__c = 'Bachelor\'s';
        objSurvey.IsActive__c = true;
        objSurvey.New_Survey__c = true;
        objSurvey.Survey_Header__c = 'Bachelor Admission Survey';
        objSurvey.Timer__c = 45;
        objSurvey.Submit_Response__c = 'Thank You';
        insert objSurvey;

        List<Survey_Question__c> lstSurveyQuestion = new List<Survey_Question__c>();

        Survey_Question__c objSQ1 = new Survey_Question__c();
        objSQ1.Survey__c = objSurvey.Id;
        objSQ1.Question_Bank__c = objQB.Id;
        lstSurveyQuestion.add(objSQ1);

        Survey_Question__c objSQ2 = new Survey_Question__c();
        objSQ2.Survey__c = objSurvey.Id;
        objSQ2.Question_Bank__c = objQB1.Id;
        lstSurveyQuestion.add(objSQ2);

        Survey_Question__c objSQ3 = new Survey_Question__c();
        objSQ3.Survey__c = objSurvey.Id;
        objSQ3.Question_Bank__c = objQB2.Id;
        lstSurveyQuestion.add(objSQ3);

        Counsellor_Profile__c objProfile = new Counsellor_Profile__c();
        objProfile.First_Name__c = 'fagu';
        objProfile.Middle_Name__c = 'dsafdsf';
        objProfile.Employee_Image_URL__c='www.gmail.com';
        objProfile.Employee_Sign_URL__c='www.gmail.com';
        objProfile.Gender__c = 'Female';
        insert objProfile;
    }

    @isTest
    static void unitTest1() {
        Counsellor_Profile__c objProfile = [SELECT id FROM Counsellor_Profile__c LIMIT 1];
        Test.startTest();
            List<Survey__c> lstSurvey = Survey.getAssessments();
            Survey__c objSurvey = lstSurvey[0];
            Survey.getSurveyRecord();
            Survey.getQuestionBanks(objSurvey.id);
            Survey.getAssessmentRecords(1,200,null,null,null,null);
            Survey.getAssessmentRecords(1,200,null,'Name','DESC',null);
            Survey.QuestionBankWrapper qbwrapper = Survey.getQuestionBank(objSurvey.Function__c,objSurvey.Activity__c,objSurvey.Program_Type__c,objSurvey.Id);
            Survey__c objSurveyClone = objSurvey.clone();
            objSurveyClone = Survey.upsertAssessment(objSurveyClone);
            Survey.addQuestions(qbwrapper.lstQuestionBank,objSurveyClone.Id);
            Survey.SurveyTakerWrapper stwrapper = Survey.createNewSurveyTaker(objSurveyClone.Id,objProfile.Id);
            List<Survey_Question__c> lstqb = [SELECT id FROM Survey_Question__c WHERE Survey__c=:objSurveyClone.Id];
            SurveyQuestionResponse__c objResponse = new SurveyQuestionResponse__c();
            objResponse.Answer__c = 'test';
            objResponse.SurveyTaker__c = stwrapper.surveyTakerId;
            objResponse.Survey_Question__c = lstqb[0].Id;
            Survey.upsertSurveyQuestionResponse(objResponse,5);
            Survey.createNewSurveyTaker(objSurveyClone.Id,objProfile.Id);
            Survey.createNewSurveyTaker(objSurveyClone.Id,null);
            Survey.createNewSurveyTaker(objSurveyClone.Id,'test');
            Survey.submitAssessment(stwrapper.objSurveyTaker);
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        Test.startTest();
            Question_Bank__c objQB = new Question_Bank__c();
            objQB.Active__c = true;
            objQB.Function__c = 'Admissions';
            objQB.Activity__c = 'Validity Extension';
            objQB.Answer__c = 'Two years;Fours years';
            objQB.Program_Type__c = 'Bachelor\'s';
            objQB.Question__c = 'Duration of PG program?';
            objQB.Type__c = 'Multiple Choice';
            objQB.Mark__c = 1;
            Survey.Createrecord(objQB);
        Test.stopTest();
    }
}