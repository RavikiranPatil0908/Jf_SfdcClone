@isTest
public class AEPRequestTriggerHandlerTracker {
    @TestSetup
    static void makeData(){
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
        AEP_Request__c objAEP = new AEP_Request__c();
        objAEP.Lead__c = objLead.Id;
        objAEP.Status__c = 'New';
        objAEP.Subject__c = 'My book not received';
        insert objAEP;
        AEP_Request__c objAEP1 = new AEP_Request__c();
        objAEP1.Lead__c = objLead.Id;
        objAEP1.Status__c = 'New';
        objAEP1.Subject__c = 'Eligibility Exemption';
        objAEP1.Reason_For_Exemption__c = 'Eligibility Exemption';
        objAEP1.Document_Link__c = 'Eligibility Exemption';
        insert objAEP1;
        Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com');
        insert objBusinessAccount;
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objLead.nm_InformationCenter__c;
        cp.BusinessAccount__c = objBusinessAccount.id;
        cp.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        cp.AEP_Request_Subject__c = 'My book not received';
        cp.AEP_Request_Start_Time__c = Datetime.now().time().addHours(-3);
        cp.AEP_Request_End_Time__c = Datetime.now().time().addHours(3);
        insert cp;
    }

    @IsTest
    static void methodName1(){
        List<AEP_Request__c> lstAep = [SELECT Id FROM AEP_Request__c ];
        List<Counsellor_Profile__c> coun = [SELECT Id, Name, UserIsActive__c FROM Counsellor_Profile__c ];
        System.debug(coun);
        for (AEP_Request__c objAEP : lstAep) {
            objAEP.Status__c = 'Escalated to HO';
            update objAEP;
            
        }
        Test.startTest();
        
        Test.stopTest();
        
    }

    @IsTest
    static void methodName2(){
        AEP_Request__c objAEP = [SELECT Id FROM AEP_Request__c LIMIT 1];
        List<Counsellor_Profile__c> coun = [SELECT Id, Name, UserIsActive__c FROM Counsellor_Profile__c ];
        Counsellor_Profile__c cloneObj = coun[0].clone();
        cloneObj.AEP_Request_Subject__c = '';
        insert cloneObj;
        System.debug(coun);
        objAEP.Subject__c = 'Escalated to HO';
        objAEP.Status__c = 'Escalated to HO';
        update objAEP;
        AEP_Request__c objAEP1 =objAEP.clone();
        objAEP1.Admission_Co_ordinator__c = cloneObj.Id;
        objAEP1.Status__c = 'Escalated to HO1';
        insert objAEP1;
        objAEP1.Subject__c = 'Escalated to HO';
        objAEP1.Status__c = 'Escalated to HO';
        update objAEP1;

        Test.startTest();
        
        Test.stopTest();
        
    }
}