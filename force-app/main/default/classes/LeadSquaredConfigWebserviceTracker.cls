@isTest
public class LeadSquaredConfigWebserviceTracker {
    public static testmethod void leadsquaredmthd(){
        
       // leadSquaredConfigWebservice.createLead('TestSwati', 'testSingh', 'testemail@gmail.com', '9874561232','City','1d0d01cc-1003-85aa-8246-f20b461bfd90');
        leadSquaredConfigWebservice.createListofLead('[{"attributes":{"type":"Lead","url":"/services/data/v44.0/sobjects/Lead/00QO0000009FvohMAC"},"LastModifiedDate":"2018-11-24T07:44:20.000+0000","HasOptedOutOfFax":false,"Refund_Loan_Payment__c":false,"nm_InformationCenter__c":"a02O000000DHXMMIA5","pi__Needs_Score_Synced__c":false,"Monthly__c":"11","Is_Lateral__c":false,"Created_Month__c":"K11_November","nm_ExtraChargeApplicable__c":false,"nm_newadmission__c":true,"Status_Tracking__c":"2018-11-24T07:43:00.000+0000","LastModifiedByID":"005O0000005MGlrIAG","nmm_BatchName__c":"January2019","Status":"Hot","IsDeleted":false,"AboveStatusSince__c":0,"Partial_form_filled__c":false,"nm_OldStudent__c":false,"Unique_ID__c":"00QO0000009FvohMAC","nm_VerificationLink__c":"_HL_ENCODED_http://sandbox-ngasce.cs5.force.com/nmEmailVerification?id=00QO0000009Fvoh&type=Lead&verify=Email_HL_here_HL__blank_HL_","nm_ChooseaProgram__c":"Post Graduate Diploma Programs","nm_LeadContacted__c":"No","Id":"00QO0000009FvohMAC","InActiveTrigger__c":false,"Weekday__c":"Saturday","Days_to_Convert__c":0.00,"DoNotCall":false,"nm_Invalid_Lead__c":false,"Lead_Number__c":"31078","OwnerId":"005900000036PyIAAU","Counter__c":0,"Loan_Sanctioned__c":false,"Mother_Name__c":" ","nm_DGM__c":false,"nm_LeadWeightage__c":50.00,"Aadhaar_Card_Waive_Off__c":false,"testing__c":"3:44","nm_Callme__c":false,"CRT__c":"November","Profile_Name__c":"Information Center"}]');
        
        Lead objLead = new  Lead();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false); 
        leadSquaredConfigWebservice.updateLeadInLeadsquare(objLead.id);
        leadSquaredConfigWebservice.GetLeadId(objLead,objLead.email);      
       leadSquaredConfigWebservice.UpdateleadsquaredId('{"Status":"Success","Message":{"Id":"4faaf28d-8508-419d-b15c-facfe8d4edf1"}}',objLead);
        leadSquaredConfigWebservice.postparameter(objLead,'Create',null);
        leadSquaredConfigWebservice.postparameter(objLead,'Update',null);
        JSONHelper jds=new JSONHelper();
    
    
    
    }

}