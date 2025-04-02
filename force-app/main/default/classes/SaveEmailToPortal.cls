/**
 * @description       :
 * @author            : @BK
 * @group             :
 * @last modified on  : 05-12-2024
 * @last modified by  : @BK
 **/

public class SaveEmailToPortal {
    public static HttpCalloutMock mock = null;

    @InvocableMethod(
        label='Save Email to Portal'
        description='Log emails to the portal'
        category='EmailMessage'
    )
    public static void callSaveEmailToPortalAPI(List<FlowInputs> request) {
        if (!System.isFuture()) {
            callWebService(
                request[0].subject,
                request[0].sapId,
                request[0].toMailId,
                request[0].body
            );
        }
    }

    @future(callout=true)
    public static void callWebService(
        String sub,
        String sap,
        String toMail,
        String content
    ) {
        SendEmailToPortal.callWebService(sub, content, sap, toMail);
    }

    public class FlowInputs {
        @InvocableVariable(required=true)
        public String subject;
        @InvocableVariable(required=true)
        public String toMailId;
        @InvocableVariable(required=true)
        public String body;
        @InvocableVariable(required=true)
        public String sapId;
    }
}