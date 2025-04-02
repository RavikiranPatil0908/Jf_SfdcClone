@isTest (SeeAllData=false)
public class HikeEducationServiceTracker
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
        nm_Centers__c objCen = [SELECT Id FROM nm_Centers__c WHERE RecordType.Name = 'Information Center' LIMIT 1];
        objCen.GroupName__c = 'Group 1';
        update objCen;
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
    }
    
    static TestMethod void unitTest1()
    {
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/HikeEducationService';
        RestContext.request.addHeader('httpMethod','POST');
        HikeEducationService.connectToEnquiry('First Name', 'tvbes5dggdfghdfddfg452@gmail.com', '9987226106', 'Shiksha', 'BE', 2020.0, 'Mumbai - Mira Road East', 'Diploma Programs', '', 'Partner', 'Hot', '','Mass Database');
    }
    static TestMethod void unitTest2()
    {
        nm_Centers__c objCen = [SELECT Id,Name FROM nm_Centers__c WHERE GroupName__c = 'Group 1' LIMIT 1];
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/HikeEducationService';
        RestContext.request.addHeader('httpMethod','POST');
        HikeEducationService.connectToEnquiry('First Name', 'tvbes5dggdfghdfddfg452@gmail.com', '9987226106', 'Shiksha', 'BE', 2020.0, objCen.Name, 'Diploma Programs', '', 'Partner', 'Hot', '','Mass Database');
    }
    static TestMethod void unitTest3()
    {
        nm_Centers__c objCen = [SELECT Id,Name FROM nm_Centers__c WHERE GroupName__c = 'Group 1' LIMIT 1];
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/HikeEducationService';
        RestContext.request.addHeader('httpMethod','POST');
        HikeEducationService.connectToEnquiry('First Name', 'tvbes5dggdfghdfddfg452@gmail.com', '9987226106', 'Shiksha', 'BE', 2020.0, objCen.Name, 'Diploma Programs', '', 'Partner', 'Hot', '','Mass Database');
        HikeEducationService.connectToEnquiry('First Name', 'tvbes5dggdfghdfddfg452@gmail.com', '9987226106', 'Shiksha', 'BE', 2020.0, objCen.Name, 'Diploma Programs', '', 'Partner', 'Hot', '','Mass Database');
    }
    static TestMethod void unitTest4()
    {
        nm_Centers__c objCen = [SELECT Id,Name FROM nm_Centers__c WHERE GroupName__c = 'Group 1' LIMIT 1];
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/HikeEducationService';
        RestContext.request.addHeader('httpMethod','POST');
        HikeEducationService.connectToEnquiry('First Name', 'tvbes5dggdfghdfddfg452@gmail.com', '4987226106', 'Shiksha', 'BE', 2020.0, objCen.Name, 'Diploma Programs', '', 'Partner', 'Hot', '','Mass Database');
    }
    static TestMethod void unitTest5()
    {
        nm_Centers__c objCen = [SELECT Id,Name FROM nm_Centers__c WHERE GroupName__c = 'Group 1' LIMIT 1];
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/HikeEducationService';
        RestContext.request.addHeader('httpMethod','POST');
        HikeEducationService.connectToEnquiry('First Name', 'tvbes5dggdfghdfddfg452gmail.com', '9987226106', 'Shiksha', 'BE', 2020.0, objCen.Name, 'Diploma Programs', '', 'Partner', 'Hot', '','Mass Database');
    }
}