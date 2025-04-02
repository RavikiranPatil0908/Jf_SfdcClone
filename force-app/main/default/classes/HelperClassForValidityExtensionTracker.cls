@isTest(SeeAllData=true)
public class HelperClassForValidityExtensionTracker
{
    public static Account objAccount;
    public static nm_StudentProgram__c studentProgram;
    public static nm_Program__c objProgram;
    public static Calender__c calender;
    public static Validity_Extension__c objValEx;
    public static nm_Payment__c objPayment2;
    
    static testMethod void test1()
    {
         loadData();
          map<String,integer> mapOfMonthAndNumber = new map<String,integer>();
          List<String> monthList = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
            for(integer i=0;i<monthList.size();i++)
            {
                integer s = i;
                mapOfMonthAndNumber.put(monthList[i],s+1);
                s++;
            }  
        HelperClassForValidityExtension helper = new HelperClassForValidityExtension();
       helper.ValidateRecord(objAccount.nm_StudentNo__c,objAccount.nm_DateOfBirth__c,mapOfMonthAndNumber);
        
      
    }
    
   static void loadData()
    {
         
             objAccount= new Account();
             objAccount.lastname ='kumar';
             objAccount.nm_StudentNo__c='771120002188';
             objAccount.nm_PreStudentNo__c ='77112';
             objAccount.nm_StudentStatus__c='Confirmed';
             objAccount.PersonMobilePhone='837700000985721';
             objAccount.nm_DateOfBirth__c= System.today();
             objAccount.PersonEmail='chandra@gma11il.com';
             objAccount.Validity_Extension_Count__c = 0;
             objAccount.nm_SerialNo__c=2;
             objAccount.nmStudent_Program__c='Diploma in General Management';
             objAccount.Extend_Validity_upto_Month__c='June';
             objAccount.nm_Category__c='General';
             objAccount.ValidUptoR__c='Jun 2020';
             objAccount.Extend_Validity_Upto_Year__c=2;
             objAccount.Extended_Validity_For_This_Session__c=true;
             objAccount.Validity_Extension_Count__c=1;
         
            insert objAccount;
            
            objProgram=new nm_Program__c ();
            objProgram.nm_ProgramName__c='Post Graduate Diploma in Banking and Finance Management';
            objProgram.nm_TotalSemesters__c=4;
            objProgram.nm_Type__c='Post Graduate Diploma Programs';
            insert objProgram;
            
            objValEx = new Validity_Extension__c();
            objValEx.Batch_Name__c='JUL2015';
            objValEx.Expiry_Date_Of_Program__c='2020';
            objValEx.Mobile_Number__c='242343254326534';
            objValEx.Name_Of_Account__c='Fagu Babu';
            objValEx.Student_Number_Of_Account__c='77114000213';
            objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
            objValEx.Related_Account__c = objAccount.id;
            insert objValEx;
            
            objPayment2 = new nm_Payment__c();
            objPayment2.nm_PaymentType__c='Admission';
            objPayment2.nm_ModeOfPayment__c='Demand Draft';
            objPayment2.nm_DemandDraftNumber__c='234234';
            objPayment2.nm_Amount__c=17000;
            objPayment2.nm_ModeOfPayment__c ='Demand Draft';
            objPayment2.nm_PaymentStatus__c='Payment Made';
            objPayment2.nm_BankLocation__c='noida';
            objPayment2.Validity_Extension__c = objValEx.id;
            objPayment2.nm_DispatchDate__c=system.today();
            insert objPayment2;
            
            studentProgram=new nm_StudentProgram__c ();
            studentProgram.nm_Student__c=objAccount.id;
            studentProgram.nm_Program__c=objProgram.id;
            studentProgram.nm_FeesPaidofSemester__c=4;
            insert studentProgram;
    } 
    
}