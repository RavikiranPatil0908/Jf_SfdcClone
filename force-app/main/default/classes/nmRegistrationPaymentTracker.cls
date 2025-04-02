/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-06-2022
 * @last modified by  : shubhranshu
**/
@isTest(SeeAllData=false)
public class nmRegistrationPaymentTracker {
 public static Lead objLead;
    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_Program__c program; 
    public static User objUser;
    public static nm_UserMapping__c objUserMap;
    public static nm_EligiblityCriteria__c objEc;
    public static nm_Centers__c centerInformationCenter;
    public static nm_Centers__c centerLearningCenter;
    public static nm_Centers__c   objcen;
    public static Pricebook2 objPriceBook;
    public static nm_StudentProgram__c objSP ;
    public static nm_Payment__c objPayment;
     public static nm_Program__c objProgram; 
     public static nmSerialNo__c objSerial;
     public static Product2 objProduct;
     public static OpportunityLineItem objLineItem ; 
     public static nm_Holidays__c objHoliday;
     //public static SystemConfiguration__c objSystemConfiguration;
      public static nm_UserMapping__c objMap ;
    public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
   list<nm_Payment__c> insertList = new List<nm_Payment__c>();
   
    public static testMethod void UnitTest1()
   {
       LoadData();
            
       nmRegistrationPayment Controller =new nmRegistrationPayment();
       
    }
    
   /* public static  testmethod void UpdateLeadTest()
    {
        LoadData();
       apexpages.currentpage().getparameters().put('id',objLead.id);
       apexpages.currentpage().getparameters().put('oppId',objopp.id);
       ApexPages.currentPage().getParameters().put('payOpt','2');
      nmRegistrationPayment Controller =new nmRegistrationPayment();
      // Controller.strLeadId=objLead.id;
       Controller.objLead.nm_Fee_Type__c ='registration';
       Controller.UpdateLead(objLead.id);
       Controller.opportunityId ='NA';
       Controller.objPayment.nm_ModeOfPayment__c = 'Demand Draft';
       Controller.objPayment.nm_DemandDraftNumber__c  = '1234567';
       Controller.objPayment.nm_DemandDraftDate__c = System.today();
       Controller.objPayment.nm_NameoftheBank__c  = 'SBI';
       Controller.objPayment.nm_BankLocation__c  = 'Mumbai';
       Controller.objPayment.nm_DispatchDate__c = System.today();
       Controller.strSelectedPayFor ='PGAllSemFee';
       Controller.SaveDD();
       Controller.opportunityId ='NA';
       Controller.strSelectedPayFor ='MultipleSemFee';
       Controller.SaveDD();
    }*/
    
