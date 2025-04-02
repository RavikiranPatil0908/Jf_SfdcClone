trigger nmICChangeRequestTrigger on IC_Change_Request__c (after update,after insert) 
{
  if(trigger.isAfter && trigger.isUpdate)
  {
    nmICChangeRequestTriggerHandler objnmICChangeRequestTriggerHandler = new nmICChangeRequestTriggerHandler();
    objnmICChangeRequestTriggerHandler.AfterUpdate(trigger.new, trigger.OldMap); 
  }
  
  if(trigger.isAfter && trigger.isInsert)
  {
    nmICChangeRequestTriggerHandler objnmICChangeRequestTriggerHandler = new nmICChangeRequestTriggerHandler();
    objnmICChangeRequestTriggerHandler.AfterInsert(trigger.new); 
  }
  
/*if(trigger.isBefore && trigger.isUpdate)
  {
    nmICChangeRequestTriggerHandler objnmICChangeRequestTriggerHandler = new nmICChangeRequestTriggerHandler();
    objnmICChangeRequestTriggerHandler.BeforeUpdate(trigger.new); 
  }
  */
}