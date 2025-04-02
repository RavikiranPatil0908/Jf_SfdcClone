/**
 * @File Name          : ArchiveLinkForDocuments.cls
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-05-2021
 * @last modified by  : @BK
**/
public without sharing class ArchiveLinkForDocuments implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful { 
    
    public void execute(SchedulableContext sc) {
        ArchiveLinkForDocuments b = new ArchiveLinkForDocuments();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        String filter = System.Label.Archive_Query_Filter;

        String query = 'SELECT Id FROM Account WHERE ' + filter;
        System.debug('Query = '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<String> lstAccountId = new List<String>();
        Map<Id,List<nm_LinksForDocuments__c>> mapOfAccountVsDocuments = new Map<Id,List<nm_LinksForDocuments__c>>();
        List<Archived_Document__b> lstArchiveDocuments = new List<Archived_Document__b>();

        for (Sobject s : scope) {
            Account objAccount = (Account)s;
            lstAccountId.add(objAccount.Id);
        }

        List<nm_LinksForDocuments__c> lstOfDocuments = [SELECT Id,Name,nm_URLforDocuments__c,nm_Status__c,nm_Account__c FROM nm_LinksForDocuments__c WHERE nm_Account__c IN :lstAccountId ORDER BY Name];
        for (nm_LinksForDocuments__c objDocument : lstOfDocuments) {
            List<nm_LinksForDocuments__c> lstDocs = mapOfAccountVsDocuments.containsKey(objDocument.nm_Account__c) 
                ? mapOfAccountVsDocuments.get(objDocument.nm_Account__c) : new List<nm_LinksForDocuments__c>();
            lstDocs.add(objDocument);
            mapOfAccountVsDocuments.put(objDocument.nm_Account__c,lstDocs);
        }

        for(Id key : mapOfAccountVsDocuments.keySet()) {
            List<nm_LinksForDocuments__c> lstDocs = mapOfAccountVsDocuments.get(key);
            Archived_Document__b objDoc = new Archived_Document__b();
            objDoc.Account__c = key;
            Integer i = 1;
            for(nm_LinksForDocuments__c objLinksForDocuments :lstDocs) {
                objDoc.put('Document_Name_'+i+'__c',objLinksForDocuments.Name);
                objDoc.put('URL_for_Documents'+i+'__c',objLinksForDocuments.nm_URLforDocuments__c);
                objDoc.put('Document_Status_'+i+'__c',objLinksForDocuments.nm_Status__c);
                i++;
            }
            System.debug(objDoc);
            lstArchiveDocuments.add(objDoc);
        }

        if(lstArchiveDocuments.size() > 0) {
            system.debug('lstArchiveDocuments ---> ' + lstArchiveDocuments);
            if(!Test.isRunningTest()){
                Database.insertImmediate(lstArchiveDocuments);
            } 
            system.debug('lstArchiveDocuments ---> ' + lstArchiveDocuments);
            List<nm_LinksForDocuments__c> lstOfDocsTobeDeleted = new List<nm_LinksForDocuments__c>();
            for(Archived_Document__b objDocs :lstArchiveDocuments) {
                lstOfDocsTobeDeleted.addAll(mapOfAccountVsDocuments.get(objDocs.Account__c));
            }

            if(lstOfDocsTobeDeleted.size() > 0) {
                deleteLinkForDocument(lstOfDocsTobeDeleted);
            }
        }
    }

    public void finish(Database.BatchableContext bc) { 
        System.debug('Finished');
    }

    public void deleteLinkForDocument(list<nm_LinksForDocuments__c> docsToDelete) {
        try {
            Set<String> lstFailedRecords = new Set<String>();
            Set<String> lstSuccessRecords = new Set<String>();
            Database.DeleteResult[] srList = Database.delete(docsToDelete, false);
            for (Integer i = 0; i < docsToDelete.size(); i++) {
                Database.DeleteResult sr = srList[i];
                nm_LinksForDocuments__c origRecord = docsToDelete[i];
                if (sr.isSuccess()) {
                    lstSuccessRecords.add(origRecord.Id);
                } else {
                    lstFailedRecords.add(origRecord.id);
                }
            }
            System.debug('lstSuccessRecords ==>'+lstSuccessRecords.size());
            System.debug('lstFailedRecords ==>'+lstFailedRecords.size());
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }
}