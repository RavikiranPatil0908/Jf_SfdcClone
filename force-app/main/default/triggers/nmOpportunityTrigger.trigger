trigger nmOpportunityTrigger on Opportunity (Before insert, Before update, after insert, after update) 
{
    if(trigger.isBefore && trigger.isUpdate)
    {
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.BeforeUpdate(trigger.new, trigger.oldmap);
    } 
    if(trigger.isBefore && trigger.isInsert)
    {
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.BeforeInsert(trigger.new, trigger.Newmap);
    }
    if(trigger.isafter && trigger.isinsert)
    {
        nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isafter && trigger.isupdate)
    {
      nmOpportunityTriggerHandler obj = new nmOpportunityTriggerHandler();
      obj.AfterUpdate(trigger.new, trigger.oldmap,trigger.newmap);
       nmStopRecursion.stopRecursiveOpportunityTriggerHandlerRun = false;
       if(nmStopRecursion.stopRecursiveOpportunityTriggerHandlerRun)
       {
           return;
       }
       nmStopRecursion.stopRecursiveOpportunityTriggerHandlerRun = true;
      // nmICPaymentTriggerHandler objICPayment = new nmICPaymentTriggerHandler();
       //objICPayment.AfterUpdate(trigger.newmap, trigger.oldmap);
    } 
    
}