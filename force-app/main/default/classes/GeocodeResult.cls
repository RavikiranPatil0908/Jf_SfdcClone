/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-18-2024
 * @last modified by  : @BK
**/
public class GeocodeResult {
    public String city { get; set; }
    public String state { get; set; }
    public String country { get; set; }
    public String postalCodeMessage { get; set; }

    public GeocodeResult() {
        this.city = '';
        this.state = '';
        this.country = '';
        this.postalCodeMessage = '';
    }
}