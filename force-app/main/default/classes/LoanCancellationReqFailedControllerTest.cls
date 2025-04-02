/**
 * @description       : 
 * @author            : @Vicky
 * @group             : 
 * @last modified on  : 31-10-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData = false)
public class LoanCancellationReqFailedControllerTest {
    @testSetup
    public static void setUpData() {
        nmGenericTracker.InsertSerialNo();
      nmGenericTracker.CreateCenter('Mumbai');
      nmGenericTracker.CreateProduct('Live Lectures',1200);
      Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

      Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
      objAccount.nm_Tagged_Pricebook__c = null;
      objAccount.nm_LeadId__c = String.valueOf(objLead.id);
      update objAccount;
      
      Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
      nmGenericTracker.CreateOpportunityLineItem(objopp);

      Opportunity objopp2 = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Re-Registration Pending','2',objAccount,'admission');
      nmGenericTracker.CreateOpportunityLineItem(objopp2);
    }

    @isTest
    static void testUnit1() {
        List<Opportunity> op = [SELECT Id FROM Opportunity limit 1];
        LoanCancellationRequestFailedController controller = new LoanCancellationRequestFailedController();
        Test.startTest();
            controller.loanCancellation(op[0].Id,'Opportunity', 'Loan Cancelation Failed', 'Loan Cancelation Failed');
        Test.stopTest();
    }
}