/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-27-2020
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-27-2020   @BK   Initial Version
**/
trigger AepSiteInspectionTrigger on AEP_site_inspection__c (after insert, after update) {
    AepSiteInspectionTriggerHandler obj = new AepSiteInspectionTriggerHandler();
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            obj.AfterInsert(trigger.new, trigger.newMap, trigger.newMap);
        }else if(trigger.isUpdate){
            obj.AfterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
}