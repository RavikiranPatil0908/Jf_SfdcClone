/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-12-2024
 * @last modified by  : @BK
**/
public without sharing class SendEmailToPortal {

    // Constants for static values
    private static final String BASE_URL = System.Label.Student_Portal + 'm/insertEmailsEntryToPortal';
    private static final String CONFIRM_ACCOUNT_URL = System.Label.Student_Zone_Base_Url + 'salesforce-emailLogs/m/saveSfdcEmailLog';
    private static final String FROM_MAIL_ID = 'donotreply.cdoe@nmims.edu';
    
    // Utility method to send the email and handle HTTP request
    private static void sendEmailRequest(String endpointUrl, String fromEmailId, String toEmailId, String body, String requestBody, String recordId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try {
            if( System.label.Environment == 'Production' && !Test.isRunningTest()){ //
                response = http.send(req);
            }
      //  if (System.Label.Environment == 'Production' || Test.isRunningTest()) {
            
               // response = http.send(req);
                String objectType = getObjectName(recordId);
                // Log response based on status
                if (!Test.isRunningTest() && response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    APIRequestHandler.insertAPIRequest(requestBody, responseBody, 'SendEmailToPortal', true, recordId, objectType, 'PortalAPI');
                } else {
                    APIRequestHandler.insertAPIRequest(requestBody, response.getBody(), 'SendEmailToPortal', false, recordId, objectType, 'PortalAPI');
                    System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
                }
            } catch (Exception e) {
                System.debug('Error sending HTTP request: ' + e.getMessage());
            }
       // }
    }

    // Method to handle common email template processing
    private static EmailDetails processEmailTemplate(String templateName, String recordId, String type) {
        
        String whoId = (type == 'who') ? recordId : null;
        String whatId = (type == 'what') ? recordId : null;

        // Fetch the email template
        List<EmailTemplate> emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1];
        if (emailTemplate.isEmpty()) {
            System.debug('Email template not found: ' + templateName);
            return null;  // Return null if template is not found
        }
        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, whoId, whatId);
        String emailBody = email.getHtmlBody();
        
        // Minify HTML or fallback to plain text body
        if (String.isBlank(emailBody) || emailBody.containsIgnoreCase('"')) {
            emailBody = email.getPlainTextBody();
        } else {
            emailBody = HtmlMinifier.minifyHtml(emailBody);
        }

        return new EmailDetails(emailBody, email.getSubject());
    }

    private static String getObjectName(String recordId) {
        try {
            return String.isBlank(recordId) ? null : Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        } catch (Exception error) {
            System.debug('Error Message = '+error.getMessage());
        }
        return null;
    }

    // First method to send email
    public static void callWebService(String templateName, String recordId, String type, String sapId, String toMailId, String fromMailId) {
        System.debug('callWebService triggered for Record ID: ' + recordId);

        // Process the email template
        EmailDetails objDetails = processEmailTemplate(templateName, recordId, type);
        if (objDetails.emailBody == null) return; // If template is not found, exit method

        // Prepare request body map
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('subject', objDetails.emailSubject);  // Customize subject if needed
        requestBodyMap.put('fromEmailId', fromMailId);
        requestBodyMap.put('sapid', sapId);
        requestBodyMap.put('mailId', toMailId);
        requestBodyMap.put('body', objDetails.emailBody);

        String requestBody = JSON.serialize(requestBodyMap);

        // Send email request to portal
        sendEmailRequest(BASE_URL, fromMailId, toMailId, objDetails.emailBody, requestBody, recordId);
    }

    // Second method to send email (Confirmation)
    public static void callWebServiceConfirmAccount(String templateName, String recordId, String type, String parentId, String mailId, String fromEmailId,String registrationNumber) {
        System.debug('callWebServiceConfirmAccount triggered for Parent ID: ' + parentId);

        // Process the email template
        EmailDetails objDetails = processEmailTemplate(templateName, recordId, type);
        if (objDetails.emailBody == null) return; // If template is not found, exit method

        // Prepare request body map
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('subject', objDetails.emailSubject);  // Customize subject if needed
        requestBodyMap.put('fromEmailId', fromEmailId);
        requestBodyMap.put('parentId', parentId); 
        requestBodyMap.put('registrationNumber', registrationNumber);
        requestBodyMap.put('mailId', mailId);
        requestBodyMap.put('body', objDetails.emailBody);

        String requestBody = JSON.serialize(requestBodyMap);

        // Send email request to confirm account
        sendEmailRequest(CONFIRM_ACCOUNT_URL, fromEmailId, mailId, objDetails.emailBody, requestBody, parentId);
    }

    // Third method to send email using Body
    public static void callWebService(String emailSubject, String emailBody, String sapId, String toMailId) {
        System.debug('callWebService triggered for sapId: ' + sapId);
        //sapId = '77777777143';
        // Prepare request body map
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('subject', emailSubject);  // Customize subject if needed
        requestBodyMap.put('fromEmailId', FROM_MAIL_ID);
        requestBodyMap.put('sapid', sapId);
        requestBodyMap.put('mailId', toMailId);
        requestBodyMap.put('body', emailBody);

        String requestBody = JSON.serialize(requestBodyMap);
        System.debug('callWebService triggered for sapId: ' + sapId);
        System.debug('callWebService requestBody: ' + requestBody);
        // Send email request to portal
        sendEmailRequest(BASE_URL, FROM_MAIL_ID, toMailId, emailBody, requestBody, null);
    }

    // Fourth method to send email (Confirmation)
    public static void callWebServiceSaveLog(SaveMailLogWrapper saveMailLog) {
        System.debug('callWebServiceSaveLog triggered for Parent ID: ' + saveMailLog.parentId);
        EmailDetails objDetails;
        // Process the email template
        if(saveMailLog.mailbodytype == 'template'){
            objDetails = processEmailTemplateById(saveMailLog.templateId, saveMailLog.recordId, saveMailLog.type);
            if (objDetails.emailBody == null) return; // If template is not found, exit method
        }
        
        // Prepare request body map
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('subject', saveMailLog.mailbodytype == 'template' ? objDetails.emailSubject : saveMailLog.mailSubject);  // Customize subject if needed
        requestBodyMap.put('fromEmailId', saveMailLog.fromEmailId);
        requestBodyMap.put('parentId', saveMailLog.parentId);
        requestBodyMap.put('mailId', saveMailLog.mailId);
        requestBodyMap.put('body', saveMailLog.mailbodytype == 'template' ? objDetails.emailBody : saveMailLog.mailbody);
        requestBodyMap.put('registrationNumber', saveMailLog.registrationNumber);  // add regId here
        String requestBody = JSON.serialize(requestBodyMap);

        // Send email request to confirm account
        sendEmailRequest(CONFIRM_ACCOUNT_URL, saveMailLog.fromEmailId, saveMailLog.mailId, saveMailLog.mailbodytype == 'template' ? objDetails.emailBody : saveMailLog.mailbody, requestBody, saveMailLog.parentId);
    }

    private static EmailDetails processEmailTemplateById(String templateId, String recordId, String type) {
        
        String whoId = (type == 'who') ? recordId : null;
        String whatId = (type == 'what') ? recordId : null;

        // Fetch the email template
        List<EmailTemplate> emailTemplate = [SELECT Id FROM EmailTemplate WHERE Id = :templateId LIMIT 1];
        if (emailTemplate.isEmpty()) {
            System.debug('Email template not found: ' + templateId);
            return null;  // Return null if template is not found
        }
        
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, whoId, whatId);
        String emailBody = email.getHtmlBody();
        
        // Minify HTML or fallback to plain text body
        if (String.isBlank(emailBody) || emailBody.containsIgnoreCase('"')) {
            emailBody = email.getPlainTextBody();
        } else {
            emailBody = HtmlMinifier.minifyHtml(emailBody);
        }

        return new EmailDetails(emailBody, email.getSubject());
    }

    public class EmailDetails {
        public String emailBody;
        public String emailSubject;

        public EmailDetails(String emailBody, String emailSubject) {
            this.emailBody = emailBody;
            this.emailSubject = emailSubject;
        }
    }
}