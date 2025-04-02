/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-28-2022
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-15-2021   @BK   Initial Version
**/
public class ZestResponseWrapper{
	public String eventType;	//StatusChange
	public cls_payload payload;
	public class cls_payload {
		public cls_transaction transactionDetails;
		public cls_customer customer;
	}
	public class cls_transaction {
		public String partnerTransactionId;	//2021HB78770
		public String zestTransactionId;	//6e2c9b93-6e39-4a45-86df-f6a603bed7ec
		public String ZestLoanId;	//1127439A2933
		public Decimal basketAmount;	//23349.00
		public Decimal loanAmount;	//20000.00
		public Integer tenure;	//6
		public Decimal downpaymentAmount;	//3300.00
		public String utr;
		public String status;
		public Double settlementAmount;
		public String settledOnDate;
		public String key;	//75cbbd3f3ce9d2555c4e4d7b326235fd83c7ad438cb20a2c593834ba89ba9add14051753b7fd27cf3e87fe3de25a4e29c335e44ec72c00830dba96e76c9413a6
	}
	public class cls_customer {
		public String name;	//FirstName LastName
		public String email;	//XXXXXXXXXX@gmail.com
		public String mobileNumber;	//91XXXXXXXXXX
	}
	public static ZestResponseWrapper parse(String json) {
		return (ZestResponseWrapper) System.JSON.deserialize(json, ZestResponseWrapper.class);
	}
}