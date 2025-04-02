/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : @BK
**/
public class ResendEmailToPortalBatch implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts, Database.Stateful {
    
    // Constants for reusable values
    private static final String FROM_MAIL_ID = 'donotreply.cdoe@nmims.edu';
    private static final String TEMPLATE_NAME = 'Admission Confirmation';
    private static final String TYPE = 'what'; // For account

    public void execute(SchedulableContext sc){
        ResendEmailToPortalBatch b = new ResendEmailToPortalBatch();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id, nm_StudentNo__c, PersonEmail From Account WHERE nm_StudentNo__c != null and Synced_With_LDAP__c = true AND Account_Confirm_Date__c = TODAY';
        System.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> acclst) { 
        // Step 1: Collect account IDs to query API_Request__c
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : acclst) {
            if (acc.Id != null) {
                accountIds.add(acc.Id);
            }
        }
        
        // Step 2: Query all related API_Request__c records at once
        Map<Id, List<API_Request__c>> accountToApiRequestsMap = new Map<Id, List<API_Request__c>>();
        if (!accountIds.isEmpty()) {
            List<API_Request__c> apivalue = [SELECT Id, API_Name__c, Request__c, Response__c, Success__c, Account__c 
                                             FROM API_Request__c 
                                             WHERE Success__c = true 
                                             AND API_Name__c = 'SendEmailToPortal' 
                                             AND Account__c IN :accountIds];
            // Organize API_Request__c records by AccountId
            for (API_Request__c apiReq : apivalue) {
                if (!accountToApiRequestsMap.containsKey(apiReq.Account__c)) {
                    accountToApiRequestsMap.put(apiReq.Account__c, new List<API_Request__c>());
                }
                accountToApiRequestsMap.get(apiReq.Account__c).add(apiReq);
            }
        }

        // Step 3: Process each account
        for (Account acc : acclst) {
            // Check if email exists before sending
            if (String.isNotEmpty(acc.PersonEmail) && !accountToApiRequestsMap.containsKey(acc.Id)) {
                String sapId = acc.nm_StudentNo__c;
                String recordId = acc.Id;
                String toMailId = acc.PersonEmail;

                // Log for debugging purposes
                System.debug('Sending email for Account ID: ' + acc.Id + ' to: ' + toMailId);

                // Step 4: Call the web service to send the email
                try {
                    SendEmailToPortal.callWebService(TEMPLATE_NAME, recordId, TYPE, sapId, toMailId, FROM_MAIL_ID);
                } catch (Exception e) {
                    System.debug('Error sending email for Account ID: ' + acc.Id + ' : ' + e.getMessage());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Finished');
    }
}