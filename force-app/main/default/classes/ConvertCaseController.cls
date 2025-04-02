/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : @BK
**/
Global class ConvertCaseController {
    @AuraEnabled
    webservice static void CaseConvert(Id Caseid, String purpose){
        DateTime dT = system.today();
    	Date d = date.newinstance(dT.year(), dT.month(), dT.day());
        Case c = [SELECT ContactId, Status, Student_No__c, Expected_Close_Date__c, Student_Category__c, RecordTypeId FROM Case WHERE Id =:CaseId];
		
        c.Student_Purpose__c = purpose;
        c.Status = 'New';
        c.Old_Status__c = 'Open';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        Case__c mcs = Case__c.getValues(c.Student_Category__c);
        Integer tat = Integer.valueOF(mcs.TAT__c);
 		Integer diff = MyCasesController.getNumberOfDays(System.today(), d.addDays(tat));
            if(diff < tat){
                Integer actualTat = tat + (tat-diff);
                c.Expected_Close_Date__c = d.addDays(actualTat);
            }else{
                c.Expected_Close_Date__c = d.addDays(tat);
            }            
          
        update c;
        
        OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(owe.id);
        mail.setReplyTo(owe.Address);
            
        // To Query the Email Template.
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'When a Feedback is converted to Enquiry or Complaint by admin' LIMIT 1];
		mail.setWhatId(CaseId);
        mail.setTargetObjectId(c.ContactId);
        mail.setTemplateId(emailTemplate.Id);
            
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
		
    }
}