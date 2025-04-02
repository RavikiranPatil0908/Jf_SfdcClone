/**
 * @File Name          : nmGenericTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 30-04-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/4/2019, 3:51:42 PM   Bala     Initial Version
**/
@IsTest
public class nmGenericTracker
{
    private CryptoUtils CryptoUtils = new CryptoUtils();
    public static Lead CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral(String IsDefence,boolean IsLateral)
    {
        nm_Program__c objProgram = CreatePGDiplomaProgram();
        nm_Centers__c objCen = CreateCenter('Mumbai - vashi');

        nm_EligiblityCriteria__c  objEc = CreateElegibilityCriteriaforMaster(objProgram.nm_Type__c);
        Lead objLead = new  Lead();
        objLead.nm_SelectedIC__c ='Mumbai';
         objLead.nm_Program__c=objProgram.id;
         objLead.Salutation='Mr';
         objLead.nm_DateOfBirth__c = date.newInstance(1990, 12, 9);
         objLead.nm_Semester__c = '1';
         objLead.LastName ='kumar';
         objLead.FirstName='amit';
        // objLead.nm_MiddleName__c = 'test';
         objLead.Father_Salutation__c='Mr.';
         objLead.Mother_Salutation__c='Ms.';
         objLead.Mother_Last_Name__c='test';
         objLead.status='Reborn';
         objLead.nm_Class12OrDiploma__c ='XII/HSC';
         objLead.nm_Class12OrDiploma__c='Diploma';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.City='noida';
         objLead.nm_Stream__c='hgfgc';
         objLead.nm_Gender__c = 'Male';
         objLead.nm_ChooseaProgram__c =objProgram.nm_Type__c;
         objLead.nm_EligiblityCriteria__c = objEc.id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_NameofBoard12__c='hvh';
         objLead.nm_SelectedProgram__c ='ccc';
         objLead.nm_InformationCenter__c =objCen.id;
         objLead.OwnerId= objCen.OwnerId;
         objLead.nm_Year__c =2017;
         objLead.LeadSource ='Web';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=3;
         objLead.nm_MaritalStatus__c ='Married';
         objLead.nm_Nationality__c='Indian';
       // objLead.nm_FathersName__c='test';
         objLead.Father_First_Name__c='hgvghv';
        objLead.Mother_First_Name__c ='cfgcfg';
       // objLead.nm_MothersName__c='test';
        objLead.nm_BloodGroup__c='test';
        objLead.nm_LocalityName__c='test';
        objLead.nm_Domicile__c='test';
        objLead.PostalCode='123456';
        objLead.nm_NearestLandmark__c='test';
        objLead.State='Goa';
        objLead.Country='India';
        objLead.Street='test';
        objLead.nm_Category__c='General';
        objLead.nm_12thClassStateBoardName__c='dsfd';
        objLead.nm_10thClassStateBoardName__c='ghftf';
        objLead.nm_10thPercentage__c=77.00;
        objLead.nm_12thPercentage__c =66.00;
        objLead.nm_NameofSchool__c='test';
        objLead.nm_NameofSchool12__c='test';
        objLead.nm_NameofBoard__c='CBSE';
        objLead.nm_YearofCompletion__c='2014';
        objLead.nm_DiplomaName__c='test';
        objLead.nm_StreamDiploma__c='test';
        objLead.nm_DiplomaSchoolCollegeUniversityname__c='test';
        objLead.Result_Diploma__c=6;
        objLead.nm_DurationOfDiploma__c=8;
        objLead.nm_DiplomaYearOfCompletion__c=2014;
        objLead.nm_HouseNumber_P__c='2';
        objLead.nm_YearofCompletion12__c='1';
        objLead.nm_Street_P__c='test';
        objLead.nm_City_P__c='test';
        objLead.nm_StateProvince_P__c='test';
        objLead.nm_PostalCode_P__c='400049';
        objLead.nm_Country_P__c='India';
        objLead.Father_Last_Name__c='fgcff';
        objLead.nm_LocalityName_P__c='test';
        objLead.nm_NearestLandmark_P__c='test';
        objLead.House_No_Name_Shipping__c='2';
        objLead.Shipping_Street__c='test';
        objLead.Shipping_City__c='test';
        objLead.State_Province_Shipping__c='test';
        objLead.Zip_Postal_Code_Shipping__c='400043';
        objLead.Country_Shipping__c='India';
        objLead.Locality_Name_Shipping__c='test';
        objLead.Nearest_LandMark_Shipping__c ='test';
        objLead.Are_you_from_Defence__c ='Yes';
        objLead.nm_ServiceNumber__c ='test';
        objLead.Relationship__c ='self';
        objLead.nm_DateofCommission__c =System.today();
        objLead.Armed_Service__c ='test';
        objLead.Rank__c ='test';
        objLead.nm_HouseNumber__c='2';
        objLead.Is_Lateral__c = true;
        objLead.nm_Street_P__c='test';
        objLead.nm_RegistrationID__c='a0BN0000001FUdB';
        objLead.Have_you_ever_registered_with_us_before__c = 'No';
        objLead.smsSendTime__c = system.now();
        objLead.Sms_Status__c = 'Success';
        objLead.Student_Plan_to_Start__c ='1 week';
        objLead.Reason_for_not_joining__c = 'Looking for full time course only';
        objLead.Other_Reason_for_not_joining__c = 'Test';
        objLead.Student_Define_Date_Time__c = null;      
        insert objLead;
        return objLead;
    }
    

