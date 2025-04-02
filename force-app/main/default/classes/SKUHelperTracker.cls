@isTest(seeAllData = true)
public class SKUHelperTracker
{
    public static Stock_Keeping_Units__c stockUnit;
    public static Stock_Keeping_Units__c getSkuByNameAndYearVar;
    public static Stock_Keeping_Units__c getStockByNameAndYear;
    //public static Stock__c getStockById;
    public static Stock__c stockAtTransit;
    public static Stock__c createFreshStock;
    public static User objUser;
    public static Opportunity opps;
    public static nm_Centers__c centerLearningCenter;
    public static nm_Centers__c centerInformationCenter;
    public static nm_Centers__c transitInformationCenter = [select id from nm_Centers__c where name ='Transit Center'];
    public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
    public static RecordType accountRecord = [select id,name from RecordType where SObjectType='Account' and name ='Person Account'];
    public static Stock__c stockFrom;
    public static Stock__c stockTo;
    public static Account acc;
    public static boolean ifStockExists;
    public static boolean ifStockExistsTransit;
    public static nm_Program__c program;
    public static nm_EligiblityCriteria__c objEc;
    public static Dispatch_Order__c dispatchOrder;
    public static nm_UserMapping__c objUserMap;
    
    
    static testMethod void test1()
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
        stockUnit.Launch_Year__c = '2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='Semester 3';
        
        insert stockUnit;
        
        program = new nm_Program__c();
        program.nmIsActive__c = true;
        program.Name= 'PGDBFM';
        program.nm_TotalSemesters__c = 4;
        program.nm_Type__c = 'Post Graduate Diploma Program';
        
        insert program;
        
        centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Nm_Active__c = true;
        centerLearningCenter.nm_CenterCode__c = 'frdgd';
        centerLearningCenter.nm_City__c = 'Mumbai';
        centerLearningCenter.Contact_No_1__c = '9867167685';
        centerLearningCenter.nm_Country__c = 'India';
        centerLearningCenter.nm_StateProvince__c = 'Maharashtra';
        centerLearningCenter.nm_Street__c = 'Altmount Road';
        centerLearningCenter.nm_PostalCode__c = '400601';
        centerLearningCenter.RecordTypeID = learningCenter.id;
        
        insert centerLearningCenter;
        
        centerInformationCenter = new nm_Centers__c();
        centerInformationCenter.Nm_Active__c = true;
        centerInformationCenter.nm_CenterCode__c = 'adrgdgbcd';
        centerInformationCenter.nm_City__c = 'Mumbai Mira Road';
        centerInformationCenter.Contact_No_1__c = '9867167685';
        centerInformationCenter.nm_Country__c = 'India';
        centerInformationCenter.nm_StateProvince__c = 'Maharashtra';
        centerInformationCenter.nm_LearningCenter__c = centerLearningCenter.id;
        centerInformationCenter.nm_Street__c = 'Altmount Road';
        centerInformationCenter.nm_PostalCode__c = '400601';
        centerInformationCenter.RecordTypeID = informationCenter.id;
        
        insert centerInformationCenter;
        
        /*
        transitInformationCenter = new nm_Centers__c();
        transitInformationCenter.Nm_Active__c = true;
        transitInformationCenter.nm_CenterCode__c = 'abcd';
        transitInformationCenter.Name = 'Transit Center';
        transitInformationCenter.RecordTypeID = informationCenter.id;
        
        insert transitInformationCenter;
        */
        
        stockFrom = new Stock__c();
        stockFrom.Centers__c = centerLearningCenter.id;
        stockFrom.Incoming_Quantity__c = 0;
        stockFrom.Outgoing_Quantity__c = 0;
        stockFrom.Quantity__c = 500;
        stockFrom.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockFrom;
        
