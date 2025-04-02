@isTest
public with sharing class AEPRequestPrintFormController_Test {
  @isTest
  static void testMethod1() {
    Test.startTest();
    nmGenericTracker.InsertSerialNo();
    nmGenericTracker.CreateCenter('Mumbai', true);
    Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);

    nm_EligiblityCriteria__c objEligibility = nmGenericTracker.CreateElegibilityCriteria();
    objEligibility.Experience_Required_In_Year__c = 2;
    update objEligibility;

    nmGenericTracker.CreateWorkExperienceForLead(objLead);

    AEP_Request__c objAEPRequest = new AEP_Request__c();
    objAEPRequest.Lead__c = objLead.Id;
    insert objAEPRequest;

    AEP_Request__c objAEPRequest1 = [SELECT Id, Lead__c FROM AEP_Request__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', objAEPRequest1.Id);

    AEPRequestPrintFormController aEPRequestPrintFormController = new AEPRequestPrintFormController();
    Test.stopTest();
    //registration Account
    // Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
    // nmGenericTracker.CreateWorkExperienceForAccount(objAccount);
  }


  @isTest
  static void testMethod2() {
    Test.startTest();
    nmGenericTracker.InsertSerialNo();
    nmGenericTracker.CreateCenter('Mumbai', true);
    Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);

    nm_EligiblityCriteria__c objEligibility = nmGenericTracker.CreateElegibilityCriteria();
    objEligibility.Experience_Required_In_Year__c = 2;
    update objEligibility;

    nmGenericTracker.CreateWorkExperienceForLead(objLead);

    //registration Account
    Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
    nmGenericTracker.CreateWorkExperienceForAccount(objAccount);

    AEP_Request__c objAEPRequest = new AEP_Request__c();
    objAEPRequest.Student__c = objAccount.Id;
    insert objAEPRequest;

    AEP_Request__c objAEPRequest1 = [SELECT Id, Lead__c FROM AEP_Request__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', objAEPRequest1.Id);

    AEPRequestPrintFormController aEPRequestPrintFormController = new AEPRequestPrintFormController();
    Test.stopTest();
    
  }
}