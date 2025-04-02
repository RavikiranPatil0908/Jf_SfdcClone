/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public class SlotAvailableEmailNotification implements Database.Batchable<sObject>, Database.Stateful {

    public String callType = null;

    public SlotAvailableEmailNotification(String typeOfCall) {
        this.callType = typeOfCall;
    }

    @InvocableMethod(label='Send Slot Availability Alert' description='To Send Email Alert on Slot Availablity to Students.')
    public static void sendEmail(List<FlowInputs> requests) {
        String callType = requests[0].callType;
        Id jobId = Database.executeBatch(new SlotAvailableEmailNotification(callType));
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for the Cases where Is_Slot_Available__c is true
        return Database.getQueryLocator('select Id,Is_Slot_Available__c,SuppliedEmail,Type_of_Call__c from Case where Is_Slot_Available__c=true AND Type_of_Call__c=:callType');
    }

    public void execute(Database.BatchableContext BC, List<Case> caseList) {
        // Create a list to store the updated Case records
        List<Case> casesToUpdate = new List<Case>();

        List<Messaging.SingleEmailMessage > lstEmailMessage = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, Name FROM EmailTemplate WHERE Name ='Send Email Notification Schedule available for callback' LIMIT 1];
        system.debug('caseList.size() --> ' +caseList.size());
        for (Case caseRec: caseList) {
            // Set Is_Slot_Available__c to false on the Case record
            caseRec.Is_Slot_Available__c = false;
            caseRec.Type_of_Call__c = null;
            casesToUpdate.add(caseRec);
            
            String[] sendingToAddresses;
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id,null, caseRec.Id);

            // To Query Organisation Details.
            OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
            
            String emailSubject = email.getSubject();
            String emailTextBody = email.getHtmlBody();
            sendingToAddresses = caseRec.SuppliedEmail.split(',');
            email.setOrgWideEmailAddressId(owe.id); 
            email.setSubject(emailSubject);
            email.setHtmlBody(emailTextBody);
            email.setToAddresses(sendingToAddresses);
            email.saveAsActivity = false;
            lstEmailMessage.add(email);
        }
        if(lstEmailMessage.size() > 0) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmailMessage);
            if(results[0].success) {
                system.debug('Email Send Successfully');
            } else {
                system.debug('Failed to send mail ' + results[0].errors[0].message);
            }
        }

            // Update the Case records
        if (!casesToUpdate.isEmpty()) {
            Database.update(casesToUpdate, false);
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Perform any post-processing or logging if needed
    }

    public class FlowInputs {
        @InvocableVariable(required=true) 
        public String callType;
    }
}