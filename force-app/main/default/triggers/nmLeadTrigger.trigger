/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 09-08-2024
 * @last modified by  : @BK
**/
trigger nmLeadTrigger on Lead (before insert, before update, after insert, after update) {

    //Getting the Process_Switches__c custom setting value that is relevant to our running 
    //user
	Process_Switches__c processSwitches = Process_Switches__c.getInstance(UserInfo.getProfileId());

    //If the user can bypass the trigger, return and do not continue the trigger.
    if(processSwitches.Leads_Process_ByPass__c) {
        return;
    }

    nmLeadTriggerHandler obj = new nmLeadTriggerHandler();
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            obj.AfterInsert(trigger.new, trigger.newMap, trigger.newMap);
        }else if(trigger.isUpdate){
            obj.AfterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            obj.BeforeInsert(trigger.New,trigger.oldMap);
        }else if(trigger.isUpdate){
            obj.BeforeUpdate(trigger.New,trigger.oldMap);
        }
    } 
}