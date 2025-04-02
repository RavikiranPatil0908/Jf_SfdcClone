/**
 * @File Name          : PaymentCheckBatchForHDFC.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 05-04-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/9/2019   @BK     Initial Version
**/
global class PaymentCheckBatchForHDFC implements Database.Batchable < sObject > , Database.AllowsCallouts, Schedulable {
    
    public List <String> successList = new List <String>();
    public Map<String,String> mapOfPaymentStatus = new Map<String,String>();
    List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = new List<PaymentConfigurationParameters__c>();
    
    global void execute(SchedulableContext sc) {
        PaymentCheckBatchForHDFC obj = new PaymentCheckBatchForHDFC();
        Database.executebatch(obj, 50);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        getPaymentConfigurationDetails();
        //Query will comapare using GMT time. Fetch Intiated Payment records created 30 minutes back and still in status of Payment Initiated 
        String query = 'SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c=\'HDFC GateWay\' AND is_Verified__c=false AND (nm_PaymentStatus__c = \'Payment Initiated\' OR nm_PaymentStatus__c = \'Transaction Failed\') AND CreatedDate = LAST_N_DAYS:15 ORDER BY CreatedDate';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List < nm_Payment_Initiated__c > scope) {
        getPaymentConfigurationDetails();
        PaymentCheckHelperClass objHelper = new PaymentCheckHelperClass();
        Map<String,String> failedMerchantRefNoGatewayResponseMap = new Map<String,String> ();
        Map<String,String> uniqueMerchantRefNoMap = new Map<String,String>();

        System.debug('scope size = ' + scope.size());
        for(Sobject s: scope) {
            nm_Payment_Initiated__c initiatedPayment = (nm_Payment_Initiated__c) s;
            uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment.IC_Name__c);
        }
        Map<String,Map<String,String>> mapOfuniqueMerchantRefNoAndStatus = objHelper.checkOriginalPaymentStatusAndMarkPaymentInitation(uniqueMerchantRefNoMap);
        mapOfPaymentStatus = mapOfuniqueMerchantRefNoAndStatus.get('status');
        uniqueMerchantRefNoMap = mapOfuniqueMerchantRefNoAndStatus.get('refNo');

        //Iterate every unique merchant referenc number that is not reflected in Original payment records
        for(String merchantRefNo : uniqueMerchantRefNoMap.keySet()){
            PaymentConfigurationParameters__c objPCP = null;
            // To check if center is upGrad
            if(uniqueMerchantRefNoMap.get(merchantRefNo) == 'upGrad' && lstPaymentConfigdetails.size() > 0) {
                objPCP = lstPaymentConfigdetails[0];
            }

            String hashValue = createHDFCDeskRequest(merchantRefNo,objPCP);
            callQueryAPI(hashValue, merchantRefNo, failedMerchantRefNoGatewayResponseMap, objPCP);
        }

        if(mapOfPaymentStatus.size() > 0) {
            objHelper.updatePaymentStatus(failedMerchantRefNoGatewayResponseMap, mapOfPaymentStatus);
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Finished');
    }

    public String createHDFCDeskRequest(String merchantRefNo,PaymentConfigurationParameters__c objPCP) {
        // SHA-512 (key|command|var1|salt) 
        // command can be verify_payment
        String secureSecretKey = Label.SECURE_SECRET;
        String hdfcSaltKey = Label.HDFC_SALT;

        if(objPCP != null) {
            secureSecretKey = objPCP.HDFC_SecretKey__c;
            hdfcSaltKey = objPCP.HDFC_SALT__c;
        }

        Blob hmacData = Crypto.generateDigest('SHA-512', Blob.valueOf(secureSecretKey + '|verify_payment|' + merchantRefNo + '|' + hdfcSaltKey));
        String checkSum = EncodingUtil.convertToHex(hmacData);
        return checkSum;
    }

    public void callQueryAPI(String hashValue, String merchantRefNo, Map <String,String> failedMerchantRefNoGatewayResponseMap, PaymentConfigurationParameters__c objPCP) {

        String secureSecretKey = Label.SECURE_SECRET;
        if(objPCP != null) {
            secureSecretKey = objPCP.HDFC_SecretKey__c;
        }

        HttpRequest req = new HttpRequest();
        System.debug('merchantRefNo Query API-->' + merchantRefNo);
        req.setEndpoint(Label.HDFC_PaymentBatch_Url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('form=2&hash='+ hashValue + '&key=' + secureSecretKey + '&var1=' + merchantRefNo + '&command=verify_payment');
        System.debug('request body-->'+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = ' + statusCode);
        if(statusCode == 200) {
            String result = res.getBody();
            JSONParser parser = JSON.createParser(res.getBody());
            
            boolean IsSuccess = false;
            String Key ='';
            Map<String,String> mapOfParameters = new Map<String,String>(); // map to Store Parameters to Post on HDFC PayResponse 
           
           // Iterate loop for putting post parameters into Map 
            while (parser.nextToken() != null) {
                if(String.valueOf(parser.getCurrentToken()).startsWith('FIELD_'))
                {
                    Key=parser.getText();
                    System.debug('Key--->'+Key);
                }else if(String.valueOf(parser.getCurrentToken()).startsWith('VALUE_'))
                {
                    // modify some parameters as we get amount instead of amt at nmHDFCPayResponse
                    if(Key =='amt')
                    {
                        Key ='amount';
                    }
                    if(Key =='error_Message')
                    {
                        Key ='Error';
                    }
                    mapOfParameters.put(Key,parser.getText());
                } 
            }  
              
            if(mapOfParameters.get('status') == 'success')
            {
                //If payment was successful, then only Pass the response from Query API to original Payment handler class: nmHDFCPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                Boolean originalPaymntUpdationStatus = updateOriginalPayment(mapOfParameters,hashValue);
                System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
                if(originalPaymntUpdationStatus) {
                    successList.add(merchantRefNo);
                }
            }else if(mapOfParameters.get('status') != 'pending'){
                //Put in failed list to update later, so that these are not queried again
                System.debug('Error Message --->'+mapOfParameters.get('status')+'----error Code---'+mapOfParameters.get('error_Message'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, mapOfParameters.get('error_Message'));
                //Mark unsuccessful transactions as failed
                mapOfPaymentStatus.put(merchantRefNo,'Transaction Failed');
                System.debug('Not creating payment records since payment is not successful. Result = ' + mapOfParameters.get('status'));
            } 
        }
        System.debug('Result = ' + res.getBody());
    }

    // public String updateOriginalPayment(Map<String,String> mapOfParameters) {
    //     String pageUrl = null;
    //     try {
    //         String strTransitionstatus = mapOfParameters.get('status') == 'success' ? 'CAPTURED' : mapOfParameters.get('status');
    //         String strErrorMessage = strTransitionstatus == 'CAPTURED' ? mapOfParameters.get('error_code') : mapOfParameters.get('error_Message');
    //         PaymentHandler objPaymentHandler = new PaymentHandler();
    //         PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
    //         objReqWrapper.udf1 = mapOfParameters.get('udf1');
    //         objReqWrapper.udf2 = mapOfParameters.get('udf2');
    //         if(String.isNotBlank(objReqWrapper.udf1) && objReqWrapper.udf1.contains('_')){
    //             if(objReqWrapper.udf1.split('_').size() > 3){
    //                 objReqWrapper.postPaymentPage = objReqWrapper.udf1.split('_')[3];
    //                 objReqWrapper.depositAmount = Decimal.valueOf(objReqWrapper.udf1.split('_')[2]);
    //                 objReqWrapper.IsReregistartion = Boolean.valueOf(objReqWrapper.udf1.split('_')[4]);
    //                 objReqWrapper.opportunityId = objReqWrapper.udf1.split('_')[5];
    //                 system.debug('udf1 -->'+objReqWrapper.udf1);
    //             }
    //         }
    //         objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c');
    //         objReqWrapper.transactionId = mapOfParameters.get('mihpayid');
    //         objReqWrapper.modeOfPayment = mapOfParameters.get('mode');
    //         objReqWrapper.merchantId = mapOfParameters.get('txnid');
    //         objReqWrapper.BankTXNId = mapOfParameters.get('bank_ref_num');
    //         objReqWrapper.status = strTransitionstatus;
    //         objReqWrapper.responseDescription = strErrorMessage;
    //         objReqWrapper.responseCode = mapOfParameters.get('error_code');
    //         objReqWrapper.detailedGatewayResponse = strTransitionstatus;
    //         pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
    //     } catch (Exception error) {
    //         System.debug('Error Message ==>'+error.getMessage());
    //         System.debug('Error Message Line No ==>'+error.getLineNumber());
    //     }
    //     return pageUrl;
    // }

    public Boolean updateOriginalPayment(Map<String,String> mapOfParameters,String hashValue)
    {
        HttpRequest req = new HttpRequest();
        String paymentPageURL = nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c');
        System.debug('Sending Query API output to ' + paymentPageURL);
        if(Test.isRunningTest()) {
            paymentPageURL = Label.Site_Url;
        }
        System.debug('Sending Query API output to ' + paymentPageURL);
        req.setEndpoint(paymentPageURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        // setting parameter for posting to HDFC pay response for Creating Record in System
        String requestBody ='msgs=123';
        for(String Keys :mapOfParameters.keyset()){
            System.debug('Key---->'+Keys +'---Values--->'+mapOfParameters.get(Keys));
            requestBody=requestBody+'&'+Keys+'='+mapOfParameters.get(Keys);
        }
        requestBody = requestBody+'&hash='+hashValue;
        System.debug('Request Body---->'+requestBody);
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('updateOriginalPayment:statusCode = ' + statusCode);

        if(statusCode == 200) {
            return true;
        } else {
            return false;
        }
    }
    
    public void getPaymentConfigurationDetails() {
        if(lstPaymentConfigdetails.size() == 0) {
            lstPaymentConfigdetails = [SELECT id,isActive__c,HDFC_SecretKey__c,HDFC_SALT__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad' LIMIT 1];
        }
    }
}