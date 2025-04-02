/**
 * @File Name          : LinksForDocumentStudentstatus.trigger
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 29-06-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    31/8/2019   @BK     Initial Version
**/
trigger LinksForDocumentStudentstatus on nm_LinksForDocuments__c (before insert, before update, after insert, after update) 
{
    //Getting the Process_Switches__c custom setting value that is relevant to our running 
        //user
	Process_Switches__c processSwitches = Process_Switches__c.getInstance(UserInfo.getProfileId());

    //If the user can bypass the trigger, return and do not continue the trigger.
    if(processSwitches.Documents_Process_ByPass__c) {
        return;
    }

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
}