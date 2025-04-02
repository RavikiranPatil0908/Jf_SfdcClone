public without sharing class AepPaymentController{
    
    public String recordId {get;set;}
    public String paymentGatewayName {get;set;}
    public nm_Payment__c objPayment{get;set;}
    public boolean paymentWindowClosed {get;set;}
    public String paymentClouserMessage {get;set;}
    public Map<String,Decimal> mapOfProductAndAmount {get;set;}
    public String paymentFor {get;set;}
    public nm_Centers__c objtCenter {get;set;}
    public AEP_site_inspection__c aepisp {get;set;}
    public String centerId {get;set;}
    public String AEPId {get;set;}
    public String AEPISPId {get;set;}
    public String postPaymentPage {get;set;}
    public Map<String,nm_Program__c> mapOfProgramNameVsProgram {get;set;}
    public String displayName {get;set;}// kept for Registration No or Student No to show on Page 
    public ProductHelper productHelper {get;set;}

    // -------------AEP License Fee MUltiple Payment ----- // 
    public Boolean isAEPLicenseFeeMultiplePayment {get;set;}
    public String aepLicenseFeeCombo {get;set;}


    //-----------------Error Message Parameter ----//
    public string errMessages { get; set; }
    public string strSecToShow { get; set; }
    
    // --------------Student Details For Payment ----//
    public String studentNo {get;set;}
    public String studentName {get;set;}
    public String studentInfo{get;set;}
    public String studentEmail {get;set;}
    public String studentMobileNo {get;set;}
    public String studentAddress {get;set;}
    public String studentCity {get;set;}
    public String studentPincode {get;set;}
    public String aepCenId {get;set;}
    
    public AepPaymentController(){
        recordId = '';
        paymentGatewayName = '';    
        productHelper = new ProductHelper();
        mapOfProgramNameVsProgram = new Map<String,nm_Program__c>();
        paymentClouserMessage = '';
        paymentWindowClosed = false;
        studentInfo ='';
        objPayment = new nm_Payment__c();
        objtCenter = new nm_Centers__c ();
        aepisp = new AEP_site_inspection__c();
        mapOfProductAndAmount = new Map<String,Decimal>();
        // objPaymentFormConfiguration = new NM_Payment_Form_Configuration__c();
        errMessages = '';
        strSecToShow = '';
        studentName = '';
        studentEmail = '';
        studentMobileNo = '';
        studentAddress = '';
        studentCity = '';
        postPaymentPage = 'PostPaymentPage';
        studentPincode = '';
        centerId = '';
        displayName = '';     
        AEPId='';
        AEPISPId = '';
        paymentFor = '';
        aepCenId='';
        isAEPLicenseFeeMultiplePayment = false;
        aepLicenseFeeCombo = '';
        if(ApexPages.currentPage() != null) {
            recordId = ApexPages.currentPage().getParameters().get('id');
            if(ApexPages.currentPage().getParameters().get('pyt') !=null){
                paymentFor = ApexPages.currentPage().getParameters().get('pyt');
            }
        }

        if(String.isNotBlank(recordId) && String.isNotBlank(paymentFor)){
            QueryAepLicenseFee();
        }
    }
    
    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString , String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }
    
    public void QueryAepLicenseFee(){
        String centerquery = getQueryAllFieldSql('nm_Centers__c','id =:recordId',null);
        String asiQuery = getQueryAllFieldSql('AEP_site_inspection__c','id =:recordId and Centers__c = null',null);
        List<nm_Centers__c> lstCenter  = DataBase.query(centerquery);
        system.debug('lstCenter--->'+lstCenter);
                           
        if(lstCenter.size()>0)
        {
            String priceBookEntryQuery4 = getQueryAllFieldSql('PriceBookEntry','product2.Family=\'AEP\' and product2.isActive = true AND Pricebook2.nmSession_Start_Date__c <= today AND Pricebook2.nmSession_End_Date__c >= today',' product2.Name,product2.GST__c, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');

            List<PriceBookEntry> lstPriceBookEntry = DataBase.query(priceBookEntryQuery4);
            if(lstPriceBookEntry.size() > 0 && paymentFor!=null){
                                
                for(PriceBookEntry objprice: lstPriceBookEntry)
                {
                    // mapOfProductAndAmount.put(objprice.product2.Name,objprice.product2.GST__c? (objprice.UnitPrice+(objprice.UnitPrice*Decimal.valueOf(Label.Service_Tax))).setScale(2): objprice.UnitPrice);
                    if (lstCenter[0].Discount_applicable__c) {
                        Decimal discountedAmount = Decimal.valueOf(Label.Discount_applicable_value	) * objprice.UnitPrice;
                        Decimal gstAmount = objprice.product2.GST__c?  discountedAmount*Decimal.valueOf(Label.Service_Tax) : 0;
                        Decimal tdsAmount = lstCenter[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * discountedAmount : 0;
                        mapOfProductAndAmount.put(objprice.product2.Name, (discountedAmount + gstAmount + tdsAmount).setScale(2));
                    } else {
                        Decimal gstAmount = objprice.product2.GST__c?  objprice.UnitPrice*Decimal.valueOf(Label.Service_Tax) : 0;
                        Decimal tdsAmount = lstCenter[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * objprice.UnitPrice : 0;
                        mapOfProductAndAmount.put(objprice.product2.Name, (objprice.UnitPrice + gstAmount - tdsAmount).setScale(2));
                    }
                }
                                    
            }                               
            for(nm_Centers__c objcenter:lstCenter)
            {
                objtCenter =  objcenter;
                studentName = objcenter.Name;
                studentEmail = objcenter.AEP_email_id__c;
                studentMobileNo = objcenter.Contact_No_1__c;
                studentCity = objcenter.nm_City__c;
                studentPincode = objcenter.nm_PostalCode__c;
                studentInfo = paymentFor;
                studentNo = '';
                paymentFor = paymentFor;
                AEPId = objcenter.id;
                displayName = paymentFor;
                system.debug('mapOfProductAndAmount-->'+mapOfProductAndAmount);
                system.debug('paymentFor-->'+paymentFor);
            }
        } else {
                               
            List<AEP_site_inspection__c> lstAEPSiteIns  = DataBase.query(asiQuery);
            system.debug('lstAEPSiteIns--->'+lstAEPSiteIns);
            if(lstAEPSiteIns.size()>0)
            {
                List<nm_Payment__c> lstASIPayApp = [SELECT Id FROM nm_Payment__c WHERE AEP_site_inspection__c = :lstAEPSiteIns[0].Id AND nm_PaymentType__c = 'Application Fee' AND (nm_PaymentStatus__c = 'Payment Made' OR nm_PaymentStatus__c = 'Payment Approved' )];
                system.debug('lstASIPayApp --> ' + lstASIPayApp);
                String priceBookEntryQuery5 = getQueryAllFieldSql('PriceBookEntry','product2.Family=\'AEP\' and product2.isActive = true AND Pricebook2.nmSession_Start_Date__c <= today AND Pricebook2.nmSession_End_Date__c >= today',' product2.Name,product2.GST__c, product2.nm_Program__c, product2.nm_Program__r.id, product2.nm_Semester__c ');

                List<PriceBookEntry> lstPriceBookEntry1 = DataBase.query(priceBookEntryQuery5);
                if(lstPriceBookEntry1.size() > 0 && paymentFor!=null){
                                        
                    for(PriceBookEntry objprice: lstPriceBookEntry1)
                    {
                        if (lstAEPSiteIns[0].Discount_applicable__c) {
                            Decimal discountedAmount = Decimal.valueOf(Label.Discount_applicable_value	) * objprice.UnitPrice;
                            Decimal gstAmount = objprice.product2.GST__c?  discountedAmount*Decimal.valueOf(Label.Service_Tax) : 0;
                            Decimal tdsAmount = lstAEPSiteIns[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * discountedAmount : 0;
                            mapOfProductAndAmount.put(objprice.product2.Name, (discountedAmount + gstAmount + tdsAmount).setScale(2));
                        } else {
                            Decimal gstAmount = objprice.product2.GST__c?  objprice.UnitPrice*Decimal.valueOf(Label.Service_Tax) : 0;
                            Decimal tdsAmount = lstAEPSiteIns[0].TDS_Deduction__c ? Decimal.valueOf(Label.TDS_value) * objprice.UnitPrice : 0;
                            mapOfProductAndAmount.put(objprice.product2.Name, (objprice.UnitPrice + gstAmount - tdsAmount).setScale(2));
                        }
                    }
                                            
                }
                List<String> licenseFeeAllowd = Label.ProductLicenseFee.split(';');
                if (lstASIPayApp.size() == 0 && licenseFeeAllowd.contains(paymentFor)) {
                    isAEPLicenseFeeMultiplePayment = true;
                    paymentFor = 'Application And ' + paymentFor;
                    aepLicenseFeeCombo = paymentFor;
                    system.debug('Application Fee --> ' + mapOfProductAndAmount.get('Application Fee'));
                    system.debug(paymentFor.substringAfter('Application And ') +' --> '+ mapOfProductAndAmount.get(paymentFor.substringAfter('Application And ')).setScale(2));
                    mapOfProductAndAmount.put(paymentFor, (mapOfProductAndAmount.get('Application Fee') + mapOfProductAndAmount.get(paymentFor.substringAfter('Application And '))).setScale(2));
                
                }                             
                for(AEP_site_inspection__c aepisp:lstAEPSiteIns)
                {
                    aepisp =  aepisp;
                    studentName = aepisp.Name_of_the_Centre__c;
                    studentEmail = aepisp.User_Email__c;
                    studentMobileNo = aepisp.Contact_No_1__c;
                    studentCity = aepisp.Location_City__c;
                    studentPincode = aepisp.nm_PostalCode__c;
                    studentInfo = paymentFor;
                    studentNo = aepisp.Name.Split('-')[1].trim();
                    paymentFor = paymentFor;
                    AEPISPId = aepisp.id;

                    displayName = String.isNotBlank(paymentFor) ? paymentFor : '';
                }
            } else {
                errMessages = 'No matching record found for mention details';
                strSecToShow = 'error';
                System.debug('errMessages '+errMessages+' strSecToShow '+strSecToShow);
                return;
            }     
        }
    }

     /*---------------------------------------------Online Payment -----------------------------------------------------------------*/
    public pageReference MakeOnlinePayment(){
       System.debug('paymentFor ---'+paymentFor );
       if(paymentFor !=null && paymentFor !=''){
            //Creating payment tracking Id. 
            string strTranTrackid = studentNo+''+datetime.now().year()+''+datetime.now().month() +''+datetime.now().day()+''+datetime.now().hour() 
            +''+datetime.now().minute()+''+datetime.now().millisecond() + '' + integer.valueof(Math.floor(1000 + Math.random()*9000));
            System.debug('recordId--->'+recordId);
            strTranTrackid = strTranTrackid.right(30);
            System.debug('strTranTrackid--->'+strTranTrackid);
            nmOnlinePayment objOnlinePayment = new nmOnlinePayment();
            objOnlinePayment.TranTrackid = strTranTrackid;
            objOnlinePayment.strAddress = studentAddress;
            objOnlinePayment.strCity = studentCity;
            objOnlinePayment.strPincode = studentPincode;
            objOnlinePayment.strName = studentName;
            system.debug('objOnlinePayment.strEmailId Before--> ' + objOnlinePayment.strEmailId);
            objOnlinePayment.strEmailId = studentEmail;
            system.debug('objOnlinePayment.strEmailId After--> ' + objOnlinePayment.strEmailId);
            objOnlinePayment.strMobileNumber = studentMobileNo;
            objOnlinePayment.recordId = recordId;
            objOnlinePayment.opportunityId = null;
            objOnlinePayment.InstallmentAmount = 'NA';
            objOnlinePayment.strPaymentType = paymentFor;
            objOnlinePayment.InstallmentPayOpt = 'NA';
            objOnlinePayment.isCourseraOpted = false;
            objOnlinePayment.studentNo = studentNo;
            objOnlinePayment.TranAmount = String.valueOf(mapOfProductAndAmount.get(paymentFor));
            objOnlinePayment.postPaymentPage = postPaymentPage;
            objOnlinePayment.IsReregistartion = false;
            objOnlinePayment.depositAmount = 0;
            objOnlinePayment.courseList = null;
            objOnlinePayment.liveLecType  = null;
            system.debug('objOnlinePayment.redirectPaymentPage Before--> ' + objOnlinePayment.redirectPaymentPage);
            objOnlinePayment.redirectPaymentPage = 'AepPaymentPage';
            system.debug('objOnlinePayment.redirectPaymentPage After--> ' + objOnlinePayment.redirectPaymentPage);
            
            // Call Payment GateWay Option Based Upon Selected Option
           return PaymentRequestCreator(objOnlinePayment,strTranTrackid); 
        }else{
            errMessages = 'Unable to get payment details.';
            strSecToShow = 'error';
            return null;
        }
    }
    
    /*-----------------------Payment Request Creator----------------------------------*/
    // Save Payment Reuest before Making Online Payment 
    // Based Upon selected Payment GateWay Option Create Secure Hash code for Online Payment
    public PageReference PaymentRequestCreator(nmOnlinePayment objOnlinePayment ,String strTranTrackid){
        System.debug('PaymentRequestCreator call ');
        PaymentRequestParams objParams = new PaymentRequestParams();
        objParams.strTranTrackid = strTranTrackid;
        objParams.strPaymentType = objOnlinePayment.strPaymentType;
        objParams.paymentGatewayVersion = null;
    
        if(paymentGateWayName =='HDFC GateWay'){
            Map<String,String> mapOfParameters =objOnlinePayment.createHDFCDeskRequest();
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.get('msg'), null);
            objParams.msg = mapOfParameters.get('msg');
            SavePaymentBeforeResponse(objParams);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            String md5HashData = Label.SECURE_SECRET;
            Blob hmacData = Crypto.generateDigest('MD5', Blob.valueOf(mapOfParameters.get('msg')));
            String checkSum = EncodingUtil.convertToHex(hmacData);
            pgURL.getParameters().put('test',mapOfParameters.get('msg'));
            mapOfParameters.remove('msg');
            mapOfParameters.remove('algo');
            mapOfParameters.remove('submit');
            for (String key : mapOfParameters.keySet()){
                pgURL.getParameters().put(key, mapOfParameters.get(key));
                System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
            }
            //pgURL.getParameters().put('secure_hash', checkSum.toUppercase());
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        }else if(paymentGateWayName == 'BillDesk GateWay'){
            if (Label.BillDesk_GatewayVersion == 'v1') {
                String msg = objOnlinePayment.createtBillDeskRequest(); 
                objParams.msg = msg;
                // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, msg, null);
                SavePaymentBeforeResponse(objParams);
            
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            pgURL.getParameters().put('msg', msg);
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
            } else if(Label.BillDesk_GatewayVersion == 'v2') {
                // Bill Desk Gateway v2
                API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
                Map<String,Object> mapOfParameters = objOnlinePayment.createtBillDeskRequestV2();
                System.debug('mapOfParameters --> ' + mapOfParameters);
                if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('error')) {
                    strSecToShow = 'PopUpError';
                    errMessages = 'Unable to get payment details.';
                    strSecToShow = 'error';
                    return null;
                }
                objParams.msg = JSON.serialize(mapOfParameters);
                objParams.orderId = (String)mapOfParameters.get('bdorderid');
                Map<String,Object> mapOfAdditionalInfo = (Map<String,Object>)mapOfParameters.get('additional_info');
                objParams.udf1 = (String)mapOfAdditionalInfo.get('additional_info1');
                objParams.udf2 = (String)mapOfAdditionalInfo.get('additional_info2');
                objParams.udf3 = (String)mapOfAdditionalInfo.get('additional_info3');
                objParams.paymentGatewayVersion = 'v2';
                SavePaymentBeforeResponse(objParams);
                // String jsonResponse = JSON.serialize(mapOfParameters);
                // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, jsonResponse, (String)mapOfParameters.get('bdorderid'));
                List<Object> listOfLinks = (List<Object>)mapOfParameters.get('links');
                Map<String, Object> mapOfHeaders = (Map<String, Object>) listOfLinks[1];
                Map<String, Object> mapOfAuth = (Map<String, Object>) mapOfHeaders.get('headers');
                PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
                pgURL.getParameters().put('type', 'BillDesk GateWay v2');
                pgURL.getParameters().put('merchantId', (String)mapOfParameters.get('mercid'));
                pgURL.getParameters().put('bdOrderId', (String)mapOfParameters.get('bdorderid'));
                pgURL.getParameters().put('ru', (String)mapOfParameters.get('ru'));
                pgURL.getParameters().put('authToken', (String)mapOfAuth.get('authorization'));
                pgURL.getParameters().put('TranTrackid', (String)mapOfParameters.get('orderid'));
                pgURL.getParameters().put('baseUrl', BilldeskV2.Base_Url__c);
                return pgURL;
            } else {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            


        }
        else if(paymentGateWayName == 'Razorpay GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createRazorPayOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('error')) {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            objParams.orderId = (String)mapOfParameters.get('id');
            objParams.paymentCurrency = (String)mapOfParameters.get('currency');
            objParams.udf1 = (String)mapOfParameters.get('udf1');
            objParams.udf2 = (String)mapOfParameters.get('udf2');
            objParams.udf3 = (String)mapOfParameters.get('udf3');
            SavePaymentBeforeResponse(objParams);
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, null, (String)mapOfParameters.get('id'));
            PageReference pgURL = new PageReference('/apex/RazorPayGateway');
            List<String> lstKey = new List<String>{'amount','amount_paid','amount_due','attempts','created_at'};
            for (String key : mapOfParameters.keySet()){
                String mapValue = null;
                if(lstKey.contains(key)) {
                    mapValue = String.valueOf(mapOfParameters.get(key));
                } else if(key == 'notes') {
                    Map<String,Object> mapOfNotes = (Map<String,Object>)mapOfParameters.get(key);
                    for (String NoteKey : mapOfNotes.keySet()){ 
                        pgURL.getParameters().put(NoteKey, (String)mapOfNotes.get(NoteKey));
                    }
                    mapValue = JSON.serialize(mapOfNotes);
                } else {
                    mapValue = (String)mapOfParameters.get(key);
                }
                pgURL.getParameters().put(key, mapValue);
                System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
            }
            pgURL.getParameters().put('Name', studentName);
            pgURL.getParameters().put('email', studentEmail);
            pgURL.getParameters().put('contact', studentMobileNo);
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        } else if(paymentGateWayName == 'ICICI GateWay') {
            Map<String,Object> mapOfParameters = objOnlinePayment.createICICIOrderRequest();
            if(mapOfParameters.size() == 0 || mapOfParameters.containsKey('type')) {
                strSecToShow = 'PopUpError';
                errMessages = 'Unable to get payment details.';
                strSecToShow = 'error';
                return null;
            }
            objParams.msg = JSON.serialize(mapOfParameters);
            objParams.orderId = (String)mapOfParameters.get('order_token');
            objParams.paymentCurrency = (String)mapOfParameters.get('order_currency');
            SavePaymentBeforeResponse(objParams);
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, jsonResponse, (String)mapOfParameters.get('order_token'));
            // objParams.msg = JSON.serialize(mapOfParameters);
            // objParams.orderId = (String)mapOfParameters.get('order_token');
            // objParams.paymentCurrency = (String)mapOfParameters.get('order_currency');
            // SavePaymentBeforeResponse(objParams);

            String paymentUrl = (String)mapOfParameters.get('payment_link');
            PageReference pgURL = new PageReference(paymentUrl);
            return pgURL;
        }
        /*on hold
        else if(paymentGateWayName =='PayPal GateWay') {
            Map<String,String> mapOfParameters = objOnlinePayment.createPayPalRequest();
            SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.remove('JSONREQ'));
            PageReference pgURL = new PageReference(mapOfParameters.get('ReturnURL'));
            return pgURL;
        }*/
        // else if(paymentGateWayName == 'CCAvenue GateWay') {
        //     Map<String,String> mapOfParameters = objOnlinePayment.createCCAvenueOrderRequest();
        //     System.debug('mapOfParameters ==>'+mapOfParameters);
        //     objParams.msg = mapOfParameters.remove('msg');
        //     objParams.paymentCurrency = 'USD';
        //     objParams.udf1 = mapOfParameters.remove('udf1');
        //     objParams.udf2 = mapOfParameters.remove('udf2');
        //     // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid, mapOfParameters.remove('msg'), null, 'USD', mapOfParameters.get('merchant_param1'), mapOfParameters.get('merchant_param2'));
        //     System.debug('objParams 1 ==>'+objParams);
        //     SavePaymentBeforeResponse(objParams);
        //     PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
        //     for (String key : mapOfParameters.keySet()){
        //         pgURL.getParameters().put(key, mapOfParameters.get(key));
        //         System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
        //     }
        //     pgURL.getParameters().put('type', paymentGateWayName);
        //     return pgURL;
        // } 
        else{
            // For Paytm Gateway
            Map<String,String> mapOfParameters = objOnlinePayment.createPayTMRequest();
            objParams.msg = mapOfParameters.remove('msg');
            SavePaymentBeforeResponse(objParams);
            // SavePaymentBeforeResponse(objOnlinePayment.strPaymentType, strTranTrackid , mapOfParameters.remove('msg'), null);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            for (String key : mapOfParameters.keySet()){
                pgURL.getParameters().put(key, mapOfParameters.get(key));
                System.debug('Key---->'+Key+'----Value----->'+mapOfParameters.get(key));
            }
            pgURL.getParameters().put('type', paymentGateWayName);
            return pgURL;
        }
    }
    
     /*-------------- Creating Payment Records before Payment --------------*/
    // Creating Payment Initiation Record Based Upon Selected Option (eg.Regisatrtion,Admission,PGAllSemFee,AnnualFee) for Future Reference
    // public void SavePaymentBeforeResponse(String strPaymentType ,String strTranTrackid ,String msg, String orderId){
    public void SavePaymentBeforeResponse(PaymentRequestParams objParams){
        // System.debug('objParams 2 ==>'+objParams);
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToInsert = new list<nm_Payment_Initiated__c>();
        
        
        //------- Initializing payment object with common values ---------//
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c(); 
        objPayment.nm_PaymentStatus__c = 'Payment Initiated';   
        objPayment.nm_Lead__c = null; 
        objPayment.nm_OpportunityNew__c = null;    
        objPayment.nm_ModeOfPayment__c = 'Online';  
        objPayment.nm_TransactionDate__c = Date.today();    
        objPayment.nm_PaymentGatewayName__c = paymentGateWayName;   
        objPayment.nm_Merchant_Track_Id__c = objParams.strTranTrackid;    
        objPayment.Gateway_Detailed_Request__c = objParams.msg;   
        objPayment.Additional_param1__c = objParams.udf1;
        objPayment.Additional_param2__c = objParams.udf2;
        objPayment.Additional_param3__c = objParams.udf3;
        objPayment.Payment_Gateway_Version__c = objParams.paymentGatewayVersion;
        if(String.isNotBlank(objParams.orderId)) {
            objPayment.OrderId__c = objParams.orderId;
        }
        if(String.isNotBlank(paymentFor)){

            if(!paymentFor.contains('Application And')){  
              lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, paymentFor, mapOfProductAndAmount.get(paymentFor),mapOfProductAndAmount.get(paymentFor), paymentFor) );
            } else if (paymentFor.contains('Application And')) {
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, 'Application Fee', mapOfProductAndAmount.get('Application Fee'),mapOfProductAndAmount.get(paymentFor), 'Application Fee') );
                lstPaymentToInsert.add( CreatePaymentInitiatedRecord( objPayment, paymentFor.substringAfter('Application And '), mapOfProductAndAmount.get(paymentFor.substringAfter('Application And ')).setScale(2),mapOfProductAndAmount.get(paymentFor).setScale(2), paymentFor.substringAfter('Application And ')) );
            }
        }
        System.debug('lstPaymentToInsert --> ' + lstPaymentToInsert);
        System.debug('paymentFor--'+paymentFor+'------'+mapOfProductAndAmount.get(paymentFor));
        try{
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                insert lstPaymentToInsert;
            }
        }catch(Exception e){
            system.debug('------string.valueof(e)--------'+string.valueof(e));
        }
    }
    /*----------------Create Payment Initiation Record ------------------------------------------------*/
    // Method to Create Payment Initiation Record
    public nm_Payment_Initiated__c CreatePaymentInitiatedRecord( nm_Payment_Initiated__c objPayment, String PaymentType, decimal Amount , decimal paymentForAmount, String feesType){
        nm_Payment_Initiated__c objPay = objPayment.clone();
        objPay.nm_PaymentType__c = PaymentType;
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount;
        objPay.nm_Amount__c = Amount;
        objPay.nm_Fee_Type__c = feesType;
        if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            system.debug('AEPId -->' + AEPId);
            objPay.AEP__c = AEPId;
            objPay.nm_Lead__c = null;
        }else if(AEPISPId != '' && AEPISPId != null && AEPISPId != 'NA'){
            System.debug('AEPISPId -->'+AEPISPId);
            objPay.AEP_site_inspection__c = AEPISPId;
            objPay.nm_Lead__c = null;
        }
        
        return objPay;
    }
    
    /*-------------- Creating Payment Records after Payment --------------*/
    // This Method used to Handle Payment Response After Making Online Payment
    // Creating Payment Record with status of Payment made if transition is successfully 
    // Creating Payment Record with status of Transaction Failed if transition is failed

    //
    // public String MakePaymentAfterResponse (
    //     String strResTranId, 
    //     String paymentTransactionMode,
    //     string strPaymentTrackId,
    //     String strPaymentId, 
    //     String strResResult, 
    //     String strErrorText,
    //     String strErrorCode,
    //     String strPaymentType,
    //     String detailedGatewayResponse,//Added by Sanket 13-Oct-2015
    //     //String PaymentSelectionOption // it can be Creadit card,Debit card ,Net Banking
    //     String additionalResult, // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
    //     // String currencyOfPayment,
    //     Decimal feeCharges,
    //     Decimal tax
    // ){
    
    public String MakePaymentAfterResponse (PaymentHandler.PaymentResponseWrapper objResponse){
        String strResTranId = objResponse.transactionId;
        String paymentTransactionMode = objResponse.modeOfPayment;
        string strPaymentTrackId = objResponse.merchantId;
        String strPaymentId = objResponse.BankTXNId;
        String strResResult = objResponse.status;
        String strErrorText = objResponse.responseDescription;
        String strErrorCode = objResponse.responseCode;
        String strPaymentType =objResponse.udf1;
        String detailedGatewayResponse = objResponse.status; //Added by Sanket 13-Oct-2015
        //String PaymentSelectionOption // it can be Creadit card,Debit card ,Net Banking
        String additionalResult = objResponse.udf2; // Added by shubhranshu on 06/09/2021 to avoid Payment gateway error
        // String currencyOfPayment,
        Decimal feeCharges = objResponse.feeChrages;
        Decimal tax = objResponse.tax;
        //--------- List of payments to insert in System -------------
        list<nm_Payment_Initiated__c> lstPaymentToUpdate = new list<nm_Payment_Initiated__c>();
        Date admissionTranscationDate = null;
        system.debug('-----------strPaymentTrackId------------'+strPaymentTrackId);
        system.debug('AEPId -->' + AEPId);
        
        lstPaymentToUpdate = [Select Id, nm_PaymentStatus__c,nm_PaymentType__c,payment_Transaction_Mode__c,nm_Amount__c,nm_ActualPaymentAmmount__c, nm_Lead__c,nm_PaymentGatewayName__c , nm_ModeOfPayment__c, nm_TransactionDate__c, nm_TransactionID__c, nm_Merchant_Track_Id__c, Online_Payment_Id__c, nm_PaymentGatewayResponse__c, Online_Response_Error__c, nm_Error_Code__c from nm_Payment_Initiated__c where nm_Merchant_Track_Id__c =: strPaymentTrackId];
        
        system.debug('-----------lstPaymentToUpdate------------'+lstPaymentToUpdate);
        
        for(nm_Payment_Initiated__c objpay : lstPaymentToUpdate)
        {
            objpay.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
            objpay.nm_TransactionID__c = strResTranId;
            objpay.payment_Transaction_Mode__c = paymentTransactionMode;
            objpay.Online_Payment_Id__c = strPaymentId;
            objpay.nm_PaymentGatewayResponse__c = strResResult;
            objpay.Online_Response_Error__c = strErrorText;
            objpay.nm_Error_Code__c=strErrorCode;
            objpay.Gateway_Detailed_Response__c = detailedGatewayResponse;//Added by Sanket 13-Oct-2015
            if('Admission'.equalsIgnoreCase(objpay.nm_PaymentType__c)) // checking Admission Trans Date for Inserting Late Fee Product
            {
                admissionTranscationDate = objpay.nm_TransactionDate__c;
            }
        }
        
        if(lstPaymentToUpdate.size() > 0 )
        {
            update lstPaymentToUpdate;
        }
        
        list<nm_Payment__c> lstPaymentToInsert = new list<nm_Payment__c>();
        nm_Payment__c objPayment = new nm_Payment__c();
        objPayment.nm_PaymentStatus__c = strResResult.toUpperCase() == 'CAPTURED' ? 'Payment Made' : 'Transaction Failed';
        if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPayment.AEP__c = AEPId;
            system.debug('AEPId -->' + AEPId);
            
            //objPayment.nm_Lead__c = null;
        }else if(AEPISPId != '' && AEPISPId != null && AEPISPId != 'NA'){
            System.debug('AEPISPId -->'+AEPISPId);
            objPayment.AEP_site_inspection__c = AEPISPId;
        }
       
        
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_TransactionDate__c =lstPaymentToUpdate.size()>0 ? lstPaymentToUpdate[0].nm_TransactionDate__c : Date.today(); // making Payment Initation Created Date As Transction Date for Payment Record
        objPayment.nm_TransactionID__c = strResTranId;
        objPayment.payment_Transaction_Mode__c = paymentTransactionMode;
        objPayment.nm_PaymentGatewayName__c =lstPaymentToUpdate[0].nm_PaymentGatewayName__c ;
        objPayment.nm_Merchant_Track_Id__c = strPaymentTrackId;
        objPayment.Online_Payment_Id__c = strPaymentId;
        objPayment.nm_PaymentGatewayResponse__c = strResResult;
        objPayment.Online_Response_Error__c = strErrorText;
        objPayment.nm_Error_Code__c=strErrorCode;
        objPayment.Fee_Charges__c = feeCharges;
        objPayment.Tax__c = tax;
        objPayment.Payment_Gateway_Version__c = objResponse.gatewayVersion;
        objPayment.Transaction_DateTime__c = objResponse.transactionDateTime;
        // if(currencyOfPayment == 'USD') {
        //     objPayment.CurrencyIsoCode = currencyOfPayment;
        // }
        paymentFor = strPaymentType.split('_')[0];
        System.debug('Product Keys -->'+mapOfProductAndAmount.keySet());
        system.debug('mapOfProductAndAmount.get(paymentFor)--->'+mapOfProductAndAmount.get(paymentFor));
        Decimal discountedPrice = 0.0;
        if(String.isNotBlank(paymentFor) && (paymentFor == 'UG And PG License Fee' || paymentFor == 'MS License Fee')){
            List<nm_Payment__c> lstPay = [SELECT Id,nm_Amount__c,nm_PaymentType__c,nm_PaymentStatus__c from nm_Payment__c Where AEP_site_inspection__c=:AEPISPId and (nm_PaymentType__c = 'MS License Fee' or nm_PaymentType__c = 'UG And PG License Fee') and (nm_PaymentStatus__c = 'Payment Approved' or nm_PaymentStatus__c = 'Payment Made')];
            if(lstPay.size()>0){
                discountedPrice = mapOfProductAndAmount.get(paymentFor) - (mapOfProductAndAmount.get(paymentFor) * 0.2);
            }
        } 

        if(String.isNotBlank(paymentFor)){
            System.debug('paymentFor '+paymentFor);
            if(paymentFor.contains('Application And')) {
                mapOfProductAndAmount.put(paymentFor, (mapOfProductAndAmount.get('Application Fee') + mapOfProductAndAmount.get(paymentFor.substringAfter('Application And '))).setScale(2));
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, 'Application Fee', mapOfProductAndAmount.get('Application Fee'),mapOfProductAndAmount.get(paymentFor), 'Application Fee' ,paymentFor) );
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, paymentFor.substringAfter('Application And '), mapOfProductAndAmount.get(paymentFor.substringAfter('Application And ')).setScale(2),mapOfProductAndAmount.get(paymentFor), paymentFor.substringAfter('Application And ') ,paymentFor) );
            } else if(paymentFor != 'Late Fees'){
                lstPaymentToInsert.add( CreatePaymentRecord( objPayment, paymentFor, mapOfProductAndAmount.get(paymentFor),mapOfProductAndAmount.get(paymentFor), paymentFor ,paymentFor) );
            }
        }
        
         String firstPaymentRecordId = '';
        try{
            //----Inserting Payment records------//
            if( lstPaymentToInsert.size() > 0 ){
                //avoid multiple payment records being created for same merchant ID, for Browser back button press 
                firstPaymentRecordId = upsertPaymentRecordsBasedOnMerchantNumber(lstPaymentToInsert);
            }
            return firstPaymentRecordId;
        }catch(Exception e){
            return 'Failed to insert data in system :: Sumit ::' + string.valueof(e); 
        }
    }
    
    // update Payment records based upon Merchant Ref No
    public String upsertPaymentRecordsBasedOnMerchantNumber(list<nm_Payment__c> lstPaymentToInsert){
        System.debug('Method Of upsertPaymentRecordsBasedOnMerchantNumber called --->'+lstPaymentToInsert);
        list<nm_Payment__c> insertList = new List<nm_Payment__c>();
        list<nm_Payment__c> updateList = new List<nm_Payment__c>();
        boolean AEPlicensePayment = false ;
        String firstPaymentRecordId = '';
        Boolean AEPMerchendisePayment = false;
        
        Set<String> merchantRefNumberIds = new Set<String>();
        for(nm_Payment__c payment : lstPaymentToInsert){
            merchantRefNumberIds.add(payment.nm_Merchant_Track_Id__c);
            
        }
        
        Map<String, Id> merchantIdRecordIdMap = new Map<String, ID>();
        list<nm_Payment__c> existingPayments = [Select id, nm_Merchant_Track_Id__c, nm_TransactionID__c from nm_Payment__c where nm_Merchant_Track_Id__c in :merchantRefNumberIds];
        if(existingPayments != null ){
            for(nm_Payment__c payment : existingPayments){
                merchantIdRecordIdMap.put(payment.nm_Merchant_Track_Id__c, payment.ID);
            }
        }
        
        for(nm_Payment__c payment : lstPaymentToInsert){
            String key = payment.nm_Merchant_Track_Id__c;
            if(merchantIdRecordIdMap.containsKey(key)){
                //Payment Record already exists with given Merchant Track Id  
                ID id = merchantIdRecordIdMap.get(key);
                payment.ID = id;
                updateList.add(payment);
            }else{
                //New Record
                insertList.add(payment);
            }
        }
        
        if(insertList.size() > 0 ){
            System.debug('Adding new Payment record');
            insert insertList;
            system.debug('insertList --> ' + insertList);
            firstPaymentRecordId = insertList[0].Id;
        }
        
        if(updateList.size() > 0 ){
            System.debug('Updating existing Payment record');
            update updateList;
            firstPaymentRecordId = updateList[0].Id;
        }
        
        return firstPaymentRecordId;
    }
    
     // Create Online Pyament Record in system
    public nm_Payment__c CreatePaymentRecord( nm_Payment__c objPayment, String PaymentType, decimal Amount, decimal paymentForAmount,String feesType ,String InstallmentRef){
        nm_Payment__c objPay =  new nm_Payment__c();
        System.debug('objPayment  ->'+objPayment);
        objPay = objPayment.clone();
        paymentForAmount = paymentForAmount!=null ? paymentForAmount : 0;
        objPay.nm_PaymentType__c = PaymentType;
        system.debug('paymentForAmount -->'+paymentForAmount );
        objPay.nm_ActualPaymentAmmount__c = paymentForAmount;
        objPay.nm_Amount__c = Amount;
        objPay.nm_Installment_Payment_Ref__c = InstallmentRef;
        objPay.nm_Fee_Type__c = PaymentType;
   
        if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPay.AEP__c = AEPId;

        }else if(AEPId !='' && AEPId !=null && AEPId !='NA'){
            objPay.AEP__c = AEPId;
           
        }else if(AEPISPId != '' && AEPISPId != null && AEPISPId != 'NA'){
            objPay.AEP_site_inspection__c = AEPISPId;    
        }

        return objPay;
    }

    public void updateOpportunityFeesType(String updateRecordId){
        Opportunity objOpportunity = new Opportunity(id=updateRecordId);
        objOpportunity.Coursera__c = true;
        update objOpportunity;
        System.debug('objOpportunity----'+objOpportunity);
    }
   
    public class PaymentRequestParams {
        public String strPaymentType {get;set;}
        public String strTranTrackid {get;set;}
        public String msg {get;set;}
        public String orderId {get;set;}
        public String paymentCurrency {get;set;}
        public String udf1 {get;set;}
        public String udf2 {get;set;}
        public String udf3 {get;set;}
        public String paymentGatewayVersion {get;set;}
        public PaymentRequestParams() {
            this.strPaymentType = null;
            this.strTranTrackid = null;
            this.msg = null;
            this.orderId = null;
            this.paymentCurrency = 'INR';
            this.udf1 = null;
            this.udf2 = null;
            this.udf3 = null;
            this.paymentGatewayVersion = null;
        }
    }
    
    
    // method not in use
    public String MakeAdditionalChargePaymentAfterResponse(
        string strResTranId, 
        string strPaymentTrackId,
        String strPaymentId, 
        String strResResult, 
        String strErrorText,
        String strErrorCode,
        String strPaymentType,
        String detailedGatewayResponse,
        String detailedGatewayResponse1,
        String detailedGatewayResponse2
    ){
        return null;
    }
}