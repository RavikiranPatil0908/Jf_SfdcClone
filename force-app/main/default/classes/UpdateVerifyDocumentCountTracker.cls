/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 10-27-2021
 * @last modified by  : shubhranshu
**/
@isTest(SeeAllData=false)
public with sharing class UpdateVerifyDocumentCountTracker {
    
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
    
    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        nm_Program__c program = nmGenericTracker.CreatePGDiplomaProgram();
        nmGenericTracker.CreateICAndUser(nmGenericTracker.CreateCenter('Mumbai'));
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        nmGenericTracker.CreateWorkExperienceForLead(objLead);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents submitted');
        Account objAccount2 = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Documents Re-submitted');
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.Salutation__c = 'Mr.';
        cp.First_Name__c = 'Test';
        cp.Last_Name__c = 'test';
        cp.AEP_Name__c = objAccount.nm_Centers__c;
        // cp.BusinessAccount__c = objBusinessAccount.id;
        cp.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        insert cp;
        objAccount.Admission_Co_ordinator__c = cp.Id;
        objAccount2.nm_DocumentSubmittedDate__c = System.Now();
        update objAccount;

        Counsellor_Profile__c cp1 = new Counsellor_Profile__c();
        cp1.Salutation__c = 'Mr.';
        cp1.First_Name__c = 'Test';
        cp1.Last_Name__c = 'test';
        cp1.AEP_Name__c = objAccount2.nm_Centers__c;
        // cp.BusinessAccount__c = objBusinessAccount.id;
        cp1.Program_Offered__c = 'Certificate Programs;Diploma Programs;Post Graduate Diploma Programs;Professional Programs;Bachelor Programs;MBA (WX);M.Sc.; MBA (X);M.Sc. (AI & ML Ops)';
        insert cp1;
        objAccount2.Admission_Co_ordinator__c = cp1.Id;
        objAccount2.Document_Approved_Date__c = System.today();
        objAccount2.nm_DocumentSubmittedDate__c = System.Now();
        update objAccount2;
    }

    static testmethod void testSuccessBatch(){
        Test.startTest();
        UpdateVerifyDocumentCountBatch batchClass = new UpdateVerifyDocumentCountBatch();
         Database.executeBatch(batchClass,200);
        Test.stopTest();
     }
}