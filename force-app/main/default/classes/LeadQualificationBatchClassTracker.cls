@isTest
public with sharing class LeadQualificationBatchClassTracker {
    @TestSetup
    static void makeData(){


        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('MumbaiIT');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');

        Calender__c objCal = new Calender__c();
        objCal.Name = 'Jan 2021';
        objCal.Session__c = 'July';
        objCal.Year__c = 2020;
        objCal.Session_Start_Date__c = Date.today().addDays(-10);
        objCal.Session_End_Date__c = Date.today().addDays(10);
        objCal.Category__c = 'Admission';
        insert objCal;

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_Centers__c objCen = [SELECT Id FROM nm_Centers__c LIMIT 1];
        insert new Lead(FirstName = 'test', LastName = 'test', nm_DateOfBirth__c = Date.today().addYears(-20), Email = 'testt@test.com', MobilePhone = '8652140215', LeadSource = 'Web', nm_ChooseaProgram__c = 'Master Programs', nm_InformationCenter__c =objCen.Id);
    }

    @IsTest
    static void methodName(){
        Test.startTest();
        nm_StudentProgram__c objnm =[SELECT Id, Drive_Key__c FROM nm_StudentProgram__c LIMIT 1];
        system.debug(objnm.Drive_Key__c);
        LeadQualificationBatchClass instance = new LeadQualificationBatchClass();
        Database.executeBatch(instance);
        Test.stopTest();
        
    }
}