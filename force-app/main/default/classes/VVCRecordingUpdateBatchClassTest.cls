/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
private class VVCRecordingUpdateBatchClassTest {
    
    // Mock class for HTTP callout
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true, "message": "Video uploaded successfully"}');
            return res;
        }
    }

    @TestSetup
    static void testBatchExecution() {
        String gsRecordTypeID = Schema.SObjectType.Schedule_Time_Slot__c.getRecordTypeInfosByName().get('Video Call').getRecordTypeId();
        Schedule_Time_Slot__c objSlot = new Schedule_Time_Slot__c(Start_time__c = Time.newInstance(9,0,0,0), End_time__c = Time.newInstance(19,0,0,0), IsActive__c=true, RecordTypeId = gsRecordTypeID, Per_Call_Schedule_Minutes__c = 15, Start_date__c=System.today().addDays(-2), End_date__c=System.today().addDays(5), Recurrence__c = 'Daily',  Zoom_Id__c = 'Zoom51@nmims.edu',Selected_Counselors__c = 'Anjali Mishra; Ablena Mysa; Abishek Vitta');
        insert objSlot;

        // Insert test records into VVC_Junction__c
        List<VVC_Junction__c> vvcRecords = new List<VVC_Junction__c>();
        for (Integer i = 0; i < 5; i++) {
            VVC_Junction__c vvc = new VVC_Junction__c(
                Status__c = 'Completed',
                Meeting_Id__c = '123456' + i,
                Schedule_Call_Time__c = System.now().addHours(-4), // Past time
                Schedule_Time_Slot__c = objSlot.Id,
                Call_Date__c = System.today().addDays(-1)
            );
            vvcRecords.add(vvc);
        }
        insert vvcRecords;
    }

    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        
       // Set mock response for HTTP callout
       Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

       // Execute the batch class
       VVCRecordingUpdateBatchClass batchInstance = new VVCRecordingUpdateBatchClass();
       Database.executeBatch(batchInstance, 200);

       Test.stopTest();
    }
}