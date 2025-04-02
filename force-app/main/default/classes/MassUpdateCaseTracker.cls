@isTest(SeeAllData=false)
public class MassUpdateCaseTracker {
    @TestSetup
    static void makeData(){

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        
        Case objcase = new Case();
        objcase.Status = 'New';
        objcase.SuppliedEmail ='sachin920@gmail.com';
        objcase.Description = 'ABC';
        objcase.Subject = 'Head';
        insert objcase;

    }

    @isTest
    static void Methodname1(){
        Test.startTest();
       PageReference pg = new PageReference('/apex/MassCaseUpadte');
        MassUpdateCaseController obj =new MassUpdateCaseController();
        Case objCases = [SELECT CaseNumber FROM Case LIMIT 1];
        obj.listOfCaseNumber =objCases.CaseNumber;
        obj.CreateAEPReq();
        obj.getOptionList();
        //insert objcase;
        test.stopTest();
    }
  
}