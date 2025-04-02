@isTest
private class nmExotelIncomingResponseTracker
{
     public static Lead objLead;
   public static nm_Configure_the_Pages__c configPages;
   public static nm_Holidays__c objHoliday;
   public static nm_UserMapping__c objMap;
   public static nm_Centers__c   objcenter;
    private static testmethod  void unitTest1()
    {
        Task T = new Task();
        T.Type = 'Email';
        T.Description = '';
        T.Exotel_Sid__c ='test';        
        insert T;
        apexPages.currentPage().getParameters().put('CallSid','test');
        apexPages.currentPage().getParameters().put('From','8377985721');
        apexPages.currentPage().getParameters().put('To','8377985721');
        apexPages.currentPage().getParameters().put('RecordingUrl','test');
        apexPages.currentPage().getParameters().put('CallType','test');
        nmExotelIncomingResponse obj = new nmExotelIncomingResponse();
        obj.UpdateStatusCallback();
    
    }

    private static testmethod  void unitTest2()
    {
        string strrecord = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1].id;
        Account Acc = new Account(
        RecordTypeID=strrecord,
        FirstName='jane',
        LastName='doe',
        nm_PreStudentNo__c ='77213',
        nm_StudentStatus__c='Confirmed',
        PersonEmail = 't@t.com',
        nm_SerialNo__c=2,PersonMobilePhone='9897766543') ; 
        insert Acc;      
       
        
        apexPages.currentPage().getParameters().put('CallSid','test1');
        apexPages.currentPage().getParameters().put('From','8377985721');
        apexPages.currentPage().getParameters().put('To','8377985721');
        apexPages.currentPage().getParameters().put('RecordingUrl','test');
        apexPages.currentPage().getParameters().put('CallType','test');
        nmExotelIncomingResponse obj = new nmExotelIncomingResponse();
        obj.UpdateStatusCallback();
    
    }
    
   /*  private static testmethod  void unitTest3()
     {
         nm_Program__c  objProgram = new nm_Program__c ();
        objProgram.nm_ProgramCode__c='001';
        objProgram.nm_ProgramDuration__c=3;
        objProgram.nm_Type__c = 'Post Graduate Diploma Programs';
     
        objProgram.nm_ProgramValidity__c=3;     
        objProgram.nm_TotalSemesters__c=4;        
        insert objProgram;
        Lead objLead = new Lead();
        objLead.nm_SelectedIC__c ='1';
        objLead.LastName ='kumar';
        objLead.FirstName='amit';
        objLead.nm_DateOfBirth__c =System.today();
        objLead.status='Hot';
        objLead.Email='amit.kumar@saasfocus.com';
        objLead.nm_PlantoStart__c ='2-4 Months';
        objLead.nm_EscallationDone__c = 3;
        objLead.nm_ChooseaProgram__c ='Post Graduate Diploma Programs';
         objLead.nm_SelectedProgram__c='Post Graduate Diploma Programs';
        CommonTrackerClass.createLead(objLead); 
        apexPages.currentPage().getParameters().put('CallSid','test1');
        apexPages.currentPage().getParameters().put('From','8377985721');
        apexPages.currentPage().getParameters().put('To','8377985721');
        apexPages.currentPage().getParameters().put('RecordingUrl','test');
        apexPages.currentPage().getParameters().put('CallType','test');
        nmExotelIncomingResponse obj = new nmExotelIncomingResponse();
        obj.UpdateStatusCallback();
    
     }*/
    private static testmethod  void unitTest4()
     {
        LoadData();
        apexPages.currentPage().getParameters().put('CallSid','test1');
        apexPages.currentPage().getParameters().put('From','8377985711');
        apexPages.currentPage().getParameters().put('To','8377985721');
        apexPages.currentPage().getParameters().put('RecordingUrl','test');
        apexPages.currentPage().getParameters().put('CallType','test');
        nmExotelIncomingResponse obj = new nmExotelIncomingResponse();
        obj.UpdateStatusCallback();
    
     }
    
     static void LoadData()
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

    /*    user usr = [Select id from user limit 1];
        
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
                 objLead.MobilePhone='8789987678';
                 objLead.FirstName='sandy';
                 objLead.LastName='babar';
                 objLead.nm_BloodGroup__c='B+';
                 objLead.nm_Gender__c='male';
                // objLead.nm_FathersName__c='subhash';
                 //objLead.nm_MothersName__c='kalpana';
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
                 //objLead.OwnerId=usr.id;
                 insert objLead;
    }
    

}