/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 08-17-2024
 * @last modified by  : Ravi
**/
@isTest(SeeAllData=false)
public class PartnerLeadBulkControllerTracker {

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
    List<PartnerLeadBulkController.InputVariables> lst = new List<PartnerLeadBulkController.InputVariables>();
    PartnerLeadBulkController.InputVariables obj = new PartnerLeadBulkController.InputVariables();
    obj.UserIds = userId;
    lst.add(obj);

    Blob csvFileBody = null;
    Blob csvFileBody2 = null;
    String csvContent = 'First Name,Last Name,Email,MOBILEPHONE,Choose a Program,Agency\n'+
                        'Ganesh,mourya,gm@gmail.com,9892433630,Master Programs,abc\n'+
                        'Govind,Dev,gd@gmail.com,1144585578,Bachelor Programs,xyz\n'+
                        'Gauranga,mishra,gm@gmail.com,8974364827,MBA (Online) Programs,ijk';    
    csvFileBody = Blob.valueOf(csvContent);

    String csvContent2 = 'Last Name,Email,MOBILEPHONE,Choose a Program,Agency\n'+
                        'Ganesh,mourya,gm@gmail.com,9892433630,Master Programs,abc\n'+
                        'Govind,Dev,gd@gmail.com,1144585578,Bachelor Programs,xyz\n'+
                        'Gauranga,mishra,gm@gmail.com,8974364827,MBA (Online) Programs,ijk';    
    csvFileBody2 = Blob.valueOf(csvContent2);

    Test.startTest();
        PartnerLeadBulkController objTracker = new PartnerLeadBulkController();
        objTracker.UserId = u1.Id;
        objTracker.csvFileBody = csvFileBody;
        objTracker.importCSVFile();
        
        List<String> result = PartnerLeadBulkController.getInformationCenters(lst);

        PartnerLeadBulkController objTracker2 = new PartnerLeadBulkController();
        objTracker2.UserId = u1.Id;
        objTracker2.csvFileBody = csvFileBody2;
        objTracker2.importCSVFile();
    Test.stopTest();
        
    }
     
    
}