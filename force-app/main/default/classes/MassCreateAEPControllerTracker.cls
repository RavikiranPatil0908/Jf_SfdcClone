@isTest(SeeAllData=false)

public class MassCreateAEPControllerTracker {

    @TestSetup
    static void makeData(){
        // Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai',true);
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
         nm_Centers__c objCen = [Select Id,AEP_email_id__c from nm_Centers__c  Where Id =: objLead.nm_InformationCenter__c LIMIT 1];
         objCen.AEP_email_id__c = 'test@gmail.com';
        update objCen ;
        objLead.nm_RegistrationNo__c = '102122987113';
        update objLead;
      
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        // objAccount.ICemailaddress__c = 'test@gmail.com';
        // update objAccount;
        nmGenericTracker.CreateDiplomaStudentProgram(objAccount);
    }
    @isTest
    Static void methodName(){
        Test.startTest();
       // MassCreateAEPController.CreateAEPReq();
    Lead objLead= [Select id, nm_RegistrationNo__c from Lead Limit 1];
    Account objAcc= [Select id, nm_RegistrationNumber__c from Account Limit 1];
        PageReference pg = new PageReference('/apex/MassCreateAEP');
        MassCreateAEPController obj =new MassCreateAEPController();
        obj.listOfStudentNumber =objLead.nm_RegistrationNo__c+','+objAcc.nm_RegistrationNumber__c;
        System.debug('Laed==>' +objLead);
        System.debug('Account==>' +objAcc);
    
        obj.typeofSub = '';
        obj.Description = 'Packages is Done';
        obj.CreateAEPReq();
        obj.getStatusLists();
        obj.getTypeOptions();
        Test.stopTest();
    }
   
}