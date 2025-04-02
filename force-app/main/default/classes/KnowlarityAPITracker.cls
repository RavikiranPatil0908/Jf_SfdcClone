/**
 * @File Name          : KnowlarityAPITracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-03-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    10/8/2019, 11:00:01 AM         @BK                    Initial Version
**/
@isTest(SeeAllData = false)
private class KnowlarityAPITracker {

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
    }

    @isTest 
    static void unitTest1(){
		Test.startTest();
		String myJSON = '{'+
        '    \"callerph\": \"+919769901516\"'+
        '}';
		String uri = 'getSalesforceLeads';
		requestData(myJSON,uri);
        KnowlarityAPI.show();
		Test.stopTest();
	}

    @isTest
    static void unitTest2(){
		Test.startTest();
		String myJSON = '{'+
        '    \"callerph\": \"+918377985721\"'+
        '}';
		String uri = 'getSalesforceLeads';
		requestData(myJSON,uri);
        KnowlarityAPI.show();
		Test.stopTest();
	}

    @isTest
    static void unitTest3(){
		Test.startTest();
		String myJSON = '{'+
        '    \"callerp\": \"+918377985721\"'+
        '}';
		String uri = 'getSalesforceLeads';
		requestData(myJSON,uri);
        KnowlarityAPI.show();
		Test.stopTest();
	}

    @isTest
    static void unitTest4(){
		Test.startTest();
		String myJSON = '{'+
        '    \"callerp\": \"+918377985721\"'+
        '}';
		String uri = 'getSalesforceLeads';
		requestData(myJSON,uri);
        KnowlarityAPI.show();
		Test.stopTest();
    }
    
    /* ---------------------------------- For Regional API ------------------------------------------------*/ 
    @isTest 
    static void unitTest5(){
		Test.startTest();
		String myJSON = '{'+
        '    \"customerph\": \"9769901516\"'+
        '}';
		String uri = 'getRegionalNo';
		requestData(myJSON,uri);
        KnowlarityRoutingAPI.show();
		Test.stopTest();
	}

    @isTest
    static void unitTest6(){
		Test.startTest();
		String myJSON = '{'+
        '    \"customerph\": \"8377985721\"'+
        '}';
		String uri = 'getRegionalNo';
		requestData(myJSON,uri);
        KnowlarityRoutingAPI.show();
		Test.stopTest();
	}

    @isTest
    static void unitTest7(){
		Test.startTest();
		String myJSON = '{'+
        '    \"customerp\": \"8377985721\"'+
        '}';
		String uri = 'getRegionalNo';
		requestData(myJSON,uri);
        KnowlarityRoutingAPI.show();
		Test.stopTest();
	}

    @isTest
    static void unitTest8(){
		Test.startTest();
		String myJSON = '{'+
        '    \"customerp\": \"8377985721\"'+
        '}';
		String uri = 'getRegionalNo';
		requestData(myJSON,uri);
        KnowlarityRoutingAPI.show();
		Test.stopTest();
	}


    public static void requestData(String myJson,String uri) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requesturi = 'https://services/apexrest/Knowlarity/'+uri;
		request.requestBody = Blob.valueof(myJSON);
		RestContext.request = request;
		RestContext.response = response;
    }
}