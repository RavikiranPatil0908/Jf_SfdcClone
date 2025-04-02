/**
 * @File Name          : PaytmRefundResponseWrapperTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/2/2020, 3:11:32 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/2/2020   @BK     Initial Version
**/
@IsTest
public class PaytmRefundResponseWrapperTracker {
	
	static testMethod void testParse() {
		String json = '{'+
        '    \"head\": {'+
        '        \"clientId\": \"C11\",'+
		'        \"responseTimestamp\": \"1567421120859\",'+
		'        \"signature\": \"WaFdplm36GmfBtZ6jPIFClLSEffhAk9fTpJ6i8WpgqiZvtUNl53mLL7mu4JWwxPpfSa5pdexyxK/68WtoTmd53TI+R9GffjGc3USoLgWcKI=\",'+
		'        \"version\": \"v1\"'+
		'    },'+
		'    \"body\": {'+
		'        \"txnTimestamp\": \"2019-09-02 12:31:49.0\",'+
		'        \"orderId\": \"YOUR_ORDER_ID\",'+
		'        \"mid\": \"YOUR_MID_HERE\",'+
		'        \"refId\": \"UNIQUE_REFUND_ID\",'+
		'        \"resultInfo\": {'+
		'            \"resultStatus\": \"PENDING\",'+
		'            \"resultCode\": \"601\",'+
		'            \"resultMsg\": \"Refund request was raised for this transaction. But it is pending state\"'+
		'        },'+
		'        \"refundId\": \"PAYTM_REFUND_ID\",'+
		'        \"txnId\": \"PAYTM_TRANSACTION_ID\",'+
		'        \"refundAmount\": \"1.00\"'+
		'    }'+
		'}';
		PaytmRefundResponseWrapper obj = PaytmRefundResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}