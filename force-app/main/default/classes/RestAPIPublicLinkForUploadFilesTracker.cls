/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class RestAPIPublicLinkForUploadFilesTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    static void makeData(){
        
        Id personAccRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(FirstName='Test123', LastName='abc', RecordTypeId = personAccRecordTypeId, nm_StudentNo__c='77777778556', nm_RegistrationNumber__c='745123669000', PersonMobilePhone='8652532023',PersonEmail='test123@gmail.com');
        insert acc;

        String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77777778556', Escalation_Level__c=0, RecordTypeId=ticket, Account=acc);
        insert c1;      
    }

    @isTest
    public static void testMethod1() {
        Case objCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest(); 
            String myJSON = '{"fileContent":"hfjdjdksks","fileName":"test","caseId":' + '"' +objCase.Id+ '"' + '}';
            RequestData(myJSON,'POST');
            RestAPIPublicLinkForUploadFiles.doPost();
        Test.stopTest();
    }

    @isTest
    public static void testMethod2() {        
        Test.startTest(); 
        String myJSON = '{"fileContent":"hfjdjdksks","fileName":"test","caseId":""}';
        RequestData(myJSON,'POST');
            RestAPIPublicLinkForUploadFiles.doPost();
        Test.stopTest();
    }

    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/RestAPIPublicLinkForUploadFiles';
        request.httpMethod = requestMethod;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }
}