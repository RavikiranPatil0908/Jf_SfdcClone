/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public class MassRefundBatchController implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    
    public Set<String> lstFailedRecords;
    public Integer successCount = 0;
    public Integer failedCount = 0;
    public Integer totalCount = 0;

    public void execute(SchedulableContext sc) {
        MassRefundBatchController b = new MassRefundBatchController();
        Database.executebatch(b, 10);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = getQueryAllFieldSql('nmRefund_Payment__c', 'Status__c=\'Refund Submitted to Finance\' AND Process_Refund__c=TRUE AND Refunded_Amount__c=null AND Refund_Initiated__c=FALSE AND Avoid_Batch__c=FALSE ORDER BY Name ASC LIMIT '+System.Label.MassRefundLimit, null);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<nmRefund_Payment__c> scope) { 
        try {
            Map<String,String> mapOppIdVsRefundId = new Map<String,String>();
            Map<String,nmRefund_Payment__c> mapOfRefundIdVsRefund = new Map<String,nmRefund_Payment__c>();
            for (nmRefund_Payment__c objRP : scope) {
                if(String.isNotBlank(objRP.Opportunity__c)) {
                    mapOppIdVsRefundId.put(objRP.Opportunity__c,objRP.id);
                }
                mapOfRefundIdVsRefund.put(objRP.id,objRP);
            }

            Map<String,List<nm_Payment__c>> mapOfRPIdVsPayments = getPayments(mapOppIdVsRefundId,mapOfRefundIdVsRefund);
            List<nm_Payment__c> lstPaymentToUpdate = new List<nm_Payment__c>();
            List<nmRefund_Payment__c> lstRPToUpdate = new List<nmRefund_Payment__c>();
            Map<String,nmRefund_Payment__c> mapOfIdVsRefundToUpdate = new Map<String,nmRefund_Payment__c>();
            for (String refundId : mapOfRPIdVsPayments.keySet()) {
                nmRefund_Payment__c objRP = mapOfRefundIdVsRefund.get(refundId);
                for (nm_Payment__c objPayment : mapOfRPIdVsPayments.get(refundId)) {
                    System.debug('objPayment ==>'+objPayment);
                    RPPackage objPackage = callReundAPI(objPayment,objRP,objPayment.nm_ActualPaymentAmmount__c);
                    System.debug('result==>'+objPackage.refundResult);
                    if(objPackage.objPayment!=null) {
                        lstPaymentToUpdate.add(objPackage.objPayment);
                    }

                    // update Refund Payment Record as Refund Paid 
                    if(objPackage.refundResult == 'Record Refunded Successfully' || objPackage.refundResult == 'PENDING') {
                        objPackage.objRP = mapOfIdVsRefundToUpdate.containsKey(objRP.id) ? mapOfIdVsRefundToUpdate.get(objRP.id) : objRP;
                        objPackage.objRP = updateRefundPaymentRecord(objPackage.objRP, objPackage.MerchantRefundNo, objPayment.nm_ActualPaymentAmmount__c,objPackage.refundResult);
                        mapOfIdVsRefundToUpdate.put(objPackage.objRP.id,objPackage.objRP);
                    }
                }
            }

            if(mapOfIdVsRefundToUpdate.size() > 0) {
                update mapOfIdVsRefundToUpdate.values();
            }

            if(lstPaymentToUpdate.size() > 0) {
                upatePaymentRecords(lstPaymentToUpdate);
            }

        } catch (Exception e) {
            System.debug('Error 1 ==>'+e.getMessage());
            System.debug('Error 1 ==>'+e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
            sendErrorMail();
        }
    }

    public Map<String,List<nm_Payment__c>> getPayments(Map<String,String> mapOppIdVsRefundId,Map<String,nmRefund_Payment__c> mapOfRefundIdVsRefund) {
        Set<String> setOppId = mapOppIdVsRefundId.keySet();
        String querypaymentrecord = getQueryAllFieldSql('nm_Payment__c', 'nm_OpportunityNew__c IN :setOppId AND nm_ModeOfPayment__c=\'Online\' AND (nm_PaymentStatus__c=\'Payment Made\' OR nm_PaymentStatus__c=\'Payment Approved\') AND Refund_Payment__c=null', null);
        List<nm_Payment__c> lstPayment = DataBase.query(querypaymentrecord);
        System.debug('lstPayment Size'+lstPayment.size());
        Map<String,Map<String,nm_Payment__c>> mapOfRefundVsMapOfPtIdVsPayment = new Map<String,Map<String,nm_Payment__c>>();
        for (nm_Payment__c objPayment : lstPayment) {
            List<String> lstPaymentIdsToRemove = new List<String>();
            String refundId = mapOppIdVsRefundId.get(objPayment.nm_OpportunityNew__c);
            Map<String,nm_Payment__c> mapOfPtIdVsPayment = mapOfRefundVsMapOfPtIdVsPayment.containsKey(refundId) ? mapOfRefundVsMapOfPtIdVsPayment.get(refundId) : new Map<String,nm_Payment__c>();
            if(mapOfPtIdVsPayment.size() > 0) {
                Boolean checkTrackIdExists = false;
                for(String paymentId : mapOfPtIdVsPayment.keySet()) {
                    nm_Payment__c objPay = mapOfPtIdVsPayment.get(paymentId);
                    if(objPay.nm_Merchant_Track_Id__c == objPayment.nm_Merchant_Track_Id__c) {
                        checkTrackIdExists=true;
                        if(objPayment.nm_ActualPaymentAmmount__c > objPayment.nm_Amount__c && objPayment.nm_Amount__c > objPay.nm_Amount__c) {
                            lstPaymentIdsToRemove.add(paymentId);
                            mapOfPtIdVsPayment.put(objPayment.id,objPayment);
                        }
                    }
                }
                if(!checkTrackIdExists) {
                    mapOfPtIdVsPayment.put(objPayment.id,objPayment);
                }
            } else {
                mapOfPtIdVsPayment.put(objPayment.id,objPayment);
            }
            if(lstPaymentIdsToRemove.size() > 0) {
                for (String paymentId : lstPaymentIdsToRemove) {
                    mapOfPtIdVsPayment.remove(paymentId);
                }
            }
            mapOfRefundVsMapOfPtIdVsPayment.put(refundId,MapOfPtIdVsPayment);
        }

        Map<String,List<nm_Payment__c>> mapOfRPIdVsPayments = new Map<String,List<nm_Payment__c>>();
        for (String refundId : mapOfRefundVsMapOfPtIdVsPayment.keySet()) {
            nmRefund_Payment__c objRP = mapOfRefundIdVsRefund.get(refundId);
            Decimal totalAmount = 0;
            Map<String,nm_Payment__c> mapOfPtIdVsPayment = mapOfRefundVsMapOfPtIdVsPayment.get(refundId);
            System.debug('mapOfPtIdVsPayment Size'+mapOfPtIdVsPayment.size());
            for (nm_Payment__c objPayment : mapOfPtIdVsPayment.values()) {
                System.debug('objPayment.nm_ActualPaymentAmmount__c ==>'+objPayment.nm_ActualPaymentAmmount__c);
                totalAmount += objPayment.nm_ActualPaymentAmmount__c;
            }
            System.debug('totalAmount ==>'+totalAmount);
            if(totalAmount==objRP.Total_amount_to_refund__c) {
                mapOfRPIdVsPayments.put(refundId,MapOfPtIdVsPayment.values());
            }
        }
        return mapOfRPIdVsPayments;
    }

    public String getQueryAllFieldSql(String SObjectAPIName, String conditionString, String relatedFields) {
        Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
        Map<String, schema.SObjectField> fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List<String> fieldNames = new  List<String>(fieldMap.keySet());
        if(relatedFields != null && relatedFields != '')
        {
            fieldNames.add(relatedFields);
        }
        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + SObjectAPIName + ' WHERE ' + conditionString;
        return query;
    }

    public RPPackage callReundAPI(nm_Payment__c objPayment, nmRefund_Payment__c objRefundPayment, Decimal refundAmount) {
        RPPackage objPackage = new RPPackage();
        String MerchantRefundNo = '';
        try {
            // HDFC GateWay
            String refundResult = '';
            objPayment.Refund_Payment__c = objRefundPayment.id;
            if('HDFC GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
                String saltKey = Label.HDFC_SALT;
                String key = Label.SECURE_SECRET;
                
                String method ='cancel_refund_transaction';
                String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
                String var1 = objPayment.nm_TransactionID__c;           
                MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));         
                String var3= String.valueof(refundAmount);
                        
                Blob hmacData = Crypto.generateDigest('SHA-512',Blob.valueOf(key+'|'+method+'|'+var1+'|'+saltKey));
                String Hashed = EncodingUtil.convertToHex(hmacData);
            
                String Poststring = 'key=' + key +  '&command=' + method +  '&hash=' + Hashed + '&var1=' + var1 + '&var2=' + MerchantRefundNo + '&var3=' + var3 ;
            
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
                                objPayment.Refunded_Amount__c = refundAmount;
                                // update Refund Payment Record as Refund Paid 
                                objPackage.refundResult = 'Record Refunded Successfully';
                            } else {
                                objPayment.nm_Error_Code__c = String.valueOf( mapOfResponseParameters.get('status'));
                                objPayment.Refund_Initiated_Error_Message__c =String.valueOf( mapOfResponseParameters.get('msg'));
                                objPackage.refundResult = objPayment.Refund_Initiated_Error_Message__c;
                            }
                            objPayment.Refund_Payment__c = objRefundPayment.id;
                            objPackage.objPayment = objPayment;
                        } else {
                            objPackage.refundResult = 'Size zero';
                        }
                    }                
                }                  
            }

            if('Razorpay Gateway'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)){
                String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
                String paymentId = objPayment.Online_Payment_Id__c;
                MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));         
        
                Decimal amount = refundAmount * 100; // Dollar subunits 100 cents = 1 Dollar
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
                                objPayment.Refunded_Amount__c = refundAmount;
                                // update Refund Payment Record as Refund Paid 
                                objPackage.refundResult = 'Record Refunded Successfully'; 
                            } else {
                                objPayment.Refund_Process_Status__c = String.valueOf(mapOfResponseParameters.get('status'));
                                objPayment.Refund_Error_Code__c = objPayment.Refund_Process_Status__c;
                                objPayment.RefundId__c = String.valueOf(mapOfResponseParameters.get('id'));
                                objPackage.refundResult = objPayment.Refund_Initiated_Error_Message__c;
                            }
                            objPayment.Refund_Payment__c = objRefundPayment.id;
                            objPackage.objPayment = objPayment;
                        } else {
                            objPackage.refundResult = 'Size zero';
                        } 
                    } 
                }        
            }

            if('BillDesk GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
                Datetime transdateTime = objPayment.nm_TransactionDate__c;
                String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
                String RequestType = '0400';
                // fixed provided by Bank
                String transId = objPayment.nm_TransactionID__c;
                String formattedDateTime = transdateTime.format('yyyyMMdd');
                String CustomerID = merchantRefNo;
                Decimal TxnAmount = objPayment.nm_ActualPaymentAmmount__c;
                Decimal RefAmount = refundAmount;
                if(Label.Environment != null && Label.Environment == 'Sandbox') {
                    TxnAmount = 1;
                    RefAmount = 1;
                }
                Datetime currentDateTime = Datetime.now();
                String RefDateTime = currentDateTime.format('yyyyMMddHHmmss');
                MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));
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
                            objPayment.Refunded_Amount__c = refundAmount;
                            // update Refund Payment Record as Refund Paid 
                            
                            objPackage.refundResult = 'Record Refunded Successfully';
                        } else {
                            objPayment.nm_Error_Code__c = responseParameters[9];
                            objPayment.Refund_Initiated_Error_Message__c = responseParameters[10];
                            objPackage.refundResult = objPayment.Refund_Initiated_Error_Message__c;
                        }
                        objPayment.Refund_Request__c = msg;
                        objPayment.Online_Response_Error__c = result;
                        objPayment.Refund_Payment__c = objRefundPayment.id;
                        objPackage.objPayment = objPayment;
                    } else {
                        objPackage.refundResult = 'Size zero';
                    }
                }
            }

            /* Paytm v2.0 */   
            if('Paytm GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
                String masterKey = Label.Paytm_Encryption_Key;
                String merchantKey = Label.Paytm_Merchant_Key;
                String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
                MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));

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
                body.put('refundAmount', String.valueOf(refundAmount));
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
                            objPayment.Refunded_Amount__c = refundAmount;
                            // update Refund Payment Record as Refund Paid 
                            objPackage.refundResult = 'Record Refunded Successfully';
                        } else {
                            objPayment.Refund_Process_Status__c = respWrapper.body.resultInfo.resultStatus;
                            objPayment.Refund_Error_Code__c = respWrapper.body.resultInfo.resultCode;
                            objPayment.Refund_Initiated_Error_Message__c = respWrapper.body.resultInfo.resultMsg;
                            objPayment.RefundId__c = respWrapper.body.refId;
                            if(respWrapper.body.resultInfo.resultStatus == 'PENDING') {
                                objPackage.refundResult = respWrapper.body.resultInfo.resultStatus;
                            } else {
                                objPackage.refundResult = respWrapper.body.resultInfo.resultMsg;
                            }
                        }
                        objPayment.Refund_Payment__c = objRefundPayment.id;
                        objPackage.objPayment = objPayment;
                    } else {
                        objPackage.refundResult = 'Size zero';
                    }
                }                  
            }

            if('ICICI GateWay'.equalsIgnoreCase(objPayment.nm_PaymentGatewayName__c)) {
                Map<String,Object> mapOfResponseParameters = new Map<String,Object>();        
                String merchantRefNo = objPayment.nm_Merchant_Track_Id__c;
                MerchantRefundNo = 'REF' + merchantRefNo + String.valueOf((Integer)Math.floor(Math.random() * 100));
            
                Map<String, Object> ICICIParams = new Map<String, Object>();
                ICICIParams.put('refund_id', MerchantRefundNo);
                ICICIParams.put('refund_amount', refundAmount);

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
                                objPayment.Refunded_Amount__c = refundAmount;
                                // update Refund Payment Record as Refund Paid 
                                objPackage.refundResult = 'Record Refunded Successfully'; 
                            } else {
                                objPayment.Refund_Process_Status__c = String.valueOf(mapOfResponseParameters.get('refund_status'));
                                objPayment.Refund_Error_Code__c = objPayment.Refund_Process_Status__c;
                                objPayment.RefundId__c = (String)mapOfResponseParameters.get('refund_id');
                                objPayment.Refund_Initiated_Error_Message__c = (String)mapOfResponseParameters.get('status_description');
                                if(String.valueOf(mapOfResponseParameters.get('refund_status')) == 'PENDING') {
                                    objPackage.refundResult = String.valueOf(mapOfResponseParameters.get('refund_status'));
                                } else {
                                    objPackage.refundResult = objPayment.Refund_Initiated_Error_Message__c;
                                }
                            }
                            objPayment.Refund_Payment__c = objRefundPayment.id;
                            objPackage.objPayment = objPayment;
                        } else {
                            objPackage.refundResult = 'Size zero';
                        } 
                    } 
                }
            }

            objPackage.MerchantRefundNo = MerchantRefundNo;
        } catch (Exception e) {
            System.debug('Error 2 ==>'+e.getMessage());
            System.debug('Error 2 ==>'+e.getLineNumber());
        }
        return objPackage;
    }

    public nmRefund_Payment__c updateRefundPaymentRecord(nmRefund_Payment__c objRP, String merchantid, Decimal refundedAmount, String status) {
        if(status=='Record Refunded Successfully') {
            objRP.nm_Transaction_Date__c = System.today();
            if(objRP.Merchant_ID__c != null && objRP.Merchant_ID__c != '') {
                objRP.Merchant_ID__c = objRP.Merchant_ID__c + ',' + merchantid;
            }else{
                objRP.Merchant_ID__c = merchantid;
            }
            System.debug('refundedAmount -->'+refundedAmount);
            if(objRP.Refunded_Amount__c != null) {
                objRP.Refunded_Amount__c = objRP.Refunded_Amount__c + refundedAmount;
            } else {
                objRP.Refunded_Amount__c = refundedAmount;
            }
            Decimal pendingAmount = objRP.Total_amount_to_refund__c - objRP.Refunded_Amount__c;
            if(pendingAmount <= 0) {
                objRP.nm_Payment_Status__c = 'Payment Refunded';
                objRP.Status__c = 'Payment Refunded';
                objRP.Payment_Refunded_D_T__c= System.Now();
            }
        }
        objRP.Refund_Initiated__c = true;
        return objRP;
    }

    public void upatePaymentRecords(List<nm_Payment__c> lstPaymentToUpdate) {
        Database.SaveResult[] srList = Database.update(lstPaymentToUpdate, false);
        for (Integer i = 0; i < lstPaymentToUpdate.size(); i++) {
            Database.SaveResult sr = srList[i];
            nm_Payment__c origRecord = lstPaymentToUpdate[i];
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Payment ID: ' + sr.getId());
                successCount++;
            } else {
                System.debug('sr.getId() -->'+origRecord.id);
                lstFailedRecords.add(origRecord.id);
                failedCount++;
                // Operation failed, so get all errors.                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Payment fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    public void sendErrorMail() {
        String recordList = '';
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0){
            for(String s: lstFailedRecords) {
                recordList += (recordList==''?'':',\n')+s;
            }
        }
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        String[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('Mass Refund Process Failed Records List');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below SendCourseListBatch Class Error:\n'+
        'Here are the lists of failed records List:\n'+
          recordList +'\n\n'+
        'Total Records Processed: ' +totalCount +'\n'+
        'Sucess Records: '+ successCount +'\n'+
        'Error Records: '+ failedCount +'\n\n'+
       
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public class RPPackage {
        public String refundResult {get;set;}
        public String MerchantRefundNo {get;set;}
        public nm_Payment__c objPayment {get;set;}
        public nmRefund_Payment__c objRP {get;set;}

        public RPPackage() {
            this.refundResult = '';
            this.MerchantRefundNo = '';
            this.objPayment = null;
            this.objRP = null;
        }
    }
}