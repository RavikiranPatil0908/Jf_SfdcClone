/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 21-12-2022
 * @last modified by  : @BK
**/
@istest
public class ContactUserRoleChangeHandlerTracker {
     @TestSetup
    static void makeData(){

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
      TimeZoneSidKey='America/Chicago',
      MobilePhone='9897654545'
    );
  Database.insert(portalAccountOwner1);

  System.runAs ( portalAccountOwner1 ) 
  {
    //Create account
    Account portalAccount1 = new Account(
    Name = 'TestAccount',
    OwnerId = portalAccountOwner1.Id
    );
    Database.insert(portalAccount1);
        
        

    //Create contact
    Contact contact1 = new Contact(
    FirstName = 'Test',
    Lastname = 'McTesty',
    MobilePhone ='9897878790',
    AccountId = portalAccount1.Id,User_Role__c='Executive',
    Email = System.now().millisecond() + 'test@test.com'
    );
    Database.insert(contact1);

    //Create user
   // Profile portalProfile = [SELECT Id FROM Profile where Name='pp profile' limit 1];
   Profile portalProfile = [SELECT Id FROM Profile where Name='Information Center Partner Community User' limit 1];
        
    User user1 = new User(
    Username = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000)) + 'test123456@test.com',
    ContactId = contact1.Id,
    ProfileId = portalProfile.Id,
    Alias = 'test2910',
    Email = 'test2910@test.com',
    EmailEncodingKey = 'UTF-8',
    LastName = 'McTesty',
    CommunityNickname = 'test12345',
    TimeZoneSidKey = 'America/Los_Angeles',
    LocaleSidKey = 'en_US',
    LanguageLocaleKey = 'en_US',
    MobilePhone='8989898978'
    );
    Database.insert(user1);
        
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.OwnerId = user1.id;
        cp.BusinessAccount__c = portalAccount1.id;
        cp.Employee_Sign_URL__c = 'www.google.com';
        cp.Email__c='test234@gmail.com';
        insert cp;
  }
}
    
     @IsTest
    static void methodName(){
   
        Test.startTest();
        Contact obj = [SELECT Id,User_Role__c FROM Contact LIMIT 1];
       
        List<Counsellor_Profile__c> lstCp = [SELECT Id,OwnerId ,MobilePhone__c FROM Counsellor_Profile__c];
        ContactUserRoleChangeHandler.updateUseRole(new Set<String>{obj.Id});
        obj.User_Role__c='User';
        obj.Counselor_Profile__c=lstCp[0].id;
        //obj.MobilePhone='9878765645';
        update obj;
        ContactUserRoleChangeHandler.updateUseRole(new Set<String>{obj.Id});
        
        Test.stopTest();
        
    }
    


}