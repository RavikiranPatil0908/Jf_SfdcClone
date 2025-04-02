/**
 * @File Name          : nmOnlinePayment.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20-09-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    22/3/2019, 11:51:01 AM   Balakrishnan     Initial Version
**/
public class nmOnlinePayment 
{
    //Properties to get values from page, will be different for different transactions. 
    public String TranTrackid{get;set;}
    public String TranAmount{get;set;}
    public String strPaymentType{get;set;}
    public String strEmailId{get;set;}
    public String strMobileNumber{get;set;}
    public String strAddress{get;set;}
    public String recordId{get;set;}
    public String opportunityId{get;set;}
    public String strCity {get;set;}
    public String studentNo {get;set;}
    public String strCountry {get;set;}
    public String strPincode {get;set;}
    public String strName {get;set;}
    public String InstallmentPayOpt {get;set;}  
    public String TypeOfReuest {get;set;} // distinguish between New Pages for Payment and Old pages
    //Properties to store value from custom settings, Payment gateway required fiels.
    public String strPortalId{get;set;}
    public String strPassword{get;set;}
    public String InstallmentAmount {get;set;}
    public String ReqTranportalId{get;set;}
    public String ReqTranportalPassword{get;set;}
    public String ReqAmount{get;set;}
    public String ReqTrackId{get;set;}
    public String ReqCurrency{get;set;}
    public String ReqLangid{get;set;}
    public String ReqAction{get;set;}
    public String ReqResponseUrl{get;set;}
    public String ReqErrorUrl{get;set;}
    public String postPaymentPage {get;set;}
    public boolean IsReregistartion {get;set;}
    public decimal depositAmount {get;set;}
    public boolean IsOptedForCareerService {get;set;}
    public Boolean isCourseraOpted {get;set;}
    public boolean IsupGrad {get;set;}
    public String liveLecType {get;set;}
    public String courseList {get;set;}
    public String redirectPaymentPage {get;set;}
    
    public String strResponseBody{get;set;}

    // For upGrad Payment Configuration
    public String HDFC_SecretKey {get;set;}
    public String HDFC_SALT {get;set;}

    public String Paytm_EncryptionKey {get;set;}
    public String Paytm_IndustryId {get;set;}
    public String Paytm_MerchantKey {get;set;}
    public String Paytm_MID {get;set;}
    public Boolean isInternational {get;set;}
    
    //////////////////////////////////
    public string duration{get;set;}
    
  
    public nmOnlinePayment()
    {
        //Portal id 9000640
        //Merchant Id 13140
        //Terminal Id 9000640
        //Terminal Alias 9000640
        //Currency Code 356
        //Currency Code INR
        //Currency Code Exponential 2
        //Payment gateway fss
        postPaymentPage = '';
        InstallmentPayOpt  ='';      
        TranTrackid = '';
        TranAmount = '';
        strPaymentType = '';
        strEmailId = '';
        strMobileNumber = '';
        studentNo = '';
        strAddress = '';   
        duration='';
        TypeOfReuest ='';
        depositAmount = 0;
        IsReregistartion = false;  
        IsOptedForCareerService = false;
        isCourseraOpted = false;
        IsupGrad = false;
        liveLecType = '';
        courseList = '';
        isInternational = false;
        redirectPaymentPage = 'NA';

    }
    
