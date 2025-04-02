/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-27-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class PaymentDisapprovedUpdateStatusTracker {

    @TestSetup
    static void makeData(){
        nm_Centers__c objCen= nmGenericTracker.CreateCenter('Mumbai');
        nm_Program__c program = nmGenericTracker.CreatePGDiplomaProgram();
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',true);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',true,'Admission form & documents submitted');
        Opportunity objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
        nm_Payment__c objPayment1 = nmGenericTracker.CreateAdmissionPaymentRecordForOpptyForApproved(objopp);
        nmGenericTracker.CreateICAndUser(objCen);
        objopp.StageName = 'Closed Won';
        update objopp;
        String id = nmGenericTracker.CreateOpportunityLineItem(objopp);
        // nm_Payment__c objPayment2 = nmGenericTracker.CreatePaymentRecordForOpportunityApproved(objopp,'Registration');
    }

    @isTest
    static void unitTest1() {
        nm_Payment__c objPayment = [SELECT Id,nm_PaymentStatus__c,nm_PaymentDissapproved__c,nm_OpportunityNew__c FROM nm_Payment__c LIMIT 1];
        Opportunity objOpp = [SELECT Id,StageName FROM Opportunity LIMIT 1];
        Test.startTest();
        objPayment.nm_PaymentStatus__c = 'Payment Disapproved';
        objPayment.nm_PaymentDissapproved__c = 'test';
        update objPayment;
        Test.stopTest();
    }
}