@isTest
public  class TranchNotificationBatchClassTracker {
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('MumbaiIT');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
         nm_Payment__c objPayment = new nm_Payment__c ();

        objPayment.nm_OpportunityNew__c = objopp.Id;
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Waived Off';
        objPayment.nm_PaymentGatewayName__c ='Bill Desk';
        objPayment.nm_PaymentType__c = 'Additional Charge';
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment;
    }

    @IsTest
    static void methodName1(){
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        objOpp.Tenure__c = '15';
        objOpp.Loan_Type__c = 'LiquiLoans';
        objOpp.Down_Payment_Made__c = true;
        update objOpp;
        Test.startTest();
        TranchNotificationBatchClass instance = new TranchNotificationBatchClass();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
    @IsTest
    static void methodName2(){
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        objOpp.Tenure__c = '15';
        objOpp.Loan_Type__c = 'EduVanz';
        objOpp.Down_Payment_Made__c = true;
        update objOpp;
        Test.startTest();
        TranchNotificationBatchClass instance = new TranchNotificationBatchClass();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
    @IsTest
    static void methodName3(){
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        objOpp.Tenure__c = '15';
        objOpp.Loan_Type__c = 'GrayQuest';
        objOpp.Down_Payment_Made__c = true;
        update objOpp;
        Test.startTest();
        TranchNotificationBatchClass instance = new TranchNotificationBatchClass();
        Database.executeBatch(instance,1);
        Test.stopTest();
    }
}