/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 19-07-2025
 * @last modified by  : @Shailesh
**/
@isTest(SeeAllData=false)
public without sharing class VvcMeetingUrlControllerTracker {
    public VvcMeetingUrlControllerTracker() {
    }
      //Create Access Token
    private class RestMockI implements HttpCalloutMock {
        RestMockI() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"access_token":"ytfdfghjhjjj","token_type":"bearer","expires_in":3600,"scope":"test","start_url":"http:testurl"}';
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


    }
        @isTest 
    static void testMethod1() {
        VVC_Junction__c objVVC = [SELECT Id,Call_Date__c FROM VVC_Junction__c LIMIT 1];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Schedule_Time_Slot__c objSTS = [SELECT Id,Time_Gap__c FROM Schedule_Time_Slot__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockI());
        //  Test.setMock(HttpCalloutMock.class, new RestMockII());
        VvcMeetingUrlController.checkForRefreshUrl(objVVC.Id);
        Test.stopTest();
    }
}