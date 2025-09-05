/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 27-05-2025
 * @last modified by  : @Shailesh
**/
public class SendEmailToPortalQueueableBatch implements Queueable, Database.AllowsCallouts{

    private List<SendEmailToPortalConfirmedAccount.FlowInputs> request = new List<SendEmailToPortalConfirmedAccount.FlowInputs>();
    public SendEmailToPortalQueueableBatch(List<SendEmailToPortalConfirmedAccount.FlowInputs> request) {
        this.request = request;
    }
 
    public void execute(QueueableContext context) {
        SendEmailToPortal.callBatchWebServiceConfirmAccount(request);
    }
}