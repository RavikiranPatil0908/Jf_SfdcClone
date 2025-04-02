/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-10-2022
 * @last modified by  : @BK
**/
public class ICICIRefundWebhookWrapper{
	public cls_data data;
	public String event_time;	//2022-02-28T13:04:28+05:30
	public String type;	//REFUND_STATUS_WEBHOOK
	public class cls_data {
		public cls_refund refund;
	}
	public class cls_refund {
		public String cf_refund_id;	//refund_11325632
		public Integer cf_payment_id;	//789727431
		public String refund_id;	//refund_sampleorder0413
		public String order_id;	//sampleorder0413
		public Decimal refund_amount;	//2
		public String refund_currency;	//INR
		public String entity;	//Refund
		public String refund_type;	//MERCHANT_INITIATED
		public String refund_arn;	//205907014017
		public String refund_status;	//SUCCESS
		public String status_description;	//Refund processed successfully
		public String created_at;	//2022-02-28T12:54:25+05:30
		public String processed_at;	//2022-02-28T13:04:27+05:30
		public Decimal refund_charge;	//0
		public String refund_note;	//Test
		public cls_metadata metadata;
		public String refund_mode;	//STANDARD
	}
	public class cls_metadata {
	}
	public static ICICIRefundWebhookWrapper parse(String json){
		return (ICICIRefundWebhookWrapper) System.JSON.deserialize(json, ICICIRefundWebhookWrapper.class);
	}
}