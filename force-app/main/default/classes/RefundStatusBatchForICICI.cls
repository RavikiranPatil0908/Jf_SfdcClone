/**
 * @File Name          : RefundStatusBatchForICICI.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 06-04-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/2/2020   @BK     Initial Version
**/
global class RefundStatusBatchForICICI implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    
    // public Set<String> lstFailedRecords;
    public Map<String,Set<String>> mapOfRecordTypeVsRecords = new Map<String,Set<String>>();

    global void execute(SchedulableContext sc) {
        RefundStatusBatchForICICI b = new RefundStatusBatchForICICI();
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
        String query = 'SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,CareerServiceProgram__c,Refund_Process_Status__c,Refund_Error_Code__c,Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c,Refund_Payment__c FROM nm_Payment__c WHERE Refund_Process_Status__c=:pendingStatus AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null AND nm_PaymentGatewayName__c=\'ICICI GateWay\' LIMIT 100';
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
                nmRefund_Payment__c objRefundPayment;
                nmRefund_Payment__c priorRefundPayment;
                Id mapKey = objPayment.Refund_Payment__c;
                if(mapOfRefundPayment.containsKey(mapKey)) {
                    objRefundPayment = mapOfRefundPayment.get(mapKey);
                    if(mapOfRefundPaymentToUpdate.containsKey(objRefundPayment.Id)) {
                        priorRefundPayment = mapOfRefundPaymentToUpdate.get(objRefundPayment.Id);
                    }
                }
                
                mapOfTypeVsObject = callQueryAPI(objPayment, objRefundPayment,priorRefundPayment);
                
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
            mail.setSubject('Batch Subject RefundStatusBatchForICICI');
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
    * @author @BK | 4/2/2020 
    * @param postData 
    * @param objPCP 
    * @param objPayment 
    * @param objRefundPayment 
    * @param priorRefundPayment 
    * @return Map<String, SObject> 
    **/
    public Map<String, SObject> callQueryAPI(nm_Payment__c objPayment,nmRefund_Payment__c objRefundPayment, nmRefund_Payment__c priorRefundPayment) {
        Map<String, SObject> mapOfTypeVsObject = new Map<String, SObject>();
        HttpRequest req = new HttpRequest();
        String ICICIRefundUri = nmCommon.getConfigSettings('ICICI_Base_Url__c') + '/orders/'+ objPayment.nm_Merchant_Track_Id__c +'/refunds';
        System.debug('Sending Query API output to ' + ICICIRefundUri);
        if(Test.isRunningTest()) {
            ICICIRefundUri = 'https://securegw-stage.paytm.in/v2/refund/status';
        }
        req.setEndpoint(ICICIRefundUri);
        req.setMethod('GET');
        req.setHeader('accept', 'application/json');
        req.setHeader('x-api-version','2022-01-01');
        req.setHeader('x-client-id',Label.ICICI_App_Id);
        req.setHeader('x-client-secret',Label.ICICI_Secret_Key);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode =' + statusCode);
        if(statusCode == 200) {
            String result = res.getBody();
            System.debug('result ==>'+result);
            List<Object> listOfResponse = (List<Object>)JSON.deserializeUntyped(result); 
            Map<String,Object> mapOfResponse = (Map<String,Object>)listOfResponse[0]; 
            if(mapOfResponse.containsKey('refund_id') && !mapOfResponse.containsKey('code')) {
                if(mapOfResponse.containsKey('refund_status') && (String)mapOfResponse.get('refund_status')=='SUCCESS') {
                    Decimal refundAmount = (Decimal)mapOfResponse.get('refund_amount');
                    Date refundProcessDate = Date.valueOf((String)mapOfResponse.get('processed_at'));
                    objPayment.Refund_Paid_Date__c = refundProcessDate;
                    objPayment.Refund_Process_Status__c = 'Y';
                    objPayment.Refunded_Amount__c = refundAmount;
                    objPayment.Refund_Initiated_Error_Message__c = 'Refund Successfull';
                    objPayment.Refund_Error_Code__c = '10';
                    if(objRefundPayment != null) {
                        mapOfTypeVsObject.put('nmRefund_Payment__c' ,updateRefundPaymentRecord(objRefundPayment, objPayment.nm_Merchant_Track_Id__c, refundAmount, priorRefundPayment,refundProcessDate));
                    }
                } else {
                    objPayment.Refund_Process_Status__c = (String)mapOfResponse.get('refund_status');
                    objPayment.Refund_Error_Code__c = '619';
                    objPayment.Refund_Initiated_Error_Message__c = (String)mapOfResponse.get('status_description');
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
    public static nmRefund_Payment__c updateRefundPaymentRecord(nmRefund_Payment__c objRefund, String merchantid, Decimal refundedAmount, nmRefund_Payment__c priorRefundPayment, Date processDate) {
        
        objRefund.nm_Transaction_Date__c = processDate;
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