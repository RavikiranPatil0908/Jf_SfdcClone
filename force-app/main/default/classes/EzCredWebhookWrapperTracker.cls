/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-20-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-20-2020   shubhranshu   Initial Version
**/
@isTest (SeeAllData=false)
public without sharing class EzCredWebhookWrapperTracker {
    static testMethod void testParse() {
		String json=		'{'+
		'    "customer_account_number": "123",'+
		'    "loan_account_number": "123",'+
		'    "lead_number": "1270",'+
		'    "partner_reference_id": "000461007725",'+
		'    "status": "DISBURSED",'+
		'    "submitted_on_date": "29-10-2019",'+
		'    "loan_detail": {'+
		'        "principal": 50000,'+
		'        "number_of_repayments": 12,'+
		'        "emi_amount": 2450.0,'+
		'        "down_payment": 1231'+
		'    },'+
		'    "merchant_information": {'+
		'        "merchant_id": "EDUCLASSPLUS123"'+
		'    },'+
		'    "customer_information": {'+
		'        "personal_information": {'+
		'            "type": "INDIVIDUAL",'+
		'            "first_name": "First",'+
		'            "middle_name": "Middle",'+
		'            "last_name": "Last",'+
		'            "date_of_birth": "25-10-2019",'+
		'            "gender": "MALE"'+
		'        },'+
		'        "phones": ['+
		'            {'+
		'                "type": "MOBILE",'+
		'                "country_calling_code": "91",'+
		'                "number": "1234567890"'+
		'            }'+
		'        ]'+
		'    },'+
		'    "approval_data": {'+
		'        "approval_date": "29-10-2019",'+
		'        "approved_amount": 50000.00'+
		'    },'+
		'    "agreement_sign_url": "<agreement sign url>",'+
		'    "rejection_data": {'+
		'        "rejection_date": "29-10-2019",'+
		'        "reason": "Low income"'+
		'    },'+
		'    "disbursal_data": {'+
		'        "disbursal_date": "29-10-2019",'+
		'        "disbursal_amount": 50000.00,'+
		'        "disbursal_utr": "KKBK123456"'+
		'    },'+
		'    "repayment_schedule": ['+
		'        {'+
		'            "due_date": "05-11-2018",'+
		'            "amount": 2500,'+
		'            "interest": 300,'+
		'            "principal": 2200'+
		'        },'+
		'        {'+
		'            "due_date": "05-12-2018",'+
		'            "amount": 2500,'+
		'            "Interest": 300,'+
		'            "principal": 2200'+
		'        },'+
		'        {'+
		'            "due_date": "05-01-2019",'+
		'            "amount": 2500,'+
		'            "Interest": 300,'+
		'            "principal": 2200'+
		'        },'+
		'        {'+
		'            "due_date": "05-02-2019",'+
		'            "amount": 2500,'+
		'            "Interest": 300,'+
		'            "principal": 2200'+
		'        },'+
		'        {'+
		'            "due_date": "05-03-2019",'+
		'            "amount": 2500,'+
		'            "Interest": 300,'+
		'            "principal": 2200'+
		'        },'+
		'        {'+
		'            "due_date": "05-04-2019",'+
		'            "amount": 2500,'+
		'            "Interest": 300,'+
		'            "principal": 2200'+
		'        }'+
		'    ],'+
		'    "transaction_data": ['+
		'        {'+
		'            "payment_details": {'+
		'                "receipt_number": "1234567890"'+
		'            },'+
		'            "transaction_amount": 2500,'+
		'            "transaction_date": "21-02-2020",'+
		'            "transaction_status": "PENDING",'+
		'            "transaction_type": "DOWNPAYMENT"'+
		'        },'+
		'        {'+
		'            "payment_details": {'+
		'                "receipt_number": "123456790"'+
		'            },'+
		'            "transaction_amount": 100,'+
		'            "transaction_date": "21-02-2020",'+
		'            "transaction_status": "COMPLETED",'+
		'            "transaction_type": "PROCESSING_FEE"'+
		'        },'+
		'        {'+
		'            "payment_details": {'+
		'                "receipt_number": "123456790"'+
		'            },'+
		'            "transaction_amount": 1000,'+
		'            "transaction_date": "21-02-2020",'+
		'            "transaction_status": "COMPLETED",'+
		'            "transaction_type": "EMI_REPAYMENT"'+
		'        },'+
		'        {'+
		'            "payment_details": {'+
		'                "receipt_number": "123456790"'+
		'            },'+
		'            "transaction_amount": 1000,'+
		'            "transaction_date": "21-02-2020",'+
		'            "transaction_type": "EMI_REPAYMENT"'+
		'        }'+
		'    ]'+
		'}';
		EzCredWebhookWrapper obj = EzCredWebhookWrapper.parse(json);
		System.assert(obj != null);
	}
}