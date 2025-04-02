@isTest(SeeAllData =true)
public class MassFeeReceiptTracker
{
  public static nm_Payment__c objPayment;
  public static Opportunity objopp;
  public static Lead objLead;
  public static nm_Program__c program;
  public static nm_Holidays__c objHoliday;
  public static nm_Centers__c infoCenter;
  public static nm_Centers__c objCen;
  public static Account objAccount;
  public static nm_EligiblityCriteria__c eligibility;
  public static nm_UserMapping__c objUserMap;
  public static nm_UserMapping__c obuse;
  public static nmSerialNo__c objSerial;
  Public static User objUser;
  
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
       objSerial.nm_name__c='hgfs';
       insert objSerial;
        
         objAccount = new Account();     
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Registered';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonMobilePhone ='1002030120';
        objAccount.PersonEmail = 'lav.singh@saasfocus.com'; 
        objAccount.nm_StudentNo__c = 'Lav';
        objAccount .nm_Centers__c= objCen.id;
        objAccount.nm_DateOfBirth__c = system.today();
        objAccount.nm_RegistrationNumber__c = '93434';
        objAccount.nm_StudentNo__c='345454';
        objAccount.nm_Program__c=program.id;
        objAccount.nm_EligiblityCriteria__c=eligibility.id;
        //objAccount.OwnerId= usr.id;                  
        insert objAccount;

        objopp= new Opportunity();
        objopp.AccountId=objAccount.id;
        objopp.Amount=1700;
        objopp.nm_ModeOfPayment__c='Demand Draft';
        objopp.nm_Year__c=2016;
        objopp.nm_Session__c='July';
        objopp.nm_Semester__c = '1';
        objopp.nm_Category__c='Lateral Admission';
        objopp.Is_Re_Registration_Payment__c = true;
        objopp.nm_ModeOfPayment__c ='Demand Draft';
        objopp.nm_InformationCenters__c=objCen.id;
        objopp.nm_Program__c=program.id;
        //objopp.nm_StudentProgram__c=objstudentprog.id;
        objopp.StageName='Payment Approved';
        objopp.CloseDate=system.today()+10;
        objopp.Name='Tets_Ting_PGDITM_Sem_1_January_2016';
        insert objopp;
       
        objPayment=new nm_Payment__c();
        objPayment.nm_Amount__c=17000;
        objPayment.nm_ModeOfPayment__c='Demand Draft';
        objPayment.nm_DemandDraftDate__c=system.today();
        objPayment.nm_BankLocation__c='chembur';
        objPayment.nm_NameoftheBank__c='SBH';
        objPayment.nm_Pay_Mode__c='Full Fee';
        objPayment.nm_ActualPaymentAmmount__c=17000;
        objPayment.nm_DemandDraftNumber__c='1111';
        objPayment.nm_PaymentType__c='Admission';
        objPayment.Receipt_Number__c='40000153';
        objPayment.nm_PaymentStatus__c='Payment Approved';
        objPayment.ExportFeeReceipt__c= true;
        objPayment.nm_TransactionDate__c=system.today();
        objPayment.nm_TransactionID__c='12345';
        objPayment.nm_OpportunityNew__c=objopp.id;
        
       // objPayment.Semester_Line_Item__c =17000;
        insert objPayment;   
   }
        
        static testmethod void UnitTest1()
        {
         LoadData();
         PageReference pg = new PageReference('/apex/MassFeeReceipt');
         MassFeeReceiptController obj =new MassFeeReceiptController();
         
         obj.ListReceiptNumber='2000000000113';
        
         obj.search(); 
         obj.ListReceiptNumber='';
         obj.View();
         obj.search(); 
         obj.RemoveError();      
        }
        
        static testmethod void UnitTest2()
        {
         LoadData();
         // objPayment.nm_PaymentType__c='Late Fees';
        objPayment.Receipt_Number__c='40000153';
        objPayment.nm_PaymentStatus__c='Payment Approved';
        //objPayment.ExportFeeReceipt__c=true;
        update objPayment;
         PageReference pg = new PageReference('/apex/MassFeeReceipt');
         MassFeeReceiptController obj =new MassFeeReceiptController();
         
         obj.ListReceiptNumber='2000000000113';
        
         obj.search(); 
         obj.ListReceiptNumber='';
         obj.View();
         obj.search(); 
         obj.RemoveError();     
        }
     }