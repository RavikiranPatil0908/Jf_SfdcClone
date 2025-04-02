/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : @BK
**/
public class PaytmRefundWebhookResponseWrapper {

	public cls_head head;
	public cls_body body;

	public class cls_head {
		public String signature;	//Ec4jwawWFcsOS4lZJ5aClcats/J8c55CJ/DW0MA9gp37MwQ8bcXsMT1mmlbDrefundIdwgGOzxzba5/kADe7UiALEtZQvKVQ5YrYS/pcQtZ0gghKLWc=
		public String version;	//v1
	}

	public class cls_body {
		public String txnTimestamp;	//2020-09-03 16:51:41.0
		public String orderId;	//ORDERID_98765
		public String refundAmount;	//1.00
		public String refundId;	//20200903XXXXXX801300168821700215705
		public String txnAmount;	//1.00
		public String txnId;	//202005081112128XXXXXX68470101509706
		public String merchantRefundRequestTimestamp;	//2020-09-03 16:52:08.0
		public String acceptRefundTimestamp;	//2020-09-03 16:52:09.0
		public String refId;	//REFUNDID_98765
		public String refundReason;	//Sample Refund Reason 
		public cls_agentInfo agentInfo;
		public String status;	//SUCCESS
		public String rejectRefundReasonCode;	//1
		public String rejectRefundReasonMessage;	//Insufficient balance in your settlement account
	}

	public class cls_agentInfo {
		public String employeeId;	//Emp-001
		public String name;	//Lalit
		public String phoneNo;	//7777777777
		public String email;	//customer@example.com
	}
	
	public static PaytmRefundWebhookResponseWrapper parse(String json){
		return (PaytmRefundWebhookResponseWrapper) System.JSON.deserialize(json, PaytmRefundWebhookResponseWrapper.class);
	}
}