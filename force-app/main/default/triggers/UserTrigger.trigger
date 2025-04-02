trigger UserTrigger on User (after insert, after update) {
    if(trigger.isAfter && trigger.isInsert)
    {
        UserTriggerHandler obj = new UserTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    if(trigger.isafter && trigger.isupdate)
    {    
        UserTriggerHandler obj = new UserTriggerHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
    }
}