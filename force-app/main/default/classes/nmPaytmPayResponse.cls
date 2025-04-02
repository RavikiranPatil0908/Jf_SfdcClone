/**
 * @File Name          : nmPaytmPayResponse.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 03-18-2023
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    22/3/2019, 5:41:38 PM   Balakrishnan     Initial Version
**/
public class nmPaytmPayResponse {

    //Payment Response
    public Map<String,String> mapOfParameters {get;set;}
    public PaymentHandler.PaymentResponseWrapper objDetails {get;set;}
    public String results {get;set;}

    public nmPaytmPayResponse() {

        objDetails = new PaymentHandler.PaymentResponseWrapper();
        mapOfParameters = ApexPages.currentPage().getParameters();
        // to set payment details
        setPaymentDetails();
        if(String.isNotBlank(objDetails.postPaymentPage) && objDetails.postPaymentPage !='NA'){
            results = 'REDIRECT='+Label.Site_Url+objDetails.postPaymentPage+'?ResTrackId='+objDetails.merchantId;
        }else{
            results = 'REDIRECT='+objDetails.paymentResponseUrl+'?ResTrackId='+objDetails.merchantId;
        }
    }

  /**
  * @description
  * @author Balakrishnan | 26/3/2019
  * @return PageReference
  */
    public PageReference StorePaymentInSystem()  {
        System.debug('EnterPaymentFunction');
        Boolean verifyCheckSum = false;
        
        // To query the upGrad payment credential details.
        List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,isActive__c,Paytm_EncryptionKey__c,Paytm_IndustryId__c,Paytm_MID__c,Paytm_Website_Key__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];
        PaymentConfigurationParameters__c objPCP = new PaymentConfigurationParameters__c();
        if(lstPaymentConfigdetails.size() > 0) {
            objPCP = lstPaymentConfigdetails[0];
        }
        
        String checkSumHash = checkMapContainsKeyOrNot('CHECKSUMHASH', mapOfParameters);
        if(String.isNotBlank(checkSumHash)) {
            verifyCheckSum = CheckSumServiceHelper.getCheckSumServiceHelper().verifycheckSum(Label.Paytm_Encryption_Key, mapOfParameters, checkSumHash);
            // For MBA (X) upGrad Program check.
            if(!verifyCheckSum && lstPaymentConfigdetails.size() > 0){
                verifyCheckSum = CheckSumServiceHelper.getCheckSumServiceHelper().verifycheckSum(objPCP.Paytm_EncryptionKey__c, mapOfParameters, checkSumHash);
            }
        }
        System.debug('verifyCheckSum -->'+verifyCheckSum);

