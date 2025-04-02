/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-06-2021
 * @last modified by  : @BK
**/
public class InsertLinkForDocuments implements Queueable, Database.AllowsCallouts {
    private String jsonOfAccountId;
    private String jsonOfAccountIdVsLeadId;

    public insertLinkForDocuments(String jsonOfAccountId,String jsonOfAccountIdVsLeadId) {
        this.jsonOfAccountId = jsonOfAccountId;
        this.jsonOfAccountIdVsLeadId = jsonOfAccountIdVsLeadId;
    }

    public void execute(QueueableContext context) {
        List<nm_LinksForDocumentsLead__c> lstDocumentLeadToInsert = new List<nm_LinksForDocumentsLead__c>();
        Set<String> setOfAccountId = (Set<String>)JSON.deserialize(jsonOfAccountId, Set<String>.class);
        Map<String,String> mapOfAccountIdVsLeadId = (Map<String,String>)JSON.deserialize(jsonOfAccountIdVsLeadId, Map<String,String>.class);
        String query = 'SELECT id,Account__c';
        String subQuery = '';
        for (Integer i = 1; i <= 20; i++) {
            subQuery +=  ',Document_Name_'+i+'__c,Document_Status_'+i+'__c,URL_for_Documents'+i+'__c';
        }
        query = query + subQuery + ' FROM Archived_Document__b WHERE Account__c IN :setOfAccountId';
        List<Archived_Document__b> lstOfLinkOfDocs = DataBase.query(query);
        for (Archived_Document__b objDoc : lstOfLinkOfDocs) {
            for (Integer i = 1; i <= 20; i++) {
                if(objDoc.get('Document_Name_'+i+'__c') != null) {
                    String docName = (String)objDoc.get('Document_Name_'+i+'__c');
                    Boolean skipDocument = (docName=='Photo ID proof' || docName=='Student Photograph') ? true : false;
                    nm_LinksForDocumentsLead__c objLeadDoc = new nm_LinksForDocumentsLead__c ();
                    objLeadDoc.nm_DocumentName__c = docName;
                    objLeadDoc.Name = (String)objDoc.get('Document_Name_'+i+'__c');
                    objLeadDoc.nm_URLforDocuments__c = skipDocument ? '' : (String)objDoc.get('URL_for_Documents'+i+'__c');
                    objLeadDoc.nm_Status__c = skipDocument ? '' : (String)objDoc.get('Document_Status_'+i+'__c');
                    objLeadDoc.Lead__c = mapOfAccountIdVsLeadId.get(objDoc.Account__c);
                    lstDocumentLeadToInsert.add(objLeadDoc);
                }
            }
        }
        System.debug(lstDocumentLeadToInsert);
        if(lstDocumentLeadToInsert.size() > 0) {
            List<nm_LinksForDocuments__c> lstOfDocuments = [SELECT Id,Name,nm_URLforDocuments__c,nm_Status__c,nm_Account__c FROM nm_LinksForDocuments__c WHERE nm_Account__c IN :setOfAccountId];
            try{
                insert lstDocumentLeadToInsert;
                if(lstOfDocuments.size() > 0) {
                   delete lstOfDocuments;
                }
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }
}