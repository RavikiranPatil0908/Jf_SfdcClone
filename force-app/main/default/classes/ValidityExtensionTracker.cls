/**
 * @File Name          : ValidityExtensionTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 23/10/2019, 11:26:58 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    23/10/2019   @BK     Initial Version
**/
@isTest(seeAllData=false)
public class ValidityExtensionTracker
{
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

      @TestSetup
      static void makeData(){
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',true,'Admission form & documents submitted');
            Opportunity objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
            nmGenericTracker.CreateOpportunityLineItem(objopp);
      }

      @isTest 
      static void unitTest1() {
            Account objAccount = [SELECT Id FROM Account Limit 1];
            Test.startTest();
                  ApexPages.currentPage().getParameters().put('id',objAccount.Id);
                  ValidityExtension objExtension = new ValidityExtension();
                  objExtension.ProceedToPaymentPage();
                  objExtension.Logout();
            Test.stopTest();
      }

}