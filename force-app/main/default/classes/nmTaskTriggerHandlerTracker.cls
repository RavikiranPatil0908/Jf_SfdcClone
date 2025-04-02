/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-06-2022
 * @last modified by  : shubhranshu
**/
@istest(SeeAllData=true)
public class nmTaskTriggerHandlerTracker {
    
        
     static testMethod void TestMethod1() 
     {
           Profile p = [SELECT Id FROM Profile where name='Information Center']; 
           User u = new User(Alias = 'st', Email='standarduser12434@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='Testingrer', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, 
           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123434@testorg.com');
           insert u;
           Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center']; 
         nm_Centers__c objCenter = new nm_Centers__c();
             
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
           
         Lead objLead = new Lead();
         objLead.nm_SelectedIC__c ='1';
         objLead.LastName ='kumar tes test';
         objLead.FirstName='amit test test';
       //  objLead.nm_MiddleName__c='test';
         objLead.nm_DateOfBirth__c =Date.newInstance(1990, 12, 9);
         objLead.status='Hot';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.nm_ChooseaProgram__c ='Certificate Programs';
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_SelectedProgram__c ='MCA';
         objLead.nm_InformationCenter__c =objCenter.id;
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Web';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=10;
         objLead.nm_RegistrationID__c='';
         //objLead.nm_RegistrationNo__c='a0BN0000001FUdB';
         objLead.ownerid=u.id;
         insert objLead;
         system.debug('**Lead'+objLead);
    Task objtas=new Task();
    objtas.ActivityDate = Date.today().addDays(7);
    objtas.Subject='Sample Task';
    objtas.WhoId = objLead.id;
    objtas.OwnerId = u.id;
    objtas.Status='In Progress';
     insert objtas;
     list<task> lstta=new list<task>();
     lstta.add(objtas);
  nmTaskTriggerHandler obj=new nmTaskTriggerHandler();
  //obj.DisableReminder(lstta);
}
}