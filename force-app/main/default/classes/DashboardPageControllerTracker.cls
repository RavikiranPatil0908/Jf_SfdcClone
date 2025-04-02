/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Ravi
**/

@isTest(SeeAllData = false)
public with sharing class DashboardPageControllerTracker {
    @TestSetup
    static void setupTestData() {
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Status = 'Admission Fee Paid';
        update objLead ;
       
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
    }
       /**
    * @description 
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void unitTest1() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        DashboardPageController controller = new DashboardPageController();
        Test.startTest();
        controller.setObjectType('Lead');
        controller.setObjectId(testLead.Id);
        Test.stopTest();

    }

    /**
    * @description 
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void  unitTest2() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        DashboardPageController controller = new DashboardPageController();
        controller.setObjectType('Account');
        controller.setObjectId(testAccount.Id);
        
        Test.stopTest();

    }


    @isTest
    static void unitTest3(){
        Test.startTest();
        DashboardPageController controller = new DashboardPageController();
        controller.sendOTP();
        controller.verifyOTP();
        controller.validateSession();
        Test.stopTest();
    }
}