        if(verifyCheckSum && String.isNotBlank(objDetails.merchantId)) {
            PaymentHandler objPaymentHandler = new PaymentHandler();
            String pageUrl = objPaymentHandler.savePaymentResponse(objDetails);
            if(String.isNotBlank(pageUrl)) {
                PageReference page = new PageReference(pageUrl);
                return page;
            }
            PageReference page = new PageReference(objDetails.paymentResponseUrl+'?ResTrackId='+objDetails.merchantId);
            return page;
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 03-18-2023 
    **/
    public void setPaymentDetails() {
        for(String key :mapOfParameters.keySet()) {
            System.debug(key + '=>' + mapOfParameters.get(key));
        }
        objDetails.status = checkMapContainsKeyOrNot('STATUS',mapOfParameters);
        objDetails.responseCode = checkMapContainsKeyOrNot('RESPCODE',mapOfParameters);
        objDetails.responseDescription = responseCodeVsResponse(objDetails.responseCode);
        objDetails.detailedGatewayResponse = checkMapContainsKeyOrNot('RESPMSG',mapOfParameters);
        objDetails.transactionId = checkMapContainsKeyOrNot('TXNID',mapOfParameters);
        objDetails.modeOfPayment = checkMapContainsKeyOrNot('PAYMENTMODE',mapOfParameters);
        objDetails.merchantId = checkMapContainsKeyOrNot('ORDERID',mapOfParameters);
        objDetails.BankTXNId = checkMapContainsKeyOrNot('BANKTXNID',mapOfParameters);
        objDetails.udf1 = checkMapContainsKeyOrNot('MERC_UNQ_REF',mapOfParameters);
        objDetails.depositAmount = Decimal.valueOf(mapOfParameters.get('TXNAMOUNT'));
        objDetails.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentResponseUrl_Paytm__c');
        if(Test.isRunningTest()) {
            objDetails.paymentResponseUrl = Label.Site_Url + 'nmPaytmPayResponse';
        }
        String udf1 = objDetails.udf1;
        String status = objDetails.status;
        if(String.isNotBlank(udf1) && udf1.contains('_')){
            System.debug('udf1 -->'+udf1);
            List<String> lstudf1 = udf1.split('_');
            if(lstudf1.size() > 3){
                objDetails.postPaymentPage = lstudf1[3];
                objDetails.IsReregistartion = Boolean.valueOf(lstudf1[4]);
                objDetails.opportunityId =  lstudf1[5];
                String csRes = lstudf1[6];
                String IsliveLect = lstudf1[7];
                String cousrList = lstudf1[8];
                String Coursera = lstudf1.size() >= 10 ? lstudf1[9] : 'false';
                objDetails.udf2 = csRes+'_'+IsliveLect+'_'+cousrList+'_'+Coursera;
                objDetails.udf3 = lstudf1.size() >= 11 ? lstudf1[10] : '';
            }
        }
        
        if(String.isNotBlank(status) && status.toUpperCase() == 'TXN_SUCCESS') {
            objDetails.status = 'CAPTURED';
        } else if (String.isNotBlank(status) && status.toUpperCase() == 'PENDING') {
            objDetails.status = 'pending';
        } else {
            objDetails.status = 'failure';
        }
    }

    /**
    * @description
    * @author Balakrishnan | 26/3/2019
    * @param String code
    * @return String
    */
    public String responseCodeVsResponse(String code) {
        String ResponseString = '';
        Map<String,String> MapOfResponseCodeVsResponse = new Map<String,String> {
            '01'=>'Txn Successful','202'=>'User does not have enough credit limit. Bank has declined the transaction','295'=>'No Description available',
            '205'=>'Transaction has been declined by the bank.','207'=>'Card used by customer has expired','330'=>'Paytm checksum mismatch',
            '208'=>'Transaction has been declined by the acquirer bank.','209'=>'Card details entered by the user is/are invalid.',
            '210'=>'Lost Card received','220'=>'Bank communication error','222'=>'Transaction amount return by the gateway does not match with Paytm transaction amount',
            '227'=>'Txn Failed','229'=>'3D Secure Verification failed','232'=>'Invalid account details','297'=>'Cancel and Redirect to 3D Page',
            '296'=>'We are facing problem at bank`s end. Try using another Payment mode','810'=>'Closed after page load','3102'=>'Invalid card details',
            '401'=>'Abandoned transaction','402'=>'Transaction abandoned from CCAvenue','2271'=>'User cancelled the transaction on banks net banking page',
            '2272'=>'User cancelled the transaction from 3D secure/OTP page' 
        };
        if(MapOfResponseCodeVsResponse.containsKey(code)) {
            ResponseString = MapOfResponseCodeVsResponse.get(code);
        }
        return ResponseString;
    }

    /**
    * @description
    * @author @BK | 23/4/2019
    * @param String field
    * @param Map<String, String> mapOfResponseParameters
    * @return String
    */
    public String checkMapContainsKeyOrNot(String field ,Map<String,String> mapOfResponseParameters){
        if(mapOfResponseParameters.containsKey(field)){
            return mapOfResponseParameters.get(field);
        }
        return null;
    }
}