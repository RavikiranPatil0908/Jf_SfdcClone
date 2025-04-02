/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-12-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class CallDispositionControllerTest {

    @TestSetup
    static void makeData(){ 

        List<Case__c> lstTat = new List<Case__c>();
        Case__c objTAT = new Case__c();
        objTAT.Name = 'Admissions';
        objTAT.TAT__c = 3;
        lstTat.add(objTAT);

        Case__c objTAT2 = new Case__c();
        objTAT2.Name = 'Academics';
        objTAT2.TAT__c = 2;
        lstTat.add(objTAT2);
        insert lstTat;
        
        nm_Program__c prog = new nm_Program__c(Name='MBA(WX) - DM', nm_TotalSemesters__c=5, PVM__c=30);
        insert prog;
        Id personAccRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(FirstName='Test123', LastName='abc', RecordTypeId = personAccRecordTypeId, nm_StudentNo__c='77119958556', nm_Program__c=prog.Id , PersonMobilePhone='8652532023',PersonEmail='priyankakorade22@gmail.com');
        insert acc;
    	String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket);
        insert c1;
        CaseComment cc = new CaseComment(CommentBody='Test', ParentId=c1.Id);
        insert cc;
        ContentVersion cvf = new ContentVersion(Title='Doc1', FirstPublishLocationId=c1.Id, Comment_Id__c=cc.Id, PathOnClient='Doc1.pdf', VersionData=Blob.valueOf('Test Content Version Data'));
        insert cvf;

        List<Schedule_Time_Slot__c> lstST = new List<Schedule_Time_Slot__c>();
        Schedule_Time_Slot__c obj = new Schedule_Time_Slot__c(Start_date__c=System.today().addDays(-5),End_date__c=System.today().addDays(5),Recurrence__c='Daily',Start_time__c=Time.newInstance(22,00,00,00),End_time__c=Time.newInstance(23,00,00,00),IsActive__c=TRUE,Type_of_Call__c='Escalation',Total_Counselors__c=1,Skill_Name__c='TEST',Per_Call_Schedule_Minutes__c=15,Escalation_Level__c='1');
        lstST.add(obj);
        
        Schedule_Time_Slot__c obj2 = obj.clone();
        obj2.End_date__c = System.today().addDays(10);
        obj2.Recurrence__c = 'Custom';
        obj2.Custom_Schedule_Days__c = 'Tuesday';
        lstST.add(obj2);
        
        insert lstST;

        List<Task> lstTK = new List<Task>();
        Task objTask = new Task(Subject='Call Scheduling',Schedule_Time_Slot__c=obj.id,Status='Not Started',Priority='Normal',Escalation_Level__c='1',WhatId=c1.id,Call_date__c=System.today(),Customer_number__c='8800000000',Student_Name__c='Test',Case__c=c1.id,Student_Email__c='test@gmail.com',Time_Range__c='10 pm - 11 pm');
        lstTK.add(objTask);
        lstTK.add(objTask.clone());

        Task objTask3 = objTask.clone();
        objTask3.Status = 'Not Connected';
        lstTK.add(objTask3);
        insert lstTK;

        // to insert Live Chat Transcript.
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin' limit 1];
         
        User  u = new User(Alias = 'standt1', Email='standar1duser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standard11user@testorg.com');
        insert u;
        
        
        LiveChatVisitor objVisit=new LiveChatVisitor();
        insert objVisit;
    
        LiveChatTranscript objTanscrpt=new LiveChatTranscript(); 
        objTanscrpt.LiveChatVisitorId=objVisit.id;
        objTanscrpt.Transcript_Events__c='sdsdsd';
        objTanscrpt.AccountId = acc.id;
        insert objTanscrpt;
        
        LiveChatTranscriptEvent objEvent=new LiveChatTranscriptEvent();
        objEvent.Type='Other';
        objEvent.Time=system.now();
        objEvent.LiveChatTranscriptId=objTanscrpt.id;
        objEvent.AgentId=u.id;
        objEvent.Detail='Test';
        insert objEvent;
    }

    @isTest
    static void testUpdateTaskRecordSuccess() {
        String taskId = [SELECT id FROM Task LIMIT 1].Id;
        Test.startTest();
            String result = CallDispositionController.updateTaskRecord(
                taskId,
                'Enquiry',
                'No',
                'In Progress',
                'Academics',
                'Document',
                'Updated Description'
            );
        Test.stopTest();

        // System.assertEquals('Success', result);
        // Task updatedTask = [SELECT Subject, Purpose__c, Query_Resolved__c, Status, Call_Category__c, Disposition__c, Description FROM Task WHERE Id = :testTask.Id];
        // System.assertEquals('Call Scheduling', updatedTask.Subject);
        // System.assertEquals('Feedback', updatedTask.Purpose__c);
        // System.assertEquals('No', updatedTask.Query_Resolved__c);
        // System.assertEquals('In Progress', updatedTask.Status);
        // System.assertEquals('Academics', updatedTask.Call_Category__c);
        // System.assertEquals('Document', updatedTask.Disposition__c);
        // System.assertEquals('Updated Description', updatedTask.Description);
    }

    @isTest
    static void testUpdateTaskRecordError() {
        String taskId = [SELECT id FROM Task LIMIT 1].Id;
        Test.startTest();
            // Simulate an error during update by passing an invalid task ID
            String result = CallDispositionController.updateTaskRecord(
                null,
                'Enquiry',
                'No',
                'In Progress',
                'Academics',
                'Document',
                'Updated Description'
            );
        Test.stopTest();

        // System.assertEquals('Error:', result.substring(0, 6)); // Check if the result starts with 'Error:'
    }

    @isTest
    static void unitTest1(){
        String caseId = [SELECT id FROM Case LIMIT 1].Id;
        String chatId = [SELECT id FROM LiveChatTranscript LIMIT 1].Id;
        Test.startTest();
            CallDispositionController.getTaskDetails(caseId);
            CallDispositionController.getTaskFieldOptions('Purpose__c');
            CallDispositionController.getDependentPicklistValues('Disposition__c','Admissions');
            CallDispositionController.getChatTrancriptTasks(chatId);
        Test.stopTest();
    }

}