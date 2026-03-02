/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 05--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   02--01--2026   @Ravi   Initial Version
**/
trigger WorkExperienceTrigger on nm_WorkExperience__c (after insert,after update, after delete, before insert,before update) {
    
    if(trigger.isBefore && trigger.isInsert)
    {
        WorkExperienceTriggerHandler obj = new WorkExperienceTriggerHandler();
        obj.BeforeInsert(trigger.new,trigger.newMap);
    }
    if(trigger.isBefore && trigger.isUpdate){
        WorkExperienceTriggerHandler obj = new WorkExperienceTriggerHandler();
        obj.BeforeUpdate(trigger.new,trigger.newMap);
    }
    
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
        obj.AfterDelete(trigger.old,trigger.oldMap); 
    }

}