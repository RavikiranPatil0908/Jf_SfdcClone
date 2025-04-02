/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-04-2024
 * @last modified by  : @BK
**/
@isTest
public class CommonTrackerClass
{
  



    // This Method Used To Create Program
    // ------------------------------------------------------------------------------------
    // Version#     Date                    Author                          Description
    // ------------------------------------------------------------------------------------
    // 1.0         14-may-2014             Amit kumar                   Initial Version   
    // -------------------------------------------------------------------------------------
   

    public static nm_Program__c createProgram(nm_Program__c objProgram)
    {
        objProgram.nm_ProgramCode__c='001';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c ='Certificate Programs';
        if( objProgram.nm_ProgramName__c == null)
        {
            objProgram.nm_ProgramName__c='CCC';
        }
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;        
        insert objProgram;
        system.assert(objProgram.id != null);       
        return objProgram;                                
    
    }
    
    public static nm_Program__c createProgram1(nm_Program__c objProgram)
    {
        objProgram.nm_ProgramCode__c='002';
        objProgram.nm_ProgramDuration__c=1;
        objProgram.nm_Type__c ='Post Graduate Diploma Programs';
        if( objProgram.nm_ProgramName__c == null)
        {
            objProgram.nm_ProgramName__c='PGDM';
        }
        objProgram.nm_ProgramValidity__c=2;     
        objProgram.nm_TotalSemesters__c=2;        
        insert objProgram;
        system.assert(objProgram.id != null);       
        return objProgram;                                
    
    }
    

    public static Account createAccount(Account objAccount)
    {
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Confirmed';
        objAccount.PersonMobilePhone='8377985721';
         objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_SerialNo__c=2;
          if(objAccount.nm_EligiblityCriteria__c == null)
         {
         
             nm_EligiblityCriteria__c  objEcc = new nm_EligiblityCriteria__c();
             objEcc =createEligibiltyCriteria(objEcc);
             objAccount.nm_EligiblityCriteria__c =objEcc.id;
         }
        insert objAccount;
        system.assert(objAccount.id != null);  
        return objAccount;  
        
         
    }

    //  public static nm_AdmissionDriveDate__c createAdmissionDriveDate(nm_AdmissionDriveDate__c objADD)
    //  {
    //      //objADD.nm_ADDName__c ='test7499';
    //      objADD.nm_Batch__c ='January';
    //      objADD.nm_DriveDate__c=System.today();
    //      objADD.nm_StartDate__c=System.today();
         
    //      if(objADD.nm_Program__c == null)
    //      {
    //          nm_Program__c  objProgram = new nm_Program__c();
    //          objProgram  = createProgram(objProgram);
    //          objADD.nm_Program__c =objProgram.id;
    //      }
         
    //      insert objADD;
    //      system.assert(objADD.id != null); 
    //      return objADD; 
         
         
     
    //  }
     
     public static nm_Centers__c createCenter(nm_Centers__c objCenter,String RecordTypeID)
     {
       
         if(RecordTypeID !=null && RecordTypeID.trim()!='')
         {
             objcenter.RecordTypeID =RecordTypeID;
         }
         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
        
         system.assert(objCenter.id != null); 
         return objCenter; 
     
     }
     
     public static nm_EligiblityCriteria__c createEligibiltyCriteria(nm_EligiblityCriteria__c objEc)
     {
         objEc = new nm_EligiblityCriteria__c ();
         objEc.Name='NameEligibility Criteria';
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c ='Certificate Programs';
         objEC.Is_Active__c=true;
         insert objEc;
         system.assert(objEc.id != null); 
         return objEc; 
     }
     
     
     
     public static Lead createLead(Lead objLead)
     {
          
        // objLead = new  Lead();
         objLead.LastName ='kumar';
         objLead.FirstName='amit';
         objLead.nm_DateOfBirth__c =System.today();
         objLead.status='Hot';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.nm_ChooseaProgram__c ='Certificate Programs';
         
        /*  if(objLead.nm_Program__c == null)
         {
              nm_Program__c  objProgram = new nm_Program__c();
              objProgram  = createProgram(objProgram);
              objProgram.nm_Type__c='Certificate Programs';
              objLead.nm_Program__c=objProgram.id;
         
         }*/
       
       /*  if(objLead.nm_InformationCenter__c == null)
         {
             nm_Centers__c obj = new nm_Centers__c ();
             obj  =createCenter(obj,'');
             objLead.nm_InformationCenter__c =obj.id;
         
         }*/
         
       /*  if(objLead.nm_EligiblityCriteria__c == null)
         {
         
             nm_EligiblityCriteria__c  objEcc = new nm_EligiblityCriteria__c();
             objEcc =createEligibiltyCriteria(objEcc);
             objLead.nm_EligiblityCriteria__c =objEcc.id;
         }*/
         
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Walk -in';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='0-7 week';
         insert objLead;
         system.assert(objLead.id != null); 
         return objLead; 
     }
     
