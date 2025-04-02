public class SendEmailToPortalConfirmedAccount {

    public static HttpCalloutMock mock = null; 
    private static Boolean isJobQueued = false;
    
    @InvocableMethod(label='Save Email to Portal Confirmed Account' description='Log emails to the portal Confirmed Account' category='EmailMessage')
    public static void callSaveEmailToPortalAPI(List<FlowInputs> request) {
        // if (!System.isFuture()) {
        //     CallWebService(request[0].templateName, request[0].recordId, request[0].type, request[0].parentId, request[0].mailId, request[0].fromEmailId, request[0].registrationNumber);
        // }
        if (!isJobQueued) {
            System.enqueueJob(new SendEmailToPortalQueueable(request[0].templateName, request[0].recordId, request[0].type, request[0].parentId, request[0].mailId, request[0].fromEmailId,request[0].registrationNumber));
            isJobQueued = true;
        }
    }

    // @future(callout=true)
    // public static void callWebService(String templateName,String recordId,String type,String parentId,String mailId,String fromEmailId,String registrationNumber) {
    // System.debug('callWebService123');
    // SendEmailToPortal.callWebServiceConfirmAccount(templateName,recordId,type,parentId, mailId, fromEmailId,registrationNumber);  
    // }
    public class FlowInputs {
        @InvocableVariable(required=true)
         public String templateName;
        @InvocableVariable(required=true)
         public String type;
        @InvocableVariable(required=true)
         public String recordId;
        @InvocableVariable(required=true)
         public String parentId;
        @InvocableVariable(required=true)
         public String mailId;
        @InvocableVariable(required=true)
         public String fromEmailId;
        @InvocableVariable(required=false description='please provide registrationNumber.')
        public String registrationNumber;
    }
}