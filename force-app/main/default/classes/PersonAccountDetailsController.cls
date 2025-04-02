/**
 * @description       : 
 * @author            : @Monikac
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : @Monikac
**/
public without sharing class PersonAccountDetailsController {
    @AuraEnabled(cacheable=true)
    public static List<PersonAccountWrapper> getPersonAccountDetails(String recordId) {
        List<PersonAccountWrapper> results = new List<PersonAccountWrapper>();

        // Query the Person Account details
        List<Account> accounts = [SELECT Id, PersonEmail, PersonMobilePhone ,nm_SecondryEmail__c, Phone FROM Account WHERE Id = :recordId AND IsPersonAccount = TRUE];

        for (Account acc : accounts) {
            results.add(new PersonAccountWrapper(
                acc.PersonEmail, 
                acc.PersonMobilePhone,
                acc.nm_SecondryEmail__c,
                acc.Phone

            ));
        }
        
        return results;
    }

    public class PersonAccountWrapper {
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String mobile { get; set; }
        @AuraEnabled public String secondaryEmail { get; set; }
        @AuraEnabled public String phone { get; set; }

        public PersonAccountWrapper(String email, String mobile, String secondaryEmail, String phone) {
            this.email = email;
            this.mobile = mobile;
            this.secondaryEmail = secondaryEmail;
            this.phone = phone;
        }
    }
}