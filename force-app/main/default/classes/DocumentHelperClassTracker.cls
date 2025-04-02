/**
 * @File Name          : DocumentHelperClassTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 23--03--2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/14/2019, 11:30:17 AM   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class DocumentHelperClassTracker 
{

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
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
        Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
        Set<String> setOfEligiblityCriteria = new Set<String>();
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',false);
        nm_LinksForDocumentsLead__c objLeadDoc = nmGenericTracker.CreatedDocumentForLead(objLead,'Aadhaar Card');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents submitted');
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Defence Document');

        // to create new Eligiblity creitria

        nm_EligiblityCriteria__c objEc = new nm_EligiblityCriteria__c ();
        objEc.Name='Bachelor with 55% and 3 yr Work exp.';
        objEc.Is_Active__c = true;
        objEc.nm_Documnetslist__c ='10th Marksheet; 12th Marksheet';
        objEc.Experience_Required_In_Year__c= 3;
        objEc.nm_EligiblityCriteria__c ='test';
        objEc.nm_Program__c = 'Post Graduate Diploma Programs';
        objEc.Graduation_Required__c = true;
        objEc.Mandatory_Document_list__c = '12th Marksheet';
        insert objEc;
        
        objLead.nm_Category__c = 'OBC';
        objLead.Differently_abled__c  ='Yes';
        update objLead;
    }

    @isTest
    static void createDocumentRecordsLead()
    {
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c FROM Lead LIMIT 1];
        Test.startTest();
            Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
            Set<String> setOfEligiblityCriteria = new Set<String>();
            List<Lead> lstLead = new List<Lead>();
            objLead.Are_you_from_Defence__c = 'Yes';
            objLead.Relationship__c = 'Parent';
            objLead.Differently_abled__c = 'Yes';
            objLead.Your_disability__c = 'PWD - Low-vision';
            objLead.Relationship__c = 'Parent';
            objLead.Is_Lateral__c = true;
            objLead.nm_ChooseaProgram__c='Bachelor Programs';
            objLead.Diploma_status__c='Appeared';
            objLead.HSC_status__c='Pending';
            lstLead.add(objLead);
            
            if(String.isNotBlank(objLead.nm_EligiblityCriteria__c)){
                setOfEligiblityCriteria.add(objLead.nm_EligiblityCriteria__c);
            }
                
            DocumentHelperClass obj = new DocumentHelperClass();
            if(setOfEligiblityCriteria.size() > 0){
                mapCriteriaDocuments = obj.GetProgrameWiseDocumentsList(setOfEligiblityCriteria);
            } 
            obj.CreateDocumentRecordsOnLead(lstLead,mapCriteriaDocuments);
        Test.stopTest();
    }

    @isTest
    static void createDocumentRecordsLead2()
    {
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c,nm_Program__c FROM Lead LIMIT 1];
        Test.startTest();
            Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
            Set<String> setOfEligiblityCriteria = new Set<String>();
            nm_Program__c program = nmGenericTracker.CreateProgram('Certificate Programs', 'Advanced Certificate program in Operations Management', 2 , '');
            List<Lead> lstLead = new List<Lead>();
            objLead.Are_you_from_Defence__c = 'Yes';
            objLead.Relationship__c = 'Parent';
            objLead.Is_Lateral__c =true;
            System.debug('program.id '+program.Id);
            objLead.nm_Program__r = program;
            update objLead;

            Lead ld = [select Id , nm_Program__c ,nm_ProgramName__c from Lead where Id =: objLead.Id];
            System.debug('objLead.nm_ProgramName__c in CreateDocumentRecordsLead2'+ld.nm_ProgramName__c);
            objLead.nm_Program__c = ld.nm_Program__c;
            lstLead.add(objLead);
            
            if(String.isNotBlank(objLead.nm_EligiblityCriteria__c)){
                setOfEligiblityCriteria.add(objLead.nm_EligiblityCriteria__c);
            }
                
            DocumentHelperClass obj = new DocumentHelperClass();
            if(setOfEligiblityCriteria.size() > 0){
                mapCriteriaDocuments = obj.GetProgrameWiseDocumentsList(setOfEligiblityCriteria);
            } 
            obj.CreateDocumentRecordsOnLead(lstLead,mapCriteriaDocuments );
        Test.stopTest();
    }

    @isTest
    static void Test_CheckDocToDelete(){
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c FROM Lead LIMIT 1];
        Test.startTest();
            Set<string> set1 = new Set<string>();
            List<nm_LinksForDocumentsLead__c> lst = new List<nm_LinksForDocumentsLead__c>();
            nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
            nm_LinksForDocumentsLead__c objDocument2 = new nm_LinksForDocumentsLead__c();
            
            objDocument.name = 'Test';
            objDocument.nm_DocumentName__c = 'Test';
            objDocument.Lead__c = objLead.id;   
            set1.add(objDocument.name) ;                       
            lst.add(objDocument);

            objDocument2.name = 'Test2';
            objDocument2.nm_DocumentName__c = 'Test2';
            objDocument2.Lead__c = objLead.id;
            lst.add(objDocument2);

            DocumentHelperClass obj = new DocumentHelperClass();
            System.Assert(obj.checkDocToDelete(set1, lst) != null);
            obj.insertDocumentsAfterUpdate(lst);
            obj.documentNeedToDelete(lst);
            obj.IsNullOrEmpty('value');
        Test.StopTest();
    }
    
    @isTest
    static void transferDocLeadToAccount()
    {
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c FROM Lead LIMIT 1];
        Account objAccount = [SELECT id,nm_LeadId__c FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
            List<Account> lstAccount = new List<Account>();
            objAccount.nm_LeadId__c = objLead.id;
            update objAccount;
            lstAccount.add(objAccount);
            DocumentHelperClass obj = new DocumentHelperClass();
            obj.TransferDocumentFromLeadToAccount(lstAccount);
        Test.StopTest();
    }

    @isTest
    static void updateDocumentsOnLeadForChangeInEligibilityCriteria()
    {
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c FROM Lead LIMIT 1];
        nm_EligiblityCriteria__c objEc  = [SELECT Id FROM nm_EligiblityCriteria__c WHERE Experience_Required_In_Year__c=3 LIMIT 1];
        Test.startTest();
            List<Lead> lstLead = new List<Lead>();
            objLead.nm_EligiblityCriteria__c = objEc.Id;
            objLead.Is_Lateral__c = true;
            lstLead.add(objLead);
            update lstLead;
            DocumentHelperClass obj = new DocumentHelperClass();
        Test.StopTest();
    } 

    @isTest
    static void Test_checkContains(){
        Test.StartTest();
            Set<string> set1 = new Set<string>{'77214001654','77214001734','77214001816'};
            Set<string> set2 = new Set<string>{'77214001654','77214001534','77264001816'};
            // TODO : Change following Assert Statement
            DocumentHelperClass obj = new DocumentHelperClass();
            System.Assert(obj.checkContains(set1, set2) != null);
        Test.StopTest();
    }

    
    @isTest
    static void validateDocumentsEligibilityCriteria()
    {
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c FROM Lead LIMIT 1];
        nm_LinksForDocumentsLead__c objLeadDoc = [SELECT id,Name,Lead__c,nm_DocumentName__c,nm_URLforDocuments__c FROM nm_LinksForDocumentsLead__c WHERE nm_DocumentName__c='Aadhaar Card' AND Lead__c=:objLead.id];
        Test.startTest();
            DocumentHelperClass obj = new DocumentHelperClass();
            map<string,string> DocumentStatus = new map<string,string>{objLeadDoc.id+'-'+objLeadDoc.Name => 'Disapproved'};
            map<string,string> DocumentLink = new map<string,string>{objLeadDoc.id+'-'+objLeadDoc.Name=>null};
            Set<string> SetofMandataryDocumentforEligibilityCriteria = new Set<string>{objLeadDoc.Name}; 
            Set<string> SubmittedDocument = new Set<string>();
            obj.ValidateDocumentsEligibilityCriteriaWiseonLead(String.valueOf(objLeadDoc.id),DocumentStatus,DocumentLink,SubmittedDocument,SetofMandataryDocumentforEligibilityCriteria);
            DocumentStatus = new map<string,string>{objLeadDoc.id+'-'+objLeadDoc.Name => 'Pending'};
            obj.ValidateDocumentsEligibilityCriteriaWiseonLead(String.valueOf(objLeadDoc.id),DocumentStatus,DocumentLink,SubmittedDocument,SetofMandataryDocumentforEligibilityCriteria);
            DocumentStatus = new map<string,string>{objLeadDoc.id+'-'+objLeadDoc.Name => 'Disapproved'};
            obj.ValidateDocumentsEligibilityCriteriaWiseonLead(String.valueOf(objLeadDoc.id),DocumentStatus,DocumentLink,SubmittedDocument,SetofMandataryDocumentforEligibilityCriteria);
        Test.StopTest();
    }
    @isTest
    static void validateUpdateDocumentsOnLeadForFlagChanges()
    {
        Lead objLead = [SELECT id,Are_you_from_Defence__c,Relationship__c,Is_Lateral__c,nm_EligiblityCriteria__c, nm_Category__c, Differently_abled__c FROM Lead LIMIT 1];
        nm_LinksForDocumentsLead__c objLeadDoc = [SELECT id,Name,Lead__c,nm_DocumentName__c,nm_URLforDocuments__c FROM nm_LinksForDocumentsLead__c WHERE nm_DocumentName__c='Aadhaar Card' AND Lead__c=:objLead.id];
        objLead.Differently_abled__c  = 'Yes';
        objLead.nm_Category__c = 'OBC';
        Test.startTest();
            DocumentHelperClass obj = new DocumentHelperClass();
        Test.StopTest();
    }
}