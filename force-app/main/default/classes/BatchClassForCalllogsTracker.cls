/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 27-02-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class BatchClassForCalllogsTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            DateTime startDate = System.now().addDays(-1);
            DateTime endDate = System.now().addDays(-1).addMinutes(5);
            String fullJson ='{"status":"success","message":[{"monitorUCID":"3522170238422061","UCID":"3522170238422061","UUI":"00T2j00000wHJ08EAG","Did":"912269315390","CampaignName":"Regularcallbacks","Location":"mumbai","CallerID":"08369389877","PhoneName":"AnjaliMishra","SkillID":"24917","Skill":"DailyCallBacks","StartTime":"'+startDate.format('yyyy-MM-dd HH:mm:ss')+'","EndTime":"'+endDate.format('yyyy-MM-dd HH:mm:ss')+'","TimeToAnswer":"00:00:22","CallDuration":"01:03:13","Duration":"00:02:51","FallBackRule":"Agent Dials","DialedNumber":"21429","Type":"Progressive","AgentID":"AnjaliMishra","AgentPhoneNumber":"21429","AgentUniqueID":"8771","AgentName":"Anjali Mishra","Disposition":"Exams_Missed Examination","HangupBy":"UserHangup","Status":"Answered","AudioFile":"https://s3.ap-southeast-1.amazonaws.com/recordings.kookoo.in/nmims_2/IVRdd2491df020f94c2b2892f5546745065.mp3","TransferType":"No Transfers","TransferredTo":"","Comments":"~~","DialStatus":"answered","Apikey":"","AgentStatus":"answered","CustomerStatus":"answered","UserName":"","CallerConfAudioFile":"","ConfDuration":"00:00:00","CampaignStatus":"ONLINE","TotalWrapupTime":"00:00:09","TotalHandlingTime":"00:03:00","CustomerRingTime":"00:00:08"},{"monitorUCID":"3522170235180721","UCID":"3522170235180721","UUI":"00T2j00000wHFaWEAW","Did":"912269315390","CampaignName":"Regularcallbacks","Location":"mumbai","CallerID":"08904407597","PhoneName":"NidaVasaikar","SkillID":"24917","Skill":"DailyCallBacks","StartTime":"'+startDate.format('yyyy-MM-dd HH:mm:ss')+'","EndTime":"'+endDate.format('yyyy-MM-dd HH:mm:ss')+'","TimeToAnswer":"00:00:20","CallDuration":"00:01:52","Duration":"00:01:32","FallBackRule":"Agent Dials","DialedNumber":"21441","Type":"Progressive","AgentID":"NidaVasaikar","AgentPhoneNumber":"21441","AgentUniqueID":"17971","AgentName":"Nida Vasaikar","Disposition":"Exams_Exam Schedule Change","HangupBy":"UserHangup","Status":"Answered","AudioFile":"https://s3.ap-southeast-1.amazonaws.com/recordings.kookoo.in/nmims_2/IVReed0f8920e9d500a984da4bbf7ac0b74.mp3","TransferType":"No Transfers","TransferredTo":"","Comments":"~~","DialStatus":"answered","Apikey":"","AgentStatus":"answered","CustomerStatus":"answered","UserName":"","CallerConfAudioFile":"","ConfDuration":"00:00:00","CampaignStatus":"ONLINE","TotalWrapupTime":"00:00:14","TotalHandlingTime":"00:01:46","CustomerRingTime":"00:00:13"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup    
    public static void makeData(){  
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.MobilePhone = '8904407597';
        update objLead;

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No', false,'Admission form & documents Approved');
        objAccount.PersonMobilePhone = '8369389877';
        update objAccount;
    }


    @isTest 
    static void unitTest1() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            BatchClassForCalllogs batchClass = new BatchClassForCalllogs();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest2() {
        DateTime startDate = System.now().addDays(-1);
        Account objAccount = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
        Task objTask = new Task(Subject='Call Scheduling', Status='Connected', Priority='Normal',  WhatId=objAccount.Id, Call_date__c=startDate.date(), Customer_number__c=objAccount.PersonMobilePhone, Actual_Call_Date__c=startDate);
        insert objTask;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            BatchClassForCalllogs batchClass = new BatchClassForCalllogs();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }
}