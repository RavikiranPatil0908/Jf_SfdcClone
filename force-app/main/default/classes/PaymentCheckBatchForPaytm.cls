/**
 * @File Name          : PaymentCheckBatchForPaytm.cls
 * @Description        : 
 * @Author             : Bala
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/2/2020, 1:07:21 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    11/4/2019, 3:49:22 PM   Bala     Initial Version
**/
global class PaymentCheckBatchForPaytm implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
	
	String query;
	public List <String> successList = new List <String> ();
    public List <String> errorList = new List <String> ();
    public Map<String,String> uniqueMerchantRefNoMap = new Map<String,String> ();
    public List<nm_Payment_Initiated__c> lstPaymentInitationToUpdate = new List<nm_Payment_Initiated__c>();
	
	global PaymentCheckBatchForPaytm() {}

	/**
	* @description executes in 50 record counts
	* @author Balakrishnan | 28/3/2019
	* @param SchedulableContext sc
	* @return void
	*/
	global void execute(SchedulableContext sc) {
        PaymentCheckBatchForPaytm obj = new PaymentCheckBatchForPaytm();
        Database.executebatch(obj, 50);
    }
	
	/**
	* @description
	* @author Balakrishnan | 28/3/2019
	* @param Database.BatchableContext BC
	* @return Database.QueryLocator
	*/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Started PaymentCheckBatchPaytmForTransactionFailed Batch');
        Datetime time30MinutesBack = System.now().addMinutes(-2880);
        System.debug('time30MinutesBack '+time30MinutesBack );
        DateTime gmtTime30MinutesBack = time30MinutesBack.addMinutes(-330); //5 and half hour
        System.debug('gmtTime30MinutesBack '+gmtTime30MinutesBack );
        String formattedGMTTime = gmtTime30MinutesBack.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        System.debug('formattedGMTTime '+formattedGMTTime );
        //Query will comapare using GMT time. Fetch Intiated Payment records created 30 minutes back and still in status of Payment Initiated 
        query = 'SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c=\'Paytm GateWay\' AND nm_PaymentStatus__c =\'Payment Initiated\' AND createdDate =LAST_N_DAYS:20 ORDER BY nm_Merchant_Track_Id__c';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
	}

   	/**
   	* @description
   	* @author Balakrishnan | 28/3/2019
   	* @param Database.BatchableContext BC
   	* @param List<nm_Payment_Initiated__c> scope
   	* @return void
   	*/
   	global void execute(Database.BatchableContext BC, List<nm_Payment_Initiated__c> scope) {

		Map<String,String> failedMerchantRefNoGatewayResponseMap = new Map<String,String> ();
        Map<String,String> bankResponseAwaitingTransactionMap = new Map<String,String> ();
        List<PaymentConfigurationParameters__c> lstPaymentConfigdetails = [SELECT id,isActive__c,Paytm_EncryptionKey__c,Paytm_IndustryId__c,Paytm_MID__c,Paytm_Website_Key__c FROM PaymentConfigurationParameters__c WHERE isActive__c=true AND Name='upGrad'];

        System.debug('scope = ' + scope);
        for(Sobject s: scope) {
            nm_Payment_Initiated__c initiatedPayment = (nm_Payment_Initiated__c) s;
            uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment.IC_Name__c);
        }

        //Iterate every unique merchant referenc number that is not reflected in Original payment records
        for(String merchantRefNo: uniqueMerchantRefNoMap.keySet()) {
            PaymentConfigurationParameters__c objPCP = null;
            // To check if center is upGrad
            if(uniqueMerchantRefNoMap.get(merchantRefNo) == 'upGrad' && lstPaymentConfigdetails.size() > 0) {
                objPCP = lstPaymentConfigdetails[0];
            }

            String postData = createPaytmRequest(merchantRefNo,objPCP);
            callQueryAPI(postData, merchantRefNo, failedMerchantRefNoGatewayResponseMap, bankResponseAwaitingTransactionMap, objPCP);
        }
        // mark Payment made For Already Payment Approved Payment Initation Status Payment Record
        if(lstPaymentInitationToUpdate.size() > 0) {
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
	
	global void finish(Database.BatchableContext BC) {
		System.debug('Finished');
	}

	/**
	* @description
	* @author Balakrishnan | 28/3/2019
	* @param Map<String, String> merchantRefNoGatewayResponseMap
	* @param String newStatus
	* @return void
	*/
	public void updateStatus(Map<String,String> merchantRefNoGatewayResponseMap, String newStatus) {
        List<nm_Payment_Initiated__c> paymentList = new List<nm_Payment_Initiated__c>();
        Set<String> merchantSetNoSet = merchantRefNoGatewayResponseMap.keySet();
        List<nm_Payment_Initiated__c> failedPayments = [SELECT Id,nm_Error_Code__c, nm_Merchant_Track_Id__c, nm_PaymentStatus__c, Gateway_Detailed_Response__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c in: merchantSetNoSet];
        for(nm_Payment_Initiated__c p: failedPayments) {
            p.nm_PaymentStatus__c = newStatus;
            p.Gateway_Detailed_Response__c = merchantRefNoGatewayResponseMap.get(p.nm_Merchant_Track_Id__c);
            p.nm_Error_Code__c = merchantRefNoGatewayResponseMap.get(p.nm_Merchant_Track_Id__c+'1');
            paymentList.add(p);
        }
        update paymentList;
    }


	/**
	* @description 
	* @author @BK | 23/9/2019 
	* @param orderId 
	* @param objPCP 
	* @return String 
	**/
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


    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @param postData 
    * @param merchantRefNo 
    * @param failedMerchantRefNoGatewayResponseMap 
    * @param bankResponseAwaitingTransactionMap 
    * @param objPCP 
    * @return void 
    **/
    public void callQueryAPI(String postData, String merchantRefNo, Map<String,String> failedMerchantRefNoGatewayResponseMap, Map<String,String> bankResponseAwaitingTransactionMap, PaymentConfigurationParameters__c objPCP) {
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
               // checking If Payment Record with Merchant Refernce Number Is Approver Or Not .If Approved then Do Not Create Payment Record Only Update Payment Initation Record
				Boolean originalPaymentApproved = false;
				originalPaymentApproved = checkOriginalPaymentStatusAndUpdatePaymentInitation(merchantRefNo);
            	System.debug('originalPaymentApproved = ' + originalPaymentApproved);
				if(!originalPaymentApproved) {
					//If payment was successful, then only Pass the response from Query API to original Payment handler class: nmPaytmPayResponse.cls, so that it will create Payment records and update status of Initiated Payment records
					Boolean originalPaymntUpdationStatus = updateOriginalPayment(mapOfParameters,objPCP);
					System.debug('originalPaymntUpdationStatus = ' + originalPaymntUpdationStatus);
					if(originalPaymntUpdationStatus) {
						successList.add(merchantRefNo);
					} else {
						errorList.add(merchantRefNo);
					}
				}     
            }else if(mapOfParameters.get('STATUS') == 'PENDING'){
                 //This means BillDesk is waiting for Response from Bank, Dont mark it failed yet. Try in next run of Batch class again
                bankResponseAwaitingTransactionMap.put(merchantRefNo, mapOfParameters.get('RESPMSG'));
                bankResponseAwaitingTransactionMap.put(merchantRefNo+'1', mapOfParameters.get('RESPCODE'));
            }else{
                //Put in failed list to update later, so that these are not queried again
                System.debug('Error Message --->'+mapOfParameters.get('RESPMSG')+'----error Code---'+mapOfParameters.get('RESPCODE'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo, mapOfParameters.get('RESPMSG'));
                failedMerchantRefNoGatewayResponseMap.put(merchantRefNo+'1', mapOfParameters.get('RESPCODE'));
                System.debug('Not creating payment records since payment is not successful. Result = ' + mapOfParameters.get('RESPMSG'));
            } 
        }else {
            // put Error merchantRefNo into error list
            errorList.add(merchantRefNo);
        }
        System.debug('Result = ' + res.getBody());
    }
    

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @param mapOfParameters 
    * @param objPCP 
    * @return Boolean 
    **/
    public Boolean updateOriginalPayment(Map<String,String> mapOfParameters,PaymentConfigurationParameters__c objPCP) {
        HttpRequest req = new HttpRequest();
        String PaytmResponseURL = nmCommon.getConfigSettings('nm_PaymentResponseUrl_Paytm__c');
        System.debug('Sending Query API output to ' + PaytmResponseURL);
        if(Test.isRunningTest()) {
            PaytmResponseURL = System.Label.Site_Url + 'nmPaytmPayResponse';
        }
        req.setEndpoint(PaytmResponseURL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String paytmEncryptionKey = System.Label.Paytm_Encryption_Key;
        if(objPCP!=null) {
            paytmEncryptionKey = objPCP.Paytm_EncryptionKey__c;
        }

        String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(paytmEncryptionKey, mapOfParameters);
        String encoded = EncodingUtil.urlEncode(checkSum, 'UTF-8');
        mapOfParameters.put('CHECKSUMHASH',encoded);

        // setting parameter for posting to Paytm pay response for Creating Record in System
        String requestBody = '';
        for(String Keys :mapOfParameters.keyset()) {
            System.debug('Key---->'+Keys +'---Values--->'+mapOfParameters.get(Keys));
            requestBody = requestBody+'&'+Keys+'='+mapOfParameters.get(Keys);
        }
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
    
    /**
    * @description check payment with merchant reference no is Already Approved or made
    * @author Balakrishnan | 28/3/2019
    * @param String merchantRefNo
    * @return Boolean
    */
    public Boolean checkOriginalPaymentStatusAndUpdatePaymentInitation(String merchantRefNo) {
        List<nm_Payment__c> lstPaymentAlreadyApproved =[SELECT id,nm_PaymentStatus__c FROM nm_Payment__c WHERE nm_Merchant_Track_Id__c=:merchantRefNo AND (nm_PaymentStatus__c ='Payment Approved' OR nm_PaymentStatus__c='Payment Made' )];
        if(lstPaymentAlreadyApproved.size() > 0) {
			list<nm_Payment_Initiated__c> lstPayment = [SELECT Id, nm_PaymentStatus__c, nm_Lead__c,nm_PaymentGatewayName__c , nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c =: merchantRefNo ];
			if(lstPayment.size()>0) {
			System.debug('before Update Original Payment Initation Record Id--->'+lstPayment[0].id);
				for(nm_Payment_Initiated__c obj :lstPayment) {
					obj.nm_PaymentStatus__c = 'Payment Made';
					lstPaymentInitationToUpdate.add(obj);
					System.debug('After Update Original Payment Initation Record Id--->'+obj.id);
				}
			}
           	return true;  
        }else {
            return false;
        }
    }
	
}