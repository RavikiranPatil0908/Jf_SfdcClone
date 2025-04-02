@isTest(seeAllData = true)
private class nmChangeStudentProgramTracker
{
    public static Lead objLead;
    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_StudentProgram__c objSP;
    
     private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static testmethod void TestMethod1()
    {
        Load();
        ApexPages.CurrentPage().GetParameters().put('id',objSP.Id);
        nmChangeStudentProgram obj = new nmChangeStudentProgram();
        //objLead.nm_EligiblityCriteria__c = objEc.Id;
        obj.Save();
        obj.back();
    }
    static void Load()
    {
         Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreatedDocumentForLead(objLead,'10th Certificate');
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents submitted');
        objSP =nmGenericTracker.CreatePGStudentProgram(objAccount);
        objopp = nmGenericTracker.CreateDiplomaOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
       // objPayment = nmGenericTracker.CreateAdmissionPaymentRecordForOppty(objopp);
    }
      /*
        // createPricebook();
         //createProgram();
       // createProduct2();
        
        CreatePriceBookEntry();

        Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 

        objcenter = new nm_Centers__c();

        objcenter.RecordTypeID =rt.id;         
        objCenter.nm_CenterCode__c ='002';
        objCenter.nm_CenterCity__c='Delhi';
        objCenter.nm_City__c='Delhi';
        objCenter.nm_StateProvince__c='Delhi';
        objCenter.nm_Street__c='Laxmi Ngar';
        objCenter.nm_PostalCode__c='110091';         
        insert objCenter;

        Recordtype rt1=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        objcenter1 = new  nm_Centers__c(); 
        objcenter1.nm_LearningCenter__c =  objcenter .id;         
        objcenter1.RecordTypeID =rt1.id;           
        objCenter1.nm_CenterCode__c ='002';
        objCenter1.nm_CenterCity__c='Delhi';
        objCenter1.nm_City__c='Delhi';
        objCenter1.nm_StateProvince__c='Delhi';
        objCenter1.nm_Street__c='Laxmi Ngar';
        objCenter1.nm_PostalCode__c='110091';         
        insert objCenter1;

        objcenter2 = new  nm_Centers__c(); 
        objcenter2.nm_LearningCenter__c =  objcenter .id;         
        objcenter2.RecordTypeID =rt1.id;           
        objCenter2.nm_CenterCode__c = '002';
        objCenter2.nm_CenterCity__c='Delhi';
        objCenter2.nm_City__c='Delhi';
        objCenter2.nm_StateProvince__c='Delhi';
        objCenter2.nm_Street__c='Laxmi Ngar';
        objCenter2.nm_PostalCode__c='110091';         
        insert objCenter2;
        
        objldl1 =new nm_LinksForDocumentsLead__c();
        objldl1.Name = 'Student Photograph';
        objldl1.nm_DocumentName__c='Student Photograph';
          //objldl1.nm_LinksForDocumentsLead__c=objLead .id;
        objldl1.Lead__c=objldl1.id;
        insert objldl1;

        nm_ICProgram__c objIC;
        CommonTrackerClass.createICProgram(objIC);
       
          
       

        objEc = new nm_EligiblityCriteria__c();
        objEc.Name ='NameEligibility Criteria';
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c ='Post Graduate Diploma Programs';
        objEc.Is_Active__c =true;
        insert objEc;       

        objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Registered';
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_EligiblityCriteria__c =objEc.id; 
        insert objAccount;

        objSP = new nm_StudentProgram__c ();
        objSP.nm_CurrentSession__c =2;
        objSP.nm_FeesPaidofSemester__c=2;  
        objSP.nm_Program__c=objProgram.id;
        objSP.nm_Student__c =objAccount.id;
        insert objSP ;
         
         Opportunity objopp = new Opportunity();
         objOpp.StageName = 'Registration Done';  
         objOpp.Accountid=objAccount.id;
         objOpp.nm_Program__c=objProgram.id;
         objOpp.name='yersy';
         objOpp.closeDate=system.today();
         objOpp.nm_StudentProgram__c=objSP.id;
         insert objopp;
        // objopp = CommonTrackerClass.createOpportunity(objopp);
         
        
        objLead = new Lead();       
        objLead.nm_SelectedIC__c ='1';
        objLead.LastName ='kumar tes test';
        objLead.FirstName='amit test test';
        objLead.nm_MiddleName__c='test';
        objLead.nm_DateOfBirth__c =System.today();
        objLead.status='Hot';
        objLead.Email='amit.kumar@saasfocus.com';
        objLead.MobilePhone ='8377985721';
        objLead.nm_ChooseaProgram__c ='Post Graduate Diploma Programs';
        objLead.nm_Program__c = objProgram.Id;
        objLead.nm_EligiblityCriteria__c = objEc.Id;
        objLead.nm_PaymentCompleted__c = false;
        objLead.nm_SelectedProgram__c ='MCA';
        objLead.nm_InformationCenter__c =objCenter1.id;
        objLead.nm_Year__c =2014;
        objLead.LeadSource ='Web';
        objLead.nm_PaymentStatus__c ='Registration form filled';
        objLead.nm_PlantoStart__c ='2-4 Months';
        objLead.nm_Session__c='July';
        objLead.nm_CopyAddress__c='Yes';
        objLead.nm_ModeOfPayment__c='Online';
        objLead.nm_EscallationDone__c=5;
        objLead.nm_RegistrationID__c='';
        //objLead.nm_RegistrationNo__c='a0BN0000001FUdB';
        insert objLead;
        system.debug('**Lead'+objLead);
        
        nmGenericTracker.CreateOpportunityLineItem(objopp);
    
    }

   
          
     public static void createProduct2()
    {
      
        objProduct= new Product2();
        objProduct.Name = 'Semester I'; 
        objProduct.nm_Semester__c = '1';
        objProduct.isActive = true;
        objProduct.nm_Program__c=objProgram.id;
        
        insert objProduct;
    
    
    }
    
     public static void  createPricebook()
   
     {
        
        objPricebook = new Pricebook2();
        objPricebook.Name='NMIMS Price Book';
           objPricebook.IsActive = true;
          // objPricebook.IsStandard = false;
           objPricebook.nmSession_Start_Date__c= system.today();
           objPricebook.nmSession_Start_Date__c= system.today()+1;
          
        
        insert objPricebook;
      
    }
         
        public static void  CreatePriceBookEntry()
        {
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = objProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
          
           objPricebook1= new PricebookEntry(
            Pricebook2Id = objPricebook.id, Product2Id = objProduct.Id,
            UnitPrice = 17000, IsActive = true);
            
          insert objPricebook1;
        } 

    public static void createProgram()
    {
        objProgram= new nm_Program__c ();
        objProgram.nm_ProgramCode__c='TestCode';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c='Post Graduate Diploma Programs';
        if( objProgram.nm_ProgramName__c == null)
        {
            objProgram.nm_ProgramName__c='Post Graduate Diploma in Financial Management';
           
        }
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;   
        objProgram.nmIsActive__c = true ; 
        objProgram.Name = 'PGDFM';  
        insert objProgram;
    } */
    
}