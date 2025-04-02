/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-08-2024
 * @last modified by  : @BK
**/
public without sharing class WelcomeLetterPageController {
    public Id objectId;
    public String emailHtmlBody {get;set;}

    public WelcomeLetterPageController() {
        emailHtmlBody = '';
    }

    public Id getObjectId() {
		return this.objectId;
	}

    public void setObjectId(Id objectId) {
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId)) {
            getEmailBody(this.objectId);
        }
	}

    public void getEmailBody(Id recordId) {
        List<EmailTemplate> emailTemplate = [SELECT Id FROM EmailTemplate WHERE name='Admission Confirmation' LIMIT 1];
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, null, recordId);
        emailHtmlBody = email.getHtmlBody();
        System.debug('body-->'+ emailHtmlBody);
    }

  
}