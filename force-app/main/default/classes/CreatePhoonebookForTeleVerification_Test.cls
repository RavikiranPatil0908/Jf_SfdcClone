@isTest
public with sharing class CreatePhoonebookForTeleVerification_Test {

    @TestSetup
    public static void setUpData(){
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_Year__c = 2021;
        
        update objLead;

        KnowlarityAPI__c objKnowlarityAPI =  new KnowlarityAPI__c();
        objKnowlarityAPI.x_api_key__c = 'Fc6M9Fgf4z9sLDva8guyv4UZwsfz8MoJakPHHibW';
        objKnowlarityAPI.IVR_ID__c = '1000066590';
        objKnowlarityAPI.authorization__c = '3659882c-b6ad-4039-b397-9853b4f8cd6d';
        objKnowlarityAPI.k_number__c = '+918035362688';
        objKnowlarityAPI.PhonebookAPI_URL__c = 'https://kpi.knowlarity.com/Basic/v1/account/contacts/phonebook';
        objKnowlarityAPI.Name = 'KnowlarityAPIData';
        objKnowlarityAPI.Add_Call_To_Order_URL__c = 'https://kpi.knowlarity.com/Basic/v1/account/call-center/add_call_to_order';
        objKnowlarityAPI.OutboundAPI_URL__c='https://kpi.knowlarity.com/Basic/v1/account/call/campaign';
        insert objKnowlarityAPI;
    }
    

    public class RestMock implements HttpCalloutMock {
    HttpResponse[] responses = new HttpResponse[0];
    public void addResponse(HttpResponse response) {
        responses.add(response);
    }
    public HttpResponse respond(HttpRequest request) {
        return responses.remove(0);
    }


}

      public class RestMockII implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"result": "call added successfully","Status_code":1}');
            response.setStatusCode(200);
            return response; 
        }
    }
      public class RestMockIII implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"msg": ["Successfully added phonebook"],"id": "<Phonebook_id>"}');
            response.setStatusCode(200);
            return response; 
        }
    }

    @isTest
    static void testPostCallout1() {
        // Campaign_Call__c campaignCall = new Campaign_Call__c();
        // campaignCall.Id = campaignId;
        // campaignCall.Order_Id__c = OrderId;
        // campaignCall.Order_Start_Date__c =  DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 09, 0, 0);
        // campaignCall.Order_End_Date__c =  DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() , 19, 0, 0);
        // insert campaignCall;


        // RestMock mock = new RestMock();
        // HttpResponse res1 = new HttpResponse();
        // res1.setHeader('Content-Type', 'application/json');
        // res1.setBody('{"msg": ["Successfully added phonebook"],"id": "<Phonebook_id>"}');
        // res1.setStatusCode(200);
        // mock.addResponse(res1);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockIII());
        CreatePhonebookForTeleVerification instance = new CreatePhonebookForTeleVerification();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }


    @isTest
    static void testcaa() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockIII());
        CreatePhonebookForTeleVerification instance = new CreatePhonebookForTeleVerification();
        instance.postPhoneBookApiResult('{"numbers":"+918377985721","phonebookname":"AfgSCE-d35ee906-fc38"}');
        Test.stopTest();
    }

    @isTest
    static void testPostCallout5() {
        Test.startTest();
        RestMockII rest = new RestMockII();
        Test.setMock(HttpCalloutMock.class, rest);

        // Lead objLead = [Select Id From Lead LIMIT 1];
        // objLead.Knowlarity_Attempt__c = '1-morning';
        // update objLead;
        DateTime myDateTime = DateTime.now();

        Campaign_Call__c campaignCall = new Campaign_Call__c();
        campaignCall.Order_Id__c = 'OrderId';
        campaignCall.Phone_Id__c = 'PhoneId';
        campaignCall.Phonebook_Name__c = 'phoneBookName';
        campaignCall.Order_Start_Date__c = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day()-2);
        campaignCall.Order_End_Date__c = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() + 2);
        campaignCall.Type_Of_Object__c	 = 'Knowlarity';
        insert campaignCall;

        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
    @isTest
    static void testPostCallout6() {
        Test.startTest();
        RestMockII rest = new RestMockII();
        Test.setMock(HttpCalloutMock.class, rest);

        // Lead objLead = [Select Id From Lead LIMIT 1];
        // objLead.Knowlarity_Attempt__c = '1-morning';
        // update objLead;
        DateTime myDateTime = DateTime.now();

        Campaign_Call__c campaignCall = new Campaign_Call__c();
        campaignCall.Phone_Id__c = 'PhoneId';
        campaignCall.Phonebook_Name__c = 'phoneBookName';
        campaignCall.Order_Start_Date__c = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day()-2);
        campaignCall.Order_End_Date__c = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() + 2);
        campaignCall.Type_Of_Object__c	 = 'Knowlarity';
        insert campaignCall;

        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
    @isTest
    static void testPostCallout2() {
        Lead objLead = [Select Id From Lead LIMIT 1];
        objLead.Knowlarity_Attempt__c = '1-morning';
        update objLead;
        Test.startTest();
        RestMock mock = new RestMock();
        HttpResponse res1 = new HttpResponse();
        // fill out values here
        res1.setHeader('Content-Type', 'application/json');
        // response.setBody('{"phonebookname" : "<phonebookname>","numbers":"+91XXXXXXXXXX;+91XXXXXXXXXX"}');
        res1.setBody('{"msg": ["Successfully added phonebook"],"id": "<Phonebook_id>"}');
        res1.setStatusCode(200);


        HttpResponse res2 = new HttpResponse();
        // fill out values here
        res2.setHeader('Content-Type', 'application/json');
        res2.setBody('{"order_id": "order_id","result": "placed order successfully","status_code": 1}');
        res2.setStatusCode(200);
        mock.addResponse(res1);
        mock.addResponse(res2);
        Test.setMock(HttpCalloutMock.class, mock);


        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
    @isTest
    static void testPostCallout3() {
        Lead objLead = [Select Id From Lead LIMIT 1];
        objLead.Knowlarity_Attempt__c = '1-morning,1-afternoon';
        update objLead;
        Test.startTest();
        RestMock mock = new RestMock();
        HttpResponse res1 = new HttpResponse();
        // fill out values here
        res1.setHeader('Content-Type', 'application/json');
        // response.setBody('{"phonebookname" : "<phonebookname>","numbers":"+91XXXXXXXXXX;+91XXXXXXXXXX"}');
        res1.setBody('{"msg": ["Successfully added phonebook"],"id": "<Phonebook_id>"}');
        res1.setStatusCode(200);


        HttpResponse res2 = new HttpResponse();
        // fill out values here
        res2.setHeader('Content-Type', 'application/json');
        res2.setBody('{"order_id": "order_id","result": "placed order successfully","status_code": 1}');
        res2.setStatusCode(200);
        mock.addResponse(res1);
        mock.addResponse(res2);
        Test.setMock(HttpCalloutMock.class, mock);


        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
    @isTest
    static void testPostCallout4() {
        Lead objLead = [Select Id From Lead LIMIT 1];
        objLead.Knowlarity_Attempt__c = '1-morning,1-afternoon,1-morning,2-afternoon';
        update objLead;
        Test.startTest();
        RestMock mock = new RestMock();
        HttpResponse res1 = new HttpResponse();
        // fill out values here
        res1.setHeader('Content-Type', 'application/json');
        // response.setBody('{"phonebookname" : "<phonebookname>","numbers":"+91XXXXXXXXXX;+91XXXXXXXXXX"}');
        res1.setBody('{"msg": ["Successfully added phonebook"],"id": "<Phonebook_id>"}');
        res1.setStatusCode(200);


        HttpResponse res2 = new HttpResponse();
        // fill out values here
        res2.setHeader('Content-Type', 'application/json');
        res2.setBody('{"order_id": "order_id","result": "placed order successfully","status_code": 1}');
        res2.setStatusCode(200);
        mock.addResponse(res1);
        mock.addResponse(res2);
        Test.setMock(HttpCalloutMock.class, mock);


        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }


    @isTest
    static void testPostCall() {
        Test.startTest();
        RestMock mock = new RestMock();
        HttpResponse res2 = new HttpResponse();
        res2.setHeader('Content-Type', 'application/json');
        res2.setBody('{"order_id": "order_id","result": "placed order successfully","status_code": 1}');
        res2.setStatusCode(200);
        mock.addResponse(res2);
        Test.setMock(HttpCalloutMock.class, mock);


        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        instance.postOutBoundApiResult('vjhvj');
        Test.stopTest();
    }
    @isTest
    static void testPostCall1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        TeleVerificationBatchClassClone instance = new TeleVerificationBatchClassClone();
        instance.putAddCallToOrder('gug');
        Test.stopTest();
    }




}