    public static Lead CreateLeadWithProgramAndCenterForMasterProg()
    {
        nm_Program__c objProgram = CreateDegreeProgram();
        nm_Centers__c objCen = CreateCenter('Mumbai - mulund',true);

        nm_EligiblityCriteria__c  objEc = CreateElegibilityCriteriaforMaster('Master Programs');
        Lead objLead = new  Lead();
        objLead.nm_SelectedIC__c ='Mumbai';
         objLead.nm_Program__c=objProgram.id;
         objLead.Salutation='Mr';
         objLead.nm_DateOfBirth__c = date.newInstance(1990, 12, 9);
         objLead.nm_Semester__c = '1';
         objLead.LastName ='singh';
         objLead.FirstName='sunil';
        // objLead.nm_MiddleName__c = 'test';
         objLead.Father_Salutation__c='Mr.';
         objLead.Mother_Salutation__c='Ms.';
         objLead.Mother_Last_Name__c='test';
         objLead.status='Reborn';
         objLead.nm_Class12OrDiploma__c ='XII/HSC';
         objLead.nm_Class12OrDiploma__c='Diploma';
         objLead.Email='sunil.singh@gmail.com';
         objLead.MobilePhone ='8377985722';
         objLead.City='noida';
         objLead.nm_Stream__c='hgfgc';
         objLead.nm_Gender__c = 'Male';
         objLead.nm_ChooseaProgram__c ='Master Programs';
         objLead.nm_EligiblityCriteria__c = objEc.id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_NameofBoard12__c='hvh';
         objLead.nm_SelectedProgram__c ='ccc';
         objLead.nm_InformationCenter__c =objCen.id;
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Web';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=3;
         objLead.nm_MaritalStatus__c ='Married';
         objLead.nm_Nationality__c='Indian';
      //  objLead.nm_FathersName__c='test';
         objLead.Father_First_Name__c='hgvghv';
        objLead.Mother_First_Name__c ='cfgcfg';
        //objLead.nm_MothersName__c='test';
        objLead.nm_BloodGroup__c='test';
        objLead.nm_LocalityName__c='test';
        objLead.nm_Domicile__c='test';
        objLead.PostalCode='123456';
        objLead.nm_NearestLandmark__c='test';
        objLead.State='Goa';
        objLead.Country='India';
        objLead.Street='test';
        objLead.nm_Category__c='General';
        objLead.nm_12thClassStateBoardName__c='dsfd';
        objLead.nm_10thClassStateBoardName__c='ghftf';
        objLead.nm_10thPercentage__c=77.00;
        objLead.nm_12thPercentage__c =66.00;
        objLead.nm_NameofSchool__c='test';
        objLead.nm_NameofSchool12__c='test';
        objLead.nm_NameofBoard__c='CBSE';
        objLead.nm_YearofCompletion__c='2014';
        objLead.nm_DiplomaName__c='test';
        objLead.nm_StreamDiploma__c='test';
        objLead.nm_DiplomaSchoolCollegeUniversityname__c='test';
        objLead.Result_Diploma__c=6;
        objLead.nm_DurationOfDiploma__c=8;
        objLead.nm_DiplomaYearOfCompletion__c=2014;
        objLead.nm_HouseNumber_P__c='2';
        objLead.nm_YearofCompletion12__c='1';
        objLead.nm_Street_P__c='test';
        objLead.nm_City_P__c='test';
        objLead.nm_StateProvince_P__c='test';
        objLead.nm_PostalCode_P__c='400049';
        objLead.nm_Country_P__c='India';
        objLead.Father_Last_Name__c='fgcff';
        objLead.nm_LocalityName_P__c='test';
        objLead.nm_NearestLandmark_P__c='test';
        objLead.House_No_Name_Shipping__c='2';
        objLead.Shipping_Street__c='test';
        objLead.Shipping_City__c='test';
        objLead.State_Province_Shipping__c='test';
        objLead.Zip_Postal_Code_Shipping__c='400043';
        objLead.Country_Shipping__c='India';
        objLead.Locality_Name_Shipping__c='test';
        objLead.Nearest_LandMark_Shipping__c ='test';
        objLead.Are_you_from_Defence__c ='Yes';
        objLead.nm_ServiceNumber__c ='test';
        objLead.Relationship__c ='self';
        objLead.nm_DateofCommission__c =System.today();
        objLead.Armed_Service__c ='test';
        objLead.Rank__c ='test';
        objLead.nm_HouseNumber__c='2';
        objLead.Is_Lateral__c = true;
        objLead.nm_Street_P__c='test';
        objLead.nm_RegistrationID__c='a0BN0000001FUdB';
        objLead.Have_you_ever_registered_with_us_before__c = 'No';
        objLead.smsSendTime__c = system.now();
        objLead.Sms_Status__c = 'Success';
        objLead.Student_Plan_to_Start__c ='1 week';
        objLead.Reason_for_not_joining__c = 'Looking for full time course only';
        objLead.Other_Reason_for_not_joining__c = 'Test';
        objLead.Student_Define_Date_Time__c = null;
                    
        insert objLead;
        return objLead;
    }

    public static void CreateICAndUser( nm_Centers__c objCen)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        insert objUser; 
        
