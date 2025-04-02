/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 07-24-2024
 * @last modified by  : @vickysahu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-15-2021   shubhranshu   Initial Version
**/
@isTest(SeeAllData=false)
public class InterviewScheduleLead_Tracker {
    private class RestMock implements HttpCalloutMock {
        public String method;

        RestMock() {
            method ='';
        }

        public HTTPResponse respond(HTTPRequest req) {
            Integer statusCode = 201;
            String fullJson = '{"uuid":"i7pLNRJBSmW7OT7LSkpcow==","id":369201743,"host_id":"XW4NHyiHS4yfzslHZ32cyg","topic":"Interview","type":2,"status":"waiting","start_time":"2019-06-23T06:30:00Z","duration":10,"timezone":"Asia/Kolkata","agenda":"Interview Meeting","created_at":"2019-05-23T05:49:28Z","start_url":"https://ngasce.zoom.us/s/369201743?zak=eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjbGllbnQiLCJ1aWQiOiJYVzROSHlpSFM0eWZ6c2xIWjMyY3lnIiwiaXNzIjoid2ViIiwic3R5IjoxMDAsIndjZCI6ImF3MSIsImNsdCI6MCwic3RrIjoiUGxzWVJ2cEFDZ0V0RW55TW95RmtuaFJoV2Rkb0FoTmNEdFFzRnF5aTB3MC5CZ1VnZW1sck9WZENSREl4U3poS1IzQlFZaTgzTm1GNU4wRnBObG8yVWxCUFNYcEFZVFk0WW1GaU5EVXhPVGs1WkRSbE0yTTBaRGt6WWpJNE1EWTJabUV4TWpRd1pqRXdNalEzWWprNFl6ZzROakU0TUdKaE0yVTJORFk0WkdNeE5qa3daUUFNTTBOQ1FYVnZhVmxUTTNNOUFBTmhkekUiLCJleHAiOjE1NTg1OTc3NjgsImlhdCI6MTU1ODU5MDU2OCwiYWlkIjoiN1VfVlgtZnRRclNwRHpSSEgxUXVidyIsImNpZCI6IiJ9.-6MzTVOtn-0lHf7YSInAKXgBj7bg277kwhjEWwiIChY","join_url":"https://ngasce.zoom.us/j/369201743","settings":{"host_video":true,"participant_video":true,"cn_meeting":false,"in_meeting":true,"join_before_host":false,"mute_upon_entry":false,"watermark":false,"use_pmi":false,"approval_type":2,"audio":"voip","auto_recording":"none","enforce_login":false,"enforce_login_domains":"","alternative_hosts":"","close_registration":false,"registrants_confirmation_email":true,"waiting_room":false,"global_dial_in_countries":["US"]}}';
            if(method == 'failed') {
                fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"2015101253010087","TXNAMOUNT":"100.12","STATUS":"TXN_FAILURE","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0"}';
                statusCode = 400;
            }else if(method == 'address') {
                fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
                statusCode = 200;
            }
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(statusCode);
            return res;
        }
    }

    private class RestMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock2());

        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
        
        

        Interview_Slot__c objInterviewSlot = new Interview_Slot__c() ;
        objInterviewSlot.Interview_Date__c =system.today().addDays(5);
        objInterviewSlot.Start_time__c = Time.newInstance(18, 00, 0, 00);
        objInterviewSlot.End_time__c = Time.newInstance(19, 00, 0, 00);
        objInterviewSlot.IntakeAlllowed__c = 4;
        objInterviewSlot.Per_Interview_minutes__c = 20;
        objInterviewSlot.IsActive__c=TRUE;
        objInterviewSlot.Meeting_UserId_1__c = 'Zoom18@nmims.edu';
        objInterviewSlot.Slot_Type__c = 'Counselling';
        objInterviewSlot.Program_Type__c = 'M.Sc. (AI)';
        insert objInterviewSlot;

        objLead.Interview_Date__c = System.today().addDays(5);
        objLead.Time_Range__c = '6:00 PM - 7:00 PM';
        objLead.Interview_Slot__c = objInterviewSlot.id;
        update objLead;

        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.Interview_Date__c = System.today();
        objAccount.Interview_Slot__c = objInterviewSlot.Id;
        objAccount.Interview_Meeting_Id__c = '';
        objAccount.Zoom_Url__c = '';
        // objAccount.nm_Tagged_Pricebook__c = null;
        // objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        update objAccount;
    }
    
    @isTest 
    static void validateRegistration() {

        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            RestMock rest = new RestMock();
            rest.method = 'address';
            Test.setMock(HttpCalloutMock.class, rest);
            Date dt = Date.Today();
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            InterviewScheduleLeadController objnmReg = new InterviewScheduleLeadController();
            objnmReg.getInterviewDate();
            objnmReg.getInterviewTime();
        Test.stopTest();
    }
   
   
    @isTest 
    static void testMethod1() {

        Lead objLead = [SELECT Id,Interview_Date__c,Time_Range__c FROM Lead LIMIT 1];
        Test.startTest();
            RestMock rest = new RestMock();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().put('id',objLead.Id);
            InterviewScheduleLeadController objnmReg = new InterviewScheduleLeadController();

            objnmReg.getInterviewTime = new List<SelectOption>();
            objnmReg.getInterviewDate = new List<SelectOption>();

            objnmReg.objLead.Interview_Date__c = System.today().addDays(5);
            objnmReg.objLead.Time_Range__c = '6:00 PM - 7:00 PM';
            // update objAccount;

            objnmReg.getInterviewDate();
            objnmReg.getInterviewTime();
            objnmReg.getMinutesBetweenStartVsEndTime(Time.newInstance(18, 00, 0, 00),Time.newInstance(19, 00, 0, 00));
            objnmReg.SaveDetail();

            InterviewScheduleSetZoomLinkBatch batchClass = new InterviewScheduleSetZoomLinkBatch();
            Database.executeBatch(batchClass);
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {
        
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',objLead.Id);
            RestMock rest = new RestMock();
            rest.method = 'failed';
            Test.setMock(HttpCalloutMock.class, rest);
            InterviewScheduleLeadController objnmReg = new InterviewScheduleLeadController();

            objnmReg.getInterviewTime = new List<SelectOption>();
            objnmReg.getInterviewDate = new List<SelectOption>();

            objnmReg.objLead.Interview_Date__c= system.today().addDays(5);
            objnmReg.objLead.Time_Range__c = '6:00 PM - 7:00 PM';
            // update objAccount;

            objnmReg.getInterviewDate();
            objnmReg.getInterviewTime();
            objnmReg.getMinutesBetweenStartVsEndTime(Time.newInstance(18, 00, 0, 00),Time.newInstance(19, 00, 0, 00));
            objnmReg.SaveDetail();

            InterviewScheduleSetZoomLinkBatch batchClass = new InterviewScheduleSetZoomLinkBatch();
            Database.executeBatch(batchClass);
        Test.stopTest();
    }
}