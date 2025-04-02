/**
 * @File Name          : nmPaymentTrigger.trigger
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 17-01-2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/28/2019   shubhranshu     Initial Version
**/
trigger nmPaymentTrigger on nm_Payment__c (before insert,before update, after insert,after update,after delete,before delete) 
{
   
    
    
    if(trigger.isBefore && trigger.isInsert)
        {
        
            nmPaymentTriggerHandler objnmPaymentTriggerHandler = new nmPaymentTriggerHandler();
            objnmPaymentTriggerHandler.BeforeInsert(trigger.New);
        }

     if(trigger.isBefore && trigger.isUpdate)
    {
    
         nmPaymentTriggerHandler objnmPaymentTriggerHandler = new nmPaymentTriggerHandler();
         objnmPaymentTriggerHandler.BeforeUpdate(trigger.New,trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert)
    {
        nmPaymentTriggerHandler objnmPaymentTriggerHandler = new nmPaymentTriggerHandler();
        objnmPaymentTriggerHandler.afterInsert(trigger.New, trigger.OldMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        
        if(nmStopRecursion.stopRecursivePaymentTriggerRun){
            return;
        }
    
        nmStopRecursion.stopRecursivePaymentTriggerRun = true;
        
        nmPaymentTriggerHandler objnmPaymentTriggerHandler = new nmPaymentTriggerHandler();
        objnmPaymentTriggerHandler.afterUpdate(trigger.New, trigger.OldMap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        nmPaymentTriggerHandler objnmPaymentTriggerHandler = new nmPaymentTriggerHandler();
        objnmPaymentTriggerHandler.beforeDelete(trigger.old);
    }

  /*  if(Trigger.isAfter && Trigger.isDelete){
        nmPaymentTriggerHandler objnmPaymentTriggerHandler = new nmPaymentTriggerHandler();
        objnmPaymentTriggerHandler.afterDelete(trigger.old);
    }*/
}