public class SendEmailToPortalQueueable implements Queueable, Database.AllowsCallouts {
    private String templateName;
    private String recordId;
    private String type;
    private String parentId;
    private String mailId;
    private String fromEmailId;
    private String registrationNumber;

    public SendEmailToPortalQueueable(String templateName, String recordId, String type, String parentId, String mailId, String fromEmailId,String registrationNumber) {
        this.templateName = templateName;
        this.recordId = recordId;
        this.type = type;
        this.parentId = parentId;
        this.mailId = mailId;
        this.fromEmailId = fromEmailId;
        this.registrationNumber = registrationNumber;
    }

    public void execute(QueueableContext context) {
        SendEmailToPortal.callWebServiceConfirmAccount(templateName, recordId, type, parentId, mailId, fromEmailId,registrationNumber);
    }
}