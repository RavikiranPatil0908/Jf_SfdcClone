public  class LeadAllotmentForAgencyBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    Boolean isProcessAllReadyRunning = false;
    AssignCounsellorHelper AssignCounsellorHelper = new AssignCounsellorHelper();
    Map < String, nm_Centers__c > mapOfCenterNameVsCenter = new Map < String, nm_Centers__c >(); 
    AssignCounsellorHelper.LeadAssignmentMetadate LeadAssignmentMetadate = new AssignCounsellorHelper.LeadAssignmentMetadate();
    Map<String, String> mapOfagencyVsType = new Map<String, String>();
    Map<String, set<String>> mapOfTypeVsSetAgency = new Map<String, set<String>>();
    AssignCounsellorHelper.FamilyOfProgram FamilyOfProgram = new AssignCounsellorHelper.FamilyOfProgram();
    Map<String, String> mapOfProgramVsFamily = new Map<String, String>();
    Map<String, set<String>> mapOfFamilyVsSetOfProgram = new Map<String, set<String>>();
    Map<String, Map<String, Lead_Assignment__c>> getMapLeadAssignmentWithAgency = new Map<String, Map<String, Lead_Assignment__c>>();
    AssignCounsellorHelper.LeadCount LeadCount = new AssignCounsellorHelper.LeadCount();
    Map<String, Map<String, Integer>> mapOfAgencyTypeVsMapOfFamilyVsBaseCount = new Map<String, Map<String, Integer>>();
    Map<String, Map<String, Map<String, Integer>>> mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount  = new Map<String, Map<String, Map<String, Integer>>>(); 
    Map<String,Map<String,Map<String, Integer>>> MaxCountForAgencyVsFamilyVsCenterVsCount = new Map<String,Map<String,Map<String, Integer>>>();        

    public void execute(SchedulableContext sc) {
        LeadAllotmentForAgencyBatchClass b = new LeadAllotmentForAgencyBatchClass();
        Database.executebatch(b, 20);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> setOfStatus = new Set<String>{'Holding', 'Preparing', 'Processing', 'Queued'};
        List<AsyncApexJob> AsyncApexJobForAEP = [Select Id,CreatedDate, Status, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email, ExtendedStatus
                from AsyncApexJob where JobType='BatchApex' AND ID != :bc.getJobId() AND ApexClass.Name = 'LeadAllotmentForAgencyBatchClass' AND Status IN :setOfStatus AND CreatedDate = Today ];
        isProcessAllReadyRunning = AsyncApexJobForAEP.size() > 0 ? true : false;
        // Set<String> setOfAgency = new Set<String>();
        if (!isProcessAllReadyRunning && Boolean.valueOf(System.Label.LC_Wise_Distribution_Active)) {
            mapOfCenterNameVsCenter = getMapOfCenterNameVsCenter();
            LeadAssignmentMetadate = AssignCounsellorHelper.getMapAgencyTypeFromMetadataVsLabel();
            mapOfagencyVsType  = LeadAssignmentMetadate.mapOfagencyVsType;
            mapOfTypeVsSetAgency  = LeadAssignmentMetadate.mapOfTypeVsLstAgency;
            mapOfProgramVsFamily = FamilyOfProgram.mapOfProgramVsFamily;
            mapOfFamilyVsSetOfProgram = FamilyOfProgram.mapOfFamilyVsSetOfProgram;
            getMapLeadAssignmentWithAgency = AssignCounsellorHelper.getMapLeadAssignmentWithAgency();
            Set<String> setActiveAgency = new Set<String>(getMapLeadAssignmentWithAgency.keySet());
            LeadCount = AssignCounsellorHelper.getMapAgencyTypeVsLstLead(null, null, mapOfFamilyVsSetOfProgram, mapOfagencyVsType, mapOfTypeVsSetAgency, mapOfProgramVsFamily, setActiveAgency);
            mapOfAgencyTypeVsMapOfFamilyVsBaseCount = LeadCount.mapOfAgencyTypeVsMapOfFamilyVsBaseCount;
            mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount = LeadCount.mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount;
            MaxCountForAgencyVsFamilyVsCenterVsCount = AssignCounsellorHelper.getMaxCountForAgencyVsFamilyVsCenterVsCount(getMapLeadAssignmentWithAgency, mapOfAgencyTypeVsMapOfFamilyVsBaseCount);
            // for(String key : mapOfTypeVsSetAgency.keySet()){ {
            //     for (String agency : mapOfTypeVsSetAgency.get(key)) {
            //             setOfAgency.add(agency);
            //         }
            //     }
            // }
        }

        
        Date todayDate = Date.today(); 
        String query = 'SELECT id,Agency__c,nm_ChooseaProgram__c,nm_SelectedIC__c, nm_InformationCenter__c FROM Lead WHERE CreatedDate= Today AND nm_ChooseaProgram__c != null  AND IsConverted=false AND IsDeleted = false' +
           ' AND ( nm_InformationCenter__c = null OR nm_InformationCenter__r.Name =  \'Counsellor\' )  AND (CreatedBy.Name = \'marketing ngasce\' OR LC_Wise_Marketing_Distribution_Date__c = Today OR CreatedBy.Name = \'Suyog Deshmukh\') AND LeadSource!= \'Partner\'';
        if(Test.isRunningTest()) {
            query =  'SELECT id,Agency__c,nm_ChooseaProgram__c,nm_SelectedIC__c, nm_InformationCenter__c FROM Lead';
        }
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List <Lead> leadToUpdate = new List<Lead>();
        if(scope.size() > 0 && !isProcessAllReadyRunning && Boolean.valueOf(System.Label.LC_Wise_Distribution_Active)) { 
            for(SObject sc : scope){
                Lead objLead = (Lead)sc;
                Lead obLead = new Lead();
                obLead.Id = objLead.Id;
                String family = mapOfProgramVsFamily.containsKey(objLead.nm_ChooseaProgram__c) ? mapOfProgramVsFamily.get(objLead.nm_ChooseaProgram__c) : null;
                String agency = String.isNotBlank(objLead.Agency__c) &&  mapOfagencyVsType.containsKey(objLead.Agency__c.trim()) ? mapOfagencyVsType.get(objLead.Agency__c.trim()) : 'Others';
                if(String.isNotBlank(family) && String.isNotBlank(agency)) {
                    String selectedCenterName = null;
                    String selectedLearningCenterName = null;
                    if (String.isNotBlank(objLead.nm_SelectedIC__c) && mapOfCenterNameVsCenter.containsKey(objLead.nm_SelectedIC__c) && objLead.nm_ChooseaProgram__c != '') {
                        nm_Centers__c objCenter1 = mapOfCenterNameVsCenter.get(objLead.nm_SelectedIC__c);
                        if (
                            String.isNotBlank(objCenter1.nm_ChooseaProgram__c) &&
                            objCenter1.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c) &&
                            objCenter1.RegistrationClosed__c == false
                        ) {
                            selectedCenterName = objCenter1.Name;
                            selectedLearningCenterName = objCenter1.CenterName__c;
                        } else if (
                            mapOfCenterNameVsCenter.containsKey(objCenter1.CenterName__c) &&
                            String.isNotBlank(mapOfCenterNameVsCenter.get(objCenter1.CenterName__c).nm_ChooseaProgram__c) &&
                            mapOfCenterNameVsCenter.get(objCenter1.CenterName__c).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c) &&
                            mapOfCenterNameVsCenter.get(objCenter1.CenterName__c).RegistrationClosed__c == false
                        ) {
                            nm_Centers__c objCenter2 = mapOfCenterNameVsCenter.get(objCenter1.CenterName__c);
                            selectedLearningCenterName = objCenter2.Name;
                        } 
                    }
                    Map<String, Map<String,Integer>> mapOfFamilyVsMapOfMaxCount = MaxCountForAgencyVsFamilyVsCenterVsCount.containsKey(agency) ? MaxCountForAgencyVsFamilyVsCenterVsCount.get(agency) : new Map<String, Map<String,Integer>>();
                    Map<String, Map<String, Integer>> MapFamilyVsCenterVsLeadCount = mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.containsKey(agency) ? mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.get(agency) : new Map<String, Map<String, Integer>>();
                    Map<String, Integer> mapOfCenterVsLeadCount = MapFamilyVsCenterVsLeadCount.containsKey(family) ? MapFamilyVsCenterVsLeadCount.get(family) : new Map<String, Integer>();
                    Map<String, Integer>  mapOfMaxCount = mapOfFamilyVsMapOfMaxCount.containsKey(family) ? mapOfFamilyVsMapOfMaxCount.get(family) : new Map<String, Integer>();
                    Map<String, Integer>  mapOfLeadCount = MapFamilyVsCenterVsLeadCount.containsKey(family) ? MapFamilyVsCenterVsLeadCount.get(family) : new Map<String, Integer>();
                    String CenterThroughAssignment = AssignCounsellorHelper.getCenterForLeadThroughAllotment(mapOfLeadCount,mapOfMaxCount, selectedLearningCenterName );
                    String centerName = String.isNotBlank(selectedCenterName) && selectedLearningCenterName == CenterThroughAssignment ? selectedCenterName: CenterThroughAssignment;
                    if(centerName != 'Counsellor') {
                        mapOfLeadCount = AssignCounsellorHelper.updateLeadAllotmentCount(mapOfLeadCount, centerName);
                        MapFamilyVsCenterVsLeadCount.put(family, mapOfLeadCount);
                        mapOfAgencyTypeVsMapFamilyVsCenterVsLeadCount.put(agency, MapFamilyVsCenterVsLeadCount);
                        obLead.nm_InformationCenter__c = getMapLeadAssignmentWithAgency.get(agency).get(centerName).Assign_To__c;
                        obLead.Agency_Internal_Category__c = agency;
                        obLead.LC_Wise_Marketing_Distribution_Date__c = date.today();
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
        from AsyncApexJob where JobType='BatchApex' AND ApexClass.Name = 'LeadAllotmentForAgencyBatchClass' AND Status IN :setOfStatus AND CreatedDate = Today ];
        for (AsyncApexJob objAsyncApexJob : AsyncApexJobForAEP) {
            System.abortJob(objAsyncApexJob.Id);
        }
        if (AsyncApexJobForAEP.size() > 0) {
            system.debug('AsyncApexJobForAEP-- > ');
            List<AsyncApexJob> AsyncApexJobForAEPNewCreation = [Select Id,CreatedDate, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email, ExtendedStatus
            from AsyncApexJob where JobType='BatchApex' AND ApexClass.Name = 'LeadAllotmentForAgencyBatchClass' AND Status IN :setOfStatus AND CreatedDate = Today ];
            if (AsyncApexJobForAEPNewCreation.size()== 0) {
                system.debug('AsyncApexJobForAEPNewCreation-- > ');
                Database.executeBatch(new LeadAllotmentForAgencyBatchClass(), 20);
            }
        }
        system.debug('LeadAllotmentForAgencyBatchClass finish --> ');
    }

    public Map < String, nm_Centers__c > getMapOfCenterNameVsCenter() {
        Map<String, nm_Centers__c> mapOfNameVsCen = new Map<String, nm_Centers__c>();
        for (nm_Centers__c objCenter :  [SELECT Id, Assign_IC_To_LC__c, Name, nm_ChooseaProgram__c, RegistrationClosed__c, CenterName__c FROM nm_Centers__c]) {
            if (String.isNotBlank(objCenter.Assign_IC_To_LC__c)) {
                for (string assignIcTOLC: objCenter.Assign_IC_To_LC__c.split(';')) {
                    mapOfNameVsCen.put(assignIcTOLC.trim(), objCenter);
                }
            }
            mapOfNameVsCen.put(objCenter.Name, objCenter);
        }
        return mapOfNameVsCen;
    }
    
}