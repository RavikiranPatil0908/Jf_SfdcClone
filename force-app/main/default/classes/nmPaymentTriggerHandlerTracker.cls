/**
 * @File Name          : nmPaymentTriggerHandlerTracker.cls
 * @Description        :
 * @Author             : @BK
 * @Group              :
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-01-2025
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author              Modification
 *==============================================================================
 * 1.0    15/7/2019, 12:57:34 PM   @BK     Initial Version
**/
@isTest
public class nmPaymentTriggerHandlerTracker{
    // private static nm_Payment__c objPayment;
    private static Opportunity objopp;
    private static Lead objLead;
    public static nm_Program__c program;
    public static Account objAccount;
    // public static  RecordType AccountRecordType  = [select id,Name from RecordType where SobjectType='Account' and name='Person Account'];
    public static User objUser;
    public static IC_Change_Request__c objIcChange;
    public static nm_Holidays__c objHoliday;
    public static nm_UserMapping__c objUserMap;
    private static nm_Centers__c   objcen;
    public static nm_StudentProgram__c objSP ;
    public static nm_EligiblityCriteria__c eligibility;
    public static nm_EligiblityCriteria__c  objEc;
    public static Late_Fee__c objLate;
    
   
    private class RestMock implements HttpCalloutMock {
        RestMock() {
           
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"status":"success"}';
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
        objCen= nmGenericTracker.CreateCenter('Mumbai');
        program = nmGenericTracker.CreatePGDiplomaProgram();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',true);
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',true,'Admission form & documents submitted');
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
        nmGenericTracker.CreateICAndUser(objCen);
        // objSP = nmGenericTracker.CreatePGStudentProgram(objAccount);
        nm_Payment__c objPayment2= nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
        IC_Change_Request__c icchange = new IC_Change_Request__c();
        icchange.Name = '011636069--->Program Change';
        icchange.Student__c = objAccount.Id;
        icchange.Status__c = 'New';
        icchange.New_Program__c= program.Id;
        icchange.Opportunity__c = objopp.Id;
        icchange.nm_Reason_for_Change_of_Program__c = 'Test';
        icchange.nm_TypeofRequest__c = 'Program Change';
        insert icchange;

        Validity_Extension__c objValEx = new Validity_Extension__c();
        objValEx.Batch_Name__c='JUL2015';
        objValEx.Expiry_Date_Of_Program__c='2020';
        objValEx.Mobile_Number__c='242343254326534';
        objValEx.Name_Of_Account__c='Fagu Babu';
        objValEx.Student_Number_Of_Account__c='77114000213';
        objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
        objValEx.Related_Account__c = objAccount.id;
        insert objValEx;
        
        // IC_Change_Request__c icchange1 = new IC_Change_Request__c();
        // icchange1.Name = '011636393--->IC Change';
        // icchange1.Student__c = objAccount.Id;
        // icchange1.Current_Information_Center__c = objCen.Id;
        // icchange1.New_Information_Center__c = objCen.Id;
        // icchange1.Status__c = 'New';
        // icchange1.Opportunity__c = objopp.Id;
        // icchange1.nm_Reason_for_Change_of_Program__c = 'Test';
        // icchange1.nm_TypeofRequest__c = 'IC Change';
        // insert icchange1;
    }
    
