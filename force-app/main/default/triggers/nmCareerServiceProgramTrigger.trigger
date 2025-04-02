trigger nmCareerServiceProgramTrigger on Career_Service_Program__c (before insert, before update, after insert, after update) 
{
    if(trigger.isAfter && trigger.isInsert)
    {
        nmCareerServiceProgramTriggerHandler obj = new nmCareerServiceProgramTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    
  /*  if(trigger.isBefore && trigger.isInsert)
    {
        nmCareerServiceProgramTriggerHandler obj = new nmCareerServiceProgramTriggerHandler();
        obj.BeforeInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {          
        nmCareerServiceProgramTriggerHandler obj = new nmCareerServiceProgramTriggerHandler();
        obj.BeforeUpdate(trigger.New, trigger.oldMap);
    }*/
    if(trigger.isafter && trigger.isupdate)
    {            
        nmCareerServiceProgramTriggerHandler obj = new nmCareerServiceProgramTriggerHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
    }
}