public class nmBillDeskPayResponse {
    public String transaction_response {get;set;}
    public String TranTrackid {get;set;}
    public String results {get;set;}
    public nmBillDeskHelper.PaymentDetails objDetails {get;set;}
    
    public nmBillDeskPayResponse() {
        transaction_response = ApexPages.currentPage().getParameters().get('transaction_response');
        TranTrackid = ApexPages.currentPage().getParameters().get('TranTrackid');
        System.debug(JSON.serialize(ApexPages.currentPage().getParameters()));
        objDetails = new nmBillDeskHelper.PaymentDetails();
        if(String.isBlank(transaction_response) || transaction_response == 'undefined') {
            results = 'REDIRECT='+nmCommon.getConfigSettings('nm_PaymentResponseUrl_BillDesk__c');
        }
    }
    public PageReference StorePaymentInSystem() {
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        system.debug('transaction_response --> ' + transaction_response);
        List<String> resultSplit = String.isNotBlank(transaction_response) ? transaction_response.split('\\.') : new List<String>();
        if(String.isNotBlank(transaction_response) && transaction_response != 'undefined' && resultSplit.size() == 3 && nmBillDeskHelper.hmacSHA256Verification(resultSplit[0], resultSplit[1], resultSplit[2], BilldeskV2.Secret_Key__c)) {
            objDetails = nmBillDeskHelper.setPaymentDetails(objDetails, resultSplit[1]);
            PaymentHandler objPaymentHandler = new PaymentHandler();
            PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
            objReqWrapper.merchantId = objDetails.merchantId;
            objReqWrapper = nmBillDeskHelper.setPaymentResponseWrapper(objReqWrapper, objDetails);
            String pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
            if(String.isNotBlank(pageUrl)) {
                PageReference page = new PageReference(pageUrl);
                return page;
            }
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId='+objDetails.merchantId);
            return page;
        } else {
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId=');
            return page;
        }
    }
}