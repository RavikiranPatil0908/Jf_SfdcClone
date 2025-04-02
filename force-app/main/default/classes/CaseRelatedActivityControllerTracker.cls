/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--10--2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class CaseRelatedActivityControllerTracker {
  
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

    CaseComment cc = new CaseComment(CommentBody='Test', ParentId=lstToInsert[0].Id);
    insert cc;

    ContentVersion cvf = new ContentVersion(Title='Doc1', FirstPublishLocationId=c1.Id, Comment_Id__c=objLead.Id, PathOnClient='Doc1.pdf', VersionData=Blob.valueOf('Test Content Version Data'));
        insert cvf;
    
     ContentDistribution newDist = new ContentDistribution();
            newDist.ContentVersionId = cvf.id;
            newDist.Name = cvf.Title;
            newDist.PreferencesNotifyOnVisit = false;
            newDist.PreferencesAllowViewInBrowser = true;
            newDist.PreferencesAllowOriginalDownload=true;
    insert newDist;
}


  @isTest
  static void unitTest1(){
            CaseRelatedActivityController controller = new CaseRelatedActivityController();
            Lead lead = [SELECT Id FROM Lead LIMIT 1];
            Case c = [SELECT Id, Status, Student_Category__c, Student_Sub_Categories__c, Query_Type__c, Lead__c, recordTypeId FROM Case WHERE Lead__c=:lead.Id LIMIT 1];
           Test.startTest();
            controller.getCaseId();
            controller.setCaseId(c.Id);
           Test.stopTest();
        }

 @isTest
 static void unitTest2(){
            CaseRelatedActivityController controller = new CaseRelatedActivityController();
            Test.startTest();
            controller.getCaseId();
            Test.stopTest();
        }

     
}