    static testMethod void testUpdateLeadStageAndTranserPaymentFromLeadToOpportunity1(){
        Test.startTest();
        Opportunity objopp = [select Id , nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(objPayment.id,objPayment);

        objPayment.nm_OpportunityNew__c =objopp.id;
        objPayment.nm_Amount__c = 4272;
        objPayment.Receipt_Number__c='20000';
        objPayment.nm_PaymentStatus__c ='Payment Approved';
        update objPayment;
      
        lstPay.add(objPayment);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateLeadStageAndTranserPaymentFromLeadToOpportunity(lstPay,oldMap,false);
        Test.stopTest();

    }

    static testMethod void testUpdateLeadStageAndTranserPaymentFromLeadToOpportunity2(){
        Test.startTest();
        Opportunity objopp = [select Id , nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(objPayment.id,objPayment);

        objPayment.nm_Lead__c=ld.id;
        objPayment.nm_Amount__c = 4272;
        objPayment.Receipt_Number__c='20000';
        objPayment.nm_PaymentStatus__c ='Payment Made';
        update objPayment;
      
        lstPay.add(objPayment);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateLeadStageAndTranserPaymentFromLeadToOpportunity(lstPay,oldMap,true);
        Test.stopTest();

    }

    static testMethod void testUpdateAccountIncaseofCancellationWithLatefees(){
         Test.startTest();
        Opportunity objopp = [select Id, AccountId from Opportunity limit 1];
        system.debug('objopp ---> ' +  objopp);
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        nm_Payment__c nmPayment = new nm_Payment__c();
        nmPayment.nm_OpportunityNew__c =objopp.id;
        // objPayment.nm_Lead__c=ld.id;
        nmPayment.nm_Amount__c = 4272;
        nmPayment.Receipt_Number__c='20000';
        nmPayment.nm_PaymentType__c= 'Late Fees';
        nmPayment.nm_PaymentStatus__c ='Payment Approved';
        insert nmPayment;
        nm_Payment__c objPayment = [select Id,nm_AccountID__c,nm_OpportunityNew__c, nm_Amount__c, Receipt_Number__c, nm_PaymentType__c, nm_PaymentStatus__c from nm_Payment__c WHERE ID = :nmPayment.Id limit 1];
        system.debug('objPayment ---> ' +  objPayment);
        oldMap.put(objPayment.id,objPayment);
        lstPay.add(objPayment);
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateAccountIncaseofCancellationWithLatefees(lstPay,oldMap);
        Test.stopTest();

    }

    static testMethod void testUpdateAccountIncaseofCancellationWithLatefees2(){
        Test.startTest();
        Opportunity objopp = [select Id, AccountId from Opportunity limit 1];
        system.debug('objopp ---> ' +  objopp);
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        nm_Payment__c nmPayment = new nm_Payment__c();
        nmPayment.nm_OpportunityNew__c =objopp.id;
        // objPayment.nm_Lead__c=ld.id;
        nmPayment.nm_Amount__c = 4272;
        nmPayment.Receipt_Number__c='20000';
        nmPayment.nm_PaymentType__c= 'Late Fees';
        nmPayment.nm_PaymentStatus__c ='Payment Made';
        insert nmPayment;
        nm_Payment__c objPayment = [select Id,nm_AccountID__c,nm_OpportunityNew__c, nm_Amount__c, Receipt_Number__c, nm_PaymentType__c, nm_PaymentStatus__c from nm_Payment__c WHERE ID = :nmPayment.Id limit 1];
        system.debug('objPayment ---> ' +  objPayment);
        oldMap.put(objPayment.id,objPayment);
        lstPay.add(objPayment);
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateAccountIncaseofCancellationWithLatefees(lstPay,oldMap);
        Test.stopTest();

    }

     static testMethod void testUpdateAccountIncaseofCancellationWithLatefees3(){
         Test.startTest();
        Opportunity objopp = [select Id, AccountId from Opportunity limit 1];
        system.debug('objopp ---> ' +  objopp);
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        nm_Payment__c nmPayment = new nm_Payment__c();
        nmPayment.nm_OpportunityNew__c =objopp.id;
        // objPayment.nm_Lead__c=ld.id;
        nmPayment.nm_Amount__c = 4272;
        nmPayment.Receipt_Number__c='20000';
        nmPayment.nm_PaymentType__c= 'Late Fees';
        nmPayment.nm_PaymentStatus__c ='Pending Late Fees';
        insert nmPayment;
        nm_Payment__c objPayment = [select Id,nm_AccountID__c,nm_OpportunityNew__c, nm_Amount__c, Receipt_Number__c, nm_PaymentType__c, nm_PaymentStatus__c from nm_Payment__c WHERE ID = :nmPayment.Id limit 1];
        system.debug('objPayment ---> ' +  objPayment);
        oldMap.put(objPayment.id,objPayment);
        lstPay.add(objPayment);
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateAccountIncaseofCancellationWithLatefees(lstPay,oldMap);
        Test.stopTest();

    }


    static testMethod void testGenerateRegistrationReceiptNo(){
        Test.startTest();
        Opportunity objopp = [select Id from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(objPayment.id,objPayment);

        objPayment.nm_OpportunityNew__c =objopp.id;
        objPayment.nm_Lead__c=ld.id;
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_PaymentType__c='Registration';
        objPayment.nm_PaymentStatus__c ='Payment Made';
        update objPayment;
        lstPay.add(objPayment);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.GenerateRegistrationReceiptNo(lstPay,oldMap,false);
        Test.stopTest();

    }

    static testMethod void testUpdateOpportunityStage(){
        Test.startTest();
        Opportunity objopp = [select Id from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(objPayment.id,objPayment);

        objPayment.nm_OpportunityNew__c =objopp.id;
        objPayment.nm_Lead__c=ld.id;
        objPayment.nm_Amount__c = 4272;
        objPayment.Receipt_Number__c='20000';
        objPayment.nm_PaymentStatus__c ='Payment Disapproved';
        objPayment.nm_PaymentDissapproved__c='testNA';
        update objPayment;
        lstPay.add(objPayment);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateOpportunityStage(lstPay,oldMap,false);
        Test.stopTest();

    }

    @isTest 
    static void testMethodForCareerService(){

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest();
        Account objAccount = [select Id from Account limit 1];
        Career_Service_Program__c objCSProgram = new Career_Service_Program__c(Account__c=objAccount.id);
        insert objCSProgram;

        nm_Payment__c objPayment = new nm_Payment__c(
        CareerServiceProgram__c=objCSProgram.id,
        nm_Amount__c = 4272,
        Receipt_Number__c = '70021548889',
        nm_PaymentStatus__c ='Payment Made',
        nm_PaymentType__c='Career Service');

        insert objPayment;

        objPayment.nm_PaymentStatus__c = 'Payment Approved';
        update objPayment;
        Test.StopTest();
   
    }

    static testMethod void testupdatePaymentTransactionModeInOpp(){
        Test.startTest();
        Opportunity objopp = [select Id , StageName,nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,payment_Transaction_Mode__c, nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        Lead ld = [select Id from Lead limit 1];
        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(objPayment.id,objPayment);
      /*  Bank_Charges__c bc= new Bank_Charges__c();
        bc.Name = 'HDFC_upgrad';
        bc.CC__c= 0.75;
        bc.DC__c=0.99;
        bc.NB__c=17.0;
        insert bc;*/
        
        objPayment.nm_OpportunityNew__c =objopp.id;
        objPayment.nm_Lead__c=ld.id;
        objPayment.nm_Amount__c = 4272;
        objPayment.Receipt_Number__c='20000';
        objPayment.nm_PaymentGatewayName__c = 'HDFC GateWay';
        objPayment.payment_Transaction_Mode__c ='CC';
        objPayment.nm_PaymentStatus__c ='Payment Approved';
        update objPayment;
        // DELETE statement to cover the after delete method..
       // delete objPayment;
        lstPay.add(objPayment);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateLeadStageAndTranserPaymentFromLeadToOpportunity(lstPay,oldMap,false);
        obj.ApproveReRegistrationAdmissionPaymentAfterPaymnetMade(objopp);
        Test.stopTest();

    }

    @IsTest
    static void testMethodCallWebserviceToApproveAndSendToStudentzone(){
        
        Test.startTest();
        Opportunity objopp = [select Id , StageName,nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,payment_Transaction_Mode__c, nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        objPayment.nm_PaymentType__c = 'Live Lectures';
        objPayment.nm_PaymentGatewayName__c = 'BillDesk GateWay';
        update objPayment;
        Set<Id> ne = new Set<Id>();
        ne.add(objPayment.Id);
        nmPaymentTriggerHandler.callWebserviceToApproveAndSendToStudentzone(ne);
        nmPaymentTriggerHandler.CallwebserviceMassApproval(ne, true);
        //  nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        // obj.callWebserviceToApproveAndSendToStudentzone(ne);
        Test.stopTest();
        
    }

    @IsTest
    static void testMethodCallwebserviceMassApprovalMethod1(){
        
        Test.startTest();
        Lead ld = [select Id from Lead limit 1];
        Opportunity objopp = [select Id , StageName,nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,payment_Transaction_Mode__c, nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        objPayment.nm_PaymentType__c = 'Registration';
         objPayment.nm_Lead__c =ld.Id;
        update objPayment;
        Set<Id> ne = new Set<Id>();
        ne.add(objPayment.Id);
        nmPaymentTriggerHandler.CallwebserviceMassApproval(ne, true);
        //  nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        // obj.callWebserviceToApproveAndSendToStudentzone(ne);
        Test.stopTest();
        
    }
    @IsTest
    static void testMethodCallwebserviceMassApprovalMethod2(){
        
        Test.startTest();
        Lead ld = [select Id from Lead limit 1];
        Opportunity objopp = [select Id , StageName,nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
        nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,payment_Transaction_Mode__c, nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];
        // objPayment.nm_PaymentType__c = 'Registration';
        objPayment.nm_Lead__c =ld.Id;
        update objPayment;
        Set<Id> ne = new Set<Id>();
        ne.add(objPayment.Id);
        nmPaymentTriggerHandler.CallwebserviceMassApproval(ne, true);
        //  nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        // obj.callWebserviceToApproveAndSendToStudentzone(ne);
        Test.stopTest();
        
    }

    @IsTest
    static void UpdateCenterValidityLicenseMethod(){
        nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
        objCenter.Validity_From_MS__c = Date.today() -1000;
        objCenter.Validity_To_MS__c = Date.today() + 1000;
        objCenter.Validity_From__c = Date.today() -2000;
        objCenter.Validity_To__c = Date.today() + 1000;
        objCenter.Validity_From_UG__c = Date.today() -1000;
        objCenter.Validity_To_UG__c = Date.today() + 1000;
        update objCenter;
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        List<nm_Payment__c> lstPaymentToUpdate = new List<nm_Payment__c>();
        nm_Payment__c nmPayment = new nm_Payment__c(nm_PaymentType__c = 'UG And PG License Fee', nm_PaymentStatus__c = 'Payment Made', AEP__c = objCenter.Id);
        lstPaymentToInsert.add(nmPayment);

        nm_Payment__c nmPayment1 = new nm_Payment__c(nm_PaymentType__c = 'MS License Fee', nm_PaymentStatus__c = 'Payment Made', AEP__c = objCenter.Id);
        lstPaymentToInsert.add(nmPayment1);

        nm_Payment__c nmPayment2 = new nm_Payment__c(nm_PaymentType__c = 'UG And PG Renewal License Fee', nm_PaymentStatus__c = 'Payment Made', AEP__c = objCenter.Id);
        lstPaymentToInsert.add(nmPayment2);

        nm_Payment__c nmPayment3 = new nm_Payment__c(nm_PaymentType__c = 'MS Renewal License Fee', nm_PaymentStatus__c = 'Payment Made', AEP__c = objCenter.Id);
        lstPaymentToInsert.add(nmPayment3);

        nm_Payment__c nmPayment4 = new nm_Payment__c(nm_PaymentType__c = 'UG And PG And MS License Fee', nm_PaymentStatus__c = 'Payment Made', AEP__c = objCenter.Id);
        lstPaymentToInsert.add(nmPayment4);

        nm_Payment__c nmPayment5 = new nm_Payment__c(nm_PaymentType__c = 'UG And PG And MS Renewal License Fee', nm_PaymentStatus__c = 'Payment Made', AEP__c = objCenter.Id);
        lstPaymentToInsert.add(nmPayment5);

        insert lstPaymentToInsert;

        for(nm_Payment__c obj : lstPaymentToInsert) {
            obj.nm_PaymentStatus__c = 'Payment Approved';
            lstPaymentToUpdate.add(obj);
        }
        update lstPaymentToUpdate;

        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(nmPayment.id,nmPayment);
        oldMap.put(nmPayment1.id,nmPayment1);
        oldMap.put(nmPayment2.id,nmPayment2);
        oldMap.put(nmPayment3.id,nmPayment3);
        oldMap.put(nmPayment4.id,nmPayment4);
        oldMap.put(nmPayment5.id,nmPayment5);
        
        
        lstPay.add(nmPayment);
        lstPay.add(nmPayment1);
        lstPay.add(nmPayment2);
        lstPay.add(nmPayment3);
        lstPay.add(nmPayment4);
        lstPay.add(nmPayment5);


        Test.startTest();
         nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateCenterValidity(lstPay, oldMap);
       
        Test.stopTest();
        
    }
    // @IsTest
    // static void UpdateCenterValidityMethod1(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'PG License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void UpdateCenterValidityMethod2(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     objCenter.Validity_From_MS__c = Date.today() -1000;
    //     objCenter.Validity_To_MS__c = Date.today() + 1000;
    //     objCenter.Validity_From__c = Date.today() -1000;
    //     objCenter.Validity_To__c = Date.today() + 1000;
    //     objCenter.Validity_From_UG__c = Date.today() -1000;
    //     objCenter.Validity_To_UG__c = Date.today() + 1000;
    //     update objCenter;
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'UG And PG License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void UpdateCenterValidityMethod3(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     objCenter.Validity_From_MS__c = Date.today() -1000;
    //     objCenter.Validity_To_MS__c = Date.today() + 1000;
    //     objCenter.Validity_From__c = Date.today() -1000;
    //     objCenter.Validity_To__c = Date.today() + 1000;
    //     objCenter.Validity_From_UG__c = Date.today() -1000;
    //     objCenter.Validity_To_UG__c = Date.today() + 1000;
    //     update objCenter;
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'MS License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void UpdateCenterValidityMethod4(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     objCenter.Validity_From_MS__c = Date.today() -1000;
    //     objCenter.Validity_To_MS__c = Date.today() + 1000;
    //     objCenter.Validity_From__c = Date.today() -2000;
    //     objCenter.Validity_To__c = Date.today() + 1000;
    //     objCenter.Validity_From_UG__c = Date.today() -1000;
    //     objCenter.Validity_To_UG__c = Date.today() + 1000;
    //     update objCenter;
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'UG And PG And MS License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void UpdateCenterValidityMethod7(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     objCenter.Validity_From_MS__c = Date.today() -1000;
    //     objCenter.Validity_To_MS__c = Date.today() + 1000;
    //     objCenter.Validity_From__c = Date.today() -2000;
    //     objCenter.Validity_To__c = Date.today() + 1000;
    //     objCenter.Validity_From_UG__c = Date.today() -1000;
    //     objCenter.Validity_To_UG__c = Date.today() + 1000;
    //     update objCenter;
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'MS Renewal License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void UpdateCenterValidityMethod5(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     objCenter.Validity_From_MS__c = Date.today() -1000;
    //     objCenter.Validity_To_MS__c = Date.today() + 1000;
    //     objCenter.Validity_From__c = Date.today() -2000;
    //     objCenter.Validity_To__c = Date.today() + 1000;
    //     objCenter.Validity_From_UG__c = Date.today() -1000;
    //     objCenter.Validity_To_UG__c = Date.today() + 1000;
    //     update objCenter;
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'UG And PG And MS License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void UpdateCenterValidityMethod6(){
    //     nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
    //     objCenter.Validity_From_MS__c = Date.today() -1000;
    //     objCenter.Validity_To_MS__c = Date.today() + 1000;
    //     objCenter.Validity_From__c = Date.today() -2000;
    //     objCenter.Validity_To__c = Date.today() + 1000;
    //     objCenter.Validity_From_UG__c = Date.today() -1000;
    //     objCenter.Validity_To_UG__c = Date.today() + 1000;
    //     update objCenter;
    //     nm_Payment__c nmPayment = new nm_Payment__c();
    //     nmPayment.nm_PaymentType__c = 'UG And PG And MS Renewal License Fee';
    //     nmPayment.nm_PaymentStatus__c = 'Payment Made';
    //     nmPayment.AEP__c = objCenter.Id;
    //     insert nmPayment;

    //     Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
    //     List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
    //     oldMap.put(nmPayment.id,nmPayment);
        
    //     nmPayment.nm_PaymentStatus__c = 'Payment Approved';
    //     update nmPayment;
    //     lstPay.add(nmPayment);


    //     Test.startTest();
    //      nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
    //     obj.UpdateCenterValidity(lstPay, oldMap);
       
    //     Test.stopTest();
        
    // }

    @IsTest
    static void UpdateCenterRequest(){
        
        Test.startTest();
        nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
        AEP_site_inspection__c aep = new AEP_site_inspection__c();
        aep.Centers__c = objCenter.Id;
        aep.New_IC_Company_Name__c = 'test';
        aep.AEP_Service_Request__c = 'Name Change';
        insert aep;
        nm_Payment__c nmPayment = new nm_Payment__c();
        nmPayment.nm_PaymentType__c = 'Name Change Fee';
        nmPayment.nm_PaymentStatus__c = 'Payment Made';
        nmPayment.AEP__c = objCenter.Id;
        insert nmPayment;

        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(nmPayment.id,nmPayment);
        SET<ID> ids = new Set<Id>();
        ids.add(nmPayment.ID);
        
        nmPayment.nm_PaymentStatus__c = 'Payment Approved';
        update nmPayment;
        lstPay.add(nmPayment);
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateCenterRequest(lstPay, oldMap);
        nmPaymentTriggerHandler.ActionOnValityPaymentApproval ac = new nmPaymentTriggerHandler.ActionOnValityPaymentApproval(ids,lstPay );
        System.enqueueJob(ac);

        Test.stopTest();
        
    }

    @IsTest
    static void UpdateCenterRequestAddress(){
        
        Test.startTest();
        nm_Centers__c  objCenter = [SELECT ID From nm_Centers__c LIMIT 1 ];
        AEP_site_inspection__c aep = new AEP_site_inspection__c();
        aep.Centers__c = objCenter.Id;
        aep.New_IC_Company_Name__c = 'test';
        aep.AEP_Service_Request__c = 'Address Change';
        aep.nm_Street__c = 'street';
        aep.Location_City__c = 'city';
        aep.nm_PostalCode__c = '74657';
        aep.nm_StateProvince__c = 'state';
        insert aep;
        nm_Payment__c nmPayment = new nm_Payment__c();
        nmPayment.nm_PaymentType__c = 'Address change Fee';
        nmPayment.nm_PaymentStatus__c = 'Payment Made';
        nmPayment.AEP__c = objCenter.Id;
        insert nmPayment;

        Map<id,nm_Payment__c> oldMap = new Map<id,nm_Payment__c>();
        List<nm_Payment__c> lstPay = new List<nm_Payment__c>();
        
        oldMap.put(nmPayment.id,nmPayment);
        SET<ID> ids = new Set<Id>();
        ids.add(nmPayment.ID);
        
        nmPayment.nm_PaymentStatus__c = 'Payment Approved';
        update nmPayment;
        lstPay.add(nmPayment);
        nmPaymentTriggerHandler obj = new nmPaymentTriggerHandler();
        obj.UpdateCenterRequest(lstPay, oldMap);
        nmPaymentTriggerHandler.ActionOnValityPaymentApproval ac = new nmPaymentTriggerHandler.ActionOnValityPaymentApproval(ids,lstPay );
        System.enqueueJob(ac);

        Test.stopTest();
        
    }


    @isTest
    static void UpdateCourserStatus() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Opportunity objopp = [select Id , StageName,nm_StudentProgram__c , nm_Program__c ,AccountId ,nm_Semester__c ,nm_StudentProgram__r.nm_Program__c from Opportunity limit 1];
            nm_Payment__c objPayment = [select Id,nm_Lead__c,nm_OpportunityNew__c,payment_Transaction_Mode__c, nm_PaymentType__c,Receipt_Number__c,nm_Amount__c from nm_Payment__c limit 1];

            objopp.Synced_With_StudentZone__c =true;
            update objopp;

            Account objAccount = new Account(id=objopp.AccountId);
            objAccount.nm_StudentStatus__c = 'Confirmed';
            objAccount.nm_StudentNo__c = '123';
            update objAccount;
            
            objPayment.nm_OpportunityNew__c =objopp.id;
            objPayment.nm_PaymentType__c = 'Coursera';
            objPayment.nm_Amount__c = 4272;
            objPayment.Receipt_Number__c='20000';
            objPayment.nm_PaymentGatewayName__c = 'HDFC GateWay';
            objPayment.payment_Transaction_Mode__c ='CC';
            objPayment.nm_PaymentStatus__c ='Payment Approved';
            update objPayment;

        Test.stopTest();
    }
    @isTest
    static void Paymentdel() {
         //String uId=userinfo.getuserid();
       // List<User> uRList=[select id,Name from User where UserRole.Name='Head Office'];
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        UserRole obj=new UserRole(Name= 'Head Office'); 
         insert obj; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id,
                         UserRoleId = obj.Id
                        ); 
        
        
        insert uu;
        System.runAs(uu) {
        Test.startTest();
         nm_Payment__c objPayment = [select Id,nm_PaymentStatus__c from nm_Payment__c limit 1];
            objPayment.nm_PaymentStatus__c='Pending Extra Fees';
            update objPayment;
           delete objPayment;
        Test.stopTest();
        }
    }

    @isTest
    static void checkDuplicateForLoan() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Opportunity objopp = [select Id , AccountId from Opportunity limit 1];
            insert new nm_Payment__c(nm_PaymentType__c= 'Admission',nm_OpportunityNew__c = objopp.id, nm_Amount__c = 10000,nm_ActualPaymentAmmount__c = 10000, nm_PaymentStatus__c = 'Payment Made', nm_ModeOfPayment__c = 'NEFT', nm_Merchant_Track_Id__c = '12345');
            insert new nm_Payment__c(nm_PaymentType__c= 'Admission',nm_OpportunityNew__c = objopp.id, nm_Amount__c = 10000,nm_ActualPaymentAmmount__c = 10000, nm_PaymentStatus__c = 'Payment Made', nm_ModeOfPayment__c = 'NEFT', nm_Merchant_Track_Id__c = '12345');
        } catch (Exception e) {
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Duplicate payment found with same UTR number')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
        
        System.assertEquals(true, exceptionThrown, 'No exception was thrown');
        Test.stopTest();
        
    }

    @isTest
    static void testValidityextensionApproval(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nm_Payment__c objPayment = [select id,nm_PaymentStatus__c,nm_PaymentDissapproved__c,Validity_Extension__c from nm_Payment__c limit 1];
        Validity_Extension__c objValEx = [select id from Validity_Extension__c limit 1];
        
        Test.startTest();
        objPayment.Validity_Extension__c = objValEx.Id;
        objPayment.nm_PaymentStatus__c = 'Payment Approved';
        objPayment.nm_PaymentType__c = 'Validity Extension Fee';
        update objPayment;

        objPayment.nm_PaymentStatus__c = 'Payment Made';
        objPayment.nm_PaymentType__c = 'Registration';
        update objPayment;
        Test.stopTest();
    }

    // @isTest
    // static void testGenerateRegistrationReceiptNos(){
    //     nm_Payment__c objPayment = [select id,nm_PaymentStatus__c,nm_PaymentDissapproved__c,Validity_Extension__c from nm_Payment__c limit 1];
        
    //     Test.startTest();
    //     objPayment.nm_PaymentStatus__c = 'Payment Made';
    //     objPayment.nm_PaymentType__c = 'Registration';
    //     update objPayment;
    //     Test.stopTest();
    // }
}