@isTest(SeeAllData=true)
public class nmPaymentDocUploadTracker
{
    public static nm_Payment__c objPayment; 
 
 static testMethod void UnitTest()
  { 
      objPayment = new nm_Payment__c ();
      objPayment.nm_Amount__c = 4272;
      objPayment.nm_PaymentStatus__c ='Payment Made';
      objPayment.nm_PaymentType__c ='Admission';
      insert objPayment; 
    
    nmPaymentDocUpload paydoc= new nmPaymentDocUpload();
    
  }
}