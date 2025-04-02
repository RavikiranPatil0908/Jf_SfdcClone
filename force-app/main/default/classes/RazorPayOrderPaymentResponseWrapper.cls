/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 04-28-2022
 * @last modified by  : @BK
**/
public class RazorPayOrderPaymentResponseWrapper{
	public String entity;	//collection
	public Integer count;	//1
	public cls_items[] items;
    public cls_error error;
	public class cls_items {
		public String id;	//pay_J0Fx3a1fRsVraS
		public String entity;	//payment
		public Integer amount;	//4150000
		public String currencyType;	//INR
		public String status;	//captured
		public String order_id;	//order_J0FwjMcZCPPNXW
		public String invoice_id;	//
		public boolean international;
		public String method;	//netbanking
		public Integer amount_refunded;	//0
		public String refund_status;	//
		public boolean captured;
		public String description;	//Test Transaction
		public String card_id;	//
		public String bank;	//VIJB
		public String wallet;	//
		public String vpa;	//
		public String email;	//absbsb@gmail.com
		public String contact;	//+919999955123
		public cls_notes notes;
		public Integer fee;	//97940
		public Integer tax;	//14940
		public String error_code;	//
		public String error_description;	//
		public String error_source;	//
		public String error_step;	//
		public String error_reason;	//
		public cls_acquirer_data acquirer_data;
		public Integer created_at;	//1645795223
	}
	public class cls_notes {
		public String udf2;	//false_No_null
		public String udf1;	//InitialAdmissionFee_00QO000000AGozAMAT_0_PostPaymentPage_false_NA
		public String udf3; //Redirect page name
	}
	public class cls_acquirer_data {
		public String bank_transaction_id;	//5420190
	}
    public class cls_error {
		public String code;	//BAD_REQUEST_ERROR
		public String description;	//The order id must be 20 characters.
		public String source;	//business
		public String step;	//payment_initiation
		public String reason;	//input_validation_failed
		public cls_metadata metadata;
		public String field;	//order_id
	}
	public class cls_metadata {
	}
	public static RazorPayOrderPaymentResponseWrapper parse(String json){
		return (RazorPayOrderPaymentResponseWrapper) System.JSON.deserialize(json, RazorPayOrderPaymentResponseWrapper.class);
	}
}