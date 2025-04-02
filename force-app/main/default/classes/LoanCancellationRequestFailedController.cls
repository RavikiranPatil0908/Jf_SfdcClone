/**
 * @description       : 
 * @author            : @Vicky
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
**/
public without sharing class LoanCancellationRequestFailedController {

    /**
    * @description 
    * @author @BK | 25-10-2023 
    * @param recordId 
    * @param recordType 
    **/
    public void loanCancellation(String recordId, String recordType, String Subject, String content) {
        Map<String, String> params = new Map<String, String>();
        try {
            if(recordType == 'Opportunity') {
                Opportunity opportunity = [SELECT Id,Account.Name,Amount,Loan_Amount__c,Student_Number__c,EduVanz_lead_id__c,Loan_Type__c,Account.nm_RegistrationNumber__c FROM Opportunity WHERE Id=:recordId LIMIT 1];
                String studentNo = String.isBlank(opportunity.Student_Number__c) ? opportunity.Account.nm_RegistrationNumber__c : opportunity.Student_Number__c;
                params.put('studentName', opportunity.Account.Name);
                params.put('loanAmount', opportunity.Loan_Amount__c);
                params.put('sapId', studentNo);
                params.put('loanId', opportunity.EduVanz_lead_id__c);
                params.put('loanProviderName', opportunity.Loan_Type__c);
            } else if(recordType == 'Lead') {
                Lead objLead = [SELECT id,Name,Loan_Amount__c,nm_RegistrationNo__c,Loan_Type__c,EduVanz_lead_id__c FROM Lead WHERE Id=:recordId LIMIT 1];
                params.put('studentName', objLead.Name);
                params.put('loanAmount', objLead.Loan_Amount__c);
                params.put('sapId', objLead.nm_RegistrationNo__c);
                params.put('loanId', objLead.EduVanz_lead_id__c);
                params.put('loanProviderName', objLead.Loan_Type__c);
            }

            OrgWideEmailAddress owe = [SELECT id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            string[] bccAddress = System.Label.setBccAdderess.split(',');
            mail.setToAddresses(getEmailAddresses());
            mail.setBccAddresses(bccAddress);
            mail.setSubject(subject + ' for ' + params.get('studentName') + ' and Registration No. ' + params.get('sapId'));
            mail.setOrgWideEmailAddressId(owe.id); 
            String messageBody = '<html><p>Hi Team,</p>'
                                    +'<p>Please find below '+ content  +' request</p>'
                                    +'<br>'
                                    +'<p>Student Name: '+params.get('studentName')+'</p>'
                                    +'<p>SAP ID: '+params.get('sapId')+'</p>'
                                    +'<p>Loan Amount: '+params.get('loanAmount')+'</p>'
                                    +'<p>Loan Provider Name: '+params.get('loanProviderName')+'</p>'
                                    +'<p>Loan Id (if available): '+params.get('loanId')+'</p>'
                                    +'<br>'
                                    +'<p>Regards,</p>'
                                    +'<p>NMIMS CDOE</p></html>';
            mail.setHtmlBody(messageBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception error) {
            System.debug('Error Msg: ' + error.getMessage());
        }
    }


    /**
    * @description 
    * @author @BK | 31-10-2023 
    * @return List<String> 
    **/
    private List<String> getEmailAddresses() {
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name='Loan Cancelation Alert'];
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
            mailToAddresses.add(u.email);
        }
        if (label.Environment == 'Sandbox') {
            mailToAddresses.clear();
            mailToAddresses.add('suyog.deshmukh.ext@nmims.edu');
            mailToAddresses.add('dsuyog2013@gmail.com');
        }

        return mailToAddresses;
    }
    
}