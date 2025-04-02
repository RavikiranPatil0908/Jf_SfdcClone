/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
@isTest
public class DEBStudentDetailsWrapperTracker {

    @isTest
    static void testParse() {
		String json=		''+
		'{'+
		'    "Message": "Data retrival successful.",'+
		'    "Status": "Process Success",'+
		'    "Resource": ['+
		'        {'+
		'            "StudentID": "345345",'+
		'            "Program": "",'+
		'            "email": "test@gmail.com",'+
		'            "stdname": "test test",'+
		'            "fathername": "",'+
		'            "mobile": "9000000001",'+
		'            "cdate": "Sep  2 2024  6:34PM",'+
		'            "institutename": "",'+
		'            "InstituteID": "",'+
		'            "ipaddress": "192.000.00.37",'+
		'            "programcode": "000000027388",'+
		'            "mode": "",'+
		'            "AdmissionDate": "",'+
		'            "AdmissionDetails": "",'+
		'            "UniversityName": "",'+
		'            "CourseName": "",'+
		'            "ABCID": "600000000785",'+
		'            "DEBUniqueID": "090000000088",'+
		'            "Gender": "Male",'+
		'            "DOB": "15/06/1991",'+
		'            "_list": null'+
		'        }'+
		'    ]'+
		'}';
		DEBStudentDetailsWrapper obj = DEBStudentDetailsWrapper.parse(json);
		System.assertNotEquals(null, obj, 'Expected the parse to not return null');
	}
}