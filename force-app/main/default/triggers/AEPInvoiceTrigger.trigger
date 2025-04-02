/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 06-25-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-25-2021   shubhranshu   Initial Version
**/
trigger AEPInvoiceTrigger on AEPInvoice__c (before insert, before update, after insert, after update) {
    if(trigger.isAfter && trigger.isInsert)
    {   
        if(AEPInvoiceTriggerHandler.isFirstTime){
            AEPInvoiceTriggerHandler.isFirstTime = false;
            AEPInvoiceTriggerHandler obj = new AEPInvoiceTriggerHandler();
            obj.AfterInsert(trigger.new, trigger.newmap);
        }
    }
    if(trigger.isafter && trigger.isupdate)
    {   
        if(AEPInvoiceTriggerHandler.isFirstTime){
            AEPInvoiceTriggerHandler.isFirstTime = false;              
            AEPInvoiceTriggerHandler obj = new AEPInvoiceTriggerHandler();
            obj.AfterUpdate(trigger.new, trigger.oldMap);
        }   
    }

    if(trigger.isBefore && trigger.isInsert){
        if(AEPInvoiceTriggerHandler.isFirstTime){
            AEPInvoiceTriggerHandler.isFirstTime = false;              
            AEPInvoiceTriggerHandler obj = new AEPInvoiceTriggerHandler();
            obj.BeforeInsert(trigger.new, trigger.oldMap);
        }   
    }

    // if(trigger.isBefore && trigger.isUpdate){
    //     if(AEPInvoiceTriggerHandler.isFirstTime){
    //         AEPInvoiceTriggerHandler.isFirstTime = false;              
    //         AEPInvoiceTriggerHandler obj = new AEPInvoiceTriggerHandler();
    //         obj.BeforeUpdate(trigger.new, trigger.oldMap);
    //     }   
    // }
}