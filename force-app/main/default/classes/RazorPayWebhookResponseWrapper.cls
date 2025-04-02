/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 04-05-2022
 * @last modified by  : @BK
**/
public class RazorPayWebhookResponseWrapper {
	public String entity;	//event
	public String account_id;	//acc_BFQ7uQEaa7j2z7
	public String event;	//order.paid
	public List<String> contains;
	public cls_payload payload;
	public Integer created_at;	//1567674606

	public class cls_payload {
		public cls_payment payment;
		public cls_order order;
	}
	public class cls_payment {
		public cls_entity entity;
	}
	public class cls_entity {
		public String id;	//order_DESlLckIVRkHWj
		public String entity;	//order
		public Decimal amount;	//100
		public Decimal amount_paid;	//100
		public Decimal amount_due;	//0
		public String currencyCode;	//INR
		public String receipt;	//rcptid #1
		public String offer_id;
		public String status;	//paid
		public Integer attempts;	//1
		public cls_notes notes;
		public Integer created_at;	//1567674581
        public String order_id;
        public String invoice_id;
        public Boolean international;
        public String method;
        public Decimal amount_refunded;
        public String refund_status;
        public Boolean captured;
        public String description;
        public String card_id;
        public String bank;
        public String wallet;
        public String vpa;
        public String email;
        public String contact;
        public Decimal fee;
        public Decimal tax;
        public String error_code;
        public String error_description;
	}
	public class cls_notes {
		public String udf2;	//false_No_null
		public String udf1;	//Registration_00QO000000C1MieMAF_0_PostPaymentPage_false_NA
		public String udf3;	//Redirect page name
	}
	public class cls_order {
		public cls_entity entity;
	}

	public static RazorPayWebhookResponseWrapper parse(String json){
		System.debug('RazorPayWebhookResponseWrapper --> ' +System.JSON.deserialize(json, RazorPayWebhookResponseWrapper.class));
		return (RazorPayWebhookResponseWrapper) System.JSON.deserialize(json, RazorPayWebhookResponseWrapper.class);
	}
}