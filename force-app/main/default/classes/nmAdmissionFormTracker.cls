@isTest
private class  nmAdmissionFormTracker 
{
   
    private static nm_Payment__c objpaymnt;
    private static Opportunity objopp;
    public static nm_Program__c program; 
    public static Account objAccount;
    public static  RecordType AccountRecordType  = [select id,Name from RecordType where SobjectType='Account' and name='Person Account'];
    public static IC_Change_Request__c objIcChange;
    private static nm_Centers__c   objcen;
    public static nm_StudentProgram__c objSP ;
    public static nm_EligiblityCriteria__c eligibility;
    public static nm_EligiblityCriteria__c  objEc;  
    private static nm_Configure_the_Pages__c configPages;
    public static Product2 objProduct;
    public static Pricebook2 objPriceBook;
    public static OpportunityLineItem objLineItem ;
    public static PriceBookEntry objPriceBookEntry;
    public static nmSerialNo__c objSerial;
  
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
    static testMethod void unitTest1()
    {
        loadData();
        nmAdmissionForm obj3 = new nmAdmissionForm();       
        obj3.isValidForYearlyPayment=true;
        obj3.semFeeAmount=17000;
        obj3.objOpportunity1=objopp;
        obj3.objOpportunity2.StageName ='Registration done';
        obj3.objOpportunity2.CloseDate =System.today();
        obj3.objOpportunity2.Name='test';
        obj3.strPaymentMethod ='online';
        obj3.objPayment.nm_ModeOfPayment__c = 'Online';
        obj3.TotalPaidAmmount=17000; 
        obj3.ShowEMI();
        obj3.GetEmi();
        obj3.GetEmi1();
        obj3.GetEmi2();
        obj3.selectedduration = '03';
        obj3.Back();
        obj3.LoadData();
        //obj3.CreateRecordsForOnlinePayment();
        obj3.paymentMode();
        obj3.showHideOperations();
        obj3.GenChallan();
        obj3.PrintForm();
          
    }
  
    static void loadData()
    {
         Test.setMock(HttpCalloutMock.class, new RestMock());
         nmGenericTracker.InsertSerialNo();
         objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
         objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
         objpaymnt = nmGenericTracker.CreateRegistrationPaymentRecordForOppty(objOpp);
         nmGenericTracker.CreateOpportunityLineItem(objopp);
         
         configPages = new nm_Configure_the_Pages__c();
        configPages.Name = 'Student';
        configPages.nm_Admission_Page__c = true;    
        configPages.nm_Registration_Page__c = true;
        configPages.nm_Re_Registration_Page__c = true;
        insert configPages;
       /*  Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
         objCen= new nm_Centers__c();
         objCen.RecordTypeID = RT.id;         
         objCen.nm_CenterCode__c = '002';
         objCen.nm_CenterCity__c = 'Delhi';
         objCen.nm_City__c = 'Delhi';
         objCen.nm_StateProvince__c = 'Delhi';
         objCen.nm_Street__c = 'Krishna Nagar';
         objCen.nm_PostalCode__c = '110051';
         insert objCen;
         
         objSerial = new nmSerialNo__c();
         objSerial.nm_name__c = 'Reference Number';
         objSerial.nm_MaxGenratedNo__c=122355;
         insert objSerial;
      
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
         objEc.Name='Bachelor degree';
         objEc.Is_Active__c = true;
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.Experience_Required_In_Year__c= null ;
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c ='Certificate Programs';
         objEc.Graduation_Required__c =false;
         insert objEc;
      
        objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Confirmed';       
        objAccount.nm_SerialNo__c=2;
         objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.nm_IsDocumentApproved__c = true;
        objAccount.Is_Lateral__c=true;
        objAccount.lastname ='singh';
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721';
        objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.nm_SerialNo__c=2;
        objAccount.TimestampAdmissionfeepaid__c = system.today();
        objAccount.nm_IsDocumentApproved__c = true;
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
        objopp.PendingAmmount__c = 18000;
        objopp.nm_StudentProgram__c =objSP.id;
        objopp.AccountId=objAccount.id; 
        objopp.nm_Program__c=program.id;
     
        insert objopp;
        
        configPages = new nm_Configure_the_Pages__c();
        configPages.Name = 'Student';
        configPages.nm_Admission_Page__c = true;    
        configPages.nm_Registration_Page__c = true;
        configPages.nm_Re_Registration_Page__c = true;
        insert configPages;
       
        objProduct=new Product2();
        
        objProduct.Name='dfdf';
        objProduct.nm_Program__c=program.Id;
        objProduct.nm_Semester__c='1';
        objProduct.isActive =true;
        insert objProduct; 
           
        objPriceBook = new PriceBook2();
        objPriceBook.IsActive =true;
        objPriceBook.Name ='NMIMS New Price Book';
        objPriceBook.nmSession_End_Date__c =System.today().addDays(+2);
        objPriceBook.nmSession_Start_Date__c = System.today();  
        insert objPriceBook;
         
        objPriceBookEntry = new PriceBookEntry(); 
        objPriceBookEntry.IsActive =true ;
        objPriceBookEntry.Product2Id = objProduct.id;
        objPriceBookEntry.UseStandardPrice =false;
        objPriceBookEntry.Pricebook2Id = System.Test.getStandardPricebookId();
        objPriceBookEntry.UnitPrice =500;
        objPriceBookEntry.UseStandardPrice=false;
        insert objPriceBookEntry;
        
        objLineItem = new OpportunityLineItem(); 
        objLineItem.UnitPrice=500;
        objLineItem.Quantity=1;
        objLineItem.OpportunityId = objopp.id;
        objLineItem.PriceBookEntryId = objPriceBookEntry.id;
        insert objLineItem ;
        
        objpaymnt = new nm_Payment__c ();
        objpaymnt.nm_OpportunityNew__c =objopp.id;
        objpaymnt.nm_Amount__c = 18000;
        objpaymnt.nm_PaymentStatus__c ='Payment Made';
        objpaymnt.nm_PaymentType__c ='Admission';
        insert objpaymnt; */
        
    }
}