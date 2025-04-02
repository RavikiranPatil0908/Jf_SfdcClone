/**
 * @File Name          : nmLinksForDocumentStatusHandlerTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 10-21-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/21/2019, 4:30:05 PM   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public with sharing class nmLinksForDocumentStatusHandlerTracker {
   
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

    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',false);
        // nm_LinksForDocumentsLead__c objLeadDoc = nmGenericTracker.CreatedDocumentForLead(objLead,'Aadhaar Card');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
      //   Account objAcc = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        nm_WorkExperience__c objWk1 = new nm_WorkExperience__c();
        objWk1.nm_Student__c = objAccount.Id;
        objWk1.nm_CompanyName__c = 'fgjdffj';
        insert objWk1;
        nm_LinksForDocuments__c objDoc= nmGenericTracker.CreateDocumentforAccount(objAccount,'Photo ID proof');
        nm_LinksForDocuments__c objDoc1= nmGenericTracker.CreateDocumentforAccount(objAccount,'Degree Mark Sheet');
        nm_LinksForDocuments__c objDoc2= nmGenericTracker.CreateDocumentforAccount(objAccount,'Student Photograph');
      //   nm_LinksForDocuments__c objDoc= nmGenericTracker.CreateDocumentforAccount(objAccount,'Photo ID proof');
      //   nm_LinksForDocuments__c objDoc= nmGenericTracker.CreateDocumentforAccount(objAccount,'Photo ID proof');
        
    }
    
    static testMethod void testUpdateDocumentSubmittedStatusOnAccountAtApproved(){
       
       Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account];
       nm_LinksForDocuments__c nmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c where nm_DocumentName__c='Defence Document'];
       nm_LinksForDocuments__c nmlinkDoc1 = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c where nm_DocumentName__c='Relationship Document'];
       Map<Id,nm_LinksForDocuments__c> mapofDocs = new Map<Id,nm_LinksForDocuments__c>();
       mapofDocs.put(nmlinkDoc.id, nmlinkDoc);
       nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
       nmlinkDoc.nm_Status__c = 'Approved';
       update nmlinkDoc;
       mapofDocs.put(nmlinkDoc1.id, nmlinkDoc1);
       nmlinkDoc1.nm_URLforDocuments__c= 'www.google.com';
       nmlinkDoc1.nm_Status__c = 'Approved';
       update nmlinkDoc1;
       
       List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
       lstofDocs.add(nmlinkDoc);
       lstofDocs.add(nmlinkDoc1);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.AfterInsert(lstofDocs, mapofDocs);
       Test.stopTest();
    }
    
    static testMethod void testUpdateDocumentSubmittedStatusOnAccountAtDI(){
       
       Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account limit 1];
       nm_LinksForDocuments__c nmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c where nm_DocumentName__c='Defence Document'];
       Map<Id,nm_LinksForDocuments__c> mapofDocs = new Map<Id,nm_LinksForDocuments__c>();
       mapofDocs.put(nmlinkDoc.id, nmlinkDoc);
       nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
       nmlinkDoc.nm_Status__c = 'Documents incorrect';
       update nmlinkDoc;
       List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
       lstofDocs.add(nmlinkDoc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.AfterInsert(lstofDocs, mapofDocs);
       Test.stopTest();
    }

     static testMethod void testUpdateDocumentSubmittedStatusOnAccountAtProvisional(){
       
       Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account limit 1];
       nm_LinksForDocuments__c nmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c where nm_DocumentName__c='Defence Document'];
       Map<Id,nm_LinksForDocuments__c> mapofDocs = new Map<Id,nm_LinksForDocuments__c>();
       mapofDocs.put(nmlinkDoc.id, nmlinkDoc);
       nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
       nmlinkDoc.nm_Status__c = 'Admission Form & Documents Provisional';
       nmlinkDoc.nm_ReasonforDisapprove__c ='NA';
       update nmlinkDoc;
       List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
       lstofDocs.add(nmlinkDoc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.AfterInsert(lstofDocs, mapofDocs);
       Test.stopTest();
    }

     static testMethod void testUpdateDocumentSubmittedStatusOnAccountAtReSubmitted(){
       
       Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account limit 1];
       nm_LinksForDocuments__c nmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c where nm_DocumentName__c='Defence Document'];
       Map<Id,nm_LinksForDocuments__c> mapofDocs = new Map<Id,nm_LinksForDocuments__c>();
       mapofDocs.put(nmlinkDoc.id, nmlinkDoc);
       nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
       nmlinkDoc.nm_Status__c = 'Re-Submited';
       update nmlinkDoc;
       List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
       lstofDocs.add(nmlinkDoc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.AfterInsert(lstofDocs, mapofDocs);
       Test.stopTest();
    }
    static testMethod void testUpdateDocumentSubmittedStatusOnAccount2(){
       
       Account acc = [select Id , nm_StudentStatus__c , nm_EligiblityCriteria__c from Account limit 1];
       nm_LinksForDocuments__c nmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c  limit 1];
       Map<Id,nm_LinksForDocuments__c> mapofDocs = new Map<Id,nm_LinksForDocuments__c>();
       mapofDocs.put(nmlinkDoc.id, nmlinkDoc);
       nmlinkDoc.nm_URLforIncorrectDocuments__c= 'www.google.com';
       nmlinkDoc.nm_Status__c = 'Documents incorrect';
       update nmlinkDoc;
       List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
       lstofDocs.add(nmlinkDoc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.AfterInsert(lstofDocs, mapofDocs);
       Test.stopTest();
    }
    static testMethod void testUpdateDocumentsOnAccountForChangeInEligibilityCriteria(){
       
       nm_EligiblityCriteria__c eligCriteria = nmGenericTracker.CreateElegibilityCriteriaforMaster('Master Programs');
       eligCriteria.nm_Documnetslist__c = '12th Mark Sheet';
       update eligCriteria;
       Account acc = [select Id , nm_StudentStatus__c ,Differently_abled__c, nm_LeadId__c , nm_ChooseaProgram__c ,nm_DefencePersonnel__c , nm_Relationship__c , Is_Lateral__c , nm_EligiblityCriteria__c,nm_Nationality__c,nm_Category__c  from Account limit 1];
       acc.Differently_abled__c ='Yes';
       acc.nm_EligiblityCriteria__c = eligCriteria.id;
       Id criteriaId = acc.nm_EligiblityCriteria__c;
       Id accId = acc.Id;
        acc.Program_Type__c  ='MBA (WX)';
       update acc;
       List<nm_LinksForDocuments__c> lstnmlinkDoc = [select Id ,Student_Inactive__c, nm_Account__c , nm_URLforDocuments__c , nm_URLforIncorrectDocuments__c , StudentStatus__c , Student_Number__c  from nm_LinksForDocuments__c ];
       for(nm_LinksForDocuments__c nmlinkDoc: lstnmlinkDoc){
          nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
          nmlinkDoc.nm_Status__c = 'Approved';
       }
       update lstnmlinkDoc;
       
       List<Account> lstAccount = new List<Account>();
       lstAccount.add(acc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.UpdateDocumentsOnAccountForChangeInEligibilityCriteria(lstAccount, criteriaId , accId);
       Test.stopTest();
    }

     static testMethod void testDocumentCreationOnAccount(){
       
       Lead ld = [select Id from Lead limit 1];
       Account acc = [select Id , nm_StudentStatus__c , nm_LeadId__c ,Differently_abled__c,nmStudent_Program__c , nm_DefencePersonnel__c , nm_Relationship__c , Is_Lateral__c , nm_EligiblityCriteria__c from Account limit 1];
       acc.nm_LeadId__c = ld.id;
       acc.Is_Lateral__c = true;
       acc.Differently_abled__c = 'Yes';
       update acc;
       
       nm_LinksForDocumentsLead__c nmlinkforLead = [select Id , Lead__c from nm_LinksForDocumentsLead__c limit 1];
       nmlinkforLead.Lead__c = ld.id;
       nmlinkforLead.nm_Status__c = 'Approved';
       update nmlinkforLead;

       List<Account> lstAcc = new List<Account>();
       lstAcc.add(acc);
       Test.setMock(HttpCalloutMock.class, new RestMock());
       Test.startTest();
       nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
       obj.DocumentCreationOnAccount(lstAcc);
       Test.stopTest();
    }

   @isTest
   static void testTriggerSkip() {
      Test.setMock(HttpCalloutMock.class, new RestMock());
      Test.startTest();
         insert new Process_Switches__c(SetupOwnerId=UserInfo.getOrganizationId(), Documents_Process_ByPass__c=true);

         List<nm_LinksForDocuments__c> lstnmlinkDoc = [SELECT Id,nm_Status__c,nm_Account__c,nm_URLforDocuments__c FROM nm_LinksForDocuments__c];
         for(nm_LinksForDocuments__c nmlinkDoc: lstnmlinkDoc){
            nmlinkDoc.nm_URLforDocuments__c= 'www.google.com';
            nmlinkDoc.nm_Status__c = 'Approved';
         }
         update lstnmlinkDoc;
      Test.stopTest();
   }

/**
* @description 
* @author @Ravi | 10-21-2024 
**/
@isTest
static void testUpdateLinksForDocumentsProvisionalWithHoldAccount() {
     Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes', false, 'Confirmed');
    objAccount.Provisional_With_Hold__c=true;
    update objAccount;
    //  account with 'Confirmed' status
    Account acc = [SELECT Id, nm_StudentStatus__c, nm_EligiblityCriteria__c FROM Account WHERE nm_StudentStatus__c = 'Confirmed' LIMIT 1];
    
    nm_LinksForDocuments__c nmlinkDoc = [SELECT Id, Student_Inactive__c, nm_Account__c, nm_URLforDocuments__c, nm_URLforIncorrectDocuments__c, StudentStatus__c, Student_Number__c
                                         FROM nm_LinksForDocuments__c 
                                         WHERE nm_DocumentName__c = 'Defence Document' AND nm_Account__c = :acc.Id LIMIT 1];
    
    nm_LinksForDocuments__c nmlinkDoc1 = [SELECT Id, Student_Inactive__c, nm_Account__c, nm_URLforDocuments__c, nm_URLforIncorrectDocuments__c, StudentStatus__c, Student_Number__c
                                          FROM nm_LinksForDocuments__c 
                                          WHERE nm_DocumentName__c = 'Relationship Document' AND nm_Account__c = :acc.Id LIMIT 1];
   
    Map<Id, nm_LinksForDocuments__c> mapofDocs = new Map<Id, nm_LinksForDocuments__c>();
    mapofDocs.put(nmlinkDoc.Id, nmlinkDoc);
    nmlinkDoc.nm_URLforDocuments__c = 'www.google.com';
    nmlinkDoc.nm_Status__c = 'Approved';
    nmlinkDoc.Document_Upload_Mode__c='Upload Self-Attested Now';
    update nmlinkDoc;
    mapofDocs.put(nmlinkDoc1.Id, nmlinkDoc1);
   
    nmlinkDoc1.nm_URLforDocuments__c = 'www.google.com';
     nmlinkDoc1.Document_Upload_Mode__c='Upload Self-Attested Now';
    nmlinkDoc1.nm_Status__c = 'Approved';
    update nmlinkDoc1;
    
    List<nm_LinksForDocuments__c> lstofDocs = new List<nm_LinksForDocuments__c>();
    lstofDocs.add(nmlinkDoc);
    lstofDocs.add(nmlinkDoc1);
   
   //  Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
    obj.AfterInsert(lstofDocs, mapofDocs);
    Test.stopTest();
}

}