     public static  nm_StudentProgram__c createStudentProgram(nm_StudentProgram__c objSP)
     {
         objSP = new nm_StudentProgram__c ();
         objSP.nm_CurrentSession__c =2;
         objSP.nm_FeesPaidofSemester__c=2;  
         
           
         
         if(objSP.nm_EligiblityCriteria__c == null)
         {
         
             nm_EligiblityCriteria__c  objEcc = new nm_EligiblityCriteria__c();
             objEcc =createEligibiltyCriteria(objEcc);
             objSP.nm_EligiblityCriteria__c =objEcc.id;
         }
         if(objSP.nm_Program__c == null)
         {
              nm_Program__c  objProgram = new nm_Program__c();
              objProgram  = createProgram(objProgram);
              objSP.nm_Program__c=objProgram.id;
         
         }
         
         if(objSP.nm_Student__c == null)
         {
             Account objAcc = new Account();
             objAcc =createAccount(objAcc);
             objSP.nm_Student__c =objAcc.id;
         }
         
         insert objSP;
         system.assert(objSP.id != null); 
         return objSP; 
     }
     
     
      public static User createUser(string strUserName, string profileId)
    {
        string languageLocale = [Select LanguageLocaleKey From Organization].LanguageLocaleKey;
        User objTempUser = new User();        
        objTempUser.Username = strUserName ;
        objTempUser.LastName = strUserName;
        objTempUser.Email = 'amit.amity10899@gmail.com';
        objTempUser.Alias = '0A234';
        objTempUser.TimeZoneSidKey = 'America/Chicago' ;
        objTempUser.LocaleSidKey = 'en_US' ;
        objTempUser.EmailEncodingKey = 'ISO-8859-1' ;
        objTempUser.ProfileId = profileId;   
        objTempUser.LanguageLocaleKey = languageLocale ;
       // objTempUser.ManagerId = managerId;
        objTempUser.IsActive = true;
        insert objTempUser;        
        // assert Check 
        User localUser = [select id, Username,Email from user where id =: objTempUser.id ];
        system.assertEquals(localUser.Email , strUserName.toLowerCase());
        
        return objTempUser;
    } 
     
     
    public static nm_UserMapping__c createCenterUsers(nm_UserMapping__c  objUsrMap)
    {
       
        objUsrMap.nm_Head__c =true;       
        insert objUsrMap ;
        system.assert(objUsrMap .id != null); 
        return objUsrMap ; 
    }
     
    public static nm_CourseMaster__c createCourseMaster(nm_CourseMaster__c objCM)
    {
        objCM =new nm_CourseMaster__c();
        objCM.name='DATABASE';
        insert objCM;
        System.assert(objCM.id!=null);
        return objCM;
    } 
  


     public static Product2 createProduct(Product2 objProduct)
    {       
        
        objProduct.Name = 'Registration Fee'; 
        if(objProduct.nm_Program__c == null)
        {
            nm_Program__c  objProgram = new nm_Program__c();
            objProgram  = createProgram(objProgram);
            objProduct.nm_Program__c=objProgram.id;
        
        }       
        insert objProduct;        
        system.assert(objProduct.id != null);        
        return objProduct;
    }

    public static nm_Courses__c  createCourse(nm_Courses__c  objCourse)
    {
        objCourse = new nm_Courses__c();
        if(objCourse.nm_CourseMaster__c == null)
        {
              nm_CourseMaster__c objCM =   new nm_CourseMaster__c ();
              objCM =createCourseMaster(objCM);
              objCourse.nm_CourseMaster__c  = objCM.id;
        }
        
        if(objCourse.nm_Semester__c == null)
        {
            Product2 objProduct = new Product2();
            objProduct = createProduct(objProduct );
            objCourse.nm_Semester__c =objProduct.id;
        
        }
        
        insert objCourse;
        system.assert(objCourse.id != null);        
        return objCourse;
        
    }
    public static nm_Holidays__c creatHolidays(nm_Holidays__c  objHD)
    {
        objHD = new nm_Holidays__c ();
        objHD.nm_Date__c = System.today();
        insert objHD;
        system.assert(objHD.id != null);        
        return objHD; 
    }
    
