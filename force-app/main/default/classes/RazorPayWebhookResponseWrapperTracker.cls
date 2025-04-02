/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-28-2022
 * @last modified by  : @BK
**/
@IsTest
public with sharing class RazorPayWebhookResponseWrapperTracker {
    @isTest
	static void testParse() {
		String json=		'{'+
		'    "entity": "event",'+
		'    "account_id": "acc_BFQ7uQEaa7j2z7",'+
		'    "event": "order.paid",'+
		'    "contains": ['+
		'        "payment",'+
		'        "order"'+
		'    ],'+
		'    "payload": {'+
		'        "payment": {'+
		'            "entity": {'+
		'                "id": "pay_DESlfW9H8K9uqM",'+
		'                "entity": "payment",'+
		'                "amount": 100,'+
		'                "currencyCode": "INR",'+
		'                "status": "captured",'+
		'                "order_id": "order_DESlLckIVRkHWj",'+
		'                "invoice_id": null,'+
		'                "international": false,'+
		'                "method": "netbanking",'+
		'                "amount_refunded": 0,'+
		'                "refund_status": null,'+
		'                "captured": true,'+
		'                "description": null,'+
		'                "card_id": null,'+
		'                "bank": "HDFC",'+
		'                "wallet": null,'+
		'                "vpa": null,'+
		'                "email": "gaurav.kumar@example.com",'+
		'                "contact": "+919876543210",'+
		'                "notes": {'+
		'                    "udf2": "false_No_null",'+
		'                    "udf1": "Registration_00QO000000C1MieMAF_0_PostPaymentPage_false_NA"'+
		'                },'+
		'                "fee": 2,'+
		'                "tax": 0,'+
		'                "error_code": null,'+
		'                "error_description": null,'+
		'                "created_at": 1567674599'+
		'            }'+
		'        },'+
		'        "order": {'+
		'            "entity": {'+
		'                "id": "order_DESlLckIVRkHWj",'+
		'                "entity": "order",'+
		'                "amount": 100,'+
		'                "amount_paid": 100,'+
		'                "amount_due": 0,'+
		'                "currencyCode": "INR",'+
		'                "receipt": "rcptid #1",'+
		'                "offer_id": null,'+
		'                "status": "paid",'+
		'                "attempts": 1,'+
		'                "notes": {'+
		'                    "udf2": "false_No_null",'+
		'                    "udf1": "Registration_00QO000000C1MieMAF_0_PostPaymentPage_false_NA"'+
		'                },'+
		'                "created_at": 1567674581'+
		'            }'+
		'        }'+
		'    },'+
		'    "created_at": 1567674606'+
		'}';
		RazorPayWebhookResponseWrapper obj = RazorPayWebhookResponseWrapper.parse(json);
		System.assert(obj != null);
	}
}