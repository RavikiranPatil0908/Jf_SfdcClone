/**
 * @File Name          : SalesCadenceControllerTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 07-09-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    25/6/2020   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class SalesCadenceControllerTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"LogonUrl" :"https://staging-app.zestmoney.in/?LoanApplicationId=e9229f74-dbe5-4884-88d9-61ec1f8a9f5f&merchantid=93863917-d9c6-4e71-8bd4-1b0b3a41caec&basketamount=76000&returnurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&approvedurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&downpaymentamount=6200"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

        // insert attachment
        Document documentObj;
        documentObj = new Document();
        documentObj.Body = Blob.valueOf('Some Document Text');
        documentObj.ContentType = 'application/pdf';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.AuthorId = UserInfo.getUserId();
        documentObj.FolderId = UserInfo.getUserId();
        insert documentObj;

        // // insert task.
        // Task objTask = new Task();
        // objTask.WhoId = objLead.id;
        // objTask.Subject = 'Call';
        // objTask.Description = 'test';
        // objTask.ActivityDate = System.today();
        // objTask.Type = 'Call';
        // objTask.TaskSubtype = 'Call';
        // insert objTask;               
    }

    public static testMethod void unitTest1() {
        Lead objLead = [select id,nm_Program__c,nm_InformationCenter__r.Name from Lead limit 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            salesCadenceController.getLeads();
            salesCadenceController.getLeadsforRefresh();
            salesCadenceController.updateLead(objLead,objLead.id);
            salesCadenceController.updateDescription(objLead.id,'test');
            salesCadenceController.getActivityHistory(objLead.id,'last_7_days',0);
            salesCadenceController.getActivityHistory(objLead.id,'last_30_days',0);
            salesCadenceController.getActivityHistory(objLead.id,'next_7_days',0);
            salesCadenceController.getLeadRecord(objLead.id);
            salesCadenceController.getRefershRecord(objLead.id);
            salesCadenceController.getOrgDetails();
            salesCadenceController.getOrganization();
            salesCadenceController.getLSMappings();
            salesCadenceController.getCounselorDetails(objLead.nm_InformationCenter__r.Name);
        Test.stopTest();
    }

    public static testMethod void unitTest2() {
        Lead objLead = [select id,nm_Program__c,nm_InformationCenter__r.Name from Lead limit 1];
        // insert task.
        Task objTask = new Task();
        objTask.WhoId = objLead.id;
        objTask.Subject = 'Call';
        objTask.Description = 'test';
        objTask.ActivityDate = System.today();
        objTask.Type = 'Call';
        objTask.TaskSubtype = 'Call';
        // insert objTask; 
        Document attachments = [SELECT Id,body,ContentType,Name FROM Document Limit 1];
        List<String> attachmentId = new List<String>{attachments.Id};
        Test.startTest();
            Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
            Schema.SObjectType targetType=globalDescMap.get('Lead');
            sObject sObj = targetType.newSObject();
            salesCadenceController.fetchPickListValue(sObj,'Status');
            salesCadenceController.EmailValueWrapper objWrapper = new salesCadenceController.EmailValueWrapper();
            objWrapper.leadId = objLead.Id;
            objWrapper.toAddress = 'test@gmail.com';
            objWrapper.fromAdress = 'test@gmail.com';
            objWrapper.ccAddress = 'test@gmail.com';
            objWrapper.bccAddress = 'test@gmail.com';
            objWrapper.subject = 'test';
            objWrapper.body = 'test';
            objWrapper.hasAttachment = true;
            objWrapper.attachments = attachmentId;
            objWrapper.emailType = 'text';
            salesCadenceController.sendEmail(objWrapper);
            Task objTask2 = salesCadenceController.saveTask(objTask);
            salesCadenceController.getEmailDetails(objTask2.Id);
            salesCadenceController.getActivityHistory(objLead.id,'last_7_days',0);
        Test.stopTest();
    }

    public static testMethod void unitTest3() {
        Test.startTest();
            salesCadenceController.getAllEmailTemplate();
        Test.stopTest();
    }

    public static testMethod void unitTest4() {
        Test.startTest();
            salesCadenceController.getAllDocuments();
        Test.stopTest();
    }
}