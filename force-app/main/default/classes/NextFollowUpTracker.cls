/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-06-2022
 * @last modified by  : shubhranshu
**/
@isTest(SeeAllData=true)
public class NextFollowUpTracker
{
    public static Lead objLead;
    
    public static testMethod void UnitTest1()
    {     
         objLead = new Lead();
        objLead.nm_SelectedIC__c ='Mumbai';
        objLead.LastName ='amit kumar';
        objLead.FirstName='';
        objLead.nm_DateOfBirth__c = Date.newInstance(1990, 12, 9);
        objLead.status='Hot';
        objLead.Email='amit.kumar@saasfocus.com';
        objLead.MobilePhone ='8377985721';
        objLead.nm_ChooseaProgram__c ='Certificate Programs';
        objLead.nm_Year__c = 2014;
        objLead.LeadSource = 'Web';
        objLead.nm_PaymentStatus__c ='Registration form filled';
        objLead.nm_PlantoStart__c ='0-1 week';
        objLead.nm_Program__c = null;
        objLead.nm_CopyAddress__c = 'No';
        objLead.Shipping_Address_Choice__c = '';
        insert objLead;
        
         ApexPages.currentPage().getParameters().put('id',objLead.id);
         ApexPages.currentPage().getParameters().put('param','test');

         NextFollowUp Controller =new NextFollowUp();  
         Controller.saveFllowUpdate();
         Controller.getReasonForNotJoining();
         Controller.getStudentPlantoStart();
          Controller.getQueryAllFieldSql('Lead','id');
    }
}