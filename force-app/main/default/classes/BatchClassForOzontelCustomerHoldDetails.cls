public with sharing class BatchClassForOzontelCustomerHoldDetails implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    private static final String API_ENDPOINT_URL = 'https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/GetCustomerHoldDetailsCDR/getCustomerHoldCDR?apiKey=' + System.Label.OzontelAPIKey;
    public Map<String, CustomerHolDetail> mapOfCallNumberVsCustomerHoldDetail = new Map<String, CustomerHolDetail>();

   // https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/GetCustomerHoldDetailsCDR/getCustomerHoldCDR?apiKey={{apiKey}}&userName={{userName}}&fromDate=2023-11-29&format=json
    public void execute(SchedulableContext sc) {
        BatchClassForOzontelCustomerHoldDetails b = new BatchClassForOzontelCustomerHoldDetails();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('BatchClassForOzontelCustomerHoldDetails Batch Class Started');
        mapOfCallNumberVsCustomerHoldDetail = fetchCallData();
        String query = '';
        if (mapOfCallNumberVsCustomerHoldDetail.isEmpty()) {
            query = 'SELECT Id, Customer_number__c, Schedule_Call_Time__c FROM Task WHERE Subject=\'BatchClassForOzontelCustomerHoldDetails\''; // No such subject so task will be null
        } else {
            query = 'SELECT Id, Customer_number__c, Schedule_Call_Time__c FROM Task WHERE Subject=\'Call Scheduling\' AND Call_date__c=YESTERDAY AND Hold_Start_Time__c = null AND Customer_number__c != null AND Schedule_Call_Time__c != null';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Task> scope) {
        List<Task> lstTaskUpdate = new List<Task>();
        for (Task objTask : scope) {
            String key = objTask.Customer_number__c + '|' + String.valueOf( objTask.Schedule_Call_Time__c);
            if(mapOfCallNumberVsCustomerHoldDetail.containsKey(key)) {
                CustomerHolDetail CustomerHolDetail = mapOfCallNumberVsCustomerHoldDetail.get(key);
                Task upTask = new Task();
                upTask.Id = objTask.Id;
                upTask.Hold_Duration__c = CustomerHolDetail.HoldDuration;
                upTask.Hold_Ended_After_Call__c = CustomerHolDetail.HoldEndedAfterCall;
                upTask.Hold_End_Time__c = CustomerHolDetail.HoldEndTime;
                upTask.Hold_Started_After_Call__c = CustomerHolDetail.HoldStartedAfterCall;
                upTask.Hold_Start_Time__c = CustomerHolDetail.HoldStartTime;
                lstTaskUpdate.add(upTask);
            }
        }
        update lstTaskUpdate;
    }


    public void finish(Database.BatchableContext bc) {
        System.debug('BatchClassForOzontelCustomerHoldDetails Batch Class Finished');
    }


    public Map<String, CustomerHolDetail>  fetchCallData() {
        Map<String, CustomerHolDetail> mapOfCallVsHoldDetail = new Map<String, CustomerHolDetail>();
        DateTime startDate = System.today().addDays(-1);
        String encodedStartDate = EncodingUtil.urlEncode(startDate.format('yyyy-MM-dd'), 'UTF-8');
        String reqBoby = '&userName=nmims_2&fromDate='+encodedStartDate+'&format=json';
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
            if(mapOfJsonResponse.get('message') == 'success') {
                List<Object> lstCallData = (List<Object>)mapOfJsonResponse.get('data');
                for (Object obj : lstCallData) {
                    Map<String, Object> callMap = (Map<String, Object>)obj;
                    CustomerHolDetail CustomerHolDetail = new CustomerHolDetail();
                    CustomerHolDetail.CallerNo = String.isNotBlank((String) callMap.get('Caller No')) ? ((String) callMap.get('Caller No')).right(10) : null;
                    CustomerHolDetail.CallStartTime = String.isNotBlank((String) callMap.get('Call Start Time')) ? DateTime.Valueof((String) callMap.get('Call Start Time')) : null;
                    CustomerHolDetail.HoldStartTime = String.isNotBlank((String) callMap.get('Hold Start Time')) ? DateTime.Valueof((String) callMap.get('Hold Start Time')) : null;
                    CustomerHolDetail.HoldEndTime = String.isNotBlank((String) callMap.get('Hold End Time')) ? DateTime.Valueof((String) callMap.get('Hold End Time')) : null;
                    CustomerHolDetail.HoldDuration = gettotalMinutesAPI((String) callMap.get('Hold Duration'));
                    CustomerHolDetail.HoldStartedAfterCall = gettotalMinutesAPI((String) callMap.get('Hold Started After Call'));
                    CustomerHolDetail.HoldEndedAfterCall = gettotalMinutesAPI((String) callMap.get('Hold Ended After Call'));
                    if (String.isNotBlank(CustomerHolDetail.CallerNo) && CustomerHolDetail.CallStartTime != null) {
                        mapOfCallVsHoldDetail.put(CustomerHolDetail.CallerNo + '|' + String.valueOf(CustomerHolDetail.CallStartTime), CustomerHolDetail);
                    }
                }
            }
        }
        return mapOfCallVsHoldDetail;
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

    public class CustomerHolDetail {
        public String CallerNo {get;set;}
        public DateTime CallStartTime {get;set;}
        public DateTime HoldStartTime {get;set;}
        public DateTime HoldEndTime {get;set;}
        public Decimal HoldDuration {get;set;}
        public Decimal HoldStartedAfterCall {get;set;}
        public Decimal HoldEndedAfterCall {get;set;}
        public CustomerHolDetail() {
            CallStartTime = null;
            CallerNo = null;
            HoldDuration = null;
            HoldEndTime = null;
            HoldDuration = null;
            HoldDuration = null;
            HoldDuration = null;
        }
    }
}