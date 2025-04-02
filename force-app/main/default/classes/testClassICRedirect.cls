@isTest

public class testClassICRedirect
{
    static testMethod void testMethodICRedirect()
    {
            nm_Centers__c c = nmGenericTracker.CreateCenter('Mumbai');
            c.Name ='Hyderabad - Banjara Hills';
        	c.nm_StateProvince__c ='AP';
        	c.nm_City__c='Hydrabad';
       		c.nm_LearningCenter__c=c.id;
        	c.Nm_Active__c=true;
            IC_Payment__c payment = new IC_Payment__c();
        	//payment.Centers__c='a02O000000DHXLu';
	        payment.Centers__c = c.id;
            payment.Payment_Month__c = '8';
            payment.Payment_Year__c = '2014';
            payment.Amount__c = 5000;
            payment.Payment_Due_Date__c = System.today();
			c.IC_Company_Name__c =c.IC_Company_Name__c;           
            insert payment;
            
            nmICRedirectExtension extension = new nmICRedirectExtension(new ApexPages.StandardController(payment));
            
             extension.icRedirect();
    }

}