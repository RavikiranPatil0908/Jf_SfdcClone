/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class VideoCallAgentNotJoinedBatchClassTracker {

    @TestSetup
    static void makeData(){
        //Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');

        //Schedule Time Slot
        String gsRecordTypeID = Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Video Call').getRecordTypeId();
        Schedule_Time_Slot__c objSlot = new Schedule_Time_Slot__c(Start_time__c = Time.newInstance(9,0,0,0), End_time__c = Time.newInstance(19,0,0,0), IsActive__c=true, RecordTypeId = gsRecordTypeID, Per_Call_Schedule_Minutes__c = 15, Start_date__c=System.today().addDays(-2), End_date__c=System.today().addDays(5), Recurrence__c = 'Daily',  Zoom_Id__c = 'Zoom51@nmims.edu',Selected_Counselors__c = 'Anjali Mishra; Ablena Mysa; Abishek Vitta');
        insert objSlot;
       
        //task
        List<Task> lstTask = new List<Task>();
        Task objTask = new Task(Zoom_User_Id__c = 'Zoom51@nmims.edu',Subject='Video Call Scheduling', Schedule_Time_Slot__c = objSlot.Id, Call_date__c = System.today(), Time_Range__c = '9 am - 10 am', WhatId = objAccount.Id, Status = 'In Progress');
        objTask.Schedule_Call_Time__c = System.now().addMinutes(30);
        objTask.AgentName__c = 'Abishek Vitta';
        objTask.Meeting_Id__c = '1234';
        lstTask.add(objTask);

        Task objTask3 = new Task(Zoom_User_Id__c = 'Zoom51@nmims.edu',Subject='Video Call Scheduling', Schedule_Time_Slot__c = objSlot.Id, Call_date__c = System.today(), Time_Range__c = '9 am - 10 am', WhatId = objAccount.Id, Status = 'In Progress');
        objTask3.Schedule_Call_Time__c = System.now().addMinutes(-30);
        objTask3.AgentName__c = 'Anjali Mishra';
        objTask3.Meeting_Id__c = '7897';
        lstTask.add(objTask3);
        
        Task objTask2 = new Task(Zoom_User_Id__c = 'Zoom51@nmims.edu',Subject='Video Call Scheduling', Schedule_Time_Slot__c = objSlot.Id, Call_date__c = System.today(), Time_Range__c = '9 am - 10 am', Status = 'In Progress');
        objTask2.Schedule_Call_Time__c = System.now().addMinutes(45);
        objTask2.AgentName__c = 'Ablena Mysa';
        objTask2.Meeting_Id__c = '4553';
        lstTask.add(objTask2);

        Task objTask4 = new Task(Zoom_User_Id__c = 'Zoom51@nmims.edu',Subject='Video Call Scheduling', Schedule_Time_Slot__c = objSlot.Id, Call_date__c = System.today(), Time_Range__c = '9 am - 10 am', WhatId = objAccount.Id, Status = 'In Progress');
        objTask4.Schedule_Call_Time__c = System.now().addMinutes(60);
        objTask4.AgentName__c = 'Anjali Mishra';
        objTask4.Meeting_Id__c = '7567';
        lstTask.add(objTask4);
        insert lstTask;
    }

    @isTest     
    static void unitTest1(){ 
        List<Task> scope = [SELECT id FROM Task];
        Test.startTest();
        VideoCallAgentNotJoinedBatchClass batchClass = new VideoCallAgentNotJoinedBatchClass();
            Database.executeBatch(batchClass,100);
        Test.stopTest();
    }
}