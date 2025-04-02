/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-15-2021   @BK   Initial Version
**/
@IsTest
public class ZestResponseWrapperTracker {
	
	@isTest
	static void testParse() {
		String json=		'{'+
		'    "eventType": "StatusChange",'+
		'    "payload": {'+
		'        "transactionDetails": {'+
		'            "partnerTransactionId": "2021HB78770",'+
		'            "zestTransactionId": "6e2c9b93-6e39-4a45-86df-f6a603bed7ec",'+
		'            "ZestLoanId": "1127439A2933",'+
		'            "basketAmount": 23349.00,'+
		'            "loanAmount": 20000.00,'+
		'            "tenure": 6,'+
		'            "downpaymentAmount": 3300.00,'+
		'            "utr": "AXISCN0070280788",'+
		'            "status": "Settled",'+
		'            "settlementAmount": 70534.57,'+
		'            "settledOnDate": "2021-02-24T11:48:11Z",'+
		'            "key": "75cbbd3f3ce9d2555c4e4d7b326235fd83c7ad438cb20a2c593834ba89ba9add14051753b7fd27cf3e87fe3de25a4e29c335e44ec72c00830dba96e76c9413a6"'+
		'        },'+
		'        "customer": {'+
		'            "name": "FirstName LastName",'+
		'            "email": "XXXXXXXXXX@gmail.com",'+
		'            "mobileNumber": "91XXXXXXXXXX"'+
		'        }'+
		'    }'+
		'}';
		ZestResponseWrapper obj = ZestResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}