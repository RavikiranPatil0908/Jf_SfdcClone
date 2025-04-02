@isTest
public class DispatchForClosedWonTracker
{
    public static Stock_Keeping_Units__c stockUnit;
    public static Stock_Keeping_Units__c stockUnitOp;
    public static nmSerialNo__c objSerial;
    public static Stock__c stock1;
    public static Dispatch_Order__c dispatch;
    public static Stock__c stock2;
    public static nm_Centers__c centerLearningCenter;
    public static nm_Centers__c centerInformationCenter;
    public static nm_Centers__c transitCenter;
    public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
    public static RecordType accountRecord = [select id,name from RecordType where SObjectType='Account' and name ='Person Account'];
    public static Account objAccount;
    public static nm_Program__c program;
    public static User objUser;
    public static Opportunity opps;
    public static Opportunity opps2;
    public static Opportunity opps3;
    public static Opportunity opps4;   
    public static nm_UserMapping__c objUserMap;
    public static nm_EligiblityCriteria__c objEc;
    public static String output;
    public static String response;
    public DispatchForClosedWon dispatchForClosed;
     static testMethod void test1()
    {
        loadData();
        opps = new Opportunity();
        opps.AccountID = objAccount.id;
        opps.Name = 'OppsForSem1';
        opps.StageName ='Closed Won';
        opps.Dispatch_Order_For_Student__c= false;
        opps.nm_Program__c = program.id;
        opps.nm_Semester__c = '4';
        opps.nm_Session__c = 'January';
        opps.nm_Year__c =2019;
        opps.nm_SelfLearningMaterial__c = 'Send to my shipping address';
        opps.CloseDate = system.today();
        insert opps;
       
        Test.StartTest();  
        //DispatchForClosedWon.CreateDispatch(opps.id,'Mumbai - Thane West');
        response = DispatchForClosedWon.UpdateFinalQuantityOnCenter(centerInformationCenter.id,stockUnit.id);
        Test.StopTest();
        
    
    }   
   
    static testMethod void test3()
    {
        loadData();
        opps3 = new Opportunity();
        opps3.AccountID = objAccount.id;
        opps3.Name = 'OppsForSem1';
        opps3.StageName ='Closed Won';
        opps3.Dispatch_Order_For_Student__c= false;
        opps3.nm_Program__c = program.id;
        opps3.nm_Session__c= 'July';
        opps3.nm_Year__c    = 2018;
        opps3.nm_Semester__c = '3';
        opps3.nm_SelfLearningMaterial__c = 'Send to my Information Centre. I will pick up.';
        opps3.CloseDate = system.today();
        insert opps3;
        Test.StartTest();
        stockUnitOp = new Stock_Keeping_Units__c();
        stockUnitOp = DispatchForClosedWon.getSkuByNameAndYear(program.Name,opps3.nm_Semester__c,opps3.Launch_Year__c);
        Test.StopTest();    
    }
    static testMethod void test4()
    {
        loadData();
        Test.StartTest();
        DispatchForClosedWon.CheckStockAtFromCenter('PGDSCM','4','JUL2014','Mumbai - Thane West');
        boolean checkStock = DispatchForClosedWon.checkIfStockExists(centerLearningCenter.id,stockUnit.id);
        Test.StopTest();
    }
    
   static void loadData()
   {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        
        insert objUser;
        
           
        stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDSCM-S4-JUL2014-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2014';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDSCM';
        stockUnit.Semester__c='4';
        
        insert stockUnit;
        
        program = new nm_Program__c();
        program.nmIsActive__c = true;
        program.Name = 'PGDSCM';
        program.nm_TotalSemesters__c = 4;
        program.nm_Type__c = 'Post Graduate Diploma Program';
        
        insert program;
        
        centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Nm_Active__c = true;
        centerLearningCenter.nm_CenterCode__c = 'abcdsdf';
        centerLearningCenter.nm_City__c = 'Mumbai';
        centerLearningCenter.Contact_No_1__c = '9867167685';
        centerLearningCenter.nm_Country__c = 'India';
        centerLearningCenter.nm_StateProvince__c = 'Maharashtra';
        centerLearningCenter.nm_Street__c = 'Altmount Road';
        centerLearningCenter.nm_PostalCode__c = '400601';
        centerLearningCenter.RecordTypeID = learningCenter.id;
        
        insert centerLearningCenter;
        
        transitCenter= new nm_Centers__c();
        transitCenter.name = 'Transit Center';
        transitCenter.Nm_Active__c = true;
        transitCenter.nm_CenterCode__c = 'abcd5fg';
        transitCenter.nm_City__c = 'Mumbai';
        transitCenter.Contact_No_1__c = '9867167685';
        transitCenter.nm_Country__c = 'India';
        transitCenter.nm_StateProvince__c = 'Maharashtra';
        transitCenter.nm_Street__c = 'Altmount Road';
        transitCenter.nm_PostalCode__c = '400601';
        transitCenter.RecordTypeID = learningCenter.id;
        
        insert transitCenter;
        
        
        
        centerInformationCenter = new nm_Centers__c();
        centerInformationCenter.name = 'Mumbai - Thane West';
        centerInformationCenter.Nm_Active__c = true;
        centerInformationCenter.nm_CenterCode__c = 'abcdhj';
        centerInformationCenter.nm_City__c = 'Mumbai - Thane West';
        centerInformationCenter.Contact_No_1__c = '9867167685';
        centerInformationCenter.nm_Country__c = 'India';
        centerInformationCenter.nm_StateProvince__c = 'Maharashtra';
        centerInformationCenter.nm_LearningCenter__c = centerLearningCenter.id;
        centerInformationCenter.nm_Street__c = 'Altmount Road';
        centerInformationCenter.nm_PostalCode__c = '400601';
        centerInformationCenter.RecordTypeID = informationCenter.id;
        
        insert centerInformationCenter;
        
        objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=centerInformationCenter.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        
        insert objUserMap;
        
        stock1 = new Stock__c();
        stock1.Centers__c = centerLearningCenter.id;
        stock1.Stock_Keeping_Unit__c = stockUnit.id;
        stock1.Quantity__c = 100;
        stock1.Outgoing_Quantity__c =0;
        stock1.Incoming_Quantity__c = 0;
        
        insert stock1;
        
        stock2 = new Stock__c();
        stock2.Centers__c = centerInformationCenter.id;
        stock2.Stock_Keeping_Unit__c = stockUnit.id;
        stock2.Quantity__c = 100;
        stock2.Outgoing_Quantity__c =0;
        stock2.Incoming_Quantity__c = 0;
        
        insert stock2;
        
        objEc = new nm_EligiblityCriteria__c ();
         objEc.Name='NameEligibility Criteria';
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.Experience_Required_In_Year__c=2;
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c ='Certificate Programs';
         insert objEc;
        
        objAccount= new Account();
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Admission form & documents Approved';
        objAccount.PersonMobilePhone='8377985721';
        objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_SerialNo__c=2;
        objAccount.BatchStartD__c =System.today();
        objAccount.nm_Centers__c=centerInformationCenter.id;
        objAccount.nm_EligiblityCriteria__c =objEc.id;
       
        insert objAccount;
       
          objSerial = new nmSerialNo__c();
          //objSerial.Name=11111;
          objSerial.nm_MaxGenratedNo__c=122355;
          objSerial.nm_name__c='Fee Receipt Counter';
          insert objSerial;
   
   objSerial = new nmSerialNo__c();
          //objSerial.Name=11111;
          objSerial.nm_MaxGenratedNo__c=0;
          objSerial.nm_name__c='Reference Number';
          insert objSerial;
   
   }
  
   
  




}