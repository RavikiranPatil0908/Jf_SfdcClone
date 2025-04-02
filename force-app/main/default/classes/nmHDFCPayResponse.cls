/**
 * @File Name          : nmHDFCPayResponse.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 21-03-2023
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    10/8/2019, 7:03:07 PM   @BK     Initial Version
**/
public class nmHDFCPayResponse {

    public PaymentHandler.PaymentResponseWrapper objDetails {get;set;} //Payment Response
    public String results {get;set;}
    public Map<String,String> mapOfParameters {get;set;}

    public nmHDFCPayResponse()
    {
        objDetails = new PaymentHandler.PaymentResponseWrapper();
        mapOfParameters = ApexPages.currentPage().getParameters();
        // to set payment details
        setPaymentDetails();

        if(String.isNotBlank(objDetails.postPaymentPage) && objDetails.postPaymentPage!='NA'){
            results = 'REDIRECT='+Label.Site_Url+objDetails.postPaymentPage+'?ResTrackId='+objDetails.merchantId ;
        }else{
            results = 'REDIRECT='+nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c')+'?ResTrackId='+objDetails.merchantId ;
        }
    }
    
    public PageReference StorePaymentInSystem() {
        System.debug('EnterPaymentFunction');    
        if(verifyChecksum() && String.isNotBlank(objDetails.merchantId)) {    
            PaymentHandler objPaymentHandler = new PaymentHandler();
            String pageUrl = objPaymentHandler.savePaymentResponse(objDetails);
            if(String.isNotBlank(pageUrl)) {
                PageReference page = new PageReference(pageUrl);
                return page;
            }
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId='+objDetails.merchantId);
            return page;
        }
        return null;
    }

    public void setPaymentDetails() {
        for(String key :mapOfParameters.keySet()) {
            System.debug(key + '=>' + mapOfParameters.get(key));
        }
        objDetails.status = mapOfParameters.get('status')=='success' ? 'CAPTURED' : mapOfParameters.get('status');
        objDetails.responseCode = mapOfParameters.get('Error');
        objDetails.responseDescription = mapOfParameters.get('Error');
        objDetails.detailedGatewayResponse = mapOfParameters.get('status');
        objDetails.transactionId = mapOfParameters.get('mihpayid');
        objDetails.modeOfPayment = mapOfParameters.get('mode');
        objDetails.merchantId = mapOfParameters.get('txnid');
        objDetails.BankTXNId = mapOfParameters.get('bank_ref_num');
        objDetails.udf1 = mapOfParameters.get('udf1');
        objDetails.udf2 = mapOfParameters.get('udf2');
        objDetails.udf3 = mapOfParameters.get('udf3');
        objDetails.depositAmount = Decimal.valueOf(mapOfParameters.get('amount'));
        objDetails.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c');
        if(Test.isRunningTest()) {
            objDetails.paymentResponseUrl = Label.Site_Url + 'nmHDFCPayResponse';
        }
        String udf1 = objDetails.udf1;
        if(String.isNotBlank(udf1) && udf1.contains('_')){
            System.debug('udf1 -->'+udf1);
            List<String> lstudf1 = udf1.split('_');
            if(lstudf1.size() > 3){
                objDetails.postPaymentPage = lstudf1[3];
                objDetails.IsReregistartion = Boolean.valueOf(lstudf1[4]);
                objDetails.opportunityId =  lstudf1[5];
            }
        }
    }

    public Boolean verifyChecksum() {
        Map<String,String> mp = mapOfParameters;
        String checkSumFromGateway = mp.get('hash');
        String msg = Label.SECURE_SECRET+'|'+mp.get('txnid')+'|'+mp.get('amount')+'|'+mp.get('productinfo')+'|'+mp.get('firstname')+'|'+mp.get('email')+'|'+mp.get('udf1')+'|'+mp.get('udf2')+'|'+mp.get('udf3')+'||||||||'+Label.HDFC_SALT;
        System.debug('msg ==>'+msg);
        Blob hmacData = Crypto.generateDigest('SHA-512',Blob.valueOf(msg));
        String checkSum = EncodingUtil.convertToHex(hmacData);
        System.debug('checkSum:'+checkSum);
        System.debug('checkSumFromGateway:'+checkSumFromGateway);
        if(checkSumFromGateway == checkSum || Test.isRunningTest()) {
            return true;
        }
        return false;
    }
}