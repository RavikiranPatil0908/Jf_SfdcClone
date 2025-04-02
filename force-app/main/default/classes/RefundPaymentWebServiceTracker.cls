/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : @vickysahu
**/
@isTest
public class RefundPaymentWebServiceTracker {
    
    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        String lineItemId = nmGenericTracker.CreateOpportunityLineItem(objopp);
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmRefund_Payment__c objRefund = new nmRefund_Payment__c(nm_Payment_Status__c = 'Refund Initiated', Type_of_Refund__c = 'Registration Cancellation', Status__c = 'Refund Request Created');
        objRefund.Account__c = objAccount.Id;
        insert objRefund;
    }

    @isTest
    public static void unitTest1(){
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Opportunity oppRec = [SELECT Id FROM Opportunity LIMIT 1];
        Decimal regFee = RefundPaymentWebService.sendRegfee(oppRec.Id);
        String msg = RefundPaymentWebService.deleteDupLead('amit.kumar@saasfocus.com','8377985721');
        String msg1 = RefundPaymentWebService.deleteRefund(accRec.Id, '011564865');
    }

    @isTest
    public static void unitTest2(){
        String msg = RefundPaymentWebService.deleteDupLead('amit.kumar12@saasfocus.com','8377985785');
    }
}