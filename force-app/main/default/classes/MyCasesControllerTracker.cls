/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 18-04-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class MyCasesControllerTracker {
   
    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status":"success","message":[{"Response":"success","ScheduleTime":"2023-05-13 12:45:00","campaign_name":"Test_Campaign","PhoneNumber":"8800000000","Name":"Bala","AgentID":null,"skill":"TEST","msg":"Data updated successfully","rowId":"2561154","index":0}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

  @testSetup
    public static void setUpData(){
        nm_Program__c prog = new nm_Program__c(Name='MBA(WX) - DM', nm_TotalSemesters__c=5, PVM__c=30);
        insert prog;
        
        Id personAccRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(FirstName='Test123', LastName='abc', RecordTypeId = personAccRecordTypeId, nm_StudentNo__c='77119958556', nm_RegistrationNumber__c='745123669000',nm_Program__c=prog.Id , PersonMobilePhone='8652532023',PersonEmail='priyankakorade22@gmail.com');
        insert acc;

        String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
        String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();

        Test.setMock(HttpCalloutMock.class, new RestMockII());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_RegistrationNo__c = '37478657834653';
        update objLead;

      List<Case__c> lstTat = new List<Case__c>();
        Case__c objTAT = new Case__c();
        objTAT.Name = 'Admissions';
        objTAT.TAT__c = 3;
        lstTat.add(objTAT);

        Case__c objTAT2 = new Case__c();
        objTAT2.Name = 'Academics';
        objTAT2.TAT__c = 2;
        lstTat.add(objTAT2);
        
        Case__c objTAT3 = new Case__c();
        objTAT3.Name = 'Learner Support Center';
        objTAT3.TAT__c = 3;
        lstTat.add(objTAT3);
        insert lstTat;
    
        List<Case> lstToInsert = new List<Case>();
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket, Account=acc);
        lstToInsert.add(c1);
        Case c2 = new Case(Subject='Test', Status='Closed', Student_Purpose__c='Feedback', Tech_Issue__c='No', nm_Category__c='Admissions', sub_categories__c='Admission - Payment issue', Student_Category__c='Admissions', Student_No__c='77119958556', RecordTypeId=feedback, Account=acc);
        lstToInsert.add(c2);
        Case c3 = new Case(Subject='Test', Status='Closed', Student_Purpose__c='Complaint', Tech_Issue__c='No', nm_Category__c='Admissions', sub_categories__c='Admission - Payment issue', Student_Category__c='Admissions', Student_No__c='77119958556', RecordTypeId=ticket, Account=acc);
        lstToInsert.add(c3);
        Case c4 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=2, RecordTypeId=ticket, Account=acc);
        lstToInsert.add(c4);
        Case c5 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=3, RecordTypeId=ticket, Account=acc);
        lstToInsert.add(c5);
        Case c6 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=4, RecordTypeId=ticket, Account=acc);
        lstToInsert.add(c6);
        insert lstToInsert;

        CaseComment cc = new CaseComment(CommentBody='Test', ParentId=lstToInsert[0].Id);
        insert cc;
        
    
        ContentVersion cvf = new ContentVersion(Title='Doc1', FirstPublishLocationId=c1.Id, Comment_Id__c=cc.Id, PathOnClient='Doc1.pdf', VersionData=Blob.valueOf('Test Content Version Data'));
        insert cvf;

        List<Schedule_Time_Slot__c> lstST = new List<Schedule_Time_Slot__c>();
        Id voiceCallRecordTypeId =  Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Voice Call - Support').getRecordTypeId();
        Id voiceCallLCRecordTypeId =  Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Voice Call - LC Support').getRecordTypeId();
        Schedule_Time_Slot__c obj = new Schedule_Time_Slot__c(Start_date__c=System.today(),End_date__c=System.today().addDays(5),Recurrence__c='Daily',Start_time__c=Time.newInstance(22,00,00,00),End_time__c=Time.newInstance(23,00,00,00),IsActive__c=TRUE,Type_of_Call__c='Escalation',Total_Counselors__c=1,Skill_Name__c='TEST',Per_Call_Schedule_Minutes__c=15,Escalation_Level__c='1',RecordTypeId=voiceCallRecordTypeId);
        Schedule_Time_Slot__c obj2 = obj.clone();
        obj2.Start_date__c = System.today().addDays(3);
        obj2.End_date__c = System.today().addDays(9);
        Schedule_Time_Slot__c obj3 = obj.clone();
        obj3.Type_of_Call__c = 'Regular';
        obj3.Escalation_Level__c = null;
        Schedule_Time_Slot__c obj4 = obj.clone();
        obj4.Type_of_Call__c = 'Regular';
        obj4.RecordTypeId = voiceCallLCRecordTypeId;
        obj4.Escalation_Level__c = null;
        obj4.Skill_Name__c = 'Mumbai';
        obj4.LC_Type__c = 'Mumbai';
  
        lstST.add(obj);
        lstST.add(obj2);
        lstST.add(obj3);
        lstST.add(obj4);
        insert lstST;
    }
    
    @isTest
    static void testUnit1() {
        
        Test.setMock(HttpCalloutMock.class, new RestMockII());

        Account acct = [SELECT Id, PersonContactId, nm_StudentNo__c, nm_RegistrationNumber__c, PersonEmail, PersonMobilePhone FROM Account limit 1];
        Lead l = [SELECT Id, Email, MobilePhone, nm_RegistrationNo__c FROM Lead limit 1];
        Case c = [Select Id, contactId FROM Case limit 1];               
        c.ContactId = acct.PersonContactId;
        system.debug('Con '+acct.PersonContactId);
        update c;
        Case c2 = [SELECT Id FROM Case WHERE Student_Purpose__c = 'Feedback'];
        CaseComment cc = [SELECT Id FROM CaseComment WHERE ParentId = :c.Id];
        String token='lUkQ1jz5m8QHivEZle7huqJ71snTbAx1HUww5INiopMzyBk1iWdW7IGICzf6d4B3';
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        Map<String, Object> fileMap = new Map<String, Object>();
        fileMap.put('PathOnClient', 'doc1.png');
        fileMap.put('Title', 'doc1');
        fileMap.put('VersionData', 'File data here');
        files.add(fileMap);
        Map<String,String> caseMap = new Map<String,String>{'studentNo'=> acct.nm_StudentNo__c,'category'=> 'Admissions','purpose'=>'Feedback'};
        String res = MyCasesController.decryptToken(token);
        String sno = res.split(' ')[0];
        system.debug(sno);
        List<Id> ids = new List<Id>();
        ids.add(c.Id);
        generateToken.getToken(sno);
        RunAssignmentRules.assignCases(ids);
        MyCasesController.createCase(caseMap);
        MyCasesController.addComment('Test', c.Id, false);
        MyCasesController.getStudentDetails(sno, '', '', '');
        MyCasesController.getStudentDetails('', l.nm_RegistrationNo__c, '', '');
        MyCasesController.getMyCaseList(sno);
        MyCasesController.getMyClosedCaseList(sno);
        MyCasesController.getFeedbacks(sno);
        MyCasesController.findCases('test', sno);        
        MyCasesController.getEmailsForCase(c.Id);
        MyCasesController.getCaseDetails(c.Id);
        MyCasesController.updateCaseStatus(c.Id,true);
        MyCasesController.reopenCase(c.Id,'New Query');
        MyCasesController.escalateCase(c.Id,'No');
        MyCasesController.getDependentPicklistValues('Admissions', 'MBA(WX) - DM');
        MyCasesController.getMobileAndEmailForOTP(sno, '', '','', 'false');
        MyCasesController.VerifyOTP('42386', '42386',DateTime.now().getTime());
        Account acc = MyCasesController.verifyStudent(sno);
        MyCasesController.getStudentNo(acc.Id);
        MyCasesController.uploadFiles(files, c.Id); 
        ConvertCaseController.CaseConvert(c.Id, 'Enquiry');
        // UploadFiles.uploadFiles(files, c.Id, cc.Id);
    }

    @isTest
    static void testUnit2() {
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        
        Account acct = [SELECT Id, PersonContactId, nm_StudentNo__c FROM Account limit 1];
        Lead l = [SELECT Id, Email, MobilePhone, nm_RegistrationNo__c FROM Lead limit 1];
        Case c = [Select Id, contactId FROM Case limit 1];               
        c.ContactId = acct.PersonContactId;
        system.debug('Con '+acct.PersonContactId);
        update c;
        Case c2 = [SELECT Id FROM Case WHERE Student_Purpose__c = 'Feedback'];
        CaseComment cc = [SELECT Id FROM CaseComment WHERE ParentId = :c.Id];
        String token='lUkQ1jz5m8QHivEZle7huqJ71snTbAx1HUww5INiopMzyBk1iWdW7IGICzf6d4B3';
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        Map<String, Object> fileMap = new Map<String, Object>();
        fileMap.put('PathOnClient', 'doc1.png');
        fileMap.put('Title', 'doc1');
        fileMap.put('VersionData', 'File data here');
        files.add(fileMap);
        Map<String,String> caseMap = new Map<String,String>{'studentNo'=> acct.nm_StudentNo__c,'category'=> 'Admissions'};
        String res = MyCasesController.decryptToken(token);
        String sno = res.split(' ')[0];
        system.debug(sno);
        List<Id> ids = new List<Id>();
        ids.add(c.Id);
        generateToken.getToken(sno);
        RunAssignmentRules.assignCases(ids);
        List<Schedule_Time_Slot__c> lstST = [SELECT id FROM Schedule_Time_Slot__c LIMIT 1];
        Test.startTest();
            MyCasesController.createCase(caseMap);
            //MyCasesController.escalateCase(c.Id,'No');
            MyCasesController.getSchedulingTask('1',c.Id,c.Id,'Escalation', 'MBA (D)', '');
            MyCasesController.ScheduleCallWrapper objWrapper = new MyCasesController.ScheduleCallWrapper();
            objWrapper.scheduleId = lstST[0].id;
            objWrapper.scheduleDate = '2023-06-12';
            objWrapper.scheduleTimeRange = '12 am - 1 am';
            objWrapper.scheduleEscalationLevel = '1';
            objWrapper.recordId = c.Id;
            objWrapper.mobileNumber = '0000000001';
            objWrapper.studentName = 'Test';
            objWrapper.caseId = c.Id;
            objWrapper.email = 'test@gmail.com';
            objWrapper.callType = 'Escalation';
            MyCasesController.scheduleCall(objWrapper);
        Test.stopTest();
    }

    @isTest
    static void testUnit3() { 
        Case c = [Select Id, contactId, AccountId, Account.nm_StudentNo__c FROM Case limit 1];
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=c.Id;
        insert attach;             
        Test.startTest();
            MyCasesController.getCaseAttachments(c.Id);
            MyCasesController.checkCallAlreadyScheduled(c.AccountId);
            MyCasesController.getAccountId(c.Account.nm_StudentNo__c);
        Test.stopTest();
    }

    @isTest
    static void testUnit4() { 
        Case c = [Select Id, contactId, AccountId FROM Case limit 1];
        List<Schedule_Time_Slot__c> lstST = [SELECT id FROM Schedule_Time_Slot__c LIMIT 1];
        Test.startTest();
        MyCasesController.getSchedulingTask('2',c.Id,c.Id,'Regular', 'MBA (D)', '');
        Task objTask = new Task(Subject='Call Scheduling', Status='Not Started', Priority='Normal', Schedule_Time_Slot__c=lstST[0].id, 
                    Time_Range__c='12 am - 1 am',Escalation_Level__c='1',WhatId=c.Id,Call_date__c=System.today().addDays(1),
                    Customer_number__c='0000000000',Student_Name__c='test', Case__c=c.Id, Student_Email__c='test@gmail.com',Type_of_Call__c='Regular');
                    insert objTask;
                    MyCasesController.getSchedulingTask('1',c.Id,c.Id,'Regular', 'MBA (D)', '');
                    MyCasesController.getScheduleTableData(c.Id);
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            MyCasesController.getCancelScheduleAPI('12345', objTask.Id, 'In Progress', 'Cancel');
        Test.stopTest();
    }

    @isTest
    static void unitTest1() {
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        Account acct = [SELECT Id, PersonContactId, nm_StudentNo__c, nm_RegistrationNumber__c, PersonEmail, PersonMobilePhone FROM Account limit 1];
        Map<String,String> caseMap = new Map<String,String>{'accId'=> acct.Id,'category'=> 'Admissions'};

        Lead ld = [SELECT id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        System.debug('nm_RegistrationNo__c ==>'+ld.nm_RegistrationNo__c);
        Map<String,String> caseMap2 = new Map<String,String>{'converted'=> 'false','category'=> 'Admissions','regNo'=>ld.nm_RegistrationNo__c};
        Test.startTest();
            MyCasesController.createCase(caseMap);
            MyCasesController.createCase(caseMap2);
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        Account acct = [SELECT Id, PersonContactId, nm_StudentNo__c, nm_RegistrationNumber__c, PersonEmail, PersonMobilePhone FROM Account limit 1];
        Map<String,String> caseMap = new Map<String,String>{'converted'=> 'true','category'=> 'Admissions', 'regNo'=>'', 'email'=>acct.PersonEmail, 'mobile'=>acct.PersonMobilePhone};
        Map<String,String> caseMap2 = new Map<String,String>{'converted'=> 'true','category'=> 'Admissions', 'regNo'=>acct.nm_RegistrationNumber__c,'isSchedule'=>'yes'};

        Lead ld = [SELECT id,nm_RegistrationNo__c,Email,MobilePhone FROM Lead LIMIT 1];
        Map<String,String> caseMap3 = new Map<String,String>{'converted'=> 'false','category'=> 'Admissions','regNo'=>'', 'email'=>ld.Email, 'mobile'=>ld.MobilePhone,'source'=>'Website'};
        Test.startTest();
            MyCasesController.createCase(caseMap);
            MyCasesController.createCase(caseMap2);
            MyCasesController.createCase(caseMap3);
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        Account acct = [SELECT Id, PersonContactId, nm_StudentNo__c, nm_RegistrationNumber__c, PersonEmail, PersonMobilePhone FROM Account LIMIT 1];
        Test.startTest();
            MyCasesController.getMyCaseList(acct.nm_StudentNo__c);
        Test.stopTest();
    }
    
}