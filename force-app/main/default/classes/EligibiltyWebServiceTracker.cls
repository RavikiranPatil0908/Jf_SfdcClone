@Istest
public with sharing class EligibiltyWebServiceTracker {
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
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();

         Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
         nmGenericTracker.CreateWorkExperienceForLead(objLead);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');
        nm_StudentProgram__c objSP = nmGenericTracker.CreatePGStudentProgram(objAccount);

        Account objBusinessAccount = new Account(Name='Head Office',Phone='8850232820',nm_AccountEmail__c='standarduser@testorg.com');
        insert objBusinessAccount;
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objAccount.nm_Centers__c;
        cp.BusinessAccount__c = objBusinessAccount.id;
        cp.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        insert cp;
    }

    public static testMethod void TestMethod1(){

        Account objAccount = [select id,Shipping_Address_Choice__c from Account where Name!='Head Office' limit 1];
        Lead objLead= [select id from Lead limit 1];
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Map<id,Account> oldMap = new Map<id,Account>();
        List<Account> lstAcc = new List<Account>();
        EligibiltyWebService.addAdmissionCordinator(objAccount.id);

     }

}