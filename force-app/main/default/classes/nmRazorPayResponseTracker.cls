/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-09-2022
 * @last modified by  : @BK
**/
@isTest(seeAllData=false)
public class nmRazorPayResponseTracker {

    private class RestMock implements HttpCalloutMock {
        public String udf1 = '';
        public String udf2 = '';
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"entity":"collection","count":1,"type":"credit","items":[{"id":"5454878787","entity":"payment","amount":100,"currency":"INR","status":"captured","order_id":"1234","invoice_id":null,"international":false,"method":"card","amount_refunded":0,"refund_status":null,"captured":true,"description":"","card_id":"card_Be7AhhLtm1gxzc","bank":null,"wallet":null,"vpa":null,"email":"gaurav.kumar@example.com","contact":"+919999999999","customer_id":"cust_Be6N4O63pXzmqK","token_id":"token_BhNxzjrZvkqLWr","notes":{"udf1": "'+udf1+'","udf2": "'+udf2+'"},"fee":0,"tax":0,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"auth_code":null},"created_at":1655212834}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
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
        
        RestMock rest = new RestMock();
        rest.udf1 = 'Registration_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null_false';
        rest.udf2 = 'False_No_null';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('razorpay_order_id','1234');
            ApexPages.currentPage().getParameters().Put('razorpay_payment_id','5454878787');
            ApexPages.currentPage().getParameters().Put('error[code]','test');
            nmRazorPayResponse obj=new nmRazorPayResponse();
            obj.StorePaymentInSystem();
        Test.stopTest();
    }

    @isTest 
    static void testUnit5() {
        Referral__c objReferral = [select id from Referral__c limit 1];
        RestMock rest = new RestMock();
        rest.udf1 = 'Seminar Fee_'+objReferral.id+'_0_PostPaymentPage_false_NA_false';
        rest.udf2 = 'False_No_null';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('razorpay_order_id','1234');
            ApexPages.currentPage().getParameters().Put('razorpay_payment_id','5454878787');
            ApexPages.currentPage().getParameters().Put('error[code]','test');

            nmRazorPayResponse obj=new nmRazorPayResponse();
            obj.StorePaymentInSystem();
        Test.stopTest();
    }
    @isTest
    static void testUnit6() {
        Opportunity objOpp = [select id,nm_Program__c,AccountId,nm_StudentProgram__c,nm_Semester__c  from Opportunity limit 1];
        RestMock rest = new RestMock();
        rest.udf1 = 'Additional Charge_'+objOpp.id+'_0_PostPaymentPage_true_'+objOpp.id;
        rest.udf2 = 'False_No_null';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('razorpay_order_id','1234');
            ApexPages.currentPage().getParameters().Put('razorpay_payment_id','5454878787');
            ApexPages.currentPage().getParameters().Put('error[code]','test');
            nmRazorPayResponse obj=new nmRazorPayResponse();
            obj.StorePaymentInSystem();
        Test.stopTest();
    }

    @isTest
    static void testUnit7() {
        Opportunity objOpp = [select id,nm_Program__c,AccountId,nm_StudentProgram__c,nm_Semester__c  from Opportunity limit 1];
        RestMock rest = new RestMock();
        rest.udf1 = 'Additional Charge_'+objOpp.id+'_0_PostPaymentPage_true_'+objOpp.id;
        rest.udf2 = 'False_No_null';
        List<nm_Payment_Initiated__c> lst = [SELECT id,Additional_param1__c,Additional_param2__c,OrderId__c,nm_Merchant_Track_Id__c FROM nm_Payment_Initiated__c LIMIT 1];
        lst[0].Additional_param1__c = rest.udf1;
        lst[0].Additional_param2__c = rest.udf2;
        lst[0].OrderId__c = '1234';
        lst[0].nm_Merchant_Track_Id__c = '1234';
        update lst;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, rest);
            ApexPages.currentPage().getParameters().Put('razorpay_order_id','1234');
            ApexPages.currentPage().getParameters().Put('razorpay_payment_id','5454878787');
            ApexPages.currentPage().getParameters().Put('error[code]','PAYMENT_FAILED');
            nmRazorPayResponse obj=new nmRazorPayResponse();
            obj.StorePaymentInSystem();
        Test.stopTest();
    }

}