/**
 * @File Name          : cancelStudentHelperClassTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-07-2021
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

        nm_Payment__c objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
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
       Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id ];
       nmRefund_Payment__c ref = new nmRefund_Payment__c();
       ref.Status__c = 'Refund Request Created';
       ref.Additional_Deduction__c = 0;
       ref.Type_of_Refund__c = 'Admission Cancellation';
       ref.Account__c = acc.Id;
       ref.Opportunity__c = opp.Id;
       insert ref;
       opp.Processed__c = true;
       update opp;
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
}