    /* public static testMethod void UnitTest2()
   {
       LoadData();
       apexpages.currentpage().getparameters().put('id',objLead.id);
       apexpages.currentpage().getparameters().put('oppId',objopp.id);
       ApexPages.currentPage().getParameters().put('payOpt','2');
       nmRegistrationPayment Controller =new nmRegistrationPayment();
       //Controller.payOptions.Option4.PaymentType='PGAllSemFee';
       Controller.payOptions.Option4.Amount=62000;
        Controller.strSelectedPayFor ='admission';
       Controller.makePayment();
       Controller.strSelectedPayFor ='registration';
       Controller.makePayment();
       Controller.strSelectedPayFor ='fullFee';
       Controller.makePayment();
        Controller.strSelectedPayFor ='PGAllSemFee';
       Controller.makePayment();
       Controller.strSelectedPayFor ='AnnualFee';
       Controller.makePayment();
       Controller.strSelectedPayFor ='MultipleSemFee';
       Controller.makePayment();
       Controller.PrintForm();
       Controller.opportunityId ='NA';
       Controller.objPayment.nm_ModeOfPayment__c = 'Demand Draft';
       Controller.objPayment.nm_DemandDraftNumber__c  = '1234567';
       Controller.objPayment.nm_DemandDraftDate__c = System.today();
       Controller.objPayment.nm_NameoftheBank__c  = 'SBI';
       Controller.objPayment.nm_BankLocation__c  = 'Mumbai';
       Controller.objPayment.nm_DispatchDate__c = System.today();
       Controller.strSelectedPayFor ='Registration';
       Controller.SaveDD();
       Controller.opportunityId ='NA';
       Controller.strSelectedPayFor ='admission';
       Controller.SaveDD();
       Controller.opportunityId ='NA';
       Controller.strSelectedPayFor ='AnnualFee';
       Controller.SaveDD();
       Controller.UpdateLeadBeforePayment(objLead.id);
   }  
    public static  testmethod void UpdateLeadTest3()
    {
        LoadData();
         objLead.nm_Fee_Type__c ='PGAllSemFee';
         update objLead;
       apexpages.currentpage().getparameters().put('id',objLead.id);
       apexpages.currentpage().getparameters().put('oppId',objopp.id);
       ApexPages.currentPage().getParameters().put('payOpt','2');
       nmRegistrationPayment Controller =new nmRegistrationPayment();
       Controller.strLeadId=objLead.id;
       Controller.objLead.nm_Fee_Type__c ='registration';
       Controller.UpdateLead(objLead.id);
       Controller.opportunityId ='NA';
       Controller.objPayment.nm_ModeOfPayment__c = 'Demand Draft';
       Controller.objPayment.nm_DemandDraftNumber__c  = '1234567';
       Controller.objPayment.nm_DemandDraftDate__c = System.today();
       Controller.objPayment.nm_NameoftheBank__c  = 'SBI';
       Controller.objPayment.nm_BankLocation__c  = 'Mumbai';
       Controller.objPayment.nm_DispatchDate__c = System.today();
       Controller.strSelectedPayFor ='PGAllSemFee';
       Controller.SaveDD();
       Controller.opportunityId ='NA';
       Controller.strSelectedPayFor ='MultipleSemFee';
       Controller.SaveDD();
    }
   */
    static void LoadData()
    {
       
       nm_EscalationMatrix__c objCustomSeetings3 = new nm_EscalationMatrix__c();
        
        objCustomSeetings3.name='0-1 Months';
        objCustomSeetings3.nm_LCEscalationTime__c='22:45';
        objCustomSeetings3.nm_RemidertoIC__c='22:45';
        objCustomSeetings3.nm_HOEscalationTime__c='20:56';
        objCustomSeetings3.nm_RemidertoHO__c='22:45';
        
        insert objCustomSeetings3;
        
        nm_EscalationMatrix__c objCustomSeetings = new nm_EscalationMatrix__c();
        
        objCustomSeetings.name='3-6 Months';
        objCustomSeetings.nm_LCEscalationTime__c='20:45';
        objCustomSeetings.nm_RemidertoIC__c='21:45';
        objCustomSeetings.nm_HOEscalationTime__c='20:56';
        objCustomSeetings.nm_RemidertoHO__c='21:45';
        
        insert objCustomSeetings; 
        
        nm_EscalationMatrix__c objCustomSeetings2 = new nm_EscalationMatrix__c();
        objCustomSeetings2.name='3-4 Months';
        objCustomSeetings2.nm_LCEscalationTime__c='20:34';
        objCustomSeetings2.nm_RemidertoIC__c='21:45';
        objCustomSeetings2.nm_HOEscalationTime__c='20:56';
        objCustomSeetings2.nm_RemidertoHO__c='21:45';
        insert objCustomSeetings2; 
        
       objHoliday=new nm_Holidays__c();
        objHoliday.Name='Holi';
        objHoliday.nm_Date__c=system.today();
        insert objHoliday;
        
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        insert objSystemConfiguration;

        user usr = [Select id from user limit 1];
        
        objMap = new nm_UserMapping__c();
        objMap.nm_User__c =usr.id;
         
         
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
         
       program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = 'Post grad diploma finance';
       program.nm_ProgramValidity__c = 4;
       program.nm_TotalSemesters__c = 4;
       program.nm_Type__c = 'Post Graduate Diploma Program';
                 
       insert program; 
       
      objSerial = new nmSerialNo__c();
      objSerial.nm_MaxGenratedNo__c=122355;
      objSerial.nm_name__c='Reference Number';
      insert objSerial;
       
       objSerial = new nmSerialNo__c();
      objSerial.nm_MaxGenratedNo__c=122355;
      objSerial.nm_name__c='Fee Receipt Counter';
      insert objSerial;
        
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        objUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg.com');
        insert objUser;    
        
          objUserMap= new nm_UserMapping__c();
      objUserMap.nm_Centers__c=objCen.id;
      objUserMap.nm_User__c=objUser.id;
      objUserMap.nm_Phone__c='326392156';
      objUserMap.nm_Head__c= true;
      insert objUserMap;
      
       objEc = new nm_EligiblityCriteria__c ();
         objEc.Name='Bachelor degree';
         objEc.Is_Active__c = true;
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.Experience_Required_In_Year__c= null ;
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c ='Certificate Programs';
         objEc.Graduation_Required__c =false;
         insert objEc;
     
      objLead = new  Lead();
         objLead.nm_SelectedIC__c ='1';
         objLead.LastName ='kumar';
         objLead.FirstName='amit';
         objLead.nm_DateOfBirth__c =Date.newInstance(1990, 12, 9);
         objLead.status='Reborn';
         //objLead.Lead_Description__c = 'Will register in a week or 10 days';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.nm_ChooseaProgram__c ='Certificate Programs';
         //objLead.nm_Program__c = objP.Id;
         objLead.nm_EligiblityCriteria__c = objEc.Id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_SelectedProgram__c ='MCA';
         objLead.nm_InformationCenter__c =objCen.id;
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Walk -in';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=8;
         objLead.nm_RegistrationID__c='00QO0000005DojN';
         
         insert objLead;
         
         objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Admission form & documents submitted';       
        objAccount.nm_SerialNo__c=2;
         objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
         objAccount.nm_LeadId__c='00QO0000003JgdZ';
        objAccount.Is_Lateral__c=true;
        //objAccount.nm_Centers__c=objCen.id;        
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721';
        objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.nmStudent_Program__c ='Advance Certificate in Digital Marketing';
        //objAccount.Owner=objUser;
            objAccount.nm_SerialNo__c=2;
        
        objAccount.nm_Centers__c=objCen.id;
        insert objAccount;
            
         objSP = new nm_StudentProgram__c ();
         objSP.nm_Student__c =objAccount.id;
         //objSP.nm_EligiblityCriteria__c =objEc.id;
         objSP.nm_FeesPaidofSemester__c = 3;
         objSP.nm_Program__c = program.id;
         insert objSP;   
            
            
          objopp =new Opportunity();
        objopp.StageName='Payment made';
        objopp.nm_Payment_Approved__c =true;
        objopp.CloseDate=System.today();
        objopp.nm_Semester__c='1';
        objopp.Name='Chandra_Singh_11DSCM_Sem_1_Jan_2015';
        objopp.nm_StudentProgram__c =objSP.id;
        objopp.AccountId=objAccount.id; 
        objopp.nm_Program__c=program.id;
        objopp.nm_Session__c='July';
        objopp.nm_Year__c=2020;

     
        insert objopp;
        
        objProduct=new Product2();
        
        objProduct.Name='dfdf';
        objProduct.nm_Program__c=program.Id;
        objProduct.nm_Semester__c='1';
        objProduct.isActive =true;
        insert objProduct; 
         
           
        
         
         nm_Payment__c objPayment2 = new nm_Payment__c ();
        objPayment2.nm_OpportunityNew__c =objopp.id;
        objPayment2.nm_Amount__c = 4272;
        objPayment2.nm_PaymentStatus__c ='Payment Made';
         objPayment2.nm_PaymentType__c ='Admission';
        insert objPayment2; 
        
            
    }
   
}