/**
 * @File Name          : nmHDFCPayResponseTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 05-31-2022
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    26/9/2019   @BK     Initial Version
**/
@isTest(seeAllData=false)
public class nmHDFCPayResponseTracker{
    
     private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
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
    static testmethod void testUnit1() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c  from Lead limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // recordId = objLead.id;

        ApexPages.currentPage().getParameters().put('mihpayid','1234');
        ApexPages.currentPage().getParameters().put('txnid','5444563');
        ApexPages.currentPage().getParameters().put('Amount','1200');
        ApexPages.currentPage().getParameters().put('Error','Invalid Autentication');
        ApexPages.currentPage().getParameters().put('status','Success');
        ApexPages.currentPage().getParameters().put('Productinfo','0');
        ApexPages.currentPage().getParameters().put('bank_ref_num','5454878787');
        ApexPages.currentPage().getParameters().Put('udf1','Registration_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null');
        ApexPages.currentPage().getParameters().Put('udf2','False_No_null_false');
        nmHDFCPayResponse obj=new nmHDFCPayResponse();
       obj.StorePaymentInSystem();


        Test.stopTest();
  }
   static testmethod void testUnit2() {
        Validity_Extension__c objvalid =[select id from Validity_Extension__c limit 1];
        Account objAccount =[select id from account limit 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());

       ApexPages.currentPage().getParameters().put('mihpayid','1234');
       ApexPages.currentPage().getParameters().put('txnid','5444563');
       ApexPages.currentPage().getParameters().put('Amount','18000');
       ApexPages.currentPage().getParameters().put('Error','Invalid Autentication');
       ApexPages.currentPage().getParameters().put('status','Success');
       ApexPages.currentPage().getParameters().put('Productinfo','0');
       ApexPages.currentPage().getParameters().put('bank_ref_num','5454878787');
       ApexPages.currentPage().getParameters().Put('udf1','Validity Extension Fee-'+objAccount.id+'-NA');
       ApexPages.currentPage().getParameters().Put('udf2','False_No_null_false');
       nmHDFCPayResponse obj=new nmHDFCPayResponse();
      obj.StorePaymentInSystem();

        Test.stopTest();
  }
  static testmethod void testUnit3() {
       // Validity_Extension__c objvalid =[select id from Validity_Extension__c limit 1];
        Account objAccount =[select id from account limit 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());

       ApexPages.currentPage().getParameters().put('mihpayid','1234');
       ApexPages.currentPage().getParameters().put('txnid','5444563');
       ApexPages.currentPage().getParameters().put('Amount','18000');
       ApexPages.currentPage().getParameters().put('Error','Invalid Autentication');
       ApexPages.currentPage().getParameters().put('status','Success');
       ApexPages.currentPage().getParameters().put('Productinfo','0');
       ApexPages.currentPage().getParameters().put('bank_ref_num','5454878787');
       ApexPages.currentPage().getParameters().Put('udf1',objAccount.id+'_2_'+'AdmissionLateFees');
       ApexPages.currentPage().getParameters().Put('udf2','False_No_null_false');
       nmHDFCPayResponse obj=new nmHDFCPayResponse();
      obj.StorePaymentInSystem();

        Test.stopTest();
  }
  static testmethod void testUnit4() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c from Lead limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // recordId = objLead.id;

        ApexPages.currentPage().getParameters().put('mihpayid','1234');
        ApexPages.currentPage().getParameters().put('txnid','5444563');
        ApexPages.currentPage().getParameters().put('Amount','18000');
        ApexPages.currentPage().getParameters().put('Error','Invalid Autentication');
        ApexPages.currentPage().getParameters().put('status','Success');
        ApexPages.currentPage().getParameters().put('Productinfo','0');
        ApexPages.currentPage().getParameters().put('bank_ref_num','5454878787');
        ApexPages.currentPage().getParameters().Put('udf1','Installment-'+objLead.id+'-'+'NA'+'-NA'+'-1000');
        ApexPages.currentPage().getParameters().Put('udf2','False_No_null_false');
        nmHDFCPayResponse obj=new nmHDFCPayResponse();
       obj.StorePaymentInSystem();


        Test.stopTest();
  }
    static testmethod void testUnit5() {
        Referral__c objReferral = [select id from Referral__c limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // recordId = objLead.id;

        ApexPages.currentPage().getParameters().put('mihpayid','1234');
        ApexPages.currentPage().getParameters().put('txnid','2015101253010098');
        ApexPages.currentPage().getParameters().put('Amount','18000');
        ApexPages.currentPage().getParameters().put('Error','Invalid Autentication');
        ApexPages.currentPage().getParameters().put('status','Success');
        ApexPages.currentPage().getParameters().put('Productinfo','0');
        ApexPages.currentPage().getParameters().put('bank_ref_num','5454878787');
        ApexPages.currentPage().getParameters().Put('udf1','Seminar Fee_'+objReferral.id+'_0_PostPaymentPage_false_NA_false');
        ApexPages.currentPage().getParameters().Put('udf2','False_No_null_false');
        nmHDFCPayResponse obj=new nmHDFCPayResponse();
       obj.StorePaymentInSystem();


        Test.stopTest();
  }
  static testmethod void testUnit6() {
       Opportunity objOpp = [select id,nm_Program__c,AccountId,nm_StudentProgram__c,nm_Semester__c,nm_Session__c,nm_Year__c  from Opportunity limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // recordId = objLead.id;

        ApexPages.currentPage().getParameters().put('mihpayid','1234');
        ApexPages.currentPage().getParameters().put('txnid','2015101253010090');
        ApexPages.currentPage().getParameters().put('Amount','18000');
        ApexPages.currentPage().getParameters().put('Error','Invalid Autentication');
        ApexPages.currentPage().getParameters().put('status','Success');
        ApexPages.currentPage().getParameters().put('Productinfo','0');
        ApexPages.currentPage().getParameters().put('bank_ref_num','5454878787');
        ApexPages.currentPage().getParameters().Put('udf1','Additional Charge_'+objOpp.id+'_0_PostPaymentPage_true_'+objOpp.id);
        ApexPages.currentPage().getParameters().Put('udf2','False_No_null_false');
        nmHDFCPayResponse obj=new nmHDFCPayResponse();
        //obj.
       obj.StorePaymentInSystem();


        Test.stopTest();
  }
    
}