/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-10-2024
 * @last modified by  : @BK
**/
public without sharing class CaseRelatedActivityController {

    public Id caseId;
    public CaseActivityWrapper objWrapper {get;set;}

    public CaseRelatedActivityController() {
        objWrapper = new CaseActivityWrapper();
    }

    // Getter and setter for caseId
    public Id getCaseId() {
        return caseId;
    }

    public void setCaseId(Id caseId) {
        this.caseId = caseId;
        if(String.isNotBlank(this.caseId)) {
            objWrapper.lstComments = getCaseComments(this.caseId);
            objWrapper.isCommentExists = !objWrapper.lstComments.isEmpty() ? true : false;
            objWrapper.lstAttachments = getCaseAttachments(this.caseId);
            objWrapper.isAttachmentExists = !objWrapper.lstAttachments.isEmpty() ? true : false;
        }
    }

    /**
    * @description 
    * @author @BK | 10-06-2024 
    * @param recordId 
    * @return List<CaseCommentData> 
    **/
    public List<CaseCommentData> getCaseComments(Id recordId){
        List<CaseCommentData> lstComment = new List<CaseCommentData>();
        try {
            Case c = [SELECT Id, Lead__r.Name,Account.Name,AccountId FROM Case WHERE id=:recordId LIMIT 1];
            String studentName = c.AccountId != null ? c.Account.Name : c.Lead__r.Name;
            for (CaseComment em : [select Id, CreatedDate, CreatedBy.Name, CommentBody FROM CaseComment WHERE ParentId = :recordId ORDER BY CreatedDate DESC]) {
                CaseCommentData obj = new CaseCommentData();
                obj.comment = em.CommentBody;
                obj.createdDate = em.CreatedDate;
                String createdBy = em.CreatedBy.Name;
                String[] nameParts = createdBy.split(' ');
                String formattedName = nameParts.size() > 1 ? nameParts[0] + ' ' + nameParts[1].substring(0, 1) : nameParts[0];

                obj.userName = (createdBy == 'NMIMS Site Guest User' || createdBy == 'Admin User') 
                                ? studentName
                                : formattedName;
                lstComment.add(obj);
            }
        } catch (Exception error) {
            System.debug('Get Case Comments Error =>'+error.getMessage());
        }
        
        return lstComment;
    }

    /**
    * @description 
    * @author @BK | 10-06-2024 
    * @param recordId 
    * @return List<AttachmentData> 
    **/
    public List<AttachmentData> getCaseAttachments(Id recordId) {
        List<AttachmentData> lstData = new List<AttachmentData>();
        try {
            Set<Id> docIdSet = new Set<Id>();
            Map<Id,ContentDocumentLink> mapOfIdVsfile = new Map<Id,ContentDocumentLink>();
            for(ContentDocumentLink doc : [Select ContentDocumentId,ContentDocument.Title, ContentDocument.LatestPublishedVersionId
                            from ContentDocumentLink where LinkedEntityId =:recordId]){
                docIdSet.add(doc.ContentDocumentId);
                mapOfIdVsfile.put(doc.ContentDocumentId,doc);
            }

            if(docIdSet.size() > 0) {
                List<ContentDistribution> lstpublicUrl = [SELECT Id,DistributionPublicUrl,ContentDocumentId,Name,ContentVersionId,CreatedDate FROM ContentDistribution WHERE ContentDocumentId IN : docIdSet];
                if(lstpublicUrl.size() > 0) {
                    for (ContentDistribution objCD : lstpublicUrl) {
                        AttachmentData objData = new AttachmentData();
                        objData.name = objCD.Name;
                        objData.fileURL = objCD.DistributionPublicUrl;
                        objData.recordId = objCD.Id;
                        objData.createdDate = objCD.CreatedDate;
                        lstData.add(objData);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error ==>'+ e.getMessage());
            System.debug('Error ==>'+ e.getLineNumber());
        }
        return lstData;
    }

    public class CaseActivityWrapper {
        public CaseActivityWrapper() {
            this.lstAttachments = new List<AttachmentData>();
            this.isAttachmentExists = false;
            this.lstComments = new List<CaseCommentData>();
            this.isCommentExists = false;
        }
        public List<CaseCommentData> lstComments {get;set;}
        public Boolean isCommentExists {get;set;}
        public List<AttachmentData> lstAttachments {get;set;}
        public Boolean isAttachmentExists {get;set;}
    }

    public class AttachmentData {
        public AttachmentData() {
            this.name = '';
            this.fileURL = '';
            this.recordId = '';
            this.createdDate = null;
        }
        public String name {get;set;}
        public String fileURL {get;set;}
        public String recordId {get;set;}
        public DateTime createdDate {get;set;}
    }

    public class CaseCommentData {
        public CaseCommentData() {
            this.createdDate = null;
            this.userName = '';
            this.comment = '';
        }
        public DateTime createdDate {get;set;}
        public String userName {get;set;}
        public String comment {get;set;}
    }
}