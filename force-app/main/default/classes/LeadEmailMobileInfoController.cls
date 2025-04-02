/**
 * @description       : 
 * @author            : @Monikac
 * @group             : 
 * @last modified on  : 22-11-2024
 * @last modified by  : @BK
**/
public without sharing class LeadEmailMobileInfoController {
    @AuraEnabled(cacheable=true)
    public static List<LeadWrapper> getLeadEmailMobileInfo(String recordId) {
        List<LeadWrapper> results = new List<LeadWrapper>();

        // Query the Lead details
        List<Lead> leads = [SELECT Id, Email, MobilePhone, nm_SecondryEmail__c, Phone, is_dnd_new__c FROM Lead WHERE Id = :recordId AND is_dnd_new__c!='Yes' LIMIT 1];

        for (Lead lead : leads) {
            results.add(new LeadWrapper(
                lead.Email, 
                lead.MobilePhone,
                lead.nm_SecondryEmail__c,
                lead.Phone
            ));
        }
        
        return results;
    }

    @AuraEnabled
    public static void updateLeadInfo(String leadId, String email, String mobile,  String secondaryEmail, String phone) {
        // Validation for mobile phone: ensure it's a 10-digit number
        if (String.isNotBlank(mobile) && !Pattern.matches('\\d{10}', mobile)) {
            throw new AuraHandledException('Mobile number must be a 10-digit number.');
        }
        // Validation for phone: ensure it's a numeric value
        if (String.isNotBlank(phone) && !Pattern.matches('\\d+', phone)) {
            throw new AuraHandledException('Phone must contain only numeric characters.');
        }
        
        Lead lead = [SELECT Id, Email, MobilePhone, nm_SecondryEmail__c, Phone FROM Lead WHERE Id = :leadId LIMIT 1];
        lead.Email = email;
        lead.MobilePhone = mobile;
        lead.nm_SecondryEmail__c = secondaryEmail;
        lead.Phone = phone;
        update lead;
    }

    public class LeadWrapper {
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String mobile { get; set; }
        @AuraEnabled public String secondaryEmail { get; set; }
        @AuraEnabled public String phone { get; set; }

        public LeadWrapper(String email, String mobile, String secondaryEmail, String phone) {
            this.email = email;
            this.mobile = mobile;
            this.secondaryEmail = secondaryEmail;
            this.phone = phone;
        }
    }
}