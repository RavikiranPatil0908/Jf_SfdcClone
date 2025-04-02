@isTest
private class unsubscribeTest {
    // The following test methods provide adequate code coverage 
    // for the unsubscribe email class.
    // There are two methods, one that does the testing
    // with a valid "unsubcribe" in the subject line
    // and one the does not contain "unsubscribe" in the
    // subject line. 
    private static Lead objLead;
     private static Account objaccount;
     private static nm_Centers__c objcenter;
     private static nm_Centers__c objcenter1;
     private static nm_Centers__c objcenter2;
     private static nm_UserMapping__c objMap;
     private static nm_UserMapping__c obuse;
     private static nm_Program__c  objP ;
     private static Calender__c objC;
     private static Lead_Routing__c objrouting;
     private static nm_LinksForDocumentsLead__c objlfdoc;   
     private static nm_LinksForDocumentsLead__c  objldl1 ;
     static private nm_EligiblityCriteria__c objEc;
     static private nmSerialNo__c objSNo;
     static private nm_Holidays__c objHoliday;
     
     Public static  nm_StudentProgram__c objSP;       
    static testMethod void testUnsubscribe() {
    
       // Create a new email and envelope object.
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
    
       // Create a new test lead and insert it in the test method.
      /* Lead l = new lead(firstName='John', 
                lastName='Smith',
                Company='Salesforce', 
                Email='user@acme.com', 
                HasOptedOutOfEmail=false);
       insert l;
    */
    LoadData();
       // Create a new test contact and insert it in the test method.
       Contact c = new Contact(firstName='john', 
                    lastName='smith', 
                    Email='user@acme.com', 
                    HasOptedOutOfEmail=false);
       insert c;
       
       // Test with the subject that matches the unsubscribe statement.
       email.subject = 'test unsubscribe test';
       env.fromAddress = 'user@acme.com';
       
       // Call the class and test it with the data in the testMethod.
       unsubscribe unsubscribeObj = new unsubscribe();
       unsubscribeObj.handleInboundEmail(email, env );
                            
    }
     
    static testMethod void testUnsubscribe2() {
    
       // Create a new email and envelope object.
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
       // Create a new test lead and insert it in the test method.        
      /* Lead l = new lead(firstName='john', 
                lastName='smith',
                Company='Salesforce', 
                Email='user@acme.com', 
                HasOptedOutOfEmail=false);
       insert l;
    */
    LoadData();
       // Create a new test contact and insert it in the test method.    
       Contact c = new Contact(firstName='john', 
                    lastName='smith', 
                    Email='user@acme.com', 
                    HasOptedOutOfEmail=false);
       insert c;
       
       // Test with a subject that does not contain "unsubscribe."
       email.subject = 'test';
       env.fromAddress = 'user@acme.com';
    
       // Call the class and test it with the data in the test method.
       unsubscribe unsubscribeObj = new unsubscribe();
       unsubscribeObj.handleInboundEmail(email, env );                      
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
          
     
         Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
     
         objcenter = new nm_Centers__c();
         
         objcenter.RecordTypeID =rt.id;         
         objCenter.nm_CenterCode__c ='00hfh2';
         objCenter.nm_CenterCity__c='Delhi';
         objCenter.nm_City__c='Delhi';
         objCenter.nm_StateProvince__c='Delhi';
         objCenter.nm_Street__c='Laxmi Ngar';
         objCenter.nm_PostalCode__c='110091';         
         insert objCenter;
     
        Recordtype rt1=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        objcenter1 = new  nm_Centers__c(); 
        objcenter1.nm_LearningCenter__c =  objcenter .id;    
        objcenter1.Name = 'Halo Knowledge Foudation, Thane (W)'   ;  
        objcenter1.RecordTypeID =rt1.id;           
        objCenter1.nm_CenterCode__c ='002hftj';
        objCenter1.nm_CenterCity__c='Delhi';
        objCenter1.nm_City__c='Delhi';
        objCenter1.nm_StateProvince__c='Delhi';
        objCenter1.nm_Street__c='Laxmi Ngar';
        objCenter1.nm_PostalCode__c='110091';
                 
        insert objCenter1;
     
        objcenter2 = new  nm_Centers__c(); 
        objcenter2.nm_LearningCenter__c =  objcenter .id;         
        objcenter2.RecordTypeID =rt1.id;           
        objCenter2.nm_CenterCode__c ='002gykygk';
        objCenter2.nm_CenterCity__c='Delhi';
        objCenter2.nm_City__c='Delhi';
        objCenter2.nm_StateProvince__c='Delhi';
        objCenter2.nm_Street__c='Laxmi Ngar';
        objCenter2.nm_PostalCode__c='110091';         
        insert objCenter2;
        
        objP= new nm_Program__c ();
        objP.nm_ProgramCode__c='77012';
        objP.nm_ProgramDuration__c=3;
        objP.nm_Type__c='Post Graduate Diploma Programs';
         objp.nmIsActive__c = true;
         objp.nm_ProgramValidity__c = 4;
         objp.nm_TotalSemesters__c = 4;
        if( objP.nm_ProgramName__c == null)
        {
            objP.nm_ProgramName__c= 'PGDBM';
        }  
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
         
          objaccount = new Account();
         objaccount.PersonEmail='amit.kumar@saasfocus.com';
         objaccount.PersonMobilePhone='8377985721';
         objaccount.nm_RegistrationNumber__c='07160501';
         objaccount.nm_StudentStatus__c='Admission form & documents Approved';
         
        
              }    
}