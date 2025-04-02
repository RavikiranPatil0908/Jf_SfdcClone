/**
 * @File Name          : nmPaytmPayResponse_Test.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 23-03-2023
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    30/3/2019, 1:24:40 PM   Balakrishnan     Initial Version
**/
@isTest(SeeAllData=false)
public class nmPayResponseNewTracker
{
    static nmPayResponseNew instance = null;
    static String recordId = 'NA';
    static String orderId = '2015101253010087';
    static String orderId2 = '2015101253010090';
    static String orderId3 = '2015101253010093';   
    static String orderId4 = '2015101253010098';   

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

    /**
    * @description setup data.
    * @author Bala | 3/4/2019
    * @return void
    */
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
         CreatePaymentInitRecords(objvalid.id,'Validity Extension Fee','Validity_Extension__c',orderId3);
       
        //form COnfiguration
        createPaymentFOrmConfiguration('Certificate Programs','Admission','1');//lead registration
        createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Admission','1');//account registration
        createPaymentFOrmConfiguration('Post Graduate Diploma Programs','Re-Registration','1');//account reregistration
        
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
        
        createProductAndPricebookEntry('Registration Fee',null,null,priceBooke2Id);
        //Lead Product Sem1
        createProductAndPricebookEntry('Semester','1',objLead.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Semester','1',objOpp.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Semester','2',objLead.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Semester','2',objOpp.nm_Program__c,priceBooke2Id);
        createProductAndPricebookEntry('Certificate_Annual',null,null,priceBooke2Id);
        nmGenericTracker.CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
        nmGenericTracker.CreateElegibilityCriteria();
        nmGenericTracker.CreateCalender();
        nmGenericTracker.createLateFeeRecord('Is Lateral','Certificate Programs');

        CreatePaymentInitRecords(objLead.id,'Registration','Lead',orderId);
        CreatePaymentInitRecords(objopp.id,'Admission','Opportunity',orderId2);
        

        nm_Payment__c PaymentRecord = new nm_Payment__c();
        PaymentRecord.nm_PaymentType__c = 'Additional Charge';
        PaymentRecord.nm_PaymentStatus__c = 'Pending Extra Fees';
        PaymentRecord.nm_OpportunityNew__c = objopp.id;
        PaymentRecord.nm_Merchant_Track_Id__c = orderId;
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

        
        CreatePaymentInitRecords(objReferral.id,'Seminar Fee','Referral__c',orderId4);
         nmGenericTracker.CreatePGDiplomaProgram();
        
    }

  /**
  * @description
  * @author Bala | 3/4/2019
  * @return testmethod
  */
  static testmethod void testUnit1() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c,nm_Session__c,nm_Year__c from Lead limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        recordId = objLead.id;
    
      
        Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0300|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
        nmPayResponseNew Controller = new nmPayResponseNew();
        Controller.StorePaymentInSystem();

    Test.stopTest();
  }

  static testmethod void testUnitErrorCode1() {
    Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c from Lead limit 1];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    recordId = objLead.id;

  
   Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|NA|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
    nmPayResponseNew Controller = new nmPayResponseNew();
    Controller.StorePaymentInSystem();

Test.stopTest();
}

static testmethod void testUnitErrorCode2() {
    Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c from Lead limit 1];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    recordId = objLead.id;

  
   Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0002|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
    nmPayResponseNew Controller = new nmPayResponseNew();
    Controller.StorePaymentInSystem();

Test.stopTest();
}

static testmethod void testUnitErrorCode3() {
    Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c,nm_Session__c,nm_Year__c from Lead limit 1];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    recordId = objLead.id;

  
   Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0001|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false_cs_1SemLecturesFee_null|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
    nmPayResponseNew Controller = new nmPayResponseNew();
    Controller.StorePaymentInSystem();

Test.stopTest();
}

static testmethod void testUnitErrorCode4() {
    Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c from Lead limit 1];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    recordId = objLead.id;

  
   Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0399|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
    nmPayResponseNew Controller = new nmPayResponseNew();
    Controller.StorePaymentInSystem();

Test.stopTest();
}

static testmethod void testUnitErrorCode5() {
    Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c from Lead limit 1];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    recordId = objLead.id;

  
   Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0004|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
    nmPayResponseNew Controller = new nmPayResponseNew();
    Controller.StorePaymentInSystem();

