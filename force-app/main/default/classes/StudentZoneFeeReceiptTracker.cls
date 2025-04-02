@isTest
public class StudentZoneFeeReceiptTracker
{
 public static nm_Payment__c objPayment;
 public static Opportunity objopp;
 public static Account objAccount;
 public static nmSerialNo__c objSerialNo;
  public static nm_Program__c program;
  
  static testmethod void test1()
  {
     LoadData();
      apexpages.currentpage().getparameters().put('StudentNo','1234');
      apexpages.currentpage().getparameters().put('Sem','1'); 
      // apexpages.currentpage().getparameters().put('Paymentid',objPayment.id); 
      StudentZoneFeeReceiptController ob =new StudentZoneFeeReceiptController();
  }
  
  static void LoadData()
  {
            objSerialNo=new nmSerialNo__c();
            
            objSerialNo.nm_MaxGenratedNo__c=123456;
            objSerialNo.nm_name__c='Fee Receipt Counter';
            insert objSerialNo;
            
            objSerialNo=new nmSerialNo__c();
            
            objSerialNo.nm_MaxGenratedNo__c=123456;
            objSerialNo.nm_name__c='Reference Number';
            insert objSerialNo;
            
             program = new nm_Program__c();
        program.nmIsActive__c = true;
        program.nm_ProgramCode__c = 'test';
        program.nm_ProgramDuration__c= 2.0;
        program.nm_ProgramName__c = 'Post grad diploma finance';
        program.nm_ProgramValidity__c = 4;
        program.nm_TotalSemesters__c = 4;
        program.nm_Type__c = 'Post Graduate Diploma Program';
        
        insert program;
        
        objAccount = new Account();
        objAccount.lastname ='kumar';
        objAccount.Salutation ='Mrs.';
        objAccount.nm_PreStudentNo__c ='77213';
        objAccount.nm_StudentStatus__c='Registered';
        objAccount.nm_SerialNo__c=2;
        objAccount.PersonMobilePhone ='1002030120';
        objAccount.PersonEmail = 'lav.singh@saasfocus.com'; 
        objAccount.nm_StudentNo__c = '1234';
        objAccount.nm_DateOfBirth__c = system.today();
        objAccount.nm_RegistrationNumber__c = '93434';
       
       insert objAccount;
  
      objopp= new Opportunity();
      objopp.AccountId=objAccount.id;
      objopp.Amount=1700;
      objopp.nm_ModeOfPayment__c='Online';
      objopp.nm_Year__c=2016;
      objopp.nm_Session__c='July';
      objopp.nm_Semester__c = '1';
      objopp.StageName='Closed Won';
      objopp.nm_Program__c = program.id;
      objopp.CloseDate=system.today()+10;
      objopp.Name='dhf';
      insert objopp;
      
      objPayment = new nm_Payment__c();
      
      objPayment.nm_PaymentStatus__c='Payment Approved';
      objPayment.nm_ModeOfPayment__c='Online';
      objPayment.nm_PaymentType__c='Admission';
      objPayment.nm_OpportunityNew__c=objopp.id;
      objPayment.nm_Amount__c =1000;
      insert objPayment;
  }
      
}