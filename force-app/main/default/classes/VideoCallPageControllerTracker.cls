/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 12--02--2026
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class VideoCallPageControllerTracker {

 
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
    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
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

    @testSetup
    public static void setUpData(){

        //lead
        // nmGenericTracker.InsertSerialNo();
        // nmGenericTracker.CreateCenter('Mumbai');
        // Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        
        //Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        


        //Opportunity
        Opportunity objOpp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment made','1','Post Graduate Diploma Programs',objAccount,'Admission');

        //Schedule Time Slot
        String gsRecordTypeID = Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Video Call').getRecordTypeId();
        Schedule_Time_Slot__c objSlot = new Schedule_Time_Slot__c(Start_time__c = Time.newInstance(9,0,0,0), End_time__c = Time.newInstance(19,0,0,0), IsActive__c=true, RecordTypeId = gsRecordTypeID, Per_Call_Schedule_Minutes__c = 15, Start_date__c=System.today().addDays(-2), End_date__c=System.today().addDays(5), Recurrence__c = 'Daily',  Zoom_Id__c = 'Zoom51@nmims.edu',Selected_Counselors__c = 'Anjali Mishra; Ablena Mysa; Abishek Vitta');
        insert objSlot;

        //video Verification
        VVC_Junction__c objVVC = new VVC_Junction__c(Schedule_Time_Slot__c = objSlot.Id, Call_Date__c = System.today().addDays(2), Time_Range__c = '9:00 AM - 10:00AM', Account__c = objAccount.Id, Status__c = 'In Progress',Schedule_Call_Time__c = System.now().addDays(2));
        insert objVVC;


        NM_Payment_Form_Configuration__c nmpay = nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');        
        nmpay.ShowLiveLectures__c = true;
        nmpay.Current_Admission_Year__c = '2020';
        nmpay.Session__c = 'July';
        nmpay.Program_Type__c = null;
        nmpay.Last_Date_For_Video_Verification__c = System.today().addDays(10);
        update nmpay;

        // Cancelation_Date__c objCancel = new Cancelation_Date__c();
        // objCancel.NM_Payment_Form_Configuration__c = nmpay.Id;
        // objCancel.From_Date__c = System.today().addDays(-5);
        // objCancel.To_Date__c = System.today().addDays(10);
        // objCancel.Amount__c =1000;
        // insert objCancel;

        VVC_Question__c objVVQ = new VVC_Question__c(Account__c = objAccount.Id,Question__c = 'Test',Display_to_Student__c = true,Answer__c='test',VVC_Junction__c = objVVC.Id);
        insert objVVQ;
    }

    @isTest 
    static void testMethod1() {
        VVC_Junction__c objVVC = [SELECT Id,Call_Date__c FROM VVC_Junction__c LIMIT 1];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Schedule_Time_Slot__c objSTS = [SELECT Id,Time_Gap__c FROM Schedule_Time_Slot__c LIMIT 1];
        Test.startTest();
            VideoCallPageController objnmReg = new VideoCallPageController();
            VideoCallPageController.ObjWrapper wrapper = new VideoCallPageController.ObjWrapper();

            //objnmReg.getVideoCallTime = new List<SelectOption>();
            objnmReg.getVideoCallDate = new List<SelectOption>();
            objnmReg.scheduleTimeSlotId = objSTS.Id;

            wrapper.meetingDate = String.valueOf(System.today().addDays(1));
            wrapper.meetingTimeRange = '6:00 PM - 7:00 PM';
            wrapper.meetingTime = '6:00 PM';
            objnmReg.vvcJunctionId = objVVC.Id;
            objnmReg.setObjectId(objAccount.Id);
            objnmReg.getCallDateTime(objVVC,'6:00 PM');
            objnmReg.getVideoCallDate();
            objnmReg.getVideoCallTimeRange();
            objnmReg.getVideoCallTime();
            objnmReg.getVVCQuestion();
            objnmReg.getVideoTranscript();
            
            objnmReg.SaveDetail();
            objnmReg.saveVVCDetailFromAdmApp();
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {

        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
            VideoCallPageController objnmReg = new VideoCallPageController();
            VideoCallPageController.ObjWrapper wrapper = new VideoCallPageController.ObjWrapper();
    
            //objnmReg.getVideoCallTime = new List<SelectOption>();
            objnmReg.getVideoCallDate = new List<SelectOption>();

            wrapper.meetingDate = String.valueOf(System.today().addDays(1));
            wrapper.meetingTimeRange = '6:00 PM - 7:00 PM';
            wrapper.meetingTime = '6:00 PM';
            objnmReg.setObjectId(objAccount.Id);
            objnmReg.getObjectId();
            objnmReg.getObjectType();
            objnmReg.getVideoCallDate();
            objnmReg.getVideoCallTimeRange();
            objnmReg.getVideoCallTime();
            objnmReg.SaveDetail();
            objnmReg.saveVVCDetailFromAdmApp();
            //objnmReg.checkValidityOfMeeting();
            Test.setMock(HttpCalloutMock.class, new RestMockI());
            objnmReg.checkReschedule();
            objnmReg.getCallSchedulingPage();
            objnmReg.checkValidityOfMeeting();
            objnmReg.setObjectType('Account');
        Test.stopTest();
    }
}