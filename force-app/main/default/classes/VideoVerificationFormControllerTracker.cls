/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class VideoVerificationFormControllerTracker {

    @testSetup
    public static void setUpData(){
        //Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objOpp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Registration Done','1','Post Graduate Diploma Programs',objAccount,'admission');

        //Schedule Time Slot
        String gsRecordTypeID = Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Video Call').getRecordTypeId();
        Schedule_Time_Slot__c objSlot = new Schedule_Time_Slot__c(Start_time__c = Time.newInstance(9,0,0,0), End_time__c = Time.newInstance(19,0,0,0), IsActive__c=true, RecordTypeId = gsRecordTypeID, Per_Call_Schedule_Minutes__c = 15, Start_date__c=System.today().addDays(-2), End_date__c=System.today().addDays(5), Recurrence__c = 'Daily',  Zoom_Id__c = 'Zoom51@nmims.edu',Selected_Counselors__c = 'Anjali Mishra; Ablena Mysa');
        insert objSlot;

        //Video Verification
        VVC_Junction__c objVcc = new VVC_Junction__c(Schedule_Time_Slot__c = objSlot.Id, Call_Date__c = System.today().addDays(2), Time_Range__c = '9:00 AM - 10:00AM', Account__c = objAccount.Id, Status__c = 'In Progress');
        insert objVcc;
    }

    @isTest 
    static void testMethod1() {
        Account objAccount = [SELECT Id,OwnerId FROM Account LIMIT 1];
        VVC_Junction__c objVcc = [SELECT Id FROM VVC_Junction__c LIMIT 1];
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Map<String,String> map1 = new Map<String,String>(); 
        map1.put('test','Ans');
        map1.put('Does the student photo in our database match the person on the video call?','Yes, the photo matches – Proceed with questionnaire');
        Test.startTest();
        
        VideoVerificationFormController.VideoWrapper result = VideoVerificationFormController.getAccount(objAccount.Id);
        VideoVerificationFormController.VideoWrapper result2 = VideoVerificationFormController.createStudentRating(true, objAccount.Id, objVcc.Id,map1,'test');
        String image = VideoVerificationFormController.getStudentImage(objAccount.Id);
        Test.stopTest();
    }
}