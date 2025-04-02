trigger WorkExperienceTrigger on nm_WorkExperience__c (after insert,after update, after delete) {
    if(trigger.isAfter && trigger.isInsert)
    {
        WorkExperienceTriggerHandler obj = new WorkExperienceTriggerHandler();
        obj.AfterInsert(trigger.new,trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        WorkExperienceTriggerHandler obj = new WorkExperienceTriggerHandler();
        obj.AfterUpdate(trigger.new,trigger.oldMap); 
    }
    if(trigger.isAfter && trigger.isDelete)
    {
        WorkExperienceTriggerHandler obj = new WorkExperienceTriggerHandler();
        obj.AfterDelete(trigger.old); 
    }

}