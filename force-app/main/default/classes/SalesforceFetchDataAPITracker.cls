/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-25-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01-25-2021   @BK   Initial Version
**/
@isTest(SeeAllData = false)
public class SalesforceFetchDataAPITracker {
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

    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        nmGenericTracker.InsertSerialNo();
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccount.nm_StudentNo__c = '77214000953';
        update objAccount;
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }


    /**
    * @description 
    * @author @BK | 01-25-2021 
    * @return testMethod 
    **/
    static testMethod void unitTest1(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"email":"'+objAccount.PersonEmail+'","mobile":"'+objAccount.PersonMobilePhone+'","program":"Master Programs","name":"Test Test","city":"Delhi"}';
        String URI = 'getRecord';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }


    /**
    * @description 
    * @author @BK | 01-25-2021 
    * @return testMethod 
    **/
    static testMethod void unitTest2(){
        Lead objLead = [Select id,Email,MobilePhone from Lead Limit 1];
        Test.startTest();
        String myJSON = '{"email":"'+objLead.Email+'","mobile":"'+objLead.MobilePhone+'","program":"Master Programs","name":"Test Test","city":"Delhi"}';
        String URI = 'getRecord';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }

    /**
    * @description 
    * @author @BK | 01-25-2021 
    * @return testMethod 
    **/
    static testMethod void unitTest3(){
        Test.startTest();
        String myJSON = '{"email":"test@gmail.com","mobile":"7541236580","name":"Test Test","city":"Delhi"}';
        String URI = 'getRecord';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }

    static testMethod void unitTest4(){
        Test.startTest();
        String myJSON = '{"email":"test@gmail.com","mobile":"7541236580","name":"Test Test","city":"Delhi"}';
        String URI = 'getRecords';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
    static testMethod void unitTest5(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"AccountId":"'+objAccount.Id+'"}';
        String URI = 'getDocuments';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
     static testMethod void unitTest6(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"AccountId":"'+objAccount.Id+'"}';
        String URI = 'getRefund';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
    static testMethod void unitTest7(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"AccountId":"'+objAccount.Id+'"}';
        String URI = 'getDispatchOrder';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
    static testMethod void unitTest8(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"AccountId":"'+objAccount.Id+'"}';
        String URI = 'getLatestOpportunity';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
    static testMethod void unitTest9(){
        Lead objLead = [Select id,Email,MobilePhone from Lead Limit 1];
        Test.startTest();
        String myJSON = '{"whoId": "'+objLead.id+'","ReminderDateTime": "11/11/2021 08:00 AM","Subject": "Meeting"}';
        String URI = 'CreateTask';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
     static testMethod void unitTest10(){
        Test.startTest();
        String myJSON = '{"Email":"kria771@gmail.com","Phone":"8833232891","Subject":"Master Programs","Description":"Test Test","Name":"Delhi"}';
        String URI = 'CreateCase';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
    static testMethod void unitTest11(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"Subject": "Master Programs","Description": "Test Test","AccountId": "'+objAccount.Id+'"}';
        String URI = 'CreateCase';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
    static testMethod void unitTest12(){
        Account objAccount = [Select id,PersonEmail,PersonMobilePhone from Account Limit 1];
        Test.startTest();
        String myJSON = '{"whoId": "'+objAccount.Id+'","ReminderDateTime": "11/11/2021 08:00 AM","Subject": "Meeting"}';
        String URI = 'CreateTask';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }

    static testMethod void unitTest13(){
        Account objLead = [Select id,nm_StudentNo__c from Account Limit 1];
        Test.startTest();
        String myJSON = '{"SapId":"'+objLead.nm_StudentNo__c+'"}';
        String URI = 'getRecordBySapId';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }
     static testMethod void unitTest14(){
        Lead objLead = [Select id,Email,MobilePhone from Lead Limit 1];
        Test.startTest();
        String myJSON = '{"email":"'+objLead.Email+'","mobile":"'+objLead.MobilePhone+'"}';
        String URI = 'getRecordFromEmailAndMobile';
        RequestData(myJSON,URI);
        SalesforceFetchDataAPI.show();
        Test.stopTest();
    }

    public static void RequestData(String myJson,String URI) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://services/apexrest/salesforceFetchData/'+URI;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }
}