/*
  @description       : 
  @author            : @MonikaC
  @group             : 
  @last modified on  : 01-04-2024
  @last modified by  : @MonikaC
*/

@isTest(SeeAllData=false)
public class OpportunityLineItemDataTableTracker {
    @TestSetup    
    public static void makeData(){  
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_DateOfBirth__c =System.today();
        objAccount.nm_ProgramType__c = 'Post Graduate Diploma Programs';
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'FullFee');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
    }

    @isTest 
    static void unitTest1(){ 
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
            List<OpportunityLineItem> lst = OpportunityLineItemDataTableController.getOpportunityLineItems(lstOpp[0].Id);
            System.assertEquals(lst.size() > 0, true, 'OpportunityLineItem Exists');
        Test.stopTest();
    }
}