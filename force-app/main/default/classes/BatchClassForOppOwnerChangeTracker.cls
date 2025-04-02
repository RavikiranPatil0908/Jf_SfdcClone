@isTest
public class BatchClassForOppOwnerChangeTracker {
    @TestSetup
    static void makeData(){

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');      
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('OwnerId','1',objAccount,'admission');
       
    }

    @IsTest
    static void methodName(){
        
        Test.startTest();
        BatchClassForOppOwnerChange instance = new BatchClassForOppOwnerChange();
        //instance.sendErrorMail();
        Database.executeBatch(instance, 200);
        Test.stopTest();
        
    }
    @IsTest
    static void methodName1(){
        
        Test.startTest();
    BatchClassForOppOwnerChange instance = new BatchClassForOppOwnerChange();
         instance.sendErrorMail();
        Test.stopTest();
        
    }
}