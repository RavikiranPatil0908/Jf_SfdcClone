/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-05-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-27-2020   @BK   Initial Version
**/
public class AepSiteInspectionTriggerHandler {

    public static boolean IsAfterInsertRunOnce = false;
    public static boolean IsAfterUpdateRunOnce = false;
    DocumentHelperClass documentHelper = new DocumentHelperClass();

    public AepSiteInspectionTriggerHandler() {
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitQueryRows());
        System.debug('Total Number of records that can be queriedxc  in this Apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() );
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime());
        System.debug('Total Number of Future Call allowed in this Apex code context: ' +  Limits.getLimitFutureCalls());
    }

    public void AfterInsert(list<AEP_site_inspection__c> triggerNew, map<id,AEP_site_inspection__c> triggernewmap, map<id, AEP_site_inspection__c> triggerOldMap){ 
        if(IsAfterInsertRunOnce){
            return;
        }
        IsAfterInsertRunOnce = true;

        CreateDocumentRecordsOnLead(triggerNew);

        updateSiteInspectionOwner(triggerNew);

        System.debug('-------------------------------After Insert-------------------------------');
        System.debug('1. Number of Queries used in this Apex code so far : ' + Limits.getQueries());
        System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
        System.debug('3. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
        System.debug('4. Number of DML statements used so far: ' +  Limits.getDmlStatements());    
        System.debug('5. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
        System.debug('6. Number of Future Call used so far: ' + Limits.getFutureCalls());
        
    }

    public void AfterUpdate(list<AEP_site_inspection__c> triggerNew, map<id,AEP_site_inspection__c> triggernewmap, map<id,AEP_site_inspection__c> triggerOldMap){
        if(IsAfterUpdateRunOnce){
            return;
        }
        IsAfterUpdateRunOnce = true;

        UpdateDocumentsForChangeInEntity(triggerNew,triggerOldMap);

        updateSiteInspectionOwner(triggerNew);


        System.debug('-------------------------------After Update-------------------------------');
        System.debug('1. Number of Queries used in this Apex code so far : ' + Limits.getQueries());
        System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
        System.debug('3. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
        System.debug('4. Number of DML statements used so far: ' +  Limits.getDmlStatements());    
        System.debug('5. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
        System.debug('6. Number of Future Call used so far: ' + Limits.getFutureCalls());
    }


    /**
    * @description 
    * @author @BK | 10-30-2020 
    * @param listOfAepSiteInspection 
    **/
    public void CreateDocumentRecordsOnLead(List<AEP_site_inspection__c> listOfAepSiteInspection) {
        Map<String, Set<String>> mapCriteriaDocuments = getCriteriaDocuments(null);
        //Document list to insert  
        List<nm_LinksForDocumentsLead__c> lstDocuments = new List<nm_LinksForDocumentsLead__c>();
        for(AEP_site_inspection__c objRecord : listOfAepSiteInspection) {
            String entity = objRecord.Entity__c;
            if(String.isNotBlank(entity) && mapCriteriaDocuments.containsKey(entity)) {
                //Creating document records to insert.
                for(String strDocName : mapCriteriaDocuments.get(entity)) { 
                    if(String.isNotBlank(strDocName)) {
                        nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
                        objDocument.name = strDocName.trim();
                        objDocument.nm_DocumentName__c = strDocName.trim();
                        objDocument.AEP_site_inspection__c = objRecord.Id;
                        objDocument.AEP_User_Email_Address__c = objRecord.User_Email__c;
                        objDocument.LC_Email_Address__c = objRecord.Owner_Email_Address__c;
                        lstDocuments.add(objDocument);
                    }
                }
            }
        }

        //Inserting document list
        if(lstDocuments.size() > 0)
            insert lstDocuments;
    }

    /**
    * @description 
    * @author @BK | 10-28-2020 
    * @param listOfAepSiteInspection 
    * @param oldMapOfAepSiteInspection 
    **/
    public void UpdateDocumentsForChangeInEntity(List<AEP_site_inspection__c> listOfAepSiteInspection , Map<id,AEP_site_inspection__c> oldMapOfAepSiteInspection) {
        Map<String,List<nm_LinksForDocumentsLead__c>> mapofDocuments = new Map<String,List<nm_LinksForDocumentsLead__c>>();
        Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
        Set<String> setOfEntity = new Set<String>();
        Map<Id,AEP_site_inspection__c> mapOfIdvsAepSiteInspection = new Map<Id,AEP_site_inspection__c>();
        List<nm_LinksForDocumentsLead__c> lstDocumentsInsert = new List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocumentsLead__c> lstDocumentsDelete = new List<nm_LinksForDocumentsLead__c>();

        for(AEP_site_inspection__c objRecord : listOfAepSiteInspection) {
            System.debug('objRecord.Entity__c in after update'+objRecord.Entity__c + ' ==> '+ oldMapOfAepSiteInspection.get(objRecord.id).Entity__c);
            if(String.isNotBlank(objRecord.Entity__c) && objRecord.Entity__c != oldMapOfAepSiteInspection.get(objRecord.id).Entity__c && String.isBlank(objRecord.Centers__c)) {
                setOfEntity.add(objRecord.Entity__c);
                mapOfIdvsAepSiteInspection.put(objRecord.Id,objRecord);
            }
        }

        System.debug('setOfEntity size ==>'+setOfEntity.size());
        if(setOfEntity.size() > 0) {
            mapCriteriaDocuments = getCriteriaDocuments(setOfEntity);
            mapofDocuments = getDocumentsToProcess(mapCriteriaDocuments, mapOfIdvsAepSiteInspection);
            if(!mapofDocuments.isEmpty()){
                if(mapofDocuments.containsKey('INSERT')){
                    lstDocumentsInsert.addAll(mapofDocuments.get('INSERT'));
                }
                if(mapofDocuments.containsKey('DELETE')){
                    lstDocumentsDelete.addAll(mapofDocuments.get('DELETE'));
                }
            }
        }
        // delete the documents if not need
        System.debug('lstDocumentsDelete '+lstDocumentsDelete);
        if(lstDocumentsDelete.size() > 0){
            documentHelper.documentNeedToDelete(lstDocumentsDelete);
        }

        // update documents on the basis of eligiblity criteria
        System.debug('lstDocumentsInsert --->'+lstDocumentsInsert);
        if(lstDocumentsInsert.size() > 0){
            documentHelper.insertDocumentsAfterUpdate(lstDocumentsInsert);
        }
    }


    /**
    * @description 
    * @author @BK | 10-28-2020 
    * @param setOfEntity 
    * @return Map<String, Set<String>> 
    **/
    public Map<String, Set<String>> getCriteriaDocuments(Set<String> setOfEntity) {
        Map<String, Set<String>> mapCriteriaDocuments =  new Map<String, Set<String>>();
        List<Entity_Setting__mdt> lstEntitySettings = new List<Entity_Setting__mdt>();
        if(setOfEntity!=null && setOfEntity.size() > 0) {
            lstEntitySettings = [SELECT id,Label,DeveloperName,List_of_documents__c FROM Entity_Setting__mdt WHERE Label IN :setOfEntity];
        } else {
            lstEntitySettings = [SELECT id,Label,DeveloperName,List_of_documents__c FROM Entity_Setting__mdt];
        }
        
        for(Entity_Setting__mdt objRd : lstEntitySettings) {
            String documents = objRd.List_of_documents__c;
            Set<String> setOfDocuments = new Set<String>();
            for(String doc : documents.split(';')) {
                if(String.isNotBlank(doc)) {
                    setOfDocuments.add(doc.trim());
                }
            }
            mapCriteriaDocuments.put(objRd.Label,setOfDocuments);
        }
        return mapCriteriaDocuments;
    }

    /**
    * @description 
    * @author @BK | 10-28-2020 
    * @param mapCriteriaDocuments 
    * @param mapOfIdvsAepSiteInspection 
    * @return Map<String, List<nm_LinksForDocumentsLead__c>> 
    **/
    public Map<String,List<nm_LinksForDocumentsLead__c>> getDocumentsToProcess(
        Map<String, Set<String>> mapCriteriaDocuments,
        Map<Id,AEP_site_inspection__c> mapOfIdvsAepSiteInspection) 
    {
        // map of existing Document record
        Map<Id,List<nm_LinksForDocumentsLead__c>> mapOfexistingDocsRecord = new Map<Id, List<nm_LinksForDocumentsLead__c>>();
        // map of existing Documents
        Map<Id,Set<string>> mapOfexistingDocs = new Map<Id, Set<String>>(); 
        //map of Documents to insert and delete
        Map<String,List<nm_LinksForDocumentsLead__c>> mapofDocuments = new Map<String,List<nm_LinksForDocumentsLead__c>>();

        List<nm_LinksForDocumentsLead__c> lstDocuments = new List<nm_LinksForDocumentsLead__c>();
        // List<nm_LinksForDocumentsLead__c> lstDocumentsToDelete = new List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocumentsLead__c> docNeedToDelete = new List<nm_LinksForDocumentsLead__c>();
        Map<Id,Set<string>> documentsForNewEntity = new Map<Id,Set<string>>();
        if(mapCriteriaDocuments.size() > 0 && mapOfIdvsAepSiteInspection.size() > 0) {
            //fetch all document Already Inserted for current AepSiteInspection 
            List<nm_LinksForDocumentsLead__c> oldDocuments = [SELECT id,nm_DocumentName__c,nm_DocumentLink__c,Documents_Submited_Date__c,linkID__c,nm_ReasonforDisapprove__c,nm_Status__c,nm_URLforDocuments__c,AEP_site_inspection__c,AEP_User_Email_Address__c,LC_Email_Address__c FROM nm_LinksForDocumentsLead__c WHERE AEP_site_inspection__c IN : mapOfIdvsAepSiteInspection.keySet()];
            if(oldDocuments.size() > 0) {
                for(nm_LinksForDocumentsLead__c oldDoc : oldDocuments) {
                    // For Document Name
                    Set<String> setOfDocs = mapOfexistingDocs.containsKey(oldDoc.AEP_site_inspection__c) ? mapOfexistingDocs.get(oldDoc.AEP_site_inspection__c) : new Set<String>();
                    setOfDocs.add(oldDoc.nm_DocumentName__c);
                    mapOfexistingDocs.put(oldDoc.AEP_site_inspection__c,setOfDocs);

                    // For Document Record
                    List<nm_LinksForDocumentsLead__c> setOfDocsRecord = mapOfexistingDocsRecord.containsKey(oldDoc.AEP_site_inspection__c) ? mapOfexistingDocsRecord.get(oldDoc.AEP_site_inspection__c) : new List<nm_LinksForDocumentsLead__c>();
                    setOfDocsRecord.add(oldDoc);
                    mapOfexistingDocsRecord.put(oldDoc.AEP_site_inspection__c,setOfDocsRecord);
                    
                }
            }

            //Fetch Document according to new criteria
            for(AEP_site_inspection__c objRd :mapOfIdvsAepSiteInspection.values()){
                if(String.isNotBlank(objRd.Entity__c)){
                    documentsForNewEntity.put(objRd.Id,mapCriteriaDocuments.get(objRd.Entity__c));
                }  
            }

            if(documentsForNewEntity.size() > 0){  
                //Creating document records to insert.
                for(string inspectionId : documentsForNewEntity.keySet())
                {
                    Set<String> strDocumentName = documentsForNewEntity.get(inspectionId) != null ? documentsForNewEntity.get(inspectionId) : new Set<String>();
                    Set<String> existDocumentName = mapOfexistingDocs.get(inspectionId) != null ? mapOfexistingDocs.get(inspectionId) : new Set<String>();

                    // existing record to delete if it is not eligible for eligible criteria 
                    List<nm_LinksForDocumentsLead__c> existDocumentRecord = mapOfexistingDocsRecord.get(inspectionId) != null ? mapOfexistingDocsRecord.get(inspectionId) : new List<nm_LinksForDocumentsLead__c>();
                    List<String> docNeedToInsert = documentHelper.checkContains(existDocumentName,strDocumentName);
                    if(docNeedToInsert.size() > 0){
                        for(String strDocName : docNeedToInsert){ 
                            if(String.isNotBlank(strDocName)) {
                                nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c();
                                objDocument.name = strDocName;
                                objDocument.nm_DocumentName__c = strDocName;
                                objDocument.AEP_site_inspection__c = inspectionId;
                                objDocument.AEP_User_Email_Address__c = mapOfIdvsAepSiteInspection.get(inspectionId).User_Email__c;
                                objDocument.LC_Email_Address__c = mapOfIdvsAepSiteInspection.get(inspectionId).Owner_Email_Address__c;
                                lstDocuments.add(objDocument);
                            }     
                        }
                    }

                    // for deleting the old docs which is not required
                    List<nm_LinksForDocumentsLead__c> docNeedToDeleteCheck = documentHelper.checkDocToDelete(strDocumentName,existDocumentRecord);
                    if(docNeedToDeleteCheck.size() > 0) {
                        docNeedToDelete.addAll(docNeedToDeleteCheck);
                    }
                }
            }
        }

        mapofDocuments.put('INSERT',lstDocuments);
        mapofDocuments.put('DELETE',docNeedToDelete);
        
        return mapofDocuments;
    }


    public void updateSiteInspectionOwner(List<AEP_site_inspection__c> listOfAepSiteInspection) {

        Set<Id> lstLcId = new Set<Id>();
        List<AEP_site_inspection__c> lstAepSiteInspection = new List<AEP_site_inspection__c>();
        for(AEP_site_inspection__c objAEPSiteIn :listOfAepSiteInspection) {
            if(String.isNotBlank(objAEPSiteIn.Learning_Center__c)) {
                lstLcId.add(objAEPSiteIn.Learning_Center__c);
            }
        }
        Map<ID,nm_Centers__c> mapOfCenter = new Map<ID,nm_Centers__c>([Select Id, OwnerId From nm_Centers__c Where Id IN :lstLcId]);
        for(AEP_site_inspection__c objAEPSite :listOfAepSiteInspection) {
            if(mapOfCenter.containsKey(objAEPSite.Learning_Center__c)) {
                AEP_site_inspection__c upAEPSite = new AEP_site_inspection__c();
                upAEPSite.Id = objAEPSite.Id;
                upAEPSite.OwnerId = mapOfCenter.get(objAEPSite.Learning_Center__c).OwnerId;
                lstAepSiteInspection.add(upAEPSite);
            }
        }

        if(lstAepSiteInspection.size() > 0) {
            update lstAepSiteInspection;
        }
    }
}