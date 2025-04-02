/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @BK
**/
trigger nmRefundTrigger on nmRefund_Payment__c (before insert, before update, after insert, after update,before delete) 
{
    if(trigger.isAfter && trigger.isInsert) {
        nmRefundTriggerHandler obj = new nmRefundTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isBefore && trigger.isInsert) {
        nmRefundTriggerHandler obj = new nmRefundTriggerHandler();
        obj.BeforeInsert(trigger.new, trigger.newmap);
    }
    
    /*
    if(trigger.isBefore && trigger.isUpdate)
    {
        nmRefundTriggerHandler obj = new nmRefundTriggerHandler();
        obj.BeforeUpdate(trigger.New, trigger.oldMap);
    }*/
    
    if(trigger.isafter && trigger.isupdate) {    
        nmRefundTriggerHandler obj = new nmRefundTriggerHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
    }
    
     if(Trigger.isBefore && Trigger.isDelete){
        nmRefundTriggerHandler objnmRefundTriggerHandler = new nmRefundTriggerHandler();
        objnmRefundTriggerHandler.beforeDelete(trigger.old);
    }
}