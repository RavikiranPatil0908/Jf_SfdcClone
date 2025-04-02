@isTest(SeeAllData=false)
public class CallLogControllerTracker {
    public CallLogControllerTracker() {

    }

    @testSetup
    public static void setUpData() {
       Account acc = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Registered');

       Case case1 = new Case(Subject='Test', Account=acc);
        insert case1;
        
    }

    @isTest
    static void doTest(){

        List<Case> lstCase = [SELECT Id, Account.Id FROM Case ];

        Task task1 = new Task(Subject ='Call',
        Description = 'tracker test',
        Call_Category__c = 'Admissions',
        Disposition__c= 'Acknowledgement',
        Call_Type__c= 'Inbound Call');
        

        Test.startTest();
        CallLogController.checkAccount(lstCase[0].Id);
        CallLogController.checkAccount(null);
        CallLogController.getPickListValuesForDisposition(task1.Call_Category__c);
        CallLogController.createCallLog(lstCase[0].Id, task1);
        CallLogController.createCallLog(null, task1);
        CallLogController.createCallLog('dummy1234', task1);
        CallLogController.getPickListValuesForCallCategory();
        CallLogController.getPickListValuesForCallType();
        CallLogController.getPickListValuesForSubject();
        Test.stopTest();

    }
}