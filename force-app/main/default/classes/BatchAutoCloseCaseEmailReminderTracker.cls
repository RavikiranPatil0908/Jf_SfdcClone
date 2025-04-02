@isTest
public class BatchAutoCloseCaseEmailReminderTracker {
    @isTest 
    static void unitTest1(){
        
   /*Profile p = [SELECT Id FROM Profile WHERE Name='NMIMS Profile']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NMIMS Site Guest User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg11.com');
     insert u;*/

    Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
       objAccount.PersonEmail='shindeswati2910@gmail.com';
        objAccount.IsPartner=False;
        update objAccount;
        
        Contact newContact = [SELECT Id,FirstName,LastName,email FROM Contact WHERE AccountId = :objAccount.Id];
        newContact.Email='shindeswati@gmail.com';
         update newContact;   
    String ticketing = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        List<Lead> lstLead = [SELECT id,Email FROM Lead LIMIT 1];
        List<Account> lstAcc = [SELECT id,PersonEmail FROM Account LIMIT 1];
        system.debug('Acc Id='+lstAcc[0].Id);
        Case objcase2 = new Case();
            objcase2.Expected_Close_Date__c = null;
            objcase2.recordTypeId = ticketing;
            objcase2.StudentZone_QueryId__c ='2261';
          //  objcase2.SuppliedEmail = lstLead[0].Email;
            objcase2.Description = 'Zero Books Admission';
            objcase2.Student_Category__c='Academics';
            objcase2.Student_Sub_Categories__c = 'Faculty feedback';
            objcase2.Subject='Test';
            objcase2.Email_Reminder_DateTime__c=System.today() - 2;
            //objcase2.Lead__c=lstLead[0].id;
            objcase2.AccountId=lstAcc[0].id;
            objcase2.contactId=newContact.Id;
            objcase2.Tech_Issue__c='No';
            objcase2.Status='In Progress';
            insert objcase2;
        system.debug('objcase2 ContactEmail==>'+objcase2.ContactEmail);
        system.debug('objcase2 Account==>'+objcase2.AccountId);
        // System.runAs(u) {
        CaseComment  caseComment1 = new CaseComment(ParentId = objcase2.Id, CommentBody = 'test');
            insert caseComment1;
     // }
        BatchAutoCloseCaseEmailReminder b=new BatchAutoCloseCaseEmailReminder();
        Database.ExecuteBatch(b);
    }
    
    @isTest 
    static void unitTest2(){
    Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
       objAccount.PersonEmail='shindeswati2910@gmail.com';
        objAccount.IsPartner=False;
        update objAccount;
        
        Contact newContact = [SELECT Id,FirstName,LastName,email FROM Contact WHERE AccountId = :objAccount.Id];
        newContact.Email='shindeswati@gmail.com';
         update newContact;   
    String ticketing = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        List<Lead> lstLead = [SELECT id,Email FROM Lead LIMIT 1];
        List<Account> lstAcc = [SELECT id,PersonEmail FROM Account LIMIT 1];
        system.debug('Acc Id='+lstAcc[0].Id);
        Case objcase2 = new Case();
            objcase2.Expected_Close_Date__c = null;
            objcase2.recordTypeId = ticketing;
            objcase2.StudentZone_QueryId__c ='2261';
          //  objcase2.SuppliedEmail = lstLead[0].Email;
            objcase2.Description = 'Zero Books Admission';
            objcase2.Student_Category__c='Academics';
            objcase2.Student_Sub_Categories__c = 'Faculty feedback';
            objcase2.Subject='Test';
            objcase2.Email_Reminder_DateTime__c=System.today() - 4;
            //objcase2.Lead__c=lstLead[0].id;
            objcase2.AccountId=lstAcc[0].id;
            objcase2.contactId=newContact.Id;
            objcase2.Tech_Issue__c='Yes';
            objcase2.Status='In Progress';
            insert objcase2;
        system.debug('objcase2 ContactEmail==>'+objcase2.ContactEmail);
        system.debug('objcase2 Account==>'+objcase2.AccountId);
      
        CaseComment  caseComment1 = new CaseComment(ParentId = objcase2.Id, CommentBody = 'test');
            insert caseComment1;
        BatchAutoCloseCaseEmailReminder b=new BatchAutoCloseCaseEmailReminder();
        Database.ExecuteBatch(b);
    }

}