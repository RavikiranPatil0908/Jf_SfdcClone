/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : @BK
**/
public class BatchClassForStockLedger implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public void execute(SchedulableContext sc) {
        BatchClassForStockLedger b = new BatchClassForStockLedger();
        Database.executebatch(b, 200);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT Id,Quantity__c FROM Stock__c WHERE IsActive__c=TRUE';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Stock__c> lstSTK) { 
        List<Id> lstOfSTKId = new List<Id>();
        for (Stock__c obj : lstSTK) {
            lstOfSTKId.add(obj.Id);
        }
        Map<Id,Stock_Ledger__c> mapOfSTKIdVsSTL = new Map<Id,Stock_Ledger__c>();
        for (Stock_Ledger__c objSTL : [SELECT Id,Stock__c,Quantity__c FROM Stock_Ledger__c WHERE Stock__c IN :lstOfSTKId AND Entry_Date__c=TODAY]) {
            mapOfSTKIdVsSTL.put(objSTL.Stock__c,objSTL);
        }
        List<Stock_Ledger__c> lstSTLToInsert = new List<Stock_Ledger__c>();
        for (Stock__c obj : lstSTK) {
            if(!mapOfSTKIdVsSTL.containsKey(obj.Id)) {
                Stock_Ledger__c objSTL = new Stock_Ledger__c(Entry_Date__c=System.today(),
                Stock__c=obj.Id,Incoming_Quantity__c=0,Outgoing_Quantity__c=0,Quantity__c=obj.Quantity__c);
                lstSTLToInsert.add(objSTL);
            }
        }

        if(lstSTLToInsert.size() > 0) {
            insert lstSTLToInsert;
        }
    }

    public void finish(Database.BatchableContext bc) { 
        System.debug('Finished');
    }
}