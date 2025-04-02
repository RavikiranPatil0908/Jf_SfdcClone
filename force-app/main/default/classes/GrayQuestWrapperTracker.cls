/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-11-2024
 * @last modified by  : @BK
**/
@IsTest
public class GrayQuestWrapperTracker{
    
    @isTest
    static void testParse() {
        String json=		'{'+
		'	"entity": "monthly-emi",'+
		'	"event": "emi.disbursed",'+
		'	"timestamp": "05-02-2024 15:30:21",'+
		'	"reference_id": "NDI3001",'+
		'	"application_details": {'+
		'		"code": "GQEMI-1H4OYP54QZI",'+
		'		"ID": 523551,'+
		'		"created_on": "01-02-2024 15:30:21"'+
		'	},'+
		'	"student_details": {'+
		'		"code": "90b3879b-c0f5-4d42-ac53-1a2578751b6c",'+
		'		"group": "New Dawn International",'+
		'		"institute": "New Dawn International High School",'+
		'		"location": "Mumbai",'+
		'		"education_type": "CBSE",'+
		'		"class": "Class IX",'+
		'		"academic_year": "2023-2024",'+
		'		"first_name": "Divya",'+
		'		"middle_name": "Rajesh",'+
		'		"last_name": "Malhotra",'+
		'		"student_uuid": "SCS971410",'+
		'		"type": "EXISTING"'+
		'	},'+
		'	"fee_details": {'+
		'		"amount": 45000,'+
		'		"plan_name": "New Dawn International - Mumbai - CBSE - 7 EMIs - 0 DP",'+
		'		"tenure": 6,'+
		'		"interest_rate": 0,'+
		'		"processing_rate": 0,'+
		'		"discount_rate": 3.5,'+
		'		"fee_details_split": ['+
		'			{'+
		'				"code": "93e4bb1c-8667-4cc8-a247-7b777fdf0d09",'+
		'				"fee_type_name": "payable_fee_01",'+
		'				"fee_type_code": "87157d73-4562-49ab-8f78-e9833a746017",'+
		'				"amount": 70000,'+
		'				"concession": 0'+
		'			},'+
		'			{'+
		'				"code": "4dcf5e60-3d22-4dd8-9128-05a413d36455",'+
		'				"fee_type_name": "payable_fee_02",'+
		'				"fee_type_code": "b610a95a-e4b1-4326-a393-91832a16c7cb",'+
		'				"amount": 70000,'+
		'				"concession": 0'+
		'			}'+
		'		]'+
		'	},'+
		'	"customer_details": {'+
		'		"code": "6df641e7-25a9-4715-87fa-6cf0e244ad48",'+
		'		"first_name": "Rajesh",'+
		'		"middle_name": "Ashokrao",'+
		'		"last_name": "Malhotra",'+
		'		"mobile": "6302520629",'+
		'		"email": "Malhotra@gmail.com",'+
		'		"pan": "AHKPN7715J",'+
		'		"dob": "1981-08-15",'+
		'		"gender": "FEMALE"'+
		'	},'+
		'	"merchant_details": {'+
		'		"merchant_id": "GQ-ef4688e5-0830-4f52-aa92-67bae23c2785"'+
		'	},'+
		'	"unique_master_bank_details": {'+
		'		"account_number": "911010059946739",'+
		'		"ifsc": "UTIB0001017",'+
		'		"account_holder_name": "Mr Rajesh Malhotra",'+
		'		"bank_name": "Development Bank of India",'+
		'		"branch_name": "Juhu Branch",'+
		'		"account_type": "SAVINGS"'+
		'	},'+
		'	"disbursement_details": {'+
		'		"amount": 45000,'+
		'		"date": "04-05-2023",'+
		'		"utr": "IFT23124061891",'+
		'		"disbursed_amount": 45000,'+
		'		"discount_rate": 3.5,'+
		'		"discount_amount": 1576,'+
		'		"retention_rate": 0,'+
		'		"retention_amount": 0,'+
		'		"discount_gst_rate": 0,'+
		'		"discount_gst_amount": 0'+
		'	},'+
		'	"downpayment_details": {'+
		'		"label": "EMI 1",'+
		'		"due_date": "04-05-2023",'+
		'		"amount": 7500,'+
		'		"balance_amount": 0,'+
		'		"paid_amount": 7500,'+
		'		"is_complete": true,'+
		'		"overdue_days": 31,'+
		'		"overdue_amount": 0'+
		'	},'+
		'	"udf_details": {'+
		'		"udf_1": "New Dawn International",'+
		'		"udf_2": "CBSE",'+
		'		"udf_3": "Class IX",'+
		'		"udf_4": "Total Due - 50000",'+
		'		"udf_5": "Net Due - 4975",'+
		'		"udf_6": "GQ_emi amount - 44325",'+
		'		"udf_7": "Location - Mumbai",'+
		'		"udf_8": "Platform - Android",'+
		'		"udf_9": "2023-2024",'+
		'		"udf_10": "Class IX"'+
		'	},'+
		'	"notes": {'+
		'		"program": "B.Tech",'+
		'		"Course": "Computer Science",'+
		'		"year/semester": "2023-2024",'+
		'		"platform": "Online",'+
		'		"class": "Class IX",'+
		'		"location": "Mumbai",'+
		'		"total_due": 30,'+
		'		"total_net_due": "0"'+
		'	}'+
		'}';
        GrayQuestWrapper obj = GrayQuestWrapper.parse(json);
        System.assert(obj != null);
    }
}