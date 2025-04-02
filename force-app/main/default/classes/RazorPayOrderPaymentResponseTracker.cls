/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-03-2022
 * @last modified by  : @BK
**/
@isTest
public class RazorPayOrderPaymentResponseTracker {
    static testMethod void testParse() {
		String json=		'{'+
		'    "entity": "collection",'+
		'    "count": 1,'+
		'    "items": ['+
		'        {'+
		'            "id": "pay_J0Fx3a1fRsVraS",'+
		'            "entity": "payment",'+
		'            "amount": 4150000,'+
		'            "currencyType": "INR",'+
		'            "status": "captured",'+
		'            "order_id": "order_J0FwjMcZCPPNXW",'+
		'            "invoice_id": "",'+
		'            "international": false,'+
		'            "method": "netbanking",'+
		'            "amount_refunded": 0,'+
		'            "refund_status": "",'+
		'            "captured": true,'+
		'            "description": "Test Transaction",'+
		'            "card_id": "",'+
		'            "bank": "VIJB",'+
		'            "wallet": "",'+
		'            "vpa": "",'+
		'            "email": "absbsb@gmail.com",'+
		'            "contact": "+919999955123",'+
		'            "notes": {'+
		'                "udf2": "false_No_null",'+
		'                "udf1": "InitialAdmissionFee_00QO000000AGozAMAT_0_PostPaymentPage_false_NA"'+
		'            },'+
		'            "fee": 97940,'+
		'            "tax": 14940,'+
		'            "error_code": "",'+
		'            "error_description": "",'+
		'            "error_source": "",'+
		'            "error_step": "",'+
		'            "error_reason": "",'+
		'            "acquirer_data": {'+
		'                "bank_transaction_id": "5420190"'+
		'            },'+
		'            "created_at": 1645795223'+
		'        }'+
		'    ],'+
		'    "error": {'+
		'        "code": "BAD_REQUEST_ERROR",'+
		'        "description": "The order id must be 20 characters.",'+
		'        "source": "business",'+
		'        "step": "payment_initiation",'+
		'        "reason": "input_validation_failed",'+
		'        "metadata": {},'+
		'        "field": "order_id"'+
		'    }'+
		'}';
		RazorPayOrderPaymentResponseWrapper obj = RazorPayOrderPaymentResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}