@RestResource(urlMapping='/BillDeskWebhookAPI/V1.1/*')
global  without sharing class BillDeskWebhookAPI {
    // https://ngasce--dev2.sandbox.my.salesforce-sites.com/services/apexrest/BillDeskWebhookAPI/V1.1/

    @HttpPost
    global static List<MessageWrapper> UpdatePaymentStatus(){
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        MessageWrapper messageWrapper = null;
        nmBillDeskHelper.PaymentDetails objDetails = new nmBillDeskHelper.PaymentDetails();
        try{
            RestRequest req = RestContext.request;

            Blob body = req.requestBody;
            requestString = body.toString();
            apiReq.Request__c = requestString;

            API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
            List<String> resultSplit = String.isNotBlank(requestString) ? requestString.split('\\.') : new List<String>();
            if(String.isNotBlank(requestString) && requestString != 'undefined' && resultSplit.size() == 3 && nmBillDeskHelper.hmacSHA256Verification(resultSplit[0], resultSplit[1], resultSplit[2], BilldeskV2.Secret_Key__c)) {
                objDetails = nmBillDeskHelper.setPaymentDetails(objDetails, resultSplit[1]);
                apiReq.Request__c = objDetails.strTransitionResponse;
                String merchantId = objDetails.merchantId;
                List<nm_Payment_Initiated__c> InitiatedPayment = [SELECT id,nm_Merchant_Track_Id__c,nm_Fee_Type__c,nm_Lead__c,nm_PaymentStatus__c,nm_OpportunityNew__c,payment_Transaction_Mode__c,nm_ModeOfPayment__c,Online_Payment_Id__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c=:merchantId AND nm_PaymentGatewayName__c='BillDesk GateWay'];
                if(InitiatedPayment.size() == 0) {
                    return returnMessage(apiReq,'501','No Payment Record Found.',false);
                }
                apiReq.Payment_Initiated__c = InitiatedPayment[0].id;
                List<nm_Payment__c> lstPayment = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,nm_PaymentStatus__c,Refund_Error_Code__c,Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c=:merchantId AND nm_PaymentGatewayName__c='BillDesk GateWay'];
                if(lstPayment.size() > 0) {
                    for(nm_Payment__c nmPay:lstPayment){
                        if(nmPay.nm_PaymentStatus__c == 'Payment Approved' || nmPay.nm_PaymentStatus__c == 'Payment Made'){
                            return returnMessage(apiReq,'200','Payment status Updated.',true);
                        }
                    }
                }
                PaymentHandler objPaymentHandler = new PaymentHandler();
                PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
                objReqWrapper.merchantId = objDetails.merchantId;
                objReqWrapper = nmBillDeskHelper.setPaymentResponseWrapper(objReqWrapper, objDetails);
                String pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
                if(String.isNotBlank(pageUrl)) {
                    return returnMessage(apiReq,'200','Payment status Updated.',true);
                } else {
                    return returnMessage(apiReq,'400','Failed to update',false);
                }
            } else {
                return returnMessage(apiReq,'501','checksum is not matched..',false);
            }
        }catch(Exception error){
            System.debug('Error Message ==>'+error.getMessage());
            return returnMessage(apiReq,'504',error.getMessage(),false);
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
    public static List<MessageWrapper> returnMessage(API_Request__c apiReq, String code, String msg, Boolean isSuccess) {
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'UpdatePaymentStatus';
        apiReq.API_Name__c='BillDeskWebhookV2API';
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

}