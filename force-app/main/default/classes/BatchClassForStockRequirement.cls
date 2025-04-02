/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 21-02-2024
 * @last modified by  : @BK
**/
public class BatchClassForStockRequirement implements Database.Batchable<sObject>, Database.Stateful {

    List<Id> lstSuccessOfSKUIds = new List<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String session = System.Label.Current_Session;
        String year = System.Label.Current_Year;
        String query = 'SELECT id,Stock_Keeping_Units__c,Stock__r.Quantity__c,Stock_Keeping_Units__r.Program__c,Stock_Keeping_Units__r.Launch_Year__c,Study_Kit_Stock__c,Stock_Keeping_Units__r.Semester__c,Base_Count__c,Session__c,Year__c FROM StockSkuJunction__c WHERE Year__c=:year AND Session__c=:session';
        System.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<StockSkuJunction__c> lstStockSKU) { 

        StockWrapper objWrapper = new StockWrapper();
        Map<String,List<Opportunity>> mapOfKeyVslstOpp = new Map<String,List<Opportunity>>();
        List<StockSkuJunction__c> sjList = new List<StockSkuJunction__c>();

        // to set the Wrapper
        objWrapper = setWrapper(lstStockSKU);
        System.debug('setPrgName==> '+objWrapper.setPrgName);
        
        // to get the key vs baseCount
        mapOfKeyVslstOpp = getKeyVslstOpp(objWrapper);

        // to get the StockToUpdate
        sjList = getStockToUpdate(lstStockSKU,objWrapper.mapOfSKUIdVsUniqueKeys,mapOfKeyVslstOpp);

        if(sjList.size() > 0) {
            System.debug('sjList Size==>'+sjList.size());
            update sjList;
        }
    }

    /**
    * @description 
    * @author @BK | 15-02-2024 
    * @param Database.BatchableContext bc 
    **/
    public void finish(Database.BatchableContext bc){
        // update Final Requirement
        System.debug('lstSuccessOfSKUIds Size ==>'+lstSuccessOfSKUIds.size());
        System.debug('Finished');
    }

    /**
    * @description 
    * @author @BK | 15-02-2024 
    * @param StockWrapper objWrapper 
    * @return Map<Id, Set<String>> 
    **/
    public Map<String,List<Opportunity>> getKeyVslstOpp(StockWrapper objWrapper) {
        Map<String,List<Opportunity>> mapOfKeyVslstOpp = new Map<String,List<Opportunity>>();
        // to get the query;
        String previousSession = System.Label.Previous_Session;
        Integer previousYear = Integer.valueOf(System.Label.Previous_Year);
        Set<String> setOfLaunchYear = objWrapper.setOfLaunchYear;
        Set<String> setOfBBAProgramName = objWrapper.setOfBBAProgramName;
        Set<String> setPrgName = objWrapper.setPrgName;
        Set<String> setOfSemester = objWrapper.setOfSemester;
        Set<Integer> setOfYear = objWrapper.setOfYear;
        Set<String> setOfSession = objWrapper.setOfSession;

        String query = getQuery(objWrapper);

        List<Opportunity> lstOpp = DataBase.query(query);
        System.debug('lstOpp Size ==>'+lstOpp.size());
        for (Opportunity obj : lstOpp) {
            List<String> lstSems = new List<String>{'5','6'};
            String mapKey = '';
            if(obj.Elective_Subject_Type__c!=null && obj.nm_Program__r.Name=='BBA' && lstSems.contains(obj.nm_Semester__c)) {
                mapKey = obj.Elective_Subject_Type__c + '_' + obj.Launch_Year__c + '_' + obj.nm_Semester__c + '_' + obj.nm_Year__c + '_' + obj.nm_Session__c;
            } else {
                mapKey = obj.nm_Program__r.Name + '_' + obj.Launch_Year__c + '_' + obj.nm_Semester__c + '_' + obj.nm_Year__c + '_' + obj.nm_Session__c;
            }
            List<Opportunity> lstOpps = mapOfKeyVslstOpp.containsKey(mapKey) ? mapOfKeyVslstOpp.get(mapKey) : new List<Opportunity>();
            lstOpps.add(obj);
            mapOfKeyVslstOpp.put(mapKey, lstOpps);
        }

        // For Debug
        for (String mapKey : mapOfKeyVslstOpp.keySet()) {
            System.debug('mapKey ==>'+mapKey);
            System.debug('baseCount ==>'+mapOfKeyVslstOpp.get(mapKey).size());
        }

        return mapOfKeyVslstOpp;
    }

    /**
    * @description 
    * @author @BK | 15-02-2024 
    * @param List<StockSkuJunction__c> lstStockSKU 
    * @return StockWrapper 
    **/
    public StockWrapper setWrapper(List<StockSkuJunction__c> lstStockSKU) {
        StockWrapper objWrapper = new StockWrapper();
        for (StockSkuJunction__c obj : lstStockSKU) {
            Set<String> setProgName = String.isNotBlank(obj.Stock_Keeping_Units__r.Program__c) ? new Set<String>(obj.Stock_Keeping_Units__r.Program__c.split(';')) : new Set<String>();

            objWrapper.setOfLaunchYear.add(obj.Stock_Keeping_Units__r.Launch_Year__c);
            if((setProgName.contains('BBA - Marketing') || setProgName.contains('BBA - Finance')) && obj.Stock_Keeping_Units__r.Semester__c == '6') { //obj.Stock_Keeping_Units__r.Semester__c=='6'
                objWrapper.isElective = true;
                String programName = setProgName.contains('BBA - Marketing') ? 'Marketing' : 'Finance';
                objWrapper.setOfBBAProgramName.add(programName);
                if(setProgName.size() == 1) {
                    Set<String> setOfProgramName = new Set<String>{programName};
                    objWrapper.mapOfSKUIdVsUniqueKeys = getSKUIdVsUniqueKeys(objWrapper.mapOfSKUIdVsUniqueKeys,setOfProgramName,obj,true);
                } else {
                    objWrapper.mapOfSKUIdVsUniqueKeys = getSKUIdVsUniqueKeys(objWrapper.mapOfSKUIdVsUniqueKeys,objWrapper.setOfBBAProgramName,obj,true);
                }
            } else {
                if(setProgName.size() > 0) {
                    objWrapper.setPrgName.addAll(setProgName);
                }
                objWrapper.setOfSemester.add(obj.Stock_Keeping_Units__r.Semester__c);
                objWrapper.setOfYear.add(Integer.valueOf(obj.Year__c));
                objWrapper.setOfSession.add(obj.Session__c);
                objWrapper.mapOfSKUIdVsUniqueKeys = getSKUIdVsUniqueKeys(objWrapper.mapOfSKUIdVsUniqueKeys,setProgName,obj,false);
            }
        }

        return objWrapper;
    }


    /**
    * @description 
    * @author @BK | 15-02-2024 
    * @param Map<Id Set<String>> mapOfSKUIdVsUniqueKeys 
    * @param Set<String> setProgName 
    * @param StockSkuJunction__c obj 
    * @return Map<Id, Set<String>> 
    **/
    public Map<Id,Set<String>> getSKUIdVsUniqueKeys(Map<Id,Set<String>> mapOfSKUIdVsUniqueKeys, Set<String> setProgName, StockSkuJunction__c obj, Boolean isElective) {
        String previousSession = System.Label.Previous_Session;
        Integer previousYear = Integer.valueOf(System.Label.Previous_Year);

        for (String programName : setProgName) {
            String mapKey = programName + '_' + obj.Stock_Keeping_Units__r.Launch_Year__c;
            if(isElective) {
                // Boolean setPreviousDrive =  obj.Stock_Keeping_Units__r.Semester__c == '6' ? true : false;
                // String sem = setPreviousDrive ? '5' : obj.Stock_Keeping_Units__r.Semester__c;
                // String session = setPreviousDrive ? previousSession : obj.Session__c;
                // Integer year = setPreviousDrive ? previousYear : Integer.valueOf(obj.Year__c);
                // mapKey = mapKey + '_' + sem + '_' + year + '_' + session;
                mapKey = mapKey + '_5_' + previousYear + '_' + previousSession;
            } else {
                mapKey = mapKey + '_' + obj.Stock_Keeping_Units__r.Semester__c + '_' + obj.Year__c + '_' + obj.Session__c;
            }
            Set<String> setOfKey = mapOfSKUIdVsUniqueKeys.containsKey(obj.Id) ? mapOfSKUIdVsUniqueKeys.get(obj.Id) : new Set<String>();
            setOfKey.add(mapKey);
            mapOfSKUIdVsUniqueKeys.put(obj.Id,setOfKey);
            System.debug('obj.Id 2==>'+obj.Id);
            System.debug('mapKey 2==>'+setOfKey);
        }
        return mapOfSKUIdVsUniqueKeys;
    }

    /**
    * @description 
    * @author @BK | 15-02-2024 
    * @param StockWrapper objWrapper 
    * @return String 
    **/
    public String getQuery(StockWrapper objWrapper) {
        String previousSession = System.Label.Previous_Session;
        Integer previousYear = Integer.valueOf(System.Label.Previous_Year);
        Set<String> setOfLaunchYear = objWrapper.setOfLaunchYear;
        Set<String> setOfBBAProgramName = objWrapper.setOfBBAProgramName;
        Set<String> setPrgName = objWrapper.setPrgName;
        Set<String> setOfSemester = objWrapper.setOfSemester;
        Set<Integer> setOfYear = objWrapper.setOfYear;
        Set<String> setOfSession = objWrapper.setOfSession;
        System.debug('previousSession ==>'+previousSession);
        System.debug('previousYear ==>'+previousYear);
        System.debug('setOfLaunchYear ==>'+setOfLaunchYear);
        System.debug('setOfBBAProgramName ==>'+setOfBBAProgramName);
        System.debug('setPrgName ==>'+setPrgName);
        System.debug('setOfSemester ==>'+setOfSemester);
        System.debug('setOfYear ==>'+setOfYear);
        System.debug('setOfSession ==>'+setOfSession);

        String query = 'SELECT id,nm_Program__r.Name,Launch_Year__c,nm_Semester__c,nm_Year__c,nm_Session__c,Elective_Subject_Type__c FROM Opportunity WHERE Is_Re_Registration_Payment__c=true AND Student_Status__c=\'Confirmed\' AND Launch_Year__c IN :setOfLaunchYear AND ';
        if(objWrapper.isElective) {
            query = query + ' ((nm_Program__r.Name=\'BBA\' AND nm_Semester__c=\'5\' AND nm_Year__c=:previousYear AND nm_Session__c=:previousSession AND Elective_Subject_Type__c IN :setOfBBAProgramName) OR (';
        }
        query = query + ' nm_Program__r.Name IN :setPrgName AND nm_Semester__c IN :setOfSemester AND nm_Year__c IN :setOfYear AND nm_Session__c IN :setOfSession';
        if(objWrapper.isElective) {
            query = query + '))';
        }

        System.debug('query ==>');
        System.debug(query);

        return query;
    }

    /**
    * @description 
    * @author @BK | 15-02-2024 
    * @param List<StockSkuJunction__c> lstStockSKU 
    * @param Map<Id Set<String>> mapOfSKUIdVsUniqueKeys 
    * @param Map<String List<Opportunity>> mapOfKeyVslstOpp 
    * @return List<StockSkuJunction__c> 
    **/
    public List<StockSkuJunction__c> getStockToUpdate(List<StockSkuJunction__c> lstStockSKU, Map<Id,Set<String>> mapOfSKUIdVsUniqueKeys, Map<String,List<Opportunity>> mapOfKeyVslstOpp) {
        List<StockSkuJunction__c> sjList = new List<StockSkuJunction__c>();
        for (StockSkuJunction__c obj : lstStockSKU) {
            Set<String> setOfMapKey = mapOfSKUIdVsUniqueKeys.containsKey(obj.Id) ? mapOfSKUIdVsUniqueKeys.get(obj.Id) : new Set<String>();
            Integer baseCount = 0;
            if(setOfMapKey.size() > 0) {
                for (String mapKey : setOfMapKey) {
                    baseCount = baseCount + (mapOfKeyVslstOpp.containsKey(mapKey) ? mapOfKeyVslstOpp.get(mapKey).size() : 0);
                    System.debug('mapKey exists ==>'+mapKey);
                }
            
            }
            System.debug('obj.Id ==>'+obj.Id);
            System.debug('setOfMapKey ==>'+setOfMapKey);
            System.debug('baseCount ==>'+baseCount);
            if(baseCount >= 0) {
                obj.Base_Count__c=baseCount;
                obj.Study_Kit_Stock__c = obj.Stock__r.Quantity__c;
                sjList.add(obj);
                lstSuccessOfSKUIds.add(obj.Id);
            } 
        }
        return sjList;
    }

    private class StockWrapper {
        private Set<String> setPrgName {get;set;}
        private Set<String> setOfLaunchYear {get;set;} 
        private Set<String> setOfSemester {get;set;} 
        private Set<Integer> setOfYear {get;set;}
        private Set<String> setOfSession {get;set;}
        private Boolean isElective {get;set;}
        private Set<String> setOfBBAProgramName {get;set;}
        private Map<Id,Set<String>> mapOfSKUIdVsUniqueKeys {get;set;}
        private StockWrapper() {
            this.setPrgName = new Set<String>();
            this.setOfLaunchYear = new Set<String>();
            this.setOfSemester = new Set<String>();
            this.setOfYear = new Set<Integer>();
            this.setOfSession = new Set<String>();
            this.isElective = false;
            this.setOfBBAProgramName = new Set<String>();
            this.mapOfSKUIdVsUniqueKeys = new Map<Id,Set<String>>();
        }
    }
}