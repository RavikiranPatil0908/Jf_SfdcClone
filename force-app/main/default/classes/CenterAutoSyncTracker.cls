@isTest//(SeeAllData=true)
private class CenterAutoSyncTracker
{
	public static List<CenterAutoSync.CenterActionRequest> lstParam;
	// public static CenterAutoSync.CenterActionRequest requestParam;
	public static nm_Centers__c center;

	private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"code":"200","message":"Success"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

	//Initial Test Data
	//Add Logic to Create data required
	static void SetUp(){

		//setting the Parameters in the request.
		CenterAutoSync.CenterActionRequest requestParam = new CenterAutoSync.CenterActionRequest();
		center = (nm_Centers__c)nmGenericTracker.CreateCenter('Mumbai');
		requestParam.CenterId = center.Id;
		requestParam.CenterName = center.Name;
		requestParam.address = center.nm_City__c;
		requestParam.state = center.nm_StateProvince__c;
		requestParam.city = center.nm_City__c;
		requestParam.LcName = center.CenterName__c;
		requestParam.Active = center.Nm_Active__c;

		lstParam = new List<CenterAutoSync.CenterActionRequest> { requestParam };

		Test.setMock(HttpCalloutMock.class, new RestMock());
		test.StartTest();
	}
	
	//Tear Down 
	//Add Logic to delete data that has been created
	static void TearDown(){
		test.StopTest();
	}
	
	// Test Method: calloutmethod
	public static testmethod void Test_calloutmethod(){
		SetUp();
		
		string jsonresults = JSON.serialize(lstParam);
		// TODO : Add extra code to validate the method call
		CenterAutoSync.calloutmethod(jsonresults);
		TearDown();
	}


}