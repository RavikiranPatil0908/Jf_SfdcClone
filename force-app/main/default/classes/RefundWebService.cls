/**
 * @File Name          : RefundWebService.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 07-10-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    29/3/2019, 6:01:56 PM   Balakrishnan     Initial Version
**/
global without sharing class RefundWebService
{
    public static List<String> successList;
    public static List<String> errorList;
    webservice static String inititateRefund(String PaymentId, Decimal RefundAmount)
    {
        errorList = new  List<String>();
        successList = new  List<String>();
        String oppid;
        String csid;
        String veid;
        String queryrefundpaymentrecord;
        SystemConfiguration__c objCustomsetting = SystemConfiguration__c.getValues('System Data');
        String querypaymentrecord = getQueryAllFieldSql('nm_Payment__c', ' id =:PaymentId and Refund_Process_Status__c !=\'Y\'', null);
        List<nm_Payment__c> lstPayment = DataBase.query(querypaymentrecord);
        oppid = lstPayment[0].nm_OpportunityNew__c;
        csid = lstPayment[0].CareerServiceProgram__c;
        veid= lstPayment[0].Validity_Extension__c;
        System.debug('veid==>'+veid);
        if(String.isNotBlank(oppid)) {
            queryrefundpaymentrecord = getQueryAllFieldSql('nmRefund_Payment__c', 'Opportunity__c=:oppid and nm_Payment_Status__c !=\'Payment Refunded\'', null);
        } else if(String.isNotBlank(csid)) {
            queryrefundpaymentrecord = getQueryAllFieldSql('nmRefund_Payment__c', 'CareerServiceProgram__c=:csid and nm_Payment_Status__c !=\'Payment Refunded\'', null);
        } else if(String.isNotBlank(veid)) {
            System.debug('Inside Validity Extension');
            queryrefundpaymentrecord = getQueryAllFieldSql('nmRefund_Payment__c', 'Validity_Extension__c=:veid and nm_Payment_Status__c !=\'Payment Refunded\'', null);
        }
      
        List<nmRefund_Payment__c> lstRefundPayment = DataBase.query(queryrefundpaymentrecord);
		//system.debug('lstRefundPayment==>'+lstRefundPayment[0].Validity_Extension__c);

        List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT isActive__c,Paytm_EncryptionKey__c,Paytm_MID__c,HDFC_SecretKey__c,HDFC_SALT__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];
        PaymentConfigurationParameters__c objPCP = new PaymentConfigurationParameters__c();
        if(lstPaymentConfigdetails.size() > 0) {
            objPCP = lstPaymentConfigdetails[0];
        }

        if(lstPayment.size() > 0 && lstRefundPayment.size() > 0)
        {
            String result = callReundAPI(lstPayment[0], lstRefundPayment[0], RefundAmount, objPCP);
            system.debug('result==>'+result);
            return result;
        }
        else
        {
            return 'Please check refund Intiated record';
        }
    }
    
    public static String getQueryAllFieldSql(String SObjectAPIName, String conditionString, String relatedFields)
    {
        Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
        Map<String, schema.SObjectField> fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List<String> fieldNames = new  List<String>(fieldMap.keySet());
        if(relatedFields != null && relatedFields != '')
        {
            fieldNames.add(relatedFields);
        }
        String query = 'Select ' + String.join(fieldNames, ',') + ' from ' + SObjectAPIName + ' where ' + conditionString;
        return query;
    }
    public static String callReundAPI(nm_Payment__c objPayment, nmRefund_Payment__c objRefundPayment, Decimal RefundAmount, PaymentConfigurationParameters__c objPCP) {
        // HDFC GateWay
        String refundResult = '';
        objPayment.Refund_Payment__c = objRefundPayment.id;
        if('HDFC GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
            String saltKey = Label.HDFC_SALT;
            String key = Label.SECURE_SECRET;
            if(objPayment.IC_Name__c == 'upGrad') {
                key = objPCP.HDFC_SecretKey__c;
                saltKey = objPCP.HDFC_SALT__c;
            }
            
            String method ='cancel_refund_transaction';
            String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
            String var1 = objPayment.nm_TransactionID__c;           
            String var2 = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));         
            String var3= String.valueof(RefundAmount);
                       
            Blob hmacData = Crypto.generateDigest('SHA-512',Blob.valueOf(key+'|'+method+'|'+var1+'|'+saltKey));
            String Hashed = EncodingUtil.convertToHex(hmacData);
          
            String Poststring = 'key=' + key +  '&command=' + method +  '&hash=' + Hashed + '&var1=' + var1 + '&var2=' + var2 + '&var3=' + var3 ;
           
            System.debug('Poststring---->'+Poststring );
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint(Label.HDFC_PostURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(Poststring);
           
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();                  
            if(statusCode == 200) {
                String result = resp.getBody();
                System.debug('result --->'+result );
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                if(!mapOfResponseParameters.isEmpty()) {
                    if(mapOfResponseParameters.containsKey('status')) {
                        String currentStatus = String.valueOf(mapOfResponseParameters.get('status'));
                        if(Integer.valueof(currentStatus)==1) {
                            objPayment.Refund_Paid_Date__c = system.today();
                            objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('txn_update_id'));
                            objPayment.Refund_Process_Status__c = 'Y';
                            //Refund Process Status
                            objPayment.Refunded_Amount__c = RefundAmount;
                            // update Refund Payment Record as Refund Paid 
                            updateRefundPaymentRecord(objRefundPayment.id, var2,  RefundAmount);
                            refundResult = 'Record Refunded Successfully'; 
                        } else {
                            objPayment.nm_Error_Code__c = String.valueOf( mapOfResponseParameters.get('status'));
                            objPayment.Refund_Initiated_Error_Message__c =String.valueOf( mapOfResponseParameters.get('msg'));
                            refundResult = objPayment.Refund_Initiated_Error_Message__c;
                        }
                        update objPayment;
                        if(refundResult == 'Record Refunded Successfully') {
                            CheckTotalAmountRefunded(objRefundPayment.id);                                             
                        }
                    } else {
                        refundResult = 'Size zero';
                    }
                }                
            }                  
        }
     

        if('Razorpay Gateway'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)){
            String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
            String paymentId = objPayment.Online_Payment_Id__c;
            String MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));         
    
            Decimal amount = RefundAmount * 100; // Dollar subunits 100 cents = 1 Dollar
            Map<String,Object> mapOfParametersToPass = new Map<String,Object>();
            mapOfParametersToPass.put('amount',amount); 
            mapOfParametersToPass.put('receipt',MerchantRefundNo);
            mapOfParametersToPass.put('speed', 'normal');
            String jsonBodyParam = JSON.serialize(mapOfParametersToPass);
            System.debug('Before mapOfParametersToPass = '+jsonBodyParam);

            Blob headerValue = Blob.valueOf(Label.RazorPay_key_id +':'+Label.RazorPay_key_secret);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            String RazorpayRefudUrl = 'https://api.razorpay.com/v1/payments/'+paymentId+'/refund';
            if(Test.isRunningTest()) { 
                RazorpayRefudUrl = Label.Site_Url;
            }
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint(RazorpayRefudUrl);
            req.setMethod('POST');
            req.setHeader('Authorization',authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonBodyParam);
            System.debug('Request --->'+req.getBody());
        
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200) {
                String result = resp.getBody();
                System.debug('result --->'+result );
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                if(!mapOfResponseParameters.isEmpty()) {
                    if(mapOfResponseParameters.containsKey('status')) {
                        String currentStatus = String.valueOf(mapOfResponseParameters.get('status'));
                        if(currentStatus == 'processed' ) {
                            objPayment.Refund_Paid_Date__c = system.today();
                            objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('id'));
                            objPayment.Refund_Process_Status__c = 'Y';
                            //Refund Process Status
                            objPayment.Refunded_Amount__c = RefundAmount;
                            // update Refund Payment Record as Refund Paid 
                            updateRefundPaymentRecord(objRefundPayment.id, MerchantRefundNo,  RefundAmount);
                            refundResult = 'Record Refunded Successfully'; 
                        } else {
                            objPayment.Refund_Process_Status__c = String.valueOf(mapOfResponseParameters.get('status'));
                            objPayment.Refund_Error_Code__c = objPayment.Refund_Process_Status__c;
                            objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('id'));
                            refundResult = objPayment.Refund_Initiated_Error_Message__c;
                        }
                        update objPayment;
                        if(refundResult == 'Record Refunded Successfully') {
                            CheckTotalAmountRefunded(objRefundPayment.id);                                             
                        }
                    } else {
                        refundResult = 'Size zero';
                    } 
                } 
            }        
        }


        // if('CCAvenue GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)){
        //     String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
        //     String transId = objPayment.nm_TransactionID__c;
        //     Decimal RefAmount = RefundAmount;
        //     //Decimal reference_no = Refno;
        //     String RefundRefno = 'RefundRefno';
        //     String refund_ref_no = RefundRefno;
        //     String MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));

        //     Map<String,String> mapOfParametersToPass = new Map<String,String>();
        //     mapOfParametersToPass.put('refund_amount',String.valueOf(RefundAmount)); // Dollar subunits 100 cents = 1 Dollar
        //     mapOfParametersToPass.put('reference_no',objPayment.nm_TransactionID__c);
        //     mapOfParametersToPass.put('refund_ref_no',RefundRefno);


        //     string jsonstring = JSON.serialize(mapOfParametersToPass);
        //     String masterKey = !Test.isRunningTest() ? nmCommon.getConfigSettings('CCAvenue_Encryption_Key__c') : '80F9259185AE3CF4C05D512E8D93B6ZZ';
        //     Encryption encryption = new AesEncryptionCCAvenue();
        //     String checkSumValue = encryption.encrypt(jsonstring, masterKey);
        //     String requestData = 'enc_request='+checkSumValue+'&access_code='+nmCommon.getConfigSettings('CCAvenue_Access_Code__c')+'&command=refundOrder&request_type=JSON&response_type=JSON&version=1.1';
            
        //     HttpRequest req = new HttpRequest();
        //     req.setEndpoint('https://login.ccavenue.com/apis/servlet/DoWebTrans?'+requestData);
        //     req.setMethod('POST');
        //     req.setbody(requestData);
        //     Http http = new Http();
        //     HTTPResponse res = http.send(req);      
        //     Integer statusCode = res.getStatusCode();
        //     System.debug('callQueryAPI:statusCode = '+statusCode);
        //     if(statusCode == 200) {
        //         String result = res.getBody();
        //         System.debug('result --->'+result );
        //         Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
        //         if(!mapOfResponseParameters.isEmpty()) {
        //             if(mapOfResponseParameters.containsKey('status')) {
        //                 String currentStatus = String.valueOf(mapOfResponseParameters.get('status'));
        //                 if(currentStatus == '0' ) {
        //                     objPayment.Refund_Paid_Date__c = system.today();
        //                     objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('id'));
        //                     objPayment.Refund_Process_Status__c = 'Y';
        //                     //Refund Process Status
        //                     objPayment.Refunded_Amount__c = RefundAmount;
        //                     // update Refund Payment Record as Refund Paid 
        //                     updateRefundPaymentRecord(objRefundPayment.id, MerchantRefundNo,  RefundAmount);
        //                     refundResult = 'Record Refunded Successfully'; 
        //                 } else {
        //                     objPayment.nm_Error_Code__c = String.valueOf( mapOfResponseParameters.get('status'));
        //                     objPayment.Refund_Initiated_Error_Message__c =String.valueOf( mapOfResponseParameters.get('msg'));
        //                     refundResult = objPayment.Refund_Initiated_Error_Message__c;
        //                 }
        //                 update objPayment;
        //                 if(refundResult == 'Record Refunded Successfully') {
        //                     CheckTotalAmountRefunded(objRefundPayment.id);                                             
        //                 }
        //             } else {
        //                 refundResult = 'Size zero';
        //             } 
        //         } 
        //     }    
        // } 

        if('BillDesk GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c) && String.isBlank(objPayment.Payment_Gateway_Version__c)) {
            Datetime transdateTime = objPayment.nm_TransactionDate__c;
            String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
            String RequestType = '0400';
            // fixed provided by Bank
            String transId = objPayment.nm_TransactionID__c;
            String formattedDateTime = transdateTime.format('yyyyMMdd');
            String CustomerID = merchantRefNo;
            Decimal TxnAmount = objPayment.nm_ActualPaymentAmmount__c;
            Decimal RefAmount = RefundAmount;
            if(Label.Environment != null && Label.Environment == 'Sandbox') {
                TxnAmount = 1;
                RefAmount = 1;
            }
            Datetime currentDateTime = Datetime.now();
            String RefDateTime = currentDateTime.format('yyyyMMddHHmmss');
            String MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));
            String msg = RequestType + '|NMIMS|' + transId + '|' + formattedDateTime + '|' + CustomerID + '|' + TxnAmount + '|' + RefAmount + '|' + RefDateTime + '|' + MerchantRefundNo + '|NA|NA|NA';
            //Generate checksumkey
            String algorithmName = 'HmacSHA256';
            String secretKey = 'eSTTsLAjCzks';
            Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(msg), Blob.valueOf(secretKey));
            String checkSum = EncodingUtil.convertToHex(hmacData);
            //Append Checksum at the end of the message.
            msg = msg + '|' + checkSum.touppercase();
            System.debug('After msg = ' + msg);
            // call Refund API 
            HttpRequest req = new  HttpRequest();
            req.setEndpoint(Label.BillDesk_Refund_API);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
            req.setBody('msg=' + msg);
            Http http = new  Http();
            HTTPResponse res = http.send(req);
            Integer statusCode = res.getStatusCode();
            System.debug('callQueryAPI:statusCode = ' + statusCode);
            if(statusCode == 200) {
                String result = res.getBody();
                System.debug('callQueryAPI:result = ' + result);
                //Query API returns one additional paramter, remove that so that response is same as original gateway call result
                String trimmedResult = result.subString(result.indexOf('|') + 1, result.length());
                String[] responseParameters = trimmedResult.split('\\|');
                if(responseParameters.size() > 0) {
                    String refundStatusCode = responseParameters[7];
                    System.debug('trimmedResult -->'+ responseParameters);
                    System.debug('refundStatusCode ->'+refundStatusCode);
                    //Refund Status code
                    // if Refund Successfully then update Original Payment to Refunded Completed 
                    if(refundStatusCode == '0799') {
                        objPayment.Refund_Paid_Date__c = system.today();
                        objPayment.RefundId__c = responseParameters[8];
                        //Refund Trans Id
                        objPayment.Refund_Process_Status__c = responseParameters[11];
                        //Refund Process Status
                        objPayment.Refunded_Amount__c = RefundAmount;
                        // update Refund Payment Record as Refund Paid 
                        
                        updateRefundPaymentRecord(objRefundPayment.id, MerchantRefundNo,  RefundAmount);
                        refundResult = 'Record Refunded Successfully';
                    } else {
                        objPayment.nm_Error_Code__c = responseParameters[9];
                        objPayment.Refund_Initiated_Error_Message__c = responseParameters[10];
                        refundResult = objPayment.Refund_Initiated_Error_Message__c;
                    }
                    objPayment.Refund_Request__c = msg;
                    objPayment.Online_Response_Error__c = result;
                    Update objPayment;
                    CheckTotalAmountRefunded(objRefundPayment.id);
                } else {
                    refundResult = 'Size zero';
                }
            }
        }

        if('BillDesk GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c) && objPayment.Payment_Gateway_Version__c == 'v2' && objPayment.Transaction_DateTime__c != null) {
            API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
            Map<String,Object> mapOfResponseParameters = new Map<String,Object>();    
            String merc_refund_ref_no = 'REF' + objPayment.nm_Merchant_Track_Id__c + String.valueOf((Integer)Math.floor(Math.random() * 100));
            Map<String,Object> mapOfParametersToPass = new Map<String,Object>();
            mapOfParametersToPass.put('transactionid', objPayment.nm_TransactionID__c);
            mapOfParametersToPass.put('orderid',objPayment.nm_Merchant_Track_Id__c);
            mapOfParametersToPass.put('mercid',BilldeskV2.Merchant_ID__c);
            mapOfParametersToPass.put('transaction_date',objPayment.Transaction_DateTime__c.format('yyyy-MM-dd\'T\'HH:mm:ss', 'IST') + '+05:30');
            mapOfParametersToPass.put('txn_amount', String.valueOf(objPayment.nm_ActualPaymentAmmount__c.setScale(2)) );
            mapOfParametersToPass.put('refund_amount', String.valueOf(RefundAmount.setScale(2)) );
            mapOfParametersToPass.put('currency','356');
            mapOfParametersToPass.put('merc_refund_ref_no', merc_refund_ref_no);
            String jsonBodyParam = JSON.serialize(mapOfParametersToPass);

            String headerJWS = '{"alg":"HS256","clientid":"' + BilldeskV2.Client_ID__c + '"}';
            string jwt = nmBillDeskHelper.base64URLencode(blob.valueof(headerJWS)) + '.' +nmBillDeskHelper.base64URLencode(blob.valueof(jsonBodyParam));
            blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),blob.valueof(BilldeskV2.Secret_Key__c));

            String billDeskV2Url = BilldeskV2.Base_Url__c + 'payments/ve1_2/refunds/create';
            if(Test.isRunningTest()) { 
                billDeskV2Url = Label.Site_Url;
            }
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(billDeskV2Url);
            req.setMethod('POST');
            req.setHeader('content-type', 'application/jose');
            req.setHeader('accept', 'application/jose');
            req.setHeader('bd-traceid', merc_refund_ref_no);
            req.setHeader('bd-timestamp', String.valueOf(Datetime.now().getTime()) );
            req.setBody(jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
            System.debug('Request --->'+jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            String result = resp.getBody();
            System.debug('RESULT ===>'+result);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                List<String> resultSplit = String.isNotBlank(result) ? result.split('\\.') : new List<String>();
                if (resultSplit.size() == 3 && nmBillDeskHelper.hmacSHA256Verification(resultSplit[0], resultSplit[1], resultSplit[2], BilldeskV2.Secret_Key__c)) {
                    mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped((EncodingUtil.base64decode(resultSplit[1])).toString());
                    if(!mapOfResponseParameters.isEmpty()) {
                        if(mapOfResponseParameters.containsKey('refund_status')) {
                            String currentStatus = String.valueOf(mapOfResponseParameters.get('refund_status'));
                            if(currentStatus == '0799' || currentStatus == '0699' ) {
                                objPayment.Refund_Paid_Date__c = system.today();
                                objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('refundid'));
                                objPayment.Refund_Process_Status__c = 'Y';
                                //Refund Process Status
                                objPayment.Refunded_Amount__c = RefundAmount;
                                // update Refund Payment Record as Refund Paid 
                                updateRefundPaymentRecord(objRefundPayment.id, merc_refund_ref_no,  RefundAmount);
                                CheckTotalAmountRefunded(objRefundPayment.id); 
                                refundResult = 'Record Refunded Successfully'; 
                            } else {
                                objPayment.Refund_Process_Status__c = currentStatus;
                                objPayment.Refund_Error_Code__c = objPayment.Refund_Process_Status__c;
                                objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('refundid'));
                                objPayment.Refund_Initiated_Error_Message__c = objPayment.Refund_Error_Code__c;
                                refundResult = objPayment.Refund_Error_Code__c;
                            }
                            update objPayment;
                        } else {
                            refundResult = 'Size zero';
                        } 
                    } 
                }
            }
        }

        /* Paytm v2.0 */   
        if('Paytm GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
            String masterKey = Label.Paytm_Encryption_Key;
            String merchantKey = Label.Paytm_Merchant_Key;
            if(objPayment.IC_Name__c == 'upGrad') { 
                masterKey = objPCP.Paytm_EncryptionKey__c;
                merchantKey = objPCP.Paytm_MID__c;
            }
            String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
            String MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));

            /* initialize an object */
            Map<String, Map<String,String>> paytmParams = new Map<String, Map<String,String>>();
            /* body parameters */
            Map<String, String> body = new Map<String,String>();
            /* head parameters */
            Map<String, String> head = new Map<String,String>();

            body.put('mid', merchantKey);
            body.put('txnType', 'REFUND');
            body.put('orderId', merchantRefNo);
            body.put('txnId', objPayment.nm_TransactionID__c);
            body.put('refId', MerchantRefundNo);
            body.put('refundAmount', String.valueOf(RefundAmount));
            String jsonBodyParam = JSON.serialize(body);
            System.debug('jsonBodyParam ==>'+jsonBodyParam);
            //Generate checksumkey
            String paytmChecksum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(masterKey, jsonBodyParam);

            head.put('clientId', 'C11');
            /* put generated checksum value here */
            head.put('signature', paytmChecksum);

            /* prepare JSON string for request */
            paytmParams.put('body', body);
            paytmParams.put('head', head);

            //Serialize the Map to json
            String postData = JSON.serialize(paytmParams);
            // postData = 'JsonData=' + postData;
            System.debug('postData---->'+postData);

            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String refundURL = nmCommon.getConfigSettings('Paytm_Refund_Url__c');
            if(Test.isRunningTest()){
                refundURL = 'https://securegw-stage.paytm.in/refund/apply';
            }
            req.setEndpoint(refundURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(postData);
           
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode(); 

            if(statusCode == 200) {
                String result = resp.getBody();
                System.debug('result --->'+result );
                PaytmRefundResponseWrapper respWrapper = PaytmRefundResponseWrapper.parse(result);
                if(respWrapper!=null && respWrapper.body!=null && respWrapper.body.resultInfo!=null && String.isNotBlank(respWrapper.body.resultInfo.resultCode)) {
                    if(respWrapper.body.resultInfo.resultCode == '10') {
                        objPayment.Refund_Paid_Date__c = System.today();
                        objPayment.RefundId__c = respWrapper.body.refId;
                        objPayment.Refund_Process_Status__c = 'Y';
                        //Refund Process Status
                        objPayment.Refunded_Amount__c = RefundAmount;
                        
                        // update Refund Payment Record as Refund Paid 
                        updateRefundPaymentRecord(objRefundPayment.id, MerchantRefundNo,  RefundAmount);
                        CheckTotalAmountRefunded(objRefundPayment.id); 
                        refundResult = 'Record Refunded Successfully';
                    } else {
                        objPayment.Refund_Process_Status__c = respWrapper.body.resultInfo.resultStatus;
                        objPayment.Refund_Error_Code__c = respWrapper.body.resultInfo.resultCode;
                        objPayment.Refund_Initiated_Error_Message__c = respWrapper.body.resultInfo.resultMsg;
                        objPayment.RefundId__c = respWrapper.body.refId;
                        refundResult = respWrapper.body.resultInfo.resultMsg;
                    }
                    update objPayment;
                } else {
                    refundResult = 'Size zero';
                }
            }                  
        }

        if('ICICI GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
            Map<String,Object> mapOfResponseParameters = new Map<String,Object>();        
            String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
            String MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));
        
            Map<String, Object> ICICIParams = new Map<String, Object>();
            ICICIParams.put('refund_id', MerchantRefundNo);
            ICICIParams.put('refund_amount', RefundAmount);

            String ICICIRefundUri = nmCommon.getConfigSettings('ICICI_Base_Url__c') + '/orders/'+ objPayment.nm_Merchant_Track_Id__c +'/refunds';
            System.debug('ICICIRefundUri ==>'+ICICIRefundUri);
            String postData = JSON.serialize(ICICIParams);
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(ICICIRefundUri);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setHeader('x-api-version','2022-01-01');
            req.setHeader('x-client-id',Label.ICICI_App_Id);
            req.setHeader('x-client-secret',Label.ICICI_Secret_Key);
            req.setBody(postData);
            System.debug('Request --->'+req.getBody());
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode(); 
            system.debug('statusCode==>'+statusCode);
            if(statusCode == 200) {
                String result = resp.getBody();
                System.debug('result --->'+result );
                mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);

                if(!mapOfResponseParameters.isEmpty()) {
                    if(mapOfResponseParameters.containsKey('refund_status')) {
                        String currentStatus = String.valueOf(mapOfResponseParameters.get('refund_status'));
                        if(currentStatus == 'SUCCESS' ) {
                            objPayment.Refund_Paid_Date__c = system.today();
                            objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('refund_id'));
                            objPayment.Refund_Process_Status__c = 'Y';
                            //Refund Process Status
                            objPayment.Refunded_Amount__c = RefundAmount;
                            // update Refund Payment Record as Refund Paid 
                            updateRefundPaymentRecord(objRefundPayment.id, MerchantRefundNo,  RefundAmount);
                            CheckTotalAmountRefunded(objRefundPayment.id); 
                            refundResult = 'Record Refunded Successfully'; 
                        } else {
                            objPayment.Refund_Process_Status__c = String.valueOf(mapOfResponseParameters.get('refund_status'));
                            objPayment.Refund_Error_Code__c = objPayment.Refund_Process_Status__c;
                            objPayment.RefundId__c = (String)mapOfResponseParameters.get('refund_id');
                            objPayment.Refund_Initiated_Error_Message__c = (String)mapOfResponseParameters.get('status_description');
                            refundResult = objPayment.Refund_Initiated_Error_Message__c;
                        }
                        update objPayment;
                    } else {
                        refundResult = 'Size zero';
                    } 
                } 


            }
        }

        // if('PayPal GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)){
            
        //     String result = PayPalWebService.PayPalRefundRequest(String.valueOf(RefundAmount),objPayment.Online_Response_Error__c,objPayment.nm_Merchant_Track_Id__c,objPayment.Id);
        //     System.debug('result --->'+result );
        //     String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
        //     String var2 = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));
        //     if(String.isNotBlank(result)){
        //         Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
        //         System.debug('mapOfResponseParameters '+mapOfResponseParameters);
        //         Map<String,Object> mapOfdetailsParameters = new Map<String,Object>();
        //         List<Object> lstofDetails = new List<Object>();

        //         if(!mapOfResponseParameters.isEmpty()) {
        //             if(mapOfResponseParameters.containsKey('state')) {
        //                 String currentStatus = String.valueOf(mapOfResponseParameters.get('state'));
        //                 if(currentStatus.equalsIgnoreCase('COMPLETED')) {
        //                     objPayment.Refund_Paid_Date__c = system.today();
        //                     objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('id'));
        //                     objPayment.Refund_Process_Status__c = 'Y';
        //                     //Refund Process Status
        //                     objPayment.Refunded_Amount__c = RefundAmount;
        //                     // update Refund Payment Record as Refund Paid 
        //                     updateRefundPaymentRecord(objRefundPayment.id, var2,  RefundAmount);
        //                     refundResult = 'Record Refunded Successfully'; 
        //                 } 
        //             } else {
        //                 String responseResult = '';
        //                 if(mapOfResponseParameters.containsKey('name')){
        //                     objPayment.nm_Error_Code__c = String.valueOf( mapOfResponseParameters.get('name'));
        //                     if(mapOfResponseParameters.containsKey('details')){    
        //                         lstofDetails = (List<Object>)mapOfResponseParameters.get('details');
        //                         if(lstofDetails.size()>0){
        //                             for(Object obj:lstofDetails){
        //                                 mapOfdetailsParameters = (Map<String,Object>)obj;
        //                                 if(!mapOfdetailsParameters.isEmpty() && mapOfdetailsParameters.containsKey('field')){
        //                                     responseResult = String.valueOf(mapOfdetailsParameters.get('issue'));
        //                                 }
        //                             }
        //                         }
        //                     }else{
        //                         if(mapOfResponseParameters.containsKey('message')){
        //                             System.debug(mapOfResponseParameters.get('message'));
        //                             responseResult = String.valueOf(mapOfResponseParameters.get('message'));
        //                         }
        //                     }

        //                     objPayment.Refund_Initiated_Error_Message__c = responseResult;
        //                     refundResult = objPayment.Refund_Initiated_Error_Message__c;    
        //                 }
        //             }
        //             try {
        //                 update objPayment;    
        //             } catch (DMLException e) {
        //                 System.debug('Error '+e.getMessage());
        //             }
                    
        //             if(refundResult == 'Record Refunded Successfully') {
        //                 CheckTotalAmountRefunded(objRefundPayment.id);                                             
        //             }
        //         }
        //     }                  
        // }
        return refundResult;
    }

    public static void updateRefundPaymentRecord(String RefundId, String Merchantid,  Decimal refundedAmount)
    {
        Double refundsum;
        Double diffrefamount;
        String queryrefundpaymentrecord = getQueryAllFieldSql('nmRefund_Payment__c', 'id=:RefundId', null);
        List<nmRefund_Payment__c> lstRefundPayment = DataBase.query(queryrefundpaymentrecord);
        List<nmRefund_Payment__c> lstRefundToUpdate = new  List<nmRefund_Payment__c>();
        /*  refundsum = (Decimal)[select Sum(Refunded_Amount__c)refundamount
        from  nm_Payment__c
        where nm_OpportunityNew__c=:OpportunityID][0].get('refundamount');
        
        */
        if(lstRefundPayment.size() > 0) {
            for(nmRefund_Payment__c objRefund: lstRefundPayment) {
                //diffrefamount = objRefund.Total_amount_to_refund__c - refundsum;
                /*  if(diffrefamount <= 0)
                {
                objRefund.nm_Payment_Status__c = 'Payment Refunded';
                }*/
                objRefund.nm_Transaction_Date__c = System.today();
                if(objRefund.Merchant_ID__c != null && objRefund.Merchant_ID__c != '') {
                    objRefund.Merchant_ID__c = objRefund.Merchant_ID__c + ',' + Merchantid;
                }else{
                    objRefund.Merchant_ID__c = Merchantid;
                }
                System.debug('refundedAmount -->'+refundedAmount);
                if(objRefund.Refunded_Amount__c != null) {
                    objRefund.Refunded_Amount__c = objRefund.Refunded_Amount__c + refundedAmount;
                } else {
                    objRefund.Refunded_Amount__c = refundedAmount;
                }
                System.debug('objRefund.Refunded_Amount__c -->'+objRefund.Refunded_Amount__c);
                lstRefundToUpdate.add(objRefund);
            }
        }
        if(lstRefundToUpdate.size() > 0) {
            Update lstRefundToUpdate;
        }
    }

    public static void CheckTotalAmountRefunded(String RefundId) {
        String queryrefundpayment = getQueryAllFieldSql('nmRefund_Payment__c', 'id=:RefundId', null);
        List<nmRefund_Payment__c> lstRefundPaymentcheck = DataBase.query(queryrefundpayment);
        List<nmRefund_Payment__c> lstRefundToUpdate = new  List<nmRefund_Payment__c>();
        if(lstRefundPaymentcheck.size() > 0)
        {
            for(nmRefund_Payment__c objRefund: lstRefundPaymentcheck)
            {
                if(objRefund.RefundAmountPending__c <= 0)
                {
                    objRefund.nm_Payment_Status__c = 'Payment Refunded';
                    objRefund.Status__c= 'Payment Refunded';
                    objRefund.Payment_Refunded_D_T__c= System.Now();
                    lstRefundToUpdate.add(objRefund);
                }
            }
        }
        if(lstRefundToUpdate.size() > 0)
        {
            Update lstRefundToUpdate;
        }
    }
}