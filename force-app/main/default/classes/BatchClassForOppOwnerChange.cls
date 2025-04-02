/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public with sharing class BatchClassForOppOwnerChange implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    public List<String> interviewSlotIds = new List<String>();
    public Set<String> lstFailedRecords;
    public Set<String> lstSuccessRecords;
    public Integer successCount = 0;
    public Integer failedCount = 0;
    public Integer totalCount = 0;
     public void execute(SchedulableContext sc) {
        BatchClassForOppOwnerChange b = new BatchClassForOppOwnerChange();
        Database.executebatch(b, 200);
    }

       public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('OppOwnerChangeClass Batch Class Started');
        DateTime myDateTime = DateTime.now();

        DateTime last3DayLead = DateTime.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day() -3 , 0, 0, 0);
        Date last3Day = last3DayLead.date();
        
        String query ='';
        if(!Test.isRunningTest()) {
        //     query = 'SELECT id FROM Interview_Slot__c WHERE Interview_Date__c >= :last3Day AND Send_Interview_Batch__c = false AND Program_Type__c = \'MBA (WX)\' AND Id In (SELECT Interview_Slot__c FROM Account) ' ;
               query = 'SELECT id, OwnerId ,Account.OwnerId FROM Opportunity WHERE OpportunityOwnerId__c=true AND Account.User_IsActive__c =true Order by CreatedDate DESC limit 9999' ;
    } else {
            query = 'SELECT id,Account.OwnerId ,AccountID FROM Opportunity  Order by CreatedDate limit 1' ;
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
         List<Opportunity> OppOwnerChange = new List<Opportunity>();
        for(SObject sc : scope){
            Opportunity ChangeOwner = (Opportunity)sc;
            Opportunity updateOwner = new Opportunity();
                updateOwner.Id = ChangeOwner.Id;
                updateOwner.OwnerId = ChangeOwner.Account.OwnerId;
                OppOwnerChange.add(updateOwner);
                  totalCount++;

            
        }
        if(OppOwnerChange.size() > 0) {
            try {
                lstFailedRecords = new Set<String>();
                lstSuccessRecords = new Set<String>();
                Database.SaveResult[] srList = Database.update(OppOwnerChange, false);
                for (Integer i = 0; i < OppOwnerChange.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Opportunity origRecord = OppOwnerChange[i];
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        lstSuccessRecords.add(origRecord.Id);
                        System.debug('Successfully updated Opportunity Owner ID: ' + sr.getId());
                         successCount++;
        
                    } else {
                        System.debug('sr.getId() -->'+origRecord.id);
                        lstFailedRecords.add(origRecord.id);
                        failedCount++;
                        // Operation failed, so get all errors.                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Opportunity fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
         catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
             }
        }
    }


    public void finish(Database.BatchableContext bc) {
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
            sendErrorMail();
        }
    }

       public void sendErrorMail() {
        String recordList = '';
        if(lstFailedRecords!=null && lstFailedRecords.size()>0)
        {
            for(String s: lstFailedRecords) {
            recordList += (recordList==''?'':',\n')+s;
        }
        
        }
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        string[] toAddress = System.Label.setBccAdderess.split(','); 
      //  String[] sendingToAddress = new List<String>();
        // string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('Course Sync Error Mail');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below SendCourseListBatch Class Error:\n'+
        'Here are the lists of failed records List:\n'+
          recordList +'\n\n'+
        'Total Records Processed: ' +totalCount +'\n'+
        'Sucess Records: '+ successCount +'\n'+
        'Error Records: '+ failedCount +'\n\n'+
       
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

     
    }
}