    public string MakePayment()
    {  
        //strPortalId = '9000640';
        strPortalId = nmCommon.getConfigSettings('nm_PaymentgatewayID__c');
        //strPassword = 'password1';
        strPassword = nmCommon.getConfigSettings('nm_Paymentgatewaypassword__c');
        System.debug('duration+++'+duration);
        if(duration == '')
        {
            duration = 'Full' ;
        }
/*
       list<EMI_Duration_Terminal_Mapping__c> nmEMI_Duration_Terminal_Mapping = EMI_Duration_Terminal_Mapping__c.getAll().Values();
        System.debug(nmEMI_Duration_Terminal_Mapping );
        for(EMI_Duration_Terminal_Mapping__c obj : nmEMI_Duration_Terminal_Mapping )
        {
            if(obj.Name == duration)
            {
                strPortalId = obj.Terminal_Id__c ;
                strPassword = obj.Terminal_Id__c ;
            }
        }
       */
        System.debug('strPortalId+++'+strPortalId );
        System.debug('strPassword +++'+strPassword );
        
        ReqTranportalId = 'id='+strPortalId+'&';
        ReqTranportalPassword = 'password='+strPassword+'&';        
        ReqAmount = 'amt='+TranAmount+'&';  
        ReqTrackId='trackid='+TranTrackid+'&';
        ReqCurrency = 'currencycode=356&';      
        ReqLangid = 'langid=USA&'; 
        ReqAction = 'action=1&';
        
        
        ReqResponseUrl = 'responseURL='+nmCommon.getConfigSettings('nm_PaymentResponseURL__c')+'&';       
        ReqErrorUrl = 'errorURL='+nmCommon.getConfigSettings('nm_PaymentErrorResponseURL__c')+'&';   
        
        System.debug('NRA:TracId:::'+TranTrackid); 
        String ReqUdf1 = 'udf1='+strPaymentType+'&';    // UDF1 values 
        String ReqUdf2 = 'udf2='+strEmailId+'&';    // UDF2 values 
        String ReqUdf3 = 'udf3='+strMobileNumber+'&';   // UDF3 values 
        String ReqUdf4 = 'udf4='+strAddress+'&';    // UDF4 values 
        
        system.debug(strPortalId+'ppp'+TranTrackid+'!!!!'+TranAmount);
        String strhashTID = strPortalId;//USE Tranportal ID FIELD Value FOR HASHING 
        String strhashtrackid = TranTrackid;//USE Trackid FIELD Value FOR HASHING 
        String strhashamt = TranAmount;//USE Amount FIELD Value FOR HASHING 
        String strhashcurrency = '356';//USE Currencycode FIELD Value FOR HASHING 
        String strhashaction = '1';//USE Action code FIELD Value FOR HASHING
        
        
       
        //Create a Hashing String to Hash
        
        String Strhashs=strhashTID.trim()+strhashtrackid.trim()+strhashamt.trim()+strhashcurrency.trim()+strhashaction.trim();
        System.debug('NRAC:Strhashs:::'+Strhashs);
        
       
        
        String ReqUdf5 = 'udf5='+ ConvertToSha256(Strhashs);
        
        System.debug('NRACHASHCODE:::'+ReqUdf5);

        //Payment Id, Payment Page and ConnectionResponse variables are declared
        String paymentId=null;
        String paymentPage=null;
        String TranResponse=null;  
        
        // Now merchant sets all the inputs in one string for passing to the Payment Gateway URL
        try 
        {
            
           
            String TranRequest= ReqTranportalId+ReqTranportalPassword+ReqAction+ReqLangid+ReqCurrency+ReqAmount+ReqResponseUrl+ReqErrorUrl+ReqTrackId+ReqUdf1+ReqUdf2+ReqUdf3+ReqUdf4+ReqUdf5;
        
            System.debug('NRACQSTRING::::'+TranRequest);
            //This is Payment Gateway URL where merchant sends request. 
            //string url = 'https://securepgtest.fssnet.co.in/pgway/servlet/PaymentInitHTTPServlet';
            
            
            string url = nmCommon.getConfigSettings('nm_PaymentGatewayURL__c');
           // string url = 'https://securepg.fssnet.co.in/pgway/servlet/PaymentInitHTTPServlet';
                    
            //Sending payment request
            Http http = new Http();
            HTTPResponse res = sendPaymentRequest(TranRequest, url); 
            
            //Response result
            strResponseBody = res.getBody();
            System.debug('NRACPlayer:::'+strResponseBody);  
            
            if(strResponseBody != null && strResponseBody.split(':').size() > 1)
            {
                String strPaymentId = strResponseBody.split(':')[0];
                String strPaymentUrl = strResponseBody.split(':')[1];
                system.debug(strPaymentUrl+'?PaymentID='+strPaymentId);
                //return new PageREference('https://securepgtest.fssnet.co.in:443/pgway/gateway/payment/payment.jsp?PaymentID='+strPaymentId);
                return strResponseBody;
            }
        } 
        catch(Exception ex)
        {
            system.debug('NRACEXCEPTION::::::'+ex.getMessage());
            return null;
        }
        
        return null;
    }
    
    public string ConvertToSha256(string strInput)
    {
        blob hashString = Crypto.generateDigest('SHA-256', Blob.valueOf(strInput));
        return EncodingUtil.convertToHex(hashString);
    }
    
    //Method to make http request and return response
    public HTTPResponse sendPaymentRequest(string postString, String strUrl)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(strUrl);
        req.setMethod('POST');
        req.setHeader('Content-Length',String.valueof(postString.length()));
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody(postString);
          
        Http http = new Http();
        HTTPResponse res = http.send(req);        
        
