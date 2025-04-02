trigger ConnecToTrigger on Connecto__c (before insert,after insert,before update,after update) 
{
    if(trigger.isBefore && trigger.isInsert)
    {
        ConnecToTriggerHandler obj = new ConnecToTriggerHandler();
        obj.BeforeInsert(trigger.new);
    
    }
    if(trigger.isBefore && trigger.isUpdate)
    {
    
        ConnecToTriggerHandler obj = new ConnecToTriggerHandler();
        obj.BeforeUpdate(trigger.new,trigger.OldMap);
    }  
    if(trigger.isAfter && trigger.isUpdate)
    {    
        ConnecToTriggerHandler obj = new ConnecToTriggerHandler();
        obj.AfterUpdate(trigger.New,trigger.OldMap);
    }  
}