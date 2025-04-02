/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-05-2022
 * @last modified by  : @BK
**/
public class PaymentCheckBatchForRazorPay implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
    
    public List <String> successList = new List <String>();
    public String authorizationHeader = null;
    public Map<String,String> mapOfPaymentStatus = new Map<String,String>();
    public Map<String,String> mapOfSuccessMerchanId = new Map<String,String>();


    public void execute(SchedulableContext sc) {
        PaymentCheckBatchForRazorPay obj = new PaymentCheckBatchForRazorPay();
        Database.executebatch(obj, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Query will comapare using GMT time. Fetch Intiated Payment records created 30 minutes back and still in status of Payment Initiated 
        String query = 'SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c FROM nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c=\'Razorpay GateWay\' AND is_Verified__c=false AND (nm_PaymentStatus__c=\'Payment Initiated\' OR nm_PaymentStatus__c = \'Transaction Failed\') AND CreatedDate=LAST_N_DAYS:15 ORDER BY CreatedDate';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        PaymentCheckHelperClass objHelper = new PaymentCheckHelperClass();
        Map<String,String> failedMerchantRefNoGatewayResponseMap = new Map<String,String> ();
        Map<String,String> uniqueMerchantRefNoMap = new Map<String,String> ();
        //String SuccessMerchantId;

        System.debug('scope size = ' + scope.size());
        for(Sobject s: scope) {
            nm_Payment_Initiated__c initiatedPayment = (nm_Payment_Initiated__c) s;
            uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment.OrderId__c);
        }
        Map<String,Map<String,String>> mapOfuniqueMerchantRefNoAndStatus = objHelper.checkOriginalPaymentStatusAndMarkPaymentInitation(uniqueMerchantRefNoMap);
        Map<String,String> mapOfPaymentStatus = mapOfuniqueMerchantRefNoAndStatus.get('status');
        uniqueMerchantRefNoMap = mapOfuniqueMerchantRefNoAndStatus.get('refNo');

        //Iterate every unique merchant referenc number that is not reflected in Original payment records
        for(String merchantRefNo : uniqueMerchantRefNoMap.keySet()){
             callQueryAPI(merchantRefNo, failedMerchantRefNoGatewayResponseMap, uniqueMerchantRefNoMap);
        }
        if(mapOfPaymentStatus.size() > 0) {
            objHelper.updatePaymentStatus(failedMerchantRefNoGatewayResponseMap, mapOfPaymentStatus);
        }
        if(mapOfSuccessMerchanId.size()>0)
        {
            objHelper.updatePaymentRecordStatus(mapOfSuccessMerchanId);
        }

    }

    /**
    * @description 
    * @author @BK | 04-28-2022 
    * @param merchantId 
    * @param failedMerchantRefNoGatewayResponseMap 
    **/
    public void callQueryAPI(String merchantId, Map<String,String> failedMerchantRefNoGatewayResponseMap, Map<String,String> uniqueMerchantRefNoMap){
        try {
            String orderId = uniqueMerchantRefNoMap.get(merchantId).trim();
            
            if(String.isBlank(authorizationHeader)) {
                Blob headerValue = Blob.valueOf(Label.RazorPay_key_id +':'+Label.RazorPay_key_secret);
                authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.razorpay.com/v1/orders/'+orderId+'/payments');
            req.setMethod('GET');
            req.setHeader('Authorization',authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);      
            Integer statusCode = res.getStatusCode();
            System.debug('callQueryAPI:statusCode = '+statusCode);
            if(statusCode == 200){
           //Set<String> setofsuccesMerchantId = new Set<String>();
                String jsonString = res.getBody();
                System.debug('jsonString ==>'+jsonString);
                jsonString = jsonString.replace('currency', 'currencyType');
                RazorPayOrderPaymentResponseWrapper reqWrapper = RazorPayOrderPaymentResponseWrapper.parse(jsonString);
                if(reqWrapper.error == null) {
                    List<RazorPayOrderPaymentResponseWrapper.cls_items> lstItems = reqWrapper.items;
                    for (RazorPayOrderPaymentResponseWrapper.cls_items objEntity : lstItems) {
                        if(objEntity.status == 'captured') {
                            //If payment was successful, then only Pass the response from Query API to original Payment handler class: nmPaytmPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                           mapOfSuccessMerchanId.put(merchantId,'Payment Made');
                            String originalPaymntUpdationStatus = updateOriginalPayment(objEntity,merchantId);
                            System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
                            if(String.isNotBlank(originalPaymntUpdationStatus)) {
                                successList.add(merchantId);
                            }
                        }else if(objEntity.status != 'authorized' && objEntity.status != 'captured'){
                            //Put in failed list to update later, so that these are not queried again
                            failedMerchantRefNoGatewayResponseMap.put(merchantId, objEntity.status);
                            //Mark unsuccessful transactions as failed
                            mapOfPaymentStatus.put(merchantId,'Transaction Failed');
                            System.debug('Not creating payment records since payment is not successful. Result = ' + objEntity.status);
                        } 
                    }
                }

            }                
            System.debug('Result = ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage());
        }
    }

    /**
    * @description 
    * @author @BK | 04-28-2022 
    * @param objEntity 
    * @param merchantId 
    * @return String 
    **/
    public String updateOriginalPayment(RazorPayOrderPaymentResponseWrapper.cls_items objEntity,String merchantId) {
        String pageUrl = null;
        try {
            RazorPayOrderPaymentResponseWrapper.cls_notes objNotes = objEntity.notes;
            String strTransitionstatus = objEntity.status == 'captured' || objEntity.status == 'authorized' ? 'CAPTURED' : objEntity.status;
            String strErrorMessage = strTransitionstatus == 'CAPTURED' ? 'Txn Successful' : objEntity.description;
            Decimal feeCharges = objEntity.fee == null ? 0 : objEntity.fee / 100;
            Decimal taxCharges = objEntity.tax == null ? 0 : objEntity.tax / 100;
            String postPaymentPage = objNotes.udf1.split('_')[3];
            String depositAmount = objNotes.udf1.split('_')[2];
            string IsReregistartion = objNotes.udf1.split('_')[4];
            string opportunityId = objNotes.udf1.split('_')[5];
            String modeOfPayment = objEntity.method;
            string responseCode = objEntity.status;

            PaymentHandler objPaymentHandler = new PaymentHandler();
            PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
            objReqWrapper.udf1 = objNotes.udf1;
            objReqWrapper.postPaymentPage = postPaymentPage;
            objReqWrapper.udf2 = objNotes.udf2;
            objReqWrapper.udf3 = objNotes.udf3;
            objReqWrapper.depositAmount =  Decimal.valueOf(depositAmount);
            objReqWrapper.IsReregistartion = Boolean.valueOf(IsReregistartion);
            objReqWrapper.opportunityId = opportunityId;
            objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
            objReqWrapper.transactionId = objEntity.order_id;
            objReqWrapper.modeOfPayment = objEntity.method;
            objReqWrapper.merchantId = merchantId;
            objReqWrapper.BankTXNId = objEntity.id;
            objReqWrapper.status = strTransitionstatus;
            objReqWrapper.responseDescription = strErrorMessage;
            objReqWrapper.responseCode = responseCode;
            objReqWrapper.detailedGatewayResponse = strTransitionstatus;
            objReqWrapper.currencyCode = objEntity.currencyType;
            objReqWrapper.feeChrages = feeCharges;
            objReqWrapper.tax = taxCharges;
            pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            System.debug('Error Message Line No ==>'+error.getLineNumber());
        }
        return pageUrl;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Finished');
    }
}