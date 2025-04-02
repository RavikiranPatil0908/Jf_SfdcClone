/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
trigger BookStockTrigger on Book_Stock__c (before insert, before update, after update, after insert) {
    BookStockTriggerHandler obj=new BookStockTriggerHandler();
    if(trigger.isAfter){
        if(trigger.isUpdate){
            obj.afterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }

    if(trigger.isBefore){
        if(trigger.isInsert){
            obj.beforeInsert(trigger.New);
        }
    }
}