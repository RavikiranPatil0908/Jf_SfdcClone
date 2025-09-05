/**
 * @File Name          : LinksForDocumentStudentstatus.trigger
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 30--07--2025
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/8/2019   @BK     Initial Version
**/
trigger LinksForDocumentStudentstatus on nm_LinksForDocuments__c (before insert, before update, after insert, after update, after delete) 
{
    //Getting the Process_Switches__c custom setting value that is relevant to our running 
        //user
	Process_Switches__c processSwitches = Process_Switches__c.getInstance(UserInfo.getProfileId());

    //If the user can bypass the trigger, return and do not continue the trigger.
    if(processSwitches.Documents_Process_ByPass__c) {
        return;
    }
    System.debug('trigger.======> '+trigger.isDelete);
    if(trigger.isAfter && trigger.isInsert)
    {
        nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
        obj.AfterInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isBefore && trigger.isInsert)
    {
        nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
        obj.BeforeInsert(trigger.new, trigger.newmap);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
        obj.BeforeUpdate(trigger.New, trigger.oldMap);
    }
    if(trigger.isafter && trigger.isupdate)
    {    
               
        nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
        obj.AfterUpdate(trigger.new, trigger.oldMap);
    }
    
    System.debug('trigger.==> '+trigger.isDelete);
    if(trigger.isAfter && trigger.isDelete)
    {
        System.debug('trigger.isDelete==> '+trigger.isDelete);
        nmLinksForDocumentStatusHandler obj = new nmLinksForDocumentStatusHandler();
        obj.AfterDelete(trigger.old); 
    }
}