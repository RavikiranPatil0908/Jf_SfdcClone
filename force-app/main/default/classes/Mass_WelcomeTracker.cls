/**
 * @File Name          : Mass_WelcomeTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20/12/2019, 11:26:16 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    20/12/2019   @BK     Initial Version
**/
@istest (SeeAllData=false)
public class Mass_WelcomeTracker
{
   private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
 @testSetup
    public static void setUpData(){
    Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
    }       
    public static testmethod void welcomeletterTest(){
        Test.startTest();
        
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        objAccount.nm_StudentNo__c = '77216433684';
        update objAccount;
        
        Mass_Welcome controller = new Mass_Welcome();
        controller.search();
        controller.find();

        // After with student number.
        controller.StudentNumber = objAccount.nm_StudentNo__c;
        controller.search();
        controller.find();

        Test.stopTest();
    }
}