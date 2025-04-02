public without sharing class SendEmailToPortalSaveLog {
    public static HttpCalloutMock mock = null; 
    private static Boolean isJobQueued = false;
    
    @InvocableMethod(label='Save Email to Portal Save Log' description='Log emails to the portal Save Log' category='EmailMessage')
    public static void callSaveEmailToPortalAPI(List<FlowInputs> request) {
        // if (!System.isFuture()) {
        //     CallWebService(request[0].templateId, request[0].recordId, request[0].type, request[0].parentId, request[0].mailId, request[0].fromEmailId, request[0].mailBody, request[0].mailBodytype,request[0].mailSubject,request[0].registrationNumber);
        // }
        SaveMailLogWrapper mailLogWrapper = new SaveMailLogWrapper(
            request[0].templateId, request[0].type, request[0].recordId,
            request[0].parentId, request[0].mailId, request[0].fromEmailId,
            request[0].mailBody, request[0].mailBodytype, request[0].mailSubject,request[0].registrationNumber
        );
        if (!isJobQueued) {
            System.enqueueJob(new SaveEmailToPortalLogQueueable(mailLogWrapper));
            isJobQueued = true;
        }
    }
    // @future(callout=true)
    // public static void callWebService(String templateId,String recordId,String type,String parentId,String mailId,String fromEmailId,String mailbody,String mailbodytype,String mailSubject,String registrationNumber) {
    // System.debug('callWebService123');
    // SendEmailToPortal.callWebServiceSaveLog(new SaveMailLogWrapper( templateId, type, recordId, parentId, mailId, fromEmailId, mailbody, mailbodytype,mailSubject,registrationNumber));  

    // }
    public class FlowInputs {
        @InvocableVariable(required=false)
         public String templateId;
        @InvocableVariable(required=false)
         public String type;
        @InvocableVariable(required=true)
         public String recordId;
        @InvocableVariable(required=true)
         public String parentId;
        @InvocableVariable(required=true)
         public String mailId;
        @InvocableVariable(required=true)
         public String fromEmailId;
        @InvocableVariable(required=false)
         public String mailBody;
        @InvocableVariable(required=false)
         public String mailSubject;
        @InvocableVariable(required=true description='For Mailtemplate value is template and For Mailbody value is mailbody')
         public String mailBodytype;
        @InvocableVariable(required=false description='please provide registrationNumber.')
         public String registrationNumber;
         
         
    }
}