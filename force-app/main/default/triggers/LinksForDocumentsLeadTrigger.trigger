/**
 * @File Name          : LinksForDocumentsLeadTrigger.trigger
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 17/1/2020, 5:30:03 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/17/2019, 6:07:35 PM   shubhranshu     Initial Version
**/
trigger LinksForDocumentsLeadTrigger on nm_LinksForDocumentsLead__c (after update) {
    if(trigger.isAfter && trigger.isUpdate) {
        LinksForDocumentsLeadTriggerHandler obj = new LinksForDocumentsLeadTriggerHandler();
        obj.AfterUpdate(trigger.new,trigger.oldMap);
    } 
}