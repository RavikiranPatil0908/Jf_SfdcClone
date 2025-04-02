/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class ResendEmailToPortalBatchTracker {

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
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account  objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_StudentNo__c = '7777777333';
        objAccount.Synced_With_LDAP__c = true;
        objAccount.Account_Confirm_Date__c = System.today();
        update objAccount;
    }

    @isTest
    static void testUnit1() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Database.executeBatch(new ResendEmailToPortalBatch(), 200);
        Test.stopTest();
    }

    @isTest
    static void testUnit2() {
        Test.startTest();
            Account  objAccount = [SELECT Id FROM Account][0];
            List<API_Request__c> apivalue = [SELECT Id, API_Name__c, Request__c, Response__c, Success__c, Account__c 
                                             FROM API_Request__c 
                                             WHERE Success__c = true 
                                             AND API_Name__c = 'SendEmailToPortal' 
                                             AND Account__c = :objAccount.Id];
            delete apivalue;                                       
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Database.executeBatch(new ResendEmailToPortalBatch(), 200);
        Test.stopTest();
    }
}