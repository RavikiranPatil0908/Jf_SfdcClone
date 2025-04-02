/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-28-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-17-2020   shubhranshu   Initial Version
**/
@isTest (SeeAllData=false)
public class EzCredRequestWrapperTracker {
	static testMethod void testParse() {
		String json= '{'+
		'  "partner_id": "Partner Id",'+
		'  "merchant_id": "Merchant Id",'+
		'  "partner_reference_id": "Reference Id",'+
		'  "partner_merchant_id": "Center Code",'+
		'  "entity_type": "CUSTOMER",'+
		'  "customer_information": {'+
		'    "personal_information": {'+
		'      "first_name": "First",'+
		'      "middle_name": "Middle",'+
		'      "last_name": "Last",'+
		'      "date_of_birth": "25-10-2019",'+
		'      "gender": "MALE",'+
		'      "personal_details": {'+
		'        "marital_status": "SINGLE",'+
		'        "father_name": "dad",'+
		'        "mother_name": "mom",'+
		'        "profession": "SALARIED",'+
		'        "email": "abc@gmail.com"'+
		'      }'+
		'    },'+
		'    "phones": ['+
		'      {'+
		'        "type": "MOBILE",'+
		'        "country_calling_code": "91",'+
		'        "number": "1234567890"'+
		'      }'+
		'    ],'+
		'    "emails": ['+
		'      {'+
		'        "type": "WORK",'+
		'        "email": "a@b.in"'+
		'      }'+
		'    ],'+
		'    "addresses": ['+
		'      {'+
		'        "type": "PERMANENT",'+
		'        "street": "Villa - 13A",'+
		'        "address_line_1": "Colony New",'+
		'        "address_line_2": "NewPort",'+
		'        "city": "Bangalore",'+
		'        "state": "Karnataka",'+
		'        "pincode": "560102"'+
		'      }'+
		'    ],'+
		'    "identifiers": ['+
		'      {'+
		'        "type": "PAN_CARD",'+
		'        "id": "QWEPS3026E"'+
		'      }'+
		'    ],'+
		'    "bank_account_information": ['+
		'      {'+
		'        "account_number": "accountnumber",'+
		'        "account_type": "SAVINGS",'+
		'        "account_holder_name": "accountholdername",'+
		'        "ifsc_code": "ifsccode"'+
		'      }'+
		'    ]'+
		'  },'+
		'  "loan_scheme_code": "EMI123456789",'+
		'  "redirect_url": "https://www.merchantsite.com/applicationId=xyz",'+
		'  "product_details": {'+
		'    "type": "PRIMARY",'+
		'    "category": "Category",'+
		'    "brand": "Brand",'+
		'    "model": "Model",'+
		'    "price": 25000.0'+
		'  },'+
		'  "student_details": {'+
		'    "name": "Anish Chopra",'+
		'    "application_no": "1231231231",'+
		'    "board": "cbse",'+
		'    "course": "english",'+
		'    "relation_with_applicant": "FATHER",'+
		'    "date_of_birth": "01-01-1990",'+
		'    "gender": "MALE"'+
		'  }'+
		'}';
		EzCredRequestWrapper obj = EzCredRequestWrapper.parse(json);
		System.assert(obj != null);
	}
}