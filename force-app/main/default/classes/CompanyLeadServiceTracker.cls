/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-04-2024
 * @last modified by  : @BK
**/
@isTest (SeeAllData=false)
public class CompanyLeadServiceTracker
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
        objCen.Assign_Company__c = 'Mettler Toledo';
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
    
    @isTest
    static void unitTest1()
    {
        Test.startTest();
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/CompanyLeadService';
            RestContext.request.addHeader('httpMethod','POST');
            CompanyLeadService.connectToEnquiry('First Name', 'test@gmail.com', '9987226106', 'Shiksha', 'Mettler Toledo', 'MBA (Distance) Programs', 'null', null);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest2()
    {
        Test.startTest();
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/CompanyLeadService';
            RestContext.request.addHeader('httpMethod','POST');
            CompanyLeadService.connectToEnquiry('First Name', 'test@gmail.com', '9987226106', 'Shiksha', 'Mettler ToledoY', 'MBA (Distance) Programs', 'null', null);
        Test.stopTest();
    }

    @isTest
    static void unitTest3()
    {
        Test.startTest();
            Lead objL = [SELECT Id,Name, Email, MobilePhone FROM Lead LIMIT 1];
            System.debug('objL ==> ' + objL);
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/CompanyLeadService';
            RestContext.request.addHeader('httpMethod','POST');
            CompanyLeadService.connectToEnquiry('First Name', objL.Email, '9987220006', 'Shiksha', 'Mettler Toledo', 'MBA (Distance) Programs', 'null', null);
        Test.stopTest();
    }

    @isTest
    static void unitTest4()
    {
        Test.startTest();
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/CompanyLeadService';
            RestContext.request.addHeader('httpMethod','POST');
            CompanyLeadService.connectToEnquiry('First Name', 'test+@gmail.com', '99872+26106', 'Shiksha', 'Mettler Toledo', 'MBA (Distance) Programs', 'null', null);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest5()
    {
        Test.startTest();
            Lead objL = [SELECT Id,Name, Email, MobilePhone FROM Lead LIMIT 1];
            System.debug('objL ==> ' + objL);
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/CompanyLeadService';
            RestContext.request.addHeader('httpMethod','POST');
            CompanyLeadService.connectToEnquiry('First Name', objL.Email, '99872+26106', 'Shiksha', 'Mettler Toledo', 'MBA (Distance) Programs', 'null', null);
        Test.stopTest();
    }
}