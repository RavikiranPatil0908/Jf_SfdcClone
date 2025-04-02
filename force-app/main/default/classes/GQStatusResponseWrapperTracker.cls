/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class GQStatusResponseWrapperTracker {
    
    @isTest
    static void testParse() {
		String json=		'{'+
		'   "success": true,'+
		'   "status_code": 200,'+
		'   "message": "Application status fetched successfully",'+
		'   "data": ['+
		'       {'+
		'           "application_id": 348073,'+
		'           "student_id": "maha_test_00005",'+
		'           "reference_id": "NDI3001",'+
		'           "stage": "Approved Conditionally",'+
		'           "stage_slug": "loan-execution",'+
		'           "notes": {'+
		'               "app_notes": "Mahalakshmi",'+
		'               "app_description": "Notes Test",'+
		'               "notes_type": "Test Decimal"'+
		'           },'+
		'           "udf_details": {'+
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
		'           }'+
		'       },'+
		'       {'+
		'           "application_id": 348056,'+
		'           "student_id": "maha_test_00005",'+
		'           "stage": "Incomplete Applications",'+
		'           "stage_slug": "lead",'+
		'           "reference_id": "NDI3001",'+
		'           "notes": {'+
		'               "app_notes": "Mahalakshmi",'+
		'               "app_description": "Notes Test",'+
		'               "notes_type": "Test Decimal"'+
		'           },'+
		'           "udf_details": {'+
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
		'           }'+
		'       }'+
		'   ]'+
		'}'+
		'';

        GQStatusResponseWrapper obj = GQStatusResponseWrapper.parse(json);
		System.assert(obj != null, 'Wrapper Should not be Blank');
	}
}