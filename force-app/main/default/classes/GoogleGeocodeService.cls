/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-08-2024
 * @last modified by  : @BK
**/
public class GoogleGeocodeService implements IGeocodeService {

    /**
     * Fetches geocode information for a given postal code using the Google Geocode API.
     * 
     * @param postalCode The postal code for which geocode information is requested.
     * @return GeocodeResult An object containing geocode information including city, state, country, and any error messages.
     */
    public GeocodeResult fetchGeocode(String postalCode) {
        GeocodeResult result = new GeocodeResult();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        try {
            // Build the URL for the Google Geocode API request
            String uri = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + postalCode + '&key=' + System.Label.GeocodeApIKey;
            request.setEndpoint(uri);
            request.setMethod('GET');
            
            // Send the HTTP request
            response = http.send(request);

            // Check the HTTP response status
            if (response.getStatusCode() == 200) {
                // Parse the response body and extract geocode information
                result = parseGeocodeResponse(response.getBody());
            } else {
                // Handle HTTP errors
                result.postalCodeMessage = 'Error';
            }
        } catch (Exception e) {
            // Handle exceptions that occur during the HTTP request or processing
            result.postalCodeMessage = 'Error';
            System.debug('Exception occurred: ' + e.getMessage());
        }

        return result;
    }

    /**
     * Parses the response body from the Google Geocode API.
     * 
     * @param responseBody The response body from the API call.
     * @return GeocodeResult An object containing geocode information parsed from the response.
     */
    private GeocodeResult parseGeocodeResponse(String responseBody) {
        GeocodeResult result = new GeocodeResult();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String status = (String) responseMap.get('status');

        // Check if the API response status is 'OK'
        if (status == 'OK') {
            List<Object> results = (List<Object>) responseMap.get('results');
            Map<String, Object> addressResult = (Map<String, Object>) results[0];
            List<Object> addressComponents = (List<Object>) addressResult.get('address_components');
            
            // Extract relevant address components
            result = extractAddressComponents(addressComponents);
            result.postalCodeMessage = 'Success';
        } else {
            // Handle API-specific errors
            result.postalCodeMessage = 'Error';
        }

        return result;
    }

    /**
     * Extracts address components from the API response.
     * 
     * @param addressComponents List of address components from the API response.
     * @return GeocodeResult An object containing extracted address information.
     */
    private GeocodeResult extractAddressComponents(List<Object> addressComponents) {
        GeocodeResult result = new GeocodeResult();
        Boolean isLocalNamePresent = false;
        Boolean isAdministerAreaLevel2Present = false;

        // Iterate through the address components to find city, state, and country
        for (Object address : addressComponents) {
            Map<String, Object> addressMap = (Map<String, Object>) address;
            List<Object> types = (List<Object>) addressMap.get('types');

            // Determine city based on address types
            if (types.contains('locality')) {
                isLocalNamePresent = true;
                result.city = (String) addressMap.get('long_name');
            }
            if (types.contains('administrative_area_level_2') && !isLocalNamePresent) {
                isAdministerAreaLevel2Present = true;
                result.city = (String) addressMap.get('long_name');
            }
            if (types.contains('administrative_area_level_1')) {
                result.state = (String) addressMap.get('long_name');
                if (!isLocalNamePresent && !isAdministerAreaLevel2Present) {
                    result.city = (String) addressMap.get('long_name');
                }
            }
            if (types.contains('country')) {
                result.country = (String) addressMap.get('long_name');
            }
        }

        return result;
    }
}