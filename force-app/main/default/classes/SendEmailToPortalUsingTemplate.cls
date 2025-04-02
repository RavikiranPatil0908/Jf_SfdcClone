/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
public class SendEmailToPortalUsingTemplate {
    public static HttpCalloutMock mock = null;
    
    @InvocableMethod(label='Save Email to Portal Using Template' description='Log emails to the portal' category='EmailMessage')
    public static void callSaveEmailToPortalAPI(List<FlowInputs> request) {
        if (!System.isFuture()) {
            CallWebService(request[0].templateName, request[0].recordId, request[0].type, request[0].sapId, request[0].toMailId, request[0].fromMailId);
        }
    }

    @future(callout=true)
    public static void callWebService(String templateName,String recordId,String type,String sapId,String toMailId,String fromMailId) {
    System.debug('callWebService123');
    SendEmailToPortal.callWebService(templateName, recordId, type, sapId, toMailId, fromMailId);  
    }
    public class FlowInputs {
        @InvocableVariable(required=true)
         public String templateName;
        @InvocableVariable(required=true)
         public String recordId;
        @InvocableVariable(required=true)
         public String type;
        @InvocableVariable(required=true)
         public String sapId;
        @InvocableVariable(required=true)
         public String toMailId;
        @InvocableVariable(required=true)
         public String fromMailId;
    }
}