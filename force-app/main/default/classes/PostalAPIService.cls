/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-18-2024
 * @last modified by  : @BK
**/
public class PostalAPIService implements IGeocodeService {

    public GeocodeResult fetchGeocode(String postalCode) {
        GeocodeResult result = new GeocodeResult();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try {
            String uri = Label.PostalCodeAPI + postalCode;
            request.setEndPoint(uri);
            request.setHeader('Access-Control-Allow-Origin', '*');
            request.setMethod('GET');
            
            response = http.send(request);
            
            String resultBody = response.getBody();
            List<Object> lstOfApiResponse = (List<Object>) JSON.deserializeUntyped(resultBody);
            Map<String, Object> mapOfAPIResponse = (Map<String, Object>) lstOfApiResponse[0];
            
            if (mapOfAPIResponse.get('Status') == 'Success') {
                List<Object> postalOffice = (List<Object>) mapOfAPIResponse.get('PostOffice');
                Map<String, Object> mapOfAPIResponseParam = (Map<String, Object>) postalOffice[0];
                
                result.country = (String) mapOfAPIResponseParam.get('Country');
                result.state = (String) mapOfAPIResponseParam.get('State');
                result.city = (String) mapOfAPIResponseParam.get('District');
                
                result.postalCodeMessage = String.valueOf(mapOfAPIResponse.get('Status'));
            } else {
                result.postalCodeMessage = String.valueOf(mapOfAPIResponse.get('Status'));
            }
        } catch (Exception e) {
            // Handle exceptions that occur during the HTTP request or processing
            result.postalCodeMessage = 'Error';
            System.debug('Exception occurred: ' + e.getMessage());
        }
        return result;
    }
}