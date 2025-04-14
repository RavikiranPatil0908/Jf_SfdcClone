/**
 * @File Name          : nmSendNotificationTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 09--04--2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    14/8/2019, 3:20:26 PM   @BK     Initial Version
**/
@isTest
public class nmSendNotificationTracker 
{
     public static Account objAccount;
     public static Lead objLead;
      private class RestMock implements HttpCalloutMock {
        RestMock() {}

        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    static testMethod void sendVerificationEmailToLead()
    {
        LoadData();
        nmSendNotification.sendVerificationEmailToStudent('test@gmail.com','lc@gmail.com','test','lead',objLead.Id);
        nmSendNotification.sendVerificationSMSToStudent('8888888888','PGDBFM','071116','Registration No.','Lead','ox00123');
        nmSendNotification.UpdateDateAndTimeOfRequest(objLead.id,'Success','Email Sent');  
        nmSendNotification.sendEmailOTPToStudent('test@gmail.com','Registration No.','fhdh gff');
        nmSendNotification.sendSMSToDNDActiveStudent('8888888888','Bala');
    }

    static testMethod void sendVerificationEmailToAccount()
    {
        LoadData();
        nmSendNotification.sendVerificationEmailToStudent('test@gmail.com','lc@gmail.com','test','Account','0ahhgvhgh');
        nmSendNotification.sendVerificationSMSToStudent('8888888888','PGDBFM','071116','Registration No.','Account','ox00123');
        nmSendNotification.UpdateDateAndTimeOfRequest(objAccount.id,'Success','Email Sent');  
        nmSendNotification.UpdateDateAndTimeOfRequest(objAccount.id,'Success','SMS Sent'); 
        nmSendNotification.sendSMSToNoResponseStudent('8888888888');
    }

    public static void LoadData()
    {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');                
    }   
}