@isTest
public  class LeadAllotmentOfAgencyForAEPTracker {
        
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        // objLead.Agency__c ='L1_fdgdfgd';
        nm_Centers__c objLcCen = nmGenericTracker.CreateLearningCenter('Delhi');
        objLcCen.nm_ChooseaProgram__c ='Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objLcCen.Name ='Delhi';
        objLcCen.Assign_IC_To_LC__c ='Mumbai';
        update objLcCen;
        
        nm_Centers__c objCeDel = CreateCenter('Delhi-Dwarka', objLcCen);
        nm_Centers__c objCeDel1 = CreateCenter('Delhi-Lake', objLcCen);
        
        
        
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Agency__c ='L1_fdgdfgd';
        objLead.nm_InformationCenter__c =objLcCen.Id;
        update objLead;

        Lead objLead1 = objLead.clone();
        objLead1.Email = 'gfyjftj@ghhg.com';
        objLead1.MobilePhone = '8516952001';
        objLead1.nm_InformationCenter__c =objCeDel.Id;
        insert objLead1;

        List < nm_Centers__c > lstCenter = [SELECT Id FROM nm_Centers__c WHERE  RecordType.Name = 'Information Center' AND CenterName__c = 'Delhi' ];
        String chooseProgram = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
        String AgencyType = 'L1; L2; L3';
        RecordType RTS = [SELECT Id, Name FROM RecordType WHERE Name = 'AEP Assignment' LIMIT 1];
        List<Lead_Assignment__c> lstLeadAssigned = new List<Lead_Assignment__c>();
        for(nm_Centers__c objCen : lstCenter ) {
            lstLeadAssigned.add(new Lead_Assignment__c(Agency_Type__c = AgencyType, Choose_a_Program__c = chooseProgram,From_Center__c = objLcCen.Id,  Assign_To__c = objCen.Id, Allotment_PG__c= 10
            ,Allotment_MS__c= 10, Allotment_UG__c= 10, RecordTypeId = RTS.Id, Active__c = TRUE  ));

        }
        insert lstLeadAssigned;

        

        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();

        objCen.Nm_Active__c = true;
        objCen.Name='Counsellor';
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = '022';
        objCen.ShareApplicable__c =true;
        objCen.nm_CenterCity__c = 'Counsellor';
        objCen.nm_City__c = 'Counsellor';
        objCen.nm_StateProvince__c = 'Counsellor';
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.OwnerId= UserInfo.getUserId();
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c='Retail';
        insert objCen;
    }

    @IsTest
    static void methodName(){
        Test.startTest();
        List<Lead> objLead = [SELECT Id,nm_InformationCenter__c,nm_InformationCenter__r.Name, nm_InformationCenter__r.nm_LearningCenter__r.Name, nm_InformationCenter__r.nm_LearningCenter__c FROM Lead]; 
        system.debug('ListObjLead ==> '+ objLead);
        List<nm_Centers__c> lstCenter = [SELECT Id, Name, RecordType.Name FROM nm_Centers__c];
        system.debug('lstCenter ==> '+ lstCenter);
        LeadAllotmentOfAgencyForAEP instance = new LeadAllotmentOfAgencyForAEP();
        Database.executeBatch(instance);
        Test.stopTest();
        
    }

    public static nm_Centers__c CreateCenter(String centerName,nm_Centers__c objLcCen )
    {
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name= centerName;
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = centerName +'00221';
        objCen.ShareApplicable__c =true;
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.OwnerId= UserInfo.getUserId();
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCen.ConsumerType__c='Retail';
        insert objCen;

         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'newUser' , Email= centerName +'newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=centerName +'newuseoijior@testorg.com');
        insert objUser; 
        
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        objUserMap.nm_Centers__c=objCen.id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;
        return objCen;
    }
}