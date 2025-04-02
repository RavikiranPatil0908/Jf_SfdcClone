@isTest
public class MassUpdateWelcomeKitControllerTracker
{
    public static Account objAccount;
    public static nmSerialNo__c objSerial;
    public static User objUser;
    public static nm_EligiblityCriteria__c eligibility;
    public static nm_UserMapping__c objUserMap;
    public static nm_Program__c program;
    public static nm_Centers__c objCen;
    public static Opportunity objopp;
    public List<string> getSemesterList;
    
    
    static testMethod void test1()
    {
         LoadData();
         //getSemesterList = ('Semester 1''Semester 2');
         PageReference pg = new PageReference('/apex/MassUpdateWelcomeKit');
         MassUpdateWelcomeKitController obj =new MassUpdateWelcomeKitController();
        // obj.getSemesterList ={'Semester 1','Semester 2'};
         //obj.getOptionList('Welcome Kit');
         obj.listOfStudentNumbers = '77116000222';
         obj.typeOfUpdate ='Welcome Kit';
         obj.UpdateStudentNumber();
         
    
    }
    static testMethod void test2()
    {
         LoadData();
         PageReference pg = new PageReference('/apex/MassUpdateWelcomeKit');
         MassUpdateWelcomeKitController obj =new MassUpdateWelcomeKitController();
         obj.getSemesterList();
         obj.getOptionList();
         obj.listOfStudentNumbers = '77116000222';
         obj.typeOfUpdate ='Fee Receipt';
         obj.UpdateStudentNumber();
         
         
    }
    
     static testMethod void test3()
    {
         LoadData();
         PageReference pg = new PageReference('/apex/MassUpdateWelcomeKit');
         MassUpdateWelcomeKitController obj =new MassUpdateWelcomeKitController();
         obj.getSemesterList();
         obj.getOptionList();
         obj.listOfStudentNumbers = '77116000222';
         obj.typeOfUpdate ='Letter Of UnderTaking';
         obj.UpdateStudentNumber();
    }     
     static testMethod void test4()
    {
         LoadData();
         PageReference pg = new PageReference('/apex/MassUpdateWelcomeKit');
         MassUpdateWelcomeKitController obj =new MassUpdateWelcomeKitController();
         obj.getSemesterList();
         obj.getOptionList();
         obj.listOfStudentNumbers = '77116000222';
         obj.typeOfUpdate ='Program Change Waive Off';
         obj.UpdateStudentNumber();
    }     
     static testMethod void test5()
    {
         LoadData();
         PageReference pg = new PageReference('/apex/MassUpdateWelcomeKit');
         MassUpdateWelcomeKitController obj =new MassUpdateWelcomeKitController();
         obj.getSemesterList();
         obj.getOptionList();
         obj.listOfStudentNumbers = '77116000222';
         obj.typeOfUpdate ='Hard Copy Recieved';
         obj.UpdateStudentNumber();
    }     
    
    static void LoadData()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        insert objUser;    
        
        
      
         Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
         objCen= new nm_Centers__c();
         objCen.RecordTypeID = RT.id;         
         objCen.nm_CenterCode__c = '002';
         objCen.nm_CenterCity__c = 'Delhi';
         objCen.nm_City__c = 'Delhi';
         objCen.nm_StateProvince__c = 'Delhi';
         objCen.nm_Street__c = 'Krishna Nagar';
         objCen.nm_PostalCode__c = '110051';
        // objCen.Owner=objUser;
         
         insert objCen;
         
         objUserMap= new nm_UserMapping__c();
          objUserMap.nm_Centers__c=objCen.id;
          objUserMap.nm_User__c=objUser.id;
          objUserMap.nm_Phone__c='326392156';
          objUserMap.nm_Head__c= true;
          insert objUserMap;
         
          
        eligibility = new nm_EligiblityCriteria__c();
        CommonTrackerClass.createEligibiltyCriteria(eligibility);
        
       program = new nm_Program__c();
       CommonTrackerClass.createProgram(program);
       
            objSerial = new nmSerialNo__c();
            //objSerial.Name=11111;
            objSerial.nm_MaxGenratedNo__c=122355;
            objSerial.nm_name__c='Fee Receipt Counter';
            insert objSerial;
             objSerial = new nmSerialNo__c();
            objSerial.nm_MaxGenratedNo__c=0;
            objSerial.nm_name__c='Reference Number';
            insert objSerial;
        
        objAccount = new Account();
        
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77116';
        objAccount.nm_StudentNo__c = '77116000222';
        objAccount.nm_StudentStatus__c='Registered';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonMobilePhone ='1002030120';
        objAccount.PersonEmail = 'lav.singh@saasfocus.com'; 
        objAccount .nm_Centers__c= objCen.id;
        objAccount.nm_DateOfBirth__c = system.today();
        objAccount.nm_RegistrationNumber__c = '93434';
        objAccount.nm_Program__c=program.id;
        objAccount.Letter_Of_Undertaking__c = true;
        objAccount.nm_EligiblityCriteria__c=eligibility.id;
        objAccount.Welcome_Kit_dispatched__c = true;
        //objAccount.OwnerId= usr.id;                  
        insert objAccount;
        
        objopp= new Opportunity();
        objopp.AccountId=objAccount.id;
        objopp.Amount=1700;
        objopp.nm_ModeOfPayment__c='Demand Draft';
        objopp.nm_Year__c=2016;
        objopp.nm_Session__c='July';
        objopp.nm_Semester__c = '1';
        objopp.nm_InformationCenters__c=objCen.id;
        objopp.Fee_Receipt_Dispatched__c = true;
        objopp.Fee_Receipt_Dispatched_Date__c = system.today();
        objopp.nm_Program__c=program.id;
        //objopp.nm_StudentProgram__c=objstudentprog.id;
        objopp.StageName='Payment Approved';
        objopp.CloseDate=system.today()+10;
        objopp.Name='Tets_Ting_PGDITM_Sem_1_January_2016';
        insert objopp;
    
    }
    
}