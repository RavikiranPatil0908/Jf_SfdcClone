/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-12-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class GQLoanRequestWrapperTracker {
    
    @isTest
    static void testParse() {
		String json=		'{'+
		'   "student_id": "st_1212024",'+
		'   "customer_mobile": "9823232314",'+
		'	"emi_plan_id": 12345,'+
		'    "fee_headers": {'+
		'        "invoice_1": 85000,'+
		'        "invoice_2": 85000,'+
		'        "invoice_3": 85000'+
		'   },'+
		'   "student_details": {'+
		'       "student_first_name": "Maha",'+
		'       "student_middle_name": "Kumar",'+
		'       "student_last_name": "Thevar",'+
		'       "student_type": "NEW",  '+
		'       "student_class_id": 2,'+
		'       "student_dob": "03-09-1996",'+
		'       "student_gender": "FEMALE",'+
		'       "student_email": "maha.salo@kakashi.com",'+
		'       "student_admission_type": "NEW",'+
		'       "student_admission_no": "ML-Ao-001",'+
		'       "student_admission_date": "02-04-2023",'+
		'       "student_gr_no": "ML-GR-001",'+
		'       "student_blood_group": "B"'+
		'   },'+
		'   "customer_details": {'+
		'       "customer_first_name": "Naruto",'+
		'       "customer_middle_name": "Minato",'+
		'       "customer_last_name": "Uzumaki",'+
		'       "customer_email": "itachi@uchiha.com",'+
		'       "customer_dob": "03-09-1988",'+
		'       "customer_marital_status": "OTHERS",'+
		'       "customer_gender": "MALE",'+
		'       "customer_employment_type": "SALARIED"'+
		'   },'+
		'   "kyc_details": {'+
		'       "pan_number": "AAAPA0000A",'+
		'       "driving_license_number": "MH43 20100028334",'+
		'       "passport_number": "R2943071",'+
		'       "voter_id_number": "SAV4378188"'+
		'   },'+
		'   "notes": {'+
		'       "app_description": "Test payment",'+
		'       "notes_type": "Test payment"'+
		'   },'+
		'    "udf_details": {'+
		'               "udf_1": "New Dawn International",'+
		'               "udf_2": "CBSE",'+
		'               "udf_3": "Class IX",'+
		'               "udf_4": "Total Due - 50000",'+
		'               "udf_5": "Net Due - 4975",'+
		'               "udf_6": "GQ_emi amount - 44325",'+
		'               "udf_7": "Location - Mumbai",'+
		'               "udf_8": "Platform - Android",'+
		'               "udf_9": "2023-2024",'+
		'               "udf_10": "Class IX"'+
		'    },'+
		'   "redirection": {'+
		'       "success_url": "https://www.youtube.com",'+
		'       "error_url": "https://www.google.com"'+
		'   }'+
		'}';
		GQLoanRequestWrapper obj = GQLoanRequestWrapper.parse(json);
		System.assert(obj != null, 'Wrapper Should not be Blank');
	}
}