        stockAtTransit = new Stock__c();
        stockAtTransit.Centers__c = transitInformationCenter.id;
        stockAtTransit.Incoming_Quantity__c = 0;
        stockAtTransit.Outgoing_Quantity__c = 0;
        stockAtTransit.Quantity__c = 0;
        stockAtTransit.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockAtTransit;
        
        
        stockTo = new Stock__c();
        stockTo.Centers__c = centerInformationCenter.id;
        stockTo.Incoming_Quantity__c = 0;
        stockTo.Outgoing_Quantity__c = 0;
        stockTo.Quantity__c = 500;
        stockTo.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockTo;
        
        objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='NameEligibility Criteria';
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.Experience_Required_In_Year__c=2;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c ='Certificate Programs';
        insert objEc;  
        
        objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=centerInformationCenter.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        
        insert objUserMap;      
        
        acc = new Account();
        acc.LastName = 'Menon';
        acc.AccountNumber = '9930630174';
        acc.PersonEmail = 'vikasrmenon@gmail.com';
        acc.Agency__c = 'student';
        acc.nm_BloodGroup__c = 'B+';
        acc.nm_City__c = 'Mumbai';
        acc.nm_Gender__c = 'Male';
        acc.nm_Centers__c = centerInformationCenter.id;
        acc.Is_Lateral__c = false;
        // acc.Launch_Year__c = 'JUL2014';
        acc.nm_EligiblityCriteria__c = objEc.id;
        
        insert acc;
        
       
        
        opps = new Opportunity();
        opps.Name = 'Opps Student';
        opps.AccountID = acc.id;
        opps.StageName = 'Registration Done';
        opps.nm_Program__c = program.id;
        opps.nm_Semester__c = '3';
        opps.CloseDate = system.today();
        opps.nm_Session__c='July';
        opps.nm_Year__c=2020;

        insert opps;
        
        dispatchOrder = new Dispatch_Order__c();
        dispatchOrder.From_Centers__c = centerLearningCenter.id; 
        dispatchOrder.To_Centers__c = centerInformationCenter.id;
        dispatchOrder.Quantity__c = 100.0;
        dispatchOrder.Stock_Keeping_Unit__c = stockUnit.id;
        //dispatchOrder.To_Student__c = acc.id;
        dispatchOrder.Opportunity__c = opps.id;
        dispatchOrder.Order_Type__c = 'Transfer Order';
        
        insert dispatchOrder;
        
        
        SKUHelper ob = new SKUHelper();
      /*  getSkuByNameAndYearVar = new Stock_Keeping_Units__c();
        //getSkuByNameAndYearVar = ob.getSkuByNameAndYear(string.valueOf(opps.nm_Program__r.nm_ProgramName__c),integer.valueOf(opps.nm_Semester__c));
        
        
        
        ifStockExists = ob.checkIfStockExistsAtToCenter(centerInformationCenter.id,stockUnit.id);
        ifStockExists = ob.checkIfStockExistsAtFromCenter(centerInformationCenter.id,stockUnit.id);
        ifStockExistsTransit = ob.checkStockExistsAtTransitCenter(stockUnit.id);*/
        createFreshStock = ob.createFreshStock(centerLearningCenter.id,stockUnit.id);
        
        //ob.opportunityupdate(acc.id);
        
        ob.transitstage(stockFrom,stockAtTransit,dispatchOrder.Quantity__c,stockUnit.id);
        
        ob.deliverystage(stockFrom,stockTo,stockAtTransit,dispatchOrder.Quantity__c);
        
        ob.deliverystagewithouttocentre(stockFrom,stockAtTransit,dispatchOrder.Quantity__c);
        
        ob.ifStageIsCancelled(stockFrom,stockAtTransit,dispatchOrder.Quantity__c);
        
        
        getStockByNameAndYear = new Stock_Keeping_Units__c();
       // getStockByNameAndYear = ob.getSkuByNameAndYear(program.Name,opps.nm_Semester__c,acc.Launch_Year__c);
  
    }
}