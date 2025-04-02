/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : @BK
**/
public class nmICICIPayResponse {
    // Payment Response
    public String orderId {get;set;}
    public String orderToken {get;set;}
    public String results {get;set;}
    public PaymentDetails objDetails {get;set;}

    public nmICICIPayResponse() {
        orderId = ApexPages.currentPage().getParameters().get('order_id');
        orderToken = ApexPages.currentPage().getParameters().get('order_token');
        objDetails = new PaymentDetails();

        if(String.isBlank(orderId)) {
            results = 'REDIRECT='+nmCommon.getConfigSettings('nm_PaymentResponseUrl_ICICI__c');
        }
    }

    public PageReference StorePaymentInSystem() { 
        if(String.isNotBlank(orderId)) {
            fetchOrder();
            PaymentHandler objPaymentHandler = new PaymentHandler();
            PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
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
            objReqWrapper.merchantId = orderId;
            objReqWrapper.BankTXNId = objDetails.BankTXNId;
            objReqWrapper.status = objDetails.strTransitionstatus;
            objReqWrapper.responseDescription = objDetails.strErrorMessage;
            objReqWrapper.responseCode = objDetails.responseCode;
            objReqWrapper.detailedGatewayResponse = objDetails.strErrorMessage;
            objReqWrapper.currencyCode = objDetails.currencyOfPayment;
            objReqWrapper.feeChrages = 0;
            objReqWrapper.tax = 0;

            String pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
            if(String.isNotBlank(pageUrl)) {
                PageReference page = new PageReference(pageUrl);
                return page;
            }
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId='+orderId);
            return page;
        } else {
            PageReference page = new PageReference(nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'?ResTrackId=');
            return page;
        }
    }

    public void fetchOrder() { 
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        String paymentUri = nmCommon.getConfigSettings('ICICI_Base_Url__c')+'/orders/'+orderId;
        req.setEndpoint(paymentUri);
        req.setMethod('GET');
        req.setHeader('Accept','application/json');
        req.setHeader('x-api-version','2022-01-01');
        req.setHeader('x-client-id',Label.ICICI_App_Id);
        req.setHeader('x-client-secret',Label.ICICI_Secret_Key);

        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('RESULT ===>'+result);
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                if(mapOfResponseParameters.containskey('order_token') && orderToken == (String)mapOfResponseParameters.get('order_token')) {
                    Map<String,Object> mapOfOrderTags = (Map<String,Object>)mapOfResponseParameters.get('order_tags');
                    Map<String,Object> mapOfpaymentsUrl = (Map<String,Object>)mapOfResponseParameters.get('payments');
                    objDetails.udf1 = (String)mapOfOrderTags.get('udf1');
                    objDetails.udf2 = (String)mapOfOrderTags.get('udf2');
                    objDetails.udf3 = (String)mapOfOrderTags.get('udf3');
                    objDetails.currencyOfPayment = (String)mapOfResponseParameters.get('order_currency');
                    paymentUri = (String)mapOfpaymentsUrl.get('url');
                    objDetails.postPaymentPage = objDetails.udf1.split('_')[3];
                    // objDetails.depositAmount = Decimal.valueOf(objDetails.udf1.split('_')[2]);
                    System.debug('Payment Amount==>'+mapOfResponseParameters.get('order_amount'));
                    objDetails.depositAmount = (Decimal)mapOfResponseParameters.get('order_amount');
                    System.debug('Deposit Amount==>'+objDetails.depositAmount);
                    objDetails.IsReregistartion = Boolean.valueOf(objDetails.udf1.split('_')[4]);
                    objDetails.opportunityId = objDetails.udf1.split('_')[5];
                    String orderStatus = (String)mapOfResponseParameters.get('order_status');
                    // if(orderStatus == 'PAID') {
                        fetchPayment(paymentUri);
                    // }
                }
                System.debug('mapOfResponseParameters ==>'+mapOfResponseParameters);
            }
        }catch(Exception e){
            System.debug('Callout Exception Order_API :'+e.getMessage());
        }
    }

    public void fetchPayment(String paymentUri) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(paymentUri);
        req.setMethod('GET');
        req.setHeader('Accept','application/json');
        req.setHeader('x-api-version','2022-01-01');
        req.setHeader('x-client-id',Label.ICICI_App_Id);
        req.setHeader('x-client-secret',Label.ICICI_Secret_Key);

        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('RESULT ===>'+result);
                List<Object> lstObjects = (List<Object>)Json.deserializeuntyped(result);
                System.debug(lstObjects);
                if(lstObjects.size() > 1) {
                    Boolean paymentSuccess = false;
                    for (Object objResponse : lstObjects) {
                        if(setPaymentDetails(objResponse,false)) {
                            paymentSuccess = true;
                        }
                    }
                    if(!paymentSuccess) {
                        setPaymentDetails(lstObjects[0],true);
                    }
                } else if(lstObjects.size() == 1) {
                    setPaymentDetails(lstObjects[0],true);
                }
            }
        }catch(Exception e){
            System.debug('Callout Exception Payment_API :'+e.getMessage());
        }  
    }

    public Boolean setPaymentDetails(Object objResponse, Boolean skipSuccess) {
        Map<String,Object> mapOfPayResponse = (Map<String,Object>)objResponse;
        if((mapOfPayResponse.containskey('payment_status') && mapOfPayResponse.get('payment_status') == 'SUCCESS') || skipSuccess) {
            objDetails.strTransitionstatus = (String)mapOfPayResponse.get('payment_status');
            objDetails.modeOfPayment = (String)mapOfPayResponse.get('payment_group');
            objDetails.BankTXNId = (String)mapOfPayResponse.get('bank_reference');
            objDetails.strTransitionstatus = objDetails.strTransitionstatus == 'SUCCESS' ? 'CAPTURED' : objDetails.strTransitionstatus;
            objDetails.strErrorMessage = objDetails.strTransitionstatus == 'CAPTURED' ? 'Txn Successful' : (String)mapOfPayResponse.get('payment_message');
            objDetails.responseCode = (String)mapOfPayResponse.get('payment_status');
            objDetails.transactionId = String.valueOf(mapOfPayResponse.get('cf_payment_id'));
        }
        return objDetails.strTransitionstatus == 'CAPTURED' ? true : false;
    }

    public class PaymentDetails { 
        public String postPaymentPage {get;set;}
        public String udf1 {get;set;}
        public String udf2 {get;set;}
        public String udf3 {get;set;}
        public Decimal depositAmount {get;set;}
        public Boolean IsReregistartion {get;set;}
        public String opportunityId {get;set;}
        public String transactionId {get;set;}
        public String modeOfPayment {get;set;}
        public String BankTXNId {get;set;}
        public String currencyOfPayment {get;set;}
        public String strTransitionstatus {get;set;}
        public String strErrorMessage {get;set;}
        public String responseCode {get;set;}

        public PaymentDetails() {
            this.postPaymentPage = '';
            this.udf1 = '';
            this.udf2 = '';
            this.udf3 = '';
            this.depositAmount = 0;
            this.IsReregistartion = false;
            this.opportunityId = '';
            this.transactionId = '';
            this.modeOfPayment = '';
            this.BankTXNId = '';
            this.currencyOfPayment = 'INR';
            this.strTransitionstatus = '';
            this.strErrorMessage = '';
            this.responseCode = '';
        }
    }
}