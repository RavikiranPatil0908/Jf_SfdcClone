public  class LeadAllotmentOfAgencyForAEP implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    Boolean isProcessAllReadyRunning = false;
    AssignCounsellorHelper AssignCounsellorHelper = new AssignCounsellorHelper();
    public Map<String, String> mapOfProgramVsFamily = new Map<String, String>();
    public  Map < String, nm_Centers__c > mapOfCenterNameVsCenter = new Map<String, nm_Centers__c>();
    public  Map<String,Map<String,Lead_Assignment__c>> mapOfNameVsAssignment = new Map<String,Map<String,Lead_Assignment__c>>();
    public List < Lead > lstLeadOfForAllAep = new List<Lead>();
    public Map<String, Map<String,  Map<String, Integer>>> MapOfMaxCountForAEP = new Map<String, Map<String,  Map<String, Integer>>>();
    public Map<String, Map<String, Map<String , Integer>>> MapOFAgencyVsAEPCount = new Map<String, Map<String, Map<String , Integer>>>();

    public void execute(SchedulableContext sc) {
        LeadAllotmentOfAgencyForAEP b = new LeadAllotmentOfAgencyForAEP();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> setOfStatus = new Set<String>{'Holding', 'Preparing', 'Processing', 'Queued'};
        List<AsyncApexJob> AsyncApexJobForAEP = [Select Id,CreatedDate, Status, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email, ExtendedStatus
                from AsyncApexJob where JobType='BatchApex' AND ID != :bc.getJobId() AND ApexClass.Name = 'LeadAllotmentOfAgencyForAEP' AND Status IN :setOfStatus AND CreatedDate = Today ];
        isProcessAllReadyRunning = AsyncApexJobForAEP.size() > 0 ? true : false;

        if (!isProcessAllReadyRunning) {
            mapOfNameVsAssignment = AssignCounsellorHelper.getMapLeadAssignmentForAEP();
            mapOfProgramVsFamily = AssignCounsellorHelper.getMapOfProgramVsFamily();
            lstLeadOfForAllAep = AssignCounsellorHelper.getLstLeadOfForAllAEP('');
            MapOFAgencyVsAEPCount = AssignCounsellorHelper.getMapOFAgencyVsAEPCount(lstLeadOfForAllAep, mapOfProgramVsFamily);
            Map<String, Map<String, Decimal>> mapOfBaseCountForAgencyVsAEP = AssignCounsellorHelper.getBaseCountForAgencyVsAEP(lstLeadOfForAllAep, mapOfProgramVsFamily);
            
            MapOfMaxCountForAEP = AssignCounsellorHelper.getMapOfMaxCountForAEP(mapOfNameVsAssignment, mapOfBaseCountForAgencyVsAEP );    
        }

        
        String onlyCen = '';
        String aepAllotmentLc = System.Label.Lead_Assignment_For_AEP;
        if(String.isNotBlank(aepAllotmentLc)) {
            List<String> lstCe = aepAllotmentLc.split(';');
            onlyCen = ' AND LC_Name__c IN : lstCe ';
        }
        System.debug('LeadAllotmentOfAgencyForAEP started');
        // String leadId = '00QO0000008ZKfM';
        Date todayDate = Date.today(); 
        List<String> SetOFLeadStatusToNotUpdate = Label.Transfer_Lead_To_LC.split(','); 
        String query = 'SELECT id,Agency__c,nm_ChooseaProgram__c, nm_InformationCenter__c, nm_InformationCenter__r.CenterName__c FROM Lead WHERE Status != :SetOFLeadStatusToNotUpdate  AND CreatedDate= Today AND nm_ChooseaProgram__c != null  AND IsConverted=false AND IsDeleted = false' +
           ' AND nm_InformationCenter__c != null AND nm_InformationCenter__r.RecordType.Name = \'Learning Center\'  AND (Agency__c LIKE \'L1_%\' OR Agency__c LIKE \'L2_%\' OR Agency__c LIKE \'L3_%\') ' + onlyCen;
        if(Test.isRunningTest()) {
            query =  'SELECT id,Agency__c,nm_ChooseaProgram__c, nm_InformationCenter__c, nm_InformationCenter__r.CenterName__c FROM Lead';
        }
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        
        List <Lead> leadToUpdate = new List<Lead>();
        if(scope.size() > 0 && !isProcessAllReadyRunning) { 
            for(SObject sc : scope){
                Lead objLead = (Lead)sc;
                    Lead obLead = new Lead();
                    obLead.Id = objLead.Id;
                    String agency2 = mapOfProgramVsFamily.containsKey(objLead.nm_ChooseaProgram__c) ? mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c) : null;
                    String lcName = objLead.nm_InformationCenter__r.CenterName__c;
                    if(String.isNotBlank(agency2) && MapOfMaxCountForAEP.containsKey(lcName)) {
                        Map<String,  Map<String, Integer>> mapOfAgencyVsMapOfMaxCount = MapOfMaxCountForAEP.containsKey(lcName) ? MapOfMaxCountForAEP.get(lcName) : new Map<String,  Map<String, Integer>>();
                        Map<String, Integer>  mapOfMaxCount = mapOfAgencyVsMapOfMaxCount.containsKey(agency2) ? mapOfAgencyVsMapOfMaxCount.get(agency2) : new Map<String, Integer>();
                        Map<String, Map<String,Integer>> mapOfAgencyVsMapOfLeadCount = MapOFAgencyVsAEPCount.containsKey(lcName) ? MapOFAgencyVsAEPCount.get(lcName) : new Map<String, Map<String,Integer>>();
                        Map<String, Integer>  mapOfLeadCount = mapOfAgencyVsMapOfLeadCount.containsKey(agency2) ? mapOfAgencyVsMapOfLeadCount.get(agency2) : new Map<String, Integer>();
                        String centerName = AssignCounsellorHelper.getCenterForLeadThroughAllotment(mapOfLeadCount,mapOfMaxCount, null );
                        if(centerName != 'Counsellor') {
                            mapOfLeadCount = AssignCounsellorHelper.updateLeadAllotmentCount(mapOfLeadCount, centerName);
                            mapOfAgencyVsMapOfLeadCount.put(agency2, mapOfLeadCount);
                            MapOFAgencyVsAEPCount.put(lcName, mapOfAgencyVsMapOfLeadCount);
                            Map<String, Lead_Assignment__c> mapOFLeadAssignment = mapOfNameVsAssignment.get(lcName);
                            obLead.nm_InformationCenter__c = mapOFLeadAssignment.get(centerName).Assign_To__c;
                            leadToUpdate.add(obLead);
                        } 
                    }
            }
        } else {
            System.debug('No records found.');
        }
        if(leadToUpdate.size() > 0) {
            update leadToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        Set<String> setOfStatus = new Set<String>{'Holding', 'Preparing', 'Processing', 'Queued'};
        List<AsyncApexJob> AsyncApexJobForAEP = [Select Id,CreatedDate, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email, ExtendedStatus
        from AsyncApexJob where JobType='BatchApex' AND ApexClass.Name = 'LeadAllotmentOfAgencyForAEP' AND Status IN :setOfStatus AND CreatedDate = Today ];
        for (AsyncApexJob objAsyncApexJob : AsyncApexJobForAEP) {
            System.abortJob(objAsyncApexJob.Id);
        }
        system.debug('LeadAllotmentOfAgencyForAEP finish --> ');
    }

    
}