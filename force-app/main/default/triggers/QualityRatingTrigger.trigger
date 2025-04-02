/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-01-2025
 * @last modified by  : @BK
**/
trigger QualityRatingTrigger on Quality_Rating__c (before insert, before update) {

    QualityRatingTriggerHandler obj = new QualityRatingTriggerHandler();

    if(trigger.isBefore){
        if(trigger.isInsert){
            obj.beforeInsert(trigger.New,trigger.oldMap);
        }else if(trigger.isUpdate){
            obj.beforeUpdate(trigger.New,trigger.oldMap);
        }
    } 
}