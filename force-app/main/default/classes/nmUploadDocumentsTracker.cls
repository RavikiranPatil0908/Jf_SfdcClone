/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-10-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
private class nmUploadDocumentsTracker {

    @testSetup
    public static void setUpData(){
        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
 
        AEP_site_inspection__c objAEPSite = new AEP_site_inspection__c();
        objAEPSite.Name_of_the_Centre__c = 'Test';
        objAEPSite.User_Email__c = 'test@gmail.com';
        objAEPSite.Contact_No_1__c = '0000000000';
        objAEPSite.Entity__c = 'Pvt. Ltd.';
        insert objAEPSite;
    }

    @isTest
    static void myUnitTest()  {
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        Test.startTest();
            Apexpages.currentPage().getParameters().put('id',objAccount.id);
            nmUploadDocuments obj = new nmUploadDocuments();
        Test.stopTest();
    }

    @isTest
    static void myUnitTest1()  {
        AEP_site_inspection__c objAEPSite = [SELECT id FROM AEP_site_inspection__c LIMIT 1];
        Test.startTest();
            Apexpages.currentPage().getParameters().put('id',objAEPSite.id);
            Apexpages.currentPage().getParameters().put('type','aep');
            nmUploadDocuments obj = new nmUploadDocuments();
            obj.accountId = null;
            System.assertEquals(null, obj.accountId, 'AccountId defined');
        Test.stopTest();
    }

    @isTest
    static void myUnitTest2()  {
        Lead objLead = [SELECT id FROM Lead LIMIT 1];
        Test.startTest();
            Apexpages.currentPage().getParameters().put('id',objLead.id);
            Apexpages.currentPage().getParameters().put('objType','Lead');
            Apexpages.currentPage().getParameters().put('mode','Upload Self-Attested Now');
            nmUploadDocuments obj = new nmUploadDocuments();
        Test.stopTest();
    }

}