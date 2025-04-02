/**
 * @File Name          : PaymentCheckBatchHDFCTransactionFailed.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 23/9/2019, 5:25:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/9/2019   @BK     Initial Version
**/
global class PaymentCheckBatchHDFCTransactionFailed implements Database.Batchable < sObject > , Database.AllowsCallouts, Schedulable {
    List < String > successList = new List < String > ();
    List < String > errorList = new List < String > ();
    Map < String, String > uniqueMerchantRefNoMap = new Map < String, String > ();
    List<nm_Payment_Initiated__c> lstPaymentInitationToUpdate =new List<nm_Payment_Initiated__c>();
    
    global void execute(SchedulableContext sc) {
        PaymentCheckBatchHDFCTransactionFailed obj = new PaymentCheckBatchHDFCTransactionFailed ();
        Database.executebatch(obj, 50);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Started PaymentCheckBatchHDFCForTransactionFailed Batch');
        Datetime time30MinutesBack = System.now()
            .addMinutes(-2880);
        system.debug('time30MinutesBack '+time30MinutesBack );
        DateTime gmtTime30MinutesBack = time30MinutesBack.addMinutes(-330); //5 and half hour
         system.debug('gmtTime30MinutesBack '+gmtTime30MinutesBack );
        String formattedGMTTime = gmtTime30MinutesBack.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
          system.debug('formattedGMTTime '+formattedGMTTime );
        //Query will comapare using GMT time. Fetch Intiated Payment records created 30 minutes back and still in status of Payment Initiated 
        String query = 'Select nm_Merchant_Track_Id__c,IC_Name__c from nm_Payment_Initiated__c where nm_PaymentGatewayName__c=\'HDFC GateWay\' and nm_PaymentStatus__c = \'Transaction Failed\' and createdDate = LAST_N_DAYS:15 order by nm_Merchant_Track_Id__c';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List < nm_Payment_Initiated__c > scope) {
        Map < String, String > failedMerchantRefNoGatewayResponseMap = new Map < String, String > ();
        Map < String, String > bankResponseAwaitingTransactionMap = new Map < String, String > ();
        List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,isActive__c,HDFC_SecretKey__c,HDFC_SALT__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];

        System.debug('scope = ' + scope);
        for(Sobject s: scope) {
            nm_Payment_Initiated__c initiatedPayment = (nm_Payment_Initiated__c) s;
            uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment.IC_Name__c);
        }

        //Iterate every unique merchant referenc number that is not reflected in Original payment records
        Set < String > merchantRefNos = new Set < String > ();
        merchantRefNos = uniqueMerchantRefNoMap.keySet();
        for(String merchantRefNo: merchantRefNos) {
            PaymentConfigurationParameters__c objPCP = null;
            // To check if center is upGrad
            if(uniqueMerchantRefNoMap.get(merchantRefNo) == 'upGrad' && lstPaymentConfigdetails.size() > 0) {
                objPCP = lstPaymentConfigdetails[0];
            }

            String hashValue = createHDFCDeskRequest(merchantRefNo,objPCP);
            callQueryAPI(hashValue, merchantRefNo, failedMerchantRefNoGatewayResponseMap, bankResponseAwaitingTransactionMap,objPCP);
        }
        // mark Payment made For Already Payment Approved Payment Initation Status Payment Record
        if(lstPaymentInitationToUpdate.size()>0)
        {
            System.debug('lstPaymentInitationToUpdate Size --->'+lstPaymentInitationToUpdate.size());
            update lstPaymentInitationToUpdate;
        }
        //Mark unsuccessful transactions as failed
        if(failedMerchantRefNoGatewayResponseMap.size() > 0) {
            updateStatus(failedMerchantRefNoGatewayResponseMap, 'Transaction Failed');
        }
        if(bankResponseAwaitingTransactionMap.size() > 0) {
            updateStatus(bankResponseAwaitingTransactionMap, 'Payment Initiated');
        }
    }
    public void updateStatus(Map < String, String > merchantRefNoGatewayResponseMap, String newStatus) {
        List < nm_Payment_Initiated__c > paymentList = new List < nm_Payment_Initiated__c > ();
        Set < String > merchantSetNoSet = merchantRefNoGatewayResponseMap.keySet();
        List < nm_Payment_Initiated__c > failedPayments = [Select Id,nm_Error_Code__c, nm_Merchant_Track_Id__c, nm_PaymentStatus__c, Gateway_Detailed_Response__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c in: merchantSetNoSet];
        for(nm_Payment_Initiated__c p: failedPayments) {
            p.nm_PaymentStatus__c = newStatus;
            p.Gateway_Detailed_Response__c = merchantRefNoGatewayResponseMap.get(p.nm_Merchant_Track_Id__c);
             p.nm_Error_Code__c= merchantRefNoGatewayResponseMap.get(p.nm_Merchant_Track_Id__c+'1');
            paymentList.add(p);
        }
        update paymentList;
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
        system.debug('hmacData '+hmacData );
        String checkSum = EncodingUtil.convertToHex(hmacData);
        system.debug('checkSum '+checkSum );
        return checkSum;
    }

    public void callQueryAPI(String hashValue, String merchantRefNo, Map < String, String > failedMerchantRefNoGatewayResponseMap, Map < String, String > bankResponseAwaitingTransactionMap,PaymentConfigurationParameters__c objPCP) {
        String secureSecretKey = Label.SECURE_SECRET;
        if(objPCP != null) {
            secureSecretKey = objPCP.HDFC_SecretKey__c;
        }
        
        HttpRequest req = new HttpRequest();
        System.debug('merchantRefNo Query API-->' + merchantRefNo);
        req.setEndpoint(Label.HDFC_PaymentBatch_Url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('form=2&hash='+ hashValue+'&key=' + secureSecretKey + '&var1=' + merchantRefNo + '&command=verify_payment');
        System.debug('request body-->'+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode = ' + statusCode);
        if(statusCode == 200) {
            String result = res.getBody();
            System.debug('result body==>'+result);
            JSONParser parser = JSON.createParser(res.getBody());
            
            boolean IsSuccess =false;
            String Key ='';
            Map<String,String> mapOfParameters =new Map<String,String>(); // map to Store Parameters to Post on HDFC PayResponse 
           
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
              
            if(mapOfParameters.get('status') =='success')
            {
               // checking If Payment Record with Merchant Refernce Number Is Approver Or Not .If Approved then Do Not Create Payment Record Only Update Payment Initation Record
               boolean originalPaymentApproved =false;
               originalPaymentApproved =checkOriginalPaymentStatusAndUpdatePaymentInitation(merchantRefNo);
                System.debug('originalPaymentApproved  = ' + originalPaymentApproved);
               if(!originalPaymentApproved)
               {
                   //If payment was successful, then only Pass the response from Query API to original Payment handler class: nmHDFCPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
                   Boolean originalPaymntUpdationStatus = false;
                   originalPaymntUpdationStatus  = updateOriginalPayment(mapOfParameters,hashValue);
                   System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
                    if(originalPaymntUpdationStatus == true) {
                        successList.add(merchantRefNo);
                    } else {
                        errorList.add(merchantRefNo);
                    }
               }     
            }else if(mapOfParameters.get('status') =='pending'){
                 //This means BillDesk is waiting for Response from Bank, Dont mark it failed yet. Try in next run of Batch class again
                bankResponseAwaitingTransactionMap.put(merchantRefNo, mapOfParameters.get('Error'));
                bankResponseAwaitingTransactionMap.put(merchantRefNo+'1', mapOfParameters.get('error_code'));
            }else{
                //Put in failed list to update later, so that these are not queried again
                System.debug('Error Message --->'+mapOfParameters.get('Error')+'----error Code---'+mapOfParameters.get('error_code'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, mapOfParameters.get('Error'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo+'1', mapOfParameters.get('error_code'));
                System.debug('Not creating payment records since payment is not successful. Result = ' + mapOfParameters.get('Error'));
            } 
        } else{
            // put Error merchantRefNo into error list
            errorList.add(merchantRefNo);
        }
        System.debug('Result = ' + res.getBody());
    }
    
    public boolean updateOriginalPayment(Map<String,String> mapOfParameters,String hashValue)
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
    
    public boolean checkOriginalPaymentStatusAndUpdatePaymentInitation(String merchantRefNo)
    {
       // check payment with merchant reference no is Already Approved or made
        List<nm_Payment__c> lstPaymentAlreadyApproved =[select id,nm_PaymentStatus__c from nm_Payment__c where nm_Merchant_Track_Id__c=:merchantRefNo and (nm_PaymentStatus__c ='Payment Approved' or nm_PaymentStatus__c='Payment Made' )];
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