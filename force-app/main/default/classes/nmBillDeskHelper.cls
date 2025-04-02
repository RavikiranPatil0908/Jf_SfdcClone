public class nmBillDeskHelper {
    public nmBillDeskHelper() {

    }

    public Static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    public Static Boolean hmacSHA256Verification(String header, String payload, String signature, String secretKey) {
        blob resSignature = Crypto.generateMac('hmacSHA256',Blob.valueof(header + '.' + payload),blob.valueof(secretKey));
        if (base64URLencode(resSignature) == signature ) {
            return true;
        }
        return false;
    }

    public static String generateTraceId() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        return EncodingUtil.convertToHex(hash);
    }


    public static PaymentDetails setPaymentDetails(PaymentDetails objDetails, String encodedTransaction) {
        Map<String, Object> MapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped((EncodingUtil.base64decode(encodedTransaction)).toString()); 
        Map<String,Object> mapOfAdditionalInfo = (Map<String,Object>)mapOfResponseParameters.get('additional_info');
        objDetails.udf1 = (String)mapOfAdditionalInfo.get('additional_info1');
        objDetails.udf2 = (String)mapOfAdditionalInfo.get('additional_info2');
        objDetails.udf3 = (String)mapOfAdditionalInfo.get('additional_info3');
        // objDetails.currencyOfPayment = (String)mapOfResponseParameters.get('currency');
        objDetails.postPaymentPage = objDetails.udf1.split('_')[3];
        System.debug('Payment Amount==>'+mapOfResponseParameters.get('amount'));
        objDetails.depositAmount = Decimal.valueOf((String)mapOfResponseParameters.get('amount'));
        System.debug('Deposit Amount==>'+objDetails.depositAmount);
        objDetails.feeChrages = Decimal.valueOf((String)mapOfResponseParameters.get('surcharge'));
        objDetails.merchantId = (String)mapOfResponseParameters.get('orderid');
        objDetails.IsReregistartion = Boolean.valueOf(objDetails.udf1.split('_')[4]);
        objDetails.opportunityId = objDetails.udf1.split('_')[5];
        objDetails.strTransitionstatus = (String)mapOfResponseParameters.get('transaction_error_type');
        objDetails.modeOfPayment = (String)mapOfResponseParameters.get('payment_method_type');
        objDetails.BankTXNId = (String)mapOfResponseParameters.get('bankid');
        objDetails.responseCode = (String)mapOfResponseParameters.get('auth_status');
        objDetails.strTransitionstatus = objDetails.responseCode == '0300' ? 'CAPTURED' : objDetails.strTransitionstatus;
        objDetails.strErrorMessage = objDetails.strTransitionstatus == 'CAPTURED' ? 'Txn Successful' : (String)mapOfResponseParameters.get('transaction_error_desc');
        objDetails.strTransitionResponse = JSON.serialize(MapOfResponseParameters);
        objDetails.transactionId = String.valueOf(mapOfResponseParameters.get('transactionid'));
        objDetails.gatewayVersion = 'v2';
        String timestampStr = (String)mapOfResponseParameters.get('transaction_date');
        objDetails.transactionDateTime = Datetime.valueOf(timestampStr.replace('T', ' '));
        return objDetails;
    }

    public static PaymentHandler.PaymentResponseWrapper setPaymentResponseWrapper(PaymentHandler.PaymentResponseWrapper objReqWrapper, PaymentDetails objDetails) {
        objReqWrapper.postPaymentPage = objDetails.postPaymentPage;
        objReqWrapper.udf1 = objDetails.udf1;
        objReqWrapper.udf2 = objDetails.udf2;
        objReqWrapper.udf3 = objDetails.udf3;
        objReqWrapper.depositAmount = objDetails.depositAmount;
        objReqWrapper.IsReregistartion = objDetails.IsReregistartion;
        objReqWrapper.opportunityId = objDetails.opportunityId;
        objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
        objReqWrapper.transactionId = objDetails.transactionId;
        objReqWrapper.modeOfPayment = objDetails.modeOfPayment;
        objReqWrapper.BankTXNId = objDetails.BankTXNId;
        objReqWrapper.status = objDetails.strTransitionstatus;
        objReqWrapper.responseDescription = objDetails.strErrorMessage;
        objReqWrapper.responseCode = objDetails.responseCode;
        objReqWrapper.detailedGatewayResponse = objDetails.strTransitionResponse;
        objReqWrapper.currencyCode = objDetails.currencyOfPayment;
        objReqWrapper.feeChrages = 0;
        objReqWrapper.tax = 0;
        objReqWrapper.gatewayVersion = objDetails.gatewayVersion;
        objReqWrapper.transactionDateTime = objDetails.transactionDateTime;
        return objReqWrapper;
    }

    public static PaymentHandler.PaymentResponseWrapper setTransactionPaymentResponse(PaymentHandler.PaymentResponseWrapper objReqWrapper, nm_Payment_Initiated__c obj) {
        objReqWrapper.postPaymentPage = obj.Additional_param1__c.split('_')[3];
        objReqWrapper.udf1 =obj.Additional_param1__c;
        objReqWrapper.udf2 = obj.Additional_param2__c;
        objReqWrapper.depositAmount = obj.nm_ActualPaymentAmmount__c;
        objReqWrapper.IsReregistartion = Boolean.valueOf(obj.Additional_param1__c.split('_')[4]);
        objReqWrapper.opportunityId = obj.Additional_param1__c.split('_')[5];
        objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
        objReqWrapper.transactionId = '';
        objReqWrapper.modeOfPayment = 'Online';
        objReqWrapper.BankTXNId = '';
        objReqWrapper.status = 'failed';
        objReqWrapper.responseDescription = 'User cancelled the transaction';
        objReqWrapper.responseCode = '404';
        objReqWrapper.detailedGatewayResponse = objReqWrapper.responseDescription;
        objReqWrapper.currencyCode = 'INR';
        objReqWrapper.feeChrages = 0;
        objReqWrapper.tax = 0;
        objReqWrapper.gatewayVersion = 'v2';
        objReqWrapper.transactionDateTime = Datetime.now();
        objReqWrapper.merchantId = obj.nm_Merchant_Track_Id__c;
        return objReqWrapper;
    }

    public static String getTransactionResponseFromAPI(String orderId) {
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        String responseMsg = '';
        String headerJWS = '{"alg":"HS256","clientid":"' + BilldeskV2.Client_ID__c + '"}';
        String jsonBodyParam = '{"mercid":'+BilldeskV2.Merchant_ID__c+',"orderid":"'+orderId+'"}';
        string jwt = nmBillDeskHelper.base64URLencode(blob.valueof(headerJWS)) + '.' +nmBillDeskHelper.base64URLencode(blob.valueof(jsonBodyParam));
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),blob.valueof(BilldeskV2.Secret_Key__c));
        System.debug('Request --->'+jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
        String timestampUnix = String.valueOf(Datetime.now().getTime());
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        req.setEndpoint( BilldeskV2.Base_Url__c+'payments/ve1_2/transactions/get');
        req.setMethod('POST');
        req.setHeader('content-type', 'application/jose');
        req.setHeader('accept', 'application/jose');
        req.setHeader('bd-traceid', nmBillDeskHelper.generateTraceId());
        req.setHeader('bd-timestamp', timestampUnix );
        req.setBody(jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
        System.debug('Request -- '+orderId+' --->'+jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            String result = resp.getBody();
            System.debug('RESULT ===>'+result);
            if(statusCode == 200) {
                responseMsg = result;
            } 
            // else if(statusCode == 404) {
            //     responseMsg = 'Not Found';
            // }
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            System.debug('Error Message Line No ==>'+error.getLineNumber());
        }
        return responseMsg;
    }

    public class PaymentDetails { 
        public String postPaymentPage {get;set;}
        public String udf1 {get;set;}
        public String udf2 {get;set;}
        public String udf3 {get;set;}
        public String merchantId {get;set;}
        public Decimal depositAmount {get;set;}
        public Boolean IsReregistartion {get;set;}
        public String opportunityId {get;set;}
        public String transactionId {get;set;}
        public String modeOfPayment {get;set;}
        public String BankTXNId {get;set;}
        public String currencyOfPayment {get;set;}
        public String strTransitionstatus {get;set;}
        public String strErrorMessage {get;set;}
        public String strTransitionResponse {get;set;}
        public String responseCode {get;set;}
        public Decimal feeChrages {get;set;}
        public String gatewayVersion {get;set;}
        public DateTime transactionDateTime {get;set;}

        public PaymentDetails() {
            this.postPaymentPage = '';
            this.udf1 = '';
            this.udf2 = '';
            this.udf3 = '';
            this.merchantId = '';
            this.depositAmount = 0;
            this.IsReregistartion = false;
            this.opportunityId = '';
            this.transactionId = '';
            this.modeOfPayment = '';
            this.BankTXNId = '';
            this.currencyOfPayment = 'INR';
            this.strTransitionstatus = '';
            this.strErrorMessage = '';
            this.strTransitionResponse = '';
            this.feeChrages = 0;
            this.gatewayVersion = '';
            this.transactionDateTime = null;
        }
    }
}