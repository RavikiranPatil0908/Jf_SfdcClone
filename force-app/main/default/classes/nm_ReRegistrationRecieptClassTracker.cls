@isTest
private class nm_ReRegistrationRecieptClassTracker
{

        private static opportunity objopp;
        private static nm_Payment__c objPayment ;
        public static nm_Payment__c objPaymnt2;
        public static nmSerialNo__c serial;
        public static Account objAccount;
        public static  nm_EligiblityCriteria__c  objEC;
        public static nm_Centers__c objCen;
        public static nm_StudentProgram__c objSP ;
        public static nm_Program__c program;
        public static Product2 objProduct;
        public static Pricebook2 objPriceBook;
        public static OpportunityLineItem objLineItem ;
        public static PriceBookEntry objPriceBookEntry;
        
     static testMethod void unitTest1()
     {
            serial =  new nmSerialNo__c();          
            serial.nm_MaxGenratedNo__c =50;
            serial.nm_name__c = 'Fee Receipt Counter';            
            insert serial;
            serial =  new nmSerialNo__c();
            serial.nm_MaxGenratedNo__c =0;
            serial.nm_name__c = 'Reference Number';            
            insert serial;
        string strrecord = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1].id; 
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
        
        objEc = new nm_EligiblityCriteria__c ();
         objEc.Name='Bachelor degree';
         objEc.Is_Active__c = true;
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.Experience_Required_In_Year__c= null ;
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c ='Certificate Programs';
         objEc.Graduation_Required__c =false;
         insert objEc; 
             
          program = new nm_Program__c();
       program.nmIsActive__c = true;
       program.nm_ProgramCode__c = 'test';
       program.nm_ProgramDuration__c= 2.0;
       program.nm_ProgramName__c = 'Post grad diploma finance';
       program.nm_ProgramValidity__c = 4;
       program.nm_TotalSemesters__c = 4;
       program.nm_Type__c = 'Post Graduate Diploma Program';
                 
       insert program; 
       
     
         
        objAccount= new Account(); 
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Admission form & documents submitted';       
        objAccount.nm_SerialNo__c=2;
        objAccount.nm_Relationship__c='Personal'; 
        objAccount.nm_DefencePersonnel__c ='Yes';
        objAccount.nm_LeadId__c='00QO0000003JgdZ';
        objAccount.Is_Lateral__c=true;
        objAccount.lastname ='singh';
        objAccount.FirstName='Chandra';
        objAccount.nm_AccountEmail__c='chandra@gmail.com';
        objAccount.lastname ='kumar';
        objAccount.PersonMobilePhone='8377985721';
        objAccount.PersonEmail='chandra@gmail.com';
        objAccount.nm_EligiblityCriteria__c=objEc.Id;
        objAccount.nm_SerialNo__c=2;
        objAccount.nmStudent_Program__c='Certificate in Digital Marketing';  
        objAccount.nm_Centers__c=objCen.id;
        insert objAccount;
            
         objSP = new nm_StudentProgram__c ();
         objSP.nm_Student__c =objAccount.id;
         objSP.nm_FeesPaidofSemester__c = 3;
         objSP.nm_Program__c = program.id;
         insert objSP;   
          
        objopp =new Opportunity();
        objopp.StageName = 'Payment Made'; 
        objopp.Close_lost__c = false;
        objopp.nm_Payment_Approved__c =true;
        objopp.CloseDate=System.today();
        objopp.nm_Semester__c='1';
        objopp.Name='Chandra_Singh_11DSCM_Sem_1_Jan_2015';
        objopp.Is_Re_Registration_Payment__c = false;
        objopp.nm_StudentProgram__c =objSP.id;
        objopp.AccountId=objAccount.id; 
        objopp.nm_Program__c=program.id;
        objopp.nm_Session__c='July';
        objopp.nm_Year__c=2020;

        objopp.Other_Courier_Service_Opportunity__c = false;
        insert objopp;
        
        objProduct=new Product2();
        
        objProduct.Name='dfdf';
        objProduct.nm_Program__c=program.Id;
        objProduct.nm_Semester__c='1';
        objProduct.isActive =true;
        insert objProduct; 
         
           
        objPriceBook = new PriceBook2();
        objPriceBook.IsActive =true;
        //objPriceBook.IsStandard =false;
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
        
        objPayment = new nm_Payment__c ();
        objPayment.nm_OpportunityNew__c =objopp.id;
        objPayment.nm_PaymentType__c ='Admission';
        objPayment.nm_Amount__c = 18000;
        objPayment.Receipt_Number__c='20000';
        objPayment.nm_PaymentStatus__c ='Payment Made';
        insert objPayment;
        
        
        ApexPages.currentPage().getParameters().put('id',objaccount.id);
        nm_ReRegistrationRecieptClass obj = new nm_ReRegistrationRecieptClass();
        nm_Payment__c  lstpymnt =obj.objPayment;
         
         
     
     }



}