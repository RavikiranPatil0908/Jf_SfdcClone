/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 11-11-2023
 * @last modified by  : @BK
**/
trigger nmCaseTrigger on Case (before insert, before update,after update,after insert) {
    nmCaseTriggerHandler handler = new nmCaseTriggerHandler();
    if(trigger.isAfter){
        if(trigger.isUpdate){
            handler.AfterUpdate(trigger.New, trigger.OldMap);
        }else if(trigger.isInsert){
            system.debug('Inside After Insert Trigger');            
            handler.AfterInsert(trigger.New);
        }
    }


    if(trigger.isBefore){
        if(trigger.isUpdate){
            handler.BeforeUpdate(trigger.New, trigger.OldMap);
        } else if(trigger.isInsert){
            handler.BeforeInsert(trigger.New);
        }
    }
}