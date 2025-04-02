/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 26-12-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false) 
public class BatchClassPushAccountToNetCoreTracker {

    private class RestMockII implements HttpCalloutMock {   
        RestMockII() {  
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
    public static void makeData(){  
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        String LeadId = objLead.id;
        System.debug('lead id-->'+LeadId);
        nmGenericTracker.CreatePaymentRecords(objLead.id,'Registration','Lead','Registration');
        nm_Payment__c objpayment =  nmGenericTracker.CreatePaymentRecords(objLead.id,'Zest-DownPayment','Lead','DownPayment-Admission');


        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        List<Account> lstAccount = [SELECT id,nm_LeadId__c,nm_Tagged_Pricebook__c,nm_DateOfBirth__c,nm_StudentNo__c FROM Account WHERE id=:objAccount.id];
        lstAccount[0].nm_Tagged_Pricebook__c = null;
        lstAccount[0].nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        lstAccount[0].nm_DateOfBirth__c =system.today();
        lstAccount[0].nm_StudentNo__c = '777777777777';
        update lstAccount;
    }

    @isTest     
    static void UnitTest1() {   
        List<Account> scope = [SELECT Id,nm_StudentNo__c,PersonEmail,PersonMobilePhone,nm_DateOfBirth__c,nm_ProgramType__c,Program_Type__c,PersonLeadSource,Agency__c,Name,
        nm_StateProvince__c,State_Province_Shipping__c,Program_Name__c,Batch__c,nm_StudentStatus__c,LC_Name__c,nm_IsProvisonal__c,Salutation,FirstName,LastName FROM Account 
        WHERE nm_StudentStatus__c='Confirmed' AND nm_StudentNo__c!=null AND LastModifiedDate=TODAY];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            // to call the start method
            BatchClassPushAccountToNetCore objBatch = new BatchClassPushAccountToNetCore();
            objBatch.start(null);
            //  to call the execute method
            objBatch.execute(null, scope);
            // to call the finish method
            objBatch.finish(null);
        Test.stopTest();    
    }
}