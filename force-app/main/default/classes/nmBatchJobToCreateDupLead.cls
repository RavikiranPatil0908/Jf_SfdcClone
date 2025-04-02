// This Class is used to create Duplicate Lead Record in Duplicate Lead Obj and deletes the record from lead obj

public class nmBatchJobToCreateDupLead implements Database.Batchable<SObject>, Schedulable {

       public final string query;

       public nmBatchJobToCreateDupLead() {

            query = 'Select Id, Name, FirstName, LastName, Status, Email, MobilePhone, Agency__c, LeadSource, nm_IPForLead__c, OwnerId From Lead where Status = \'Duplicate\'';
       }    
        
      
       public void execute(SchedulableContext sc) {
            Database.executeBatch(this, 100);
       }
       

       public Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator(query);
       }

       public void execute(Database.BatchableContext bc, List<sObject> scope) {

           list<Duplicate_Lead__c> newDupObjects = new list<Duplicate_Lead__c>();

           for(Sobject s : scope){
               Lead obj = (Lead)s; //typecasting
               newDupObjects.add(new Duplicate_Lead__c(
                   nm_FirstName__c = obj.FirstName,
                   nm_LastName__c = obj.LastName,
                   Mobile_No__c = obj.MobilePhone,
                   Email__c = obj.Email,
                   Agency__c = obj.Agency__c,
                   Lead_Source__c = obj.LeadSource,
                   IP_For_Lead__c = obj.nm_IPForLead__c,
                   OwnerId = obj.OwnerId
               ));
           }
           insert newDupObjects;
           delete scope;

       }

       public void finish(Database.BatchableContext bc) {
          system.debug('SUCCESS');
       }

}