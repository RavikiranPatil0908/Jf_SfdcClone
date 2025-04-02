/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 21-12-2022
 * @last modified by  : @BK
**/
@istest
public class ChangeCounselorProfileTracker {
         @TestSetup
    static void makeData(){

  UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
  system.debug('portalRole is ' + portalRole);

  Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
  User portalAccountOwner1 = new User(
      UserRoleId = portalRole.Id,
      ProfileId = profile1.Id,
      Username = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000)) + 'test28907@test.com',
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
    AccountId = portalAccount1.Id,User_Role__c='Executive',
    Email = System.now().millisecond() + 'test@test.com'
    );
    Database.insert(contact1);

    //Create user
    // Profile portalProfile = [SELECT Id FROM Profile where Name='pp profile' limit 1];
   Profile portalProfile = [SELECT Id FROM Profile where Name='Information Center Partner Community User' limit 1];
        
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
}
    
     @IsTest
    static void methodName(){
    
        Test.startTest();
        Contact obj = [SELECT Id,User_Role__c FROM Contact LIMIT 1];
        List<User> UserInfo=[select id,Name,Contact.Name, ContactId ,Email,Username , MobilePhone from User where ContactId=:obj.Id];
        List<Counsellor_Profile__c> lstCp = [SELECT Id,OwnerId,Email__c,Full_Name__c,MobilePhone__c FROM Counsellor_Profile__c];
        String nickName = 'Test123';
           User u=new User();
            u.Id=UserInfo[0].Id;
            u.FirstName= '';
            u.LastName= lstCp[0].Full_Name__c;
            u.MobilePhone= lstCp[0].MobilePhone__c;
            u.Username= String.valueOf((Integer)Math.floor(10000 + Math.random()*90000)) + lstCp[0].Email__c;
            u.Email= lstCp[0].Email__c;
            u.Phone=lstCp[0].MobilePhone__c;
            u.CommunityNickname = nickName;
            u.contactId=obj.Id;
            system.debug(' u.CommunityNickname==>'+ u.CommunityNickname);
           // update u;
        ChangeCounselorProfile.ChangeCounselorProfile(obj.Id,lstCp[0].Id);
        ChangeCounselorProfile.updateCP(obj.Id, lstCp[0].Id);
        ChangeCounselorProfile.updateUserInfo(obj.Id, lstCp[0].Id, u.id);
        
        Test.stopTest();
        
    }
    

}