/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-09-2022
 * @last modified by  : @BK
**/
@isTest(seeAllData=false)
public class nmICICIPayResponseTracker {
    private class RestMockOrder implements HttpCalloutMock {
        public String orderId = '';
        public String orderToken = '';
        public String recordId = '';
        RestMockOrder() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"cf_order_id":1553338,"order_id":"'+orderId+'","entity":"order","order_currency":"INR","order_amount":10.12,"order_status":"PAID","order_token":"'+orderToken+'","order_tags":{"udf1":"Registration_'+recordId+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null","udf2":"False_No_null_false"},"order_expiry_time":"2021-07-29T05:30:00+05:30","payment_link":"https://payments-test.cashfree.com/order#123bhd816dfb1","payments":{"url":"www.google.com"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockPayment implements HttpCalloutMock {
        RestMockPayment() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[{"cf_payment_id":12376123,"order_id":"order_8123","entity":"payment","payment_currency":"INR","order_amount":10.01,"is_captured":true,"payment_group":"upi","authorization":null,"payment_method":{"upi":{"channel":"collect","upi_id":"rohit@icici"}},"payment_amount":10.01,"payment_time":"2021-07-23T12:15:06+05:30","payment_completion_time":"2021-07-23T12:18:59+05:30","payment_status":"SUCCESS","payment_message":"Transaction successful","bank_reference":"P78112898712","auth_id":"A898101"}]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMockOrder());
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

        
        nmGenericTracker.CreatePaymentInitRecords(objReferral.id,'Seminar Fee','Referral__c','2015101253010098');
        nmGenericTracker.CreatePGDiplomaProgram();
    }

    @isTest 
    static void testUnit1() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c from Lead limit 1];
        RestMockOrder rest = new RestMockOrder();
        rest.orderId = '5444563';
        rest.orderToken = '5444563';
        rest.recordId = objLead.id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('order_id','5444563');
            ApexPages.currentPage().getParameters().Put('order_token','5444563');
            nmICICIPayResponse obj = new nmICICIPayResponse();
            obj.StorePaymentInSystem();
        Test.stopTest();
    }

    @isTest 
    static void testUnit2() {
        RestMockPayment rest = new RestMockPayment();
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('order_id','5444563');
            ApexPages.currentPage().getParameters().Put('order_token','5444563');
            nmICICIPayResponse obj = new nmICICIPayResponse();
            obj.fetchPayment('www.ggogle.com');
        Test.stopTest();
    }
    
}