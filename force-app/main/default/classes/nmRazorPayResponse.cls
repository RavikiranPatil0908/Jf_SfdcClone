/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-09-2022
 * @last modified by  : @BK
**/
public without sharing class nmRazorPayResponse {

    public Map<String,String> mapOfParameters {get;set;}
    public String results {get;set;}
    public String orderId {get;set;}
    public String paymentId {get;set;}
    public PaymentHandler.PaymentResponseWrapper objReqWrapper {get;set;}

    public nmRazorPayResponse() {

        mapOfParameters = ApexPages.currentPage().getParameters();
        orderId = null;
        objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
        for(String key :mapOfParameters.keySet()) {
            System.debug(key + '=>' + mapOfParameters.get(key));
        }
        if(mapOfParameters.containsKey('razorpay_order_id')) {
            orderId = mapOfParameters.get('razorpay_order_id');
            paymentId = mapOfParameters.get('razorpay_payment_id');
        } else if(mapOfParameters.containsKey('error[metadata]')) {
            Map<String,Object> mapOfKeys = (Map<String,Object>)JSON.deserializeUntyped(mapOfParameters.get('error[metadata]'));
            orderId = (String)mapOfKeys.get('order_id');
            paymentId = (String)mapOfKeys.get('payment_id');
        }
        
        if(String.isBlank(orderId)) {
            results = 'REDIRECT='+nmCommon.getConfigSettings('nm_PaymentResponseUrl_Razorpay__c');
        }
    }

    /**
    * @description : To process the payment and create the payment record.
    * @author @BK | 20-09-2022 
    * @return PageReference 
    **/
    public PageReference StorePaymentInSystem() {
        API_Request__c apiReq = new API_Request__c();
        apiReq.Request__c = JSON.serialize(mapOfParameters);
        apiReq.Success__c = false;
        apiReq.Type_of_Request__c= 'UpdatePaymentStatus';
        apiReq.API_Name__c='RazorPayGatewayRespone';
        System.debug('EnterPaymentFunction');
        if(String.isNotBlank(orderId) && verifySignature()) { 
            List<nm_Payment_Initiated__c> lstPaymentInitated = [SELECT id,OrderId__c,nm_Merchant_Track_Id__c,Additional_param1__c,Additional_param2__c FROM nm_Payment_Initiated__c WHERE OrderId__c=:orderId LIMIT 1];
            apiReq.Payment_Initiated__c = lstPaymentInitated.size() > 0 ? lstPaymentInitated[0].id : null;
            apiReq.Response__c = 'Success';
            apiReq.Success__c = true;
            if(mapOfParameters.containsKey('error[code]') && mapOfParameters.get('error[code]') == 'PAYMENT_FAILED') {
                //user cancelled the tramsaction.
                transactionCancelled(lstPaymentInitated);
            } else {
                //to fetch the Payment.
                fetchOrder(lstPaymentInitated);
            }
            
            // to fetch the card details
            if(objReqWrapper.modeOfPayment == 'card' && objReqWrapper.status == 'CAPTURED') {
                objReqWrapper.modeOfPayment = fetchCardDetails(objReqWrapper.BankTXNId);
            }

            PaymentHandler objPaymentHandler = new PaymentHandler();
            objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
            objReqWrapper.merchantId = lstPaymentInitated.size() > 0 ? lstPaymentInitated[0].nm_Merchant_Track_Id__c : null;

            insert apiReq;
            System.debug(objReqWrapper);
            String pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
            if(String.isNotBlank(pageUrl)) {
                System.debug('pageUrl =>'+pageUrl);
                PageReference page = new PageReference(pageUrl);
                return page;
            }
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId='+objReqWrapper.merchantId);
            return page;
        } else {
            insert apiReq;
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId=');
            return page;
        }
    }

    /**
    * @description : To verify payment signature.
    * @author @BK | 20-09-2022 
    * @return Boolean 
    **/
    public Boolean verifySignature() {
        if(mapOfParameters.containsKey('razorpay_signature')) {
            String salt = String.valueOf(orderId +'|'+ paymentId);
            Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(Label.RazorPay_key_secret));
            String generatedSignature = EncodingUtil.convertToHex(data);
            if(mapOfParameters.get('razorpay_signature') == generatedSignature) {
                return true;
            } else {
                return false;
            }
        } else if(mapOfParameters.containsKey('error[code]')) {
            return true;
        } 
        return false;
    }


    /**
    * @description : To get the payment details from the Order API.
    * @author @BK | 20-09-2022 
    * @param lstPaymentInitated 
    **/
    public void fetchOrder(List<nm_Payment_Initiated__c> lstPaymentInitated) {
        Blob headerValue = Blob.valueOf(Label.RazorPay_key_id +':'+Label.RazorPay_key_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        String paymentUri = nmCommon.getConfigSettings('Razorpay_Order_Url__c');
        req.setEndpoint(paymentUri+'/'+orderId+'/payments');
        req.setMethod('GET');
        req.setHeader('Authorization',authorizationHeader);
        System.debug('Request --->'+req.getBody());
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('RESULT ===>'+result);
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                List<Object> lstPaymentItems = (List<Object>)mapOfResponseParameters.get('items');
                System.debug(lstPaymentItems);
                if(lstPaymentItems.size() > 1) {
                    Boolean paymentSuccess = false;
                    for (Object objResponse : lstPaymentItems) {
                        if(setPaymentDetails(objResponse,false)) {
                            paymentSuccess = true;
                        }
                    }
                    if(!paymentSuccess) {
                        setPaymentDetails(lstPaymentItems[0],true);
                    }
                } else if(lstPaymentItems.size() == 1) {
                    setPaymentDetails(lstPaymentItems[0],true);
                } else {
                    transactionCancelled(lstPaymentInitated);
                }
            }
        }catch(Exception e){
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
        }
    }

    /**
    * @description : To set the payment values from the API.
    * @author @BK | 20-09-2022 
    * @param objResponse 
    * @param skipSuccess 
    * @return Boolean 
    **/
    public Boolean setPaymentDetails(Object objResponse, Boolean skipSuccess) {
        Map<String,Object> mapOfPayResponse = (Map<String,Object>)objResponse;
        if((mapOfPayResponse.containskey('status') && mapOfPayResponse.get('status') == 'captured') || skipSuccess) {
            objReqWrapper.status = (String)mapOfPayResponse.get('status');
            objReqWrapper.modeOfPayment = (String)mapOfPayResponse.get('method');
            objReqWrapper.BankTXNId = (String)mapOfPayResponse.get('id');
            objReqWrapper.status = objReqWrapper.status == 'captured' ? 'CAPTURED' : objReqWrapper.status;
            objReqWrapper.responseDescription = objReqWrapper.status == 'CAPTURED' ? 'Txn Successful' : (String)mapOfPayResponse.get('error_description');
            objReqWrapper.detailedGatewayResponse = objReqWrapper.responseDescription;
            objReqWrapper.responseCode = (String)mapOfPayResponse.get('error_code');
            objReqWrapper.transactionId = (String)mapOfPayResponse.get('order_id');
            objReqWrapper.currencyCode = (String)mapOfPayResponse.get('currency');
            Map<String,Object> mapOfOrderTags = (Map<String,Object>)mapOfPayResponse.get('notes');
            objReqWrapper.udf1 = (String)mapOfOrderTags.get('udf1');
            objReqWrapper.udf2 = (String)mapOfOrderTags.get('udf2');
            objReqWrapper.udf3 = (String)mapOfOrderTags.get('udf3');
            objReqWrapper.postPaymentPage = objReqWrapper.udf1.split('_')[3];
            objReqWrapper.depositAmount = Decimal.valueOf(objReqWrapper.udf1.split('_')[2]);
            objReqWrapper.IsReregistartion = Boolean.valueOf(objReqWrapper.udf1.split('_')[4]);
            objReqWrapper.opportunityId = objReqWrapper.udf1.split('_')[5];
            objReqWrapper.feeChrages = (Decimal)mapOfPayResponse.get('fee') / 100;
            objReqWrapper.tax = (Decimal)mapOfPayResponse.get('tax') / 100;
        }
        return objReqWrapper.status == 'CAPTURED' ? true : false;
    }

    /**
    * @description : To set default values if user cancelled the transactions.
    * @author @BK | 20-09-2022 
    * @param lstPaymentInitated 
    **/
    public void transactionCancelled(List<nm_Payment_Initiated__c> lstPaymentInitated) {
        if(lstPaymentInitated.size() > 0) {
            nm_Payment_Initiated__c obj = lstPaymentInitated[0];
            objReqWrapper.udf1 = obj.Additional_param1__c;
            objReqWrapper.udf2 = obj.Additional_param2__c;
            objReqWrapper.postPaymentPage = obj.Additional_param1__c.split('_')[3];
            objReqWrapper.depositAmount = Decimal.valueOf(obj.Additional_param1__c.split('_')[2]);
            objReqWrapper.IsReregistartion = Boolean.valueOf(obj.Additional_param1__c.split('_')[4]);
            objReqWrapper.opportunityId = obj.Additional_param1__c.split('_')[5];
            objReqWrapper.responseCode = (String)mapOfParameters.get('error[code]');
            objReqWrapper.responseDescription = 'User cancelled the transaction';
            objReqWrapper.status = 'failed';
            objReqWrapper.detailedGatewayResponse = objReqWrapper.responseDescription;
            objReqWrapper.transactionId = (String)mapOfParameters.get('razorpay_order_id');
        }
    }

    /**
    * @description : To Fetch Card Details
    * @author @BK | 20-09-2022 
    * @param paymentId 
    * @return String 
    **/
    public String fetchCardDetails(String paymentId) {
        Blob headerValue = Blob.valueOf(Label.RazorPay_key_id +':'+Label.RazorPay_key_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        String paymentUri = nmCommon.getConfigSettings('Razorpay_Payment_Url__c');
        req.setEndpoint(paymentUri+paymentId+'/card');
        req.setMethod('GET');
        req.setHeader('Authorization',authorizationHeader);
        System.debug('Request --->'+req.getBody());
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('RESULT ===>'+result);
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                return (String)mapOfResponseParameters.get('type') + ' card';
            }
        }catch(Exception e){
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
        }
        return 'card';
    }
}