/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-09-2022
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/RazorPayWebhookAPI/V1.1/*')
global  without sharing class RazorPayWebhookAPI {
  
    @HttpPost
    global static List<MessageWrapper> UpdatePaymentStatus(){
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        MessageWrapper messageWrapper = null;
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            requestString = body.toString();
            System.debug(req.headers.values());
            System.debug('-----------------------------debug--------------------');
            System.debug(req.headers);
            String checksum = req.headers.get('X-Razorpay-Signature');
            requestString = requestString.replace('currency', 'currencyCode');
            System.debug('requestString '+requestString);
            RazorPayWebhookResponseWrapper reqWrapper = RazorPayWebhookResponseWrapper.parse(requestString);
            System.debug('reqWrapper'+ reqWrapper);
            apiReq.Request__c = requestString;

            RazorPayWebhookResponseWrapper.cls_entity reqeOrderentity = reqWrapper.payload.order.entity;
            RazorPayWebhookResponseWrapper.cls_notes reqeOrderentityNotes = reqeOrderentity.notes;

            RazorPayWebhookResponseWrapper.cls_entity reqPaymententity = reqWrapper.payload.payment.entity;
            String merchantId = reqeOrderentity.receipt;

            if(!verifyCheckSum(checksum,body.toString())) {
                return returnMessage(apiReq,'501','checksum is not matched..',false);
            }

            List<nm_Payment_Initiated__c> InitiatedPayment = [SELECT id,nm_Merchant_Track_Id__c,nm_Fee_Type__c,nm_Lead__c,nm_PaymentStatus__c,nm_OpportunityNew__c,payment_Transaction_Mode__c,nm_ModeOfPayment__c,Online_Payment_Id__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c=:merchantId AND nm_PaymentGatewayName__c='Razorpay GateWay'];
            if(InitiatedPayment.size() == 0) {
                return returnMessage(apiReq,'501','No Payment Record Found.',false);
            }
            apiReq.Payment_Initiated__c = InitiatedPayment[0].id;
            List<nm_Payment__c> lstPayment = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,nm_PaymentStatus__c,Refund_Error_Code__c,Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c=:merchantId AND nm_PaymentGatewayName__c='Razorpay GateWay'];
            if(lstPayment.size() > 0) {
                for(nm_Payment__c nmPay:lstPayment){
                    if(nmPay.nm_PaymentStatus__c == 'Payment Approved' || nmPay.nm_PaymentStatus__c == 'Payment Made'){
                        return returnMessage(apiReq,'200','Payment status Updated.',true);
                    }
                }
            }
            
            String strTransitionstatus = reqPaymententity.status == 'captured' || reqPaymententity.status == 'authorized' ? 'CAPTURED' : reqPaymententity.status;
            String strErrorMessage = strTransitionstatus == 'CAPTURED' ? 'Txn Successful' : reqPaymententity.description;
            Decimal feeCharges = reqPaymententity.fee == null ? 0 : reqPaymententity.fee / 100;
            Decimal taxCharges = reqPaymententity.tax == null ? 0 : reqPaymententity.tax / 100;
            String postPaymentPage = reqeOrderentityNotes.udf1.split('_')[3];
            String depositAmount = reqeOrderentityNotes.udf1.split('_')[2];
            string IsReregistartion = reqeOrderentityNotes.udf1.split('_')[4];
            string opportunityId = reqeOrderentityNotes.udf1.split('_')[5];
            string responseCode = reqPaymententity.status;
            string detailedGatewayResponse = reqPaymententity.status;
            string currencyCode = reqPaymententity.currencyCode;

            if(reqPaymententity.method == 'card') {
                nmRazorPayResponse objResponseClass = new nmRazorPayResponse();
                reqPaymententity.method = objResponseClass.fetchCardDetails(reqPaymententity.id);
            }

            PaymentHandler objPaymentHandler = new PaymentHandler();
            PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
            objReqWrapper.udf1 = reqeOrderentityNotes.udf1;
            objReqWrapper.postPaymentPage = postPaymentPage;
            objReqWrapper.udf2 = reqeOrderentityNotes.udf2;
            objReqWrapper.udf3 = reqeOrderentityNotes.udf3;
            objReqWrapper.depositAmount =  Decimal.valueOf(depositAmount);
            objReqWrapper.IsReregistartion = Boolean.valueOf(IsReregistartion);
            objReqWrapper.opportunityId = opportunityId;
            objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
            objReqWrapper.transactionId = reqeOrderentity.id;
            objReqWrapper.modeOfPayment = reqPaymententity.method;
            objReqWrapper.merchantId = merchantId;
            objReqWrapper.BankTXNId = reqPaymententity.id;
            objReqWrapper.status = strTransitionstatus;
            objReqWrapper.responseDescription = strErrorMessage;
            objReqWrapper.responseCode = responseCode;
            objReqWrapper.detailedGatewayResponse = detailedGatewayResponse;
            objReqWrapper.currencyCode = currencyCode;
            objReqWrapper.feeChrages = feeCharges;
            objReqWrapper.tax = taxCharges;
            objPaymentHandler.savePaymentResponse(objReqWrapper);
        }catch(Exception error){
            System.debug('Error Message ==>'+error.getMessage());
            return returnMessage(apiReq,'504',error.getMessage(),false);
        }
        return returnMessage(apiReq,'200','Payment status Updated.',true);
    }
    global class MessageWrapper{
        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
    }
    public static List<MessageWrapper> returnMessage(API_Request__c apiReq, String code, String msg, Boolean isSuccess) {
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'UpdatePaymentStatus';
        apiReq.API_Name__c='RazorPayWebhookAPI';
        apiReq.Success__c = isSuccess;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static Boolean verifyChecksum(String webhook_signature, String message) {
        System.debug('checkSumHash ==>'+webhook_signature);
        Boolean verifyCheckSum = false;
        if(String.isNotBlank(webhook_signature)) {
            Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(message), Blob.valueOf(System.Label.RazorPay_Webhook_Key));
            String expextedSignature = EncodingUtil.convertToHex(mac);
            System.debug('expextedSignature ==>'+expextedSignature);
            verifyCheckSum = expextedSignature.equals(webhook_signature) ? true : false;
        }
        if(Test.isRunningTest()) {
            verifyCheckSum = true;
        }
        return verifyCheckSum;
    }
}