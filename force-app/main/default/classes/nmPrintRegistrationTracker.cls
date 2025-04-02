/**
 * @File Name          : nmPrintRegistrationTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 11/1/2020, 3:23:11 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/1/2020   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class nmPrintRegistrationTracker
{    
    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
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
        Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
        Set<String> setOfEligiblityCriteria = new Set<String>();
        List<nm_EscalationMatrix__c> lstEscalationMatrix = new List<nm_EscalationMatrix__c>();

        nm_EscalationMatrix__c objCustomSeetings3 = new nm_EscalationMatrix__c();
        objCustomSeetings3.name='0-1 Week';
        objCustomSeetings3.nm_LCEscalationTime__c='22:45';
        objCustomSeetings3.nm_RemidertoIC__c='22:45';
        objCustomSeetings3.nm_HOEscalationTime__c='20:56';
        objCustomSeetings3.nm_RemidertoHO__c='22:45';
        lstEscalationMatrix.add(objCustomSeetings3);
        
        nm_EscalationMatrix__c objCustomSeetings = new nm_EscalationMatrix__c();
        objCustomSeetings.name='2-4 Months';
        objCustomSeetings.nm_LCEscalationTime__c='20:45';
        objCustomSeetings.nm_RemidertoIC__c='21:45';
        objCustomSeetings.nm_HOEscalationTime__c='20:56';
        objCustomSeetings.nm_RemidertoHO__c='21:45';
        lstEscalationMatrix.add(objCustomSeetings);
        
        nm_EscalationMatrix__c objCustomSeetings2 = new nm_EscalationMatrix__c();
        objCustomSeetings2.name='3-6 Week';
        objCustomSeetings2.nm_LCEscalationTime__c='20:34';
        objCustomSeetings2.nm_RemidertoIC__c='21:45';
        objCustomSeetings2.nm_HOEscalationTime__c='20:56';
        objCustomSeetings2.nm_RemidertoHO__c='21:45';
        lstEscalationMatrix.add(objCustomSeetings2);
        insert lstEscalationMatrix;
        
        nm_Holidays__c objHoliday = new nm_Holidays__c();
        objHoliday.Name='Holi';
        objHoliday.nm_Date__c=system.today();
        insert objHoliday;
        
        SystemConfiguration__c objSystemConfiguration=new SystemConfiguration__c();
        objSystemConfiguration.name='test';
        objSystemConfiguration.nm_BusinessHoursStartTime__c='012213';
        objSystemConfiguration.nm_BusinessHoursEndTime__c='0234533';
        insert objSystemConfiguration;

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('Yes',false);
        nm_LinksForDocumentsLead__c objLeadDoc = nmGenericTracker.CreatedDocumentForLead(objLead,'Aadhaar Card');
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents submitted');
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Defence Document');
    }

    @isTest
    static void unitTest() {
        Lead objLead = [SELECT id,nm_Session__c,Status,MobilePhone FROM Lead LIMIT 1];

        PageReference pg = new PageReference('/apex/nm_PrintRegistrationForm');
        Test.setCurrentPage(pg);
        Apexpages.currentpage().getparameters().put('id',objLead.id);
        Test.StartTest();
          nmPrintRegistration objnmPrint=new nmPrintRegistration();
          objnmPrint.PrintForm();
          objnmPrint.MakePayment();
        Test.StopTest();
    }           
}