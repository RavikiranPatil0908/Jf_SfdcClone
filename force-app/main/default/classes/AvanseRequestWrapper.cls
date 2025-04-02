/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 29-11-2024
 * @last modified by  : @BK
**/
public class AvanseRequestWrapper{
    public data data;
    public String application_stage;
    public String application_status;
    public String application_no;
    public String application_sub_stage;
    public String status;
    public class utr_details{
        public String utr_timestamp;
        public String utr_no;
    }
    public class kyc_details{
        public String applicant_type;
        public String status;
        public String email;
    }
    public class data{
        public String loan_plan_title;
        public Integer subvention_fee;
        public Integer processing_fee;
        public String student_session;
        public String mode_of_course;
        public Long admission_number;
        public list<utr_details> utr_details;
        public String in_progress_timestamp;
        public Integer loan_amount;
        public String disbursement_timestamp;
        public list<kyc_details> kyc_details;
        public String ops_approved_timestamp;
        public Integer disb_amount;
        public String ops_rejected_timestamp;
        public String lan_number;
        public String credit_approved_timestamp;
        public Integer adv_emi;
        public String credit_rejected_timestamp;
        public Integer tenure;
        public String partner_application_number;
        public Integer fees;
        public String ops_under_approval_timestamp;
        public Integer roi;
        public String credit_under_approval_timestamp;
        public Integer emi;
    }

    public static AvanseRequestWrapper parse(String json) {
		return (AvanseRequestWrapper) System.JSON.deserialize(json, AvanseRequestWrapper.class);
	}
}