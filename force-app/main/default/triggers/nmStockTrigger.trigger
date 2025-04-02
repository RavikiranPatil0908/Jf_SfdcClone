/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-28-2024
 * @last modified by  : @BK
**/
trigger nmStockTrigger on Stock__c (before insert, before update, after insert, after update) {

    nmStockTriggerHandler handler = new nmStockTriggerHandler();

    if(trigger.isAfter){
        if(trigger.isUpdate) {
            handler.afterUpdate(trigger.New,trigger.oldmap);
        } 
        else if(trigger.isInsert){
            handler.afterinsert(trigger.New);
        }
    }

    // if(trigger.isafter && trigger.isupdate) {

    //     List<Id> lstSTKId = new List<Id>();

    //     for(Stock__c objSK : trigger.New) {
    //         if(objSK.Quantity__c!=trigger.oldmap.get(objSK.Id).Quantity__c) {
    //             lstSTKId.add(objSK.Id);
    //         }
    //     }

    //     Map<Id,Stock_Ledger__c> mapOfIdVsSTKLedger = new Map<Id,Stock_Ledger__c>();
    //     for (Stock_Ledger__c obj : [SELECT id,Entry_Date__c,Stock__c,
    //         Incoming_Quantity__c,Outgoing_Quantity__c,Quantity__c FROM Stock_Ledger__c WHERE 
    //         Entry_Date__c=TODAY AND Stock__c IN :lstSTKId]) {
    //             mapOfIdVsSTKLedger.put(obj.Stock__c,obj);
    //     }

    //     for (Id stkId : lstSTKId) {
    //         if(!mapOfIdVsSTKLedger.containsKey(stkId)) {
    //             Stock_Ledger__c obj = new Stock_Ledger__c(Entry_Date__c=System.today(),
    //             Stock__c=stkId,Incoming_Quantity__c=0,Outgoing_Quantity__c=0,Quantity__c=0);
    //             mapOfIdVsSTKLedger.put(stkId,obj);
    //         }
    //     }

    //     List<Stock_Ledger__c> lstSL = new List<Stock_Ledger__c>();
    //     for (Stock__c objSK : trigger.New) {
    //         System.debug('Record Id ==>'+objSK.Id);
    //         if(objSK.Quantity__c!=trigger.oldmap.get(objSK.Id).Quantity__c && mapOfIdVsSTKLedger.containsKey(objSK.Id)) { 
    //             System.debug('Enterd if condition==>');
    //             Stock_Ledger__c objSL = mapOfIdVsSTKLedger.get(objSK.Id);
    //             objSL.Quantity__c = objSK.Quantity__c;
    //             if(objSK.Quantity__c > trigger.oldmap.get(objSK.Id).Quantity__c) {
    //                 System.debug('Enterd In ward==>');
    //                 objSL.Incoming_Quantity__c = objSL.Incoming_Quantity__c + (objSK.Quantity__c - trigger.oldmap.get(objSK.Id).Quantity__c);
    //             } else {
    //                 System.debug('Enterd Out ward==>');
    //                 objSL.Outgoing_Quantity__c = objSL.Outgoing_Quantity__c + (trigger.oldmap.get(objSK.Id).Quantity__c - objSK.Quantity__c);
    //             }
    //             lstSL.add(objSL);
    //         }
    //     }

    //     upsert lstSL;
    // } 
}