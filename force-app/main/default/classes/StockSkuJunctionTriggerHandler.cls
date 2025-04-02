/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 27-02-2024
 * @last modified by  : @BK
**/
public class StockSkuJunctionTriggerHandler {

    public static boolean isAfterUpdateRunOnce = false;

    public void afterUpdate(List<StockSkuJunction__c> triggerNew, Map<id,StockSkuJunction__c> triggerNewMap, Map<id, StockSkuJunction__c> triggerOldMap){ 
        if(isAfterUpdateRunOnce){
            return;
        }

        isAfterUpdateRunOnce = true;

        // To Calculate the final Order
        calcFinalOrder(triggerNew,triggerOldMap);
        
    }

    /**
    * @description 
    * @author @BK | 16-02-2024 
    * @param List<StockSkuJunction__c> triggerNew 
    * @param Map<id StockSkuJunction__c> triggerOldMap 
    **/
    public void calcFinalOrder(List<StockSkuJunction__c> triggerNew, Map<id, StockSkuJunction__c> triggerOldMap) {
        List<Id> lstStockSKUId = new List<Id>();
        for (StockSkuJunction__c obj : triggerNew) {
            if((obj.Base_Count__c!=triggerOldMap.get(obj.Id).Base_Count__c || obj.Assumption__c!=triggerOldMap.get(obj.Id).Assumption__c || obj.Buffer__c!=triggerOldMap.get(obj.Id).Buffer__c) &&
                obj.Base_Count__c!=null && obj.Assumption__c!=null) {
                lstStockSKUId.add(obj.Id);
            }
        }

        if(lstStockSKUId.size() > 0) {
            Set<Id> setOfBookStockIds = new Set<Id>();
            List<Book_SKU_Junction__c> lstJunctionForBookStock = [SELECT Id,Book_Stock_Junction__c FROM Book_SKU_Junction__c WHERE StockSkuJunction__c IN :lstStockSKUId];
            System.debug('lstJunctionForBookStock ==>'+lstJunctionForBookStock.size());
            for (Book_SKU_Junction__c obj : lstJunctionForBookStock) {
                setOfBookStockIds.add(obj.Book_Stock_Junction__c);
            }
            System.debug('setOfBookStockIds ==>'+setOfBookStockIds.size());
            System.debug('setOfBookStockIds ==>'+setOfBookStockIds);
            
            Map<Id,Book_Stock__c> mapOfBookSKUToUpdate = setBookStockToUpdate(setOfBookStockIds);

            if(mapOfBookSKUToUpdate.size() > 0) {
                System.debug('mapOfBookSKUToUpdate Size ==>'+mapOfBookSKUToUpdate.size());
                update mapOfBookSKUToUpdate.values();
            }
        }
    }

    /**
    * @description 
    * @author @BK | 17-02-2024 
    * @param Set<Id> setOfBookStockIds 
    * @return Map<Id, Book_Stock__c> 
    **/
    public Map<Id,Book_Stock__c> setBookStockToUpdate(Set<Id> setOfBookStockIds) {
        Map<Id,Book_Stock__c> mapOfBookSKUToUpdate = new Map<Id,Book_Stock__c>();
        List<Book_SKU_Junction__c> lstJunctionsForStockSKU = [SELECT id,StockSkuJunction__r.Final_Requirment__c,StockSkuJunction__c,Book_Stock_Junction__c,Book_Stock_Junction__r.Final_Requirment__c,Book_Stock_Junction__r.Publisher__c FROM Book_SKU_Junction__c WHERE Book_Stock_Junction__c IN : setOfBookStockIds];
        Map<Id,String> mapOfIdVsPublisher = new Map<Id,String>();
        System.debug('lstJunctionsForStockSKU Size==>'+lstJunctionsForStockSKU.size());

        for (Book_SKU_Junction__c obj : lstJunctionsForStockSKU) {
            Book_Stock__c objBkSKU = mapOfBookSKUToUpdate.containsKey(obj.Book_Stock_Junction__c) ? mapOfBookSKUToUpdate.get(obj.Book_Stock_Junction__c) : new Book_Stock__c();
            Decimal finalRequirment =  obj.StockSkuJunction__r.Final_Requirment__c!=null && obj.StockSkuJunction__r.Final_Requirment__c > 0 ? obj.StockSkuJunction__r.Final_Requirment__c : 0;
            objBkSKU.id = obj.Book_Stock_Junction__c;
            objBkSKU.Final_Requirment__c = finalRequirment + (objBkSKU.Final_Requirment__c==null ? 0 : objBkSKU.Final_Requirment__c);
            mapOfBookSKUToUpdate.put(objBkSKU.id,objBkSKU);
            System.debug('Book SKU Id ==>'+objBkSKU.Id);
            System.debug('Book SKU Final_Requirment__c ==>'+objBkSKU.Final_Requirment__c);
            mapOfIdVsPublisher.put(objBkSKU.id,obj.Book_Stock_Junction__r.Publisher__c);
        }

        // to set as 100 Minimum Final Requirement for Wiley 
        // mapOfBookSKUToUpdate = setMinimumRequirement(mapOfBookSKUToUpdate, mapOfIdVsPublisher);
        return mapOfBookSKUToUpdate;
    }

    /**
    * @description 
    * @author @BK | 17-02-2024 
    * @param Map<Id Book_Stock__c> mapOfBookSKUToUpdate 
    * @param Map<Id String> mapOfIdVsPublisher 
    * @return Map<Id, Book_Stock__c> 
    **/
    // public Map<Id,Book_Stock__c> setMinimumRequirement(Map<Id,Book_Stock__c> mapOfBookSKUToUpdate, Map<Id,String> mapOfIdVsPublisher) {
    //     for (Book_Stock__c obj : mapOfBookSKUToUpdate.values()) {
    //         if(mapOfIdVsPublisher.get(obj.Id) == 'Wiley' && obj.Final_Requirment__c > 0 && obj.Final_Requirment__c < 100) {
    //             obj.Final_Requirment__c = 100;
    //             mapOfBookSKUToUpdate.put(obj.Id,obj);
    //         }
    //     }
    //     return mapOfBookSKUToUpdate;
    // }

}