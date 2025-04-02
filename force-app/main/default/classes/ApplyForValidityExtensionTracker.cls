@istest(SeeAllData=true)
public class ApplyForValidityExtensionTracker
 {
    public static nm_StudentProgram__c objsp;
    public static Account objAccount;
    public static nm_Payment__c objPayment2;
    public static Validity_Extension__c objValEx;
    public static nm_Program__c objProgram;
  
    //public static Opportunity objopp;
    
    static testmethod void unitTest1()
        {
            LoadData();
            Test.StartTest();
            ApexPages.currentPage().getParameters().put('studentNo','771124684458484');
            ApexPages.currentPage().getParameters().put('dob','10/08/2015');
             PageReference pg = new PageReference('/apex/ApplyForValidityExtension');
            Test.setCurrentPage(pg);
            ApplyForValidityExtensionController obj = new ApplyForValidityExtensionController();
            HelperClassForValidityExtension objHelperValEx=new HelperClassForValidityExtension();
            obj.objAccount.nm_StudentNo__c = '771124684458484';
            obj.objAccount.nm_DateOfBirth__c = System.today();
            obj.RedirectToValidityPage();
            Test.StopTest();
            
        }
        
         static testmethod void unitTest2()
        {
            LoadData();
            objAccount.Extended_Validity_For_This_Session__c =true;
            update objAccount;
            Test.StartTest();
            PageReference pg = new PageReference('/apex/ApplyForValidityExtension');
            Test.setCurrentPage(pg);
            ApplyForValidityExtensionController obj = new ApplyForValidityExtensionController();
            HelperClassForValidityExtension objHelperValEx=new HelperClassForValidityExtension();
            obj.objAccount.nm_StudentNo__c = '771124684458484';
            obj.objAccount.nm_DateOfBirth__c = System.today();
            obj.RedirectToValidityPage();
            obj.ShowMessageBlock('Do you wish to extend your Validity by 6 months ?','EXTEND VALIDITY','urlToRedirect');
            Test.StopTest();
            
        }
        
           static testmethod void unitTest3()
        {
            LoadData();
            objAccount.Validity_Extension_Count__c=2;
            update objAccount;
            Test.StartTest();
            PageReference pg = new PageReference('/apex/ApplyForValidityExtension');
            Test.setCurrentPage(pg);
            ApplyForValidityExtensionController obj = new ApplyForValidityExtensionController();
            HelperClassForValidityExtension objHelperValEx=new HelperClassForValidityExtension();
            obj.objAccount.nm_StudentNo__c = '771124684458484';
            obj.objAccount.nm_DateOfBirth__c = System.today();
            obj.RedirectToValidityPage();
            Test.StopTest();
            
        }
        
         static testmethod void unitTest4()
        {
            LoadData();
            Test.StartTest();
            ApexPages.currentPage().getParameters().put('studentNo','');
            ApexPages.currentPage().getParameters().put('dob','');
             PageReference pg = new PageReference('/apex/ApplyForValidityExtension');
            Test.setCurrentPage(pg);
            ApplyForValidityExtensionController obj = new ApplyForValidityExtensionController();
            HelperClassForValidityExtension objHelperValEx=new HelperClassForValidityExtension();
            obj.objAccount.nm_StudentNo__c = '';
            obj.objAccount.nm_DateOfBirth__c = null;
            obj.RedirectToValidityPage();
            Test.StopTest();
            
        }
        static void LoadData()
         {
         
             objAccount= new Account();
             objAccount.lastname ='kumar';
             objAccount.nm_StudentNo__c='771124684458484';
             objAccount.nm_PreStudentNo__c ='77112';
             objAccount.nm_StudentStatus__c='Confirmed';
             objAccount.PersonMobilePhone='837700000985721';
             objAccount.nm_DateOfBirth__c= System.today();
             objAccount.PersonEmail='chandra@gma11il.com';
             objAccount.Validity_Extension_Count__c = 0;
             objAccount.nm_SerialNo__c=2;
             objAccount.Extend_Validity_upto_Month__c='June';
             objAccount.nm_Category__c='General';
             objAccount.Extend_Validity_Upto_Year__c=2016;
             objAccount.Extended_Validity_For_This_Session__c=false;
             objAccount.Validity_Extension_Count__c=0;
             objAccount.nmStudent_Program__c='Post Graduate Diploma in Business Management';
             objAccount.ValidUptoR__c='Jun 2020';
             //objAccount.nm_Centers__c=objCen.id;
             //objAccount.nm_Tagged_Pricebook__c = string.valueOf(objPricebook.id);
             //objAccount.nm_EligiblityCriteria__c =objEc.id;
             insert objAccount;
            
           // objopp = new Opportunity();
            //objopp = CommonTrackerClass.createOpportunity(objopp);

            objValEx = new Validity_Extension__c();
            objValEx.Batch_Name__c='JUL2015';
            objValEx.Expiry_Date_Of_Program__c='2020';
            objValEx.Mobile_Number__c='242343254326534';
            objValEx.Name_Of_Account__c='Fagu Babu';
            objValEx.Student_Number_Of_Account__c='77115000170';
            objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
            objValEx.Related_Account__c=objAccount.id;
            insert objValEx;
            
            objPayment2 = new nm_Payment__c();
            nm_Payment__c objPaymnt2 = new nm_Payment__c(); 
            objPaymnt2.nm_PaymentType__c='Admission';
            objPaymnt2.nm_ModeOfPayment__c='Demand Draft';
            objPaymnt2.nm_DemandDraftNumber__c='234234';
            objPayment2.nm_Amount__c=17000;
            //objPaymnt2.nm_DemandDraftDate__c=system.today();
            //objPaymnt2.nm_NameoftheBank__c='SBI';
            objPaymnt2.nm_ModeOfPayment__c ='Demand Draft';
            objPaymnt2.nm_PaymentStatus__c='Payment Made';
           // objPaymnt2.nm_OpportunityNew__c =objopp.id;
            objPaymnt2.nm_BankLocation__c='noida';
            objPayment2.Validity_Extension__c=objValEx.id;
            objPaymnt2.nm_DispatchDate__c=system.today();
           // objPayment2.Receipt_Number__c='5265';
            insert objPaymnt2;
            
            objProgram=new nm_Program__c ();
            objProgram.nm_ProgramName__c='  Post Graduate Diploma in Banking and Finance Management';
            objProgram.nm_TotalSemesters__c=4;
            objProgram.nm_Type__c='Post Graduate Diploma Programs';
            insert objProgram;
            
            
            objsp=new nm_StudentProgram__c ();
            objsp.nm_Student__c=objAccount.id;
            objsp.nm_Program__c=objProgram.id;
            objsp.nm_FeesPaidofSemester__c=4;
            insert objsp;
         }
 }