trigger AsyncTOCLinkTrigger on AsyncTOCLink__c (before insert, before update, after insert, after update) {

    if(trigger.isAfter && trigger.isInsert) {
        AsyncTOCLinkTriggerHandler obj = new AsyncTOCLinkTriggerHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }


}