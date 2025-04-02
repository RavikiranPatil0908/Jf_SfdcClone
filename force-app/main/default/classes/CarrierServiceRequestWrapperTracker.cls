/**
 * @File Name          : CarrierServiceRequestWrapperTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 27/5/2019, 4:38:05 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    27/5/2019, 4:08:34 PM   @BK     Initial Version
**/
@isTest
public class CarrierServiceRequestWrapperTracker {
	static testMethod void unitTest1() {
		String json = '{'+
		'    \"packageId\":\"a1qO0000001pOAnIAM\",'+
		'    \"successURL\": \"www.google.com\",'+
		'    \"failureURL\": \"www.google.com\",'+
		'    \"paymentInitializationId\": \"test\"'+
		'}';
		CarrierServiceRequestWrapper r = CarrierServiceRequestWrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CarrierServiceRequestWrapper objRequest = new CarrierServiceRequestWrapper(System.JSON.createParser(json));
		System.assert(objRequest != null);
		System.assert(objRequest.paymentInitializationId == null);
		System.assert(objRequest.packageId == null);
		System.assert(objRequest.successURL == null);
		System.assert(objRequest.failureURL == null);

	}
	
}