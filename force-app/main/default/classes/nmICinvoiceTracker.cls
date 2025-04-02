@isTest
public class nmICinvoiceTracker 
{
    public static IC_Payment__c objICPayment;
    public static nm_Centers__c objCen;
    
    static testMethod void testMethod1()
    {
      Profile p = [SELECT Id FROM Profile where name='System Administrator']; 
       User u = new User(Alias = 'standtss', Email='standarduser1231@testorg.com', 
       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id,IsActive = true, 
       TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1232@testorg.com');
       
       Profile p1 = [SELECT Id FROM Profile where name='Information Center']; 
       User u1 = new User(Alias = 'standtss', Email='standardur1231@testorg.com', 
       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p1.Id,IsActive = true, 
       TimeZoneSidKey='America/Los_Angeles', UserName='standauser1232@testorg.com');
         insert u;
        System.runAs(u)
        {
            nm_Centers__c c = nmGenericTracker.CreateCenter('Mumbai');
            
            IC_Payment__c payment = new IC_Payment__c();
            payment.Centers__c = c.id;
            payment.Payment_Month__c = 'August';
            payment.Payment_Year__c = '2014';
            payment.Amount__c = 5000;
            payment.Payment_Due_Date__c = System.today();
            
            insert payment;
        }
       
        nmICinvoice obj = new nmICinvoice();
        obj.populateIcDetails();
        obj.redirect();
        obj.getICpayment();
        obj.getInfoCenterRelatedToLC();
        obj.getGrossAmount();
        obj.SelectedProgram = 'POST GRADUATION AND DIPLOMA PROGRAM';
        obj.getGrossAmount();
        obj.SelectedProgram ='CERTIFICATE PROGRAM';
        obj.getServiceAmount();
        obj.getSwachhBharat();
        obj.getKrishiKalyan();
        obj.getTotalAfterTax();
        obj.getChooseProgram();
        
    }
}