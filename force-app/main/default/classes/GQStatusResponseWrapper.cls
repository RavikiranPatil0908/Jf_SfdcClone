/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
public class GQStatusResponseWrapper{
	public boolean success;
	public Integer status_code;	//200
	public String message;	//Application status fetched successfully
	public cls_data[] data;
	public class cls_data {
		public Integer application_id;	//348073
		public String student_id;	//maha_test_00005
		public String reference_id;	//NDI3001
		public String stage;	//Approved Conditionally
		public String stage_slug;	//loan-execution
		public cls_notes notes;
		public cls_udf_details udf_details;
	}
	public class cls_notes {
		public String app_notes;	//Mahalakshmi
		public String app_description;	//Notes Test
		public String notes_type;	//Test Decimal
        public Integer loan_amount; // 100000
		public String location;
        public String program;
        public String programcode;
        public String aep;
        public String tenure ;
        public String interestRate ;       
        public Decimal subventionvalue;
	}
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
	public static GQStatusResponseWrapper parse(String json){
		return (GQStatusResponseWrapper) System.JSON.deserialize(json, GQStatusResponseWrapper.class);
	}
}