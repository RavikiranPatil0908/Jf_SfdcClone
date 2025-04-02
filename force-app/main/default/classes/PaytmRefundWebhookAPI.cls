/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-03-2022
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/PaytmRefundWebhookAPI/V1.1/*')
global without sharing class PaytmRefundWebhookAPI {

    @HttpPost
    global static List<MessageWrapper> updateRefundStatus(){ 
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        MessageWrapper messageWrapper = null;
        String paymentId = null;
        try {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            requestString = body.toString();
            System.debug('requestString '+requestString);
            PaytmRefundWebhookResponseWrapper reqWrapper = PaytmRefundWebhookResponseWrapper.parse(requestString);
            apiReq.Request__c = requestString;
            System.debug(reqWrapper);

            String checksum = '';
            PaytmRefundWebhookResponseWrapper.cls_head reqHeader = reqWrapper.head;
            PaytmRefundWebhookResponseWrapper.cls_body reqBody = reqWrapper.body;
            String bodyRequest = JSON.serialize(reqBody);
            // Paramters
            nm_Payment__c objPayment = new nm_Payment__c();

            // if(String.isNotBlank(reqHeader.signature)){
            //     checksum = reqHeader.signature;
            // } else {
            //     return returnMessage(requestString,'501','checksum is missing.',false, null);
            // }

            // if(!verifyCheckSum(checksum,bodyRequest)) {
            //     return returnMessage(requestString,'501','checksum is not matched..',false, null);
            // }

            if(!String.isNotBlank(reqBody.status)){
                return returnMessage(requestString,'501','status is missing.',false, null);
            }

            List<nm_Payment__c> lstPayment = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c,Refund_Payment__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c=:reqBody.orderId AND RefundId__c=:reqBody.refId AND nm_PaymentGatewayName__c='Paytm GateWay' LIMIT 1];
            if(lstPayment.size() == 0) {
                return returnMessage(requestString,'501','No Payment Record Found.',false, null);
            } else {
                objPayment = lstPayment[0];
                paymentId = objPayment.Id;
                if(objPayment.Refund_Initiated_Error_Message__c=='Refund Successfull') {
                    return returnMessage(requestString,'200','Refund Already Successfull.',true, paymentId);
                }
                nmRefund_Payment__c objRefundPayment = null;
                List<nmRefund_Payment__c> lstRefundPayment = [SELECT id,nm_Transaction_Date__c,Merchant_ID__c,Refunded_Amount__c,Opportunity__c,nm_Payment_Status__c,Status__c,Payment_Refunded_D_T__c FROM nmRefund_Payment__c WHERE id=:objPayment.Refund_Payment__c AND nm_Payment_Status__c!='Payment Refunded' LIMIT 1];
                if(lstRefundPayment.size() > 0) {
                    objRefundPayment = lstRefundPayment[0];
                }

                Decimal refundAmount = Decimal.valueOf(reqBody.refundAmount);
                if(reqBody.status == 'SUCCESS') {
                    objPayment.Refund_Paid_Date__c = System.today();
                    objPayment.Refund_Process_Status__c = 'Y';
                    objPayment.Refunded_Amount__c = refundAmount;
                    objPayment.Refund_Initiated_Error_Message__c = 'Refund Successfull';
                    objPayment.Refund_Error_Code__c = '10';

                    if(objRefundPayment!=null) {
                        // if(objRefundPayment.RefundAmountPending__c <= 0) {
                        //     objRefundPayment.nm_Transaction_Date__c = System.today();
                        //     objRefundPayment.nm_Payment_Status__c = 'Payment Refunded';
                        //     objRefundPayment.Status__c= 'Payment Refunded';
                        //     objRefundPayment.Payment_Refunded_D_T__c= System.Now();
                        // }
    
                        if(String.isBlank(objRefundPayment.Merchant_ID__c)) {
                            objRefundPayment.Merchant_ID__c = objPayment.nm_Merchant_Track_Id__c;
                            objRefundPayment.Refunded_Amount__c = refundAmount;
                        } else if(objRefundPayment.Merchant_ID__c != objPayment.nm_Merchant_Track_Id__c) {
                            objRefundPayment.Merchant_ID__c = objRefundPayment.Merchant_ID__c + ',' + objPayment.nm_Merchant_Track_Id__c;
                            objRefundPayment.Refunded_Amount__c = objRefundPayment.Refunded_Amount__c + refundAmount;
                        }
                        System.debug('objRefundPayment.Merchant_ID__c ==>'+objRefundPayment.Merchant_ID__c);
                        System.debug('objRefundPayment.Refunded_Amount__c -->'+objRefundPayment.Refunded_Amount__c);
                    }
                    System.debug('refundedAmount -->'+refundAmount);
                } else if(reqBody.status == 'FAILED') {
                    objPayment.Refund_Process_Status__c = 'TXN_FAILURE';
                    objPayment.Refund_Error_Code__c = reqBody.rejectRefundReasonCode;
                    objPayment.Refund_Initiated_Error_Message__c = reqBody.rejectRefundReasonMessage;
                }

                try{
                    if(objRefundPayment!=null) {
                        update objRefundPayment;
                        RefundWebService.CheckTotalAmountRefunded(objRefundPayment.id);
                    }
                    update objPayment;
                    return returnMessage(requestString,'200','Webhook API Data updated.',true,paymentId);
                }catch(Exception e){
                    System.debug(e.getMessage());
                    System.debug('Exception e '+e.getLineNumber());
                    return returnMessage(requestString,'504',e.getMessage(),false,paymentId);
                }
            }
        } catch (Exception error) {
            System.debug(error.getMessage());
            System.debug('Exception error '+error.getLineNumber());
            return returnMessage(requestString,'504',error.getMessage(),false,paymentId);
        }
    }

    global class MessageWrapper{
        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
    }


    public static Boolean verifyChecksum(String checkSumHash, String paramap) {
        Boolean verifyCheckSum = false;
        // To query the upGrad payment credential details.
        List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,isActive__c,Paytm_EncryptionKey__c,Paytm_IndustryId__c,Paytm_MID__c,Paytm_Website_Key__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];
        if(String.isNotBlank(checkSumHash)) {
            verifyCheckSum = CheckSumServiceHelper.getCheckSumServiceHelper().verifycheckSumQueryStr(Label.Paytm_Encryption_Key, paramap, checkSumHash);
            // For MBA (X) upGrad Program check.
            if(!verifyCheckSum && lstPaymentConfigdetails.size() > 0){
                verifyCheckSum = CheckSumServiceHelper.getCheckSumServiceHelper().verifycheckSumQueryStr(lstPaymentConfigdetails[0].Paytm_EncryptionKey__c, paramap, checkSumHash);
            }
        }
        if(Test.isRunningTest()) {
            verifyCheckSum = true;
        }
        return verifyCheckSum;
    }

    public static List<MessageWrapper> returnMessage(String requestString, String code, String msg, Boolean isSuccess,String paymentId) {
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        API_Request__c apiReq = new API_Request__c();
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'Refund Request';
        apiReq.API_Name__c='PaytmRefundWebhookAPI';
        apiReq.Success__c = isSuccess;
        apiReq.Payment__c = paymentId;
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
}