/**
 * @File Name          : ConnecToTriggerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 23-01-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/30/2019, 1:06:39 PM   shubhranshu     Initial Version
**/
@isTest(SeeAllData=true)
public class ConnecToTriggerTracker
{

    public static Connecto__c connectTo;
    public static nm_Centers__c center;
    public static nm_Centers__c centerCounsellor;
    public static nm_Centers__c objcenter ;
    public static nmSerialNo__c objSNo;
    public static RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
    public static RecordType informationCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
    public static nm_UserMapping__c objMap;
    
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @return testMethod
    */
    static testMethod void test1(){

        Test.StartTest();
        LoadData();
        connectTo.City__c = 'Pune';
        connectTo.Mobile_Number__c = '9892275369'; 
        connectTo.OwnerId=objMap.nm_User__c;
        connectTo.Email_ID__c='Sachin32423542@gmail8.com';
        insert connectTo;

        Task task = new Task();
        task.Status = 'Completed';
        task.WhatId = connectTo.Id;   
        insert task;
        
        connectTo.City__c = '';
        //connectTo.Center__c =centerCounsellor.id;
        connectTo.nm_FirstName__c='sachin';
        connectTo.Qualified__c=false;
        connectTo.nm_LastName__c='test';
        connectTo.Status__c ='Existing Lead';
        connectTo.Status__c='Hot';
        connectTo.Lead_Description__c='Will register in a week or 10 days';
        // connectTo.Email_ID__c = 'vikaadssrmenontest2@gmail.com';
        connectTo.nm_ChooseaProgram__c='PGDHRM';
        connectTo.Email_ID__c='Sachin454354235@gmail.com';
        update connectTo;
        ConnecToTriggerHandler obj = new ConnecToTriggerHandler();
        Test.stopTest();
        

    }
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @return testMethod
    */
    static testMethod void test2(){
        
        Test.StartTest();
        LoadData();
        center.name ='Counsellor';
        update center;
        Lead objLead =new Lead();
        objLead.FirstName ='Mohite';
        objLead.LastName='test';
        objLead.Status ='Reborn';
       // objLead.Lead_Description__c='Will register in a week or 10 days';
        objLead.MobilePhone='9089089078';
        objLead.OwnerId=objMap.nm_User__c;
        objLead.Email='Sacawfeehi45rn@gmail.com';
        objLead.nm_ChooseaProgram__c='PGDM';
        objLead.nm_InformationCenter__c=objcenter.id;
        objLead.LeadSource='Web';
        objLead.Agency__c='Connecto';
        objLead.Connecto__c=connectTo.id;
        objLead.nm_PlantoStart__c='0-1 week';
        insert objLead;
        ConnecToHelperClass ConnecToHelperClass = new ConnecToHelperClass();
        ConnecToHelperClass.updateExistingLeadTORebornFromMobileNo('9089089078');
        ConnecToHelperClass.updateExistingLeadTORebornFromEmail('Sacawfeehi45rn@gmail.com');
        Test.stopTest();
    }
    
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @return void
    */
    static void LoadData(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'newUser2', Email='newuser@testorg2.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijior@testorg2.com');
        insert objUser; 


        objcenter = nmGenericTracker.CreateCenter('Pune');
        objcenter.nm_ChooseaProgram__c = 'MBA (Distance) Programs';
        update objcenter;
        nmGenericTracker.CreateICAndUser(objcenter);
    
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
        center.nm_CenterCode__c ='002drg';
        center.nm_CenterCity__c='Delhi';
        center.nm_City__c='Delhi';
        center.nm_StateProvince__c='Delhi';
        center.nm_Street__c='Laxmi Ngar';
        center.nm_PostalCode__c='110091';
                 
        insert center;
        
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=center.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;
        
        centerCounsellor = new nm_Centers__c();
        
        centerCounsellor.Name = 'Counsellor';  
        centerCounsellor.RecordTypeID = informationCenter.id;           
        centerCounsellor.nm_CenterCode__c ='002fj';
        centerCounsellor.nm_CenterCity__c='Other';
        centerCounsellor.nm_City__c='Other';
        centerCounsellor.nm_StateProvince__c='Delhi';
        centerCounsellor.nm_Street__c='Laxmi Ngar';
        centerCounsellor.nm_PostalCode__c='110091';
        
        Recordtype rt=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
        //  objcenter = new nm_Centers__c();
         
        //  objcenter.RecordTypeID =rt.id;         
        //  objCenter.nm_CenterCode__c ='002tytj';
        //  objCenter.nm_CenterCity__c='Delhi';
        //  objCenter.nm_City__c='Delhi';
        //  objCenter.nm_StateProvince__c='Delhi';
        //  objCenter.nm_Street__c='Laxmi Ngar';
        //  objCenter.nm_PostalCode__c='110091';         
        //  insert objCenter;
        
        insert centerCounsellor;

        nm_UserMapping__c objUserMap1= new nm_UserMapping__c();
        objUserMap1.nm_Centers__c=centerCounsellor.id;
        objUserMap1.nm_User__c=objUser.id;
        objUserMap1.nm_Phone__c='326392156';
        objUserMap1.nm_Head__c= true;
        insert objUserMap1;
        
        objSNo = new nmSerialNo__c();
        objSNo.nm_MaxGenratedNo__c =578;
        objSNo.nm_name__c='Registration Counter';
        insert objSNo;
        
        profile objprofile =[select id from profile where name ='Learning Center' limit 1];
        user usr = [Select id from user where ProfileId=:objprofile.id  and IsActive =true limit 1];
        objMap = new nm_UserMapping__c();
        objMap.nm_User__c =usr.id;
        objMap.nm_Centers__c =center.id;
        CommonTrackerClass.createCenterUsers(objMap);
        
        connectTo = new Connecto__c();
        connectTo.Center__c = center.id;
        connectTo.nm_FirstName__c='Sachin';
        connectTo.nm_LastName__c='test';
        connectTo.nm_ChooseaProgram__c='PGDRM';
        connectTo.Status__c='Not Contacted';
    }
}