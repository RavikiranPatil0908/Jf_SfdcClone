@isTest(SeeAllData=false)
public class UsercenterByuserIdTracker{

    @testSetup
    public static void setUpData() {
        nm_Centers__c center  =  nmGenericTracker.CreateCenter('mumbai');
    }

    @isTest
    static void createUser() {

    nm_Centers__c objCenter = [SELECT Id FROM nm_Centers__c LIMIT 1];       

    UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
    insert r;
    Profile portalProfile = [Select Id from Profile where name = 'Information Center Partner Community User'];
    Contact portalContact;
    
    User thisUser = new User(Id=UserInfo.getUserId());
    thisUser.UserRoleId = r.Id;
    update thisUser;

    System.runAs(thisUser) {
        Account portalAccount = new Account(name = 'portalAccount');//create a portal account first
        insert portalAccount;
        portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id); //create a portal contact
        insert portalContact;
    }

    User u1 = new User( email='test@test.com',
                        profileid = portalProfile.Id, 
                        UserName='portalUser@portalTestUser.com', 
                        Alias = 'a',
                        TimeZoneSidKey='Australia/Sydney',
                        EmailEncodingKey='ISO-8859-1',
                        LocaleSidKey='en_US', 
                        LanguageLocaleKey='en_US',
                        ContactId = portalContact.Id,
                        FirstName = 'Test FirstName',
                        LastName = 'LastName'
                      );
    insert u1;

    System.runAs(thisUser) {
        nm_UserMapping__c testUserMapping = new nm_UserMapping__c(
            nm_User__c = u1.Id,
            nm_Centers__c = objCenter.Id
        );
        insert testUserMapping;
    }
    //User objUser = [SELECT Id FROM User LIMIT 1];
    String userId = u1.Id;
    List<UsercenterByuserId.FlowInputs> lst = new List<UsercenterByuserId.FlowInputs>();
    UsercenterByuserId.FlowInputs obj = new UsercenterByuserId.FlowInputs();
    obj.userId = userId;
    lst.add(obj);
    Test.startTest();
    UsercenterByuserId.getUserCenterByUserId(lst);    
    Test.stopTest();
        
    }
}