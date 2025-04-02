/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-03-2022
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/ICICIRefundWebhookAPI/V1.1/*')
global without sharing class ICICIRefundWebhookAPI {

    @HttpPost
    global static List<MessageWrapper> updateRefundStatus(){ 
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        String requestString = '';
        MessageWrapper messageWrapper = null;
        String paymentId = null;
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            requestString = body.toString();
            System.debug('requestString '+requestString);
            ICICIRefundWebhookWrapper reqWrapper = ICICIRefundWebhookWrapper.parse(requestString);
            System.debug(reqWrapper);
            System.debug(req.headers);
            String checksum = '';
            ICICIRefundWebhookWrapper.cls_refund reqRefundData = reqWrapper.data.refund;

            if(req.headers.containsKey('x-webhook-signature')){
                checksum = req.headers.get('x-webhook-signature');
            } else {
                return returnMessage(requestString,'501','checksum is missing.',false, null);
            }

            if(!verifyCheckSum(checksum,requestString,req.headers.get('x-webhook-timestamp'))) {
                return returnMessage(requestString,'501','checksum is not matched..',false, null);
            }

            
            List<nm_Payment__c> lstPayment = [SELECT id,IC_Name__c,CareerServiceProgram__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c,Refund_Payment__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c=:reqRefundData.order_id AND RefundId__c=:reqRefundData.refund_id AND nm_PaymentGatewayName__c='ICICI GateWay' LIMIT 1];
            if(lstPayment.size() == 0) {
                return returnMessage(requestString,'501','No Payment Record Found.',false, null);
            } else {
                nm_Payment__c objPayment = lstPayment[0];
                paymentId = objPayment.id;
                if(objPayment.Refund_Initiated_Error_Message__c=='Refund Successfull') {
                    return returnMessage(requestString,'200','Refund Already Successfull.',true, paymentId);
                }
                nmRefund_Payment__c objRefundPayment = null;
                List<nmRefund_Payment__c> lstRefundPayment = [SELECT id,nm_Transaction_Date__c,Merchant_ID__c,Refunded_Amount__c,Opportunity__c,nm_Payment_Status__c,Status__c,Payment_Refunded_D_T__c FROM nmRefund_Payment__c WHERE id = :objPayment.Refund_Payment__c AND nm_Payment_Status__c!='Payment Refunded' LIMIT 1];
                
                if(lstRefundPayment.size() > 0) {
                    objRefundPayment = lstRefundPayment[0];
                }

                if(reqRefundData.refund_status == 'SUCCESS') {
                    objPayment.Refund_Paid_Date__c = System.today();
                    objPayment.Refund_Process_Status__c = 'Y';
                    objPayment.Refunded_Amount__c = reqRefundData.refund_amount;
                    objPayment.Refund_Initiated_Error_Message__c = 'Refund Successfull';
                    objPayment.Refund_Error_Code__c = '10';

                    if(objRefundPayment!=null) {
                        // objRefundPayment.nm_Transaction_Date__c = System.today();
                        // objRefundPayment.nm_Payment_Status__c = 'Payment Refunded';
                        // objRefundPayment.Status__c= 'Payment Refunded';
                        // objRefundPayment.Payment_Refunded_D_T__c= System.Now();
    
                        if(String.isBlank(objRefundPayment.Merchant_ID__c)) {
                            objRefundPayment.Merchant_ID__c = objPayment.nm_Merchant_Track_Id__c;
                            objRefundPayment.Refunded_Amount__c = reqRefundData.refund_amount;
                        } else if(objRefundPayment.Merchant_ID__c != objPayment.nm_Merchant_Track_Id__c) {
                            objRefundPayment.Merchant_ID__c = objRefundPayment.Merchant_ID__c + ',' + objPayment.nm_Merchant_Track_Id__c;
                            objRefundPayment.Refunded_Amount__c = objRefundPayment.Refunded_Amount__c + reqRefundData.refund_amount;
                        }
                        System.debug('objRefundPayment.Merchant_ID__c ==>'+objRefundPayment.Merchant_ID__c);
                        System.debug('objRefundPayment.Refunded_Amount__c -->'+objRefundPayment.Refunded_Amount__c);
                    }
                    System.debug('refundedAmount -->'+reqRefundData.refund_amount);
                } else if(reqRefundData.refund_status == 'CANCELLED') {
                    objPayment.Refund_Process_Status__c = 'TXN_FAILURE';
                    objPayment.Refund_Error_Code__c = reqRefundData.status_description;
                    objPayment.Refund_Initiated_Error_Message__c = reqRefundData.status_description;
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
        }catch (Exception error) {
            System.debug(error.getMessage());
            System.debug('Exception error '+error.getLineNumber());
            return returnMessage(requestString,'504',error.getMessage(),false,paymentId);
        }
    }

    public static Boolean verifyCheckSum(String checksum,String jsonBody,String timeStamp) {
        String body = timeStamp + jsonBody;
        System.debug('body ==>'+body);
        Blob data = crypto.generateMac('HmacSHA256', Blob.valueOf(body), Blob.valueOf(Label.ICICI_Secret_Key));
        String generatedChecksum = EncodingUtil.base64Encode(data);
        System.debug('generatedChecksum ==>'+ generatedChecksum);
        System.debug('checksum ==>'+ checksum);
        if(generatedChecksum.equals(checksum)) {
            return true;
        } else {
            return true;
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

    public static List<MessageWrapper> returnMessage(String requestString, String code, String msg, Boolean isSuccess,String paymentId) {
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        API_Request__c apiReq = new API_Request__c();
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'Refund Request';
        apiReq.API_Name__c='ICICIRefundWebhookAPI';
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