      nm_UserMapping__c objUserMap= new nm_UserMapping__c();
      objUserMap.nm_Centers__c=objCen.id;
      objUserMap.nm_User__c=objUser.id;
      objUserMap.nm_Phone__c='326392156';
      objUserMap.nm_Head__c= true;
      insert objUserMap;
      //return objCen;
    }
        public static void CreateICAndUser2( nm_Centers__c objCen)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'nbsp57r', Email='balaorg@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='abpsg', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='balaorg@testorg.com');
        insert objUser;
        
      nm_UserMapping__c objUserMap= new nm_UserMapping__c();
      objUserMap.nm_Centers__c=objCen.id;
      objUserMap.nm_User__c=objUser.id;
      objUserMap.nm_Phone__c='326392156';
      objUserMap.nm_Head__c= true;
      insert objUserMap;
      //return objCen;
    }

    public static void CreateICAndUser1( nm_Centers__c objCen)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        User objUser = new User(Alias = 'newUser', Email='newuserSuperAdmin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 
        
      nm_UserMapping__c objUserMap= new nm_UserMapping__c();
      objUserMap.nm_Centers__c=objCen.id;
      objUserMap.nm_User__c=objUser.id;
      objUserMap.nm_Phone__c='326392156';
      objUserMap.nm_Head__c= true;
      insert objUserMap;
      //return objCen;
    }
    
    public static nm_Program__c CreateProgram(String typeOfProgram,String ProgramName,decimal totalSem,String sepcialization)
    {
      nm_Program__c program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.BookCChargeapplicable__c = true ;
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = ProgramName;
       program.nm_ProgramValidity__c = totalSem;
       program.nm_TotalSemesters__c = totalSem;
       program.nm_Type__c = typeOfProgram;
       program.prgst__c ='Jul2019';
       program.PVM__c = 48;
       program.Specialisation__c = sepcialization;          
       insert program; 
       return program;
    }
    public static nm_Program__c CreateProgram(String typeOfProgram,String ProgramName,decimal totalSem)
    {
      nm_Program__c program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = ProgramName;
       program.nm_ProgramValidity__c = totalSem;
       program.nm_TotalSemesters__c = totalSem;
       program.nm_Type__c = typeOfProgram;
       program.prgst__c ='Jul2019';
                 
       insert program; 
       return program;
    }
    
    public static nm_Program__c CreateDiplomaProgram()
    {
        return CreateProgram('Diploma Programs','Diploma in Supply Chain Management',2,'');
    }
    
    public static nm_Program__c CreatePGDiplomaProgram()
    {
        return CreateProgram('Post Graduate Diploma Programs','Post Graduate Diploma in Business Management',4,'');
    }
    
    public static nm_Program__c CreateCertificateProgram()
    {
        return CreateProgram('Certificate Programs','Certificate in Corporate Communication',1,'');
    }
      public static nm_Program__c CreateDegreeProgram()
    {
        return CreateProgram('Master Programs','MBA(WX) in Business Analytics',5,'MBA (WX)');
    }
    public static nm_Program__c CreateBachelorProgramsProgram()
    {
        return CreateProgram('Bachelor Programs','Bachelor of Business Administration',6,'MBA');
    }
    public static nmSerialNo__c InsertSerialNo()
    {
       nmSerialNo__c objSerial = new nmSerialNo__c();
      objSerial.nm_MaxGenratedNo__c=122355;
      objSerial.nm_name__c='Reference Number';
      insert objSerial;
       
       objSerial = new nmSerialNo__c();
      objSerial.nm_MaxGenratedNo__c=122355;
      objSerial.nm_name__c='Fee Receipt Counter';
      insert objSerial;
      return objSerial;
    }
    
    public static void CreateCalender()
    {
        List<Calender__c> lstCal = new List<Calender__c>();

        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2017;
        objCal.Session_End_Date__c = system.today()+1;
        objCal.Category__c= 'Admission';
        lstCal.add(objCal);

        Calender__c objCal1 = new Calender__c();
        objCal1.Session_Start_Date__c = system.today();
        objCal1.Session__c = 'January';
        objCal1.Year__c = 2017;
        objCal1.Session_End_Date__c = system.today()+1;
        objCal1.Category__c= 'Re-Registration';
        lstCal.add(objCal1);
        
        Calender__c objCal2 = new Calender__c();
        objCal2.Session_Start_Date__c = system.today();
        objCal2.Session__c = 'July';
        objCal2.Year__c = 2017;
        objCal2.Session_End_Date__c = system.today()+1;
        objCal2.Category__c= 'Admission';
        lstCal.add(objCal2);

        Calender__c objCal3 = new Calender__c();
        objCal3.Session_Start_Date__c = system.today();
        objCal3.Session__c = 'July';
        objCal3.Year__c = 2017;
        objCal3.Session_End_Date__c = system.today()+1;
        objCal2.Category__c= 'Re-Registration';
        lstCal.add(objCal3);

        insert lstCal;
    }

    public static void createCalender(String program, String specialisation) {
        List<Calender__c> lstCal = new List<Calender__c>();

        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = System.now().year();
        objCal.Session_End_Date__c = system.today()+1;
        objCal.Category__c= 'Admission';
        objCal.nm_Type__c = program;
        objCal.Specialisation__c = specialisation;
        lstCal.add(objCal);

        Calender__c objCal1 = new Calender__c();
        objCal1.Session_Start_Date__c = system.today();
        objCal1.Session__c = 'January';
        objCal1.Year__c = System.now().year();
        objCal1.Session_End_Date__c = system.today()+1;
        objCal1.Category__c= 'Re-Registration';
        objCal.nm_Type__c = program;
        objCal.Specialisation__c = specialisation;
        lstCal.add(objCal1);
        
        insert lstCal;
    }


    public static nm_Centers__c CreateCenter(String centerName)
    {
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        nm_Centers__c objLcCen = CreateLearningCenter('Mumbai - Mira Road East');

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name='Mumbai';
        
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = generateRandomString(7);
        objCen.ShareApplicable__c =true;
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.OwnerId= UserInfo.getUserId();
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c='Retail';

        insert objCen;
       // nm_UserMapping__c objuser = new nm_UserMapping__c ();
     //  CreateICAndUser2(objCen);
        return objCen;
    }

     public static nm_Centers__c CreateCenter(String centerName,boolean AllowDegree)
    {
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        nm_Centers__c objLcCen = CreateLearningCenter('Mumbai - Mira Road East');

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name='Mumbai';
        
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = generateRandomString(7);
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objcen.Allow_Degree__c = AllowDegree;
        objcen.Allow_MBA_WX__c = true;
        objcen.ConsumerType__c='Retail';
        insert objCen;
        return objCen;
    }

    public static nm_Centers__c CreateCenterForUpgrad(String centerName,boolean AllowDegree)
    {
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        
        objCen.Nm_Active__c = false;
        objCen.Name='upGrad';
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = generateRandomString(7);
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.Allow_Degree__c = AllowDegree;
        objCen.ConsumerType__c='Retail';
        insert objCen;
        return objCen;
    }
    public static nm_Centers__c CreateLearningCenter(String centerName)
    {
         Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = generateRandomString(7);
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Lata Kunj';
        objCen.nm_PostalCode__c = '400051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c='Retail';
        insert objCen;
        return objCen;
    }
    
    public static  nm_EligiblityCriteria__c CreateElegibilityCriteria()
    {
        nm_EligiblityCriteria__c objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='Bachelor degree';
        objEc.Is_Active__c = true;
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.Experience_Required_In_Year__c= null ;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c ='Post Graduate Diploma Programs';
        objEc.Graduation_Required__c =false;
        objEc.Mandatory_Document_list__c = '10th Marksheet';
        insert objEc;
        return objEc;
    }
    
    public static Account CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus(String IsDefence,boolean IsLateral,String studentStatus)
    {
        nm_EligiblityCriteria__c objEc = CreateElegibilityCriteria();
        nm_Centers__c objCen = CreateCenter('Mumbai');
        PriceBook2 priceBook = CreatePriceBook();
       nm_Program__c  program = CreatePGDiplomaProgram();
        String randomNumber = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
        Account  objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.Ref__c = '77216433684';
        objAccount.nm_DateOfBirth__c= date.newInstance(1990, 12, 9);
        objAccount.nm_RegistrationNumber__c ='011564865';
        objAccount.nm_StudentStatus__c=studentStatus;       
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonLeadSource = 'Web';
         objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.ValidUptoR__c='June 2020';
         objAccount.nm_LeadId__c='00QO0000003JgdZ';
         objAccount.nm_Program__c = program.id;
        objAccount.Is_Lateral__c= IsLateral;       
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c = IsDefence;
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra'+randomNumber+'@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721'+Integer.valueOf(randomNumber);
        objAccount.PersonEmail='chandra'+randomNumber+'@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.Zip_Postal_Code_Shipping__c ='400043';
        //objAccount.Owner=objUser;
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_Tagged_Pricebook__c = priceBook.id;
        objAccount.Sms_Status__c='Success';
        objAccount.smsSendTime__c = system.now();
        objAccount.EmailSendTime__c = system.now();
        objAccount.nmStudent_Program__c ='Post Graduate Diploma in Business Management';
        objAccount.nm_Centers__c=objCen.id;
        insert objAccount;
        return objAccount;
    }
    public static Account CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2(String IsDefence,boolean IsLateral,String studentStatus)
    {
        nm_EligiblityCriteria__c objEc = CreateElegibilityCriteria();
        nm_Centers__c objCen = CreateCenter('Mumbai');
        PriceBook2 priceBook = CreatePriceBook();
       nm_Program__c  program = CreatePGDiplomaProgram();
        String randomNumber = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
        Account  objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentNo__c= '77216433684';
        objAccount.nm_DateOfBirth__c= date.newInstance(1990, 12, 9);
        objAccount.nm_RegistrationNumber__c ='011564865';
        objAccount.nm_StudentStatus__c=studentStatus;       
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonLeadSource = 'Web';
         objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.ValidUptoR__c='June 2020';
         objAccount.nm_LeadId__c='00QO0000003JgdZ';
         objAccount.nm_Program__c = program.id;
        objAccount.Is_Lateral__c= IsLateral;       
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c = IsDefence;
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra'+randomNumber+'@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721'+Integer.valueOf(randomNumber);
        objAccount.PersonEmail='chandra'+randomNumber+'@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.Zip_Postal_Code_Shipping__c ='400043';
        //objAccount.Owner=objUser;
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_Tagged_Pricebook__c = priceBook.id;
        objAccount.Sms_Status__c='Success';
        objAccount.smsSendTime__c = system.now();
        objAccount.EmailSendTime__c = system.now();
        objAccount.nmStudent_Program__c ='Post Graduate Diploma in Business Management';
        objAccount.nm_Centers__c=objCen.id;
        insert objAccount;
        return objAccount;
    }


    public static Account CreateAccountWithUpgradCenterAndECForGivenDefenceAndLateralAndStatus(String IsDefence,boolean IsLateral,String studentStatus)
    {
        nm_EligiblityCriteria__c objEc = CreateElegibilityCriteria();
        nm_Centers__c objCen = CreateCenterForUpgrad('Mumbai',true);
        PriceBook2 priceBook = CreatePriceBook();
       nm_Program__c  program = CreatePGDiplomaProgram();
         String randomNumber = String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
        Account  objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.Ref__c = '77216433684';
        objAccount.nm_RegistrationNumber__c ='011564865';
        objAccount.nm_StudentStatus__c=studentStatus;       
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonLeadSource = 'Web';
         objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
         objAccount.nm_LeadId__c='00QO0000003JgdZ';
         objAccount.nm_Program__c = program.id;
        objAccount.Is_Lateral__c= IsLateral;       
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c = IsDefence;
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra'+randomNumber+'@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721'+Integer.valueOf(randomNumber);
        objAccount.PersonEmail='chandra'+randomNumber+'@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.Zip_Postal_Code_Shipping__c ='400043';
        //objAccount.Owner=objUser;
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_Tagged_Pricebook__c = priceBook.id;
        objAccount.Sms_Status__c='Success';
        objAccount.smsSendTime__c = system.now();
        objAccount.EmailSendTime__c = system.now();
        objAccount.nmStudent_Program__c ='Post Graduate Diploma in Business Management';
        objAccount.nm_Centers__c=objCen.id;
        insert objAccount;
        return objAccount;
    }
    
    public static Opportunity CreateOpportunityWithAccountAndProgram(String OpptyStage,String sem,String programType,Account objAccount,String Feetype)
    {
        Opportunity objopp =new Opportunity();
        list<Opportunity> lstopp=new list<Opportunity>();
        //Account objAccount = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents Approved');
        nm_Program__c program = new nm_Program__c();
        nm_StudentProgram__c objSP = new nm_StudentProgram__c();
        if(programType =='Post Graduate Diploma Programs' )
        {
            program = CreatePGDiplomaProgram();
            objSP = CreatePGStudentProgram(objAccount);
        }else if(programType =='Diploma Programs' )
        {
            program = CreateDiplomaProgram();
            objSP = CreateDiplomaStudentProgram(objAccount);
        }else if(programType =='Certificate Programs' )
        {
            program = CreateCertificateProgram();
         //  objSP = CreateStudentProgramBasedonProgram(objAccount,program);
        }
        else if(programType =='Master Programs' )
        {
            program = CreateDegreeProgram();
            objSP = CreateSTDegreeProgram(objAccount);
        }
        else if(programType =='Bachelor Programs' )
        {
            program = CreateBachelorProgramsProgram();
            objSP = CreateBachelorProgram(objAccount);
        }
    //    objopp.nm_AdmissionDriveDate__c = createAdmissionDriveDate(program).id;
        objopp.StageName = OpptyStage;
        objopp.nm_Fee_Type__c  = Feetype;
        objopp.nm_Payment_Approved__c =true;
        objopp.processed__c = false;
        objopp.nm_Session__c = 'January';
        objopp.nm_Year__c = 2019;
        objopp.CloseDate=System.today();
        objopp.nm_Semester__c= sem;
        objopp.Name='Chandra_Singh_11DSCM_Sem_1_Jan_2015';
      //  objopp.nm_StudentProgram__c = objSP.id;
        system.debug('objopp.nm_StudentProgram__c--->'+objopp.nm_StudentProgram__c);
        objopp.AccountId = objAccount.id; 
        objopp.nm_Program__c = program.id;
        objopp.nm_LateFee__c=1000;
        objopp.Amount=500.00; 
        objopp.TermRepeated__c= false;
        objopp.nm_Session__c='July';
        objopp.nm_Year__c=2020;

        objopp.nm_SelfLearningMaterial__c  ='Send to my Information Centre. I will pick up.';
        if(objAccount.Is_Lateral__c){
            objOpp.nm_Category__c = 'Lateral Admission';
        }else{
            objOpp.nm_Category__c = 'Admission';
        }
        insert objopp;
        return objopp;
        
    }
    
    public static Opportunity CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem(String opptyStage,String sem,Account objAccount,String Feetype)
    {
        return CreateOpportunityWithAccountAndProgram(OpptyStage,sem,'Post Graduate Diploma Programs',objAccount,Feetype);
    }
    
     public static Opportunity CreateMSOpportunityWithAccountAndProgramForGivenStageAndSem(String opptyStage,String sem,Account objAccount,String Feetype)
    {
        return CreateOpportunityWithAccountAndProgram(OpptyStage,sem,'Master Programs',objAccount,Feetype);
    }
    
    public static Opportunity CreateDiplomaOpportunityWithAccountAndProgramForGivenStageAndSem(String opptyStage,String sem,Account objAccount,String Feetype)
    {
        return CreateOpportunityWithAccountAndProgram(opptyStage,sem,'Diploma Programs',objAccount,Feetype);
    }
    
    public static Opportunity CreateCertificateOpportunityWithAccountAndProgramForGivenStageAndSem(String opptyStage,String sem,Account objAccount,String Feetype)
    {
        return CreateOpportunityWithAccountAndProgram(opptyStage,sem,'Certificate Programs',objAccount,Feetype);
    }
    public static Opportunity BachelorProgramsOpportunityWithAccountAndProgramForGivenStageAndSem(String opptyStage,String sem,Account objAccount,String Feetype)
    {
        return CreateOpportunityWithAccountAndProgram(opptyStage,sem,'Bachelor Programs',objAccount,Feetype);
    }
    
    public static nm_StudentProgram__c  CreateStudentProgram(Account objAccount,String programType)
    {
        nm_Program__c program = new nm_Program__c();
        if(programType =='Post Graduate Diploma Programs' )
        {
            program = CreatePGDiplomaProgram();
        }else if(programType =='Diploma Programs' )
        {
            program = CreateDiplomaProgram();
        }else if(programType =='Certificate Programs' )
        {
            program = CreateCertificateProgram();
        }
         program = CreatePGDiplomaProgram();
         nm_StudentProgram__c objSP = new nm_StudentProgram__c ();
         objSP.nm_Student__c =objAccount.id;
         //objSP.nm_EligiblityCriteria__c =objEc.id;
         objSP.nm_FeesPaidofSemester__c = 1;
         objSP.nm_Program__c = program.id;
         insert objSP;
         return objSP;  
    }
    
    public static nm_StudentProgram__c CreatePGStudentProgram(Account objAccount)
    {
        return CreateStudentProgram(objAccount,'Post Graduate Diploma Programs');
    }
    
    public static nm_StudentProgram__c CreateDiplomaStudentProgram(Account objAccount)
    {
        return CreateStudentProgram(objAccount,'Diploma Programs');
    }
    
    public static nm_StudentProgram__c CreateCertificateStudentProgram(Account objAccount)
    {
        return CreateStudentProgram(objAccount,'Certificate Programs');
    }
    
     public static nm_StudentProgram__c CreateSTDegreeProgram(Account objAccount)
    {
        return CreateStudentProgram(objAccount,'Master Programs');
    }
    public static nm_StudentProgram__c CreateBachelorProgram(Account objAccount)
    {
        return CreateStudentProgram(objAccount,'Bachelor Programs');
    }
    
    public static String CreateOpportunityLineItem(Opportunity objopp)
    {
        Product2 product = CreateSemesterProduct(objopp);
        product = CreateRegistrationProduct(objopp);
       product = CreatelateProduct(objopp);
        PriceBookEntry objPriceBookEntry = CreatePriceBookEntry(product,12000);
        
        OpportunityLineItem objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice=500;
        objLineItem.Quantity=1;
        objLineItem.OpportunityId = objopp.id;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        objLineItem.ActualSalePrice__c =1000;
        insert objLineItem ;
        return objLineItem.id;
    }

    public static String CreateOpportunityLineItemWithLiveLecture(Opportunity objopp)
    {
        Product2 product = CreateSemesterProduct(objopp);
        product = CreateRegistrationProduct(objopp);
       product = CreatelateProduct(objopp);
       product = CreateLiveLecturesProduct(objopp);
        PriceBookEntry objPriceBookEntry = CreatePriceBookEntry(product,12000);
        
        OpportunityLineItem objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice=500;
        objLineItem.Quantity=1;
        objLineItem.OpportunityId = objopp.id;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        objLineItem.ActualSalePrice__c =1000;
        insert objLineItem ;
        return objLineItem.id;
    }
    
    public Static Product2 CreateSemesterProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Semester';
        product2.nm_Program__c = objopp.nm_Program__c;
        product2.nm_Semester__c = objopp.nm_Semester__c;
        product2.isActive = true;
        insert product2;
        return product2;
    }
    
    public Static Product2 CreateSemesterProductSemwise(Opportunity objOpp,String Sem)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Semester';
        product2.nm_Program__c = objopp.nm_Program__c;
        product2.nm_Semester__c = Sem;
        product2.isActive = true;
        insert product2;
        return product2;
    }
    
    public Static Product2 CreateRegistrationProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Registration Fee';
        product2.isActive = true;
        insert product2;
        return product2;
    }
    
    public static Product2 CreateProduct(String productName,decimal productPrice){
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = productName;
        product2.isActive = true;
        insert product2;
        
        PriceBookEntry objPriceBookEntry = CreatePriceBookEntry(product2,productPrice);
        return product2;
    }
    
     public Static Product2 CreatelateProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Late Fee';
        product2.isActive = true;
        insert product2;
        return product2;
    }
    public Static Product2 CreateLiveLecturesProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Live Lectures';
        product2.isActive = true;
        insert product2;
        return product2;
    }
    public Static Product2 CreateCareerProduct(Opportunity objOpp)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Career Development';
        product2.isActive = true;
        insert product2;
        return product2;
    }
    
    public static IC_Change_Request__c CreateICChangeRequest(String centerName,Opportunity opps){
        IC_Change_Request__c objCR = new IC_Change_Request__c ();
        nm_Centers__c objCenter = CreateCenter(centerName);
        objCR.Status__c='New';
        objCR.Student__c= opps.AccountID;
        objCR.Opportunity__c=opps.id;
        objCR.nm_TypeofRequest__c='IC Change';
        objCR.nm_Reson__c='test test';
        objCR.New_Information_Center__c=objCenter.id;
        objCR.Current_Information_Center__c=objCenter.id;
        insert objCR;
        return objCR;
    
    }
    
    public static IC_Change_Request__c CreateICChangeRequest(Opportunity opps){
        IC_Change_Request__c objCR = new IC_Change_Request__c ();
        nm_Centers__c objCenter = CreateCenter('Mumbai');
        nm_Centers__c objCenter1 = CreateCenter('Pune');
        CreateICAndUser(objCenter);
          CreateICAndUser1(objCenter1);
        objCR.Status__c='New';
        objCR.Student__c= opps.AccountID;
        objCR.Opportunity__c=opps.id;
        objCR.nm_TypeofRequest__c='IC Change';
        objCR.nm_Reson__c='test test';
        objCR.New_Information_Center__c=objCenter1.id;
        objCR.Current_Information_Center__c=objCenter.id;
        insert objCR;
        return objCR;
    
    }
    public static IC_Change_Request__c CreateprogramChangeRequest(Opportunity opps){
        IC_Change_Request__c objCR = new IC_Change_Request__c ();
         nm_Program__c objProgram = CreateDiplomaProgram();
        objCR.Status__c='New';
        objCR.Student__c= opps.AccountID;
        objCR.Opportunity__c=opps.id;
        objCR.nm_TypeofRequest__c='Program Change';
        objCR.nm_Reson__c='test test';
        objCR.New_Program__c = objProgram.id;
        
        objCR.nm_Reason_for_Change_of_Program__c ='better oppos';
        insert objCR;
        return objCR;
    
    }
    public static Validity_Extension__c CreateValidity()
    {
        Validity_Extension__c objValEx = new Validity_Extension__c();
        Account objAccount = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents Approved');
        objValEx.Batch_Name__c='JUL2015';
        objValEx.Expiry_Date_Of_Program__c='2020';
        objValEx.Mobile_Number__c='242343254326534';
        objValEx.Name_Of_Account__c='Fagu Babu';
        objValEx.Student_Number_Of_Account__c='77115000170';
        objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
        objValEx.Related_Account__c=objAccount.id;
        insert objValEx;
        return objValEx;
    }
     public static Validity_Extension__c CreateValiditybasedonaccount(Account obj)
    {
        Validity_Extension__c objValEx = new Validity_Extension__c();
       // Account objAccount = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents Approved');
        objValEx.Batch_Name__c='JUL2015';
        objValEx.Expiry_Date_Of_Program__c='2020';
        objValEx.Mobile_Number__c='242343254326534';
        objValEx.Name_Of_Account__c='Fagu Babu';
        objValEx.Student_Number_Of_Account__c='77115000170';
        objValEx.Student_Program_Validity__c=obj.nmStudent_Program__c;
        objValEx.Related_Account__c= obj.id;
        insert objValEx;
        return objValEx;
    }
    public static PriceBookEntry CreatePriceBookEntry(Product2 product ,decimal productPrice)
    {
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        insert standardPriceBookEntry;
        
        Pricebook2 customPB = CreatePriceBook();
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id, UnitPrice = productPrice, IsActive = true);
        insert objPriceBookEntry;
        
        return objPriceBookEntry;
    }
    
    public Static PriceBook2 CreatePriceBook()
    {
        Pricebook2 priceBook = new Pricebook2(Name='NMIMS New Price Book', isActive=true , nmSession_Start_Date__c = System.today().addDays(-1), nmSession_End_Date__c = System.today().addDays(2) );
        insert priceBook;
        return priceBook;
    }
    
    public static Late_Fee__c createLateFeeRecord(String category,String type){
        Late_Fee__c objLateFee = new Late_Fee__c();
        objLateFee.Start_Date__c = System.today().addDays(-1);
        objLateFee.End_Date__c = System.today().addDays(2);
        objLateFee.Category__c = category;
        objLateFee.nm_Type__c = type;
        objLateFee.Late_Fees__c = 1000;
        insert objLateFee;
        return objLateFee;
    }
    
    public static nm_Payment__c CreatePaymentRecordForLead(Lead objLead,String TypeOfPayment)
    {
        nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.nm_Lead__c =objLead.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.Receipt_Number__c = '70021548889';
        objPayment2.nm_PaymentStatus__c ='Payment Made';
         objPayment2.nm_PaymentType__c =TypeOfPayment;
        insert objPayment2;
        return  objPayment2;
    }
    
    public static nm_Payment__c CreatePaymentRecordForOpportunity(Opportunity objOpps,String TypeOfPayment)
    {
        nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.nm_OpportunityNew__c = objOpps.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_ActualPaymentAmmount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Made';
        objPayment2.nm_PaymentType__c = TypeOfPayment;
        objPayment2.nm_Merchant_Track_Id__c = '1234';
        objPayment2.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment2;
        return  objPayment2;
    }
    
    public static nm_Payment__c CreatePaymentRecordForOpportunityApproved(Opportunity objOpps,String TypeOfPayment)
    {
        nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.nm_OpportunityNew__c = objOpps.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_ActualPaymentAmmount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Approved';
        objPayment2.nm_PaymentType__c = TypeOfPayment;
        objPayment2.nm_Merchant_Track_Id__c = '1234';
        objPayment2.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment2;
        return  objPayment2;
    }
    
    public static nm_Payment__c CreateRegistrationPaymentRecordForLead(Lead objLead)
    {
        return CreatePaymentRecordForLead(objLead,'Registration');
    }
    
    public static nm_Payment__c CreateAdmissionPaymentRecordForLead(Lead objLead)
    {
        return CreatePaymentRecordForLead(objLead,'Admission');
    }
    
    public static nm_Payment__c CreateLateFeePaymentRecordForLead(Lead objLead)
    {
        return CreatePaymentRecordForLead(objLead,'Late Fees');
    }
    
    public static nm_Payment__c CreateRegistrationPaymentRecordForOppty(Opportunity objOpps)
    {
        return CreatePaymentRecordForOpportunity(objOpps,'Registration');
    }
    
    public static nm_Payment__c CreateAdmissionPaymentRecordForOppty(Opportunity objOpps)
    {
        return CreatePaymentRecordForOpportunity(objOpps,'Admission');
    }

    public static nm_Payment__c CreateAdmissionPaymentRecordForOpptyForApproved(Opportunity objOpps)
    {
        return CreatePaymentRecordForOpportunityApproved(objOpps,'Admission');
    }
    
    public static nm_Payment__c CreateLateFeePaymentRecordForOppty(Opportunity objOpps)
    {
        return CreatePaymentRecordForOpportunity(objOpps,'Late Fees');
    }
       public static nm_Payment_Initiated__c CreatePaymentInitiatedRecordForOpportunity(Opportunity objOpps,String TypeOfPayment)
    {   
    
        nm_Payment_Initiated__c objPaymentInitiated = new nm_Payment_Initiated__c ();
        objPaymentInitiated.nm_OpportunityNew__c = objOpps.id;
        objPaymentInitiated.nm_Amount__c = 4272;
        objPaymentInitiated.nm_PaymentStatus__c ='Payment Made';
        objPaymentInitiated.nm_PaymentType__c = TypeOfPayment;
        insert objPaymentInitiated;
        return  objPaymentInitiated;                
    }
    
     public static nm_Payment_Initiated__c CreatePaymentInitiatedRecordForLead(Lead objLead,String TypeOfPayment)
    {
        nm_Payment_Initiated__c objPaymentInitiatedlead = new nm_Payment_Initiated__c ();
        objPaymentInitiatedlead.nm_Lead__c =objLead.id;
        objPaymentInitiatedlead.nm_Amount__c = 4272;
        objPaymentInitiatedlead.nm_PaymentStatus__c ='Payment Made';
        objPaymentInitiatedlead.nm_PaymentType__c =TypeOfPayment;
        objPaymentInitiatedlead.nm_Merchant_Track_Id__c ='2222';
        insert objPaymentInitiatedlead;
        return  objPaymentInitiatedlead;
    }
    
     public static nm_Payment_Initiated__c CreateRegistrationPaymentInitiatedRecordForLead(Lead objLead)
    {
        return CreatePaymentInitiatedRecordForLead(objLead,'Registration');
    }
    
    public static nm_Payment_Initiated__c CreateAdmissionPaymentInitiatedRecordForLead(Lead objLead)
    {
        return CreatePaymentInitiatedRecordForLead(objLead,'Admission');
    }
    
    public static nm_Payment_Initiated__c CreateLateFeePaymentInitiatedRecordForLead(Lead objLead)
    {
        return CreatePaymentInitiatedRecordForLead(objLead,'Late Fees');
    }
    
    public static nm_Payment_Initiated__c CreateRegistrationPaymentInitiatedRecordForOppty(Opportunity objOpps)
    {
        return CreatePaymentInitiatedRecordForOpportunity(objOpps,'Registration');
    }
    
    public static nm_Payment_Initiated__c CreateAdmissionPaymentInitiatedRecordForOppty(Opportunity objOpps)
    {
        return CreatePaymentInitiatedRecordForOpportunity(objOpps,'Admission');
    }
    
    public static nm_Payment_Initiated__c CreateLateFeePaymentInitiatedRecordForOppty(Opportunity objOpps)
    {
        return CreatePaymentInitiatedRecordForOpportunity(objOpps,'Late Fees');
    }
    
    
    public static void CreateWorkExperience(String Id ,String TypeOfWorkExp)
    {
        nm_WorkExperience__c objWorkExp = new nm_WorkExperience__c();
        objWorkExp.Department__c = 'multitask';
        objWorkExp.nm_Designation__c = 'Manager';
        objWorkExp.Industry__c = 'Advertising';
        if(TypeOfWorkExp =='Lead')
        {
            objWorkExp.nm_Lead__c = Id;
        }else if(TypeOfWorkExp == 'Account')
        {
            objWorkExp.nm_Student__c = Id;
        }
        objWorkExp.nm_StartDate__c = system.today();
        objWorkExp.nm_EndDate__c = system.today();
        insert objWorkExp;
    }
    
    public static void  CreateWorkExperienceForLead(Lead objLead)
    {
        CreateWorkExperience(objLead.id,'Lead');
    }
    
    public static void  CreateWorkExperienceForAccount(Account objAccount)
    {
        CreateWorkExperience(objAccount.id,'Account');
    }
    
    public static nm_LinksForDocumentsLead__c CreatedDocumentForLead(Lead objLead, String DocumentName)
    {
       
        nm_LinksForDocumentsLead__c objLeadDoc=new nm_LinksForDocumentsLead__c();
        objLeadDoc.Name = DocumentName;
        objLeadDoc.nm_DocumentName__c=DocumentName;
        objLeadDoc.Lead__c=objLead.id;
        objLeadDoc.nm_URLforDocuments__c ='www.google.com';
        insert objLeadDoc;
        return objLeadDoc;
        
    }
    public static nm_LinksForDocuments__c CreateDocumentforAccount(Account objAccount,string DocumentName )
    {
       nm_LinksForDocuments__c  objDoc=new nm_LinksForDocuments__c ();
       objDoc.name = DocumentName;
       objDoc.nm_DocumentName__c = DocumentName ;
       objDoc.nm_URLforDocuments__c ='www.google.com';
       objDoc.nm_Account__c = objAccount.id;
       objDoc.nm_Status__c = 'Approved';
       insert objDoc;
       return objDoc;
    }
    
    
    
    // public static nm_AdmissionDriveDate__c createAdmissionDriveDate( nm_Program__c program)
    //  {
    //      nm_AdmissionDriveDate__c objADD = new nm_AdmissionDriveDate__c();
         
    //      objADD.nm_Batch__c ='January';
    //      objADD.nm_DriveDate__c=System.today();
    //      objADD.nm_StartDate__c=System.today();
    //      objADD.nm_Program__c =program.id;
    //      insert objADD; 
    //      return objADD;
    //  }
     
     public static Calender__c  SetCalender(string Session,date startDate,date EndDate, Decimal Year)
     {
        Calender__c  objCalender = new Calender__c();
        objCalender.Session__c = Session;
        objCalender.Session_Start_Date__c = startDate;
        objCalender.Session_End_Date__c = EndDate;
        objCalender.Year__c = Year;
        insert objCalender;
        return objCalender;
      } 
      
      public static Dispatch_Order__c DispatchOrder( Stock_Keeping_Units__c stockUnit)
      {
         Dispatch_Order__c dispatch = new Dispatch_Order__c();
         nm_Centers__c  objLearningCenter=[select id from nm_Centers__c where RecordType.Name='Learning Center'];
         nm_Centers__c  objInformationCenter=[select id from nm_Centers__c where RecordType.Name='Information Center'];
         dispatch.Order_Type__c = 'Student Order';
         dispatch.Quantity__c = 1;
         dispatch.Status_Of_Dispatch__c = 'Transit';
         dispatch.From_Centers__c = objLearningCenter.id;
         dispatch.To_Centers__c = objInformationCenter.id;
         dispatch.Stock_Keeping_Unit__c = stockUnit.id;
         //dispatch.To_Student__c=objAccount.id;
         insert dispatch; 
         return dispatch;
       } 
  /* Master way to cover test class   
     public Static Map<String,String> getMapOfEditableVsDataTypeOfFieldForSObject(String SObjectAPIName){
            Map<String,String> mapOfEditableFieldAPIVsDataType = new Map<String,String>();
            Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
            Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
            
            for(String fieldName : fieldMap.keySet()) {
               if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                   mapOfEditableFieldAPIVsDataType.put(fieldName.toLowerCase() ,String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
                   if((fieldName.containsIgnoreCase('Number') || fieldName.containsIgnoreCase('Code')) && 'String'.equalsIgnoreCase(String.valueOf(fieldMap.get(fieldName).getDescribe().getType()))){
                       System.debug('Number Field--'+fieldName);
                       mapOfEditableFieldAPIVsDataType.put(fieldName.toLowerCase() ,'Number');
                   }
                }
            }
            return mapOfEditableFieldAPIVsDataType;
        }
        
        public Static Map<String,String> getMapOfPickListFieldAPIVsValue(String SObjectAPIName){
            Map<String,String> mapOfPickListFieldAPIVsValue = new Map<String,String>();
            Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
            Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
            
            for(String fieldName : fieldMap.keySet()) {
               if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    if('PickList'.equalsIgnoreCase(String.valueOf(fieldMap.get(fieldName).getDescribe().getType()))){
                        List<Schema.PickListEntry> lstPickList = fieldMap.get(fieldName).getDescribe().getPickListValues();
                        mapOfPickListFieldAPIVsValue.put(fieldName.toLowerCase(),lstPickList[0].getValue());
                    }
               }
            }
            return mapOfPickListFieldAPIVsValue ;
        }
        
        public Static SObject createSObject(String SObjectAPIName){
            Map<String,String> mapOfEditableFieldAPIVsDataType = getMapOfEditableVsDataTypeOfFieldForSObject(SObjectAPIName);
            Map<String,String> mapOfPickListFieldAPIVsValue = getMapOfPickListFieldAPIVsValue(SObjectAPIName);
            Schema.SObjectType ObjectType = Schema.getGlobalDescribe().get(SObjectAPIName);
            String emailTextvalue = 'Sachin@gmail.com';
            String mobileNumberValue = '7722445289';
            String numberValue = '77224452891';
            String textValue = 'Sachin';
            
            sObject obj = ObjectType.newSObject();
            for(String key : mapOfEditableFieldAPIVsDataType.keySet()){
                if(!key.contains('bounced')){
                    if('DATETime'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,System.now());
                    }else if('PickList'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key)) && mapOfPickListFieldAPIVsValue.containsKey(key)){
                        obj.put(key,mapOfPickListFieldAPIVsValue.get(key));
                    }else if('Email'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,emailTextvalue);
                    }else if('MobilePhone'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,mobileNumberValue);
                    }else if('Phone'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,'0224333430');
                    }else if('Decimal'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,'1200');
                    }else if('Text'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,textValue);
                    }else if('Name'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,textValue);
                    }else if('String'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,textValue);
                    }else if('Number'.equalsIgnoreCase(mapOfEditableFieldAPIVsDataType.get(key))){
                        obj.put(key,numberValue);
                    }
                }
            }
            System.debug('SObject--'+obj);
            return obj;
        }
    */
    
    public static Product2 CreateLeadSemesterProduct(Lead objLead,String productName){
        Product2 semesterproductLead = new Product2();
        semesterproductLead.Name = productName;
        semesterproductLead.nm_Program__c = objLead.nm_Program__c;
        semesterproductLead.nm_Semester__c = objLead.nm_Semester__c;
        semesterproductLead.isActive = true;
        insert semesterproductLead;
        return semesterproductLead;
    }
    
    public static  nm_EligiblityCriteria__c CreateElegibilityCriteriaforMaster(String masterprog){
        nm_EligiblityCriteria__c objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='Bachelor with 50% and 2 yr Work exp.';
        objEc.Is_Active__c = true;
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.Experience_Required_In_Year__c= 2 ;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c = masterprog;
        objEc.Graduation_Required__c =true;
        objEc.Mandatory_Document_list__c = '10th Marksheet';
        insert objEc;
        return objEc;
    }
    
    public static PriceBookEntry createProductAndPricebookEntry(String productName , String semester , String program ,String priceBook2Id){
        Product2 product = new Product2();
        product.Name = productName;
        product.nm_Program__c = program!=null && program!=''?program:null ;
        product.nm_Semester__c = semester!=null && semester!=''? semester:null;
        product.isActive = true;
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PriceBookEntry  standardPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert standardPriceBookEntry;
        
        PriceBookEntry  objPriceBookEntry = new PricebookEntry(Pricebook2Id = pricebook2Id, Product2Id = product.Id, UnitPrice = 12000, IsActive = true);
        insert objPriceBookEntry;
        return objPriceBookEntry;
    }
    
    public static nm_Payment__c CreatePaymentRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String installmentRef){
        nm_Payment__c objPayment = new nm_Payment__c ();
        if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.nm_OpportunityNew__c = recordId;
        }else{
            objPayment.nm_Lead__c  = recordId;
        }
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Payment Made';
        objPayment.nm_PaymentGatewayName__c ='Bill Desk';
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        objPayment.nm_Installment_Payment_Ref__c = installmentRef;
        insert objPayment;
        return objPayment;
    }
    
    public static NM_Payment_Form_Configuration__c  createPaymentFOrmConfiguration(String programCategory,String programType,String semester){
        NM_Payment_Form_Configuration__c objpaymentconfig = new NM_Payment_Form_Configuration__c();
        objpaymentconfig.Program_Category__c = programCategory;
        objpaymentconfig.Payment_Type__c =programType;
        objpaymentconfig.Semester__c= semester;
        objpaymentconfig.Current_Admission_Year__c = '2017';
        objpaymentconfig.Session__c = 'July';
        objpaymentconfig.No_Of_Applicable_Installment__c ='1';
        objpaymentconfig.Registration_Fee__c=1200;
        objpaymentconfig.Program_Type__c='';
        objpaymentconfig.Reg_No_Allowed_After_End_Date__c = '01723456';
        objpaymentconfig.Capital_Float_AEP_Available__c = 'Mumbai,Pune';
        objpaymentconfig.Show_Registration_Payment_Option__c = true;
        objpaymentconfig.Show_Admission_Payment_Option__c = true;
        objpaymentconfig.ShowInitialAdmissionPayment__c = true;
        objpaymentconfig.Payment_Window_EndDate__c = System.now().addDays(-1);
        objpaymentconfig.Initial_Admission_Payment__c = 1200;
        objpaymentconfig.Registration_Fee__c = 12000;
        objpaymentconfig.Is_Late_Fee_Applicable__c = true;
        objpaymentconfig.DownPayment_Amount__c = 5000;
        insert objpaymentconfig;
        return objpaymentconfig;
    }
      public static nm_Payment_Initiated__c CreatePaymentInitRecords(String recordId,String TypeOfPayment,String SObjectAPIName,String orderid)
     {
         nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c ();
          if('Opportunity'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.nm_OpportunityNew__c = recordId;
        }else if ('Lead'.equalsIgnoreCase(SObjectAPIName)) {
            objPayment.nm_Lead__c  = recordId;
        }else if('Referral__c'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.Seminar__c = recordId;
        }else if('Validity_Extension__c'.equalsIgnoreCase(SObjectAPIName)){
            objPayment.Validity_Extension__c = recordId;
        }
        objPayment.nm_Merchant_Track_Id__c = orderid;
        objPayment.nm_Amount__c = 4272;
        objPayment.nm_ActualPaymentAmmount__c = 4272;
        objPayment.nm_PaymentStatus__c ='Payment Made';
        objPayment.nm_PaymentGatewayName__c ='HDFC GateWay';
        objPayment.nm_PaymentType__c = TypeOfPayment;
        objPayment.nm_TransactionDate__c = Date.newInstance(2015, 1, 1);
        insert objPayment;
        return objPayment;
     }
      public Static nm_Courses__c CreateCourseList(Opportunity objOpp,Integer Sem,String CourseName,Id productid,Integer code)
    {
        nm_Courses__c courses = new nm_Courses__c();
        courses = new nm_Courses__c();
        courses.Name = CourseName;
        courses.Program__c = objOpp.nm_Program__c;
        courses.Semester__c = Sem;
        //Product2 product2 = CreateSemesterProductSemwise(objOpp,String.valueof(Sem));
        courses.nm_Semester__c = productid;
        courses.ConsumerType__c='Retail';
        courses.IsActive__c = true;
        courses.Program_Structure__c ='Jul2019';
        courses.Student_Zone_Course_Id__c = code;
        courses.Student_Zone_Subject_Code__c = 'tesrt';
        courses.Student_Zone_Program_Code__c =objOpp.Program_Name__c;
        insert courses;
        return courses;
    }
     public Static Product2 CreateSemesterProductvs2(id programId,Integer sem)
    {
        Product2 product2 = new Product2();
        product2 = new Product2();
        product2.Name = 'Semester';
        product2.nm_Program__c = programId;
        product2.nm_Semester__c = String.valueof(sem);
        product2.isActive = true;
        insert product2;
        return product2;
    }
    public static nm_StudentProgram__c  CreateStudentProgramBasedonProgram(Account objAccount, nm_Program__c objprogram)
    {
         nm_StudentProgram__c objSP = new nm_StudentProgram__c ();
         objSP.nm_Student__c =objAccount.id;
         //objSP.nm_EligiblityCriteria__c =objEc.id;
         objSP.nm_FeesPaidofSemester__c = 1;
         objSP.nm_Program__c = objprogram.id;
         insert objSP;
         return objSP;  
    }

    public static String generateRandomString(Integer length) {
        String charString = '9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAabcdefghijklmnopqrstuvwxyz!@#$&_';
        String randomNew = '';
        while (randomNew.length() < length) {
            Integer changeInt5 = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
            randomNew += charString.substring(changeInt5 , changeInt5 +1);
        }
        randomNew = randomNew.left(4);
        return randomNew;
    }
}