        return res;
    }
    
    public String createtBillDeskRequest(){
        String msg = '';
        System.debug('Environment = '+Label.Environment);
        
        if(opportunityId == null || opportunityId == ''){
            opportunityId = 'NA';
        }
        
        if(InstallmentPayOpt ==null || InstallmentPayOpt =='')
        {
             InstallmentPayOpt = 'NA';
        }
        
        if( postPaymentPage == null || postPaymentPage == ''){
            postPaymentPage = 'NA';
        }
        
        if(redirectPaymentPage == null || redirectPaymentPage == '') {
            redirectPaymentPage = 'NA';
        }
        
        //  if(Label.Environment != null && Label.Environment == 'Sandbox'){
        //         //Setting Transaction amount to 1, if it is Sandbox and pass actual amount as 5th additional paramter
        //         msg += 'NMIMS|'+TranTrackid+ '|NA|'+ 1 + '|NA|NA|NA|INR|NA|R|nmims|NA|NA|F|' 
        //     + strEmailId + '|'+strMobileNumber + '|'+strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion +'_'+opportunityId+'|' + recordId + '|' + TranAmount + '|' + opportunityId + '|' +IsOptedForCareerService+'_'+liveLecType+'_'+courseList+ '|' + nmCommon.getConfigSettings('Payment_Response_New_URL__c')  ;
        //  }else{
        //          msg += 'NMIMS|'+TranTrackid+ '|NA|'+ TranAmount + '|NA|NA|NA|INR|NA|R|nmims|NA|NA|F|' 
        //     + strEmailId + '|'+strMobileNumber + '|'+strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion +'_'+opportunityId+'|' + recordId + '|' + TranAmount + '|' + opportunityId + '|' +IsOptedForCareerService+'_'+liveLecType+'_'+courseList+ '|' + nmCommon.getConfigSettings('Payment_Response_New_URL__c')  ;
        //  }
         
         msg += Label.Bill_Desk_Merchant_ID+'|'+TranTrackid+ '|NA|'+ TranAmount + '|NA|NA|NA|INR|NA|R|'+Label.Bill_Desk_Security_Id+'|NA|NA|F|' 
         + strEmailId + '|'+strMobileNumber + '|'+strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion +'_'+opportunityId+'|' + recordId + '|' + redirectPaymentPage + '|' + opportunityId + '|' +IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted+ '|' + nmCommon.getConfigSettings('Payment_Response_New_URL__c')  ;

        /*if(TypeOfReuest !=null && TypeOfReuest !='')
        {
            if(Label.Environment != null && Label.Environment == 'Sandbox'){
                //Setting Transaction amount to 1, if it is Sandbox and pass actual amount as 5th additional paramter
                msg += 'NMIMS|'+TranTrackid+ '|NA|'+ 1 + '|NA|NA|NA|INR|NA|R|nmims|NA|NA|F|' 
            + strEmailId + '|'+strMobileNumber + '|'+strPaymentType+'-'+InstallmentAmount+'-'+InstallmentPayOpt + '|' + recordId + '|' + TranAmount + '|' + opportunityId +'|NA|' + nmCommon.getConfigSettings('Payment_Response_New_URL__c')  ;
            }else{
                 msg += 'NMIMS|'+TranTrackid+ '|NA|'+ TranAmount + '|NA|NA|NA|INR|NA|R|nmims|NA|NA|F|' 
            + strEmailId + '|'+strMobileNumber + '|'+strPaymentType+'-'+InstallmentAmount+'-'+InstallmentPayOpt + '|' + recordId + '|' + TranAmount + '|' + opportunityId+ '|NA|' + nmCommon.getConfigSettings('Payment_Response_New_URL__c')  ;
            }
        }
        else
        {
            if(Label.Environment != null && Label.Environment == 'Sandbox'){
                //Setting Transaction amount to 1, if it is Sandbox and pass actual amount as 5th additional paramter
                msg += 'NMIMS|'+TranTrackid+ '|NA|'+ 1 + '|NA|NA|NA|INR|NA|R|nmims|NA|NA|F|' 
            + strEmailId + '|'+strMobileNumber + '|'+strPaymentType + '|' + recordId + '|' + TranAmount + '|' + opportunityId +'|NA|' + nmCommon.getConfigSettings('nm_PaymentResponseURL__c')  ;
            }else{
                 msg += 'NMIMS|'+TranTrackid+ '|NA|'+ TranAmount + '|NA|NA|NA|INR|NA|R|nmims|NA|NA|F|' 
            + strEmailId + '|'+strMobileNumber + '|'+strPaymentType + '|' + recordId + '|' + TranAmount + '|' + opportunityId+ '|NA|' + nmCommon.getConfigSettings('nm_PaymentResponseURL__c')  ;
            }
        } */   
         
        
        System.debug('Before msg = '+msg);
        
        //Generate checksumkey
        String algorithmName = 'HmacSHA256';
        String secretKey = Label.Bill_Desk_Checksum_Key;
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(msg), Blob.valueOf(secretKey));
        String checkSum = EncodingUtil.convertToHex(hmacData);
        
        System.debug('CheckSum = '+checkSum);
        
        //Append Checksum at the end of the message.
        msg = msg + '|' + checkSum.touppercase();
        System.debug('After msg = '+msg);
        
        return msg;
    }

    /**
    * @description 
    paypal payment Request Creation 
    * @author shubhranshu | 12-07-2020 
    * @return Map<String, String> 
    **/
   /* On hold Paypal
    public Map<String,String> createPayPalRequest(){
        String result = '';
        String custId = '';
        Map<String,String> responseParams = new Map<String,String>();

        if(String.isNotBlank(opportunityId)){
            custId = opportunityId;
        } else {
            custId = recordId;
            opportunityId = 'NA';
        }

        if(String.isBlank(postPaymentPage)){
            postPaymentPage = 'NA';
        }

        String uniqueReference = strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId+'_'+IsOptedForCareerService;
        System.debug('uniqueReference -->'+uniqueReference);
        PayPalPaymentRequestWrapper paymentReq = new PayPalPaymentRequestWrapper();
        PayPalPaymentRequestWrapper.Payer payer = new PayPalPaymentRequestWrapper.Payer();
        PayPalPaymentRequestWrapper.Transactions transactions = new PayPalPaymentRequestWrapper.Transactions();
        List<PayPalPaymentRequestWrapper.Transactions> lsttransactions = new List<PayPalPaymentRequestWrapper.Transactions>();
        PayPalPaymentRequestWrapper.Amount amount = new PayPalPaymentRequestWrapper.Amount();
        PayPalPaymentRequestWrapper.Details details= new PayPalPaymentRequestWrapper.Details();
        PayPalPaymentRequestWrapper.Payment_options paypalOptions = new PayPalPaymentRequestWrapper.Payment_options();
        PayPalPaymentRequestWrapper.Redirect_urls redirect_urls = new PayPalPaymentRequestWrapper.Redirect_urls();
        
        paymentReq.intent = 'sale';
        payer.payment_method = 'paypal';
        amount.total = Label.Environment != null && Label.Environment == 'Sandbox' ? '1.0' : TranAmount;
        amount.currencyCode = 'USD';
        details.subtotal = Label.Environment != null && Label.Environment == 'Sandbox' ? '1.0' : TranAmount;
        details.tax = '0.0';
        details.shipping = '0.0';
        details.handling_fee = '0.0';
        details.shipping_discount = '0.0';
        details.insurance = '0.0';
        
        amount.details = details;
        
        transactions.description = 'NGASCE Payment';
        transactions.custom = uniqueReference;
        transactions.invoice_number = TranTrackid;
        
        paypalOptions.allowed_payment_method = 'INSTANT_FUNDING_SOURCE';
        transactions.soft_descriptor = custId;
        transactions.amount = amount;
        paymentReq.note_to_payer = 'Contact us for any questions on your order.';
        // Encrypted data for security purpose with success message
        String successEcryptedData = PayPalWebService.generateEncryptedData(TranTrackid,uniqueReference,String.valueof(amount.total),'success');
        System.debug('successEcryptedData '+successEcryptedData);
        // Encrypted data for security purpose with error message
        String failEcryptedData = PayPalWebService.generateEncryptedData(TranTrackid,uniqueReference,String.valueof(amount.total),'fail');
        System.debug('failEcryptedData '+failEcryptedData);
        String PayPalResponseURL = nmCommon.getConfigSettings('PaymentResponseUrl_PayPal__c');
        redirect_urls.return_url = PayPalResponseURL+'?data='+successEcryptedData+'&txnid='+TranTrackid;
        redirect_urls.cancel_url = PayPalResponseURL+'?data='+failEcryptedData+'&txnid='+TranTrackid;
        
        lsttransactions.add(transactions);
        paymentReq.payer = payer;
        paymentReq.transactions = lsttransactions;
        paymentReq.redirect_urls = redirect_urls;

        String JsonStringReq = SYSTEM.JSON.serialize(paymentReq);
        JsonStringReq  = JsonStringReq.replace('currencyCode','currency');
        System.debug('JsonStringReq '+JsonStringReq);
        responseParams.put('JSONREQ',JsonStringReq);
        result = PayPalWebService.callPaypalPaymentRequest(JsonStringReq,recordId,opportunityId);
        responseParams.put('ReturnURL',result);
        return responseParams;
    }

*/
    
    /**
    * @description
    * @author Balakrishnan | 26/3/2019
    * @return Map<String, String>
    */
    public Map<String,String> createPayTMRequest() {
        String custId = '';

        if(String.isNotBlank(opportunityId)){
            custId = opportunityId;
        } else {
            custId = recordId;
            opportunityId = 'NA';
        }

        if(String.isBlank(postPaymentPage)){
            postPaymentPage = 'NA';
        }

        if(String.isBlank(strEmailId)) {
           strEmailId='NA@gmail.com';
        }

        if(String.isBlank(strMobileNumber)) {
           strMobileNumber='0000000000';
        }

        // For Website Key
        String websiteKey = nmCommon.getConfigSettings('Paytm_Website_Key__c');
        //For Industry type Id 
        String IndustryId = nmCommon.getConfigSettings('Paytm_Industry_Type_Id__c');
        // For Paytm Response URL
        String PaytmResponseURL = nmCommon.getConfigSettings('nm_PaymentResponseUrl_Paytm__c');
        // For Paytm MID
        String MID = Label.Paytm_Merchant_Key;
        // For Paytm Encryption key
        String Paytm_Encryption_Key = Label.Paytm_Encryption_Key;

        if(Test.isRunningTest()) { 
            websiteKey = 'WEBSTAGING';
            IndustryId = 'Retail';
            PaytmResponseURL = Label.Site_Url+'/nmPaytmPayResponse';
        }

        if(IsupGrad && String.isNotBlank(Paytm_MID) && String.isNotBlank(Paytm_EncryptionKey)) {
            websiteKey = Paytm_MerchantKey;
            IndustryId = Paytm_IndustryId;
            MID = Paytm_MID;
            Paytm_Encryption_Key = Paytm_EncryptionKey;
        }

        // For MERC_UNQ_REF
        if(String.isBlank(courseList)){
            courseList = null;
        }
        String uniqueReference = strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId+'_'+IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted+'_'+redirectPaymentPage;
        System.debug('uniqueReference -->'+uniqueReference);
        // String promoCampId = IsOptedForCareerService+'_'+liveLecType+'_'+courseList;
        Map<String,String> mapOfParametersToPass =new Map<String,String>();
        mapOfParametersToPass.put('MID',MID);
        mapOfParametersToPass.put('ORDER_ID',TranTrackid);
        mapOfParametersToPass.put('CHANNEL_ID','WEB');
        mapOfParametersToPass.put('CUST_ID',custId);
        mapOfParametersToPass.put('MOBILE_NO',strMobileNumber);
        mapOfParametersToPass.put('EMAIL',strEmailId);
        mapOfParametersToPass.put('TXN_AMOUNT',TranAmount);
        mapOfParametersToPass.put('WEBSITE',websiteKey);
        mapOfParametersToPass.put('INDUSTRY_TYPE_ID',IndustryId);
        mapOfParametersToPass.put('CALLBACK_URL', PaytmResponseURL);
        mapOfParametersToPass.put('MERC_UNQ_REF',uniqueReference);
        // mapOfParametersToPass.put('PROMO_CAMP_ID',promoCampId);
    
        
        //to generate checksum. 
        String checkSum = CheckSumServiceHelper.getCheckSumServiceHelper().genrateCheckSum(Paytm_Encryption_Key, mapOfParametersToPass);
        mapOfParametersToPass.put('CHECKSUMHASH',checkSum);
        
        for(String key : mapOfParametersToPass.keySet()) {
            System.debug('key -->'+ key + ' value -->'+mapOfParametersToPass.get(key));
        }
        String msg = '';
        for (String Key: mapOfParametersToPass.keySet()) {
            if(!'CHECKSUMHASH'.equalsIgnoreCase(Key)) {
                msg = msg + mapOfParametersToPass.get(Key) + '|';
            }
        }
        msg = msg.removeEnd('|');
        mapOfParametersToPass.put('msg',msg);
        return mapOfParametersToPass;
    }

    public Map<String,String> createHDFCDeskRequest()
    {
       if(strAddress =='' || strAddress ==null)
       {
           strAddress='NA';
       }
       if(strEmailId =='' || strEmailId ==null)
       {
           strEmailId='NA@gmail.com';
       }
       if(strName =='' || strName ==null)
       {
           strName ='NA';
       }
       if(strPincode =='' || strPincode ==null)
       {
           strPincode='000000';
       }
       if(strMobileNumber =='' || strMobileNumber ==null)
       {
           strMobileNumber='0000000000';
       }
       if(strCity =='' || strCity ==null)
       {
           strCity='NA';
       }
       if(opportunityId == null || opportunityId == ''){
            opportunityId = 'NA';
        }
        if(InstallmentAmount ==null || InstallmentAmount =='')
        {
            InstallmentAmount='NA';
        }
        if(InstallmentPayOpt ==null || InstallmentPayOpt =='')
        {
            InstallmentPayOpt ='NA';
        }
        if( postPaymentPage == null || postPaymentPage == ''){
            postPaymentPage = 'NA';
        }
      /* String  msg =Label.SECURE_SECRET+'|'+Label.Account_ID+'|'+strAddress+'|'+TranAmount+'|10|'+strCity+'|IND|INR|'+strPaymentType+'-'+recordId+'-'+opportunityId+'-'+InstallmentAmount+'|'+strEmailId+'|LIVE|'+strName+'|'+strMobileNumber+'|'+strPincode+'|'+TranTrackid+'|'+nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c');
        Map<String,String> mapOfParametersToPass =new Map<String,String>();
        mapOfParametersToPass.Put('channel', '10');
        mapOfParametersToPass.Put('account_id', Label.Account_ID);
        mapOfParametersToPass.Put('reference_no', TranTrackid);
        mapOfParametersToPass.Put('amount',TranAmount);
        mapOfParametersToPass.Put('mode', 'LIVE');
        mapOfParametersToPass.Put('currency', 'INR');
        mapOfParametersToPass.Put('description',strPaymentType+'-'+recordId+'-'+opportunityId+'-'+InstallmentAmount);//This should be used in response 
        mapOfParametersToPass.Put('return_url', nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c'));
        mapOfParametersToPass.Put('name', strName);
        mapOfParametersToPass.Put('address',strAddress);
        mapOfParametersToPass.Put('city', strCity);
        mapOfParametersToPass.Put('country', 'IND');
        mapOfParametersToPass.Put('postal_code', strPincode);
        mapOfParametersToPass.Put('phone', strMobileNumber);
        mapOfParametersToPass.Put('email', strEmailId );
        mapOfParametersToPass.Put('algo', 'MD5');
        mapOfParametersToPass.Put('msg',msg);
        System.debug('Before mapOfParametersToPass = '+mapOfParametersToPass.values());
        return mapOfParametersToPass;*/
        String secretKey = Label.SECURE_SECRET;
        String saltKey = Label.HDFC_SALT;
        if(IsupGrad && String.isNotBlank(HDFC_SecretKey) && String.isNotBlank(HDFC_SALT)) {
            secretKey = HDFC_SecretKey;
            saltKey = HDFC_SALT;
        }
        System.debug('saltKey -->'+saltKey +' secretKey -->'+secretKey);
        
        Map<String,String> mapOfParametersToPass =new Map<String,String>();
        mapOfParametersToPass.Put('key',secretKey);
        mapOfParametersToPass.Put('txnid', TranTrackid);
        mapOfParametersToPass.Put('amount',TranAmount);
        mapOfParametersToPass.Put('udf1',strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId);//This should be used in response 
        mapOfParametersToPass.Put('udf2',IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted);//This should be used in response 
        mapOfParametersToPass.Put('udf3',redirectPaymentPage);//This should be used in response 
        mapOfParametersToPass.Put('surl', nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c'));
        mapOfParametersToPass.Put('furl', nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c'));
        mapOfParametersToPass.Put('curl', nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c'));
        mapOfParametersToPass.Put('firstname', strName);
        mapOfParametersToPass.Put('productinfo',strPaymentType);
        mapOfParametersToPass.Put('city', strCity);
        mapOfParametersToPass.Put('country', 'IND');
        mapOfParametersToPass.Put('zipcode', strPincode);
        mapOfParametersToPass.Put('phone', strMobileNumber);
        mapOfParametersToPass.Put('email', strEmailId );
        mapOfParametersToPass.Put('SALT', saltKey);
        String msg=secretKey+'|'+TranTrackid+'|'+TranAmount+'|'+strPaymentType+'|'+strName+'|'+strEmailId+'|'+strMobileNumber+'|'+strPincode+'|IND|'+strCity+'|'+strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId+'|'+IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted+'|'+redirectPaymentPage+'|'+nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c')+'|'+nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c')+'|'+nmCommon.getConfigSettings('nm_PaymentResponseUrl_HDFC__c')+'|'+saltKey;
        mapOfParametersToPass.Put('msg',msg);
        
        Blob hmacData = Crypto.generateDigest('SHA-512',Blob.valueOf(secretKey+'|'+TranTrackid+'|'+TranAmount+'|'+strPaymentType+'|'+strName+'|'+strEmailId+'|'+strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId+'|'+IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted+'|'+redirectPaymentPage+'||||||||'+saltKey));
        String checkSum = EncodingUtil.convertToHex(hmacData);
        mapOfParametersToPass.Put('hash',checksum);
        System.debug('Before mapOfParametersToPass = '+mapOfParametersToPass.values());
        return mapOfParametersToPass;
    }

    public Map<String,Object> createRazorPayOrderRequest() {

        if(String.isBlank(opportunityId)){
            opportunityId = 'NA';
        }

        if(String.isBlank(postPaymentPage)){
            postPaymentPage = 'NA';
        }

        if(String.isBlank(strEmailId)) {
           strEmailId='NA@gmail.com';
        }

        if(String.isBlank(strMobileNumber)) {
           strMobileNumber='0000000000';
        }

        // String CurrencyCode = isInternational ? 'USD' : 'INR';
        String CurrencyCode = 'INR';
        System.debug('CurrencyCode ==>'+CurrencyCode);
        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        /* 
        Note : json object Key-value pair that can be used to store additional information about the entity. 
        Maximum 15 key-value pairs, 256 characters (maximum) each. 
        For example, "note_key": "Beam me up Scotty” 
        */
        Map<String,String> mapOfNotes = new Map<String,String>();
        mapOfNotes.put('udf1',strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId);
        mapOfNotes.put('udf2',IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted);
        mapOfNotes.put('udf3', redirectPaymentPage);
        // TranAmount  = TranAmount.substringBefore('.') + '00.00'; // added 00 because razorpay takes last two digits as paise 
        // System.debug('TranAmount '+TranAmount);
        Integer amount = Integer.valueOf(TranAmount);
        Map<String,Object> mapOfParametersToPass = new Map<String,Object>();
        mapOfParametersToPass.put('amount',amount * 100); // Dollar subunits 100 cents = 1 Dollar
        mapOfParametersToPass.put('currency',CurrencyCode);
        mapOfParametersToPass.put('receipt',TranTrackid);
        mapOfParametersToPass.put('notes',mapOfNotes);
        String jsonBodyParam = JSON.serialize(mapOfParametersToPass);
        System.debug('Before mapOfParametersToPass = '+jsonBodyParam);

        Blob headerValue = Blob.valueOf(Label.RazorPay_key_id +':'+Label.RazorPay_key_secret);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String RazorpayOrderUrl = nmCommon.getConfigSettings('Razorpay_Order_Url__c');
        if(Test.isRunningTest()) { 
            RazorpayOrderUrl = Label.Site_Url;
        }

        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(RazorpayOrderUrl);
        req.setMethod('POST');
        req.setHeader('Authorization',authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBodyParam);
        System.debug('Request --->'+req.getBody());
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('RESULT ===>'+result);
                mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                mapOfResponseParameters.put('return_url',nmCommon.getConfigSettings('nm_PaymentResponseUrl_Razorpay__c'));
                mapOfResponseParameters.put('udf1',mapOfNotes.get('udf1'));
                mapOfResponseParameters.put('udf2',mapOfNotes.get('udf2'));
                mapOfResponseParameters.put('udf3',mapOfNotes.get('udf3'));
            }
        }catch(Exception e){
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
        }
        return mapOfResponseParameters;
    }

    /**
    * @description 
    * @author @BK | 18-08-2022 
    * @return Map<String, Object> 
    **/
    public Map<String,Object> createICICIOrderRequest() {
        if(String.isBlank(opportunityId)){
            opportunityId = 'NA';
        }

        if(String.isBlank(postPaymentPage)){
            postPaymentPage = 'NA';
        }

        if(String.isBlank(strEmailId)) {
           strEmailId='NA@gmail.com';
        }

        if(String.isBlank(strMobileNumber) || strMobileNumber.length() <= 10) {
           strMobileNumber='0000000000';
        }

        if(String.isBlank(strName)) {
            strName ='NA';
        }

        if(String.isBlank(studentNo)) {
            studentNo = 'NMIMS_NA';
        }

        // String CurrencyCode = isInternational ? 'USD' : 'INR';
        String CurrencyCode = 'INR';
        System.debug('CurrencyCode ==>'+CurrencyCode);
        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        
        Map<String,String> mapOfOrderTags = new Map<String,String>();
        mapOfOrderTags.put('udf1',strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId);
        mapOfOrderTags.put('udf2',IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted);
        mapOfOrderTags.put('udf3', redirectPaymentPage);
        
        Map<String,String> mapOfUrl = new Map<String,String>();
        String returnUrl = nmCommon.getConfigSettings('nm_PaymentResponseUrl_ICICI__c') + '?order_id={order_id}&order_token={order_token}';
        mapOfUrl.put('return_url',returnUrl);

        Map<String,String> mapOfCustomerDetails = new Map<String,String>();
        mapOfCustomerDetails.put('customer_id',studentNo);
        mapOfCustomerDetails.put('customer_name',strName);
        mapOfCustomerDetails.put('customer_email',strEmailId);
        mapOfCustomerDetails.put('customer_phone',strMobileNumber);

        Decimal amount = Decimal.valueOf(TranAmount);
        Map<String,Object> mapOfParametersToPass = new Map<String,Object>();
        mapOfParametersToPass.put('order_id',TranTrackid);
        mapOfParametersToPass.put('order_amount',amount);
        mapOfParametersToPass.put('order_currency',CurrencyCode);
        mapOfParametersToPass.put('order_expiry_time',datetime.now().addMinutes(30).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        mapOfParametersToPass.put('order_tags',mapOfOrderTags);
        mapOfParametersToPass.put('order_meta',mapOfUrl);
        mapOfParametersToPass.put('customer_details',mapOfCustomerDetails);
        String jsonBodyParam = JSON.serialize(mapOfParametersToPass);
        System.debug('Before mapOfParametersToPass = '+jsonBodyParam);


        String ICICIOrderUrl = nmCommon.getConfigSettings('ICICI_Base_Url__c') + '/orders';
        if(Test.isRunningTest()) { 
            ICICIOrderUrl = Label.Site_Url;
        }
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(ICICIOrderUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-api-version','2022-01-01');
        req.setHeader('x-client-id',Label.ICICI_App_Id);
        req.setHeader('x-client-secret',Label.ICICI_Secret_Key);
        req.setBody(jsonBodyParam);
        System.debug('Request --->'+req.getBody());
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                String result = resp.getBody();
                System.debug('RESULT ===>'+result);
                mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
            }
        }catch(Exception e){
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
        }
        return mapOfResponseParameters;
    }

    public Map<String,Object> createtBillDeskRequestV2() {
        if(String.isBlank(opportunityId)){
            opportunityId = 'NA';
        }

        if(String.isBlank(postPaymentPage)){
            postPaymentPage = 'NA';
        }

        if(String.isBlank(strEmailId)) {
           strEmailId='NA@gmail.com';
        }

        if(String.isBlank(strMobileNumber)) {
           strMobileNumber='0000000000';
        }

        if(String.isBlank(strName)) {
            strName ='NA';
        }

        if(String.isBlank(studentNo)) {
            studentNo = 'NMIMS_NA';
        }

        String CurrencyCode = 'INR';
        System.debug('CurrencyCode ==>'+CurrencyCode);
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        
        Map<String,String> mapOfAdditional_info = new Map<String,String>();
        mapOfAdditional_info.put('additional_info1',strPaymentType+'_'+recordId+'_'+depositAmount+'_'+postPaymentPage+'_'+IsReregistartion+'_'+opportunityId);
        mapOfAdditional_info.put('additional_info2',IsOptedForCareerService+'_'+liveLecType+'_'+courseList+'_'+isCourseraOpted);
        mapOfAdditional_info.put('additional_info3',redirectPaymentPage);

        Map<String,String> mapOfDevice = new Map<String,String>();
        mapOfDevice.put('init_channel','internet');
        mapOfDevice.put('ip',ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'));
        mapOfDevice.put('user_agent',ApexPages.currentPage().getHeaders().get('User-Agent'));

        Map<String,Object> mapOfParametersToPass = new Map<String,Object>();
        mapOfParametersToPass.put('mercid',BilldeskV2.Merchant_ID__c);
        mapOfParametersToPass.put('orderid',TranTrackid);
        mapOfParametersToPass.put('amount',TranAmount);
        // mapOfParametersToPass.put('order_date',datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        mapOfParametersToPass.put('order_date',datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') + '+05:30');
        mapOfParametersToPass.put('currency','356');
        mapOfParametersToPass.put('ru',nmCommon.getConfigSettings('nm_PaymentResponseUrl_BillDesk__c'));
        mapOfParametersToPass.put('additional_info',mapOfAdditional_info);
        mapOfParametersToPass.put('itemcode','DIRECT');
        mapOfParametersToPass.put('device',mapOfDevice);
        String jsonBodyParam = JSON.serialize(mapOfParametersToPass);
        System.debug('Before mapOfParametersToPass = '+jsonBodyParam);

        String headerJWS = '{"alg":"HS256","clientid":"' + BilldeskV2.Client_ID__c + '"}';
        string jwt = nmBillDeskHelper.base64URLencode(blob.valueof(headerJWS)) + '.' +nmBillDeskHelper.base64URLencode(blob.valueof(jsonBodyParam));
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),blob.valueof(BilldeskV2.Secret_Key__c));

        String billDeskV2Url = BilldeskV2.Base_Url__c + 'payments/ve1_2/orders/create';
        if(Test.isRunningTest()) { 
            billDeskV2Url = Label.Site_Url;
        }
        String timestampUnix = String.valueOf(Datetime.now().getTime());
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(billDeskV2Url);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/jose');
        req.setHeader('accept', 'application/jose');
        req.setHeader('bd-traceid', TranTrackid);
        req.setHeader('bd-timestamp', timestampUnix );
        system.debug('bd-traceid ---> ' + TranTrackid);
        system.debug('bd-timestamp ---> ' + timestampUnix);
        // req.setBody('jwt');
        req.setBody(jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
        System.debug('Request --->'+jwt + '.' +nmBillDeskHelper.base64URLencode(signature));
        try{
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Response --->'+resp);
            System.debug('ResponseHeaders --->'+resp.getHeaderKeys());
            for (String hd : resp.getHeaderKeys()) {
                if (String.isNotBlank(hd)) {
                    system.debug('hd ' + hd + ' --> ' + resp.getHeader(hd));
                }
            }
            String result = resp.getBody();
            System.debug('RESULT ===>'+result);
            System.debug('Authentication_API:statusCode = '+statusCode);
            if(statusCode == 200){
                List<String> resultSplit = String.isNotBlank(result) ? result.split('\\.') : new List<String>();
                if (resultSplit.size() == 3 && nmBillDeskHelper.hmacSHA256Verification(resultSplit[0], resultSplit[1], resultSplit[2], BilldeskV2.Secret_Key__c)) {
                    mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped((EncodingUtil.base64decode(resultSplit[1])).toString());
                }
            }
        }catch(Exception e){
            System.debug('Callout Exception Authentication_API :'+e);
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
        }
        return mapOfResponseParameters;
    }
}