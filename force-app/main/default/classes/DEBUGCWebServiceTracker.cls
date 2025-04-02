/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
@isTest
public class DEBUGCWebServiceTracker {

    @TestSetup
    static void setupTestData() {
        // Creating a test Lead to use its ID in test methods
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    @isTest
    static void testGetStudentDetailsSuccess() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Step 1: Set up mock response
        Test.startTest();

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{' +
                            '"Message": "Data retrival successful.",' +
                            '"Status": "Process Success",' +
                            '"Resource": [' +
                                '{' +
                                    '"StudentID": "345345",' +
                                    '"Program": "",' +
                                    '"email": "test@gmail.com",' +
                                    '"stdname": "test test",' +
                                    '"fathername": "",' +
                                    '"mobile": "9000000001",' +
                                    '"cdate": "Sep  2 2024  6:34PM",' +
                                    '"institutename": "",' +
                                    '"InstituteID": "",' +
                                    '"ipaddress": "192.000.00.37",' +
                                    '"programcode": "000000027388",' +
                                    '"mode": "",' +
                                    '"AdmissionDate": "",' +
                                    '"AdmissionDetails": "",' +
                                    '"UniversityName": "",' +
                                    '"CourseName": "",' +
                                    '"ABCID": "600000000785",' +
                                    '"DEBUniqueID": "090000000088",' +
                                    '"Gender": "Male",' +
                                    '"DOB": "15/06/1991",' +
                                    '"_list": null' +
                                '}' +
                            ']' +
                        '}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DEBUGCWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Call the method to test
        DEBStudentDetailsWrapper result = DEBUGCWebService.getStudentDetails('090000000088', lst[0].Id);

        // Step 2: Assert the results
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals('345345', result.Resource[0].StudentID, 'StudentID should match');
        System.assertEquals('test@gmail.com', result.Resource[0].email, 'Email should match');
        System.assertEquals('test test', result.Resource[0].stdname, 'Student name should match');
        System.assertEquals('9000000001', result.Resource[0].mobile, 'Mobile number should match');
        System.assertEquals('Sep  2 2024  6:34PM', result.Resource[0].cdate, 'Date should match');
        System.assertEquals('000000027388', result.Resource[0].programcode, 'Program code should match');
        System.assertEquals('600000000785', result.Resource[0].ABCID, 'ABC ID should match');
        System.assertEquals('090000000088', result.Resource[0].DEBUniqueID, 'DEB Unique ID should match');
        System.assertEquals('Male', result.Resource[0].Gender, 'Gender should match');
        System.assertEquals('15/06/1991', result.Resource[0].DOB, 'Date of Birth should match');

        Test.stopTest();
    }

    @isTest
    static void testGetStudentDetailsError() {
        List<Lead> lst = [SELECT id FROM Lead LIMIT 1];
        // Step 1: Set up mock response
        Test.startTest();

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"Message":"Invalid API Key","Status":"Process Refused"}');

        // Mocking the HTTP callout
        HttpCalloutMock mock = new DEBUGCWebServiceTracker.MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        // Call the method to test
        DEBStudentDetailsWrapper result = DEBUGCWebService.getStudentDetails('090000000088', lst[0].Id);

        // Step 2: Assert the results
        System.assertEquals(null, result, 'The result should be null');
        Test.stopTest();
    }

    // Helper class to mock HTTP responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse response) {
            mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}