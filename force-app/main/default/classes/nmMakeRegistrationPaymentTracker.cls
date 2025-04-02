@isTest(seeAllData=true)
public class nmMakeRegistrationPaymentTracker
{
    public static Lead objLead;
    public static Opportunity objopp;   
    public static Account objAccount;
    public static nm_Payment__c objPayment;
    public static nm_Payment__c objPayment1;
    public static nm_StudentProgram__c objStudPrgm;
    public  static List<nm_StudentProgram__c> lstSP ;
    public  static id strStudentProgramid ;
    public  static string strtype;
     public static PriceBookEntry objPriceBook;
     public static Product2 objProduct;
     public static PriceBook2 objPrice2;
     
     private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    } 
    public static testmethod void TestMethod1()
    {
        LoadData();
         PageReference pg = new PageReference('apex/nmMakeRegistrationPayment');
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id',objLead.id);
        //apexpages.currentpage().getparameters().put('spid',objStudPrgm.id);
        ApexPages.currentPage().getParameters().put('type','Account');
        nmMakeRegistrationPayment obj = new nmMakeRegistrationPayment();
       /* obj.objPayment.nm_DemandDraftNumber__c ='DF123';
        obj.objPayment.nm_DemandDraftDate__c =system.today();
        obj.objPayment.nm_NameoftheBank__c= 'SBI';
        obj.objPayment.nm_BankLocation__c='noida';*/
        obj.objPayment.nm_ModeOfPayment__c ='Online';
       // obj.objPayment.nm_DispatchDate__c=system.today();
        obj.MakePayment();
        obj.GenChallan();
    }
    public static testmethod void TestMethod2()
    {
        LoadData();
        //ApexPages.currentPage().getParameters().put('id',objLead.id);
        apexpages.currentpage().getparameters().put('spid',objStudPrgm.id);
        ApexPages.currentPage().getParameters().put('type','Account');
        nmMakeRegistrationPayment obj = new nmMakeRegistrationPayment();
        obj.objPayment.nm_DemandDraftNumber__c ='DF123';
        obj.objPayment.nm_DemandDraftDate__c =system.today();
        obj.objPayment.nm_NameoftheBank__c= 'SBI';
        obj.objPayment.nm_BankLocation__c='noida';
        obj.objPayment.nm_ModeOfPayment__c ='Demand Draft';
        obj.objPayment.nm_DispatchDate__c= System.today();
        obj.MakePayment();
        obj.GenChallan();
    }
    public static testmethod void TestMethod3()
    {
        LoadData();
       // ApexPages.currentPage().getParameters().put('id',objLead.id);
       // apexpages.currentpage().getparameters().put('spid',objStudPrgm.id);
        ApexPages.currentPage().getParameters().put('type','Account');
        nmMakeRegistrationPayment obj = new nmMakeRegistrationPayment();
        obj.objPayment.nm_DemandDraftNumber__c ='DF123';
        obj.objPayment.nm_DemandDraftDate__c =system.today();
        obj.objPayment.nm_NameoftheBank__c= 'SBI';
        obj.objPayment.nm_BankLocation__c='noida';
        obj.objPayment.nm_ModeOfPayment__c ='Demand Draft';
        obj.objPayment.nm_DispatchDate__c= null;
        obj.MakePayment();
        obj.GenChallan();
    }
    
    /*
    public static testmethod void itShould1()
    {
     LoadData();
   //  loadData1();
     nmMakeRegistrationPayment obj = new nmMakeRegistrationPayment();
     obj.MakeOnlinePayment();
    }*/
   
    static void LoadData()
    {
         Test.setMock(HttpCalloutMock.class, new RestMock());
         objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
         objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Admission form & documents submitted');
         objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
         nmGenericTracker.CreateCertificateStudentProgram(objAccount);
         nmGenericTracker.CreateOpportunityLineItem(objopp);
         objStudPrgm = nmGenericTracker.CreateStudentProgram(objAccount,'Certificate Programs');
         objPayment = nmGenericTracker.CreatePaymentRecordForLead(objLead,'Admission');
         objPayment = nmGenericTracker.CreatePaymentRecordForOpportunity(objopp,'Admission');
         
    }
        /*
        nm_Program__c objProgram1 = new nm_Program__c();
        objProgram1.nm_ProgramCode__c='001';
        objProgram1.nm_ProgramDuration__c=3;
        objProgram1.nm_Type__c ='Post Graduate Diploma Programs';
        objProgram1.nm_ProgramValidity__c=6;     
        objProgram1.nm_TotalSemesters__c=4;        
        insert objProgram1;
        
               
        Account objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Confirmed';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonEmail = 'test@test.com';
        objAccount.PersonMobilePhone = '9881254874';
        insert objAccount;
        
        System.debug('***Account'+objAccount);
         strStudentProgramid = ApexPages.currentPage().getParameters().get('spid');
         strtype = ApexPages.currentPage().getParameters().get('type');
         lstSP = new  List<nm_StudentProgram__c>();
         
                                      
       // if(listLead != null && listLead.size() > 0)
        objStudPrgm = new nm_StudentProgram__c ();
        // objStudPrgm.nm_EligiblityCriteria__c = objEc.Id;
        objStudPrgm.nm_Program__c = objProgram1.Id;
        objStudPrgm.nm_Student__c = objAccount.Id;
        objStudPrgm.nm_CurrentSession__c =23;
        objStudPrgm.nm_FeesPaidofSemester__c=21;
        //objStudPrgm.nm_IsClosed__c = false; 
        insert objStudPrgm;
        
        Opportunity objopp = new Opportunity();
        objopp.nm_StudentProgram__c=objStudPrgm.id;
        objopp= CommonTrackerClass.createOpportunity(objopp);
        
        nm_Payment__c objPaymnt2 = new nm_Payment__c(); 
        objPaymnt2.nm_PaymentType__c='Admission';
        objPaymnt2.nm_ModeOfPayment__c='Demand Draft';
        objPaymnt2.nm_DemandDraftNumber__c='234234';
        //objPaymnt2.nm_DemandDraftDate__c=system.today();
        //objPaymnt2.nm_NameoftheBank__c='SBI';
        objPaymnt2.nm_ModeOfPayment__c ='Demand Draft';
        objPaymnt2.nm_OpportunityNew__c =objopp.id;
        objPaymnt2.nm_BankLocation__c='noida';
        objPaymnt2.nm_Amount__c = 1000;
        objPaymnt2.nm_DispatchDate__c=null;
        insert objPaymnt2; 
        
        nm_EligiblityCriteria__c  objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='NameEligibility Criteria';
        objEc.nm_Documnetslist__c ='10th Marksheet';
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c ='Post Graduate Diploma Programs';
        insert objEc;
      
          Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center']; 
         nm_Centers__c objCenter = new nm_Centers__c();
             
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
      
        objLead = new Lead();
        objLead.LastName ='kumar';
        //objLead.nm_EligiblityCriteria__c = objEc.Id;
        objLead.FirstName='amit';
        objLead.nm_MiddleName__c='babar';
        objLead.nm_DateOfBirth__c =System.today();
        objLead.status='Hot';
        objLead.Email='amit.kumar@saasfocus.com';
        objLead.MobilePhone ='8377985721';
        objLead.nm_ChooseaProgram__c ='Post Graduate Diploma Programs';
        objLead.nm_Year__c =2014;
        objLead.LeadSource ='Walk -in';
        //objLead.nm_Program__c=objProgram1.id;
        objLead.nm_PaymentStatus__c ='Registration form filled';
        //objLead.nm_SelectedProgram__c='Post Graduate Diploma Programs';
        objLead.nm_PlantoStart__c ='0-1 week';
        objLead.nm_ModeOfPayment__c='Online';
        objLead.nm_EscallationDone__c=5;
        objLead.nm_RegistrationID__c='';
        objlead.nm_InformationCenter__c =objCenter.id;
        insert objLead;
    }
    
    static void loadData()
    {
     nm_Program__c objProgram = new nm_Program__c();
        objProgram.nm_ProgramCode__c='001';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c ='Post Graduate Diploma Programs';
        objProgram.nm_ProgramValidity__c=6;     
        objProgram.nm_TotalSemesters__c=4;        
        insert objProgram;
        
    objProduct = new Product2();
    objProduct.IsActive=true;
    objProduct.nm_Program__c=objProgram.id;
    objProduct.nm_Semester__c='1';
    objProduct.ProductCode='abc';
    objProduct.Description='xyz';
    objProduct.Name='Registration Fee';
    insert objProduct;
    
    Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
    if (!standard.isActive) 
    {
            standard.isActive = true;
            update standard;
    }
    
    objPrice2 =new PriceBook2();
    objPrice2.IsActive=true;
    //objPrice2.IsStandard=true;
    objPrice2.Name='NMIMS Price Book';
    objPrice2.nmSession_End_Date__c=system.today()+1;
    objPrice2.nmSession_Start_Date__c=system.today();
    insert objPrice2;
    
    PriceBookEntry objPriceBook1 =new PriceBookEntry();
    objPriceBook1.IsActive=true;
    objPriceBook1.UnitPrice=1000;
    objPriceBook1.Pricebook2Id=standard.id;
    objPriceBook1.Product2Id=objProduct.id;
    //objPriceBook.ProductCode='abc';
   // objPriceBook1.StandardPrice=1000;
    objPriceBook1.UseStandardPrice=false;
    insert objPriceBook1;
    
    objPriceBook =new PriceBookEntry();
    objPriceBook.IsActive=true;
    objPriceBook.UnitPrice=1000;
    objPriceBook.Pricebook2Id=objPrice2.id;
    objPriceBook.Product2Id=objProduct.id;
    //objPriceBook.ProductCode='abc';
    //objPriceBook.StandardPrice=;
    objPriceBook.UseStandardPrice=false;
    insert objPriceBook;
    
  
    
    }
   */
    
}