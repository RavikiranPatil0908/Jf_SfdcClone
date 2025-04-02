/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 04-16-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-26-2021   shubhranshu   Initial Version
**/
@isTest
private class nmAdmissionPaymentRecieptTracker
{
    public static Lead objLead;
    public static  nm_Payment__c objPayment;
    public static  nm_Payment__c objPayment2;
    private static testmethod void unit1()
    {  
        LoadData(); 
        ApexPages.currentPage().getParameters().put('PaymentId',objPayment.id);
        nmAdmissionPaymentReciept obj = new nmAdmissionPaymentReciept();
    
    }

    private static testmethod void usnit2() {
        LoadData(); 
        ApexPages.currentPage().getParameters().put('PaymentId',objPayment2.id);
        nmAdmissionPaymentReciept obj = new nmAdmissionPaymentReciept();
    }
    
    
    public static void LoadData()
    {
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objPayment = nmGenericTracker.CreatePaymentRecordForLead(objLead,'Late Fee');
        objPayment2 = nmGenericTracker.CreatePaymentRecordForLead(objLead,'Installment');
        /*
       nm_EscalationMatrix__c objCustomSeetings3 = new nm_EscalationMatrix__c();
        
        objCustomSeetings3.name='0-1 Week';
        objCustomSeetings3.nm_LCEscalationTime__c='22:45';
        objCustomSeetings3.nm_RemidertoIC__c='22:45';
        objCustomSeetings3.nm_HOEscalationTime__c='20:56';
        objCustomSeetings3.nm_RemidertoHO__c='22:45';
        
        insert objCustomSeetings3;
        
        nm_EscalationMatrix__c objCustomSeetings = new nm_EscalationMatrix__c();
        
        objCustomSeetings.name='2-4 Months';
        objCustomSeetings.nm_LCEscalationTime__c='20:45';
        objCustomSeetings.nm_RemidertoIC__c='21:45';
        objCustomSeetings.nm_HOEscalationTime__c='20:56';
        objCustomSeetings.nm_RemidertoHO__c='21:45';
        
        insert objCustomSeetings; 
        
        nm_EscalationMatrix__c objCustomSeetings2 = new nm_EscalationMatrix__c();
        objCustomSeetings2.name='3-6 Week';
        objCustomSeetings2.nm_LCEscalationTime__c='20:34';
        objCustomSeetings2.nm_RemidertoIC__c='21:45';
        objCustomSeetings2.nm_HOEscalationTime__c='20:56';
        objCustomSeetings2.nm_RemidertoHO__c='21:45';
        insert objCustomSeetings2; 
        
        objHoliday=new nm_Holidays__c();
        objHoliday.Name='Holi';
        objHoliday.nm_Date__c=system.today();
        insert objHoliday;
        
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        insert objSystemConfiguration;

        user usr = [Select id from user limit 1];
        
           objMap = new nm_UserMapping__c();
         objMap.nm_User__c =usr.id;
         
         
        Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
     
         objcenter = new nm_Centers__c();
         
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
         
         objLead = new Lead();
         objLead.Email='amit.kumasr@saasfocus.com';
         objLead.MobilePhone='8377985007';
         objLead.FirstName='sandy';
         objLead.LastName='babar';
         objLead.nm_BloodGroup__c='B+';
         objLead.nm_Gender__c='male';
         objLead.nm_FathersName__c='subhash';
         objLead.nm_MothersName__c='kalpana';
         objLead.nm_StateProvince_P__c='maharashtra';
         objLead.nm_Nationality__c='Indian';
         objLead.nm_Street_P__c='xyz';
         objLead.nm_LocalityName__c='mohitep';
         objLead.nm_SelfLearningMaterial__c='Send to my shipping address';
         objLead.nm_StudentStatus__c='Confirmed'; 
         objLead.nm_NameofBoard__c='CBSE';
         objLead.nm_10thPercentage__c=77.00;
         objLead.nm_NameofBoard__c='ICSC';
         objLead.nm_YearofCompletion__c='2000';
         objLead.nm_NameofSchool__c='nutan';
         objLead.nm_Class12OrDiploma__c='HSC';
         objLead.nm_NameofBoard12__c='LCSC';
         objLead.nm_YearofCompletion12__c='2002';
         objlead.nm_InformationCenter__c =objCenter.id; 
         objLead.nm_NameofSchool12__c='dfg';
         objLead.nm_Stream__c='adw';
         objLead.nm_BachelorsDegreeName__c='Bachelor of Applied Sciences';
         objLead.nm_Specialization__c='gf';
         objLead.nm_NameofUniversity__c='G K university';
         objLead.nm_BachelorsDegreePercentage__c=55.00;
         objLead.nm_GraduationDegreeMode__c='fgc';
         objLead.nm_YearofCollegeCompletion__c='2006';
         objLead.LeadSource='Web';
         objLead.OwnerId=usr.id;
         insert objLead;
         */
    }

}