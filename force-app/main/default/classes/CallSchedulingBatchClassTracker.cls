/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-01-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class CallSchedulingBatchClassTracker {

    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status":"success","message":[{"Response":"success","ScheduleTime":"2023-05-13 12:45:00","campaign_name":"Test_Campaign","PhoneNumber":"8800000000","Name":"Bala","AgentID":null,"skill":"TEST","msg":"Data updated successfully","rowId":"2561154","index":0}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockI implements HttpCalloutMock {
        RestMockI() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status":"success","message":[[{"Id":"7112663","api_key":"KKd918330b70de2e2f849c3825389df335","CreatedDate":"2023-06-20 13:31:13","ScheduleTime":"2023-06-22 13:00:00","ScheduleParams":"api_key=KKd918330b70de2e2f849c3825389df335&campaign_name=Escalationcallbacks&action=START&format=json&PhoneNumber=9870446663&Name=00T2j00000rBIXuEAO&ScheduledTime=2023-06-22+13%3A00%3A00&skill=Escalation","RequestTime":"2023-06-22 13:00:13","IsRequestSent":"1","Response":{"status":"FAIL","message":"PhoneNumber Added is a DND Number"}}]]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }


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
        Id recordTypeId = Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Voice Call - Support').getRecordTypeId();

        Schedule_Time_Slot__c obj = new Schedule_Time_Slot__c(Start_date__c=System.today().addDays(-5),End_date__c=System.today().addDays(5),Recurrence__c='Daily',Start_time__c=Time.newInstance(22,00,00,00),End_time__c=Time.newInstance(23,00,00,00),IsActive__c=TRUE,Type_of_Call__c='Escalation',Total_Counselors__c=1,Skill_Name__c='TEST',Per_Call_Schedule_Minutes__c=15,Escalation_Level__c='1',RecordtypeId=recordTypeId);
        //obj.RecordtypeId=recordTypeId;
        lstST.add(obj);
        
        Schedule_Time_Slot__c obj2 = obj.clone();
        obj2.End_date__c = System.today().addDays(10);
        obj2.Recurrence__c = 'Custom';
        obj2.Custom_Schedule_Days__c = 'Tuesday';
        lstST.add(obj2);

        Schedule_Time_Slot__c obj3 = obj.clone();
        obj3.End_date__c = System.today().addDays(10);
        obj3.Recurrence__c = 'Monday to Saturday';
        obj3.Per_Call_Schedule_Minutes__c = 15;
        obj3.Total_Counselors__c = 4;
        lstST.add(obj3);
        
        insert lstST;

        List<Task> lstTK = new List<Task>();
        Task objTask = new Task(Subject='Call Scheduling',Schedule_Time_Slot__c=obj.id,Status='Not Started',Priority='Normal',Escalation_Level__c='1',WhatId=c1.id,Call_date__c=System.today(),Customer_number__c='8800000000',Student_Name__c='Test',Case__c=c1.id,Student_Email__c='test@gmail.com',Time_Range__c='10 pm - 11 pm');
        lstTK.add(objTask);
        lstTK.add(objTask.clone());

        Task objTask3 = objTask.clone();
        objTask3.Status = 'Not Connected';
        lstTK.add(objTask3);

        Task objTask4 = objTask.clone();
        objTask4.Status = 'In Progress';
        objTask4.Call_date__c = System.today().addDays(1);
        objTask4.Schedule_Time_Slot__c=obj3.id;
        lstTK.add(objTask4);
        insert lstTK;
    }

    @isTest     
    static void unitTest1(){ 
        List<Task> scope = [SELECT id,Subject,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Status,Schedule_Call_Time__c FROM Task];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            CallSchedulingBatchClass batchClass = new CallSchedulingBatchClass();
            Database.executeBatch(batchClass,100);
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        Task objTask = [SELECT id,Subject,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Status,Schedule_Call_Time__c FROM Task WHERE Status='Not Started' LIMIT 1];
        
        Date callDate = System.today().addDays(1);
        Task objTask2 = objTask.clone();
        DateTime startTime = DateTime.newInstance(callDate.year(), callDate.month(), callDate.day(), 22, 0, 0);
        objTask2.Schedule_Call_Time__c = startTime;
        objTask2.Status = 'In Progress';
        insert objTask2;
         
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            CallSchedulingBatchClass batchClass = new CallSchedulingBatchClass();
            Database.executeBatch(batchClass,100);
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        Task objTask = [SELECT id,Subject,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Status,Schedule_Call_Time__c FROM Task WHERE Status='Not Started' LIMIT 1];
        Task objTask2 = objTask.clone();
        objTask2.Schedule_Call_Time__c = System.now().addHours(-3);
        objTask2.Status = 'In Progress';
        objTask2.Call_uuid__c = '7112663';
        insert objTask2;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockI());
            CallSchedulingBatchClass batchClass = new CallSchedulingBatchClass();
            Database.executeBatch(batchClass,100);
        Test.stopTest();
    } 
    
}