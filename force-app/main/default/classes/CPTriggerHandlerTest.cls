@isTest
public class CPTriggerHandlerTest {
     
     public static testMethod void TestMethod1()
    {
      Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com');
        insert objBusinessAccount;
         Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objAccount.nm_Centers__c;
        cp.BusinessAccount__c = objBusinessAccount.id;
        cp.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        insert cp;  
        
    }

}