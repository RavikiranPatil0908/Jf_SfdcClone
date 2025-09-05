/**
 * @File Name          : cancelStudentHelperClassTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Shailesh
 * @Last Modified On   : 24-07-2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/17/2019   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public without sharing class cancelStudentHelperClassTracker {
    private class RestMock implements HttpCalloutMock {
        RestMock() { }
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
        //nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Admission','Lead','Admission');
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        update objAccount;
        
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);

        nmRefund_Payment__c ref = new nmRefund_Payment__c();
        ref.Status__c = 'Refund Request Created';
        ref.Additional_Deduction__c = 0;
        ref.Type_of_Refund__c = 'Admission Cancellation';
        ref.Account__c = objAccount.Id;
        ref.Opportunity__c = objopp.Id;
        insert ref;
        objopp.Processed__c = true;
        update objopp;
        nm_Payment__c objPayment = CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
        nm_Payment__c objPayment1 = CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
        objPayment1.nm_PaymentType__c = 'Initial Payment';
        //update objPayment1;
        nm_Payment__c objPayment2 = CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
        nm_Payment__c objPayment3 = CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
        nm_Payment__c objPayment4 = CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
        objPayment2.nm_PaymentType__c = 'Avanse-DownPayment';
        objPayment3.nm_PaymentType__c = 'Additional Charge';
        objPayment4.nm_PaymentType__c = 'Installment';
        List<nm_Payment__c> lstpayment = new List<nm_Payment__c>();
        lstpayment.add(objPayment);
        lstpayment.add(objPayment1);
        lstpayment.add(objPayment2);
        lstpayment.add(objPayment3);
        lstpayment.add(objPayment4);
        insert lstpayment;

    }
     /**
     * @description 
     * @author shubhranshu | 9/14/2019 
     * @return testMethod 
     **/
    static testMethod void testintializaCancelAdmissionProcess(){
         
       Account oldAcc = [select Id , Interview_Status__c,nm_StudentStatus__c ,InActiveTrigger__c from Account limit 1];
       Account acc = [select Id , nm_StudentStatus__c , InActiveTrigger__c from Account limit 1];
       acc.nm_StudentStatus__c ='Admission Cancelled';
       acc.InActiveTrigger__c = false;
       update acc;

       List<Account> lstAcc = new List<Account>();
       lstAcc.add(oldAcc);
       Map<Id,Account> mapofAcc = new Map<Id,Account>();
       mapofAcc.put(acc.id, acc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       cancelStudentHeplerClass obj = new cancelStudentHeplerClass();
       obj.intializaCancelAdmissionProcess(lstAcc, mapofAcc);
       Test.stopTest();
    }
    static testMethod void testintializaCancelAdmissionProcess2(){
         
       Account oldAcc = [select Id , Interview_Status__c,nm_StudentStatus__c ,InActiveTrigger__c from Account limit 1];
       Account acc = [select Id , nm_StudentStatus__c , InActiveTrigger__c from Account limit 1];
       acc.nm_StudentStatus__c ='Admission Cancelled';
       acc.InActiveTrigger__c = false;
       update acc;
       List<Account> lstAcc = new List<Account>();
       lstAcc.add(oldAcc);
       Map<Id,Account> mapofAcc = new Map<Id,Account>();
       mapofAcc.put(acc.id, acc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       cancelStudentHeplerClass obj = new cancelStudentHeplerClass();
       obj.intializaCancelAdmissionProcess(lstAcc, mapofAcc);
       CancelFutureHandler.sendEmailToAepOnCancel('hjjkhjk', 'hjjh','testtee@fesf.com', '87585686564', 'test', 'testtee@fesf.com', 'testtee@fesf.com');
  
       Test.stopTest();

    //    CancelFutureHandler CancelFutureHandler = new CancelFutureHandler();
       
    }
    static testMethod void testrefundrecord(){
         List<Opportunity> objopp = [select Id ,name,Accountid,nm_InformationCenters__c,StageName from Opportunity];
        Test.setMock(HttpCalloutMock.class, new RestMock());
         Test.startTest();
         cancelStudentHeplerClass obj = new cancelStudentHeplerClass();
         obj.InsertRefundRecord(objopp[0] ,'online',5000,true,'Documents Incorrect',true,'abc111@mail.com',false,true);
         obj.updateOpportunityStage(objopp,'Registration Done','Documents Incorrect');
         Test.stopTest();
    }

    public static nm_Payment__c CreateAdmissionPaymentRecordForOpptyForApproved(Opportunity objOpps)
    {
        return CreatePaymentRecordForOpportunityApproved(objOpps,'Admission');
    }

    public static nm_Payment__c CreatePaymentRecordForOpportunityApproved(Opportunity objOpps,String TypeOfPayment)
    {
        nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.nm_OpportunityNew__c = objOpps.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_ActualPaymentAmmount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Approved';
        objPayment2.nm_PaymentType__c = TypeOfPayment;
        objPayment2.nm_Merchant_Track_Id__c = '1234';
        objPayment2.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
       // insert objPayment2;
        return  objPayment2;
    }
}