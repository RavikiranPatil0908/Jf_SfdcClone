/**
 * @File Name          : DocumentsCheckControllerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 10-17-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/26/2019, 12:08:48 PM   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class DocumentsCheckControllerTracker {

    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_LinksForDocuments__c  objDoc;
    
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
    
    @TestSetup
    public static void setUpData(){

        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents submitted');  
        objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);   
        objDoc = nmGenericTracker.CreateDocumentforAccount(objAccount,'Aadhaar Card');

        // Business account
        Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com');
        insert objBusinessAccount;
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objAccount.nm_Centers__c;
        cp.BusinessAccount__c = objBusinessAccount.id;
        insert cp;
    }

    @isTest 
    static void testGetDocument(){

       nm_LinksForDocuments__c linkDoc = [select id,nm_Status__c from nm_LinksForDocuments__c limit 1];
       linkDoc.nm_Status__c = 'Documents incorrect'; 
       update linkDoc;
       Account objAccount = [select id from Account limit 1];
       String AccId = ApexPages.currentPage().getParameters().put('id',objAccount.id);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       DocumentsCheckController DocChk = new DocumentsCheckController();
       DocChk.getDocumentRelatedData(AccId);
       Test.stopTest();
    }

    @isTest 
    static void testSave1(){
        nm_LinksForDocuments__c linkDoc = [select id,nm_Status__c,Document_Query__c,nm_ReasonforDisapprove__c from nm_LinksForDocuments__c limit 1];
        linkDoc.nm_Status__c = 'Approved'; 
        update linkDoc;
        Account objAccount = [select id,nm_StudentStatus__c from Account limit 1];
        objAccount.nm_StudentStatus__c = 'Admission form & documents submitted';
        update objAccount;
        Counsellor_Profile__c cp = [select Id ,Salutation__c, First_Name__c ,Last_Name__c from Counsellor_Profile__c limit 1];
        String studStatusForAcc = objAccount.nm_StudentStatus__c;
        String linkForDocumentId = linkDoc.id;
        String documentStatus = linkDoc.nm_Status__c;
        String docQuery = '';
        String reasonIfDisapproved = '';
        Map<String,nm_LinksForDocuments__c> mpaOflinkOfDoc = new Map<String,nm_LinksForDocuments__c>();
        mpaOflinkOfDoc.put(linkDoc.id, linkDoc);
        String jsonMap =JSON.serialize(mpaOflinkOfDoc);
        Map<String,String> mapUserIdVsCounselorId = new Map<String,String>();
        List<Counsellor_Profile__c> lstProfile = [SELECT id,OwnerId FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office'];
        for (Counsellor_Profile__c objProfile : lstProfile) {
            mapUserIdVsCounselorId.put(objProfile.OwnerId,objProfile.id);
        }
        String jsonMapOfUserId = JSON.serialize(mapUserIdVsCounselorId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        DocumentsCheckController.save(studStatusForAcc,linkForDocumentId,documentStatus,docQuery,reasonIfDisapproved,jsonMap,jsonMapOfUserId);
        Test.stopTest();
    }

    @isTest 
    static void testSave2(){
       nm_LinksForDocuments__c linkDoc = [select id,nm_Status__c,Document_Query__c,nm_ReasonforDisapprove__c, nm_URLforDocuments__c from nm_LinksForDocuments__c limit 1];
       linkDoc.nm_Status__c = 'Documents incorrect'; 
       linkDoc.nm_URLforDocuments__c='www.google.com';
       linkDoc.Document_Query__c ='Blur Photo';
       update linkDoc;
       Account objAccount = [select id,nm_StudentStatus__c from Account limit 1];
       objAccount.nm_StudentStatus__c = 'Admission form & documents submitted';
       update objAccount;
       Counsellor_Profile__c cp = [select Id ,Salutation__c, First_Name__c ,Last_Name__c from Counsellor_Profile__c limit 1];
       String studStatusForAcc = objAccount.nm_StudentStatus__c;
       String linkForDocumentId = linkDoc.id;
       String documentStatus = linkDoc.nm_Status__c;
       String docQuery = linkDoc.Document_Query__c;
       String reasonIfDisapproved = '';
       Map<String,nm_LinksForDocuments__c> mpaOflinkOfDoc = new Map<String,nm_LinksForDocuments__c>();
       mpaOflinkOfDoc.put(linkDoc.id, linkDoc);
       String jsonMap =JSON.serialize(mpaOflinkOfDoc);
       Map<String,String> mapUserIdVsCounselorId = new Map<String,String>();
       List<Counsellor_Profile__c> lstProfile = [SELECT id,OwnerId FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office'];
       for (Counsellor_Profile__c objProfile : lstProfile) {
           mapUserIdVsCounselorId.put(objProfile.OwnerId,objProfile.id);
       }
       String jsonMapOfUserId = JSON.serialize(mapUserIdVsCounselorId);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       DocumentsCheckController.save(studStatusForAcc,linkForDocumentId,documentStatus,docQuery,reasonIfDisapproved,jsonMap,jsonMapOfUserId);
       Test.stopTest();
    }

    @isTest 
    static void testSave3(){
       nm_LinksForDocuments__c linkDoc = [select id,nm_Status__c,Document_Query__c,nm_ReasonforDisapprove__c from nm_LinksForDocuments__c limit 1];
       linkDoc.nm_Status__c = 'Disapproved'; 
       update linkDoc;
       Account objAccount = [select id,nm_StudentStatus__c from Account limit 1];
       objAccount.nm_StudentStatus__c = 'Admission form & documents submitted';
       update objAccount;
       Counsellor_Profile__c cp = [select Id ,Salutation__c, First_Name__c ,Last_Name__c from Counsellor_Profile__c limit 1];
       String studStatusForAcc = objAccount.nm_StudentStatus__c;
       String linkForDocumentId = linkDoc.id;
       String documentStatus = linkDoc.nm_Status__c;
       String docQuery = '';
       String reasonIfDisapproved = '';
       Map<String,nm_LinksForDocuments__c> mpaOflinkOfDoc = new Map<String,nm_LinksForDocuments__c>();
       mpaOflinkOfDoc.put(linkDoc.id, linkDoc);
       String jsonMap =JSON.serialize(mpaOflinkOfDoc);
       Map<String,String> mapUserIdVsCounselorId = new Map<String,String>();
       List<Counsellor_Profile__c> lstProfile = [SELECT id,OwnerId FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office'];
       for (Counsellor_Profile__c objProfile : lstProfile) {
           mapUserIdVsCounselorId.put(objProfile.OwnerId,objProfile.id);
       }
       String jsonMapOfUserId = JSON.serialize(mapUserIdVsCounselorId);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       DocumentsCheckController.save(studStatusForAcc,linkForDocumentId,documentStatus,docQuery,reasonIfDisapproved,jsonMap,jsonMapOfUserId);
       Test.stopTest();
    }
}