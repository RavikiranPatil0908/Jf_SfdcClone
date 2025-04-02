trigger AEPRequestTrigger on AEP_Request__c (after insert, after update, before update) {
    if(trigger.isAfter && trigger.isInsert){
        AEPRequestTriggerHandler AEPRequestTriggerHandler = new AEPRequestTriggerHandler();
        AEPRequestTriggerHandler.AfterInsert(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        AEPRequestTriggerHandler AEPRequestTriggerHandler = new AEPRequestTriggerHandler();
        AEPRequestTriggerHandler.AfterUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isUpdate) {
        AEPRequestTriggerHandler AEPRequestTriggerHandler = new AEPRequestTriggerHandler();
        AEPRequestTriggerHandler.BeforeUpdate(trigger.new, trigger.oldMap);
    }

}