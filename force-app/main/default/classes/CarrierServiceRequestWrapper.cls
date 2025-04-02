/**
 * @File Name          : CarrierServiceRequestWrapper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 27/5/2019, 4:04:34 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/5/2019, 2:05:14 PM   @BK     Initial Version
**/
public class CarrierServiceRequestWrapper {

	public String packageId {get;set;} 
	public String successURL {get;set;}
	public String failureURL {get;set;}
	public String paymentInitializationId {get;set;}

	public CarrierServiceRequestWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'packageId') {
						packageId = parser.getText();
					} else if (text == 'successURL') {
						successURL = parser.getText();
					} else if (text == 'failureURL') {
						failureURL = parser.getText();
					} else if (text == 'paymentInitializationId') {
						paymentInitializationId = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'CarrierServiceRequestWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public static CarrierServiceRequestWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CarrierServiceRequestWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

}