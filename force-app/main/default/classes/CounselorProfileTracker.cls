/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-01-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class CounselorProfileTracker {

    @testSetup
    public static void setUpData(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);

        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce22.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);

        System.runAs(portalAccountOwner1) 
        {

            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
            Database.insert(portalAccount1);
        
            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,User_Role__c='Executive',
                Email = System.now().millisecond() + 'test@test.com'
            );
            Database.insert(contact1);
        
            //Create user
            List<Profile> ListProfile = [SELECT Id FROM Profile where Name='pp profile' limit 1];
            if(ListProfile.size() < 1) {
                ListProfile = [SELECT Id FROM Profile where Name='Information Center Partner Community User' limit 1];
            }
            Profile portalProfile = ListProfile[0];
                
            User user1 = new User(
                Username = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000)) + 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test2910',
                Email = 'test2910@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(user1);
                
            Counsellor_Profile__c cp = new Counsellor_Profile__c();
            cp.Salutation__c = 'Mr.';
            cp.First_Name__c = 'Test';
            cp.Last_Name__c = 'test';
            cp.OwnerId = user1.id;
            cp.Email__c='T29est123@gmail.com';
            cp.BusinessAccount__c = portalAccount1.id;
            cp.Employee_Sign_URL__c = 'www.google.com';
            insert cp;
        }

        // Counsellor_Profile__c objCP = new Counsellor_Profile__c();
        // objCP.First_Name__c = 'Test';
        // objCP.Last_Name__c = 'Test';

        // insert objCP;
    }

    @isTest
    static void unitTest1() {
        List<Counsellor_Profile__c> lstCP = [SELECT id,Profile_name__c FROM Counsellor_Profile__c LIMIT 1];
        System.debug(lstCP);
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id',lstCP[0].id);
            CounselorProfile obj = new CounselorProfile();
        Test.stopTest();
    }
}