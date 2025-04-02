/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 17-01-2025
 * @last modified by  : @BK
**/
public class GQLoanRequestWrapper{
    
	public String student_id;	//st_1212024
	public String customer_mobile; //8240970770
	public String reference_id; //772210454564
	public Integer emi_plan_id; //12345
	public cls_student_details student_details;
	public cls_fee_headers fee_headers;
	public cls_notes notes;
	// public cls_udf_details udf_details;
	// public cls_redirection redirection;

	public class cls_student_details {
		public String student_first_name;	//Maha
	}

	public class cls_fee_headers {
		public Integer total_payable;	//166000
	}
	
	public class cls_notes {
		public String app_description;	//Test payment
		public String notes_type;	//Test payment
		public Integer loan_amount; // 100000
		public String location;
        public String program;
        public String programcode;
        public String aep;
        public String tenure ;
        public String interestRate ;       
        public Decimal subventionvalue;
	}
	// public class cls_udf_details {
	// 	public String udf_1;	//New Dawn International
	// 	public String udf_2;	//CBSE
	// 	public String udf_3;	//Class IX
	// 	public String udf_4;	//Total Due - 50000
	// 	public String udf_5;	//Net Due - 4975
	// 	public String udf_6;	//GQ_emi amount - 44325
	// 	public String udf_7;	//Location - Mumbai
	// 	public String udf_8;	//Platform - Android
	// 	public String udf_9;	//2023-2024
	// 	public String udf_10;	//Class IX
	// }
	// public class cls_redirection {
	// 	public String success_url;	//https://www.youtube.com
	// 	public String error_url;	//https://www.google.com
	// }
	public static GQLoanRequestWrapper parse(String json){
		return (GQLoanRequestWrapper) System.JSON.deserialize(json, GQLoanRequestWrapper.class);
	}
}