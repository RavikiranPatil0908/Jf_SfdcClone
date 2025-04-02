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
public without sharing class EzCredWebhookWrapper{
	public String customer_account_number;	//123
	public String loan_account_number;	//123
	public String lead_number;	//1270
	public String partner_reference_id;	//000461007725
	public String status;	//DISBURSED
	public String submitted_on_date;	//29-10-2019
	public cls_loan_detail loan_detail;
	public cls_merchant_information merchant_information;
	public cls_customer_information customer_information;
	public cls_approval_data approval_data;
	public String agreement_sign_url;	//<agreement sign url>
	public cls_rejection_data rejection_data;
	public cls_disbursal_data disbursal_data;
	public cls_repayment_schedule[] repayment_schedule;
	public cls_transaction_data[] transaction_data;
	public class cls_loan_detail {
		public decimal principal;	//50000
		public decimal number_of_repayments;	//12
		public decimal emi_amount;	//2450
		public decimal down_payment;	//1231
	}
	public class cls_merchant_information {
		public String merchant_id;	//EDUCLASSPLUS123
	}
	public class cls_customer_information {
		public cls_personal_information personal_information;
		public cls_phones[] phones;
	}
	public class cls_personal_information {
		public String type;	//INDIVIDUAL
		public String first_name;	//First
		public String middle_name;	//Middle
		public String last_name;	//Last
		public String date_of_birth;	//25-10-2019
		public String gender;	//MALE
	}
	public class cls_phones {
		public String type;	//MOBILE
		public String country_calling_code;	//91
		public String mnumber;	//1234567890
	}
	public class cls_approval_data {
		public String approval_date;	//29-10-2019
		public decimal approved_amount;	//50000
	}
	public class cls_rejection_data {
		public String rejection_date;	//29-10-2019
		public String reason;	//Low income
	}
	public class cls_disbursal_data {
		public String disbursal_date;	//29-10-2019
		public decimal disbursal_amount;	//50000
		public String disbursal_utr;	//KKBK123456
	}
	public class cls_repayment_schedule {
		public String due_date;	//05-11-2018
		public decimal amount;	//2500
		public decimal interest;	//300
		public decimal principal;	//2200
	}
	public class cls_transaction_data {
		public cls_payment_details payment_details;
		public decimal transaction_amount;	//2500
		public String transaction_date;	//21-02-2020
		public String transaction_status;	//PENDING
		public String transaction_type;	//DOWNPAYMENT
	}
	public class cls_payment_details {
		public String receipt_number;	//1234567890
	}
	public static EzCredWebhookWrapper parse(String json){
		return (EzCredWebhookWrapper) System.JSON.deserialize(json, EzCredWebhookWrapper.class);
    }
}