Test.stopTest();
}

  static testmethod void testUnit2() {
    Opportunity objOpp = [select id,nm_Program__c,AccountId,nm_StudentProgram__c,nm_Semester__c ,nm_Session__c,nm_Year__c from Opportunity limit 1];
    Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c ,nm_Session__c,nm_Year__c from Lead limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        recordId = objOpp.id;
        System.debug('recordId  -->'+recordId);
  
      
      Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId2+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0300|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objOpp.id+'_0_PostPaymentPage_false_NA_false_1SemLecturesFee_null|'+objOpp.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
        nmPayResponseNew Controller = new nmPayResponseNew();
        Controller.StorePaymentInSystem();
    Test.stopTest();
  }
 
    static testmethod void testUnit23() {
        Validity_Extension__c objvalid =[select id from Validity_Extension__c limit 1];
        Account objAccount =[select id from account limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objAccount.id;
            System.debug('recordId  -->'+recordId);
            Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId3+'|PCMP7113789629|864863-003452|8500.00|CMP|534680|03|INR|MDDIRECT|02-NA|NA|00000000.00|16-01-2019 19:18:17|0300|NA|shehzad.kalmadi@gmail.com|9820304029|Validity Extension Fee_'+objAccount.id+'_0_PostPaymentPage_false|'+objAccount.id+'|8500.00|NA|cs_1SemLecturesFee_null_false|NA|PGS10001-Success|8B4BA186DA161DE22F67B4C0B52095FBC22E03A860929192C0EECD0C01587897');
            nmPayResponseNew Controller = new nmPayResponseNew();
            Controller.StorePaymentInSystem();
        Test.StopTest();
    }
  
   static testmethod void testUnitWebinar() {
       
        Referral__c objReferral =[select id from Referral__c limit 1 ];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        recordId = objReferral.id;

        Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId4+'|PCMP7113789629|864863-003452|8500.00|CMP|534680|03|INR|MDDIRECT|02-NA|NA|00000000.00|16-01-2019 19:18:17|0300|NA|shehzad.kalmadi@gmail.com|9820304029|Seminar Fee_'+objReferral.id+'_0_PostPaymentPage_false|'+objReferral.id+'|8500.00|NA|cs_1SemLecturesFee_null_false|NA|PGS10001-Success|8B4BA186DA161DE22F67B4C0B52095FBC22E03A860929192C0EECD0C01587897');
        nmPayResponseNew Controller = new nmPayResponseNew();
        Controller.StorePaymentInSystem();
        Test.StopTest();
   }

   static testmethod void testUnit4() {
        Lead objLead = [select id,nm_Program__c,nm_EligiblityCriteria__c,nm_Session__c,nm_Year__c from Lead limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            recordId = objLead.id;

        
            Apexpages.currentpage().getparameters().put('msg','NMIMS|'+orderId+'|PSBI7222846479|IGAFKWEZJ9|00019300.00|SBI|NA|01|INR|DIRECT|NA|NA|0.00|16-02-2019 13:44:43|0300|NA|manpreet.ss@halo.co.in|2011199500|Admission_'+objLead.id+'_0_PostPaymentPage_false_NA_cs_false|'+objLead.id+'|19300.00|NA|cs_1SemLecturesFee_null_false|NA|Completed successfully.|46248D3D0BFC3B4765237FF8E11B4A12133867DBEA4F39DBFBE294576B16A299');
            Apexpages.currentpage().getparameters().put('skipcheck','true');
            nmPayResponseNew Controller = new nmPayResponseNew();
            Controller.StorePaymentInSystem();

        Test.stopTest();
    }
    
    public static PriceBookEntry createProductAndPricebookEntry(String productName , String semester , String program ,String priceBook2Id){
        Product2 product = new Product2();
        product.Name = productName;
        product.nm_Program__c = program;
        product.nm_Semester__c = semester;
        product.isActive = true;
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert standardPriceBookEntry;
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = priceBook2Id, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert objPriceBookEntry;
        return objPriceBookEntry;
    }
    
    public static nm_Payment__c CreatePaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef){
        nm_Payment__c objPayment = new nm_Payment__c ();
        if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.nm_OpportunityNew__c = recordId;
        }else{
            objPayment.nm_Lead__c  = recordId;
        }
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Payment Made';
        objPayment.nm_PaymentGatewayName__c ='Bill Desk';
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        objPayment.nm_Installment_Payment_Ref__c = installmentRef;
        insert objPayment;
        return objPayment;
    }
     public static nm_Payment_Initiated__c CreatePaymentInitRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String orderid)
     {
         nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c ();
          if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.nm_OpportunityNew__c = recordId;
        }else if ('Lead'.equalsIgnoreCase(SObjectAPIName)) {
            objPayment.nm_Lead__c  = recordId;
        }else if('Referral__c'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.Seminar__c = recordId;
        }else if('Validity_Extension__c'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.Validity_Extension__c = recordId;
        }
        objPayment.nm_Merchant_Track_Id__c = orderid;
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Payment Made';
        objPayment.nm_PaymentGatewayName__c ='Bill Desk';
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment;
        return objPayment;
     }
    public static NM_Payment_Form_Configuration__c  createPaymentFOrmConfiguration(String programCategory,String programType,String semester){
        NM_Payment_Form_Configuration__c objpaymentconfig = new NM_Payment_Form_Configuration__c();
        objpaymentconfig.Program_Category__c = programCategory;
        objpaymentconfig.Payment_Type__c =programType;
        objpaymentconfig.Semester__c= semester;
        objpaymentconfig.Current_Admission_Year__c = '2019';
        objpaymentconfig.No_Of_Applicable_Installment__c ='1';
        objpaymentconfig.Registration_Fee__c=1200;
        objpaymentconfig.Program_Type__c='';
        objpaymentconfig.Reg_No_Allowed_After_End_Date__c = '01723456';
        objpaymentconfig.Capital_Float_AEP_Available__c = 'Mumbai,Pune';
        objpaymentconfig.Show_Registration_Payment_Option__c = true;
        objpaymentconfig.Show_Admission_Payment_Option__c = true;
        objpaymentconfig.Payment_Window_EndDate__c = System.now().addDays(-1);
        objpaymentconfig.Registration_Fee__c = 12000;
        objpaymentconfig.Is_Late_Fee_Applicable__c = true;
        insert objpaymentconfig;
        return objpaymentconfig;
    }

}