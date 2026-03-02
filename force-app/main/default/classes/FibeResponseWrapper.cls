/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 27--02--2026
 * @last modified by  : @Ravi 
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   27--02--2026   @Ravi   Initial Version
**/
public class FibeResponseWrapper {
 
    public String statusMessage;
    public Integer statusCode;
    public String transactionId;
    public String leadStatus;
    public String bitlyUrl;
    public String webJourneyUrl;
    public Decimal loanAmount;
    public Decimal maxMultiplierValue;
    public String customerRefId;
    public List<CustomerStageInfo> customerStageInfo;
    // public Boolean isCancellationPolicyApproved;
    public Integer httpStatusCode;
    public Long leadId;

    public class CustomerStageInfo {
        public String stage;
        public String action;
    }

    public static FibeResponseWrapper parse(String json) {
        return (FibeResponseWrapper) System.JSON.deserialize(json, FibeResponseWrapper.class);
    }
}