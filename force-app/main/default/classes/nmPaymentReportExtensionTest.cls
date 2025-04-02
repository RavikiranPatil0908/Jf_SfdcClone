@isTest
public class nmPaymentReportExtensionTest{

    static testmethod void Test() {

       Profile p = [SELECT Id FROM Profile where name='System Administrator']; 
       User u = new User(Alias = 'standtss', Email='standarduser1231@testorg.com', 
       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id,IsActive = true, 
       TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1232@testorg.com');
       
      
        insert u;
        System.runAs(u)
        {
            nm_Centers__c c = nmGenericTracker.CreateCenter('Mumbai');
            
            IC_Payment__c payment = new IC_Payment__c();
            payment.Centers__c = c.id;
            payment.Payment_Month__c = '8';
            payment.Payment_Year__c = '2014';
            payment.Amount__c = 5000;
            payment.Payment_Due_Date__c = System.today();
            
            insert payment;
            
            nmPaymentReportExtension extension = new nmPaymentReportExtension(new ApexPages.StandardController(payment));
            extension.selectedFilter='None';
            extension.findReport();
            extension.getavailFilters();
            extension.getreportResultList();
            extension.gettotalAmount();
            extension.getDebitAmount();
            extension.getAdmissionCancel();
            extension.getCreditafter31();
            extension.getCreditbefore31();
            extension.getGrossAmount();
            extension.getServiceAmount();
            extension.getSwachhBharat();
            extension.getKrishiKalyan();
            extension.getTotalAfterTax();
            extension.getTDSAmount();
            extension.getNetAmount();           
            extension.generatePDF();
            extension.reportFlagFalse();
        }
    }
    
      static testmethod void TestTwo() {
        User u = [select id from User where Profile.Name='System Administrator' and IsActive = true LIMIT 1];
        
        System.runAs(u)
        {
            nm_Centers__c c = nmGenericTracker.CreateCenter('Mumbai');
            
            IC_Payment__c payment = new IC_Payment__c();
            payment.Centers__c = c.id;
            payment.Payment_Month__c = '8';
            payment.Payment_Year__c = '2014';
            payment.Amount__c = 5000;
            payment.Payment_Due_Date__c = System.today();
            
            insert payment;
            
            nmPaymentReportExtension extension = new nmPaymentReportExtension(new ApexPages.StandardController(payment));
            extension.selectedFilter='DATE RANGE';
            extension.findReport();
            extension.getavailFilters();
            extension.getreportResultList();
            extension.gettotalAmount();
            extension.getDebitAmount();
            extension.getAdmissionCancel();
            extension.getCreditafter31();
            extension.getCreditbefore31();
            extension.getGrossAmount();
            extension.getServiceAmount();
            extension.getSwachhBharat();
            extension.getKrishiKalyan();
            extension.getTotalAfterTax();
            extension.getTDSAmount();
            extension.getNetAmount();
            extension.generatePDF();
            extension.reportFlagFalse();
        }
    }
    
      static testmethod void TestThree() {
        User u = [select id from User where Profile.Name='System Administrator' and IsActive = true LIMIT 1];
        
        System.runAs(u)
        {
            nm_Centers__c c = nmGenericTracker.CreateCenter('Mumbai');
            
            IC_Payment__c payment = new IC_Payment__c();
            payment.Centers__c = c.id;
            payment.Payment_Month__c = '8';
            payment.Payment_Year__c = '2014';
            payment.Amount__c = 5000;
            payment.Payment_Due_Date__c = System.today();
            
            insert payment;
            
            nmPaymentReportExtension extension = new nmPaymentReportExtension(new ApexPages.StandardController(payment));
            extension.selectedFilter='MMYYYY';
            extension.findReport();
            extension.getavailFilters();
            extension.getreportResultList();
            extension.gettotalAmount();
            extension.getDebitAmount();
            extension.getAdmissionCancel();
            extension.getCreditafter31();
            extension.getCreditbefore31();
            extension.getGrossAmount();
            extension.getServiceAmount();
            extension.getSwachhBharat();
            extension.getKrishiKalyan();
            extension.getTotalAfterTax();
            extension.getTDSAmount();
            extension.getNetAmount();
            extension.generatePDF();
            extension.reportFlagFalse();
        }
    }
}