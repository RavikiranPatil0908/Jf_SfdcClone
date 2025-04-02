/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 09-25-2024
 * @last modified by  : @Ravi
**/
public with sharing class QuickSearchController {
    
    /**
    * @description 
    * @author @Ravi | 08-31-2024 
    * @param searchText 
    * @return List<RecordAccessWrapper> 
    **/
    @AuraEnabled(cacheable=true)
public static List<RecordAccessWrapper> searchRecords(String searchText) {
    String soslQuery = 'FIND \'' + String.escapeSingleQuotes(searchText) + '\' IN ALL FIELDS RETURNING ' +
                        'Lead(Id, Name, Email, nm_RegistrationNo__c, MobilePhone, nm_SecondryEmail__c, Phone WHERE ' +
                        'Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR Email LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR nm_RegistrationNo__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR MobilePhone LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR nm_SecondryEmail__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR Phone LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'), ' +

                        'Account(Id, Name, PersonEmail, nm_RegistrationNumber__c, PersonMobilePhone, nm_SecondryEmail__c, Phone WHERE ' +
                        'Name LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR PersonEmail LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR nm_RegistrationNumber__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR PersonMobilePhone LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR nm_SecondryEmail__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR Phone LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\'), ' +

                        'Partner_Lead__c(Id, First_Name__c, Last_Name__c, Email__c, MOBILEPHONE__c WHERE ' +
                        'First_Name__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR Last_Name__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR Email__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' ' +
                        'OR MOBILEPHONE__c LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\')';

    List<List<SObject>> searchResults = Search.query(soslQuery);
    System.debug('Search results ::::'+searchResults);

    List<SearchResultWrapper> allResults = new List<SearchResultWrapper>();
    List<Id> recordIds = new List<Id>();

    // Process the search results
    for (List<SObject> result : searchResults) {
        for (SObject sObj : result) {
            allResults.add(new SearchResultWrapper(sObj.Id, String.valueOf(sObj.getSObjectType()), sObj));
            recordIds.add(sObj.Id);
        }
    }

    System.debug('allResults ::: ' + allResults);
    return checkForRecordAssess(recordIds, allResults);
}

    /**
    * @description 
    * @author @Ravi | 08-31-2024 
    * @param recordIds 
    * @param allResults 
    * @return List<RecordAccessWrapper> 
    **/
    public static List<RecordAccessWrapper> checkForRecordAssess(List<Id> recordIds, List<SearchResultWrapper> allResults) {
        List<RecordAccessWrapper> accessibleRecords = new List<RecordAccessWrapper>();
        if(recordIds.isEmpty()) {
            return accessibleRecords;
        }

        if (!recordIds.isEmpty()) {
            List<UserRecordAccess> accessRecords = [
                SELECT RecordId 
                FROM UserRecordAccess 
                WHERE UserId = :UserInfo.getUserId() 
                AND HasReadAccess = true 
                AND RecordId IN :recordIds
            ];
            
            List<Id> accessibleRecordIds = new List<Id>();
            for (UserRecordAccess accessRecord : accessRecords) {
                accessibleRecordIds.add(accessRecord.RecordId);
            }
    
            for (SearchResultWrapper resultWrapper : allResults) {
                if (accessibleRecordIds.contains(resultWrapper.recordId)) {
                    accessibleRecords.add(new RecordAccessWrapper(resultWrapper.objectType, resultWrapper.record));
                }
            }
        }
        System.debug('Found Accessible Records:::::::::::: ' + accessibleRecords);
        return accessibleRecords;
    }

 
    public class SearchResultWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String objectType;
        @AuraEnabled public SObject record;

        public SearchResultWrapper(Id recordId, String objectType, SObject record) {
            this.recordId = recordId;
            this.objectType = objectType;
            this.record = record;
        }
    }
 
    public class RecordAccessWrapper {
        @AuraEnabled public String objectType;
        @AuraEnabled public SObject record;
        
        public RecordAccessWrapper( String objectType, SObject record) {
            this.objectType = objectType;
            this.record = record;
        }
    }
}