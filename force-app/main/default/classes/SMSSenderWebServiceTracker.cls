@isTest(SeeAllData=false)
private class SMSSenderWebServiceTracker {

    // Inner class to mock HTTP callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public String type;
        MockHttpResponseGenerator() {
            type ='';
        }

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            if(type == 'SendSMSTransactional') {
                fullJson = '{"status": "ok"}';
            } else if(type == 'NetcoreSMSTransactional') {
                fullJson = '<RESULT REQID =\'17616498555\'><MID SUBMITDATE=\'2018-11-21 17:04:15\' ID=\'1\' TAG =\'null\' TID =\'45644011370\'></MID></RESULT>';
            } 

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendmGageSMS() {

        Test.startTest();
        // Test data
        String mobileNumber = '1234567890';
        String msg = 'Test message';

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the web service method
        String result = SMSSenderWebService.sendmGageSMS(mobileNumber, msg);

        // Assert the result
        System.assertEquals('', result, 'Unexpected result');
        Test.stopTest();
    }

    @isTest
    static void testSendSMSTransactional() {
        
        Test.startTest();
            // Test data
            String mobileNumber = '1234567890';
            String msg = 'Test message';

            // Mock HTTP callout
            MockHttpResponseGenerator rest = new MockHttpResponseGenerator();
            rest.type = 'SendSMSTransactional';
            Test.setMock(HttpCalloutMock.class, rest);

            // Call the web service method
            String result = SMSSenderWebService.sendSMSTransactional(mobileNumber, msg);

            // Assert the result
            System.assertEquals('{"status" : "ok"}', result, 'Unexpected result');
        Test.stopTest();
    }

    @isTest
    static void testSendSMSPromotional() {
        
        Test.startTest();
            // Test data
            String mobileNumber = '1234567890';
            String msg = 'Test message';

            // Mock HTTP callout
            MockHttpResponseGenerator rest = new MockHttpResponseGenerator();
            rest.type = 'SendSMSTransactional';
            Test.setMock(HttpCalloutMock.class, rest);

            // Call the web service method
            String result = SMSSenderWebService.sendSMSPromotional(mobileNumber, msg);

            // Assert the result
            System.assertEquals('', result, 'Unexpected result');
        Test.stopTest();
    }

    @isTest
    static void testNetcoreSMSTransactional() {
        
        Test.startTest();
            // Test data
            String mobileNumber = '1234567890';
            String msg = 'Test message';

            // Mock HTTP callout
            MockHttpResponseGenerator rest = new MockHttpResponseGenerator();
            rest.type = 'NetcoreSMSTransactional';
            Test.setMock(HttpCalloutMock.class, rest);

            // Call the web service method
            String result = SMSSenderWebService.NetcoreSMSTransactional(mobileNumber, msg);
            String tid = SMSSenderWebService.xmlparser('<RESULT REQID =\'17616498555\'><MID SUBMITDATE=\'2018-11-21 17:04:15\' ID=\'1\' TAG =\'null\' TID =\'45644011370\'></MID></RESULT>');

            // Assert the result
            System.assertEquals('{"status" : "ok"}', result, 'Unexpected result');
            System.assertEquals('45644011370', tid, 'Unexpected tid');
        Test.stopTest();
    }

    @isTest
    static void testSendSMSAfterDispatchOrderCreated() {
        
        Test.startTest();
            // Test data
            String mobileNumber = '1234567890';
            String msg = 'Test message';

            // Mock HTTP callout
            MockHttpResponseGenerator rest = new MockHttpResponseGenerator();
            rest.type = 'SendSMSTransactional';
            Test.setMock(HttpCalloutMock.class, rest);

            // Call the web service method
            String result = SMSSenderWebService.sendSMSAfterDispatchOrderCreated(mobileNumber, msg, 'test');

            // Assert the result
            System.assertEquals('', result, 'Unexpected result');
        Test.stopTest();
    }
}