    public static nm_ICProgram__c   createICProgram(nm_ICProgram__c objICP)
    {
        objICp = new nm_ICProgram__c ();
         if(objICp .nm_Program__c == null)
         {
              nm_Program__c  objProgram = new nm_Program__c();
              objProgram  = createProgram(objProgram);
              objICp .nm_Program__c=objProgram.id;
         
         }
         
          if(objICp.nm_Centers__c == null)
        {
            nm_Centers__c obj = new nm_Centers__c ();
            obj  =createCenter(obj,'');
            objICp .nm_Centers__c =obj.id;
        }
        insert objICp;
        System.assert(objICp.id!=null);
        return objICp ;
    }
    
// public static Opportunity createOpportunityForLateral(Opportunity objOpp)
// {
//     objOpp.name ='test opp';
//         if(objOPP.StageName == null)
//         {
//             objOPP.StageName ='Registration done';
//         }
//         objOpp.nm_Session__c = 'January' ;
//         objOpp.CloseDate =System.today();
//         objOPP.nm_Semester__c = '3';
//         objOPP.nm_year__c =2014;
//         objOpp.nm_Category__c = 'Lateral Admission';
        
        
//     if(objOpp.nm_AdmissionDriveDate__c==null)
//       {
//           nm_AdmissionDriveDate__c objADD= new nm_AdmissionDriveDate__c();
//           objADD=createAdmissionDriveDate(objADD);
//           objOpp.nm_AdmissionDriveDate__c= objADD.id;
//       } 
//        if(objOPP.nm_Program__c == null)
//        {
//               nm_Program__c  objProgram = new nm_Program__c();
//               objProgram  = createProgram(objProgram);
//               objOPP.nm_Program__c=objProgram.id;
         
//        }
//       if(objOpp.Account == null)
//       {
         
//               Account objAcc = new Account();
//               objAcc= createAccount(objAcc);
//               objOpp.AccountId=objAcc.id;
         
         
//       }
     
//       insert objOpp;
//       System.assert(objOpp.id!=null);
//       return objopp;
//     }



   
// public static Opportunity createOpportunity(Opportunity  objOPP)
//     {  
//         //objOPP = new Opportunity ();      
//         objOpp.name ='test opp';
//         if(objOPP.StageName == null)
//         {
//             objOPP.StageName ='Registration done';
//         }
//         objOpp.nm_Session__c = 'January' ;
//         objOpp.CloseDate =System.today();
//         objOPP.nm_Semester__c = '1';
//         objOPP.nm_year__c =2014;
        
        
//     if(objOpp.nm_AdmissionDriveDate__c==null)
//       {
//           nm_AdmissionDriveDate__c objADD= new nm_AdmissionDriveDate__c();
//           objADD=createAdmissionDriveDate(objADD);
//           objOpp.nm_AdmissionDriveDate__c= objADD.id;
//       } 
//        if(objOPP.nm_Program__c == null)
//        {
//               nm_Program__c  objProgram = new nm_Program__c();
//               objProgram  = createProgram(objProgram);
//               objOPP.nm_Program__c=objProgram.id;
         
//        }
//       if(objOpp.Account == null)
//       {
         
//               Account objAcc = new Account();
//               objAcc= createAccount(objAcc);
//               objOpp.AccountId=objAcc.id;
         
         
//       }
     
//       insert objOpp;
//       System.assert(objOpp.id!=null);
//       return objOpp;
//     }
    
    public static nm_LinksForDocuments__c createLinkForDocuments(nm_LinksForDocuments__c objLCD)
    {
        objLCD = new nm_LinksForDocuments__c();
        objLCD.nm_Status__c ='Disapproved';
        objLCD.nm_ReasonforDisapprove__c ='test';
        if(objLCD.nm_Account__c == null)
        {
            Account objAcc = new Account();
            objAcc= createAccount(objAcc);
            objLCD.nm_Account__c=objAcc.id;
        }
        insert objLCD;
        System.assert(objLCD.id != null);
        return objLCD;
    }
    
