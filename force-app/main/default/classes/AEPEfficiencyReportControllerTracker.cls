/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 02-07-2025
 * @last modified by  : @Shailesh
**/
@istest (SeeAllData=false)
public without sharing class AEPEfficiencyReportControllerTracker {
    public AEPEfficiencyReportControllerTracker() {

    }
     @testSetup
    public static void setUpData(){
        
        
        User objUser =CreateICAndUser();
        nm_Centers__c objCenter = CreateCenter('Mumbai');

        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=objCenter.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;
      

        Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com',nm_Centers__c = objCenter.id);
        insert objBusinessAccount;
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objCenter.id;
        cp.IsActive__c = false;
        cp.BusinessAccount__c = objBusinessAccount.id;
        cp.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        cp.AEP_Request_Subject__c = 'My book not received';
        cp.AEP_Request_Start_Time__c = Datetime.now().time().addHours(-3);
        cp.AEP_Request_End_Time__c = Datetime.now().time().addHours(3);
        cp.Employee_Image_URL__c  = 'http:abc123';
        insert cp;
        Account objBusinessAccountnew = new Account(Name='Head Office new',Phone='8850232800',nm_AccountEmail__c='standarduser123@testorg.com', nm_Centers__c = objCenter.id);
         insert objBusinessAccountnew;
        Counsellor_Profile__c cpnew = new Counsellor_Profile__c();
        cpnew.Salutation__c = 'Mr.';
        cpnew.First_Name__c = 'Test1';
        cpnew.Last_Name__c = 'test1';
        cpnew.AEP_Name__c = objCenter.id;
        cpnew.IsActive__c = false;
        cpnew.BusinessAccount__c = objBusinessAccountnew.id;
        cpnew.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        cpnew.AEP_Request_Subject__c = 'My book not received';
        cpnew.AEP_Request_Start_Time__c = Datetime.now().time().addHours(-3);
        cpnew.AEP_Request_End_Time__c = Datetime.now().time().addHours(3);
        cpnew.Employee_Image_URL__c  = 'http:abc';
        insert cpnew;
       // CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral(objCenter,'abc@mail.com', '8974156370',objUser);
        // CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral(objCenter,'abc123@mail.com', '8974156123',objUser);
        InsertSerialNo();
        Account acc = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed',cp.Id);
        Account acc1 = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed',cpnew.Id);
        CreateOpportunityWithAccountAndProgram('Closed Won','1','Bachelor Programs',acc,'AnnualFee','January',2025,cp.Id);
        CreateOpportunityWithAccountAndProgram('Closed Won','1','Bachelor Programs',acc1,'AnnualFee','July',2025,cpnew.Id);
    }
    public static testMethod void test1()
    {
        User objUser = [Select Id from user where LastName='Testing' limit 1];
        List<Counsellor_Profile__c> cp = [Select Id, name,Full_Name__c,AEP_Name__c from Counsellor_Profile__c where IsActive__c = false ];
        List <nm_UserMapping__c> usermappinglst = [Select Id, nm_Centers__c ,nm_User__c from nm_UserMapping__c ];
        
        
        AEPEfficiencyReportController.getAEPefficency('Jan2025,Jul2025','Mumbai');

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
     public static nm_Program__c CreatePGDiplomaProgram()
    {
        return CreateProgram('Post Graduate Diploma Programs','Post Graduate Diploma in Business Management',4,'');
    }
    public static Lead CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral( nm_Centers__c objCenter,String Email, String mobile,User objUser )
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
         objLead.status='Not Contacted';
         objLead.nm_Class12OrDiploma__c ='XII/HSC';
         objLead.nm_Class12OrDiploma__c='Diploma';
         objLead.Email= Email; //'amit.kumar@saasfocus.com';
         objLead.MobilePhone = mobile;//'8377985721';
         objLead.City='noida';
         objLead.nm_Stream__c='hgfgc';
         objLead.nm_Gender__c = 'Male';
         objLead.nm_ChooseaProgram__c =objProgram.nm_Type__c;
         objLead.nm_EligiblityCriteria__c = objEc.id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_NameofBoard12__c='hvh';
         objLead.nm_SelectedProgram__c ='ccc';
         objLead.nm_InformationCenter__c =objCenter.id;
         objLead.OwnerId= objUser.id;
         objLead.nm_Year__c =2025;
         objLead.LeadSource ='web';
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
        objLead.Is_Lateral__c = false;
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

    public static User CreateICAndUser()
    {

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');//,ContactId = objContact.Id,UserRoleId = portalRole.Id
        insert objUser; 
        return objUser;
       
        
    
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
    public Static PriceBook2 CreatePriceBook()
    {
        Pricebook2 priceBook = new Pricebook2(Name='NMIMS New Price Book', isActive=true , nmSession_Start_Date__c = System.today().addDays(-1), nmSession_End_Date__c = System.today().addDays(2) );
        insert priceBook;
        return priceBook;
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
    public static Account CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus(String IsDefence,boolean IsLateral,String studentStatus,String cpId)
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
        objAccount.Counselor_Profile__c = cpId;
        insert objAccount;
        return objAccount;
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
     public static nm_Program__c CreateDiplomaProgram()
    {
        return CreateProgram('Diploma Programs','Diploma in Supply Chain Management',2,'');
    }
    public static nm_StudentProgram__c CreateBachelorProgram(Account objAccount)
    {
        return CreateStudentProgram(objAccount,'Diploma Programs');
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
    public static nm_Program__c CreateBachelorProgramsProgram()
    {
        return CreateProgram('Bachelor Programs','Bachelor of Business Administration',6,'MBA');
    }
    public static Opportunity CreateOpportunityWithAccountAndProgram(String OpptyStage,String sem,String programType,Account objAccount,String Feetype,String session,Integer year,String cpId)
    {
        Opportunity objopp =new Opportunity();
        list<Opportunity> lstopp=new list<Opportunity>();
        //Account objAccount = CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents Approved');
        nm_Program__c program = new nm_Program__c();
        nm_StudentProgram__c objSP = new nm_StudentProgram__c();
        if(programType =='Bachelor Programs' )
        {
            program = CreateBachelorProgramsProgram();
            objSP = CreateBachelorProgram(objAccount);
        }
    //    objopp.nm_AdmissionDriveDate__c = createAdmissionDriveDate(program).id;
        objopp.StageName = OpptyStage;
        objopp.nm_Fee_Type__c  = Feetype;
        objopp.nm_Payment_Approved__c =true;
        objopp.processed__c = false;
        objopp.nm_Session__c = session;
        objopp.nm_Year__c = year;
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
        objopp.nm_Session__c=session;
        objopp.nm_Year__c=year;
        objopp.Counselor_Profile__c = cpId;
        objopp.nm_SelfLearningMaterial__c  ='Send to my Information Centre. I will pick up.';
        if(objAccount.Is_Lateral__c){
            objOpp.nm_Category__c = 'Lateral Admission';
        }else{
            objOpp.nm_Category__c = 'Admission';
        }
        insert objopp;
        return objopp;
        
    }
}