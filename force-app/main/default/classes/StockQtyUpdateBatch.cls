/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-22-2021   shubhranshu   Initial Version
**/
public with sharing class StockQtyUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful  {
    public void execute(SchedulableContext sc) {
        StockQtyUpdateBatch b = new StockQtyUpdateBatch();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('StockQtyUpdateBatch started');
        String query = 'select id ,Quantity__c,Stock_Quantity_history__c,Centers__c from Stock__c where Quantity__c > 0';
        System.debug('query '+query); 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) { 
        set<String> SetofStockIds = new set<String>();
        if(scope.size() > 0) {
            for(SObject sc : scope){
                Stock__c st = (Stock__c)sc;
                SetofStockIds.add(st.id);
            }
            List<Stock__c> lstStock = [SELECT Id,Quantity__c,Stock_Quantity_history__c from Stock__c WHERE Id in:SetofStockIds ORDER By CreatedDate desc];
            List<Stock__c> updatelstStock = new List<Stock__c>();

            System.debug('lstStock '+lstStock);
            if(lstStock.size()>0){
                for(Stock__c st: lstStock){
                    st.Stock_Quantity_history__c = String.isNotBlank(st.Stock_Quantity_history__c) ? st.Quantity__c +' update on '+date.today().format() + '<br>' + st.Stock_Quantity_history__c : st.Quantity__c +' update on '+date.today().format(); 
                    updatelstStock.add(st);
                } 
            }

            if(updatelstStock.size()>0){
                System.debug('updatelstStock '+updatelstStock);
                try {
                    update updatelstStock;
                } catch (DMLException e) {
                    System.debug('error '+e.getMessage());
                }
            }
        } else {
            System.debug('No records found.');
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finish Method Execute');
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,     JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:bc.getJobId()];
        
        OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE'LIMIT 1 ];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('StockQtyUpdateBatch ' + a.Status);
        mail.setOrgWideEmailAddressId(owe.id);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +
        'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}