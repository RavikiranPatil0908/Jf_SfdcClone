@isTest
public class nmBatchJobToCreateDupLeadTracker {

    private static Lead objLead;
    private static Lead objLead2;
    
    private static Duplicate_Lead__c objDupLead;
    private static nm_Holidays__c objHoliday;
    /*
    static testMethod void testMethodForDupLead()
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
        
        objLead = new  Lead();
        objLead.nm_SelectedIC__c ='Hyderabad - Banjara Hills';
        objLead.FirstName='test first';
        objLead.LastName ='test last';
        objLead.status='Registration Form Filled';
        objLead.Email='testfordup@ymail.com';
        objLead.MobilePhone ='8377985721';
        objLead.Agency__c='test agency';
        objLead.LeadSource= 'Web';
        objLead.nm_IPForLead__c = '1.2.3.4';
        
        Test.StartTest();
        insert objLead;
        
        objLead2 = new  Lead();
        objLead2.nm_SelectedIC__c ='Duplicate Lead Center';
        objLead2.FirstName='test first2';
        objLead2.LastName ='test last2';
        objLead2.status='Registration Form Filled';
        objLead2.Email='testfordup@ymail.com';
        objLead2.MobilePhone ='8377985222';
        objLead2.Agency__c='test agency';
        objLead2.LeadSource= 'Web';
        objLead2.nm_IPForLead__c = '1.2.3.4';
        
        insert objLead2;
        
        objDupLead = new Duplicate_Lead__c();
        objDupLead.nm_FirstName__c = 'test first2'; 
        objDupLead.nm_LastName__c = 'test last2';
        objDupLead.Mobile_No__c = ';8377985222';
        objDupLead.Email__c = 'testfordup@ymail.com';
        objDupLead.Agency__c = 'test agency';  
        objDupLead.Lead_Source__c = 'Web';
        objDupLead.IP_For_Lead__c = '1.2.3.4';   
        
        insert objDupLead;
        delete objLead2;
        
        //nmBatchJobToCreateDupLead b = new nmBatchJobToCreateDupLead();
        //database.executebatch(b);
        Test.StopTest();
        
        //system.assert(objLead.id != null); 
    } 
    */
    static testMethod void test() {
        // Create an instance of query locator
        Database.QueryLocator QL;
        // Create an instance of batchable context
        Database.BatchableContext BC;
        
        SchedulableContext sc;
        
        List<Lead> LeadList = new List<Lead>();
        List<Duplicate_Lead__c> DupLeadList = new List<Duplicate_Lead__c>();
        
        nmBatchJobToCreateDupLead objnmBatchJobToCreateDupLead = new nmBatchJobToCreateDupLead();
        // execute start method
        objnmBatchJobToCreateDupLead.execute(sc); 
        QL = objnmBatchJobToCreateDupLead.start(bc);       
        // Create an instance of Query Locator Iterator
        Database.QueryLocatorIterator QLI =  QL.iterator();
        while (QLI.hasNext())
        {
            Lead oLead = (Lead)QLI.next();
            /*
            DupLeadList.add(new Duplicate_Lead__c(
                   nm_FirstName__c = oLead.FirstName,
                   nm_LastName__c = oLead.LastName,
                   Mobile_No__c = oLead.MobilePhone,
                   Email__c = oLead.Email,
                   Agency__c = oLead.Agency__c,
                   Lead_Source__c = oLead.LeadSource,
                   IP_For_Lead__c = oLead.nm_IPForLead__c,
                   OwnerId = oLead.OwnerId
               ));  
               insert DupLeadList; 
               
             */   
            LeadList.add(oLead);
        }               
        // initiate execute method
        objnmBatchJobToCreateDupLead.execute(BC, LeadList);
        // execute finish method
        objnmBatchJobToCreateDupLead.finish(BC);    
    }

}