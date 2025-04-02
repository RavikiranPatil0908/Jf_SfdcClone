trigger StudentRatingTrigger on Student_Rating__c (after insert, after update) {
    public static boolean IsAfterUpdateRunOnce = false;
    if(trigger.isAfter && trigger.isInsert) {
        StudentRatingTriggerHandler StudentRatingTriggerHandler = new StudentRatingTriggerHandler();
        StudentRatingTriggerHandler.addAccountOnRating(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate) {
        StudentRatingTriggerHandler StudentRatingTriggerHandler = new StudentRatingTriggerHandler();
        StudentRatingTriggerHandler.UpdateAccountOnRating(trigger.new, trigger.oldMap);
    }

}