/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 24-05-2025
 * @last modified by  : @Shailesh
**/
public  class SaveEmailToPortalLogQueueableBatch implements Queueable, Database.AllowsCallouts{
    private List<SendEmailToPortalSaveLog.FlowInputs> request;
    public SaveEmailToPortalLogQueueableBatch(List<SendEmailToPortalSaveLog.FlowInputs> request) {
        this.request = request;
    }

    public void execute(QueueableContext context) {
        System.debug('Executing SaveEmailToPortalLogQueueableBatch');
        SendEmailToPortal.callbatchWebServiceSaveLog(request);
    }
}