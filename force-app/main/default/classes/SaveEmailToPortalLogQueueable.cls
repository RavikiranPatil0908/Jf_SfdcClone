public class SaveEmailToPortalLogQueueable implements Queueable, Database.AllowsCallouts {
    private SaveMailLogWrapper mailLogWrapper;
    
    public SaveEmailToPortalLogQueueable(SaveMailLogWrapper mailLogWrapper) {
        this.mailLogWrapper = mailLogWrapper;
    }

    public void execute(QueueableContext context) {
        System.debug('Executing SaveEmailToPortalQueueable');
        SendEmailToPortal.callWebServiceSaveLog(mailLogWrapper);
    }
}