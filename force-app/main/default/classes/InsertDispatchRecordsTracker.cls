@isTest
public with sharing class InsertDispatchRecordsTracker {
    public static Stock_Keeping_Units__c stockUnit;
    public static Stock_Keeping_Units__c stockUnitOp;
    public static nmSerialNo__c objSerial;
    public static Stock__c stock1;
    public static Stock_Keeping_Units__c stockUnit1;
    public static Dispatch_Order__c dispatch;
    public static Stock__c stock2;
    public static Stock__c stock3;
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


    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        Account objAccount1 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');      

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount1,'admission');
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        User objUser = new User(Alias = 'newUser', Email='newuserSuperAdmin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 
        objopp.Dispatch_Order_For_Student__c= false;
        objopp.AutoCreateDispatchOrder__c= true;
        update objopp;
        
        
           
        stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDSCM-S4-JUL2014-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2014';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDSCM';
        stockUnit.Semester__c='4';
        
        insert stockUnit;
        
         stockUnit1 = new Stock_Keeping_Units__c();
        stockUnit1.Name = 'PGDSCM-S4-JUL2014-KIT';
        stockUnit1.Cost__c = 100;
        stockUnit1.Launch_Year__c = 'JUL2014';
        stockUnit1.Number_of_Pages__c = 50;
        stockUnit1.Type_Of_SKU__c = 'Kit';
        stockUnit1.Program__c = 'PGDSCM';
        stockUnit1.Semester__c='4';
        
        insert stockUnit1;
        
        program = new nm_Program__c();
        program.nmIsActive__c = true;
        program.Name = 'PGDSCM';
        program.nm_TotalSemesters__c = 4;
        program.nm_Type__c = 'Post Graduate Diploma Program';
        program.prgst__c ='JUL2014';
        
        insert program;
        
        centerLearningCenter = new nm_Centers__c();
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
        
        transitCenter= new nm_Centers__c();
        transitCenter.name = 'Transit Center';
        transitCenter.Nm_Active__c = true;
        transitCenter.nm_CenterCode__c = 'abcdhft';
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
        centerInformationCenter.nm_CenterCode__c = 'abcdmuy';
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
        
        stock3 = new Stock__c();
        stock3.Centers__c = transitCenter.id;
        stock3.Stock_Keeping_Unit__c = stockUnit.id;
        stock3.Quantity__c = 100;
        stock3.Outgoing_Quantity__c =0;
        stock3.Incoming_Quantity__c = 0;
        
        insert stock3;
        
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

    @IsTest
    static void methodName(){
    makeData();
        Opportunity objOpps = [select id,stageName,AutoCreateDispatchOrder__c,Dispatch_Order_For_Student__c from Opportunity limit 1];
         objOpps.AutoCreateDispatchOrder__c =true;
        objOpps.Dispatch_Order_For_Student__c =false;
        
        update objOpps;

        Test.startTest();
        InsertDispatchRecords instance = new InsertDispatchRecords();
        Database.executeBatch(instance,1);

      
        instance.sendErrorMail();
        Test.stopTest();
        
    }
        static testMethod void test3()
    {
        makeData();
        opps3 = new Opportunity();
        opps3.AccountID = objAccount.id;
        opps3.Name = 'OppsForSem1';
        opps3.StageName ='Closed Won';
        opps3.Dispatch_Order_For_Student__c= false;
        opps3.nm_Program__c = program.id;
        opps3.nm_Session__c= 'July';
        opps3.nm_Year__c    = 2018;
        opps3.nm_Semester__c = '4';
        opps3.nm_SelfLearningMaterial__c = 'Send to my shipping address';
        opps3.CloseDate = system.today();
        opps3.Dispatch_From_Center__c = centerLearningCenter.id;
        opps3.AutoCreateDispatchOrder__c =true;
        opps3.Dispatch_Order_For_Student__c =false;
        
        insert opps3;
        Test.StartTest();
        //stockUnitOp = new Stock_Keeping_Units__c();
      //  stockUnitOp = InsertDispatchRecords.getSkuByNameAndYear(program.Name,opps3.nm_Semester__c,opps3.Launch_Year__c);
               InsertDispatchRecords instance = new InsertDispatchRecords();
        Database.executeBatch(instance,1);

        Test.StopTest();    
    }

}