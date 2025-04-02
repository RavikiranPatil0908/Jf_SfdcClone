trigger BookSkuJunctionTrigger on Book_SKU_Junction__c (after insert, after update,before update) {
    
     if(trigger.isAfter && trigger.isInsert)
    {
        BookSkuJunctionTriggerHandler obj = new BookSkuJunctionTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    if(trigger.isafter && trigger.isupdate)
    {    
        BookSkuJunctionTriggerHandler obj = new BookSkuJunctionTriggerHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
    }
    
     /*if(trigger.isbefore && trigger.isupdate)
    {    
        BookSkuJunctionTriggerHandler obj = new BookSkuJunctionTriggerHandler();
        obj.beforUpdate(trigger.new, trigger.oldMap);
    }*/
    
    
         
     }