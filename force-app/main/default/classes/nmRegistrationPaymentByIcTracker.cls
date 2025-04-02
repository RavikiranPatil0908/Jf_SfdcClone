@istest
public class nmRegistrationPaymentByIcTracker 
{  
   static nm_Payment__c objPayment;

   static Opportunity Objopp;

   static nm_EligiblityCriteria__c objEc2;
   static nm_Program__c objP ;
   static nm_Payment__c objpaymnt ;
    public static Lead objLead;
   public static nm_Configure_the_Pages__c configPages;
   public static nm_Holidays__c objHoliday;
   public static nm_UserMapping__c objMap;
   public static nm_Centers__c   objcenter;
   
   static testmethod void registrationlatefee()
    {
      Load();
      
      ApexPages.currentPage().getParameters().put('id',objLead.id);
      nmRegistrationPaymentByIc obj = new nmRegistrationPaymentByIc();
      
     // obj.PaymentTypeSelected='Admission';
      obj.decLatefees = 1.1;
      obj.isPaywithLatefees = false;
     // obj.decLatefees = 0.0;
     // obj.isPaywithLatefees = false;
      obj.PaymentTypeSelected='Registration';
      obj.PaymentTypeSelected='Registration';
      obj.objPayment.nm_DemandDraftNumber__c='342343';
      obj.objPayment.nm_DemandDraftDate__c=system.today();
      obj.objPayment.nm_NameoftheBank__c = 'Indian overseas bank';
      obj.objPayment.nm_BankLocation__c = 'Gr.Noida';
      obj.objPayment.nm_DispatchDate__c= system.today();
      String strProgramId = objLead.id;
      
      obj.getPaymentTypeSelected();
      obj.setPaymentTypeSelected('RRT12121'); 
      obj.getItems();
      obj.PaymentTypeSelected='Registration';
     
      obj.MakePayment();
      obj.PaymentTypeSelected='Admission';
      obj.decLatefees=44.55;
      obj.isPaywithLatefees=true;
      obj.MakePayment();
      obj.PaymentTypeSelected='Admission';
      obj.decLatefees=44.55;
      obj.isPaywithLatefees=false;
      obj.MakePayment();
    //  obj.MakeOnlinePayment();
      obj.Checklatefees();            
    }
    
   static void Load()
    {  
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

      /*  user usr = [Select id from user limit 1];
        
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
         */
                          objCenter = nmGenericTracker.CreateCenter('Mumbai - Mira Road East'); 

         
                objLead = new Lead();
                 objLead.Email='amit.kumasr@saasfocus.com';
                 objLead.MobilePhone='9898876789';
                 objLead.FirstName='sandy';
                 objLead.LastName='babar';
                 objLead.nm_BloodGroup__c='B+';
                 objLead.nm_Gender__c='male';
                // objLead.nm_FathersName__c='subhash';
                // objLead.nm_MothersName__c='kalpana';
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
                // objLead.OwnerId=usr.id;
                 insert objLead;

        
         objpaymnt = new nm_Payment__c (); 
         objpaymnt.nm_PaymentStatus__c='Payment Made';
         objpaymnt.nm_Amount__c=43343;  
         objpaymnt.nm_Lead__c=objLead.id;
         objpaymnt.nm_PaymentType__c = 'Registration';
         objpaymnt.nm_DemandDraftNumber__c = 'testing1';
         objpaymnt.nm_DemandDraftDate__c = system.today();
         objpaymnt.nm_NameoftheBank__c = 'Indian Overseas Bank';
         objpaymnt.nm_BankLocation__c = 'Noida';
         objpaymnt.nm_DispatchDate__c = system.today();
         insert objpaymnt ;
         
    }
}