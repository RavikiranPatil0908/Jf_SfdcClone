/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-08-2024
 * @last modified by  : @BK
**/
public class GeocodeController {
    public GeocodeResult processGeocode(String postalCode, String serviceType) {
        IGeocodeService geocodeService;
        GeocodeResult result = new GeocodeResult();

        if (serviceType == 'Google') {
            geocodeService = new GoogleGeocodeService();
            result = geocodeService.fetchGeocode(postalCode);
        }
        else if (serviceType == 'Postal') {
            geocodeService = new PostalAPIService();
            result = geocodeService.fetchGeocode(postalCode);
            if(result.postalCodeMessage == 'Error'){
                geocodeService = new GoogleGeocodeService();
                result = geocodeService.fetchGeocode(postalCode);
            }  
        }
         else {
            result.postalCodeMessage = 'Error';
            return result;
        }

        //result = geocodeService.fetchGeocode(postalCode);
        // Process the result as needed
        System.debug(result.city);
        System.debug(result.state);
        System.debug(result.country);
        System.debug(result.postalCodeMessage);
        return result;
    }
}