trigger AsyncShootTrigger on Async_Shoot_Post_Production__c (after insert,after update) {
    
    if(trigger.isAfter && trigger.isInsert)
    {
        AsyncShootTriggerHandler obj = new AsyncShootTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        AsyncShootTriggerHandler obj = new AsyncShootTriggerHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
    }

}