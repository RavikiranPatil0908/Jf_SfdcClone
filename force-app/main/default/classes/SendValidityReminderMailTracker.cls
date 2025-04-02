/**
 * @File Name          : SendValidityReminderMailTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 25/11/2019, 5:11:04 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/11/2019   @BK     Initial Version
**/
@isTest
public with sharing class SendValidityReminderMailTracker {
    
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){

        Integer currentYear = System.Today().year();
        Integer findInWhichHalf = System.Today().month() / 6; 
        Date newDate = System.Today().addYears(-1);
        Integer previousYear = newDate.year();
        String validityUpto = 'Jun '+String.valueOf(currentYear);
        String validityUptoPR = 'Dec '+String.valueOf(previousYear);
        if(findInWhichHalf > 0) {
            validityUpto = 'Dec '+String.valueOf(currentYear);
        }
        System.debug('findInWhichHalf ==>'+findInWhichHalf);

        Test.setMock(HttpCalloutMock.class, new RestMock());

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.Selection_AdmissionDate__c= system.today();
        objAccount.Selection_InitialDate__c= system.today();
        objAccount.Interview_Status__c = 'Selected';
        objAccount.nmCaptureOpportuntiyStage__c ='Closed Won';
        objAccount.ValidUptoR__c = validityUpto;
        update objAccount;


        Account objAccount2 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount2.Selection_AdmissionDate__c= system.today();
        objAccount2.Selection_InitialDate__c= system.today();
        objAccount2.Interview_Status__c = 'Selected';
        objAccount2.nmCaptureOpportuntiyStage__c ='Closed Won';
        objAccount2.ValidUptoR__c = validityUptoPR;
        update objAccount2;
    }

    @isTest 
    static void testFailureBatch(){
        Test.startTest();
            SendValidityReminderMail batchClass = new SendValidityReminderMail();
            Database.executeBatch(batchClass,100);

            SendValidityExpiredReminderMail batchClass2 = new SendValidityExpiredReminderMail();
            Database.executeBatch(batchClass2,100);
        Test.stopTest();
    }
    
    
}