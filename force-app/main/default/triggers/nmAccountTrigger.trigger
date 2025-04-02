/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 29-06-2024
 * @last modified by  : @BK
**/
trigger nmAccountTrigger on Account (before insert, before update, after insert, after update) 
{
    //Getting the Process_Switches__c custom setting value that is relevant to our running 
    //user
	Process_Switches__c processSwitches = Process_Switches__c.getInstance(UserInfo.getProfileId());

    //If the user can bypass the trigger, return and do not continue the trigger.
    if(processSwitches.Accounts_Process_ByPass__c) {
        return;
    }

    if(trigger.isAfter && trigger.isInsert) {
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isBefore && trigger.isInsert) {
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        obj.BeforeInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isBefore && trigger.isUpdate) {
        if(nmStopRecursion.stopRecursiveAccountTriggerRun2){
            return;
        }
        
        nmStopRecursion.stopRecursiveAccountTriggerRun2 = true;
       
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        obj.BeforeUpdate(trigger.New, trigger.oldMap);
    }
    if(trigger.isafter && trigger.isupdate) {    
        /*if(nmStopRecursion.stopRecursiveAccountTriggerRun){
        return;
        }
    
        nmStopRecursion.stopRecursiveAccountTriggerRun = true;*/
        
        nmAccountTriggerHandler obj = new nmAccountTriggerHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
        
        obj.ChkLateralFutureSemvs2(trigger.new, trigger.oldMap,'Update');
    }
}