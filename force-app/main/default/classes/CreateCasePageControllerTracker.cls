/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--10--2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public with sharing class CreateCasePageControllerTracker {

    @TestSetup
    static void makeData(){

        String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
    
         Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Account acc = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');

        List<Case> lstToInsert = new List<Case>();
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No',Query_Type__c='Complaint', Student_Category__c='Need More Information',  Student_Sub_Categories__c = 'Regarding Program',Escalation_Level__c=0, RecordTypeId=ticket, Lead__c = objLead.Id);
        lstToInsert.add(c1);
        Case c2 = new Case(Subject='Test', Status='Closed', Query_Type__c='Feedback', Tech_Issue__c='No',Student_Sub_Categories__c='Regarding Program', Student_Category__c='Need More Information', Student_No__c='77119958555', RecordTypeId=feedback, Account=acc);
        lstToInsert.add(c2);
        Case c3 = new Case(Subject='Test', Status='Closed', Query_Type__c='Complaint', Tech_Issue__c='No',Student_Sub_Categories__c='Regarding Program', Student_Category__c='Need More Information', Student_No__c='77119958556', RecordTypeId=ticket, Account=acc);
        lstToInsert.add(c3);
        Case c4 = new Case(Query_Type__c = 'Enquiry', Student_Category__c = 'Need More Information', Student_Sub_Categories__c = 'Regarding Program',  Status = 'New',  Description = 'test',Subject = 'Product-test',  Lead__c = objLead.Id, recordTypeId =ticket );
         lstToInsert.add(c4);
        insert lstToInsert;
    }

    @isTest
    static void unitTest1() {
        CreateCasePageController controller = new CreateCasePageController();
         Case caseRecords = [SELECT Id ,CaseNumber, Subject ,Description ,Student_Category__c, Student_Sub_Categories__c, CreatedDate, Status, Expected_Close_Date__c,ClosedDate,RecordType.Name FROM Case LIMIT 1];
        Test.startTest();
          controller.setCaseId(caseRecords.Id);
          controller.getCaseId();
          Test.stopTest();

    }

   @isTest
    static void unitTest2() {
        CreateCasePageController controller = new CreateCasePageController();
        controller.objComment = new CreateCasePageController.CaseCommentDetail();
        controller.objComment.comment='Test';
        controller.objComment.actionType='AddComment';
        Test.startTest();
        controller.addCaseComment();
        Test.stopTest();
    }
    
     @isTest
    static void unitTest3() {
        CreateCasePageController controller = new CreateCasePageController();
        controller.objComment = new CreateCasePageController.CaseCommentDetail();
        controller.objComment.reasonForReOpen='Not happy with the resolution';
        Case c=[SELECT Id FROM Case LIMIT 1];
        controller.setCaseId(c.Id);
        Test.startTest();
        controller.reopenTicket();
        controller.closeTicket();
        Test.stopTest();
    }
    
}