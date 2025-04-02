@isTest(SeeAllData=true)
public class nmRegistrationThankYouTracker
{
    private static nm_Payment__c objPaymnt2;
    
    static testMethod void UnitTest()
    {

        loadData();
        List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
        lstPayment.add(objPaymnt2);
        Apexpages.currentPage().getParameters().put('PaymentId',objPaymnt2.id);
        nmRegistrationThankYou obj= new nmRegistrationThankYou();
     
    }
    static void loadData()
    {
         objPaymnt2 = new nm_Payment__c(); 
         objPaymnt2.nm_PaymentType__c='Tshirt';
         objPaymnt2.nm_ModeOfPayment__c='Demand Draft';
         objPaymnt2.nm_DemandDraftNumber__c='234234';
         objPaymnt2.nm_PaymentStatus__c='Payment Made';
         objPaymnt2.nm_NameoftheBank__c='SBI';
         objPaymnt2.nm_Amount__c= 17000;
         objPaymnt2.nm_ModeOfPayment__c ='Demand Draft';
         objPaymnt2.nm_BankLocation__c='noida';
         objPaymnt2.nm_DispatchDate__c=system.today();
         insert objPaymnt2; 
   }
  
 }