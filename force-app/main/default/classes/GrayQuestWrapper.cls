/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 19-11-2024
 * @last modified by  : @BK
**/
public class GrayQuestWrapper{
	public String entity;	//monthly-emi
	public String event;	//emi.disbursed
	public String timestamp;	//05-02-2024 15:30:21
	public String reference_id;	//NDI3001
	public cls_application_details application_details;
	public cls_student_details student_details;
	public cls_fee_details fee_details;
	public cls_customer_details customer_details;
	public cls_merchant_details merchant_details;
	public cls_unique_master_bank_details unique_master_bank_details;
	public cls_disbursement_details disbursement_details;
	// public cls_downpayment_details downpayment_details;
	public cls_udf_details udf_details;
	public cls_notes notes;
	public class cls_application_details {
		public String code;	//GQEMI-1H4OYP54QZI
		public Integer ID;	//523551
		public String created_on;	//01-02-2024 15:30:21
	}
	public class cls_student_details {
		public String code;	//90b3879b-c0f5-4d42-ac53-1a2578751b6c
		public String institute;	//New Dawn International High School
		public String location;	//Mumbai
		public String education_type;	//CBSE
		public String academic_year;	//2023-2024
		public String first_name;	//Divya
		public String middle_name;	//Rajesh
		public String last_name;	//Malhotra
		public String student_uuid;	//SCS971410
		public String type;	//EXISTING
	}
	public class cls_fee_details {
		public Integer amount;	//45000
		public String plan_name;	//New Dawn International - Mumbai - CBSE - 7 EMIs - 0 DP
		public Integer tenure;	//6
		public Decimal interest_rate;	//0.0
		public Decimal processing_rate;	//0.0
		public Decimal discount_rate;	//3.5
		public cls_fee_details_split[] fee_details_split;
	}
	public class cls_fee_details_split {
		public String code;	//93e4bb1c-8667-4cc8-a247-7b777fdf0d09
		public String fee_type_name;	//payable_fee_01
		public String fee_type_code;	//87157d73-4562-49ab-8f78-e9833a746017
		public Decimal amount;	//70000
		public Decimal concession;	//0
	}
	public class cls_customer_details {
		public String code;	//6df641e7-25a9-4715-87fa-6cf0e244ad48
		public String first_name;	//Rajesh
		public String middle_name;	//Ashokrao
		public String last_name;	//Malhotra
		public String mobile;	//6302520629
		public String email;	//Malhotra@gmail.com
		public String pan;	//AHKPN7715J
		public String dob;	//1981-08-15
		public String gender;	//FEMALE
	}
	public class cls_merchant_details {
		public String merchant_id;	//GQ-ef4688e5-0830-4f52-aa92-67bae23c2785
	}
	public class cls_unique_master_bank_details {
		public String account_number;	//911010059946739
		public String ifsc;	//UTIB0001017
		public String account_holder_name;	//Mr Rajesh Malhotra
		public String bank_name;	//Development Bank of India
		public String branch_name;	//Juhu Branch
		public String account_type;	//SAVINGS
	}
	public class cls_disbursement_details {
		public Decimal amount;	//45000
		public String utr;	//IFT23124061891
		public Decimal disbursed_amount;	//45000
		public Decimal discount_rate;	//3.5
		public Decimal discount_amount;	//1576
		public Decimal retention_rate;	//0
		public Decimal retention_amount;	//0
		public Decimal discount_gst_rate;	//0
		public Decimal discount_gst_amount;	//0
	}
	// public class cls_downpayment_details {
	// 	public String label;	//EMI 1
	// 	public String due_date;	//04-05-2023
	// 	public Decimal amount;	//7500
	// 	public Decimal balance_amount;	//0
	// 	public Decimal paid_amount;	//7500
	// 	public boolean is_complete;
	// 	public Integer overdue_days;	//31
	// 	public Integer overdue_amount;	//0
	// }
	public class cls_udf_details {
		public String udf_1;	//New Dawn International
		public String udf_2;	//CBSE
		public String udf_3;	//Class IX
		public String udf_4;	//Total Due - 50000
		public String udf_5;	//Net Due - 4975
		public String udf_6;	//GQ_emi amount - 44325
		public String udf_7;	//Location - Mumbai
		public String udf_8;	//Platform - Android
		public String udf_9;	//2023-2024
		public String udf_10;	//Class IX
	}
	public class cls_notes {
		public String app_description;	//Test payment
		public String notes_type;	//Test payment
		public Decimal loan_amount; // 100000
		public String location;
        public String program;
        public String programcode;
        public String aep;
        public String tenure;
        public String interestRate ;       
        public Decimal subventionvalue;
	}

	public static GrayQuestWrapper parse(String json){
		return (GrayQuestWrapper) System.JSON.deserialize(json, GrayQuestWrapper.class);
	}
}