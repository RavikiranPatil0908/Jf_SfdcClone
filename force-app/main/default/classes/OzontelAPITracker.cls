/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-02-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData = false)
public class OzontelAPITracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
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
        nm_Program__c program = nmGenericTracker.CreatePGDiplomaProgram();
        nmGenericTracker.CreateICAndUser(nmGenericTracker.CreateCenter('Mumbai'));
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c = system.today();
        objAccount.PersonMobilePhone = objAccount.PersonMobilePhone.right(10);
        update objAccount;
    }

    @isTest 
    static void unitTest1(){
        List<Account> lstAct = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
        String mobileNo = lstAct[0].PersonMobilePhone;
		Test.startTest();
            String myJSON = '{'+
            '    \"callerph\": \"'+mobileNo+'\"'+
            '}';
            String uri = 'getLCName';
            requestData(myJSON,uri);
            OzontelAPI.show();
		Test.stopTest();
	}

    @isTest 
    static void unitTest2(){
        List<Account> lstAct = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
        String randomNumber = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
        String mobileNo = lstAct[0].PersonMobilePhone+Integer.valueOf(randomNumber);
		Test.startTest();
            String myJSON = '{'+
            '    \"callerph\": \"+91'+mobileNo+'\"'+
            '}';
            String uri = 'getLCName';
            requestData(myJSON,uri);
            OzontelAPI.show();
		Test.stopTest();
	}

    @isTest 
    static void unitTest3(){
        List<Account> lstAct = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
        String mobileNo = lstAct[0].PersonMobilePhone;
		Test.startTest();
            String myJSON = '{'+
            '    \"phone\": \"+91'+mobileNo+'\"'+
            '}';
            String uri = 'getLCName';
            requestData(myJSON,uri);
            OzontelAPI.show();
		Test.stopTest();
	}

    @isTest 
    static void unitTest4(){
        List<Account> lstAct = [SELECT id,PersonMobilePhone FROM Account LIMIT 1];
        String mobileNo = lstAct[0].PersonMobilePhone;
		Test.startTest();
            String myJSON = '[{'+
            '    \"phone\": \"+91'+mobileNo+'\"'+
            '}]';
            String uri = 'getLCName';
            requestData(myJSON,uri);
            OzontelAPI.show();
		Test.stopTest();
	}

    @isTest 
    static void unitTest5(){
        List<Lead> lstLead = [SELECT id,MobilePhone FROM Lead LIMIT 1];
        String mobileNo = lstLead[0].MobilePhone;
		Test.startTest();
            String myJSON = '{'+
            '    \"phone\": \"'+mobileNo+'\"'+
            '}';
            String uri = 'getLCName';
            requestData(myJSON,uri);
            OzontelAPI.show();
		Test.stopTest();
	}

    // @isTest 
    // static void unitTest6(){
    //     List<Lead> lstLead = [SELECT id,MobilePhone FROM Lead LIMIT 1];
    //     lstLead[0].MobilePhone = '7000000000';
    //     update lstLead;
    //     String mobileNo = lstLead[0].MobilePhone;
	// 	Test.startTest();
    //         String myJSON = '{'+
    //         '    \"phone\": \"'+mobileNo+'\"'+
    //         '}';
    //         String uri = 'getLCName';
    //         requestData(myJSON,uri);
    //         OzontelAPI.show();
	// 	Test.stopTest();
	// }

    public static void requestData(String myJson,String uri) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requesturi = 'https://services/apexrest/Ozontel/'+uri;
		request.requestBody = Blob.valueof(myJSON);
		RestContext.request = request;
		RestContext.response = response;
    }
}