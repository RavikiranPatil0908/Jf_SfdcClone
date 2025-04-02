/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 31-08-2024
 * @last modified by  : @BK
**/
@isTest
public class GeocodeControllerTracker {

    @isTest
    static void testProcessGeocodeGoogleSuccess() {
        // Setup mock response for Google Geocode API
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleGeocodeMock());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '94043'; // Example postal code
        String serviceType = 'Google';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertNotEquals(null, result, 'GeocodeResult should not be null');
        System.assertEquals('Mountain View', result.city, 'City should be Mountain View');
        System.assertEquals('California', result.state, 'State should be California');
        System.assertEquals('United States', result.country, 'Country should be United States');
        Test.stopTest();
    }

    @isTest
    static void testProcessGeocodeGoogleSuccess2() {
        // Setup mock response for Google Geocode API
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleGeocodeMock2());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '94043'; // Example postal code
        String serviceType = 'Google';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertNotEquals(null, result, 'GeocodeResult should not be null');
        System.assertEquals('California', result.city, 'City should be California');
        System.assertEquals('California', result.state, 'State should be California');
        System.assertEquals('United States', result.country, 'Country should be United States');
        Test.stopTest();
    }

    @isTest
    static void testProcessGeocodeGoogleSuccess3() {
        // Setup mock response for Google Geocode API
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleGeocodeMock3());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '94043'; // Example postal code
        String serviceType = 'Google';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertNotEquals(null, result, 'GeocodeResult should not be null');
        System.assertEquals('California', result.city, 'City should be California');
        System.assertEquals('', result.state, 'State should be Empty');
        System.assertEquals('United States', result.country, 'Country should be United States');
        Test.stopTest();
    }

    @isTest
    static void testProcessGeocodeGoogleError() {
        // Setup mock response for Google Geocode API
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GoogleGeocodeMockError());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '94043'; // Example postal code
        String serviceType = 'Google';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertEquals('Error', result.postalCodeMessage, 'PostalCodeMessage should be Error');
        Test.stopTest();
    }
    
    @isTest
    static void testProcessGeocodePostalSuccess() {
        // Setup mock response for Postal Code API
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PostalCodeMock());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '94043'; // Example postal code
        String serviceType = 'Postal';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertNotEquals(null, result, 'GeocodeResult should not be null');
        System.assertEquals('Mountain View', result.city, 'City should be Mountain View');
        System.assertEquals('California', result.state, 'State should be California');
        System.assertEquals('United States', result.country, 'Country should be United States');
        System.assertNotEquals('', result.postalCodeMessage, 'PostalCodeMessage should Not be empty');
        Test.stopTest();
    }

    @isTest
    static void testProcessGeocodePostalError() {
        // Setup mock response for Postal Code API
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PostalCodeMockError());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '94043'; // Example postal code
        String serviceType = 'Postal';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertEquals('Error', result.postalCodeMessage, 'PostalCodeMessage should be Error');
        Test.stopTest();
    }

    @isTest
    static void testProcessGeocodeFailure() {
        // Setup mock response for failure scenario
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GeocodeFailureMock());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '00000'; // Example postal code
        String serviceType = 'Google';
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertNotEquals(null, result, 'GeocodeResult should not be null');
        System.assertEquals('', result.city, 'City should be empty');
        System.assertEquals('', result.state, 'State should be empty');
        System.assertEquals('', result.country, 'Country should be empty');
        System.assertEquals('Error', result.postalCodeMessage, 'PostalCodeMessage should be Error');
        Test.stopTest();
    }

    @isTest
    static void testProcessGeocodeFailure2() {
        // Setup mock response for failure scenario
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GeocodeFailureMock());
        
        // Instantiate the controller
        GeocodeController geocodeController = new GeocodeController();
        
        // Define test data
        String postalCode = '00000'; // Example postal code
        String serviceType = null;
        
        // Call the method
        GeocodeResult result = geocodeController.processGeocode(postalCode, serviceType);
        
        // Assert the results
        System.assertNotEquals(null, result, 'GeocodeResult should not be null');
        System.assertEquals('', result.city, 'City should be empty');
        System.assertEquals('', result.state, 'State should be empty');
        System.assertEquals('', result.country, 'Country should be empty');
        System.assertEquals('Error', result.postalCodeMessage, 'PostalCodeMessage should be Error');
        Test.stopTest();
    }
    
    // Mock classes
    private class GoogleGeocodeMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "OK", "results": [{"address_components": [{"long_name": "Mountain View", "types": ["locality"]}, {"long_name": "California", "types": ["administrative_area_level_1"]}, {"long_name": "United States", "types": ["country"]}], "formatted_address": "Mountain View, CA, USA"}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class GoogleGeocodeMock2 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "OK", "results": [{"address_components": [{"long_name": "California", "types": ["administrative_area_level_1"]}, {"long_name": "United States", "types": ["country"]}], "formatted_address": "Mountain View, CA, USA"}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class GoogleGeocodeMock3 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "OK", "results": [{"address_components": [{"long_name": "California", "types": ["administrative_area_level_2"]}, {"long_name": "United States", "types": ["country"]}], "formatted_address": "Mountain View, CA, USA"}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class GoogleGeocodeMockError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "OK", "results": [{"address_components": [{"long_name": "Mountain View", "types": ["locality"]}, {"long_name": "California", "types": ["administrative_area_level_1"]}, {"long_name": "United States", "types": ["country"]}], "formatted_address": "Mountain View, CA, USA"}]}');
            res.setStatusCode(400);
            return res;
        }
    }
    
    private class PostalCodeMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Status": "Success", "PostOffice": [{"Country": "United States", "State": "California", "District": "Mountain View"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    private class PostalCodeMockError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Status": "Error", "PostOffice": [{"Country": "United States", "State": "California", "District": "Mountain View"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class GeocodeFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "ZERO_RESULTS"}');
            res.setStatusCode(200);
            return res;
        }
    }
}