    // public static nm_Payment__c createPayment(nm_Payment__c objPayment)
    // {
    //     objPayment = new nm_Payment__c ();
    //     nmSerialNo__c objSerial = new nmSerialNo__c();
    //     if(objPayment.nm_OpportunityNew__c == null)
    //     {
    //         Opportunity objOpp = new Opportunity();
    //         objOpp = createOpportunity(objOpp);
    //         objPayment.nm_OpportunityNew__c =objOpp.id;
    //         objSerial=new nmSerialNo__c();
    //         objSerial.nm_MaxGenratedNo__c=1;
    //         objSerial.nm_name__c='Fee Receipt Counter';
                
    //     }
    //     insert objSerial;
    //     insert objPayment;
    //     System.assert(objPayment.id!=null);
    //     return objPayment;
    // }
    
    
   public static Campaign createCampaign(Campaign   objCmpg)
   {
     objCmpg = new  Campaign();  
     objCmpg.name ='test';
     insert objCMPg;
     System.assert(objCMPg.id!=null);
     return objCmpg;
     
   }
    
     public static nm_CampaignCenter__c createCampaignCenter(nm_CampaignCenter__c objCC)
    {
       objCC = new  nm_CampaignCenter__c ();
       if(objCC.Campaign__c == null)
       {
           Campaign obj = new Campaign();
           obj =createCampaign(obj);
           objCC.Campaign__c =obj.id;
       
       }
       
        if(objCC.Center__c== null)
        {
            nm_Centers__c obj = new nm_Centers__c ();
            obj  =createCenter(obj,'');
            objCC.Center__c=obj.id;
        }
      insert objCC;
     System.assert(objCC.id!=null);
     return objCC;
    }
     public static Pricebook2 createPricebook(){
        
        Pricebook2 objPricebook = new PriceBook2();
        if(objPricebook.Name == null){
            objPricebook.Name = 'WB';
        }
        objPricebook.IsActive = true;
        
        insert objPricebook;
        system.assertEquals(objPricebook.Id != null, true);
        return objPricebook;
    }
    
    
    public static PricebookEntry CreatePriceBookEntry(string productId, string pricebookId)
    {
        list<PriceBook2> lstPb = new list<PriceBook2>();
        lstPb = [select id,Name from Pricebook2 where Name = 'Standard Price Book' AND isActive = true];
        
        PricebookEntry pbStandardEntry = new PricebookEntry(
                                                    UnitPrice = 500000,
                                                    PriceBook2Id = lstPb[0].Id,
                                                    Product2Id = productId,
                                                    UseStandardPrice = false,
                                                    IsActive = true
                                                    );
        Insert pbStandardEntry;
        
        PricebookEntry objPricebookEntry = new PricebookEntry(
                                                    UnitPrice = 500000,
                                                    PriceBook2Id = pricebookId,
                                                    Product2Id = productId,                                                    
                                                    IsActive = true
                                                    );
        insert objPricebookEntry;
        
        
        return objPricebookEntry;
    }
    
      public static nm_WorkExperience__c createWorkExperience(nm_WorkExperience__c objWrkExp)
    {
       objWrkExp = new  nm_WorkExperience__c ();
       if(objWrkExp.nm_Lead__c== null)
       {
           Lead obj = new Lead();
           obj =createLead(obj);
           objWrkExp.nm_Lead__c=obj.id;
       }
       
         if(objWrkExp.nm_Student__c== null)
      {
              Account objAcc = new Account();
              objAcc= createAccount(objAcc);
              objWrkExp.nm_Student__c=objAcc.id;
      }
      objWrkExp.nm_StartDate__c=System.today();
      objWrkExp.nm_EndDate__c=System.today();
      
     insert objWrkExp;
     System.assert(objWrkExp.id!=null);
     return objWrkExp;
    }
    
    
    
  /*  public static nm_LinksForDocumentsLead__c createnm_LinksForDocumentsLead(nm_LinksForDocumentsLead__c objLCDL)
   {
     objLCDL = new nm_LinksForDocumentsLead__c ();
    objLCDL.nm_Status__c ='Disapproved';
    objLCDL.nm_ReasonforDisapprove__c ='test';
   
     if(objLCDL.Lead__c ==null)
   {
      // Lead objlead = new Lead();


            Lead obj = new Lead();
           obj =createLead(obj);
           objLCDL.Lead__c=obj.id;
    }
   insert objLCDL;
        System.assert(objLCDL.id != null);
        return objLCDL;

    }
    */
    
   
    
}