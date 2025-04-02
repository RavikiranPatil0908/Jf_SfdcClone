/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 04-17-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-03-2021   @BK   Initial Version
**/
public class MassProgramTransferBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Set<String> lstFailedRecords;
    public Map<String,String> mapOfOldProgramVsNewProgramId = new Map<String,String>();

    public void execute(SchedulableContext sc) {
        MassProgramTransferBatch b = new MassProgramTransferBatch();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        getMapOfOldProgramNameVsNewProgram();
        System.debug('Mass Program Transfer Batch started');
        // String query = 'SELECT id,nm_ChooseaProgram__c,nm_EligiblityCriteria__c,nm_Program__c,nm_Program__c.Name FROM Lead WHERE IsConverted=false AND nm_ChooseaProgram__c=\'Post Graduate Diploma Programs\' AND nm_Year__c=2021 ';
        String query = 'SELECT id,nm_ChooseaProgram__c,nm_EligiblityCriteria__c,nm_Program__c,nm_Program__r.Name FROM Lead WHERE IsConverted=false AND nm_ChooseaProgram__c=\'Post Graduate Diploma Programs\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) { 
        if(scope.size() > 0) { 
            List<Lead> lstLead = new List<Lead>();
            List<String> lstLeadId = new List<String>();
            
            for(Sobject s : scope){
                Lead objLead = (Lead)s;
                objLead.nm_ChooseaProgram__c = 'MBA (Distance) Programs';
                if(objLead.nm_EligiblityCriteria__c != null) {
                    objLead.nm_EligiblityCriteria__c = null;
                }
                String programName = objLead.nm_Program__r.Name;
                if(String.isNotBlank(programName) && programName.startsWith('PGD')) {
                    objLead.nm_Program__c = mapOfOldProgramVsNewProgramId.containsKey(programName) ? mapOfOldProgramVsNewProgramId.get(programName) : null;
                } else {
                    objLead.nm_Program__c = null;
                }
                lstLead.add(objLead);
            }
            if(lstLead.size() > 0){
                updateProgram(lstLead,lstLeadId);
            }
        } else {
            System.debug('No records found.');
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('lstFailedRecords Size ==>'+lstFailedRecords.size());
        System.debug('Finished');
    }

    public void updateProgram(List<Lead> lstLead, List<String> lstLeadId) {
        try {
            lstFailedRecords = new Set<String>();
            Database.SaveResult[] srList = Database.update(lstLead, false);
            for (Integer i = 0; i < lstLead.size(); i++) {
                Database.SaveResult sr = srList[i];
                Lead origRecord = lstLead[i];
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated Lead. Lead ID: ' + sr.getId());
                } else {
                    System.debug('sr.getId() -->'+origRecord.id);
                    lstFailedRecords.add(origRecord.id);
                    // Operation failed, so get all errors.                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Lead fields that affected this error: ' + err.getFields());
                    }
                }
            }

            if(lstLeadId.size() > 0) {
                List<nm_LinksForDocumentsLead__c> lstDocs = [SELECT id FROM nm_LinksForDocumentsLead__c WHERE id IN :lstLeadId];
                if(lstDocs.size() > 0) {
                    delete lstDocs;
                }
            }

        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }

    public void getMapOfOldProgramNameVsNewProgram() {
        Map<String,String> mapOfPrograms = new Map<String,String> {
            'PGDBFM'=>'MBA (BFM)',
            'PGDBM'=>'MBA (BM)',
            'PGDBM - BFM'=>'MBA (BFM)',
            'PGDBM - FM'=>'MBA (FM)',
            'PGDBM - HRM'=>'MBA (HRM)',
            'PGDBM - ITM'=>'MBA (ITM)',
            'PGDBM - ITSM'=>'MBA (ITSM)',
            'PGDBM - MM'=>'MBA (MM)',
            'PGDBM - OM'=>'MBA (OM)',
            'PGDBM - RM'=>'MBA (RM)',
            'PGDBM - SCM'=>'MBA (SCM)',
            'PGDFM'=>'MBA (FM)',
            'PGDHRM'=>'MBA (HRM)',
            'PGDMM'=>'MBA (MM)'
        };
        
        Map<String,String> mapOfProgramVsId = new Map<String,String>();
        List<nm_Program__c> lstProgram = [SELECT id,nm_Program__c.Name FROM nm_Program__c WHERE nmIsActive__c=true AND nm_Type__c='MBA (Distance) Programs'];
        if(lstProgram.size() > 0) {
            for (nm_Program__c objProgram : lstProgram) {
                mapOfProgramVsId.put(objProgram.Name,objProgram.id);
            }

            for (String oldProgramName : mapOfPrograms.keySet()) {
                String NewProgramName = mapOfPrograms.get(oldProgramName);
                String newProgramId = mapOfProgramVsId.containsKey(NewProgramName) ? mapOfProgramVsId.get(NewProgramName) : null;
                mapOfOldProgramVsNewProgramId.put(oldProgramName, newProgramId);
            }
        }
    }
}