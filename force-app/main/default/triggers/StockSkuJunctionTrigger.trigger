/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-02-2024
 * @last modified by  : @BK
**/
trigger StockSkuJunctionTrigger on StockSkuJunction__c (after insert,after update) {
    StockSkuJunctionTriggerHandler obj=new StockSkuJunctionTriggerHandler();
    if(trigger.isAfter){
        if(trigger.isUpdate){
            obj.afterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
}