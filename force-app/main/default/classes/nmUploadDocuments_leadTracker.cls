/*
 */
@isTest
private class nmUploadDocuments_leadTracker {
     static private nm_Holidays__c objHoliday;
     static private nm_Holidays__c objHoliday1;     private static nm_Centers__c   objcenter;
     private static nm_Centers__c   objcenter1;
     private static nm_Centers__c   objcenter2;
     private static nm_UserMapping__c objMap;
       private static nm_UserMapping__c obuse;
     private static nm_Program__c  objP ;
 static private nm_EligiblityCriteria__c objEc;

    static testMethod void myUnitTest() 
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
          
          /*Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
     
         objcenter = new nm_Centers__c();
         
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='002';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;*/
        nm_Centers__c objcenter = nmGenericTracker.CreateCenter('Delhi'); 

     
     /*   Recordtype rt1=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        objcenter1 = new  nm_Centers__c(); 
        objcenter1.nm_LearningCenter__c =  objcenter .id;    
        objcenter1.Name = 'Halo Knowledge Foudation, Thane (W)'   ;  
        objcenter1.RecordTypeID =rt1.id;           
        objCenter1.nm_CenterCode__c ='002';
        objCenter1.nm_CenterCity__c='Delhi';
        objCenter1.nm_City__c='Delhi';
        objCenter1.nm_StateProvince__c='Delhi';
        objCenter1.nm_Street__c='Laxmi Ngar';
        objCenter1.nm_PostalCode__c='110091';         
        insert objCenter1;*/
        
        nm_Centers__c objCenter1 = nmGenericTracker.CreateCenter('Delhi'); 
     
       /* objcenter2 = new  nm_Centers__c(); 
        objcenter2.nm_LearningCenter__c =  objcenter .id;         
        objcenter2.RecordTypeID =rt1.id;           
        objCenter2.nm_CenterCode__c ='002';
        objCenter2.nm_CenterCity__c='Delhi';
        objCenter2.nm_City__c='Delhi';
        objCenter2.nm_StateProvince__c='Delhi';
        objCenter2.nm_Street__c='Laxmi Ngar';
        objCenter2.nm_PostalCode__c='110091';         
        insert objCenter2;*/
        
        nm_Centers__c objCenter2 = nmGenericTracker.CreateCenter('Delhi'); 
        
      objP= new nm_Program__c ();
        objP.nm_ProgramCode__c='TestCode';
        objP.nm_ProgramDuration__c=3;
        objP.nm_Type__c='Certificate Programs';
        if( objP.nm_ProgramName__c == null)
        {
            objP.nm_ProgramName__c='PGDBM';
            objP.Name='PGDBM';
        }
        objP.nm_ProgramValidity__c=3;     
        objP.nm_TotalSemesters__c=4;   
        objP.nmIsActive__c = true ;   
        insert objP;
        
     
         profile objprofile =[select id from profile where name ='information Center' limit 1];
         user usr = [Select id from user limit 1];
         //User usr =CommonTrackerClass.createUser(objuser,String.valueOf(objprofile.id));
         objMap = new nm_UserMapping__c();
         objMap.nm_User__c =usr.id;
         objMap.nm_Centers__c =objCenter2.id;
         CommonTrackerClass.createCenterUsers(objMap);
         nm_ICProgram__c objIC;
         CommonTrackerClass.createICProgram(objIC);
         objP = new nm_Program__c  () ;
         CommonTrackerClass.createProgram(objP);
         system.debug('**Program'+objP);
         
 
    
         objEc = new nm_EligiblityCriteria__c ();
         objEc.Name='NameEligibility Criteria';
         objEc.nm_Documnetslist__c ='10th Marksheet';
         objEc.nm_EligiblityCriteria__c ='test';
         objEc.nm_Program__c = 'Post Graduate Diploma Programs';
         objEc.Is_Active__c=true;
         insert objEc;
         system.debug('**eligibility criteria'+objEc);
    


      Lead  objLead = new Lead();
      
              
       // objLead= CommonTrackerClass.createLead(objLead); 
                 objLead.nm_SelectedIC__c ='1';
         
         objLead.LastName ='kumar tes test';
         objLead.FirstName='amit test test';
        // objLead.nm_MiddleName__c='test';
         objLead.nm_DateOfBirth__c =Date.newInstance(1990, 12, 9);
         objLead.status='Reborn';
         objLead.Email='amit.kumar@saasfocus.com';
         objLead.MobilePhone ='8377985721';
         objLead.nm_ChooseaProgram__c ='Post Graduate Diploma Programs';
        // objLead.nm_Program__c = objP.Id;
        objLead.nm_EligiblityCriteria__c = objEc.Id;
         objLead.nm_PaymentCompleted__c = false;
         objLead.nm_SelectedProgram__c ='PGDBM';
         objLead.nm_InformationCenter__c =objCenter1.id;
         objLead.nm_Year__c =2014;
         objLead.LeadSource ='Web';
         objLead.nm_PaymentStatus__c ='Registration form filled';
         objLead.nm_PlantoStart__c ='2-4 Months';
         objLead.nm_Session__c='July';
         objLead.nm_CopyAddress__c='Yes';
         objLead.nm_ModeOfPayment__c='Online';
         objLead.nm_EscallationDone__c=0;
         objLead.nm_RegistrationID__c='';
         objLead.IsConverted=false;
         objLead.AllowedToUploadDocument__c = true;
        // objLead.nm_Rating__c =3;
         objLead.nm_SelectedProgram__c='Post Graduate Diploma in Business Management';
         objLead.nm_SelectedIC__c='Halo Knowledge Foudation, Thane (W)';
         insert objLead;
        // lstlead1.add(objLead);
         system.debug('**Lead'+objLead);
       
        Apexpages.currentPage().getParameters().put('id',objLead.id);
        nmUploadDocuments_lead  obj = new nmUploadDocuments_lead ();

        Apexpages.currentPage().getParameters().put('mode','Upload Self-Attested Now');
        nmUploadDocuments_lead  obj2 = new nmUploadDocuments_lead ();
    }
}