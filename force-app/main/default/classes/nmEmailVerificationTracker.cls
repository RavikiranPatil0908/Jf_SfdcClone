/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-24-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   05-24-2021   @BK   Initial Version
**/
@isTest
public class nmEmailVerificationTracker{
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
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
          Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
    }
    static testMethod void TestMethod1() 
     {
       // LoadData();
       Test.startTest();
        lead  objLead =[select id,Email,MobilePhone,Mobile_Verification_Token__c from Lead limit 1];
        objLead.Mobile_Verification_Token__c = '1234';
        update objLead;
        apexpages.currentpage().getparameters().put('id',objLead.id+'-Lead-M-'+objLead.Mobile_Verification_Token__c);     
        nmEmailVerification objVE=new nmEmailVerification();
        objVE.VerifyEmailOrMobileNumber();
        Test.stopTest();   
     }
     static testMethod void TestMethod2() 
     {
      //  LoadData();
      
       lead  objLead =[select id,Email,MobilePhone from Lead limit 1];
       Test.startTest();
        apexpages.currentpage().getparameters().put('id',objLead.id+'-Lead-E');
        nmEmailVerification objVE=new nmEmailVerification();
        objVE.VerifyEmailOrMobileNumber();
        Test.stopTest();
     }
     
     public static testMethod void TestMethod3() 
     {
      //  LoadData();
       
         Test.setMock(HttpCalloutMock.class, new RestMock());
          Account objAccount = [select id,nm_LeadId__c,PersonEmail,PersonMobilePhone from Account  limit 1];
          Test.startTest();
        apexpages.currentpage().getparameters().put('id',objAccount.id+'-Account-E');        
        nmEmailVerification objVE=new nmEmailVerification();
        objVE.VerifyEmailOrMobileNumber();
        Test.stopTest();
     }
    
    public  static testMethod void TestMethod4() 
     {
      //  LoadData();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [select id,nm_LeadId__c,PersonEmail,PersonMobilePhone from Account  limit 1];
        Test.startTest();
        apexpages.currentpage().getparameters().put('id',objAccount.id+'-Account-M');         
        nmEmailVerification objVE=new nmEmailVerification();
        objVE.VerifyEmailOrMobileNumber();
        Test.stopTest();
     }
}