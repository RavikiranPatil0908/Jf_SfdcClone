trigger UpdateOwnerIdBasedOnCityTrigger on Connecto__c (before insert,after insert,before update) 
{
    if(trigger.isBefore && trigger.isInsert)
    {
        UpdateOwnerIdBasedOnCityTriggerHandler obj = new UpdateOwnerIdBasedOnCityTriggerHandler();
        obj.BeforeInsert(trigger.new);
    
    }
    else if(trigger.isBefore && trigger.isUpdate)
    {
    
        UpdateOwnerIdBasedOnCityTriggerHandler obj = new UpdateOwnerIdBasedOnCityTriggerHandler();
        obj.BeforeUpdate(trigger.new,trigger.OldMap);
    
    }
    else if(trigger.isAfter && trigger.isInsert)
    {
    
        UpdateOwnerIdBasedOnCityTriggerHandler obj = new UpdateOwnerIdBasedOnCityTriggerHandler();
        obj.AfterInsert(trigger.new);
    
    }
    
}