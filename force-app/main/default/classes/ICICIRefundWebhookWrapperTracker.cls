/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-06-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public with sharing class ICICIRefundWebhookWrapperTracker {
    static testMethod void testParse() {
		String json='{'+
		''+
		'    "data": {'+
		''+
		'        "refund": {'+
		''+
		'            "cf_refund_id": "11325632",'+
		''+
		'            "cf_payment_id": 789727431,'+
		''+
		'            "refund_id": "refund_sampleorder0413",'+
		''+
		'            "order_id": "sampleorder0413",'+
		''+
		'            "refund_amount": 2.00,'+
		''+
		'            "refund_currency": "INR",'+
		''+
		'            "entity": "Refund",'+
		''+
		'            "refund_type": "MERCHANT_INITIATED",'+
		''+
		'            "refund_arn": "205907014017",'+
		''+
		'            "refund_status": "SUCCESS",'+
		''+
		'            "status_description": "Refund processed successfully",'+
		''+
		'            "created_at": "2022-02-28T12:54:25+05:30",'+
		''+
		'            "processed_at": "2022-02-28T13:04:27+05:30",'+
		''+
		'            "refund_charge": 0,'+
		''+
		'            "refund_note": "Test",'+
		''+
		'            "refund_splits": null,'+
		''+
		'            "metadata": null,'+
		''+
		'            "refund_mode": "STANDARD"'+
		''+
		'        }'+
		''+
		'    },'+
		''+
		'    "event_time": "2022-02-28T13:04:28+05:30",'+
		''+
		'    "type": "REFUND_STATUS_WEBHOOK"'+
		''+
		'}';
		
        ICICIRefundWebhookWrapper obj = ICICIRefundWebhookWrapper.parse(json);
		System.assert(obj != null);
	}

}