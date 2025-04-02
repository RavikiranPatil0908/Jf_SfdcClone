trigger CPTrigger on Counsellor_Profile__c (before insert) {
 if(trigger.isBefore && trigger.isInsert) {
        CPTriggerHandler CPTriggerHandler = new CPTriggerHandler();
       CPTriggerHandler.BeforeInsert(trigger.new);
    }
}