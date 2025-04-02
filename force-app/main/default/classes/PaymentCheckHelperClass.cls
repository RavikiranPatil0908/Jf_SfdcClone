/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-03-2023
 * @last modified by  : @BK
**/
public without sharing class PaymentCheckHelperClass {

    public List<String> lstUpgradSupportedGateways = new List<String>{'HDFC GateWay','Paytm GateWay'};
    public Map<String,String> failedMerchantRefNoGatewayResponseMap = new Map<String,String> ();
    public Map<String,nm_Payment_Initiated__c> uniqueMerchantRefNoMap = new Map<String,nm_Payment_Initiated__c>();
    public Map<String,String> mapOfPaymentStatus = new Map<String,String>();
    public PaymentDetails objDetails = new PaymentDetails();

    /**
    * @description 
    * @author @BK | 04-28-2022 
    * @param failedMerchantRefNoGatewayResponseMap 
    * @param mapOfPaymentStatus 
    **/
    public void updatePaymentStatus(Map<String,String> failedMerchantRefNoGatewayResponseMap,Map<String,String> mapOfPaymentStatus) {
        Set<String> setOfRefNo = mapOfPaymentStatus.keySet();
        List<nm_Payment_Initiated__c> lstPaymentInitationToUpdate = new List<nm_Payment_Initiated__c>();
        List<nm_Payment_Initiated__c> lstPayment = [SELECT id,nm_PaymentStatus__c,nm_Merchant_Track_Id__c,Gateway_Detailed_Response__c,is_Verified__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c IN : setOfRefNo];
        for (nm_Payment_Initiated__c obj : lstPayment) {
            if(mapOfPaymentStatus.containsKey(obj.nm_Merchant_Track_Id__c)) {
                obj.nm_PaymentStatus__c = mapOfPaymentStatus.get(obj.nm_Merchant_Track_Id__c);
                obj.is_Verified__c = true;
                if(obj.nm_PaymentStatus__c == 'Transaction Failed' && failedMerchantRefNoGatewayResponseMap.containsKey(obj.nm_Merchant_Track_Id__c)) {
                    obj.Gateway_Detailed_Response__c = failedMerchantRefNoGatewayResponseMap.get(obj.nm_Merchant_Track_Id__c);
                }
                lstPaymentInitationToUpdate.add(obj);
                System.debug('After Update Original Payment Initation Record Id--->'+obj.id);
            }
        }
        if(lstPaymentInitationToUpdate.size() > 0) {
            update lstPaymentInitationToUpdate;
        }
    }

  

    public void updatePaymentRecordStatus(Map<String,String> mapOfSuccessMerchanId) {
        Set<String> setOfRefNo = mapOfSuccessMerchanId.keySet();
        List<nm_Payment__c> lstPaymentInitationToUpdate = new List<nm_Payment__c>();
        Map<Id,Lead> MapToUpdateLead = new Map<Id,Lead>();
        List<nm_Payment__c> lstPayment = [SELECT id,nm_PaymentStatus__c,nm_Merchant_Track_Id__c,nm_OpportunityNew__c, nm_Lead__c ,nm_Lead__r.Status FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c IN : setOfRefNo and nm_PaymentStatus__c ='Transaction Failed'];
        for (nm_Payment__c obj : lstPayment) {
            if(mapOfSuccessMerchanId.containsKey(obj.nm_Merchant_Track_Id__c)) {
                obj.nm_PaymentStatus__c = mapOfSuccessMerchanId.get(obj.nm_Merchant_Track_Id__c);
                if(obj.nm_Lead__c != null && !obj.nm_Lead__r.Status.contains('Paid')) {
                    Lead objlead = new Lead(id = obj.nm_Lead__c );
                    objlead.status = 'Registration Fee Paid';
                    MapToUpdateLead.put(objlead.id,objlead);
                }
                lstPaymentInitationToUpdate.add(obj);
                System.debug('After Update Original Payment Initation Record Id--->'+obj.id);
            }
        }
        if(lstPaymentInitationToUpdate.size() > 0) {
            update lstPaymentInitationToUpdate;
        }
        if(MapToUpdateLead!=null)
        {
            update MapToUpdateLead.values();
        }
    }

    public Map<String,Map<String,String>> checkOriginalPaymentStatusAndMarkPaymentInitation(Map<String,String> uniqueMerchantRefNoMap) {
        Map<String,String> mapOfPaymentStatus = new Map<String,String>();
        Map<String,Map<String,String>> mapOfuniqueMerchantRefNoAndStatus = new Map<String,Map<String,String>>();
        if(uniqueMerchantRefNoMap.size() > 0) {
            Set<String> lstMerchantRefNo = uniqueMerchantRefNoMap.keySet();
            List<nm_Payment__c> lstPaymentAlreadyApproved =[SELECT id,nm_PaymentStatus__c,nm_Merchant_Track_Id__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c IN:lstMerchantRefNo AND (nm_PaymentStatus__c='Payment Approved' OR nm_PaymentStatus__c ='Payment Made')];
            for (nm_Payment__c objPayment : lstPaymentAlreadyApproved) {
                if(uniqueMerchantRefNoMap.containsKey(objPayment.nm_Merchant_Track_Id__c)) {
                    uniqueMerchantRefNoMap.remove(objPayment.nm_Merchant_Track_Id__c);
                    mapOfPaymentStatus.put(objPayment.nm_Merchant_Track_Id__c,'Payment Made');
                }
            }
        }
        mapOfuniqueMerchantRefNoAndStatus.put('status', mapOfPaymentStatus);
        mapOfuniqueMerchantRefNoAndStatus.put('refNo', uniqueMerchantRefNoMap);
        return mapOfuniqueMerchantRefNoAndStatus;
    }

    public void checkOriginalPaymentStatusAndMarkPaymentInitation() {
        Map<String,Map<String,Object>> mapOfuniqueMerchantRefNoAndStatus = new Map<String,Map<String,Object>>();
        if(uniqueMerchantRefNoMap.size() > 0) {
            Set<String> lstMerchantRefNo = uniqueMerchantRefNoMap.keySet();
            List<nm_Payment__c> lstPaymentAlreadyApproved =[SELECT id,nm_PaymentStatus__c,nm_Merchant_Track_Id__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c IN:lstMerchantRefNo AND (nm_PaymentStatus__c='Payment Approved' OR nm_PaymentStatus__c ='Payment Made')];
            for (nm_Payment__c objPayment : lstPaymentAlreadyApproved) {
                if(uniqueMerchantRefNoMap.containsKey(objPayment.nm_Merchant_Track_Id__c)) {
                    uniqueMerchantRefNoMap.remove(objPayment.nm_Merchant_Track_Id__c);
                    mapOfPaymentStatus.put(objPayment.nm_Merchant_Track_Id__c,'Payment Made');
                }
            }
        }
    }

    // ---------------------------------------------------- HDFC Section begins here ---------------------------------------------------
    
    public String createHDFCRequest(String merchantRefNo,PaymentConfigurationParameters__c objPCP) {
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

    public void callQueryAPIHDFC(String hashValue, String merchantRefNo, PaymentConfigurationParameters__c objPCP) {
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
              
            if(mapOfParameters.get('status') == 'success') {
                //If payment was successful, then only Pass the response from Query API to original Payment handler class: nmHDFCPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                Boolean originalPaymntUpdationStatus = updateOriginalPaymentHDFC(mapOfParameters,hashValue);
                System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
            }else if(mapOfParameters.get('status') != 'pending'){
                //Put in failed list to update later, so that these are not queried again
                System.debug('Error Message --->'+mapOfParameters.get('status')+'----error Code---'+mapOfParameters.get('error_Message'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, mapOfParameters.get('error_Message'));
                mapOfPaymentStatus.put(merchantRefNo,'Transaction Failed');
                //Mark unsuccessful transactions as failed
                System.debug('Not creating payment records since payment is not successful. Result = ' + mapOfParameters.get('status'));
            }
        }
        System.debug('Result = ' + res.getBody());
    }

    public Boolean updateOriginalPaymentHDFC(Map<String,String> mapOfParameters,String hashValue) {
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

    // ---------------------------------------------------- HDFC Section ends here ---------------------------------------------------

    // ---------------------------------------------------- Bill Desk Section begins here ---------------------------------------------------
    
    public String createBillDeskRequest(String merchantRefNo){
        Datetime currentDateTime = Datetime.now();
        String formattedDateTime = currentDateTime.format('yyyyMMddHHmmss');
        System.debug('formattedDateTime = '+formattedDateTime);
        String msg = '0122|NMIMS|'+ merchantRefNo + '|' + formattedDateTime ;
        
        System.debug('Before msg = '+msg);
        
        //Generate checksumkey
        String algorithmName = 'HmacSHA256';
        String secretKey = 'eSTTsLAjCzks';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(msg), Blob.valueOf(secretKey));
        String checkSum = EncodingUtil.convertToHex(hmacData);
        
        System.debug('CheckSum = '+checkSum);
        
        //Append Checksum at the end of the message.
        msg = msg + '|' + checkSum.touppercase();
        System.debug('After msg = '+msg);
        
        return msg;
    }

    public void callQueryAPIBillDesk(String msg, String merchantRefNo){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.billdesk.com/pgidsk/PGIQueryController');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('msg='+msg);
        Http http = new Http();
        HTTPResponse res = http.send(req);      
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = '+statusCode);
        if(statusCode == 200){
            String result = res.getBody();
            System.debug('callQueryAPI:result = '+result);
            //Query API returns one additional paramter, remove that so that response is same as original gateway call result
            String trimmedResult = result.substring(result.indexOf('|')+1, result.length());
            
            String[] responseParameters = trimmedResult.split('\\|');
            String strResResult = responseParameters[14]; //Response Code is at position 15
            
            if(strResResult == '0300'){
                //If payment was successful, then only Pass the response from Query API to original Payment handler class: PayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                Boolean originalPaymntUpdationStatus = false;
                try{
                    originalPaymntUpdationStatus = updateOriginalPaymentBillDesk(trimmedResult);
                }catch(Exception e){
                    System.debug('Error ==>'+e.getMessage());
                }
                System.debug('originalPaymntUpdationStatus = '+originalPaymntUpdationStatus);
            }else if(strResResult != '0002'){
                //Put in failed list to update later, so that these are not queried again
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, result);
                mapOfPaymentStatus.put(merchantRefNo,'Transaction Failed');
                System.debug('Not creating payment records since payment is not successful. Result = ' +strResResult );
            }
        }
        System.debug('Result = ' + res.getBody());  
    }

    public boolean updateOriginalPaymentBillDesk(String msg){
        HttpRequest req = new HttpRequest();
        String paymentPageURL = nmCommon.getConfigSettings('Payment_Response_New_URL__c');
        if(Test.isRunningTest()) {
            paymentPageURL = Label.Site_Url;
        }
        req.setEndpoint(paymentPageURL);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('msg='+msg+'&skipcheck=true');
          
        Http http = new Http();
        HTTPResponse res = http.send(req);      
        Integer statusCode = res.getStatusCode();
        System.debug('updateOriginalPayment:statusCode = '+statusCode);
        
        if(statusCode == 200){
            return true;
        }else{
            return false;
        }
    }

    // ---------------------------------------------------- Bill Desk Section ends here ---------------------------------------------------

    // ---------------------------------------------------- Bill Desk v2 Section starts here ---------------------------------------------------

    public void callQueryAPIBillDeskv2(String merchantRefNo) {
        String result = nmBillDeskHelper.getTransactionResponseFromAPI(merchantRefNo);
        List<String> resultSplit = String.isNotBlank(result) ? result.split('\\.') : new List<String>();
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        if (result == 'Not Found') {
            PaymentHandler objPaymentHandler = new PaymentHandler();
            PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
            if (uniqueMerchantRefNoMap.containsKey(merchantRefNo)) {
                objReqWrapper = nmBillDeskHelper.setTransactionPaymentResponse(objReqWrapper, uniqueMerchantRefNoMap.get(merchantRefNo));
                String pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
            }
        } else if(String.isNotBlank(result) && resultSplit.size() == 3 && nmBillDeskHelper.hmacSHA256Verification(resultSplit[0], resultSplit[1], resultSplit[2], BilldeskV2.Secret_Key__c)) {
            nmBillDeskHelper.PaymentDetails PaymentDetail = new nmBillDeskHelper.PaymentDetails();
            PaymentDetail = nmBillDeskHelper.setPaymentDetails(PaymentDetail, resultSplit[1]);
            if (PaymentDetail.responseCode == '0300') {
                PaymentHandler objPaymentHandler = new PaymentHandler();
                PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
                objReqWrapper.merchantId = merchantRefNo;
                objReqWrapper = nmBillDeskHelper.setPaymentResponseWrapper(objReqWrapper, PaymentDetail);
                String pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
            } else if (PaymentDetail.responseCode != '0002') {
                Map<String, Object> MapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped((EncodingUtil.base64decode(resultSplit[1])).toString()); 
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, JSON.serialize(MapOfResponseParameters));
                mapOfPaymentStatus.put(merchantRefNo,'Transaction Failed');
                System.debug('Not creating payment records since payment is not successful. Result = ' +PaymentDetail.responseCode + ' -- ' + PaymentDetail.strErrorMessage );
            }
        }
    }
    // ---------------------------------------------------- Bill Desk v2 Section ends here ---------------------------------------------------

    // ---------------------------------------------------- Paytm Section begins here ---------------------------------------------------

    public String createPaytmRequest(String orderId,PaymentConfigurationParameters__c objPCP) {
        String paytmMerchantKey = System.Label.Paytm_Merchant_Key;
        String paytmEncryptionKey = System.Label.Paytm_Encryption_Key;
        if(objPCP != null) {
            paytmMerchantKey = objPCP.Paytm_MID__c;
            paytmEncryptionKey = objPCP.Paytm_EncryptionKey__c;
        } 
        
        Map<String,String> paytmParams = new Map<String,String>();
        paytmParams.put('MID', paytmMerchantKey);
        paytmParams.put('ORDERID', orderId);
        String paytmChecksum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(paytmEncryptionKey, paytmParams);
        paytmParams.put('CHECKSUMHASH', paytmChecksum);
        String postData = JSON.serialize(paytmParams);
        // postData = 'JsonData=' + postData;
        return postData;
    }

    public void callQueryAPIPaytm(String postData, String merchantRefNo, PaymentConfigurationParameters__c objPCP) {
        HttpRequest req = new HttpRequest();
        System.debug('merchantRefNo Query API-->' + merchantRefNo);
        String PaytmBatchURL = nmCommon.getConfigSettings('Paytm_PaymentBatch_Url__c');
        System.debug('Sending Query API output to ' + PaytmBatchURL);
        if(Test.isRunningTest()) {
            PaytmBatchURL = System.Label.Site_Url;
        }
        req.setEndpoint(PaytmBatchURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(postData);
        System.debug('request body-->'+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = ' + statusCode);
        if(statusCode == 200) {
            String jsonString = res.getBody();
            System.debug('jsonString ==>'+jsonString);
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            
            Boolean IsSuccess = false;
            String Key ='';
            Map<String,String> mapOfParameters =new Map<String,String>(); // map to Store Parameters to Post on Paytm PayResponse 
           
            for(String mapKey : mapOfRequestParameters.keySet()){
                mapOfParameters.put(mapKey,String.valueOf(mapOfRequestParameters.get(mapKey)));
            }
              
            if(mapOfParameters.get('STATUS') == 'TXN_SUCCESS') {
                //If payment was successful, then only Pass the response from Query API to original Payment handler class: nmPaytmPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                Boolean originalPaymntUpdationStatus = updateOriginalPaymentPaytm(mapOfParameters);
                System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
            }else if(mapOfParameters.get('STATUS') != 'PENDING'){
                //Put in failed list to update later, so that these are not queried again
                System.debug('Error Message --->'+mapOfParameters.get('RESPMSG')+'----error Code---'+mapOfParameters.get('RESPCODE'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, mapOfParameters.get('RESPMSG'));
                mapOfPaymentStatus.put(merchantRefNo,'Transaction Failed');
                System.debug('Not creating payment records since payment is not successful. Result = ' + mapOfParameters.get('RESPMSG'));
            } 
        }
        System.debug('Result = ' + res.getBody());
    }

    public Boolean updateOriginalPaymentPaytm(Map<String,String> mapOfParameters) {
        System.debug('mapOfParameters ==>');
        System.debug(mapOfParameters);
        String pageUrl = null;
        String status = mapOfParameters.get('STATUS');
        if(String.isNotBlank(status) && status.toUpperCase() == 'TXN_SUCCESS') {
            status = 'CAPTURED';
        }else if (String.isNotBlank(status) && status.toUpperCase() == 'PENDING') {
            status = 'pending';
        }else {
            status = 'failure';
        }
        try {
            String Resudf1 = mapOfParameters.get('MERC_UNQ_REF');
            String addDetails = Resudf1.split('_')[6]+'_'+Resudf1.split('_')[7]+'_'+Resudf1.split('_')[8]+'_'+Resudf1.split('_')[9];
            String redirectPageName = Resudf1.split('_').size() >= 11 ? Resudf1.split('_')[10] : '';
            PaymentHandler objPaymentHandler = new PaymentHandler();
            PaymentHandler.PaymentResponseWrapper objReqWrapper = new PaymentHandler.PaymentResponseWrapper();
            objReqWrapper.postPaymentPage = Resudf1.split('_')[3];
            objReqWrapper.udf1 = Resudf1;
            objReqWrapper.udf2 = addDetails;
            objReqWrapper.udf3 = redirectPageName;
            objReqWrapper.depositAmount = Decimal.valueOf(mapOfParameters.get('TXNAMOUNT'));
            objReqWrapper.IsReregistartion = Boolean.valueOf(Resudf1.split('_')[4]);
            objReqWrapper.opportunityId = Resudf1.split('_')[5];
            objReqWrapper.paymentResponseUrl = nmCommon.getConfigSettings('nm_PaymentResponseUrl_Paytm__c');
            objReqWrapper.transactionId = mapOfParameters.get('TXNID');
            objReqWrapper.modeOfPayment = mapOfParameters.get('PAYMENTMODE');
            objReqWrapper.merchantId = mapOfParameters.get('ORDERID');
            objReqWrapper.BankTXNId = mapOfParameters.get('BANKTXNID');
            objReqWrapper.status = status;
            objReqWrapper.responseDescription = responseCodeVsResponse(mapOfParameters.get('RESPCODE'));
            objReqWrapper.responseCode = mapOfParameters.get('RESPCODE');
            objReqWrapper.detailedGatewayResponse = mapOfParameters.get('RESPMSG');
            pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            System.debug('Error Message Line No ==>'+error.getLineNumber());
        }
        return String.isNotBlank(pageUrl) ? true : false;
        
    }

    public String responseCodeVsResponse(String code) {
        String ResponseString = null;
        Map<String,String> MapOfResponseCodeVsResponse = new Map<String,String> {
            '01'=>'Txn Successful','202'=>'User does not have enough credit limit. Bank has declined the transaction','295'=>'No Description available',
            '205'=>'Transaction has been declined by the bank.','207'=>'Card used by customer has expired','330'=>'Paytm checksum mismatch',
            '208'=>'Transaction has been declined by the acquirer bank.','209'=>'Card details entered by the user is/are invalid.',
            '210'=>'Lost Card received','220'=>'Bank communication error','222'=>'Transaction amount return by the gateway does not match with Paytm transaction amount',
            '227'=>'Txn Failed','229'=>'3D Secure Verification failed','232'=>'Invalid account details','297'=>'Cancel and Redirect to 3D Page',
            '296'=>'We are facing problem at bank`s end. Try using another Payment mode','810'=>'Closed after page load','3102'=>'Invalid card details',
            '401'=>'Abandoned transaction','402'=>'Transaction abandoned from CCAvenue','2271'=>'User cancelled the transaction on banks net banking page',
            '2272'=>'User cancelled the transaction from 3D secure/OTP page' 
        };
        if(MapOfResponseCodeVsResponse.containsKey(code)) {
            ResponseString = MapOfResponseCodeVsResponse.get(code);
        }
        return String.isBlank(ResponseString) ? code : ResponseString;
    }

    // ---------------------------------------------------- Paytm Section ends here ---------------------------------------------------

    // ---------------------------------------------------- RazorPay Section begins here ---------------------------------------------------

    public void callQueryAPIRazorpay(String orderId, String merchantId) { 
        Blob headerValue = Blob.valueOf(Label.RazorPay_key_id +':'+Label.RazorPay_key_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.razorpay.com/v1/orders/'+orderId+'/payments');
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);      
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = '+statusCode);
        if(statusCode == 200){ 
            String jsonString = res.getBody();
            System.debug('jsonString ==>'+jsonString);
            jsonString = jsonString.replace('currency', 'currencyType');
            RazorPayOrderPaymentResponseWrapper reqWrapper = RazorPayOrderPaymentResponseWrapper.parse(jsonString);
            if(reqWrapper.error == null) {
                List<RazorPayOrderPaymentResponseWrapper.cls_items> lstItems = reqWrapper.items;
                for (RazorPayOrderPaymentResponseWrapper.cls_items objEntity : lstItems) {
                    if(objEntity.status == 'captured') {
                        //If payment was successful, then only Pass the response from Query API to original Payment handler class: nmPaytmPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                        Boolean originalPaymntUpdationStatus = updateOriginalPaymentRazorpay(objEntity,merchantId);
                        System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
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
    }

    public Boolean updateOriginalPaymentRazorpay(RazorPayOrderPaymentResponseWrapper.cls_items objEntity,String merchantId) {
        String pageUrl = null;
        try {
            RazorPayOrderPaymentResponseWrapper.cls_notes objNotes = objEntity.notes;
            String strTransitionstatus = objEntity.status == 'captured' || objEntity.status == 'authorized' ? 'CAPTURED' : objEntity.status;
            String strErrorMessage = strTransitionstatus == 'CAPTURED' ? 'Txn Successful' : objEntity.description;
            Decimal feeCharges = objEntity.fee == null ? 0 : objEntity.fee / 100;
            Decimal taxCharges = objEntity.tax == null ? 0 : objEntity.tax / 100;
            String postPaymentPage = objNotes.udf1.split('_')[3];
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
            objReqWrapper.depositAmount =  Decimal.valueOf(objEntity.amount / 100);
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
        return String.isNotBlank(pageUrl) ? true : false;
    }

    // ---------------------------------------------------- RazorPay Section ends here ---------------------------------------------------

    // ---------------------------------------------------- ICICI Section begins here ---------------------------------------------------

    public void callQueryAPIICICI(String merchantId) { 
        String paymentUri = '';
        HttpRequest req = new HttpRequest();
        String ICICIOrderUrl = nmCommon.getConfigSettings('ICICI_Base_Url__c') + '/orders/' + merchantId;
        req.setEndpoint(ICICIOrderUrl);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-api-version','2022-01-01');
        req.setHeader('x-client-id',Label.ICICI_App_Id);
        req.setHeader('x-client-secret',Label.ICICI_Secret_Key);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);      
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = '+statusCode);
        if(statusCode == 200){ 
            String jsonString = res.getBody();
            System.debug('jsonString ==>'+jsonString);
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());
            if(mapOfRequestParameters.containsKey('order_status') && mapOfRequestParameters.get('order_status') == 'PAID') {
                Map<String,Object> mapOfOrderTags = (Map<String,Object>)mapOfRequestParameters.get('order_tags');
                Map<String,Object> mapOfpaymentsUrl = (Map<String,Object>)mapOfRequestParameters.get('payments');
                objDetails.udf1 = (String)mapOfOrderTags.get('udf1');
                objDetails.udf2 = (String)mapOfOrderTags.get('udf2');
                objDetails.udf3 = (String)mapOfOrderTags.get('udf3');
                objDetails.currencyOfPayment = (String)mapOfRequestParameters.get('order_currency');
                paymentUri = (String)mapOfpaymentsUrl.get('url');
                objDetails.postPaymentPage = objDetails.udf1.split('_')[3];
                // objDetails.depositAmount = Decimal.valueOf(objDetails.udf1.split('_')[2]);
                objDetails.depositAmount = (Decimal)mapOfRequestParameters.get('order_amount');
                objDetails.IsReregistartion = Boolean.valueOf(objDetails.udf1.split('_')[4]);
                objDetails.opportunityId = objDetails.udf1.split('_')[5];
                fetchPayment(paymentUri,merchantId);
            } else if(mapOfRequestParameters.containsKey('order_status') && (mapOfRequestParameters.get('order_status') != 'PROCESSED' || mapOfRequestParameters.get('order_status') != 'ACTIVE')) {
                failedMerchantRefNoGatewayResponseMap.put(merchantId, (String)mapOfRequestParameters.get('order_status'));
                //Mark unsuccessful transactions as failed
                mapOfPaymentStatus.put(merchantId,'Transaction Failed');
                System.debug('Not creating payment records since payment is not successful. Result = ' + mapOfRequestParameters.get('order_status'));
            }
        }
    }

    public void fetchPayment(String paymentUri,String merchantId) { 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(paymentUri);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-api-version','2022-01-01');
        req.setHeader('x-client-id',Label.ICICI_App_Id);
        req.setHeader('x-client-secret',Label.ICICI_Secret_Key);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);      
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = '+statusCode);
        if(statusCode == 200){ 
            String jsonString = res.getBody();
            System.debug('jsonString ==>'+jsonString);
            List<Object> lstObjects = (List<Object>)Json.deserializeuntyped(jsonString);
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
            
            Boolean originalPaymntUpdationStatus = updateOriginalPaymentICICI(merchantId);
            System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
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

    public Boolean updateOriginalPaymentICICI(String merchantId) {
        String pageUrl = null;
        try {
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
            objReqWrapper.merchantId = merchantId;
            objReqWrapper.BankTXNId = objDetails.BankTXNId;
            objReqWrapper.status = objDetails.strTransitionstatus;
            objReqWrapper.responseDescription = objDetails.strErrorMessage;
            objReqWrapper.responseCode = objDetails.responseCode;
            objReqWrapper.detailedGatewayResponse = objDetails.strErrorMessage;
            objReqWrapper.currencyCode = objDetails.currencyOfPayment;
            objReqWrapper.feeChrages = 0;
            objReqWrapper.tax = 0;
            pageUrl = objPaymentHandler.savePaymentResponse(objReqWrapper);
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            System.debug('Error Message Line No ==>'+error.getLineNumber());
        }
        return String.isNotBlank(pageUrl) ? true : false;
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

    // ---------------------------------------------------- ICICI Section ends here ---------------------------------------------------

    public String createPaymentRequest(String merchantRefNo,PaymentConfigurationParameters__c objPCP,String paymentGateway, String gatewayVersion) {
        String postData = null;
        if(paymentGateway.equals('HDFC GateWay')) {
            postData = createHDFCRequest(merchantRefNo,objPCP);
        } else if(paymentGateway.equals('BillDesk GateWay') && String.isBlank(gatewayVersion)) {
            postData = createBillDeskRequest(merchantRefNo);
        } else if(paymentGateway.equals('Paytm GateWay')) {
            postData = createPaytmRequest(merchantRefNo,objPCP);
        } 
        return postData;
    }

    public void batchExecute(Map<String,nm_Payment_Initiated__c> MapOfUniqueRefNo) {
        try {
            List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,HDFC_SecretKey__c,HDFC_SALT__c,Paytm_EncryptionKey__c,Paytm_IndustryId__c,Paytm_MID__c,Paytm_Website_Key__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad' LIMIT 1];
            uniqueMerchantRefNoMap = MapOfUniqueRefNo;
            checkOriginalPaymentStatusAndMarkPaymentInitation();
            //Iterate every unique merchant referenc number that is not reflected in Original payment records
            for(String merchantRefNo : uniqueMerchantRefNoMap.keySet()){
                String gatewayName = uniqueMerchantRefNoMap.get(merchantRefNo).nm_PaymentGatewayName__c;
                String gatewayVersion = uniqueMerchantRefNoMap.get(merchantRefNo).Payment_Gateway_Version__c;
                PaymentConfigurationParameters__c objPCP = null;
                // To check if center is upGrad
                if(lstUpgradSupportedGateways.contains(gatewayName) && uniqueMerchantRefNoMap.get(merchantRefNo).IC_Name__c == 'upGrad' && lstPaymentConfigdetails.size() > 0) {
                    objPCP = lstPaymentConfigdetails[0];
                }
                String postData = createPaymentRequest(merchantRefNo,objPCP,gatewayName, gatewayVersion);
                if(gatewayName.equals('HDFC GateWay')) {
                    callQueryAPIHDFC(postData, merchantRefNo, objPCP);
                } else if(gatewayName.equals('BillDesk GateWay') && gatewayVersion == 'v2') {
                    callQueryAPIBillDeskv2(merchantRefNo);
                } else if(gatewayName.equals('BillDesk GateWay') && String.isBlank(gatewayVersion)) {
                    callQueryAPIBillDesk(postData, merchantRefNo);
                } else if(gatewayName.equals('Paytm GateWay')) {
                    callQueryAPIPaytm(postData, merchantRefNo, objPCP);
                } else if(gatewayName.equals('Razorpay GateWay')) {
                    String orderId = uniqueMerchantRefNoMap.get(merchantRefNo).OrderId__c;
                    callQueryAPIRazorpay(orderId,merchantRefNo);
                } else if(gatewayName.equals('ICICI GateWay')) {
                    callQueryAPIICICI(merchantRefNo);
                }
            }

            if(mapOfPaymentStatus.size() > 0) {
                updatePaymentStatus(failedMerchantRefNoGatewayResponseMap, mapOfPaymentStatus);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
    }
    
}