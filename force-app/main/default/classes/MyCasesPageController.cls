/**
 * @description       : Case handler
 * @author            : @Ravi
 * @last modified on  : 23--04--2025
 * @last modified by  : @Ravi
**/
public without sharing class MyCasesPageController {

    // Record Type for Lead Support Cases
    public static String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    public static String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
    
    // Instance variables
    public Id objectId;
    public String objectType;
    public String errorMsg {get;set;}
    public CaseDetail caseWrapper { get; set; }
    public Id selectedCaseId { get; set; }
    public List<CaseDetail> caseList { get; set; }
    public String caseFilterType {get;set;}
    public List<CaseComment> comments { get; set; }
 
    public String vfParam{get; set;}
    // Constructor to initialize the wrapper
    public MyCasesPageController() {
        caseWrapper = new CaseDetail();
        caseFilterType = 'Open';
        comments = new List<CaseComment>();
        selectedCaseId = null;
        errorMsg = '';
        System.debug('Record type Id : ' + ticket);
    }

    // Getter and setter for objectId
    public Id getObjectId() {
        return objectId;
    }

    public void setObjectId(Id objectId) {
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId)) {
            queryRecordData();
        }
    }

    //  for objectType
    public String getObjectType() {
        return objectType;
    }

    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    public void queryRecordData() {
        Id recordID = getObjectId();
        List<Case> caseDetails = new List<Case>();
        if(caseFilterType == 'Open') {
            caseDetails = [SELECT Id , CaseNumber, Subject, Status, CreatedDate, Expected_Close_Date__c,Student_Status__c, Student_In_Progress_Date__c,InProgressStartDate__c,RecordTypeId, AccountId, Query_Type__c, Lead__c,ClosedDate,Student_Category__c,Description,Student_Sub_Categories__c,Escalation_Level__c
                            FROM Case 
                            WHERE (RecordTypeId =: ticket) AND (AccountId =: recordID OR Lead__c =: recordID) AND Status!='Closed'
                            ORDER BY CreatedDate DESC];
        } else if(caseFilterType == 'Close') {
            caseDetails = [SELECT Id , CaseNumber, Subject, Status, CreatedDate, Expected_Close_Date__c, Student_Status__c, Student_In_Progress_Date__c,InProgressStartDate__c,RecordTypeId, AccountId, Query_Type__c, Lead__c,ClosedDate,Student_Category__c,Description,Student_Sub_Categories__c,Escalation_Level__c
                            FROM Case 
                            WHERE (RecordTypeId =: ticket) AND (AccountId =: recordID OR Lead__c =: recordID) AND Status='Closed'
                            ORDER BY CreatedDate DESC];
        } else if(caseFilterType == 'Feedback') {
            caseDetails = [SELECT Id , CaseNumber, Subject, Status, CreatedDate, Expected_Close_Date__c, Student_Status__c, Student_In_Progress_Date__c,InProgressStartDate__c,RecordTypeId, AccountId, Query_Type__c, Lead__c,ClosedDate,Student_Category__c,Description,Student_Sub_Categories__c,Escalation_Level__c
                            FROM Case 
                            WHERE (RecordTypeId =: feedback) AND (AccountId =: recordID OR Lead__c =: recordID)
                            ORDER BY CreatedDate DESC];
        }

        System.debug('caseList : ' + caseDetails);
        setCaseData(caseDetails);
    } 

    private void setCaseData(List<Case> caseRecords) {
        caseList = new List<CaseDetail>();
        for (Case obj : caseRecords) {
            CaseDetail objWrapper = new CaseDetail();
            objWrapper.caseId = obj.Id;
            objWrapper.createdDate = obj.CreatedDate;
            objWrapper.expectedCloseDate = obj.Expected_Close_Date__c;
            objWrapper.inProgressDate = obj.Student_In_Progress_Date__c;
            objWrapper.status = obj.Student_Status__c;
            objWrapper.subject = obj.Subject;
            objWrapper.caseNumber = obj.CaseNumber;
            objWrapper.closedDate = obj.ClosedDate;
            objWrapper.type = obj.RecordTypeId == ticket ? 'ticket' : 'feedback';
            objWrapper.queryType = obj.Query_Type__c;
            objWrapper.category = obj.Student_Category__c;
            objWrapper.subCategory = obj.Student_Sub_Categories__c;
            objWrapper.description = obj.Description;
            objWrapper.escalateButtonVisibility = obj.Expected_Close_Date__c < System.today() && (obj.Escalation_Level__c < 4 || obj.Escalation_Level__c == null) ? 'block' : 'none';
            objWrapper.escalationLevel = obj.Escalation_Level__c+'';
            caseList.add(objWrapper);
        }
    }
  
    /**
    * @description 
    * @author @Ravi | 10-02-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getSearchList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Open', 'My Open Tickets'));
        options.add(new SelectOption('Close', 'My Close Tickets'));
        options.add(new SelectOption('Feedback', 'My Feedbacks'));
        return options;
    }

    /**
    * @description   Get query types for case creation
    * @author @Ravi | 10-02-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getQueryTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption('Enquiry', 'Enquiry'));
        options.add(new SelectOption('Complaint', 'Complaint'));
        options.add(new SelectOption('Feedback', 'Feedback'));
        return options;
    }

    /** 
    * @description  :::Get subcategories for case creation
    * @author @Ravi | 10-02-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getSubCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption('Regarding Program', 'Regarding Program'));
        options.add(new SelectOption('Regarding Exams','Regarding Exams'));
        options.add(new SelectOption('Regarding Eligibility and Admission Process', 'Regarding Eligibility and Admission Process'));
        options.add(new SelectOption('Regarding Loan Options and Fees', 'Regarding Loan Options and Fees'));
        options.add(new SelectOption('Brochure', 'Brochure'));
        options.add(new SelectOption('Curriculum', 'Curriculum'));
        options.add(new SelectOption('Reasons other than the above', 'Reasons other than the above'));
        return options;
    }


    /**
    * @description   ::::::: Get categories for case creation
    * @author @Ravi | 10-02-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getCategories() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption('Need More Information', 'Need More Information'));
        options.add(new SelectOption('Ask to Call Back', 'Ask to Call Back'));
        options.add(new SelectOption('Counsellor Verification', 'Counsellor Verification'));
        options.add(new SelectOption('DND', 'DND'));
        options.add(new SelectOption('Others', 'Others'));
        return options;
    }
   
    /**
    * @description 
    * @author @Ravi | 10-02-2024 
    **/
    public void insertCase() {
        errorMsg = '';
        System.debug('objLead---' + objectId);
        Case c = validateStudent(objectId);
        if (c == null) {
            errorMsg = 'Record Details Not Found';
            return;
        }
        try {
            createCase(c);
        } catch (Exception e) {
            errorMsg = 'Internal Error Occured, Kindly try again Later';
            System.debug('Error-->' + e.getMessage());
        }
    }

    /**
    * @description  Method to validate lead and populate case fields
    * @author @Ravi | 10-02-2024 
    * @param objectId 
    * @return Boolean 
    **/
    public Case validateStudent(Id objectId) {
        Case c = new Case();
        if(getObjectType() == 'Lead') {
           
            List<Lead> leadLst = [SELECT Id, Name, MobilePhone, Email, nm_RegistrationNo__c, nm_InformationCenter__r.OwnerId FROM Lead WHERE Id=:objectId LIMIT 1];
            if(leadLst.isEmpty()) {
                return null;
            }
            System.debug(leadLst[0].Id);
            c.OwnerId = leadLst[0].nm_InformationCenter__r.OwnerId;
            c.Lead__c = leadLst[0].Id;
            c.SuppliedEmail = leadLst[0].Email;
            c.SuppliedName = leadLst[0].Name;
            c.Registration_No__c = leadLst[0].nm_RegistrationNo__c;
            System.debug('Case Object ==>'+c);
        } else if(getObjectType() == 'Account') {
            List<Account> accountLst = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c, nm_Centers__r.OwnerId FROM Account WHERE Id=:objectId LIMIT 1];
            if(accountLst.isEmpty()) {
                return null;
            }
            c.OwnerId = accountLst[0].nm_Centers__r.OwnerId;
            c.AccountId = accountLst[0].Id;
            c.ContactId = accountLst[0].PersonContactId;
            c.SuppliedEmail = accountLst[0].PersonEmail;
            c.SuppliedName = accountLst[0].Name;
            c.Registration_No__c = accountLst[0].nm_RegistrationNumber__c;
        }
        return c;
    }

    /**
    * @description  :::::::Method to create a new case
    * @author @Ravi | 10-02-2024 
    **/
    public void createCase(Case c) {
        try {
            System.debug('objLead---' + objectId + ' query type' + caseWrapper.queryType + 'category' + caseWrapper.category);
              DateTime dT = system.today();
    	      Date d = date.newinstance(dT.year(), dT.month(), dT.day());
            if(caseWrapper.queryType == 'Feedback'){
                c.Student_Status__c = 'Closed';
                c.Status = 'Closed';
                c.Tech_Issue__c = 'No';
                c.Query_Type__c = caseWrapper.queryType;
                c.Student_Category__c = caseWrapper.category;
                c.Student_Sub_Categories__c = caseWrapper.subCategory;
                c.Subject = caseWrapper.subject;
                c.Other_Category__c = caseWrapper.otherCategory;
                c.Description = caseWrapper.description;
                c.RecordTypeId = feedback; 
            } else {
                c.Query_Type__c = caseWrapper.queryType;
                c.Student_Category__c = caseWrapper.category;
                c.Student_Sub_Categories__c = caseWrapper.subCategory;
                c.Subject = caseWrapper.subject;
                c.Other_Category__c = caseWrapper.otherCategory;
                c.Description = caseWrapper.description;
                c.RecordTypeId = ticket;
                // c.Expected_Close_Date__c =  System.today().addDays(2);
                 Case__c mcs = Case__c.getValues(caseWrapper.category);
                Integer tat = Integer.valueOF(mcs.TAT__c);
                Integer diff = MyCasesController.getNumberOfDays(System.today(), d.addDays(tat));
                if(diff < tat){
                    Integer actualTat = tat + (tat-diff);
                    c.Expected_Close_Date__c = d.addDays(actualTat);
                }else{
                    c.Expected_Close_Date__c = d.addDays(tat);
                }
                c.nm_Category__c = 'Learning Center';
            }   

            System.debug('Case record object' + c);
            insert c;
            
            caseWrapper.caseId = c.Id;
            System.debug('case record'+ c.Id);
        } catch (Exception e) {
            errorMsg = 'Case Created error message: ' + e.getMessage();
            System.debug('Case Created error message: ' + e.getMessage());
        }
    }

    

    public void escalateTicket(String caseId){ 
        System.debug('caseId123 '+caseId);
        
        Case c = [SELECT Status, Count_of_ECD_changed_By_System__c, Escalated_Date__c, Escalation_Level__c, Escalation_Email__c, Expected_Close_Date__c, 
        isCallback__c, Grievance_Escalation_Days__c, Head_Escalation_Days__c, Manager_Escalation_Days__c,OwnerId FROM Case WHERE Id = :caseId];   
        
     //   obj.Expected_Close_Date__c < System.now() ? 'block' : ''; // for backend validation
        if(c.Expected_Close_Date__c < System.today()){
        Integer level = Integer.valueOf(c.Escalation_Level__c);
        System.debug('caseId1234 '+caseId);
        System.debug('level-->' + level+ +c.Expected_Close_Date__c +' : '+ System.today());
        if(level == 0 || level == null){  
           c.Escalation_Level__c = 1;           
        }
        else if(level == 1){
           c.Escalation_Level__c = 2;
        }
        else if(level == 2){
           c.Escalation_Level__c = 3;     
        }
        else if(level == 3){
           c.Escalation_Level__c = 4; 
        }
        c.Expected_Close_Date__c = System.today().addDays(2);
        c.Escalated_Date__c = System.today();        
        update c;
    }
    }

    public PageReference doActionFunction(){
        // Do Something...
        System.debug('vfParam : ' + vfParam);
        escalateTicket(vfParam);
        return null;
    }

    

    public class CaseDetail {
        public CaseDetail() {
            this.caseId = null;
            this.createdDate = null;
            this.expectedCloseDate = null;
            this.inProgressDate = null;
            this.status = '';
            this.subject = '';
            this.type = '';
            this.caseNumber = '';
            this.closedDate = null;
            this.queryType = '';
            this.category = '';
            this.subCategory = '';
            this.otherCategory = '';
            this.description = '';
            this.escalateButtonVisibility = '';
            this.escalationLevel = '';
           
        }

        public Id caseId {get;set;}
        public String subject {get;set;}
        public String status {get;set;}
        public DateTime createdDate {get;set;}
        public Date expectedCloseDate {get;set;}
        public DateTime inProgressDate {get;set;}
        public String type {get;set;}
        public String caseNumber {get;set;}
        public DateTime closedDate {get;set;}
        public String queryType { get; set; }
        public String category { get; set; }
        public String subCategory { get; set; }
        public String otherCategory { get; set; }
        public String description { get; set; }
        public String escalateButtonVisibility { get; set; }
        public String escalationLevel { get; set; }
      
    }

    
}