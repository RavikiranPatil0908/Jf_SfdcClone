/**
 * @File Name          : RefundStatusBatchForPaytm.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 06-04-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/2/2020   @BK     Initial Version
**/
global class RefundStatusBatchForPaytm implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    
    // public Set<String> lstFailedRecords;
    public Map<String,Set<String>> mapOfRecordTypeVsRecords = new Map<String,Set<String>>();

    global void execute(SchedulableContext sc) {
        RefundStatusBatchForPaytm b = new RefundStatusBatchForPaytm();
        Database.executebatch(b, 200);
    }

    /**
    * @description 
    * @author @BK | 3/2/2020 
    * @param BC 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String pendingStatus = 'PENDING';
        String query = 'SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,CareerServiceProgram__c,Refund_Process_Status__c,Refund_Error_Code__c,Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c,Refund_Payment__c FROM nm_Payment__c WHERE Refund_Process_Status__c=:pendingStatus AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null AND nm_PaymentGatewayName__c=\'Paytm GateWay\' LIMIT 100';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 3/2/2020 
    * @param BC 
    * @param scope 
    * @return void 
    **/
    global void execute(Database.BatchableContext BC, List<nm_Payment__c> scope) { 
        List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,isActive__c,Paytm_EncryptionKey__c,Paytm_IndustryId__c,Paytm_MID__c,Paytm_Website_Key__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];
        Map<String, nmRefund_Payment__c> mapOfRecIdVsRefundPayment = new Map<String, nmRefund_Payment__c>();
        Set<Id> setOfRFId = new Set<Id>();
        Map<String, SObject> mapOfTypeVsObject = new  Map<String, SObject>();
        List<nm_Payment__c> lstPaymentToUpdate = new List<nm_Payment__c>();

        for(nm_Payment__c objPayment : scope) {
            setOfRFId.add(objPayment.Refund_Payment__c);
        }

        if(setOfRFId.size() > 0) {
            Map<ID, nmRefund_Payment__c> mapOfRefundPayment = new Map<ID, nmRefund_Payment__c>([SELECT id,nm_Transaction_Date__c,Merchant_ID__c,Refunded_Amount__c,Opportunity__c,CareerServiceProgram__c FROM nmRefund_Payment__c WHERE id IN :setOfRFId AND nm_Payment_Status__c!='Payment Refunded']);
            Map<Id,nmRefund_Payment__c> mapOfRefundPaymentToUpdate = new Map<Id,nmRefund_Payment__c>();
            for(nm_Payment__c objPayment : scope) {
                PaymentConfigurationParameters__c objPCP;
                if(objPayment.IC_Name__c == 'upGrad' && lstPaymentConfigdetails.size() > 0) {
                    objPCP = lstPaymentConfigdetails[0];
                }
                String postData = createPaytmRequest(objPayment.RefundId__c,objPayment.nm_Merchant_Track_Id__c,objPCP);
                nmRefund_Payment__c objRefundPayment;
                nmRefund_Payment__c priorRefundPayment;
                Id mapKey = objPayment.Refund_Payment__c;
                if(mapOfRefundPayment.containsKey(mapKey)) {
                    objRefundPayment = mapOfRefundPayment.get(mapKey);
                    if(mapOfRefundPaymentToUpdate.containsKey(objRefundPayment.Id)) {
                        priorRefundPayment = mapOfRefundPaymentToUpdate.get(objRefundPayment.Id);
                    }
                }
                
                mapOfTypeVsObject = callQueryAPI(postData, objPCP, objPayment, objRefundPayment,priorRefundPayment);
                
                if(!mapOfTypeVsObject.isEmpty()) {
                    nm_Payment__c objPaymentRecord = mapOfTypeVsObject.containsKey('nm_Payment__c') ? (nm_Payment__c)mapOfTypeVsObject.get('nm_Payment__c') : null;
                    nmRefund_Payment__c objRefund = mapOfTypeVsObject.containsKey('nmRefund_Payment__c') ? (nmRefund_Payment__c)mapOfTypeVsObject.get('nmRefund_Payment__c') : null;
                    if(objPaymentRecord!=null) {
                        lstPaymentToUpdate.add(objPaymentRecord);
                    }
                    if(objRefund!=null) {
                        mapOfRefundPaymentToUpdate.put(objRefund.Id,objRefund);
                    }
                }
            }

            if(!mapOfRefundPaymentToUpdate.isEmpty()) {
                updateRecords(mapOfRefundPaymentToUpdate.values(), null, 'nmRefund_Payment__c');
            }

            if(lstPaymentToUpdate.size() > 0) {
                updateRecords(null, lstPaymentToUpdate, 'nm_Payment__c');
            }
        }
    }

    /**
    * @description 
    * @author @BK | 11/2/2020 
    * @param BC 
    * @return void 
    **/
    global void finish(Database.BatchableContext BC) {
        System.debug('Finished');
        if(!mapOfRecordTypeVsRecords.isEmpty()) {
            OrgWideEmailAddress owe = [SELECT id from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = System.Label.setBccAdderess.split(',');
            mail.setToAddresses(toAddresses);
            mail.setSubject('Batch Subject RefundStatusBatchForPaytm');
            String msg = 'Failed records List.';
            String htmlMsg = '<p>' + msg + 'Failed Records </p><br/>';
            if(mapOfRecordTypeVsRecords.containsKey('nmRefund_Payment__c')) {
                htmlMsg += '<table><tr><th>Refund Record</th></tr>';
                for(String recordId : mapOfRecordTypeVsRecords.get('nmRefund_Payment__c')) {
                    htmlMsg += '<tr><td>' + recordId + '</td></tr>';
                }
                htmlMsg += '</table>';
            }

            if(mapOfRecordTypeVsRecords.containsKey('nm_Payment__c')) {
                htmlMsg += '<table><tr><th>Payment Record</th></tr>';
                for(String recordId : mapOfRecordTypeVsRecords.get('nm_Payment__c')) {
                    htmlMsg += '<tr><td>' + recordId + '</td></tr>';
                }
                htmlMsg += '</table>';
            }
            mail.setHtmlBody(htmlMsg);
            mail.setOrgWideEmailAddressId(owe.id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    /**
    * @description 
    * @author @BK | 3/2/2020 
    * @param refId 
    * @param orderId 
    * @param objPCP 
    * @return String 
    **/
    public String createPaytmRequest(String refId, String orderId, PaymentConfigurationParameters__c objPCP) {
        String paytmMerchantKey = System.Label.Paytm_Merchant_Key;
        String paytmEncryptionKey = System.Label.Paytm_Encryption_Key;
        if(objPCP != null) {
            paytmMerchantKey = objPCP.Paytm_MID__c;
            paytmEncryptionKey = objPCP.Paytm_EncryptionKey__c;
        } 

        Map<String, Map<String,String>> paytmParams = new Map<String, Map<String,String>>();
        Map<String,String> body = new Map<String,String>();
        Map<String,String> head = new Map<String,String>();

        body.put('mid', paytmMerchantKey);
        /* Enter your order id for which refund was initiated */
        body.put('orderId', orderId);
        /* Enter refund id which was used for initiating refund */
        body.put('refId', refId);

        String jsonBodyParam = JSON.serialize(body);
        System.debug('jsonBodyParam ==>'+jsonBodyParam);
        String checksum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(paytmEncryptionKey, jsonBodyParam);

        head.put('clientId', 'C11');
        /* put generated checksum value here */
        head.put('signature', checksum);

        /* prepare JSON string for request */
        paytmParams.put('body', body);
        paytmParams.put('head', head);
        
        String postData = JSON.serialize(paytmParams);
        // postData = 'JsonData=' + postData;
        System.debug('postData---->'+postData);
        return postData;
    }


    /**
    * @description 
    * @author @BK | 4/2/2020 
    * @param postData 
    * @param objPCP 
    * @param objPayment 
    * @param objRefundPayment 
    * @param priorRefundPayment 
    * @return Map<String, SObject> 
    **/
    public Map<String, SObject> callQueryAPI(String postData, PaymentConfigurationParameters__c objPCP,nm_Payment__c objPayment,nmRefund_Payment__c objRefundPayment, nmRefund_Payment__c priorRefundPayment) {
        Map<String, SObject> mapOfTypeVsObject = new Map<String, SObject>();
        HttpRequest req = new HttpRequest();
        String PaytmRefundStatusURL = nmCommon.getConfigSettings('Paytm_Refund_status_Url__c');
        System.debug('Sending Query API output to ' + PaytmRefundStatusURL);
        if(Test.isRunningTest()) {
            PaytmRefundStatusURL = 'https://securegw-stage.paytm.in/v2/refund/status';
        }
        req.setEndpoint(PaytmRefundStatusURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(postData);
        System.debug('request body-->'+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode =' + statusCode);
        if(statusCode == 200) {
            String result = res.getBody();
            System.debug('result ==>'+result);
            PaytmRefundStatusResponseWrapper respWrapper = PaytmRefundStatusResponseWrapper.parse(result);
            if(respWrapper!=null && respWrapper.body!=null && respWrapper.body.resultInfo!=null && String.isNotBlank(respWrapper.body.resultInfo.resultCode) && objPayment.Refund_Error_Code__c!=respWrapper.body.resultInfo.resultCode) {
                if(respWrapper.body.resultInfo.resultCode == '10') {
                    Decimal refundAmount = Decimal.valueOf(respWrapper.body.refundAmount);
                    objPayment.Refund_Paid_Date__c = System.today();
                    objPayment.Refund_Process_Status__c = 'Y';
                    objPayment.Refunded_Amount__c = refundAmount;
                    objPayment.Refund_Initiated_Error_Message__c = respWrapper.body.resultInfo.resultMsg;
                    objPayment.Refund_Error_Code__c = respWrapper.body.resultInfo.resultCode;
                    if(objRefundPayment != null) {
                        mapOfTypeVsObject.put('nmRefund_Payment__c' ,updateRefundPaymentRecord(objRefundPayment, objPayment.nm_Merchant_Track_Id__c, refundAmount, priorRefundPayment));
                    }
                } else {
                    objPayment.Refund_Process_Status__c = respWrapper.body.resultInfo.resultStatus;
                    objPayment.Refund_Error_Code__c = respWrapper.body.resultInfo.resultCode;
                    objPayment.Refund_Initiated_Error_Message__c = respWrapper.body.resultInfo.resultMsg;
                }
                mapOfTypeVsObject.put('nm_Payment__c',objPayment);
            }
        }
        System.debug('Result = ' + mapOfTypeVsObject.size());
        return mapOfTypeVsObject;
    }

 
    /**
    * @description 
    * @author @BK | 4/2/2020 
    * @param objRefund 
    * @param merchantid 
    * @param refundedAmount 
    * @param priorRefundPayment 
    * @return nmRefund_Payment__c 
    **/
    public static nmRefund_Payment__c updateRefundPaymentRecord(nmRefund_Payment__c objRefund, String merchantid, Decimal refundedAmount, nmRefund_Payment__c priorRefundPayment) {
        
        objRefund.nm_Transaction_Date__c = System.today();
        objRefund.nm_Payment_Status__c = 'Payment Refunded';
        objRefund.Status__c= 'Payment Refunded';
        objRefund.Payment_Refunded_D_T__c= System.Now();

        if(priorRefundPayment!=null) {
            objRefund.Merchant_ID__c = priorRefundPayment.Merchant_ID__c + ',' + merchantid;
            objRefund.Refunded_Amount__c = priorRefundPayment.Refunded_Amount__c + refundedAmount;
        } else {
            if(objRefund.Merchant_ID__c != null && objRefund.Merchant_ID__c != '') {
                objRefund.Merchant_ID__c = objRefund.Merchant_ID__c + ',' + merchantid;
            }else{
                objRefund.Merchant_ID__c = merchantid;
            }
            if(objRefund.Refunded_Amount__c != null) {
                objRefund.Refunded_Amount__c = objRefund.Refunded_Amount__c + refundedAmount;
            } else {
                objRefund.Refunded_Amount__c = refundedAmount;
            }
        }
        System.debug('objRefund.Merchant_ID__c ==>'+objRefund.Merchant_ID__c);
        System.debug('objRefund.Refunded_Amount__c -->'+objRefund.Refunded_Amount__c);
        System.debug('refundedAmount -->'+refundedAmount);
        return objRefund;
    }


    /**
    * @description 
    * @author @BK | 11/2/2020 
    * @param lstOfRefundRecords 
    * @param lstPaymentRecords 
    * @param recordType 
    * @return void 
    **/
    public void updateRecords(List<nmRefund_Payment__c> lstOfRefundRecords, List<nm_Payment__c> lstPaymentRecords, String recordType) {
        Set<String> lstFailedRecords = new Set<String>();
        Database.SaveResult[] srList;
        if(recordType == 'nmRefund_Payment__c' && lstOfRefundRecords!=null) {
            srList = Database.update(lstOfRefundRecords, false);
        } else if(lstPaymentRecords!=null)  {
            srList = Database.update(lstPaymentRecords, false);
        }
        Integer i = 0;
        for (Database.SaveResult sr : srList) {
            String recordId;
            if(recordType == 'nmRefund_Payment__c') {
                recordId = lstOfRefundRecords[i].id;
            } else {
                recordId = lstPaymentRecords[i].id;
            }

            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated : ' + sr.getId());
            }
            else {
                lstFailedRecords.add(recordId);
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
            i++;
        }

        if(lstFailedRecords.size() > 0) {
            if(mapOfRecordTypeVsRecords.containsKey(recordType) && mapOfRecordTypeVsRecords.get(recordType).size() > 0) {
                lstFailedRecords.addAll(mapOfRecordTypeVsRecords.get(recordType));
            }
            mapOfRecordTypeVsRecords.put(recordType, lstFailedRecords);
        }
    }
}