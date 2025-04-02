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
public without sharing class EzCredRequestWrapper{
	public String partner_id;	//Partner Id
	public String merchant_id;	//Merchant Id
	public String partner_reference_id;	//Reference Id
	public String partner_merchant_id; // center code mapping value
	public String entity_type;	//CUSTOMER
	public cls_customer_information customer_information;
	public String loan_scheme_code;	//EMI123456789
	public String redirect_url;	//https://www.merchantsite.com/applicationId=xyz
	public cls_product_details product_details;
	public cls_student_details student_details;
	public class cls_customer_information {
		public cls_personal_information personal_information;
		public cls_phones[] phones;
		public cls_emails[] emails;
		public cls_addresses[] addresses;
		public cls_identifiers[] identifiers;
		public cls_bank_account_information[] bank_account_information;
	}
	public class cls_personal_information {
		public String first_name;	//First
		public String middle_name;	//Middle
		public String last_name;	//Last
		public String date_of_birth;	//25-10-2019
		public String gender;	//MALE
		public cls_personal_details personal_details;
	}
	public class cls_personal_details {
		public String marital_status;	//SINGLE
		public String father_name;	//dad
		public String mother_name;	//mom
		public String profession;	//SALARIED
		public String email;	//abc@gmail.com
	}
	public class cls_phones {
		public String type;	//MOBILE
		public String country_calling_code;	//91
		public String mnumber;	//1234567890
	}
	public class cls_emails {
		public String type;	//WORK
		public String email;	//a@b.in
	}
	public class cls_addresses {
		public String type;	//PERMANENT
		public String street;	//Villa - 13A
		public String address_line_1;	//Colony New
		public String address_line_2;	//NewPort
		public String city;	//Bangalore
		public String state;	//Karnataka
		public String pincode;	//560102
	}
	public class cls_identifiers {
		public String type;	//PAN_CARD
		public String id;	//QWEPS3026E
	}
	public class cls_bank_account_information {
		public String account_number;	//accountnumber
		public String account_type;	//SAVINGS
		public String account_holder_name;	//accountholdername
		public String ifsc_code;	//ifsccode
	}
	public class cls_product_details {
		public String type;	//PRIMARY
		public String category;	//Category
		public String brand;	//Brand
		public String model;	//Model
		public Decimal price;	//25000
	}
	public class cls_student_details {
		public String name;	//Anish Chopra
		public String application_no;	//1231231231
		public String board;	//cbse
		public String course;	//english
		public String relation_with_applicant;	//FATHER
		public String date_of_birth;	//01-01-1990
		public String gender;	//MALE
	}
	public static EzCredRequestWrapper parse(String json){
		return (EzCredRequestWrapper) System.JSON.deserialize(json, EzCredRequestWrapper.class);
	}
}