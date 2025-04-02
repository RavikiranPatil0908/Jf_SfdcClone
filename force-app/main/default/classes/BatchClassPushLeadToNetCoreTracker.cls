/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-01-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false) 
public class BatchClassPushLeadToNetCoreTracker {

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
    }

    @isTest     
    static void UnitTest1() {   
        List<Lead> scope = [SELECT nm_LeadId__c,Email,MobilePhone,OwnerId,Created_Month__c,nm_RegistrationNo__c,DescriptionLastUpdated__c,Owner.Email,nm_PlantoStart__c,Is_Mobile_Verified__c,nm_IsEmailVerified__c,
        is_dnd_new__c,Owner.Name,nm_LCEmailID__c,Lead_Stage_7__c,Lead_Stage_6__c,Lead_Stage_5__c,Lead_Stage_4__c,Lead_Stage_3__c,Lead_Stage_2__c,Lead_Stage_1__c,nm_Eligibility_Criteria_Ref__c,
        nm_Designation__c,Industry,Total_Work_Experience__c,Highest_Qualification__c,nm_Qualification__c,Country,State,City,Networks__c,GACID__c,GCLID__c,nm_Keyword__c,
        nm_AdvertisementCampaign__c,nmm_BatchName__c,nm_Reason_for_Dead_Invalid_Leads__c,Status_after_180_days__c,Status_after_90_days__c,Status_after_60_days__c,Status_after_30_days__c,
        Status_after_15_days__c,Status_after_7_days__c,nm_Gender__c,LastName,FirstName,AEP_email_id__c,LC_Name__c,nm_ProgramName__c,Student_Number_Lateral__c,Agency__c,Name,nm_Session__c,
        RebornCounter__c,EduVanz_last_update_status_date__c,Lead_created_date__c,nm_DateOfBirth__c,CreatedDate,NumberofAttempts__c,PostalCode,nm_Year__c,LeadSource,nm_InformationCenter__r.Name,
        Program_Type__c,nm_ChooseaProgram__c,Lead_Description__c,Status FROM Lead WHERE LeadSource!='Partner' AND LastModifiedDate=TODAY];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockII());
            // to call the start method
            BatchClassPushLeadToNetCore objBatch = new BatchClassPushLeadToNetCore();
            objBatch.start(null);
            //  to call the execute method
            objBatch.execute(null, scope);
            // to call the finish method
            objBatch.finish(null);
        Test.stopTest();    
    }
}