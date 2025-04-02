/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 29-10-2024
 * @last modified by  : @BK
**/
public without sharing class CreateCasePageController {

    public Id caseId;
    public CaseWrapper caseWrapper { get; set; }
    public CaseCommentDetail objComment {get;set;}
    public String errorMsg {get;set;}

    public CreateCasePageController() {
        caseWrapper = new CaseWrapper();
        objComment = new CaseCommentDetail();
        errorMsg = '';
    }

    public Id getCaseId() {
        return caseId;
    }

    public void setCaseId(Id caseId) {
        this.caseId = caseId;
        if(String.isNotBlank(this.caseId)) {
            queryCaseData(this.caseId);
        }
    }

    public void queryCaseData(Id recordID) {
        List<Case> caseRecords = [SELECT CaseNumber, Subject ,Description ,Student_Category__c, Student_Sub_Categories__c, Other_Category__c, CreatedDate, Status, Expected_Close_Date__c,ClosedDate,RecordType.Name FROM Case WHERE Id = :recordID LIMIT 1];
        if(!caseRecords.isEmpty()) {
            Case c = caseRecords[0];
            system.debug('case_details'+c.CaseNumber+' '+c.CreatedDate+' '+c.closedDate);

            caseWrapper.caseId = c.Id;
            caseWrapper.caseNumber = c.CaseNumber;
            caseWrapper.subject = c.Subject;
            caseWrapper.description = c.Description;
            caseWrapper.category = c.Student_Category__c;
            caseWrapper.subCategory = c.Student_Sub_Categories__c;
            caseWrapper.otherCategory = c.Other_Category__c;
            caseWrapper.Status = c.Status;
            caseWrapper.createdDate = c.CreatedDate;
            caseWrapper.expectedCloseDate = c.Expected_Close_Date__c;
            CaseWrapper.isOpen = c.Status != 'Closed' ? true : false;
            caseWrapper.isFeedback = c.RecordType.Name == 'Student Feedbacks' ? true : false;
            caseWrapper.isCaseCreated = true;
            caseWrapper.closedDate = c.ClosedDate;
            
        }
    }

    public void addCaseComment() {
        errorMsg = '';
        System.debug('actionType ==>'+objComment.actionType);
        if(String.isBlank(objComment.comment) || String.isBlank(objComment.actionType)) {
            errorMsg = 'Comment cannot be blank';
            return;
        }

        try {
            insertComment();
            if(objComment.actionType == 'CloseTicket') {
                closeTicket();
            } else if(objComment.actionType == 'ReOpen'){
                reOpenTicket();
            }
        } catch (Exception e) {
            errorMsg = 'Internal Error Occured - ' + e.getMessage();
            System.debug('Error ==>'+e.getMessage());
            System.debug('Error ==>'+e.getLineNumber());
        }
    }

    /**
    * @description 
    * @author @Ravi | 10-02-2024 
    **/
    public void insertComment() {
        CaseComment comm = new CaseComment();
        comm.CommentBody = objComment.comment;
        comm.ParentId = getCaseId();
        comm.IsPublished = true;
        insert comm;

        // update status to response recieved
        if(objComment.actionType == 'AddComment') {
            Case c = [SELECT Status,OwnerId FROM Case WHERE Id = :caseId];
            List<Group> lstQueues = [SELECT Id,Name,DeveloperName,Email,Type FROM Group WHERE Type='Queue' AND Name='Omni Queue Backup Case' LIMIT 1];
            if(c.Status != 'Closed' && (c.OwnerId.getSobjectType()!=Group.SobjectType || (lstQueues.size() > 0 && lstQueues[0].Id != c.OwnerId))){
                c.Status = 'Response Received';
                update c;
            }
        }
    }

    /**
    * @description 
    * @author @Ravi | 23--10--2024 
    **/
    public void reOpenTicket() {
        Case c = new Case();
        // Case c = [SELECT Status, Expected_Close_Date__c, Escalation_Level__c, Student_Category__c ,Reason_for_Re_Opening_Case__c FROM Case WHERE Id = :caseId];
        c.id=getCaseId();
        c.Status = 'Re-Open';
        c.Reason_for_Re_Opening_Case__c = objComment.reasonForReOpen;
        update c;
    }

    /**
    * @description 
    * @author @Ravi | 10-02-2024 
    **/
    public void closeTicket() {
        Case c = new Case(  id = getCaseId(), Status = 'Closed');
        update c;
    }

    public class CaseWrapper {
        public string actionType { get; set; }
        public Id caseId { get; set; }
        public String caseNumber { get; set; }
        public String queryType { get; set; }
        public String category { get; set; }
        public String subCategory { get; set; }
        public String otherCategory {get;set;}
        public String subject { get; set; }
        public String description { get; set; }
        public Boolean attachFiles { get; set; }
        public Boolean isCaseCreated { get; set; }
        public String comment { get; set; }
        public Integer escalationLevel { get; set; }
        public String searchKeyword { get; set; }
        public DateTime createdDate { get; set; }
        public Date expectedCloseDate { get; set; }
        public String Status { get; set; }
        public Boolean isCommentsAvailble { get; set; }
        public Boolean isAttachmentsAvailble { get; set; }
        public Boolean isCallsAvailable { get; set; }
        public DateTime ClosedDate { get; set; }
        // public Boolean isClosed { get; set; }
        public Boolean isOpen { get; set; }
        public Boolean isFeedback {get;set;}

        // Constructor to initialize default values
        public CaseWrapper() {
            this.queryType = '';
            this.category = '';
            this.subCategory = '';
            this.otherCategory = '';
            this.subject = '';
            this.description = '';
            this.attachFiles = false;
            this.isCaseCreated = false;
            this.comment = '';
            this.escalationLevel = 0;
            this.searchKeyword = '';
            this.isCommentsAvailble = false;
            this.isAttachmentsAvailble =false;
            this.isCallsAvailable = false;
            // this.isClosed = false;
            this.isOpen = false;
            this.isFeedback = false;
        }
    }

    public class CaseCommentDetail {
        public CaseCommentDetail() {
            this.comment = '';
            this.actionType = 'AddComment';
            this.isAttachment = false;
            this.reasonForReOpen = '';
        }

        public String comment {get;set;}
        public Boolean isAttachment {get;set;}
        public String actionType {get;set;}
        public String reasonForReOpen {get;set;}
    }
}