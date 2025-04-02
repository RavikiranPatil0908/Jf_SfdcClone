/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-18-2024
 * @last modified by  : @BK
**/
public interface IGeocodeService {
    GeocodeResult fetchGeocode(String postalCode);
}