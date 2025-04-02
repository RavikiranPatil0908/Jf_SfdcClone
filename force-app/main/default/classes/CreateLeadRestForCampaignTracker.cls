/**
 * @File Name          : CreateLeadRestForCampaignTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 08-26-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    29/5/2020   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class CreateLeadRestForCampaignTracker
{
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();

        nm_EscalationMatrix__c EscalationMatrix =  new nm_EscalationMatrix__c();
        EscalationMatrix.Name = '0-1 Week';
        EscalationMatrix.nm_HOEscalationTime__c = '2:00';
        EscalationMatrix.nm_LCEscalationTime__c = '1:00';
        EscalationMatrix.nm_RemidertoHO__c = '2:00';
        EscalationMatrix.nm_RemidertoIC__c = '0:30';
        EscalationMatrix.nm_RemidertoLC__c = '1:00';
        EscalationMatrix.nm_SMLCEscalationTime__c	 = '4:00';
        insert EscalationMatrix;

        SystemConfiguration__c SystemConfiguration =  new SystemConfiguration__c();
        SystemConfiguration.Name = 'System Data';
        SystemConfiguration.nm_BusinessHoursEndTime__c	 = '10:00';
        SystemConfiguration.nm_BusinessHoursStartTime__c = '18:00';
        insert SystemConfiguration;
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateCenter('Mumbai');
        nm_Centers__c objLcCen = nmGenericTracker.CreateLearningCenter('Delhi');
        objLcCen.nm_ChooseaProgram__c ='Bachelor Programs';
        objLcCen.Assign_IC_To_LC__c ='Mumbai';
        objLcCen.L1_Allotment__c =80;
        objLcCen.L2_Allotment__c =80;
        objLcCen.L3_Allotment__c =80;
        update objLcCen;
        objLead.Agency__c ='L3_1390_PG';
        objLead.nm_InformationCenter__c =objLcCen.Id;
        update objLead;
        System.debug('objLead ==> ' + objLead);
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();

        objCen.Nm_Active__c = true;
        objCen.nm_LearningCenter__c = objLcCen.id;
        objCen.Name='Delhi - Barakhamba';
        
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = '00213';
        objCen.ShareApplicable__c =true;
        objCen.nm_CenterCity__c = 'Delhi - Barakhamba';
        objCen.nm_City__c = 'Delhi - Barakhamba';
        objCen.nm_StateProvince__c = 'Delhi - Barakhamba';
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objCen.OwnerId= UserInfo.getUserId();
        objCen.Allow_PG__c= true;
        objCen.Allow_Degree__c= true;
        objCen.Allow_Bachelor__c= true;
        objCen.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs';
        objCen.ConsumerType__c='Retail';

        insert objCen;

        Recordtype RTs=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCenCounsellor= new nm_Centers__c();

        objCenCounsellor.Nm_Active__c = true;
        objCenCounsellor.Name='Counsellor';
        objCenCounsellor.RecordTypeID = RTs.id;         
        objCenCounsellor.nm_CenterCode__c = '022';
        objCenCounsellor.ShareApplicable__c =true;
        objCenCounsellor.nm_CenterCity__c = 'Counsellor';
        objCenCounsellor.nm_City__c = 'Counsellor';
        objCenCounsellor.nm_StateProvince__c = 'Counsellor';
        objCenCounsellor.nm_Street__c = 'Krishna Nagar';
        objCenCounsellor.nm_PostalCode__c = '110051'; 
        objCenCounsellor.Sync_with_Portal__c =false;
        objCenCounsellor.OwnerId= UserInfo.getUserId();
        objCenCounsellor.Allow_PG__c= true;
        objCenCounsellor.Allow_Degree__c= true;
        objCenCounsellor.Allow_Bachelor__c= true;
        objCenCounsellor.nm_ChooseaProgram__c= 'Certificate Programs;MBA (Distance) Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Master Programs;Bachelor Programs';
        objCenCounsellor.ConsumerType__c='Retail';
        insert objCenCounsellor;

        nm_UserMapping__c objUserMap= new nm_UserMapping__c();
        Profile p = [SELECT Id FROM Profile WHERE Name='Super Admin']; 
        User objUser = new User(Alias = 'newUser', Email='newuserSuperAdmin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseoijiorSuperAdmin@testorg.com');
        insert objUser; 
        objUserMap.nm_Centers__c=objCenCounsellor.Id;
        objUserMap.nm_User__c=objUser.id;
        objUserMap.nm_Phone__c='326392156';
        objUserMap.nm_Head__c= true;
        insert objUserMap;

        // Executive_Lead_Routing__c elr = new Executive_Lead_Routing__c();
        // elr.Executive_Name__c = 'test';
        // elr.From_Center__c = objLcCen.Id;
        // elr.To_center__c = objCen.Id;
        // elr.Max_Lead_Count__c = 1;
        // insert elr;
        List < nm_Centers__c > lstCenter = [SELECT Id FROM nm_Centers__c WHERE  RecordType.Name = 'Learning Center' AND L1_Allotment__c != null ];
        String chooseProgram = 'Certificate Programs; Diploma Programs; Post Graduate Diploma Programs; Professional Programs; Master Programs; Bachelor Programs; MBA (Distance) Programs';
        String AgencyType = 'L1; L2; L3';
        RecordType RTSd = [SELECT Id, Name FROM RecordType WHERE Name = 'LC Assignment' LIMIT 1];
        List<Lead_Assignment__c> lstLeadAssigned = new List<Lead_Assignment__c>();
        List<String> lstAgencyType = new List<String>{'Alpha', 'Beta', 'Gamma', 'Lambda', 'Sigma', 'Others', 'Omega'};
        for (String agency : lstAgencyType) {
            for(nm_Centers__c objCenLc : lstCenter ) {
                lstLeadAssigned.add(new Lead_Assignment__c(Agency_Type__c = agency, Choose_a_Program__c = chooseProgram, Assign_To__c = objCenLc.Id, Allotment_PG__c= 20
                ,Allotment_MS__c= 20, Allotment_UG__c= 20, RecordTypeId = RTSd.Id, Active__c = TRUE  ));
                
            }
        }
        system.debug('lstLeadAssigned ===> ' + lstLeadAssigned);
        insert lstLeadAssigned;
        RecordType RTAA = [SELECT Id, Name FROM RecordType WHERE Name = 'Agency Assignment' LIMIT 1];
        Lead_Assignment__c ldA = new Lead_Assignment__c(Agency_Internal_Category__c = 'Alpha', Agency_List__c = 'L3_1390_PG', RecordTypeId = RTAA.Id, Active__c = TRUE);
        insert lda;


    }

    public static lead objLead;
    
    static TestMethod void unitTest1()
    {
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy@gmail.com','8082354578','20-25','Mumbai','5/1/1990','Mumbai','Master Programs','MBA (X)','DGM','Capital Float','MBA (X) - Business Analytics','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy@gmail.com','8082354578','20-25','Mumbai','5/1/1990','Mumbai','MBA (Distance) Programs','MBA (HRM)','DGM','Capital Float','MBA (Human Resource Management)','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','+1');
        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumbai", "DateOfBirth": "5/1/1990", "Center": "Mumbai", "Program": "Bachelor Programs", "ProgramType": "BBA", "AdvertAgency": "L3_1390_PG", "SelectProgram": "Bachelor of Business Administration", "CountryCode": "+1" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();
        API_Request__c api = new API_Request__c();
        insert api;
        CreateLeadRestForCampaign.sendMailForFailed('ghjghj', 'gfhgfhgf',api );
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy@gmail.com','8082354578','20-25','Mumbai','5/1/1990' ,'Mumbai','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','');
        
        // CreateLeadRestForCampaign.connectToEnquiry('www.google.com', 'test', 'Search_Exc_MBA_Generic_Exact_Mumbai_May19', 'google_sem-mbawx', 'BE', 'cpc', 'testsize', '182.70.112.204', '20-11-2019 17:34:53', 'Manu pqaaqqt', 'te8raaerat02nyghj9@gmail.com', '9447810243', '20-25', 'Mumbai', 'www.google.com', 'Mumbai - Mira Road East', 'Master Programs', 'Textile', 'Team Lead', 'Tonic', 'Maharastra', '400064', 'Cj0KCQjwqs3rBRCdARIsADe1pfRmxVcDtipq8Se7OvxKEXUUt6CgX6Et1YlSt0kJWJ9QELABsW9rRRgaAoIgEALw_wcB', 'good_leadadd');
    }


    static TestMethod void unitTest2()
    {
        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumbai", "DateOfBirth": "5/1/1990", "Center": "Mumbai", "Program": "Master Programs", "ProgramType": "MBA (X)", "AdvertAgency": "L3_1390_PG", "SelectProgram": "MBA (X) - Business Analytics" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy@gmail.com','8082354578','20-25','Mumbai','5/1/1990','Mumbai','Master Programs','MBA (X)','DGM','Capital Float','MBA (X) - Business Analytics','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy@gmail.com','8082354578','20-25','Mumbai','5/1/1990','Mumbai','Master Programs','MBA (X)','DGM','Capital Float','MBA (X) - Business Analytics','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','','','');
    }
    static TestMethod void unitTest3()
    {
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumbai", "DateOfBirth": "5/1/1990", "Center": "Mumbai-Mira", "Program": "Master Programs", "ProgramType": "MBA (X)", "AdvertAgency": "DGM", "SelectProgram": "MBA (X) - Business Analytics" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy12@gmail.com','8082352578','20-25','Mumbai','5/1/1990' ,'Mumbai-Mira','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy12@gmail.com','8082352578','20-25','Mumbai','5/1/1990' ,'Mumbai-Mira','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','');
    }
    static TestMethod void unitTest4()
    {
        Test.startTest();
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumbai", "DateOfBirth": "5/1/1990", "Center": "Delhi - Barakhamba", "Program": "Master Programs", "ProgramType": "MBA (X)", "AdvertAgency": "DGM", "SelectProgram": "MBA (X) - Business Analytics" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();

        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','test');
        Test.stopTest();
    }
    static TestMethod void unitTest5()
    {
        Test.startTest();
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumbai", "DateOfBirth": "5/1/1990", "Center": "Delhi - Barakhamba", "Program": "Master Programs", "ProgramType": "MBA (X)", "SelectProgram": "MBA (X) - Business Analytics" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();

        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','test');
        Test.stopTest();
    }
    static TestMethod void unitTest7()
    {
        Test.startTest();
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumbai", "DateOfBirth": "5/1/1990", "Center": "Delhi - Barakhamba", "Program": "Master Programs", "ProgramType": "MBA (X)", "AdvertAgency": "L3_1390_PG", "SelectProgram": "MBA (X) - Business Analytics", "CountryCode":"+159561" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+159561','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','test');
        Test.stopTest();
    }
    static TestMethod void unitTest6()
    {
        Test.startTest();
        
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumfdgbai", "DateOfBirth": "5/1/1990", "Center": "Delhi - Baamba", "Program": "Master Programs", "ProgramType": "MBA (X)", "AdvertAgency": "L3_1390_PG", "SelectProgram": "MBA (X) - Business Analytics", "CountryCode":"+1" }';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg','sandy132@gmail.com','8082662578','20-25','Mumfdgbai','5/1/1990' ,'Delhi - Baamba','Bachelor Programs','BBA','L1_dfdf_dff','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','test');
        Test.stopTest();
    }
    static TestMethod void unitTest9()
    {
        Test.startTest();
        
        // System.RestContext.request = new RestRequest();
        // RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
        // RestContext.request.addHeader('httpMethod','POST');

        String myJSON = '{ "Site": "google.com", "Keywords": "Test", "AdvertCampaign": "Stg1_HTMLMailer_DriveJan2017", "AdvertContent": "Test", "AdvertType": "cpl", "AdvertSize": "size", "FullName": "Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg", "EmailAddress": "Sandy@gmail.com", "ContactNumber": "8082354578", "City": "Mumfdgbai", "DateOfBirth": "5/1/1990", "Center": "Delhi - Baamba", "Program": "Master Programs", "ProgramType": "MBA (X)", "AdvertAgency": "L3_1390_PG", "SelectProgram": "MBA (X) - Business Analytics", "CountryCode":"+1" ,"Center": "Delhi - Baamba"}';
        RequestData(myJSON,'POST');
        CreateLeadRestForCampaign.connectToEnquiry();
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy sddsgfdggsdfsd sdgfsggsdgdfgdfgfdg gdfgdfgfgdfgewewgfeg gfdgdfggdfgdfg','sandy132@gmail.com','8082662578','20-25','Mumfdgbai','5/1/1990' ,'Delhi - Baamba','Bachelor Programs','BBA','L1_dfdf_dff','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','');
        // CreateLeadRestForCampaign.connectToEnquiry('google.com','Test','Stg1_HTMLMailer_DriveJan2017','BE','cpl','size','www.yahoo.com','14.139.125.227','17-11-2016 17:34:53','Sandy','sandy132@gmail.com','8082662578','20-25','Mumbai','5/1/1990' ,'Delhi - Barakhamba','Bachelor Programs','BBA','DGM','Capital Float', 'Bachelor of Business Administration','Marketing Head','infotect','Maharashtra','400071','Test1','Test1','Web','Siksha','+1','','test');
        Test.stopTest();
    }

    public static void RequestData(String myJson,String requestMethod) {
      RestResponse response = new RestResponse();
      RestRequest request = new RestRequest();
      request.requestURI = System.Label.Site_Url+'services/apexrest/CreateLeadRestForCampaign/';
      request.httpMethod=requestMethod;
      request.requestBody = Blob.valueof(myJSON);
      RestContext.request = request;
      RestContext.response = response;
    }
}