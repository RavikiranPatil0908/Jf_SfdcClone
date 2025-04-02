/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 02-03-2025
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class VideoCallSchedulingHandlerTracker {

    // Create Meeting
    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"uuid":"Cg2zmozlQVqeV7LFahKfHw==","id":85085093156,"host_id":"Z__Ixb7JSl-Ise0YcCMdjd","host_email":"Zoom51@nmims.edu","topic":"Online Meeting","type":2,"status":"waiting","start_time":"2024-05-11T09:00:00Z","duration":15,"timezone":"Asia/Kolkata","agenda":"testing","created_at":"2024-05-10T09:44:26Z","start_url":"https://ngasce.zoom.us/s/abc","join_url":"https://ngasce.zoom.us/j/76655","pre_schedule":false}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(201);
            return res;
        }
    } 

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

    // Delete
    private class RestMockIII implements HttpCalloutMock {
        RestMockIII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(204);
            return res;
        }
    }

    // Get Scheduled Meeting
    private class RestMockIV implements HttpCalloutMock {
        RestMockIV() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"page_size":300,"total_records":2,"next_page_token":"","meetings":[{"uuid":"PsNb+uTOTSyKZS4","id":8691,"host_id":"Z__Ixb7JSl-Ise0","topic":"Online Meeting","type":2,"start_time":"2024-05-11T12:00:00Z","duration":15,"timezone":"Asia/Kolkata","agenda":"Video Verification Survey","created_at":"2024-05-10T04:02:25Z","join_url":"https://ngasce.zoom.us/j/8691"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
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
       
        //Video verification
        VVC_Junction__c objVcc = new VVC_Junction__c(Zoom_User_Id__c = 'Zoom51@nmims.edu', Schedule_Time_Slot__c = objSlot.Id, Call_date__c = System.today().addDays(2), Time_Range__c = '9 am - 10 am', Account__c = objAccount.Id, Status__c = 'In Progress');
        objVcc.Schedule_Call_Time__c = Datetime.newInstance( objVcc.Call_date__c.year(),  objVcc.Call_Date__c.month(),  objVcc.Call_date__c.day(),  9,  0, 0);
        objVcc.Agent_Name__c = 'Abishek Vitta';
        objVcc.Zoom_User_Id__c = 'Zoom51@nmims.edu';
        insert objVcc;
        VVC_Junction__c objVcc2 = new VVC_Junction__c(Zoom_User_Id__c = 'Zoom51@nmims.edu', Schedule_Time_Slot__c = objSlot.Id, Call_Date__c = System.today().addDays(2), Time_Range__c = '9 am - 10 am', Status__c = 'In Progress');
        objVcc2.Schedule_Call_Time__c = Datetime.newInstance( objVcc2.Call_Date__c.year(),  objVcc2.Call_Date__c.month(),  objVcc2.Call_Date__c.day(),  9,  15, 0);
        objVcc2.Agent_Name__c = 'Ablena Mysa';
        objVcc2.Zoom_User_Id__c = 'Zoom51@nmims.edu';
        insert objVcc2;
    }

     @isTest     
    static void unitTest1(){ 
        VVC_Junction__c obj = [SELECT id,Schedule_Time_Slot__c,Zoom_User_Id__c,Zoom_Url__c,Call_Date__c,Mobile_Number__c,Student_Name__c,Student_Email__c,Account__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c,Time_Range__c,Call_Scheduled_Time__c FROM VVC_Junction__c LIMIT 1];
        Schedule_Time_Slot__c objScheduling = [SELECT id,Zoom_Id__c,Start_time__c,End_time__c FROM Schedule_Time_Slot__c WHERE id =:obj.Schedule_Time_Slot__c LIMIT 1];
        Account objAccount = [SELECT Id,PersonMobilePhone,firstName,lastName,PersonEmail FROM Account LIMIT 1];
        VVC_Junction__c objVcc = obj.clone();
        objVcc.Status__c = 'Not Started';
        objVcc.Mobile_Number__c = objAccount.PersonMobilePhone;
        objVcc.Student_Name__c = objAccount.firstName + objAccount.lastName;
        objVcc.Student_Email__c = objAccount.PersonEmail;
       
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockI());
            VideoCallSchedulingHandler objHandler = new VideoCallSchedulingHandler();
            objHandler.scheduleMeeting(objVcc,true,'10:00 AM');
            // objHandler.getExisitingCalls(objVcc);
            // objHandler.handleCallScheduling(objVcc);
            Test.setMock(HttpCalloutMock.class, new RestMockIV());
            objHandler.callApiToCreateMeeting(objVcc,true);
        Test.stopTest();
    }
    
    @isTest     
     static void unitTest2(){ 
        VVC_Junction__c obj = [SELECT id,Schedule_Time_Slot__c,Zoom_User_Id__c,Zoom_Url__c,Call_Date__c,Mobile_Number__c,Student_Name__c,Student_Email__c,Account__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c,Time_Range__c,Call_Scheduled_Time__c FROM VVC_Junction__c LIMIT 1];
        Schedule_Time_Slot__c objScheduling = [SELECT id,Zoom_Id__c,Start_time__c,End_time__c FROM Schedule_Time_Slot__c WHERE id =:obj.Schedule_Time_Slot__c LIMIT 1];
        Account objAccount = [SELECT Id,PersonMobilePhone,firstName,lastName,PersonEmail FROM Account LIMIT 1];
        VVC_Junction__c objVcc = obj.clone();
        objVcc.Status__c = 'Not Started';
        objVcc.Mobile_Number__c = objAccount.PersonMobilePhone;
        objVcc.Student_Name__c = objAccount.firstName + objAccount.lastName;
        objVcc.Student_Email__c = objAccount.PersonEmail;
        objVcc.Meeting_Id__c = '7588844'; 
        
        Test.startTest();
            VideoCallSchedulingHandler objHandler = new VideoCallSchedulingHandler();
            Test.setMock(HttpCalloutMock.class, new RestMockIV());
            objHandler.scheduleMeeting(objVcc,true,'10:00 AM');
            //objHandler.callDeleteZoomMeeting(objVcc);
        Test.stopTest();
    }

    @isTest     
    static void unitTest3(){ 
       VVC_Junction__c obj = [SELECT id,Schedule_Time_Slot__c,Zoom_User_Id__c,Zoom_Url__c,Call_Date__c,Mobile_Number__c,Student_Name__c,Student_Email__c,Account__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c,Time_Range__c,Call_Scheduled_Time__c FROM VVC_Junction__c LIMIT 1];
       Schedule_Time_Slot__c objScheduling = [SELECT id,Zoom_Id__c,Start_time__c,End_time__c FROM Schedule_Time_Slot__c WHERE id =:obj.Schedule_Time_Slot__c LIMIT 1];
       Account objAccount = [SELECT Id,PersonMobilePhone,firstName,lastName,PersonEmail FROM Account LIMIT 1];
       VVC_Junction__c objVcc = obj.clone();
       objVcc.Status__c = 'Not Started';
       objVcc.Mobile_Number__c = objAccount.PersonMobilePhone;
       objVcc.Student_Name__c = objAccount.firstName + objAccount.lastName;
       objVcc.Student_Email__c = objAccount.PersonEmail;
       objVcc.Meeting_Id__c = '7588844'; 
       
       Test.startTest();
           VideoCallSchedulingHandler objHandler = new VideoCallSchedulingHandler();
           Test.setMock(HttpCalloutMock.class, new RestMockIII());
           objHandler.callDeleteZoomMeeting(objVcc);
       Test.stopTest();
   }

   @isTest     
    static void unitTest4(){ 
       VVC_Junction__c obj = [SELECT id,Schedule_Time_Slot__c,Zoom_User_Id__c,Zoom_Url__c,Call_Date__c,Mobile_Number__c,Student_Name__c,Student_Email__c,Account__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c,Time_Range__c,Call_Scheduled_Time__c FROM VVC_Junction__c LIMIT 1];
       Schedule_Time_Slot__c objScheduling = [SELECT id,Zoom_Id__c,Start_time__c,End_time__c FROM Schedule_Time_Slot__c WHERE id =:obj.Schedule_Time_Slot__c LIMIT 1];
       Account objAccount = [SELECT Id,PersonMobilePhone,firstName,lastName,PersonEmail FROM Account LIMIT 1];
       VVC_Junction__c objVcc = obj.clone();
       objVcc.Status__c = 'Not Started';
       objVcc.Mobile_Number__c = objAccount.PersonMobilePhone;
       objVcc.Student_Name__c = objAccount.firstName + objAccount.lastName;
       objVcc.Student_Email__c = objAccount.PersonEmail;
       objVcc.Meeting_Id__c = '7588844';
       objVcc.Schedule_Call_Time__c = System.now();
       objVcc.Agent_Name__c = 'Abishek Vitta';
       objVcc.Zoom_User_Id__c = 'Zoom51@nmims.edu';
       
       Test.startTest();
           VideoCallSchedulingHandler objHandler = new VideoCallSchedulingHandler();
           Test.setMock(HttpCalloutMock.class, new RestMockII());
           objHandler.callApiToCreateMeeting(objVcc,false);
       Test.stopTest();
   }
}