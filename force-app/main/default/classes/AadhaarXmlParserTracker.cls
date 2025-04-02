/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 14-09-2024
 * @last modified by  : @BK
**/
@isTest
private class AadhaarXmlParserTracker {

    @isTest
    static void testFetchAndParseXmlValidXml() {
        // Setup mock response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
            '<Certificate>' +
            '  <CertificateData>' +
            '    <KycRes code="test" ret="Y" ts="2024-04-27T15:53:00.930+05:30"' +
            '      ttl="2025-04-27T15:53:00" txn="UKC:test">' +
            '      <UidData tkn="test"' +
            '        uid="xxxxxxxx3440">' +
            '        <Poi dob="21-09-1997" gender="F" name="test test" />' +
            '        <Pht>test</Pht>' +
            '      </UidData>' +
            '    </KycRes>' +
            '  </CertificateData>' +
            '</Certificate>'
        ));
        AadhaarXmlParser.ExtractedData result = AadhaarXmlParser.fetchAndParseXml('https://example.com/xmlfile');
        Test.stopTest();

        // Assertions to verify the expected output
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('test', result.pht, 'Pht value should be "test"');
        System.assertEquals('test test', result.name, 'Name value should be "test test"');
        System.assertEquals('21-09-1997', result.dob, 'DOB value should be "21-09-1997"');
    }

    @isTest
    static void testFetchAndParseXmlEmptyResponse() {
        // Setup mock response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(''));
        AadhaarXmlParser.ExtractedData result = AadhaarXmlParser.fetchAndParseXml('https://example.com/xmlfile');
        Test.stopTest();

        // Assertions to verify the expected output
        System.assertEquals(null, result, 'Result should be null for empty XML');
    }

    @isTest
    static void testFetchAndParseXmlInvalidXml() {
        // Setup mock response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
            '<Certificate>' +
            '  <CertificateData>' +
            '    <KycRes code="test" ret="Y" ts="2024-04-27T15:53:00.930+05:30"' +
            '      ttl="2025-04-27T15:53:00" txn="UKC:test">' +
            '      <!-- Missing UidData element -->' +
            '    </KycRes>' +
            '  </CertificateData>' +
            '</Certificate>'
        ));
        AadhaarXmlParser.ExtractedData result = AadhaarXmlParser.fetchAndParseXml('https://example.com/xmlfile');
        Test.stopTest();

        // Assertions to verify the expected output
        System.assertEquals(null, result, 'Result should be null');
    }

    @isTest
    static void testFetchAndParseXmlHttpError() {
        // Setup mock response for HTTP error
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        AadhaarXmlParser.ExtractedData result = AadhaarXmlParser.fetchAndParseXml('https://example.com/xmlfile');
        Test.stopTest();

        // Assertions to verify the expected output
        System.assertEquals(null, result, 'Result should be null for HTTP errors');
    }

    @isTest
    static void testFetchAndParseXmlInvalidLink() {
        // Setup mock response for HTTP error
        Test.startTest();
        AadhaarXmlParser.ExtractedData result = AadhaarXmlParser.fetchAndParseXml('');
        Test.stopTest();

        // Assertions to verify the expected output
        System.assertEquals(null, result, 'Result should be null for Links missing');
    }
    
    // Mock class to generate HTTP responses for testing
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;
        private String status;

        MockHttpResponseGenerator(String responseBody) {
            this.responseBody = responseBody;
            this.statusCode = 200;
            this.status = 'OK';
        }

        MockHttpResponseGenerator(Integer statusCode, String status) {
            this.responseBody = '';
            this.statusCode = statusCode;
            this.status = status;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            res.setStatus(status);
            return res;
        }
    }
}