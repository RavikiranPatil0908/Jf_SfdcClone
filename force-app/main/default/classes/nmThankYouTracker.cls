/**
 * @File Name          : nmThankYouTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 16/7/2019, 12:37:36 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    16/7/2019, 12:25:18 PM   @BK     Initial Version
**/
@isTest(SeeAllData=true)
public class nmThankYouTracker
{
    private static nm_Payment__c objPaymnt1;
    private static nm_Payment__c objPaymnt2;
    
    static testMethod void UnitTest()
    {

        loadData();
        List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
        lstPayment.add(objPaymnt2);
        Apexpages.currentPage().getParameters().put('PaymentId',objPaymnt2.id);
        nmThankYou obj= new nmThankYou();
     
    }

    static testMethod void UnitTest2()
    {

        loadData();
        List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
        lstPayment.add(objPaymnt1);
        Apexpages.currentPage().getParameters().put('PaymentId',objPaymnt1.id);
        nmThankYou obj= new nmThankYou();
     
    }
    
    static void loadData()
    {
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_Centers__c objCen = nmGenericTracker.CreateCenter('upGrad');
        objLead.nm_InformationCenter__c	= objCen.id;
        update objLead;

        objPaymnt1 = new nm_Payment__c(); 
         objPaymnt1.nm_PaymentType__c='Registration';
         objPaymnt1.nm_ModeOfPayment__c='Online';
         objPaymnt1.nm_Information_Center__c='upGrad';
         objPaymnt1.nm_PaymentStatus__c='Payment Made';
         objPaymnt1.nm_Amount__c= 17000;
         objPaymnt1.nm_DispatchDate__c=system.today();
         objPaymnt1.nm_Lead__c = objLead.id;
         insert objPaymnt1; 

         objPaymnt2 = new nm_Payment__c(); 
         objPaymnt2.nm_PaymentType__c='Admission';
         objPaymnt2.nm_ModeOfPayment__c='Online';
         objPaymnt2.nm_Information_Center__c='upGrad';
         objPaymnt2.nm_PaymentStatus__c='Payment Made';
         objPaymnt2.nm_Amount__c= 17000;
         objPaymnt2.nm_DispatchDate__c=system.today();
         objPaymnt2.nm_Lead__c = objLead.id;
         insert objPaymnt2; 
   }
  
 }