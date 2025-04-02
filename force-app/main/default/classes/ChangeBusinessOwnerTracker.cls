@isTest
public class ChangeBusinessOwnerTracker {


   @TestSetup
    static void makeData(){
        Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com');
        insert objBusinessAccount;

        

        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        nm_Centers__c objCen = nmGenericTracker.CreateCenter('Mumbai - vashi');
        User objUser = new User(Alias = 'newUser', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 

        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.OwnerId = objUser.id;
        cp.BusinessAccount__c = objBusinessAccount.id;
        cp.AEP_Name__c = objCen.Id ;
        cp.Employee_Sign_URL__c = 'www.google.com';
        insert cp;

        Contact objContact = new Contact(LastName= 'Head Office', Counselor_Profile__c = cp.Id, AccountId = objBusinessAccount.Id, Email = 'standarduser@testorg.com' );
        insert objContact;
        
        
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=objCen.Id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        // objUserMap.nm_Head__c= true;
        insert objUserMap;
    }

    @IsTest
    static void methodName(){
        List<Account> lstAcc= [SELECT Id FROM Account];
        List<Contact> lstCon = [SELECT Id FROM Contact];
        List<Counsellor_Profile__c> lstCp = [SELECT Id,OwnerId FROM Counsellor_Profile__c];
        System.debug('lstAcc ==> ' +lstAcc);
        System.debug('lstCon ==> ' +lstCon);
        Test.startTest();
            ChangeBusinessOwner.ChangeBusinessOwner(lstCon[0].Id,lstAcc[0].Id);
            ChangeContactAccount.ChangeContactAccount(lstCon[0].Id,lstAcc[0].Id);
        Test.stopTest();
        
    }
    
}