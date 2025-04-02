/**
 * @File Name          : PaytmRefundResponseWrapper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/2/2020, 3:11:02 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/2/2020   @BK     Initial Version
**/
public class PaytmRefundResponseWrapper {

	public Head head;
	public Body body;

	public class Head {
        public String clientId;
		public String responseTimestamp;
		public String signature;
		public String version;
	}

	public class ResultInfo {
		public String resultStatus;
		public String resultCode;
		public String resultMsg;
	}

	public class Body {
		public String txnTimestamp;
		public String orderId;
		public String mid;
		public String refId;
		public ResultInfo resultInfo;
		public String refundId;
		public String txnId;
		public String refundAmount;
	}

	
	public static PaytmRefundResponseWrapper parse(String json) {
		return (PaytmRefundResponseWrapper) System.JSON.deserialize(json, PaytmRefundResponseWrapper.class);
	}
}