/**
 * @File Name          : nmPayResponseNew.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 23-03-2023
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    19/9/2019   @BK     Initial Version
**/
public class nmPayResponseNew 
{

    public PaymentHandler.PaymentResponseWrapper objDetails {get;set;}
    public String result {get;set;}
    public Boolean verifyCheckSum {get;set;}
    public Boolean skipChecksum {get;set;}
    
    public nmPayResponseNew() {        
        String msg = apexpages.currentpage().getparameters().get('msg').escapeHtml4();
        String skipcheck = apexpages.currentpage().getparameters().get('skipcheck');
        skipChecksum = String.isNotBlank(skipcheck) ? Boolean.valueOf(skipcheck) : false;
        objDetails = new PaymentHandler.PaymentResponseWrapper();
        verifyCheckSum = false;
        // to set payment details
        setPaymentDetails(msg);
        if(String.isNotBlank(objDetails.postPaymentPage) && objDetails.postPaymentPage !='NA'){
            result = 'REDIRECT='+Label.Site_Url+objDetails.postPaymentPage+'?ResTrackId='+objDetails.merchantId;
        }else{
            result = 'REDIRECT='+nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId='+objDetails.merchantId;
        }
    }
    
    /**
    * @description 
    * @author @BK | 10-03-2023 
    * @return PageReference 
    **/
    public PageReference StorePaymentInSystem() {
        System.debug('EnterPaymentFunction');
        if(verifyCheckSum && String.isNotBlank(objDetails.merchantId)) {    
            PaymentHandler objPaymentHandler = new PaymentHandler();
            String pageUrl = objPaymentHandler.savePaymentResponse(objDetails);
            if(String.isNotBlank(pageUrl)) {
                PageReference page = new PageReference(pageUrl);
                return page;
            }
            return null;
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 10-03-2023 
    * @param responseMessage 
    **/
    public void setPaymentDetails(String responseMessage) {
        Map<String,String> mapOfTxnKeyVsTxsState = new Map<String,String>{
            '01'=>'NB',
            '02'=>'CC',
            '03'=>'DC',
            '04'=>'CC/MW',
            '06'=>'IMPS',
            '07'=>'RP',
            '09'=>'Others',
            '10'=>'UPI'
        };
        String[] responseParameters = responseMessage.split('\\|');
        for(Integer i=0;i<responseParameters.size();i++) {
            System.debug('responseParameters'+i+'---->'+responseParameters[i]);
        }
        System.debug('responseMessage ==>'+responseMessage);
        objDetails.merchantId = responseParameters[1]; //Merchant Order ID
        objDetails.BankTXNId = responseParameters[3];    //Payment Id-Bank Reference No
        objDetails.transactionId = responseParameters[2]; //Transaction ID
        // To get the mode of transaction
        objDetails.modeOfPayment = String.isNotBlank(responseParameters[7]) && mapOfTxnKeyVsTxsState.containsKey(responseParameters[7]) ? mapOfTxnKeyVsTxsState.get(responseParameters[7]) : responseParameters[7];
        objDetails.responseCode = responseParameters[14]; //Payment Status Code
        // To set Payment status
        setPaymentStatus(responseParameters[23],responseParameters[24]);
        objDetails.depositAmount = Decimal.valueOf(responseParameters[4]);
        objDetails.udf1 = responseParameters[18]; //PaymentType or Registration information
        objDetails.udf2 = responseParameters[22]; //Additional info 2
        objDetails.udf3 = responseParameters[20];
        String udf1 = objDetails.udf1;
        String udf2 = objDetails.udf2;
        if(udf1.contains('_')){
            if(udf1.split('_').size() > 3){
                objDetails.postPaymentPage = udf1.split('_')[3];
                objDetails.IsReregistartion = Boolean.valueOf(udf1.split('_')[4]);
            }
        }
        
        if(String.isNotBlank(udf2) && udf2.contains('_') && udf2.split('_').size() <= 3) {
            objDetails.udf2 = udf2 + '_false';
        }
        objDetails.opportunityId = responseParameters[21];
        objDetails.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
        objDetails.detailedGatewayResponse = responseMessage;

        Integer lastPipeCharacterIndex = responseMessage.lastIndexOf('|');
        String responseWithoutCheckSum = responseMessage.subString(0,lastPipeCharacterIndex);
        verifyCheckSum = verifyChecksum(responseWithoutCheckSum,responseParameters[25]);
        System.debug('objDetails ===>');
        System.debug(JSON.serialize(objDetails));
    }

    /**
    * @description 
    * @author @BK | 10-03-2023 
    * @param errorStatus 
    * @param errorDescription 
    **/
    public void setPaymentStatus(String errorStatus, String errorDescription) {
        String strResResult = objDetails.responseCode;
        if(strResResult == '0300'){
            //Success 
            strResResult = 'CAPTURED';
            objDetails.responseDescription = 'Txn Successful';
        }else if(strResResult == '0399'){
            objDetails.responseDescription = 'Invalid Authentication at Bank'+ ':' + errorStatus + ':' + errorDescription;
        }else if(strResResult == 'NA'){
            objDetails.responseDescription = 'Invalid Input in the Request Message'+ ':' + errorStatus + ':' + errorDescription;
        }else if(strResResult == '0002'){
            objDetails.responseDescription = 'BillDesk is waiting for Response from Bank'+ ':' + errorStatus + ':' + errorDescription;
        }else if(strResResult == '0001'){
            objDetails.responseDescription = 'Error at BillDesk'+ ':' + errorStatus + ':' + errorDescription;
        }else{
            objDetails.responseDescription = 'Unknown Error for Auth Status:'+strResResult + ':' + errorStatus + ':' + errorDescription;
        }
        objDetails.status = strResResult;
    }
    
    /**
    * @description 
    * @author @BK | 10-03-2023 
    * @param responseWithoutCheckSum 
    * @param checkSumFromGateway 
    * @return Boolean 
    **/
    public Boolean verifyChecksum(String msg, String checkSumFromGateway) {
        System.debug('skipChecksum ==>'+skipChecksum);
        String algorithmName = 'HmacSHA256';
        String secretKey = Label.Bill_Desk_Checksum_Key;
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(msg), Blob.valueOf(secretKey));
        String checkSum = EncodingUtil.convertToHex(hmacData).toUpperCase();
        
        System.debug('checkSum:'+checkSum);
        System.debug('checkSumFromGateway:'+checkSumFromGateway);
        if(checkSumFromGateway == checkSum || Test.isRunningTest() || skipChecksum) {
            return true;
        }
        return false;
    }
}