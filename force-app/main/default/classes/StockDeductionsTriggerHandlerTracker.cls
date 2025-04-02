@isTest(SeeAllData = true)
public class StockDeductionsTriggerHandlerTracker
{
    public static Stock_Keeping_Units__c stockUnit;
    public static Stock_Keeping_Units__c stockUnit2; 
    public static Dispatch_Order__c dispatch;
    public static Stock__c stockFromCenter2;
    public static Stock__c stockFromCenter;
    public static Stock__c stockToCenter;
    public static Account objAccount;
    public static User objUser;
    public static nm_UserMapping__c objUserMap;
    public static nm_EligiblityCriteria__c objEc;
    public static Opportunity opps;
    public static nm_Program__c program; 
    public static nm_Centers__c centerLearningCenter;
    public static nm_Centers__c centerInformationCenter;
    public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
    public static RecordType accountRecord = [select id,name from RecordType where SObjectType='Account' and name ='Person Account'];
    
 
    /* static testMethod void test2()
     {
        Test.StartTest();
        loadData();
        dispatch = new Dispatch_Order__c();
        dispatch.Order_Type__c = 'Student Order';
        dispatch.Quantity__c = 1;
        dispatch.Status_Of_Dispatch__c = 'Transit';
        dispatch.From_Centers__c = centerLearningCenter.id;
        dispatch.Stock_Keeping_Unit__c = stockUnit.id;
        dispatch.To_Student__c=objAccount.id;
        insert dispatch;
        
        StockDeductionsTriggerHandler obj = new StockDeductionsTriggerHandler();
        Test.StopTest();
     } 
     
     static testMethod void test3()
     {
        Test.StartTest();
        loadData();
        dispatch = new Dispatch_Order__c();
        dispatch.Order_Type__c = 'Student Order';
        dispatch.Quantity__c = 1;
        dispatch.Status_Of_Dispatch__c = 'Transit';
        dispatch.From_Centers__c = centerLearningCenter.id;
       dispatch.To_Centers__c = centerInformationCenter.id;
        dispatch.Stock_Keeping_Unit__c = stockUnit.id;
         //dispatch.To_Student__c=objAccount.id;
        insert dispatch;
        
        StockDeductionsTriggerHandler obj = new StockDeductionsTriggerHandler();
        Test.StopTest();
      } 
  
    static testMethod void test6()
    {
    
        loadData();
        
        dispatch.Status_Of_Dispatch__c = 'Delivered';
        insert dispatch;
         
        StockDeductionsTriggerHandler obj = new StockDeductionsTriggerHandler();
    
    } */
     static testMethod void test7()
    {
    
        loadData();
        
        dispatch.Order_Type__c = 'Student Order';
        dispatch.Quantity__c = 1;
        dispatch.From_Centers__c = centerLearningCenter.id;
        dispatch.To_Centers__c = null;  
        dispatch.Status_Of_Dispatch__c = 'Returned Back';
        insert dispatch;
        StockDeductionsTriggerHandler obj = new StockDeductionsTriggerHandler();
        StockDeductionsTriggerHandler.sendSMS('8598565878','hii','test');
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
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        
        insert stockUnit;
        
        centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Name='Mumbai';
        centerLearningCenter.Nm_Active__c = true;
        centerLearningCenter.nm_CenterCode__c = 'abcdsef';
        centerLearningCenter.nm_City__c = 'Mumbai';
        centerLearningCenter.Contact_No_1__c = '9867167685';
        centerLearningCenter.nm_Country__c = 'India';
        centerLearningCenter.nm_StateProvince__c = 'Maharashtra';
        centerLearningCenter.nm_Street__c = 'Altmount Road';
        centerLearningCenter.nm_PostalCode__c = '400601';
        centerLearningCenter.RecordTypeID = learningCenter.id;
        
        insert centerLearningCenter;
        
        centerInformationCenter = new nm_Centers__c();
        centerInformationCenter.Name='Mumbai - Mira Road East';
        centerInformationCenter.Nm_Active__c = true;
        centerInformationCenter.nm_CenterCode__c = 'abcdgdrg';
        centerInformationCenter.nm_City__c = 'Mumbai - Mira Road East';
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
        
        program = new nm_Program__c();
        program.nmIsActive__c = true;
        program.nm_ProgramCode__c = 'test';
        program.nm_ProgramDuration__c= 2.0;
        program.nm_ProgramName__c = 'Post grad diploma finance';
        program.nm_ProgramValidity__c = 4;
        program.nm_TotalSemesters__c = 4;
        program.nm_Type__c = 'Post Graduate Diploma Program';
        
        insert program;
        
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
        objAccount.nm_Centers__c=centerInformationCenter.id;
        objAccount.nm_EligiblityCriteria__c =objEc.id;
        insert objAccount;
        
        dispatch = new Dispatch_Order__c();
        dispatch.Order_Type__c = 'Student Order';
        dispatch.Quantity__c = 1;
        dispatch.Status_Of_Dispatch__c = 'Transit';
        dispatch.From_Centers__c = centerLearningCenter.id;
        dispatch.Stock_Keeping_Unit__c = stockUnit.id;
        dispatch.To_Student__c=objAccount.id;
       // insert dispatch;
        
        opps = new Opportunity();
        opps.AccountID = objAccount.id;
        opps.StageName = 'Registration Done';
        opps.Name = 'OppsForSem1';
        opps.nm_Semester__c = '1';
        opps.Dispatch_Order_For_Student__c= false;
        opps.nm_Program__c = program.id;
        opps.nm_Semester__c = '3';
        opps.CloseDate = system.today();
        opps.nm_Session__c = 'July';
        opps.nm_Year__c =2014;
        opps.nm_Semester__c = '1';
        
        insert opps;
        
        stockFromCenter = new Stock__c();
        stockFromCenter.Centers__c = centerLearningCenter.id;
        stockFromCenter.Incoming_Quantity__c = 0;
        stockFromCenter.Outgoing_Quantity__c = 0;
        stockFromCenter.Quantity__c = 500;
        stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockFromCenter;
        
    
    }


}