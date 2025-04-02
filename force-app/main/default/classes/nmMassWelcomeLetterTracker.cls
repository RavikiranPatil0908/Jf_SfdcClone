@isTest
public class nmMassWelcomeLetterTracker 
{
    public static Account objAccount;
    static testmethod void UnitTest()
    {
        LoadData();
        Mass_Welcome obj =new Mass_Welcome ();
        obj.FindRecordsUsingStudentNo('view');
        obj.search();
        obj.find();
       //obj.getResults();
    }  
    static testmethod void UnitTest1()
    {
        LoadData();
        Mass_Welcome obj =new Mass_Welcome ();
        obj.startDT='2016-2-3';
        obj.enddt ='2016-2-4';
        obj.search();
        obj.find();
        //obj.getResults();
    } 
    static void LoadData()
    {
        objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.Salutation ='Mrs.';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Registered';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonMobilePhone ='1002030120';
        objAccount.PersonEmail = 'lav.singh@saasfocus.com'; 
        objAccount.nm_StudentNo__c = 'Lav';
        //objAccount.nm_Centers__c= objCen.id;
        objAccount.nm_DateOfBirth__c = system.today();
        objAccount.nm_RegistrationNumber__c = '93434';
        objAccount.nm_StudentNo__c='345454';
        objAccount.Account_Confirm_Date__c=system.today();
        //objAccount.nm_Program__c=program.id;
        //objAccount.nm_EligiblityCriteria__c=eligibility.Id;     
        insert objAccount;    
    }

   /* 
    private static testmethod  void unitTest1()
    {
        Mass_Welcome controller = new Mass_Welcome();
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        System.assertEquals(controller.find(),null); 
        
        String startingstudentno;
        String endingstudentno;            
        Mass_Welcome obj =new Mass_Welcome ();
        
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('77214000072');
        obj.setEndingStudentNo('77214000079');
 Account objAccount=new Account();
 List<Account> results;
 results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];
       startingstudentno='77214000072';
       endingstudentno='77214000079';
       obj.search();
        obj.find();   
    }
     private static testmethod  void unitTest2()
    {
        Mass_Welcome controller = new Mass_Welcome();   
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        System.assertEquals(controller.find(),null);    
        String startingstudentno;
        String endingstudentno;
                   
       Mass_Welcome obj =new Mass_Welcome ();                          
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('77214000089');
        obj.setEndingStudentNo('77214000023');
   
 Account objAccount=new Account();
    
 List<Account> results;

results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];
if(startingstudentno>endingstudentno)
     System.assert(ApexPages.hasMessages());
      startingstudentno='77214000089';
       endingstudentno='77214000023';   
       obj.search();
        obj.find();
    }
     private static testmethod  void unitTest3()
    {
         Mass_Welcome controller = new Mass_Welcome();
        //controller.username = 'test@salesforce.com';
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        System.assertEquals(controller.find(),null); 
        
      String startingstudentno;
      String endingstudentno;
             
       Mass_Welcome obj =new Mass_Welcome ();
        
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('');
        obj.setEndingStudentNo('77214000075');   
   Account objAccount=new Account();
   List<Account> results;

results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];
 if(startingstudentno == '' || endingstudentno == '')
       System.assert(ApexPages.hasMessages());
       startingstudentno='';
       endingstudentno='77214000075';
    }
    private static testmethod  void unitTest4()
    {
     Mass_Welcome controller = new Mass_Welcome();
        //controller.username = 'test@salesforce.com';
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        System.assertEquals(controller.find(),null); 
        
      String startingstudentno;
      String endingstudentno;
             
       Mass_Welcome obj =new Mass_Welcome ();
        
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('77214000067');
        obj.setEndingStudentNo('');
   
  

 Account objAccount=new Account();
    
 List<Account> results;

results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];
if(startingstudentno == '' || endingstudentno == '')
    System.assert(ApexPages.hasMessages());
      startingstudentno='77214000067';
       endingstudentno='';
      
         obj.search();
        obj.find();
    
    }
    private static testmethod  void unitTest5()
    {
     Mass_Welcome controller = new Mass_Welcome();
        //controller.username = 'test@salesforce.com';
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        System.assertEquals(controller.find(),null); 
        
      String startingstudentno;
      String endingstudentno;
             
       Mass_Welcome obj =new Mass_Welcome ();
        
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('');
        obj.setEndingStudentNo('');

 Account objAccount=new Account();
    
 List<Account> results;

results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];
if(startingstudentno == '' || endingstudentno == '')
    System.assert(ApexPages.hasMessages());
      startingstudentno='';
       endingstudentno='';
       obj.search();
        obj.find();

    }
    private static testmethod  void unitTest6()
    {
      String startingstudentno;
      String endingstudentno;
             
       Mass_Welcome obj =new Mass_Welcome ();
        
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('77214000011');
        obj.setEndingStudentNo('77214000011');

 Account objAccount=new Account();
    
 List<Account> results;

results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];

      startingstudentno='77214000011';
       endingstudentno='77214000011';
    
    }
     private static testmethod  void unitTest7()
    {
      String startingstudentno;
      String endingstudentno;
             
       Mass_Welcome obj =new Mass_Welcome ();
        
        obj.search();
        obj.find();
        obj.getStartingStudentNo();
        obj.getEndingStudentNo();
        obj.getResults();
        obj.setStartingStudentNo('8970011');
        obj.setEndingStudentNo('789011');

 Account objAccount=new Account();
    
 List<Account> results;

results = [select id,account.name,nm_StudentNo__c,nm_Password__c,PDF_Date__c, FirstName, nm_MiddleName__c
                                   from Account
                                   where  (nm_StudentNo__c >=:startingstudentno and nm_StudentNo__c  <=:endingstudentno) 
                                   ORDER BY nm_StudentNo__c ASC ];

      startingstudentno='8970011';
       endingstudentno='789011';
    
    }
    */
}