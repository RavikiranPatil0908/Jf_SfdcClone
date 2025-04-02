/**
 * @File Name          : LinksForDocumentsLeadTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 21/1/2020, 3:24:12 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/1/2020   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class LinksForDocumentsLeadTracker {
    
    private class RestMock implements HttpCalloutMock {
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
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        
        nm_EligiblityCriteria__c objEc = [SELECT id,Mandatory_Document_list__c,nm_Documnetslist__c FROM nm_EligiblityCriteria__c WHERE id=:objLead.nm_EligiblityCriteria__c];
        objEc.nm_Documnetslist__c = '10th Marksheet; 12th Marksheet; Photo ID proof; Student Photograph; Aadhaar Card; Degree Mark Sheet; Degree Certificate; AIU Certificate (For Foreign University); Work Experience Certificate – 2 years; NMIMS Diploma Marksheet; Defence Document';
        update objEc;

        List<String> docNeedToInsert = new List<String>{'12th Marksheet','Photo ID proof','Student Photograph','Aadhaar Card','Degree Mark Sheet','Degree Certificate','AIU Certificate (For Foreign University)','Work Experience Certificate – 2 years','NMIMS Diploma Marksheet','Defence Document'};
        List<nm_LinksForDocumentsLead__c> lstDocuments = new List<nm_LinksForDocumentsLead__c>();

        for(String strDocName : docNeedToInsert){      
            nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
            objDocument.name = strDocName;
            objDocument.nm_DocumentName__c = strDocName;
            objDocument.Lead__c = objLead.id;
            lstDocuments.add(objDocument);
        }

        if(lstDocuments.size() > 0) {
            insert lstDocuments;
        }
    }

    @isTest
    static void testUnit1() { 
        Lead objLead = [SELECT id,nm_RegistrationNo__c,nm_EligiblityCriteria__c FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            LinksForDocumentsLeadTriggerHandler objHandler = new LinksForDocumentsLeadTriggerHandler();
            
            list<nm_LinksForDocumentsLead__c> lstOfDocuments = [SELECT id,Name,nm_URLforDocuments__c,nm_Status__c FROM nm_LinksForDocumentsLead__c
                WHERE Registration_No__c =:objLead.nm_RegistrationNo__c];
            list<nm_LinksForDocumentsLead__c> updateList = new list<nm_LinksForDocumentsLead__c>();
            for(nm_LinksForDocumentsLead__c objLinksForDocuments :lstOfDocuments){
                String stringURL = 'www.google.com';
                objLinksForDocuments.nm_URLforDocuments__c =stringURL;
                objLinksForDocuments.nm_Status__c='';
                updateList.add(objLinksForDocuments);
            }
            if(updateList.size()>0) {
                update updateList;
            }
        Test.stopTest();
    }
}