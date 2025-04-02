trigger StockDeductions on Dispatch_Order__c(before insert,after update)
{
    if(trigger.isBefore && trigger.isInsert)
    {
        StockDeductionsTriggerHandler obj = new StockDeductionsTriggerHandler();
        obj.BeforeInsert(trigger.New);
        
    
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
         if(checkRecursive.runAfterOnce()){
             StockDeductionsTriggerHandler obj = new StockDeductionsTriggerHandler();
             obj.AfterUpdate(trigger.New,trigger.OldMap);
         }
    }
    
    

}