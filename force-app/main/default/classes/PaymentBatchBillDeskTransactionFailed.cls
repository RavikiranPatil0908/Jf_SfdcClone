global class PaymentBatchBillDeskTransactionFailed implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    List<String> successList = new List<String>();
    List<String> errorList = new List<String>();
    Map<String, nm_Payment_Initiated__c> uniqueMerchantRefNoMap = new Map<String, nm_Payment_Initiated__c>();
    List<nm_Payment_Initiated__c> lstPaymentInitationToUpdate =new List<nm_Payment_Initiated__c>();
     
   global void execute(SchedulableContext sc) {
      PaymentBatchBillDeskTransactionFailed b = new PaymentBatchBillDeskTransactionFailed();
      Database.executebatch(b, 50);
   }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Started PaymentBatchBillDeskTransactionFailed Batch');
        Datetime time30MinutesBack = System.now().addMinutes(-2880);
        DateTime gmtTime30MinutesBack = time30MinutesBack.addMinutes(-330);//5 and half hour
        String formattedGMTTime = gmtTime30MinutesBack.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        //Query will comapare using GMT time. Fetch Intiated Payment records created 30 minutes back and still in status of Payment Initiated 
        String query = 'Select  nm_Merchant_Track_Id__c,createdDate from nm_Payment_Initiated__c where nm_PaymentGatewayName__c=\'BillDesk GateWay\' and nm_PaymentStatus__c = \'Transaction Failed\' and  createdDate = LAST_N_DAYS:15  order by nm_Merchant_Track_Id__c  ';
        System.debug('Query = '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nm_Payment_Initiated__c> scope){
        Map<String, String> failedMerchantRefNoGatewayResponseMap = new Map<String, String>();
        Map<String, String> bankResponseAwaitingTransactionMap = new Map<String, String>();
        System.debug('scope = '+scope);
        for(Sobject s : scope){
            nm_Payment_Initiated__c initiatedPayment = (nm_Payment_Initiated__c)s;
            uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment);
        }
        
        //Iterate every unique merchant referenc number that is not reflected in Original payment records
        Set<String> merchantRefNos = new Set<String>();
        merchantRefNos = uniqueMerchantRefNoMap.keySet();
        for(String merchantRefNo : merchantRefNos ){
            String msg = formBillDeskRquestParameter(merchantRefNo);
            callQueryAPI(msg, merchantRefNo, failedMerchantRefNoGatewayResponseMap, bankResponseAwaitingTransactionMap);
        }
        
        // mark Payment made For Already Payment Approved Payment Initation Status Payment Record
        if(lstPaymentInitationToUpdate.size()>0)
        {
            System.debug('lstPaymentInitationToUpdate Size --->'+lstPaymentInitationToUpdate.size());
            update lstPaymentInitationToUpdate;
        }
        
        //Mark unsuccessful transactions as failed
        if(failedMerchantRefNoGatewayResponseMap.size() > 0){
            updateStatus(failedMerchantRefNoGatewayResponseMap, 'Transaction Failed');
        }
        if(bankResponseAwaitingTransactionMap.size() > 0){
            updateStatus(bankResponseAwaitingTransactionMap, 'Payment Initiated');
        }
    }
    
    public void updateStatus(Map<String, String> merchantRefNoGatewayResponseMap, String newStatus){
        List<nm_Payment_Initiated__c> paymentList = new List<nm_Payment_Initiated__c>();
        Set<String> merchantSetNoSet = merchantRefNoGatewayResponseMap.keySet();
        List<nm_Payment_Initiated__c> failedPayments = [Select Id, nm_Merchant_Track_Id__c, nm_PaymentStatus__c, Gateway_Detailed_Response__c  from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c  in :merchantSetNoSet];
        for(nm_Payment_Initiated__c p : failedPayments ){
            p.nm_PaymentStatus__c  = newStatus;
            p.Gateway_Detailed_Response__c  = merchantRefNoGatewayResponseMap.get(p.nm_Merchant_Track_Id__c);
            paymentList.add(p);
        }
        update paymentList;
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('Finished');
    }
    
    public String formBillDeskRquestParameter(String merchantRefNo){
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
    
    public void callQueryAPI(String msg, String merchantRefNo, Map<String, String> failedMerchantRefNoGatewayResponseMap, Map<String, String> bankResponseAwaitingTransactionMap){
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
                // checking If Payment Record with Merchant Refernce Number Is Approver Or Not .If Approved or Made then Do Not Create Payment Record Only Update Payment Initation Record
               boolean originalPaymentApproved =false;
               originalPaymentApproved =checkOriginalPaymentStatusAndUpdatePaymentInitation(merchantRefNo);
               if(!originalPaymentApproved)
               {
                //If payment was successful, then only Pass the response from Query API to original Payment handler class: PayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                    Boolean originalPaymntUpdationStatus = false;
                    try{
                        originalPaymntUpdationStatus = updateOriginalPayment(trimmedResult);
                    }catch(Exception e){
                        errorList.add(merchantRefNo);
                    }
                    System.debug('originalPaymntUpdationStatus = '+originalPaymntUpdationStatus);
                    if(originalPaymntUpdationStatus == true){
                        successList.add(merchantRefNo);
                    }else{
                        errorList.add(merchantRefNo);
                    }
               }
            }else if(strResResult == '0002'){
                //This means BillDesk is waiting for Response from Bank, Dont mark it failed yet. Try in next run of Batch class again 
                Integer daysSinceInPaymentInitiation  = Date.valueOf(uniqueMerchantRefNoMap.get(merchantRefNo).CreatedDate).daysBetween(Date.Today());
                System.debug('daysSinceInPaymentInitiation ---->'+daysSinceInPaymentInitiation+'----------------merchantRefNo------'+merchantRefNo);
                // Payment Initation Record pending greater than 15 days then mark as fail 
                if(daysSinceInPaymentInitiation <15)
                {
                    bankResponseAwaitingTransactionMap.put(merchantRefNo, result);
                }else 
                {
                    failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, result);
                }
            }else{
                //Put in failed list to update later, so that these are not queried again
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, result);
                System.debug('Not creating payment records since payment is not successful. Result = ' +strResResult );
            }
            
        }else{
            errorList.add(merchantRefNo);
        }
        
        System.debug('Result = ' + res.getBody());  
    }
    
    public boolean updateOriginalPayment(String msg){
        HttpRequest req = new HttpRequest();
        System.debug('Sending Query API output to '+nmCommon.getConfigSettings('Payment_Response_New_URL__c'));
        req.setEndpoint(nmCommon.getConfigSettings('Payment_Response_New_URL__c'));
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('msg='+msg);
          
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
    
    public boolean checkOriginalPaymentStatusAndUpdatePaymentInitation(String merchantRefNo)
    {
       // check payment with merchant reference no is Already Approved or made
        List<nm_Payment__c> lstPaymentAlreadyApproved =[select id,nm_PaymentStatus__c from nm_Payment__c where nm_Merchant_Track_Id__c=:merchantRefNo and ( nm_PaymentStatus__c ='Payment Approved' or nm_PaymentStatus__c ='Payment Made')];
        if(lstPaymentAlreadyApproved.size()>0)
        {
             list<nm_Payment_Initiated__c> lstPayment = [Select Id, nm_PaymentStatus__c, nm_Lead__c,nm_PaymentGatewayName__c , nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c =: merchantRefNo ];
             if(lstPayment.size()>0)
             {
                System.debug('before Update Original Payment Initation Record Id--->'+lstPayment[0].id);
                 for(nm_Payment_Initiated__c obj :lstPayment)
                 {
                     obj.nm_PaymentStatus__c ='Payment Made';
                     lstPaymentInitationToUpdate.add(obj);
                     System.debug('After Update Original Payment Initation Record Id--->'+obj.id);
                 }
             }
             
           return true;  
        }else
        {
            return false;
        }
        return false; 
    }
}