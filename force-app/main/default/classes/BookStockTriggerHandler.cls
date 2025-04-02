/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
public without sharing class BookStockTriggerHandler {
    public static boolean isAfterUpdateRunOnce = false;

    public void afterUpdate(List<Book_Stock__c> triggerNew, Map<id,Book_Stock__c> triggerNewMap, Map<id, Book_Stock__c> triggerOldMap){ 
        if(isAfterUpdateRunOnce){
            return;
        }

        isAfterUpdateRunOnce = true;

        // To Calculate the final Order
        calcRatePerPage(triggerNew,triggerOldMap);
    }

    public void beforeInsert(List<Book_Stock__c> triggerNew){ 
        // To Calculate the final Order
        calcRatePerPage(triggerNew);
    }

    /**
    * @description 
    * @author @BK | 06-11-2024 
    * @param List<Book_Stock__c> triggerNew 
    **/
    public void calcRatePerPage(List<Book_Stock__c> triggerNew) { 
        List<Id> lstOfBookStockId = new List<Id>();

        for (Book_Stock__c obj : triggerNew) {
            if((obj.Final_Requirment__c!=null && obj.Final_Requirment__c > 0) 
            || (obj.Additional__c!=null && obj.Additional__c > 0)) {
                lstOfBookStockId.add(obj.Id);
            }
        }

        if(!lstOfBookStockId.isEmpty()) {
            Map<String,Decimal> mapOfKeyVsRatePerPage = getRatePerPageMap();

            for (Book_Stock__c obj : triggerNew) {
                if(lstOfBookStockId.contains(obj.Id)) {
                    obj.Rate_per_page__c = getSlabRatePerPage(obj, mapOfKeyVsRatePerPage);
                }
            }
        }
    }

    /**
    * @description 
    * @author @BK | 06-11-2024 
    * @param List<Book_Stock__c> triggerNew 
    * @param Map<id Book_Stock__c> triggerOldMap 
    **/
    public void calcRatePerPage(List<Book_Stock__c> triggerNew, Map<id, Book_Stock__c> triggerOldMap) { 

        List<Book_Stock__c> lstOfBookStock = new List<Book_Stock__c>();

        for (Book_Stock__c obj : triggerNew) {
            if(obj.Final_Requirment__c!=triggerOldMap.get(obj.Id).Final_Requirment__c || obj.Additional__c!=triggerOldMap.get(obj.Id).Additional__c
                || obj.Book_Stock__c!=triggerOldMap.get(obj.Id).Book_Stock__c) {
                lstOfBookStock.add(obj);
            }
        }
        System.debug('lstOfBookStock Size ==>'+lstOfBookStock.size());
        if(lstOfBookStock.size() > 0) {
            Map<String,Decimal> mapOfKeyVsRatePerPage = getRatePerPageMap();
            updateBookStocks(lstOfBookStock,mapOfKeyVsRatePerPage);
        }
    }

    /**
    * @description 
    * @author @BK | 06-11-2024 
    * @return Map<String, Decimal> 
    **/
    public Map<String,Decimal> getRatePerPageMap() {
        Publisher_Setting__mdt[] publisherSettings = [SELECT MasterLabel,Publisher__c,Rate_Per_Page__c,Slab__c FROM Publisher_Setting__mdt];
        System.debug('publisherSettings Size ==>'+publisherSettings.size());
        Map<String,Decimal> mapOfKeyVsRatePerPage = new Map<String,Decimal>();
        for (Publisher_Setting__mdt obj : publisherSettings) {
            String mapKey = obj.Publisher__c.toLowerCase() + '_' + obj.Slab__c;
            mapOfKeyVsRatePerPage.put(mapKey,obj.Rate_Per_Page__c); 
        }
        return mapOfKeyVsRatePerPage;
    }

    /**
    * @description 
    * @author @BK | 17-02-2024 
    * @param List<Book_Stock__c> lstOfBookStock 
    * @param Map<String Decimal> mapOfKeyVsRatePerPage 
    **/
    public void updateBookStocks(List<Book_Stock__c> lstOfBookStock, Map<String,Decimal> mapOfKeyVsRatePerPage) {
        List<Book_Stock__c> lstOfBookStockToUpdate = new List<Book_Stock__c>();
        for(Book_Stock__c obj : lstOfBookStock) {
            Book_Stock__c objSK = new Book_Stock__c();
            objSK.Id = obj.Id;
            objSK.Rate_per_page__c = getSlabRatePerPage(obj, mapOfKeyVsRatePerPage);
            lstOfBookStockToUpdate.add(objSK);
        }

        if(lstOfBookStockToUpdate.size() > 0) {
            update lstOfBookStockToUpdate;
        }
    }

    /**
    * @description 
    * @author @BK | 06-11-2024 
    * @param Book_Stock__c obj 
    * @param Map<String Decimal> mapOfKeyVsRatePerPage 
    * @return Decimal 
    **/
    public Decimal getSlabRatePerPage(Book_Stock__c obj, Map<String,Decimal> mapOfKeyVsRatePerPage) {
        String mapKey = (obj.Publisher__c!=null ? obj.Publisher__c.toLowerCase() : null) + '_' + getSlab(obj.Final_Order__c);
        return mapOfKeyVsRatePerPage.containsKey(mapKey) ? mapOfKeyVsRatePerPage.get(mapKey) : 0;
    }

    /**
    * @description 
    * @author @BK | 17-02-2024 
    * @param Decimal finalOrder 
    * @return String 
    **/
    public String getSlab(Decimal finalOrder) {
        if(finalOrder < 201) {
            return '100-200';
        } else if(finalOrder > 200 && finalOrder < 401) {
            return '201-400';
        } else if(finalOrder > 400 && finalOrder < 600) {
            return '401-599';
        } else if(finalOrder > 599 && finalOrder < 1001) {
            return '600-1000';
        } else if(finalOrder > 1000 && finalOrder < 2001) {
            return '1001-2000';
        } else if(finalOrder > 2000 && finalOrder < 3001) {
            return '2001-3000';
        } else if(finalOrder > 3000) {
            return 'above-3001';
        } else {
            return '';
        }
    }
}