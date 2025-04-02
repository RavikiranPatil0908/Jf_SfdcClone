@isTest(seeAllData=true)
public class UpdateOwnerIdBasedOnCityTriggerTracker
{
    public static Connecto__c connectTo;
    public static nm_Centers__c center;
    public static nm_Centers__c centerCounsellor;
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
     public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
   
    public static nm_UserMapping__c objMap;
    
  /*  static testMethod void test1()
    {      
        centerCounsellor = new nm_Centers__c();
        
        centerCounsellor.Name = 'Counsellor';  
        centerCounsellor.RecordTypeID = informationCenter.id;           
        centerCounsellor.nm_CenterCode__c ='002';
        centerCounsellor.nm_CenterCity__c='Delhi';
        centerCounsellor.nm_City__c='Delhi';
        centerCounsellor.nm_StateProvince__c='Delhi';
        centerCounsellor.nm_Street__c='Laxmi Ngar';
        centerCounsellor.nm_PostalCode__c='110091';
        
        insert centerCounsellor;
        LoadData();  
        connectTo.City__c = 'Pune';
        Test.StartTest();
        insert connectTo;
        
        Lead objLead =new Lead();
        objLead.LastName ='Mohite';
        objLead.FirstName ='Mohite23';
        objLead.Status ='Not Contacted';
        objLead.MobilePhone='9922334455';
        objLead.Email='Sachiw54364n@gmail.com';
        objLead.nm_ChooseaProgram__c='PGDM';
        objLead.nm_InformationCenter__c=centerCounsellor.id;
        objLead.LeadSource='Web';
        objLead.Agency__c='ConnectTo';
        objLead.Connecto__c=connectTo.id;
        objLead.nm_PlantoStart__c='0-1 week';
        insert objLead;
        Test.stopTest();

    }
    
    static testMethod void test2()
    {      
        Test.StartTest();
        centerCounsellor = new nm_Centers__c();
        
        centerCounsellor.Name = 'Counsellor';  
        centerCounsellor.RecordTypeID = informationCenter.id;           
        centerCounsellor.nm_CenterCode__c ='002';
        centerCounsellor.nm_CenterCity__c='Delhi';
        centerCounsellor.nm_City__c='Other';
        centerCounsellor.nm_StateProvince__c='Delhi';
        centerCounsellor.nm_Street__c='Laxmi Ngar';
        centerCounsellor.nm_PostalCode__c='110091';
        
        insert centerCounsellor;
        LoadData();
        connectTo.City__c = 'Pune'; 
        insert connectTo;
        connectTo.City__c = 'Other';
        connectTo.Center__c =centerCounsellor.id;
        connectTo.nm_FirstName__c='sachin';
        connectTo.nm_LastName__c='test';
        update connectTo;
        
        Lead objLead =new Lead();
        objLead.FirstName ='Mohite';
        objLead.LastName='test';
        objLead.Status ='Not Contacted';
        objLead.MobilePhone='9922334455';
        objLead.Email='Sachi4545766n@gmail.com';
        objLead.nm_ChooseaProgram__c='PGDM';
        objLead.nm_InformationCenter__c=centerCounsellor.id;
        objLead.LeadSource='Web';
        objLead.Agency__c='ConnectTo';
        objLead.Connecto__c=connectTo.id;
        objLead.nm_PlantoStart__c='0-1 week';
        insert objLead;
        Test.stopTest();

    }
    
    static void LoadData()
    {
    
          nm_EscalationMatrix__c objCustomSeetings3 = new nm_EscalationMatrix__c();
          objCustomSeetings3.name='0-1 week';
          objCustomSeetings3.nm_LCEscalationTime__c='22:45';
          objCustomSeetings3.nm_RemidertoIC__c='22:45';
          objCustomSeetings3.nm_HOEscalationTime__c='20:56';
          objCustomSeetings3.nm_RemidertoHO__c='22:45';
          insert objCustomSeetings3;
          
          nm_EscalationMatrix__c objCustomSeetings = new nm_EscalationMatrix__c();
          objCustomSeetings.name='2-4 week';
          objCustomSeetings.nm_LCEscalationTime__c='20:45';
          objCustomSeetings.nm_RemidertoIC__c='21:45';
          objCustomSeetings.nm_HOEscalationTime__c='20:56';
          objCustomSeetings.nm_RemidertoHO__c='21:45';
          insert objCustomSeetings; 
          
          nm_EscalationMatrix__c objCustomSeetings2 = new nm_EscalationMatrix__c();
          objCustomSeetings2.name='3-6 week';
          objCustomSeetings2.nm_LCEscalationTime__c='20:34';
          objCustomSeetings2.nm_RemidertoIC__c='21:45';
          objCustomSeetings2.nm_HOEscalationTime__c='20:56';
          objCustomSeetings2.nm_RemidertoHO__c='21:45';
          insert objCustomSeetings2; 
          
          nm_Holidays__c objHoliday=new nm_Holidays__c();
          objHoliday.Name='Holi';
          objHoliday.nm_Date__c=system.today();
          insert objHoliday;
               
          SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
          objSystemConfiguration.name='test';
          objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
          objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
          insert objSystemConfiguration;

         center = new  nm_Centers__c(); 
        center.Name = 'Halo Knowledge Foudation, Thane (W)'   ;  
        center.RecordTypeID = learningCenter.id;           
        center.nm_CenterCode__c ='002';
        center.nm_CenterCity__c='Delhi';
        center.nm_City__c='Delhi';
        center.nm_StateProvince__c='Delhi';
        center.nm_Street__c='Laxmi Ngar';
        center.nm_PostalCode__c='110091';
                 
        insert center;
        
        profile objprofile =[select id from profile where name ='Learning Center' limit 1];
        user usr = [Select id from user limit 1];
        objMap = new nm_UserMapping__c();
        objMap.nm_User__c =usr.id;
        objMap.nm_Centers__c =center.id;
        CommonTrackerClass.createCenterUsers(objMap);
        
        connectTo = new Connecto__c();
        connectTo.Center__c = center.id;
        connectTo.Email_ID__c = 'vikasrmenontest@gmail.com';
        connectTo.Mobile_Number__c ='9867167685';
        connectTo.nm_FirstName__c='Sachin';
        connectTo.nm_LastName__c='test';
        connectTo.nm_ChooseaProgram__c='PGDRM';
        connectTo.Status__c='Not Contacted';
    
    }*/


}