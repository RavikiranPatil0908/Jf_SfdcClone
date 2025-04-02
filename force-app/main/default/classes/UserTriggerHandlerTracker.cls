@isTest
public class UserTriggerHandlerTracker {
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'nbsp57r', Email='balaorg@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='abpsg', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone='8989786756',
        TimeZoneSidKey='America/Los_Angeles', UserName='balaorg@testorg.com');
        insert objUser;
        objUser.Alias= 'trh';
        objUser.MobilePhone='3434345656';
        update objUser;
        string strrecord = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1].id;
        Account Acc = new Account(
        RecordTypeID=strrecord,
        FirstName='jane',
        LastName='doe',
        nm_PreStudentNo__c ='77213',
        nm_StudentStatus__c='Confirmed',
        nm_SerialNo__c=2,PersonMobilePhone='8377985721', 
        PersonEmail = 'test@test.com') ;
        insert Acc; 
        Contact objContact = new Contact();
        objContact.LastName = 'Acc';
        objContact.Account = Acc;
        objContact.MobilePhone='7878675645';
        insert objContact;
        
        Counsellor_Profile__c cp=new Counsellor_Profile__c();
        cp.MobilePhone__c='9089786756';
        insert cp;
        
        objContact.Counselor_Profile__c=cp.Id;
        update objContact;
        
    }

    @IsTest
    static void methodName(){
        Set<String> MobileNo=new set<String>();
        MobileNo.add('6767675656');
        Test.startTest();
        Contact obj = [SELECT Id,MobilePhone,Counselor_Profile__c FROM Contact LIMIT 1];
        Counsellor_Profile__c cp=[select id from Counsellor_Profile__c limit 1];
        obj.Counselor_Profile__c=cp.Id;
        update obj;
        UserTriggerHandler.updateToIsPartnerUserTrue(new Set<Id>{obj.Id});
        UserTriggerHandler.updateToIsPartnerUserFalse(new Set<Id>{obj.Id});
        UserTriggerHandler.updateCon(obj.Id,MobileNo);
        Test.stopTest();
        
    }
    
   
     
}