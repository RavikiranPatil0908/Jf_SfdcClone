@isTest
public  class CounsellorCountForLeadBatchClassTracker {
        
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        User objUser = new User(Alias = 'newUser', Email='newuserSuperAdmin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 
        nm_Centers__c objCen = [SELECT Id FROM nm_Centers__c Where Id =:objLead.nm_InformationCenter__c LIMIT 1];
        objCen.GroupName__c = 'Group 1';
        update objCen;
        objUserMap.nm_Centers__c=objLead.nm_InformationCenter__c;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;
         Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.OwnerId = objUser.id;
        cp.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
        cp.Max_Lead_Count__c = 2;
        cp.Employee_Sign_URL__c = 'www.google.com';
        cp.Employee_Image_URL__c  = 'www.google.com';
        cp.AEP_Name__c = objLead.nm_InformationCenter__c ;
        insert cp;
        // objLead.OwnerId = UserInfo.getUserId();
        // objLead.Counselor_Profile__c = cp.Id;
        // update objLead;
    }

    @IsTest
    static void methodName(){
        List<nm_UserMapping__c> lstUserMapping = [SELECT Id, nm_User__c, nm_Head__c,User_Active__c FROM nm_UserMapping__c];
        Test.startTest();
        CounsellorCountForLeadBatchClass instance = new CounsellorCountForLeadBatchClass();
        Database.executeBatch(instance,1);

        AssignCounsellorHelper AssignCounsellorHelper = new AssignCounsellorHelper();
        AssignCounsellorHelper.AssignCenterHead(lstUserMapping, lstUserMapping[0].nm_User__c);
        // instance.AssignCenterHead(lstUserMapping, lstUserMapping[0].nm_User__c);
        // instance.sendErrorMail();
        Test.stopTest();
        
    }
}