@isTest(SeeAllData=false)
public class BatchClassForOzontelCustomerHoldTraker {

    public static String dateTimeValue = '2024-03-07 17:45:47.000';

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            DateTime startDate = System.now().addDays(-1);
            DateTime endDate = System.now().addDays(-1).addMinutes(5);
            String fullJson ='{ "status": 1, "message": "Success", "data": [ { "UCID": "24709813702508135", "Campaign Name": "Inbound_912250645726", "Caller No": "+00918369389877", "Agent ID": "SanaMukhi", "Call Start Time": "2024-03-07 17:45:47.000", "Hold Start Time": "2024-03-07 17:48:24.000", "Hold End Time": "2024-03-07 17:48:28.000", "Hold Duration": "00:00:04", "Hold Started After Call": "10:02:37", "Hold Ended After Call": "00:02:41" }]}';
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
            BatchClassForOzontelCustomerHoldDetails batchClass = new BatchClassForOzontelCustomerHoldDetails();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }

    @isTest 
    static void unitTest2() {
        DateTime startDate = System.now().addDays(-1);
        Account objAccount = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
        Task objTask = new Task(Subject='Call Scheduling', Status='Connected', Priority='Normal',  WhatId=objAccount.Id, Call_date__c=startDate.date(), Customer_number__c=objAccount.PersonMobilePhone, Actual_Call_Date__c=startDate, Schedule_Call_Time__c = DateTime.valueOf(dateTimeValue));
        insert objTask;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            BatchClassForOzontelCustomerHoldDetails batchClass = new BatchClassForOzontelCustomerHoldDetails();
            Database.executeBatch(batchClass,200);
        Test.stopTest();
    }
}