public with sharing class BatchClassForOzontelAverageAgentSummary implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    private static final String API_ENDPOINT_URL = 'https://in1-ccaas-api.ozonetel.com/CAServices/AgentState/SummaryReport.php?apiKey=' + System.Label.OzontelAPIKey;

   // https://in1-ccaas-api.ozonetel.com/CAServices/AgentState/SummaryReport.php?apiKey={{apiKey}}&userName={{userName}}&format={{format}}&fromDate=2023-11-29&toDate=2023-11-30
    public void execute(SchedulableContext sc) {
        BatchClassForOzontelAverageAgentSummary b = new BatchClassForOzontelAverageAgentSummary();
        Database.executebatch(b, 200);
    }

    public List<SObject> start(Database.BatchableContext bc) { 
        System.debug('BatchClassForOzontelAverageAgentSummary Batch Class Started');
        List<Agent_State_Summary__c> dummyList = new List<Agent_State_Summary__c>{new Agent_State_Summary__c()};
        system.debug('dummyList --> ' + dummyList.size());
        return dummyList;
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('lstTask Size ==>');
        List<Agent_State_Summary__c> lstAgentSummary = new List<Agent_State_Summary__c>();
        for (AverageAgentSummary objAgeAvgSummary : fetchCallData()) {
            Agent_State_Summary__c objAgent = new Agent_State_Summary__c();
            objAgent.Agent_Id__c = objAgeAvgSummary.AgentId;
            objAgent.Agent_Name__c = objAgeAvgSummary.AgentName;
            objAgent.Call_Date__c = objAgeAvgSummary.CallDate;
            objAgent.Mode_Type__c = objAgeAvgSummary.ModeType;
            objAgent.Total_Busy_Time__c = objAgeAvgSummary.TotalBusyTime;
            objAgent.Total_Dial_Time__c = objAgeAvgSummary.TotalDialTime;
            objAgent.Total_Idle_Time__c = objAgeAvgSummary.TotalIdleTime;
            objAgent.Total_Login_Duration__c = objAgeAvgSummary.TotalLoginDuration;
            objAgent.Total_Pause_Time__c = objAgeAvgSummary.TotalPauseTime;
            objAgent.Total_Wrapup_Time__c = objAgeAvgSummary.TotalWrapupTime;
            lstAgentSummary.add(objAgent);
        }
        if (lstAgentSummary.size() > 0) {
            insert lstAgentSummary;
        }
    }


    public void finish(Database.BatchableContext bc) {
        System.debug('BatchClassForOzontelAverageAgentSummary Batch Class Finished');
    }


    public List<AverageAgentSummary>  fetchCallData() {
        List<AverageAgentSummary> lstAverageAgentSummary = new List<AverageAgentSummary>();
        Set<String> setOfkey = new Set<String>();
        for (Agent_State_Summary__c objAvergeAgentSummary : [SELECT Id, key__c FROM Agent_State_Summary__c WHERE Call_Date__c = YESTERDAY]) {
            setOfkey.add(objAvergeAgentSummary.key__c);
        }
        DateTime startDate = System.today().addDays(-1);
        String encodedStartDate = EncodingUtil.urlEncode(startDate.format('yyyy-MM-dd'), 'UTF-8');
        DateTime endDate = System.today();
        String encodedEndDate = EncodingUtil.urlEncode(endDate.format('yyyy-MM-dd'), 'UTF-8');
        String reqBoby = '&userName=nmims_2&format=json&fromDate='+encodedStartDate+'&toDate='+encodedEndDate;
        String uri = API_ENDPOINT_URL + reqBoby;
        System.debug(uri);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri);
        req.setMethod('GET');
        req.setHeader('accept', 'application/json');
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            String jsonResponse = res.getBody();
            Map<String,Object> mapOfJsonResponse = (Map<String,Object>) JSON.deserializeUntyped(jsonResponse);
            System.debug(mapOfJsonResponse.size());
            if(mapOfJsonResponse.get('status') == 'success') {
                List<Object> lstData = (List<Object>)mapOfJsonResponse.get('message');
                for (Object obj : lstData) {
                    Map<String, Object> callMap = (Map<String, Object>)obj;
                    AverageAgentSummary AverageAgentSummary = new AverageAgentSummary();
                    AverageAgentSummary.CallDate = String.isNotBlank((String) callMap.get('CallDate')) ? Date.Valueof((String) callMap.get('CallDate')) : null;
                    AverageAgentSummary.AgentId =  String.isNotBlank((String) callMap.get('AgentId')) ? ((String) callMap.get('AgentId')) : null;
                    AverageAgentSummary.AgentName =  String.isNotBlank((String) callMap.get('AgentName')) ? ((String) callMap.get('AgentName')) : null;
                    AverageAgentSummary.ModeType =  String.isNotBlank((String) callMap.get('ModeType')) ? ((String) callMap.get('ModeType')) : null;
                    AverageAgentSummary.TotalBusyTime = gettotalMinutesAPI((String) callMap.get('TotalBusyTime'));
                    AverageAgentSummary.TotalDialTime = gettotalMinutesAPI((String) callMap.get('TotalDialTime'));
                    AverageAgentSummary.TotalIdleTime = gettotalMinutesAPI((String) callMap.get('TotalIdleTime'));
                    AverageAgentSummary.TotalLoginDuration = gettotalMinutesAPI((String) callMap.get('TotalLoginDuration'));
                    AverageAgentSummary.TotalPauseTime = gettotalMinutesAPI((String) callMap.get('TotalPauseTime'));
                    AverageAgentSummary.TotalWrapupTime = gettotalMinutesAPI((String) callMap.get('TotalWrapupTime'));
                    AverageAgentSummary.key = String.valueOf(AverageAgentSummary.CallDate) + '|' + AverageAgentSummary.AgentId + '|' + AverageAgentSummary.ModeType;
                    if (String.isNotBlank(AverageAgentSummary.AgentId) && AverageAgentSummary.CallDate != null && !setOfkey.contains(AverageAgentSummary.key)) {
                        lstAverageAgentSummary.add(AverageAgentSummary);
                    }
                }
            }
        }
        return lstAverageAgentSummary;
    }

    public static Decimal gettotalMinutesAPI(String duration) {
        Decimal totalDuration = 0;
        if(String.isNotBlank(duration)) {
            String[] strTimeSplit = String.valueOf(duration).split(':');
            if(strTimeSplit[0]!='00' && strTimeSplit[0].isNumeric()) {
                totalDuration = Decimal.valueOf(strTimeSplit[0]);
                totalDuration = totalDuration * 60;
            }
            if(strTimeSplit[1]!='00' && strTimeSplit[1].isNumeric()) {
                totalDuration += Decimal.valueOf(strTimeSplit[1]);
            }
            if(strTimeSplit[2]!='00' && strTimeSplit[2].isNumeric()) {
                totalDuration = totalDuration + (Decimal.valueOf(strTimeSplit[2]) / 100);
            }
        }
        return totalDuration;
    }

    public class AverageAgentSummary {
        public Date CallDate {get;set;}
        public String AgentId {get;set;}
        public String AgentName {get;set;}
        public String ModeType {get;set;}
        public Decimal TotalBusyTime {get;set;}
        public Decimal TotalWrapupTime {get;set;}
        public Decimal TotalPauseTime {get;set;}
        public Decimal TotalDialTime {get;set;}
        public Decimal TotalIdleTime {get;set;}
        public Decimal TotalLoginDuration {get;set;}
        public String key {get;set;}
        public AverageAgentSummary() {
            CallDate = null;
            AgentId = null;
            AgentName = null;
            ModeType = null;
            TotalBusyTime = null;
            TotalWrapupTime = null;
            TotalPauseTime = null;
            TotalDialTime = null;
            TotalIdleTime = null;
            TotalLoginDuration = null;
            key = null;
        }
    }
}