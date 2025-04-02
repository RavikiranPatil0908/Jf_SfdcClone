/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-19-2020   @BK   Initial Version
**/
public class CaptureLeadStatus implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Integer successCount = 0;
    public Integer failedCount = 0;
    public Integer totalCount = 0;
    
    public void execute(SchedulableContext sc) {
        CaptureLeadStatus b = new CaptureLeadStatus();
        Database.executebatch(b, 100);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){

        List<Integer> intervals = new List<integer>{7, 15, 30, 60, 90, 180};
        String query = 'SELECT id,Status_after_7_days__c,Status_after_15_days__c,Status_after_30_days__c,Status_after_60_days__c,Status,Status_after_90_days__c,';
        query = query + 'Status_after_180_days__c,Lead_Created_day__c FROM Lead WHERE IsConverted=false AND LeadSource!=\'Partner\' AND (';
        Integer loopCount = 0;
        Integer lstCount = intervals.size();
        System.debug('lstCount ==>'+lstCount);
        String partialQuery = '';
        for (Integer i : intervals) {
            loopCount++;
            partialQuery = partialQuery + '((Status_after_'+i+'_days__c=null OR Status_after_'+i+'_days__c=\'\') AND Lead_Created_day__c='+i+')';
            if(loopCount < lstCount) {
                partialQuery = partialQuery + ' OR ';
            }
        }
        query = query + partialQuery + ') ORDER BY Lead_Created_day__c ASC LIMIT 50000';
        System.debug('Query = '+query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 10-19-2020 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc,List<Lead> scope){ 
        List<Lead> lstLeadsToUpdate = new List<Lead>();
        for (Sobject s : scope) {
            Lead objLead = (Lead)s;
            Integer i = (Integer)objLead.Lead_Created_day__c;
            String field = 'Status_after_'+i+'_days__c';
            objLead.put(field,objLead.Status);
            lstLeadsToUpdate.add(objLead);
            totalCount++;
        }
        if(lstLeadsToUpdate.size() > 0) {
            try {
                Database.SaveResult[] srList = Database.update(lstLeadsToUpdate, false);
                for (Integer i = 0; i < lstLeadsToUpdate.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Lead origRecord = lstLeadsToUpdate[i];
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated Lead. Lead ID: ' + sr.getId());
                        successCount++;
                    } else {
                        System.debug('sr.getId() -->'+origRecord.id);
                        failedCount++;
                        // Operation failed, so get all errors.                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Lead fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            } catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
            }
        }
    }

    /**
    * @description 
    * @author @BK | 10-19-2020 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        System.debug('finished');
        if(totalCount > 0) {
            //Send an email to the User after your batch completes
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
            string[] toAddress = System.Label.setBccAdderess.split(','); 
            mail.setToAddresses(toAddress);
            mail.setSubject('Capture Lead Status Batch Process Completed');
            String mailBody = 'Hi Team,\n\n'+
            'Please find below records updated at Batch Process to Capture Lead Status:\n'+
            'Total Records Processed: ' +totalCount +'\n'+
            'Sucess Records: '+ successCount +'\n'+
            'Error Records: '+ failedCount +'\n\n'+
            'Thanks & Regards' +'\n'+
            'NMIMS CDOE';
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}