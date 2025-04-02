/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class VideoCallRecordingBatchClassTracker {

    //Create Access Token
    private class RestMockI implements HttpCalloutMock {
        RestMockI() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"access_token":"ytfdfghjhjjj","token_type":"bearer","expires_in":3600,"scope":"test"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('token===>' + responseMap.get('access_token'));
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        //Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');

        //Schedule Time Slot
        String gsRecordTypeID = Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Video Call').getRecordTypeId();
        Schedule_Time_Slot__c objSlot = new Schedule_Time_Slot__c(Start_time__c = Time.newInstance(9,0,0,0), End_time__c = Time.newInstance(19,0,0,0), IsActive__c=true, RecordTypeId = gsRecordTypeID, Per_Call_Schedule_Minutes__c = 15, Start_date__c=System.today().addDays(-2), End_date__c=System.today().addDays(5), Recurrence__c = 'Daily',  Zoom_Id__c = 'Zoom51@nmims.edu',Selected_Counselors__c = 'Anjali Mishra; Ablena Mysa; Abishek Vitta');
        insert objSlot;
       
        //video verification
        List<VVC_Junction__c> lstVcc = new List<VVC_Junction__c>();
        VVC_Junction__c objVcc = new VVC_Junction__c(Zoom_User_Id__c = 'Zoom51@nmims.edu', Schedule_Time_Slot__c = objSlot.Id, Call_Date__c = System.today(), Time_Range__c = '9 am - 10 am', Account__c = objAccount.Id, Status__c = 'In Progress');
        objVcc.Schedule_Call_Time__c = System.now().addMinutes(45);
        objVcc.Agent_Name__c = 'Abishek Vitta';
        objVcc.Meeting_Id__c = '1234';
        lstVcc.add(objVcc);
        
        VVC_Junction__c objVcc2 = new VVC_Junction__c(Zoom_User_Id__c = 'Zoom51@nmims.edu', Schedule_Time_Slot__c = objSlot.Id, Call_Date__c = System.today(), Time_Range__c = '9 am - 10 am', Status__c = 'In Progress');
        objVcc2.Schedule_Call_Time__c = System.now().addMinutes(70);
        objVcc2.Agent_Name__c = 'Ablena Mysa';
        objVcc2.Meeting_Id__c = '4553';
        lstVcc.add(objVcc2);

        VVC_Junction__c objVcc3 = new VVC_Junction__c(Zoom_User_Id__c = 'Zoom51@nmims.edu', Schedule_Time_Slot__c = objSlot.Id, Call_Date__c = System.today(), Time_Range__c = '9 am - 10 am', Account__c = objAccount.Id, Status__c = 'In Progress');
        objVcc3.Schedule_Call_Time__c = System.now().addMinutes(90);
        objVcc3.Agent_Name__c = 'Anjali Mishra';
        objVcc3.Meeting_Id__c = '7897';
        lstVcc.add(objVcc3);

        insert lstVcc;
    }

    @isTest     
    static void unitTest1(){ 
       
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockI());
            VideoCallRecordingBatchClass batchClass = new VideoCallRecordingBatchClass();
            Database.executeBatch(batchClass,90);
        Test.stopTest();
    }

}