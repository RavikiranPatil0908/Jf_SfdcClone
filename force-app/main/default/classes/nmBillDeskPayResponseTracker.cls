@isTest(seeAllData=false)
public class nmBillDeskPayResponseTracker {
    private class RestMock implements HttpCalloutMock {
        public String orderId = '';
        public String recordId = '';
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String jBody = '{"payment_category":"01","payment_method_type":"netbanking","transaction_error_type":"success","transaction_error_desc":"Transaction Successful","transaction_error_code":"TRS0000","auth_status":"0300","itemcode":"DIRECT","bankid":"123","txn_process_type":"nb","ru":"https://ngasce--sandbox.sandbox.my.salesforce-sites.com/nmBillDeskPayResponse","additional_info":{"additional_info2":"false_No_null_false","additional_info1":"Admission_'+recordId+'_0_PostPaymentPage_false_NA"},"currency":"356","charge_amount":"28700.00","discount":"0.00","surcharge":"0.00","amount":"28700.00","transaction_date":"2023-07-29T17:50:46+05:30","mercid":"UATNMSV2","orderid":'+orderId+',"transactionid":"U1230001407446","objectid":"transaction"}';
            HTTPResponse res = new HTTPResponse();
            // res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(jBody);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    
        
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
       // objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        update objAccount;


        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);

        Validity_Extension__c  objvalid = nmGenericTracker.CreateValiditybasedonaccount(objAccount);
         nmGenericTracker.CreatePaymentInitRecords(objvalid.id,'Validity Extension Fee','Validity_Extension__c', '2015101253010093');
       
        //form COnfiguration
        nmGenericTracker.createPaymentFOrmConfiguration('Certificate Programs','Admission','1');//lead registration
        nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');//account registration
        nmGenericTracker.createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Re-Registration','1');//account reregistration
        
        //custom setting
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
        objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
        objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
        insert objSystemConfiguration;
        
        Id priceBooke2Id = [select id,pricebook2Id from Opportunity limit 1].pricebook2Id;
        
        nmGenericTracker.createProductAndPricebookEntry('Registration Fee',null,null,priceBooke2Id);
        //Lead Product Sem1
        nmGenericTracker.createProductAndPricebookEntry('Semester','1',objLead.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','1',objOpp.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','2',objLead.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Semester','2',objOpp.nm_Program__c,priceBooke2Id);
        nmGenericTracker.createProductAndPricebookEntry('Certificate_Annual',null,null,priceBooke2Id);
        nmGenericTracker.CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
        nmGenericTracker.CreateElegibilityCriteria();
        nmGenericTracker.CreateCalender();
        nmGenericTracker.createLateFeeRecord('Is Lateral','Certificate Programs');

        nmGenericTracker.CreatePaymentInitRecords(objLead.id,'Registration','Lead','5444563');
        nmGenericTracker.CreatePaymentInitRecords(objopp.id,'Admission','Opportunity','2015101253010090');
        

        nm_Payment__c PaymentRecord = new nm_Payment__c();
        PaymentRecord.nm_PaymentType__c = 'Additional Charge';
        PaymentRecord.nm_PaymentStatus__c = 'Pending Extra Fees';
        PaymentRecord.nm_OpportunityNew__c = objopp.id;
        PaymentRecord.nm_Merchant_Track_Id__c = '2015101253010087';
        PaymentRecord.nm_ActualPaymentAmmount__c = 100.12;
        PaymentRecord.nm_Amount__c = 100.12;
        insert PaymentRecord;

        String opportunityId = objopp.id;
        List<nm_Payment__c> lstPayment =[select id from nm_Payment__c where nm_OpportunityNew__c =:opportunityId and nm_PaymentType__c ='Additional Charge' and nm_PaymentStatus__c ='Pending Extra Fees'];
        System.debug('opportunityId --> '+lstPayment.size());
        
        Webinar__c objWebinar = new Webinar__c ();  
        objWebinar.Active__c =TRUE;
        objWebinar.Send_Confirmation_Mail__c =TRUE;
        objWebinar.Event_Date__c =system.today();
        objWebinar.Description__c ='thanks';
        objWebinar.Closure_Messge__c ='thanks';
        objWebinar.Duplicate_Message__c ='thanks';
        objWebinar.Thankyou_Message__c ='thanks';
        objWebinar.Logo__c ='NGA Logo';
        objWebinar.Content__c =' NGA Logo';
        objWebinar.Heading__c ='NGA Logo';
        objWebinar.Page_Title__c ='NGA Logo';
        objWebinar.End_Time__c =   Time.newInstance(1, 2, 3, 4);
        objWebinar.Start_Time__c =  Time.newInstance(4, 2, 3, 4);
      
        insert objWebinar;
        
        Referral__c objReferral = new Referral__c();
        objReferral.Name__c ='test';
        objReferral.Email__c = 'sandip@gmail.com';
        objReferral.Mobile_Number__c = '8565987568';
        objReferral.City__c = 'Mumbai';   
        objReferral.Webinar__c = objWebinar.id;     
        insert objReferral;

        
        nm_Payment_Initiated__c objPayIn = nmGenericTracker.CreatePaymentInitRecords(objReferral.id,'Seminar Fee','Referral__c','2015101253010098');
        objPayIn.nm_PaymentGatewayName__c = 'BillDesk GateWay';
        update objPayIn;
        nmGenericTracker.CreatePGDiplomaProgram();
    }

