/**
 * @File Name          : PaytmRefundStatusResponseWrapper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/2/2020, 4:09:46 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/2/2020   @BK     Initial Version
**/
public class PaytmRefundStatusResponseWrapper {

	public class Head {
		public String clientId;
		public String responseTimestamp;
		public String signature;
		public String version;
	}

	public class RefundDetailInfoList {
		public String refundType;
		public String payMethod;
		public String userCreditExpectedDate;
		public String userMobileNo;
		public String refundAmount;
	}

	public class ResultInfo {
		public String resultStatus;
		public String resultCode;
		public String resultMsg;
	}

	public class Body {
		public String orderId;
		public String userCreditInitiateStatus;
		public String mid;
		public String merchantRefundRequestTimestamp;
		public ResultInfo resultInfo;
		public String txnTimestamp;
		public String acceptRefundTimestamp;
		public String acceptRefundStatus;
		public List<RefundDetailInfoList> refundDetailInfoList;
		public String userCreditInitiateTimestamp;
		public String totalRefundAmount;
		public String refId;
		public String txnAmount;
		public String refundId;
		public String txnId;
		public String refundAmount;
	}

	public Head head;
	public Body body;

	
	public static PaytmRefundStatusResponseWrapper parse(String json) {
		return (PaytmRefundStatusResponseWrapper) System.JSON.deserialize(json, PaytmRefundStatusResponseWrapper.class);
	}
}