/**
 * @description       : Case handler
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 10-01-2024
 * @last modified by  : @Ravi
**/
public class MyCasesControllerHandler {
    
    public static String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Lead Support').getRecordTypeId();
    public Id objectId { get; set; }
    public String objectType { get; set; }
    public CaseWrapper caseWrapper { get; set; }
    public Case c;
    

    // Constructor to initialize the wrapper
    public MyCasesControllerHandler() {
        caseWrapper = new CaseWrapper();
         c = new Case();
        System.debug('Record type Id : ' + ticket);
    }

    public Id getObjectId() {
        return objectId;
    }

    public void setObjectId(Id objectId) {
        this.objectId = objectId;
    }

    public String getObjectType() {
        return objectType;
    }

    public void setObjectType(String objectType) {
             this.objectType = objectType;
    }

    public List<SelectOption> getQueryTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None', 'None'));
        options.add(new SelectOption('Enquiry', 'Enquiry'));
        options.add(new SelectOption('Complaint', 'Complaint'));
        options.add(new SelectOption('Feedback', 'Feedback'));
        return options;
    }

    public List<SelectOption> getSubCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None', 'None'));
        options.add(new SelectOption('Regarding Program', 'Regarding Program'));
        options.add(new SelectOption('Regarding Eligibility and Admission Process', 'Regarding Eligibility and Admission Process'));
        options.add(new SelectOption('Regarding Loan Options and Fees', 'Regarding Loan Options and Fees'));
        options.add(new SelectOption('Brochure', 'Brochure'));
        options.add(new SelectOption('Curriculum', 'Curriculum'));
        options.add(new SelectOption('Reasons other than the above', 'Reasons other than the above'));
        return options;
    }

    public List<SelectOption> getCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None', 'None'));
        options.add(new SelectOption('Need More Information', 'Need More Information'));
        options.add(new SelectOption('Ask to Call Back', 'Ask to Call Back'));
        options.add(new SelectOption('Counsellor Verification', 'Counsellor Verification'));
        options.add(new SelectOption('DND', 'DND'));
        options.add(new SelectOption('Others', 'Others'));
        return options;
    }

    public void insertCase() {
        System.debug('objLead---' + objectId);
        if (validateStudent(objectId)) {
            return;
        }
        try {
            createCase();
        } catch (Exception e) {
            System.debug('Error-->' + String.valueOf(e));
        }
    }

    public Boolean validateStudent(Id objectId) {
        Lead lead = [SELECT Id, Name, MobilePhone, Email ,nm_RegistrationNo__c ,nm_InformationCenter__c FROM Lead WHERE Id=:objectId limit 1];
         
        if (lead == null) {
            System.debug('Lead not found');
            return true;
        } else {
             String centerId = [SELECT OwnerId FROM nm_Centers__c WHERE Id = :lead.nm_InformationCenter__c].OwnerId;
        if (String.isNotBlank(centerId)) {
            c.OwnerId =centerId ;
        }
            c.Lead__c = lead.Id;
            c.Registration_No__c =lead.nm_RegistrationNo__c;
            c.SuppliedEmail = lead.Email;
            c.SuppliedName = lead.Name;
            return false; 
        }
       
    }

    public void createCase() {
        System.debug('objLead---' + objectId+' query type'+ caseWrapper.queryType+'category'+ caseWrapper.category);
        c.Query_Type__c = caseWrapper.queryType;
        c.Student_Category__c = caseWrapper.category;
        c.Student_Sub_Categories__c = caseWrapper.subCategory;
        c.Subject = caseWrapper.subject;
        c.Description = caseWrapper.description;
        c.RecordTypeId = ticket;
        System.debug('Case record object'+c);
        // insert c;
        caseWrapper.isCaseCreated = true;
    }
    
    public void addComment(){

   }
    // Wrapper class for holding the case details and other related data
    public class CaseWrapper {
        public String queryType { get; set; }
        public String category { get; set; }
        public String subCategory { get; set; }
        public String subject { get; set; }
        public String description { get; set; }
        public Boolean attachFiles { get; set; }
        public Boolean isCaseCreated { get; set; }
        public Integer escalationLevel{ get; set; }
        public String comment { get; set; }

        // Constructor to initialize default values
        public CaseWrapper() {
            this.queryType = '';
            this.category = '';
            this.subCategory = '';
            this.subject = '';
            this.description = '';
            this.attachFiles = false;
            this.isCaseCreated = true;
            this.escalationLevel = 0; // Default escalation level is 1
        }
    }

    // Additional wrapper for attachments if needed
    public class AttachmentDataWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String fileURL;
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public DateTime createdDate;
    }
}