    @isTest 
    static void testUnit1() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        // RestMockOrder rest = new RestMockOrder();
        // rest.orderId = '5444563';
        // rest.orderToken = '5444563';
        // rest.recordId = objLead.id;
        String jsonBodyParam = '{ "objectid":"transaction", "mercid":"BDMERCID", "transaction_date":"2020-11-20T13:55:59+05:30", "surcharge":"2.00", "payment_method_type":"netbanking", "amount":"300.00", "ru":"https://example.com/pgresponse/modal/redirect", "orderid":"5444563", "transaction_error_type":"success", "discount":"0.00", "transactionid":"U1230000041968", "txn_process_type":"nb", "bankid":"123", "additional_info":{ "additional_info1":"Registration_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null", "additional_info2":"False_No_null_false"}, "itemcode":"DIRECT", "transaction_error_code":"TRS0000", "currency":"356", "auth_status":"0300", "transaction_error_desc":"Transaction Successful", "charge_amount":"302.00" }';
        String headerJWS = '{"alg":"HS256","clientid":"' + BilldeskV2.Client_ID__c + '"}';
        string jwt = base64URLencode(blob.valueof(headerJWS)) + '.' +base64URLencode(blob.valueof(jsonBodyParam));
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),blob.valueof(BilldeskV2.Secret_Key__c));
        Test.startTest();
            // Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('terminal_state','Y');
            ApexPages.currentPage().getParameters().Put('orderid','5444563');
            ApexPages.currentPage().getParameters().Put('transaction_response',jwt + '.' +base64URLencode(signature));
            nmBillDeskPayResponse obj = new nmBillDeskPayResponse();
            obj.StorePaymentInSystem();
        Test.stopTest();
    }
    
    @isTest 
    static void testUnit2() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        nm_Payment_Initiated__c objPyi = [SELECT Id FROM nm_Payment_Initiated__c WHERE nm_Merchant_Track_Id__c = '5444563'];
        objPyi.Additional_param1__c = 'Registration_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null';
        objPyi.Additional_param2__c = 'False_No_null_false';
        update objPyi;
        RestMock rest = new RestMock();
        rest.orderId = '5444563';
        rest.recordId = objLead.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('orderid','5444563');
            ApexPages.currentPage().getParameters().Put('TranTrackid','5444563');
            // ApexPages.currentPage().getParameters().Put('transaction_response','');
            nmBillDeskPayResponse obj = new nmBillDeskPayResponse();
            obj.StorePaymentInSystem();
            nmBillDeskHelper.getTransactionResponseFromAPI('5444563');
        Test.stopTest();
    }
    
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    @isTest
    static void testTrackBilldeskStausError(){
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        String jsonBodyParam = '{ "objectid":"transaction", "mercid":"BDMERCID", "transaction_date":"2020-11-20T13:55:59+05:30", "surcharge":"2.00", "payment_method_type":"netbanking", "amount":"300.00", "ru":"https://example.com/pgresponse/modal/redirect", "orderid":"2015101253010098", "transaction_error_type":"success", "discount":"0.00", "transactionid":"U1230000041968", "txn_process_type":"nb", "bankid":"123", "additional_info":{ "additional_info1":"Registration_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null", "additional_info2":"False_No_null_false"}, "itemcode":"DIRECT", "transaction_error_code":"TRS0000", "currency":"356", "auth_status":"0300", "transaction_error_desc":"Transaction Successful", "charge_amount":"302.00" }';
        String headerJWS = '{"alg":"HS256","clientid":"' + BilldeskV2.Client_ID__c + '"}';
        string jwt = base64URLencode(blob.valueof(headerJWS)) + '.' +base64URLencode(blob.valueof(jsonBodyParam));
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),blob.valueof(BilldeskV2.Secret_Key__c));
        Test.startTest();
        RequestData(jwt + '.' +base64URLencode(signature),'POST');
        BillDeskWebhookAPI.UpdatePaymentStatus();
        Test.stopTest();
    }

    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        system.debug(JSON.serialize('myJson --> ' + myJson));
        request.requestURI = System.Label.Site_Url+'services/apexrest/BillDeskWebhookAPI/V1.1/';
        request.httpMethod = requestMethod;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }

    
}