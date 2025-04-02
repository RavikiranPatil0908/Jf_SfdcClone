@isTest
private class nmReRegistrationLateFees_loginTracker
{   
    static Account objAccount;
    static nm_EligiblityCriteria__c objEc;
    static Opportunity objopp;
    static nm_Program__c objProgram;
    static nmSerialNo__c serial; 
    
    static testmethod void registrationlatefee()
    {  
            serial =  new nmSerialNo__c();
            serial.nm_MaxGenratedNo__c =50;
            serial.nm_name__c = 'Fee Receipt Counter';            
            insert serial;
            serial =  new nmSerialNo__c();
            serial.nm_MaxGenratedNo__c =0;
            serial.nm_name__c = 'Reference Number';            
            insert serial;

      Load();
      nmReRegistrationLateFees_login obj = new nmReRegistrationLateFees_login();
      obj.objAccount.nm_StudentNo__c='345454';
      obj.objAccount.nm_DateOfBirth__c=system.today();
      obj.studentLogin();
      obj.objAccount.nm_StudentNo__c='';
      obj.objAccount.nm_DateOfBirth__c=system.today();
      obj.studentLogin();
      obj.objAccount.nm_StudentNo__c=null;
      obj.objAccount.nm_DateOfBirth__c=null;
      obj.studentLogin();
      
    
    }
    
    static void Load()
    {   
        objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='NameEligibility Criteria';
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c =    'Certificate Programs';
        insert objEc;    
        
        objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Registered';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonMobilePhone ='1002030120';
        objAccount.PersonEmail = 'lav.singh@saasfocus.com';
        objAccount.nm_EligiblityCriteria__c =objEc.id; 
        objAccount.nm_StudentNo__c = 'Lav';
        objAccount.nm_DateOfBirth__c = system.today();
        objAccount.nm_RegistrationNumber__c = '93434';
        objAccount.nm_StudentNo__c='345454';
        
        insert objAccount;
        
        objProgram = new nm_Program__c ();
        objProgram.Name = 'test4';
        objProgram.nmIsActive__c = true;
        insert objProgram;
        
        objopp = new opportunity();
        objopp.nm_Semester__c = '1';
        objopp.StageName = 'Emerson Student';
        objopp.AccountId = objAccount.Id;
        objopp.nm_Program__c =objProgram.id;
        objopp.nm_Year__c =1213;
        objopp.nm_Session__c = 'july';
        objopp.name = 'lav';
        objopp.CloseDate = system.today();
        //objopp.StageName = 'Closed Won';
       
        insert objopp ;
    }
}