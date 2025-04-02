/**
 * @File Name          : LeadServiceTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 04-22-2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    4/7/2019, 2:47:34 PM   @BK     Initial Version
**/
@isTest (SeeAllData=false)
public class LeadServiceTracker
{   
    public static lead objLead;
    private class RestMock implements HttpCalloutMock {
        RestMock() {
           
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup
    public static void setUpData(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nm_Centers__c objCen = [SELECT Id FROM nm_Centers__c WHERE RecordType.Name = 'Learning Center' LIMIT 1];
        update objCen;
        Agency_Access__c access =new Agency_Access__c();
        access.Name='L3_1390_PG';
        access.password__c='L3_1390_PG123';
        access.Is_Active__c=true;
        access.Email__c='sagar@gmail.com';
        insert access;
        Agency_Access__c access1 =new Agency_Access__c();
        access1.Name='StudentPortal';
        access1.password__c='portal@123';
        access1.Is_Active__c=true;
        access1.Email__c='portal@test.in';
        insert access1;
        nm_EscalationMatrix__c  escSetting = new nm_EscalationMatrix__c();
        escSetting.Name = '0-1 week';
        escSetting.nm_HOEscalationTime__c = '2:00';
        escSetting.nm_LCEscalationTime__c = '1:00';
        escSetting.nm_RemidertoHO__c = '2:00';
        escSetting.nm_RemidertoIC__c = '0:30';
        escSetting.nm_RemidertoLC__c = '1:00';
        escSetting.nm_SMLCEscalationTime__c = '4:00';        
        insert escSetting;

        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        objSystemConfiguration.nm_Paymentgatewaypassword__c='ASas324324';
        objSystemConfiguration.nm_PaymentgatewayID__c='CHANDU80089@GMAIL.COM';
        objSystemConfiguration.nm_PaymentResponseUrl_Paytm__c = 'Snadbox';
        insert objSystemConfiguration;

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

        List < nm_Centers__c > lstCenter = [SELECT Id,L1_Allotment__c,L2_Allotment__c, L3_Allotment__c FROM nm_Centers__c WHERE  RecordType.Name = 'Learning Center' AND L1_Allotment__c != null ];
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
    
    static TestMethod void unitTest1()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Sagar','sagar@gmail.com','9987226106','L3_1390_PG','Degree',2014.00,'Mumbai','Diploma Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTestinvalidName2()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Sagar-1^','sagar@gmail.com','9987226106','L3_1390_PG','Degree',2014.00,'Mumbai','Diploma Programs','L3_1390_PG123',null, null, null);
    }
    
    static TestMethod void unitTest2()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('SagarP','amit.kumar@saasfocus.com','8377985721','L3_1390_PG','Degree',2014.00,'Mumbai','Diploma Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTestStudentPortalTest()
    {   
        Agency_Access__c agency = [select Id,Name,password__c,Is_Active__c,Email__c from Agency_Access__c Where Name ='StudentPortal' LIMIT 1];
        System.debug('agency '+agency);
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('SagarP','amit.kumar@saasfocus.com','8377985721',agency.Name,'Degree',2014.00,'Mumbai','Diploma Programs',agency.password__c,null, null, null);
    }
    
    static TestMethod void unitTestinvalidName()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Sagar-P','amit.kumar@saasfocus.com','8377985721','L3_1390_PG','Degree',2014.00,'Mumbai','Diploma Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest3()
    {   Agency_Access__c agency = [select Id,Name,password__c,Is_Active__c,Email__c from Agency_Access__c Where Name ='StudentPortal' LIMIT 1];
        Test.startTest();
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhranshu@saasfocus.com','9891234560',agency.Name,'Degree',2020.00,'Mumbai','Master Programs',agency.password__c,null, null, null);
        Test.stopTest();
    }

    static TestMethod void unitTest4()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhu@gmail.com','9987226112','PGDM','Degree',2014.00,'Mumbai','MBA (Distance) Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest5()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhu1@gmail.com','9987','PGDM','Degree',2014.00,'Mumbai','MBA (Distance) Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest6()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhu2@gmail.com','9987226113','CP','Degree',2014.00,'Mumbai','Certificate Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest7()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhu21@gmail.com','9987226114','B','Degree',2014.00,'Mumbai','Bachelor Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest8()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhu22@gmail.com','9987226114','B','Degree',2014.00,'Mumbai','Bachelor Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest9()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu','shubhu23@gmail.com','9987226114','B','Degree',2014.00,'Mumbai','Professional Programs','L3_1390_PG123',null, null, null);
    }

    static TestMethod void unitTest10()
    {   Test.startTest();
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Shubhranshu-1','shubhu24@gmail.com','4987226114','B','Degree',2014.00,'Mumbai','MBA (Distance) Programs','L3_1390_PG123',null, null, null);
        // LeadService.connectToEnquiry('Shubhranshu-1','shubhu24@gmail.com','4987226114','B','Degree',2014.00,'Mumbai','PH','L3_1390_PG123',null, null, null);
        Test.stopTest();
    }

    static TestMethod void unitTest11()
    {   Test.startTest();
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Bala','shubhu245@gmail.com','9980006114','B','Degree',2014,'Mumbai','MBA (Distance) Programs','L3_1390_PG123',null, null, null);
        Test.stopTest();
    }
    static TestMethod void unitTest12()
    {   Test.startTest();
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('Bala','shubhu245@gmail.com','9980006114','L1_gjfgt','Degree',2014,'Mumbhjhai','MBA (Distance) Programs','L3_1390_PG123',null, null, null);
        Test.stopTest();
    }
    static TestMethod void unitTest13()
    {   Test.startTest();
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/leadservice';
        RestContext.request.addHeader('httpMethod','POST');
        LeadService.connectToEnquiry('SagarP','amit.kumarom','8695101457','L3_1390_PG','Degree',2014.00,'Mumbai','Diploma Programs','L3_1390_PG123',null, null, null);
        Test.stopTest();
    }
}