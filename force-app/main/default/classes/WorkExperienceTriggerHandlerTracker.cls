@isTest(seeAllData = false)
public class WorkExperienceTriggerHandlerTracker
{
    @TestSetup
    static void makeData(){
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterForMasterProg();
        System.debug('objLead ---> ' + objLead.nm_Program__c);
        nm_Program__c objPr = [SELECT Id,Name FROM nm_Program__c WHERE Specialisation__c = 'MBA (WX)' LIMIT 1];
        System.debug('objPr --> ' + objPr);

        List<nm_EligiblityCriteria__c> upEL = new List<nm_EligiblityCriteria__c> ();
        List<nm_EligiblityCriteria__c> lstEl = [SELECT Id FROM nm_EligiblityCriteria__c];
        if(lstEl.size() > 0) {
            for (nm_EligiblityCriteria__c el : lstEl) {
                el.nm_Documnetslist__c = 'Photo ID proof; Student Photograph; Aadhaar Card; Work Experience Certificate – 2 years; 10th Mark Sheet OR Certificate; 12th Mark Sheet OR Certificate; Degree Mark Sheet; Degree Certificate; AIU Certificate (For Foreign University)';
                upEL.add(el);
            }
        }
        if(upEL.size() > 0) {
            update upEL;
        }
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_DateOfBirth__c =system.today();
        objAccount.nm_Program__c =objPr.Id;
        objAccount.nm_EligiblityCriteria__c =upEL[0].Id;
        objAccount.Program_Type__c  ='MBA (WX)';
        update objAccount;

        
    }

    @IsTest
    static void method2(){
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        nm_LinksForDocumentsLead__c objDoc = new nm_LinksForDocumentsLead__c();
        objDoc.Lead__c = objLead.Id;
        objDoc.Name = 'Work Experience Certificate';
        insert objDoc;
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        nm_LinksForDocuments__c objLD = new nm_LinksForDocuments__c();
        objLD.nm_Account__c = objAccount.Id;
        objLD.Name ='Work Experience Certificate';
        insert objLD;
        System.debug('objLD.iD --> ' + objLD);
        Test.startTest();
        nm_WorkExperience__c objWk = new nm_WorkExperience__c();
        objWk.nm_Lead__c = objLead.Id;
        objWk.nm_CompanyName__c = 'fgjfj';
        insert objWk;
        objWk.nm_CompanyName__c= 'eeee';
        update objWk;
        nm_WorkExperience__c objWk3 = new nm_WorkExperience__c();
        objWk3.nm_Lead__c = objLead.Id;
        objWk3.nm_StartDate__c = Date.today().addYears(-3);
        objWk3.nm_EndDate__c = Date.today().addYears(-1);
        objWk3.nm_CompanyName__c = 'fgjfj';
        insert objWk3;

        DELETE objWk;
        DELETE objWk3;
        
        nm_WorkExperience__c objWk1 = new nm_WorkExperience__c();
        objWk1.nm_Student__c = objAccount.Id;
        objWk1.nm_StartDate__c = Date.today().addYears(-3);
        objWk1.nm_EndDate__c = Date.today().addYears(-1);
        objWk1.nm_CompanyName__c = 'fgjdffj';
        insert objWk1;
        System.debug('objWk1 --> '+ objWk1);
        
        nm_WorkExperience__c objWk4 = new nm_WorkExperience__c();
        objWk4.nm_Student__c = objAccount.Id;
        objWk4.nm_CompanyName__c = 'fgjdffj';
        insert objWk4;
        System.debug('objWk4 --> '+ objWk4);

        DELETE objWk1;
        DELETE objWk4;

        Test.stopTest();  
    }

}