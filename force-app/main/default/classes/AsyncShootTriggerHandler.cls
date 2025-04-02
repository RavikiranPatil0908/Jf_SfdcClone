/**
 * @description       :
 * @author            : @BK
 * @group             :
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
 **/
public class AsyncShootTriggerHandler {
    public List<Messaging.SingleEmailMessage> lstEmailMessage = new List<Messaging.SingleEmailMessage>();
    public void AfterInsert(List<Async_Shoot_Post_Production__c> triggerNew, map<id, Async_Shoot_Post_Production__c> newMap) {
        updateAsyncObj(triggerNew, 'insert', newMap);
    }
    public void AfterUpdate(List<Async_Shoot_Post_Production__c> triggerNew, map<id, Async_Shoot_Post_Production__c> OldMap) {
        updateAsyncObj(triggerNew, 'update', OldMap);
    }

    public void updateAsyncObj(List<Async_Shoot_Post_Production__c> asyncObList, String event, map<id, Async_Shoot_Post_Production__c> OldMap) {
        system.debug('event===>' + event);
        for (Async_Shoot_Post_Production__c ob : asyncObList) {
            if (event == 'update') {
                if ((ob.Post_Production_Status__c != OldMap.get(ob.Id).Post_Production_Status__c) 
                    && ob.Post_Production_Status__c == 'Faculty Comments Shared with Production') {
                    if (String.isNotBlank(ob.Editor_Name__c)) {
                        system.debug('ob inside--> ' + ob);
                        lstEmailMessage.add(sendMail(ob.Editor_Email_Id__c, ob.Id));
                    }
                }
            } else if (event == 'insert') {
                if ((String.IsNotBlank(ob.getCloneSourceId()) && ob.Post_Production_Status__c == 'Faculty Comments Shared with Production') 
                    || ob.Post_Production_Status__c == 'Faculty Comments Shared with Production') {
                    if (String.isNotBlank(ob.Editor_Name__c)) {
                        system.debug('ob inside--> ' + ob);
                        lstEmailMessage.add(sendMail(ob.Editor_Email_Id__c, ob.Id));
                    }
                }
            }
        }
        if (lstEmailMessage.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmailMessage);
        }
    }

    public Messaging.SingleEmailMessage sendMail(String emailId, String recId) {
        List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE Name = 'Send Email to Editor' LIMIT 1];
        system.debug(emailTemplates);
        List<String> ccEmailId = new List<String>();
        ccEmailId = System.Label.Async_Editor_EmailId.split(',');

        system.debug(UserInfo.getUserId());
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplates[0].Id, null, recId);
        OrgWideEmailAddress owe = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        String[] sendingToCCAddress = ccEmailId;
        String[] sendingToAddresses = new List<String>{ emailId };

        String emailSubject = email.getSubject();
        String emailTextBody = email.getHtmlBody();

        //email.setTargetObjectId(user[0].Id);
        email.setToAddresses(sendingToAddresses);
        email.setOrgWideEmailAddressId(owe.id);
        email.setSubject(emailSubject);
        email.setHtmlBody(emailTextBody);
        email.setCcAddresses(sendingToCCAddress);
        email.saveAsActivity = false;
        return email;
    }
}