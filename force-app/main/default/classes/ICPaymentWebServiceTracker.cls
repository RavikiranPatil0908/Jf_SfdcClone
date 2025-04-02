@IsTest
public with sharing class ICPaymentWebServiceTracker {
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('MumbaiIT');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;
        IC_Payment__c iOne = new IC_Payment__c();
        iOne.Payment_Month__c='2';
        iOne.Payment_Year__c='2021';
        iOne.Centers__c=objAccount.nm_Centers__c;
        iOne.Amount__c = 1000 * 0.60;
        iOne.Payment_Due_Date__c = System.Today();
        iOne.Share_Processed__c = true;   
        insert iOne;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
    }

    @IsTest
    static void methodName1(){
        
        Test.startTest();
        Opportunity opp = [SELECT Id, AccountId,Account.Name  FROM Opportunity LIMIT 1];
        nm_Centers__c cen = [SELECT Id, Name FROM nm_Centers__c LIMIT 1];
        ICPaymentWebService.createICTransactionCreditEntry(opp, 2021, 8, 5245, cen.Name, '');
        ICPaymentWebService.createICTransactionDebitEntry(opp, 2021, 8, 5245, cen.Name, '');
        Test.stopTest();
        
    }
}