/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-01-2025
 * @last modified by  : @BK
**/
public class BatchClassPushLeadActivityToNetCore implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {

    public void execute(SchedulableContext sc) {
        BatchClassPushLeadActivityToNetCore b = new BatchClassPushLeadActivityToNetCore();
        Database.executebatch(b, 1000);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime dt = System.Now().addHours(-1);
        String query = 'SELECT Id,Lead.nm_ChooseaProgram__c,Lead.Lead_Description__c,Lead.nm_ProgramName__c,Lead.Status,OldValue,LeadId,Lead.Program_Type__c,'+
                        'Lead.Lead_created_date__c,Lead.nmm_BatchName__c,Lead.EduVanz_last_update_status_date__c,Lead.DescriptionLastUpdated__c FROM LeadHistory '+
                        'WHERE Lead.LeadSource!=\'Partner\' AND Field = \'Status\' AND CreatedDate >=:dt ORDER BY CreatedDate ASC';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 27-12-2024 
    * @param Database.BatchableContext BC 
    * @param List<LeadHistory> scope 
    **/
    public void execute(Database.BatchableContext bc, List<LeadHistory> scope) { 
        List<Map<String,Object>> lstData = new List<Map<String,Object>>();
        Integer counter = 0;
        Set<Id> setOfLeadIds = new Set<Id>();
        while(setOfLeadIds.size() < 1001 && counter < scope.size()) {
            if(!setOfLeadIds.contains(scope[counter].LeadId)) {
                setOfLeadIds.add(scope[counter].LeadId);
                Map<String,Object> mapOfFieldVsLead = mapLeadFields(scope[counter]);
                lstData.add(mapOfFieldVsLead);
            }
            counter++;
        }

        if(lstData.size() > 0) {
            LeadActivityHelper.callQueryAPI(lstData);
        }
    }

    /**
    * @description 
    * @author @BK | 27-12-2024 
    * @param Lead objLead 
    * @return Map<String, Object> 
    **/
    public Map<String,Object> mapLeadFields(LeadHistory objLead) { 
        LeadActivityHelper.LeadData leadData = new LeadActivityHelper.LeadData();
        leadData.leadId = objLead.LeadId;
        leadData.status = objLead.Lead.Status;
        leadData.leadDescription = objLead.Lead.Lead_Description__c;
        leadData.chooseProgram = objLead.Lead.nm_ChooseaProgram__c;
        leadData.programName = objLead.Lead.nm_ProgramName__c;
        leadData.programType = objLead.Lead.Program_Type__c;
        leadData.leadCreatedDate = objLead.Lead.Lead_created_date__c;
        leadData.batchName = objLead.Lead.nmm_BatchName__c;
        leadData.lastUpdateStatusDate = null;
        leadData.descriptionLastUpdatedDate = null;
        if(objLead.Lead.EduVanz_last_update_status_date__c!=null) {
            DateTime dt = (DateTime)objLead.Lead.EduVanz_last_update_status_date__c;
            leadData.lastUpdateStatusDate = (Date)dt.date();
        } 

        if(objLead.Lead.DescriptionLastUpdated__c!=null) {
            DateTime dt2 = (DateTime)objLead.Lead.DescriptionLastUpdated__c;
            leadData.descriptionLastUpdatedDate = (Date)dt2.date();
        }
        
        return LeadActivityHelper.mapLeadFields(leadData, 'Lead Updated');
    }

    public void finish(Database.BatchableContext bc) { 
        System.debug('Finished');
    }
}