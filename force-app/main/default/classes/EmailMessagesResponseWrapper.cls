/**
 * @File Name          : EmailMessagesResponseWrapper.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20/6/2020, 1:22:44 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/6/2020   @BK     Initial Version
**/
global class EmailMessagesResponseWrapper {
    @auraEnabled public String id;
    @auraEnabled public String parentId;
    @auraEnabled public String caseNumber;
    @auraEnabled public String caseStatus;
    @auraEnabled public String createdById;
    @auraEnabled public String createdDate;
    @auraEnabled public String lastModifiedById;
    @auraEnabled public String lastModifiedDate;
    @auraEnabled public String systemModstamp;
    @auraEnabled public String textBody;
    @auraEnabled public String htmlBody;
    @auraEnabled public String subject;
    @auraEnabled public String fromName;
    @auraEnabled public String fromAddress;
    @auraEnabled public String toAddress;
    @auraEnabled public String ccAddress;
    @auraEnabled public String bccAddress;
    @auraEnabled public Boolean incoming;
    @auraEnabled public Boolean hasAttachment;
    @auraEnabled public String status;
    @auraEnabled public String messageDate;
    @auraEnabled public Boolean isPrivateDraft;
    @auraEnabled public Boolean isDeleted;
    @auraEnabled public Boolean isExternallyVisible;
    @auraEnabled public Boolean isClientManaged;
    @auraEnabled public Boolean isTracked;
    @auraEnabled public Boolean isBounced;
    @auraEnabled public Boolean success;
    @auraEnabled public Boolean error;
    @auraEnabled public Boolean isPrivate;
    @auraEnabled public List<Attachments> attachments;

    public class Attachments {
        @auraEnabled public String id;
        @auraEnabled public String parentId;
        @auraEnabled public Boolean isDeleted;
        @auraEnabled public String attachmentId;
        @auraEnabled public String name;
        @auraEnabled public String attachmentBody;
        @auraEnabled public String bodyLength;
        @auraEnabled public String contentType;
        @auraEnabled public Boolean isPrivate;
        @auraEnabled public String ownerId;
    }

    
    public static List<EmailMessagesResponseWrapper> parse(String json) {
        return (List<EmailMessagesResponseWrapper>) System.JSON.deserialize(json, List<EmailMessagesResponseWrapper>.class);
    }
}