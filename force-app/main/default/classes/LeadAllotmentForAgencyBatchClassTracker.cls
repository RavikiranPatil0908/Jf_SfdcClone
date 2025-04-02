@isTest
public  class LeadAllotmentForAgencyBatchClassTracker {
        
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        // objLead.Agency__c ='L1_fdgdfgd';
        nm_Centers__c objLcCen = nmGenericTracker.CreateLearningCenter('Delhi');
        objLcCen.nm_ChooseaProgram__c ='Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objLcCen.Name ='Delhi';
        objLcCen.Assign_IC_To_LC__c ='Mumbai';
        update objLcCen;
        objLead.Agency__c ='L3_1390_PG';
        objLead.LC_Wise_Marketing_Distribution_Date__c = date.today();
        objLead.nm_InformationCenter__c =objLcCen.Id;
        update objLead;

        nm_Centers__c objLcCenK = nmGenericTracker.CreateLearningCenter('Kolkata');
        objLcCenK.Name ='Kolkata';
        update objLcCenK;


        
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        User objUser = new User(Alias = 'newUser', Email='newuserSuperAdmin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 
        objUserMap.nm_Centers__c=objLcCenK.Id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;

        List < nm_Centers__c > lstCenter = [SELECT Id,L1_Allotment__c,L2_Allotment__c, L3_Allotment__c FROM nm_Centers__c WHERE  RecordType.Name = 'Learning Center' AND L1_Allotment__c != null ];
        String chooseProgram = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
        String AgencyType = 'L1; L2; L3';
        RecordType RTS = [SELECT Id, Name FROM RecordType WHERE Name = 'LC Assignment' LIMIT 1];
        List<Lead_Assignment__c> lstLeadAssigned = new List<Lead_Assignment__c>();
        List<String> lstAgencyType = new List<String>{'Alpha', 'Beta', 'Gamma', 'Lambda', 'Sigma', 'Others', 'Omega'};
        for (String agency : lstAgencyType) {
            for(nm_Centers__c objCenLc : lstCenter ) {
                lstLeadAssigned.add(new Lead_Assignment__c(Agency_Type__c = agency, Choose_a_Program__c = chooseProgram, Assign_To__c = objCenLc.Id, Allotment_PG__c= 20
                ,Allotment_MS__c= 20, Allotment_UG__c= 20, RecordTypeId = RTS.Id, Active__c = TRUE  ));
    
            }
            
        }
        insert lstLeadAssigned;
        RecordType RTAA = [SELECT Id, Name FROM RecordType WHERE Name = 'Agency Assignment' LIMIT 1];
        Lead_Assignment__c ldA = new Lead_Assignment__c(Agency_Internal_Category__c = 'Alpha', Agency_List__c = 'L3_1390_PG', RecordTypeId = RTAA.Id, Active__c = TRUE);
        insert lda;
        

        

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
        LeadAllotmentForAgencyBatchClass instance = new LeadAllotmentForAgencyBatchClass();
        Database.executeBatch(instance,1);
        Test.stopTest();
        
    }
}