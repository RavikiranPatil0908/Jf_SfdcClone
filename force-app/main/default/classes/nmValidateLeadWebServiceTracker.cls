/**
 * @File Name          : nmValidateLeadWebServiceTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 08-06-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/9/2019   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class nmValidateLeadWebServiceTracker 
{
   private class RestMock implements HttpCalloutMock {
      RestMock() {
      }
      public HTTPResponse respond(HTTPRequest req) {
         // Can assert that the request is correct here
         // Generate a typical response
         String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
         HTTPResponse res = new HTTPResponse();
         res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
         res.setBody(fullJson);
         res.setStatusCode(200);
         return res;
      }
   }
   
   @TestSetup
   static void makeData(){
      //Initial Test Data
      //Add Logic to Create data required
      Test.setMock(HttpCalloutMock.class, new RestMock());
      nmGenericTracker.InsertSerialNo();
      Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
      nmGenericTracker.CreateWorkExperienceForLead(objLead);
      objLead.Student_Number_Lateral__c = '77051291234';
      update objLead;
   }

   @isTest
   static void testMethod1() {
      Lead objLead = [SELECT Id FROM Lead LIMIT 1];
      Test.StartTest();
         nmValidateLeadWebService instance = new nmValidateLeadWebService();
         nmValidateLeadWebService.ValidateLead(objLead.id);
      Test.StopTest();
   }

   @isTest
   static void testMethod2() {
      Lead objLead = [SELECT Id,Student_Number_Lateral__c FROM Lead LIMIT 1];
      Test.StartTest();
         objLead.Student_Number_Lateral__c = null;
         update objLead;

         nmValidateLeadWebService.ValidateLead(objLead.id);
      Test.StopTest();
   }

   @isTest
   static void testMethod3() {
      Lead objLead = [SELECT Id,Salutation FROM Lead LIMIT 1];
      Test.StartTest();
         objLead.Salutation = null;
         update objLead;
         nmValidateLeadWebService.ValidateLead(objLead.id);
      Test.StopTest();
   }

   @isTest
   static void testMethod4() {
      Lead objLead = [SELECT Id,nm_Class12OrDiploma__c FROM Lead LIMIT 1];
      Test.StartTest();
         objLead.nm_Class12OrDiploma__c = 'XII/HSC';
         update objLead;
         nmValidateLeadWebService.ValidateLead(objLead.id);
      Test.StopTest();
   }

   @isTest
   static void testMethod5() {
      Lead objLead = [SELECT Id,nm_Class12OrDiploma__c FROM Lead LIMIT 1];
      Test.StartTest();
         objLead.nm_DateOfBirth__c = Date.newInstance(1990, 12, 9);
         update objLead;
         nmValidateLeadWebService.ValidateLead(objLead.id);
      Test.StopTest();
   }
 
}