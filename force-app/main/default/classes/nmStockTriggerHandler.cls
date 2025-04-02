/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-02-2024
 * @last modified by  : @BK
**/
public class nmStockTriggerHandler {

    // public static boolean isAfterUpdateRunOnce = false;
    // public static boolean isBeforeUpdateRunOnce = false; 

    public void afterUpdate(List<Stock__c> triggerNew , Map<id,Stock__c> oldMap) {
        // if(isAfterUpdateRunOnce){
        //     return;
        // }
        // isAfterUpdateRunOnce = true;

        upsertStockLedger(triggerNew, oldMap, 'update');
    }

    public void afterInsert(List<Stock__c> triggerNew) {
        System.debug('Inside Afterinsert bulkified');

        upsertStockLedger(triggerNew, new Map<id,Stock__c>(), 'insert');
    }


    /**
    * @description 
    * @author @BK | 01-28-2024 
    * @param triggerNew 
    * @param oldMap 
    **/
    public void upsertStockLedger(List<Stock__c> triggerNew, Map<id,Stock__c> oldMap, String activity) {
        try {
            List<Id> lstSTKId = new List<Id>();
            for(Stock__c objSK : triggerNew) {
                if(activity == 'insert' || objSK.Quantity__c!=oldMap.get(objSK.Id).Quantity__c) {
                    lstSTKId.add(objSK.Id);
                } 
            }
            Map<Id,Stock_Ledger__c> mapOfIdVsSTKLedger = getSKL(lstSTKId);
            List<Stock_Ledger__c> lstSL = getStockLedger(activity,triggerNew,oldMap,mapOfIdVsSTKLedger);
            if(lstSL.size() > 0) {
                upsert lstSL;
            }
        } catch (Exception e) {
            System.debug('Error msg ==>'+e.getMessage());
            System.debug('Error Line no. ==>'+e.getLineNumber());
        }
    }

    /**
    * @description 
    * @author @BK | 01-28-2024 
    * @param lstSTKId 
    * @return Map<Id, Stock_Ledger__c> 
    **/
    public Map<Id,Stock_Ledger__c> getSKL(List<Id> lstSTKId) {
        Map<Id,Stock_Ledger__c> mapOfIdVsSTKLedger = new Map<Id,Stock_Ledger__c>();
        if(lstSTKId.size() > 0) {
            for (Stock_Ledger__c obj : [SELECT id,Entry_Date__c,Stock__c,
                Incoming_Quantity__c,Outgoing_Quantity__c,Quantity__c FROM Stock_Ledger__c WHERE 
                Entry_Date__c=TODAY AND Stock__c IN :lstSTKId]) {
                    mapOfIdVsSTKLedger.put(obj.Stock__c,obj);
            }

            for (Id stkId : lstSTKId) {
                if(!mapOfIdVsSTKLedger.containsKey(stkId)) {
                    Stock_Ledger__c obj = new Stock_Ledger__c(Entry_Date__c=System.today(),
                    Stock__c=stkId,Incoming_Quantity__c=0,Outgoing_Quantity__c=0,Quantity__c=0);
                    mapOfIdVsSTKLedger.put(stkId,obj);
                }
            }
        }

        return mapOfIdVsSTKLedger;
    }

    /**
    * @description 
    * @author @BK | 01-28-2024 
    * @param triggerNew 
    * @param oldMap 
    * @param mapOfIdVsSTKLedger 
    * @return List<Stock_Ledger__c> 
    **/
    public List<Stock_Ledger__c> getStockLedger(String activity, List<Stock__c> triggerNew, Map<id,Stock__c> oldMap, Map<Id,Stock_Ledger__c> mapOfIdVsSTKLedger) {
        List<Stock_Ledger__c> lstSL = new List<Stock_Ledger__c>();
        for (Stock__c objSK : triggerNew) {
            System.debug('Record Id ==>'+objSK.Id);
            if(activity == 'insert' || (objSK.Quantity__c!=oldMap.get(objSK.Id).Quantity__c && mapOfIdVsSTKLedger.containsKey(objSK.Id))) { 
                System.debug('Enterd if condition==>');
                Stock_Ledger__c objSL = mapOfIdVsSTKLedger.get(objSK.Id);
                objSL.Quantity__c = objSK.Quantity__c;
                if(activity == 'update') {
                    if(objSK.Quantity__c > oldMap.get(objSK.Id).Quantity__c) {
                        System.debug('Enterd In ward==>');
                        objSL.Incoming_Quantity__c = objSL.Incoming_Quantity__c + (objSK.Quantity__c - oldMap.get(objSK.Id).Quantity__c);
                    } else {
                        System.debug('Enterd Out ward==>');
                        objSL.Outgoing_Quantity__c = objSL.Outgoing_Quantity__c + (oldMap.get(objSK.Id).Quantity__c - objSK.Quantity__c);
                    }
                }
                lstSL.add(objSL);
            }
        }
        return lstSL;
    }

}