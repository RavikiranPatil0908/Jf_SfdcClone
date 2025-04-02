/**
 * @File Name          : PaytmRefundStatusResponseWrapperTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/2/2020, 4:11:40 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/2/2020   @BK     Initial Version
**/
@IsTest
public class PaytmRefundStatusResponseWrapperTracker {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"head\": {'+
		'        \"clientId\": \"C11\",'+
		'        \"responseTimestamp\": \"1556719120393\",'+
		'        \"signature\": \"Stx6P9HpnEG3GADkMuOcj50dm7ZHmvMPd29b8K5rxi4aVzRcJ5hklZo//RZdtTA+zcll8sdelyAYsxqPxFs66RVE0F2b9RElTMqYSfBj89I=\",'+
		'        \"version\": \"v1\"'+
		'    },'+
		'    \"body\": {'+
		'        \"orderId\": \"YOUR_ORDER_ID\",'+
		'        \"userCreditInitiateStatus\": \"SUCCESS\",'+
		'        \"mid\": \"YOUR_MID_HERE\",'+
		'        \"merchantRefundRequestTimestamp\": \"2019-05-01 19:27:25.0\",'+
		'        \"resultInfo\": {'+
		'            \"resultStatus\": \"TXN_SUCCESS\",'+
		'            \"resultCode\": \"10\",'+
		'            \"resultMsg\": \"Refund Successfull\"'+
		'        },'+
		'        \"txnTimestamp\": \"2019-05-01 19:25:41.0\",'+
		'        \"acceptRefundTimestamp\": \"2019-05-01 19:27:25.0\",'+
		'        \"acceptRefundStatus\": \"SUCCESS\",'+
		'        \"refundDetailInfoList\": ['+
		'            {'+
		'                \"refundType\": \"TO_SOURCE\",'+
		'                \"payMethod\": \"BALANCE\",'+
		'                \"userCreditExpectedDate\": \"2019-05-02\",'+
		'                \"userMobileNo\": \"91-******7777\",'+
		'                \"refundAmount\": \"1.00\"'+
		'            }'+
		'        ],'+
		'        \"userCreditInitiateTimestamp\": \"2019-05-01 19:27:26.0\",'+
		'        \"totalRefundAmount\": \"1.00\",'+
		'        \"refId\": \"UNIQUE_REFUND_ID\",'+
		'        \"txnAmount\": \"10.00\",'+
		'        \"refundId\": \"PAYTM_REFUND_ID\",'+
		'        \"txnId\": \"PAYTM_TRANSACTION_ID\",'+
		'        \"refundAmount\": \"1.00\"'+
		'    }'+
		'}';
		PaytmRefundStatusResponseWrapper obj = PaytmRefundStatusResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}