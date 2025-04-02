/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-02-2024
 * @last modified by  : @BK
**/
public class BatchClassForCalllogs implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {

    private static final String API_ENDPOINT_URL = 'https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/getCallLogs?api_key=' + System.Label.OzontelAPIKey;
    
    public void execute(SchedulableContext sc) {
        BatchClassForCalllogs b = new BatchClassForCalllogs();
        Database.executebatch(b, 200);
    }

    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @param Database.BatchableContext bc 
    * @return List<SObject> 
    **/
    public List<SObject> start(Database.BatchableContext bc) { 
        System.debug('BatchClassForCallLogs Batch Class Started');
        List<Task> dummyList = new List<Task>{new Task()};
        return dummyList;
    }


    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @param Database.BatchableContext bc 
    * @param List<SObject> scope 
    **/
    public void execute(Database.BatchableContext bc, List<SObject> scope) { 
        System.debug('lstTask Size ==>');
        List<CallBackUrlRequestWrapper> callDataList = fetchCallData();
        if(callDataList.size() > 0) {
            Map<String,List<Task>> mapOfNumberVsTasks = getScheduledTask();
            String[] filtersForLikeQuery = new List<String>();
            String[] filtersForEqualQuery = new List<String>();
            for (CallBackUrlRequestWrapper objCallData : callDataList) {
                String customerNumber = objCallData.CallerID.right(10);
                if(!isExists(customerNumber,mapOfNumberVsTasks,objCallData.StartTime)) {
                    String phoneNo = '%' + customerNumber;
                    filtersForLikeQuery.add(phoneNo);
                    filtersForEqualQuery.add(customerNumber);
                }
            }
            System.debug('Filters Size ==>'+filtersForLikeQuery.size());
            if(filtersForLikeQuery.size() > 0) {
                List<Task> tasksToInsert = setTask(filtersForLikeQuery,filtersForEqualQuery,callDataList); 
                System.debug('tasksToInsert ==>'+tasksToInsert.size());
                if(tasksToInsert.size() > 0) {
                    insert tasksToInsert;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finished ==>');
    }

    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @param String customerNumber 
    * @param Map<String List<Task>> mapOfNumberVsTasks 
    * @param String startTime 
    * @return Boolean 
    **/
    public Boolean isExists(String customerNumber, Map<String,List<Task>> mapOfNumberVsTasks, String startTime) {
        Boolean isExists = false;
        DateTime callDateTime = String.isNotBlank(startTime) ? DateTime.Valueof(startTime) : null;
        if(mapOfNumberVsTasks.containsKey(customerNumber)) {
            List<Task> lst = mapOfNumberVsTasks.get(customerNumber);
            for (Task obj : lst) {
                if(obj.Actual_Call_Date__c == callDateTime) {
                    isExists = true;
                }
            }
        }
        return isExists;
    }


    /**
    * @description 
    * @author @BK | 28-02-2024 
    * @param List<String> setOfCustomerNoSQ 
    * @param List<String> setOfCustomerNoEQ 
    * @param List<CallBackUrlRequestWrapper> callDataList 
    * @return List<Task> 
    **/
    public List<Task> setTask(List<String> setOfCustomerNoSQ, List<String> setOfCustomerNoEQ, List<CallBackUrlRequestWrapper> callDataList) {
        
        // Query Accounts
        Map<String, Account> accountsMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, PersonMobilePhone FROM Account WHERE PersonMobilePhone != null AND PersonMobilePhone != '' AND PersonMobilePhone LIKE :setOfCustomerNoSQ]) {
            accountsMap.put(acc.PersonMobilePhone.right(10), acc);
        }
        System.debug('accountsMap Size ==>'+accountsMap.size());

        // Query Leads
        Map<String, Lead> leadsMap = new Map<String, Lead>();
        for (Lead lead : [SELECT Id, MobilePhone FROM Lead WHERE IsConverted=false AND MobilePhone!=null AND MobilePhone!= '' AND MobilePhone IN :setOfCustomerNoEQ]) {
            leadsMap.put(lead.MobilePhone.right(10), lead);
        }
        System.debug('leadsMap Size ==>'+leadsMap.size());

        List<Task> tasksToInsert = new List<Task>();
        for (CallBackUrlRequestWrapper callData : callDataList) {
            String customerNumber = callData.CallerID.right(10);
            System.debug('customerNumber ==>'+customerNumber);
            if (accountsMap.containsKey(customerNumber)) {
                Task newTask = createTask(callData);
                newTask.WhatId = accountsMap.get(customerNumber).Id;
                tasksToInsert.add(newTask);
            } else if (leadsMap.containsKey(customerNumber)) {
                System.debug('entered else if condition');
                Task newTask = createTask(callData);
                newTask.WhoId = leadsMap.get(customerNumber).Id;
                tasksToInsert.add(newTask);
            }
        }

        return tasksToInsert;
    }


    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @param CallBackUrlRequestWrapper callData 
    * @return Task 
    **/
    public Task createTask(CallBackUrlRequestWrapper callData) {
        Task newTask = new Task();
        DateTime callDateTime = callData.StartTime != null ? DateTime.Valueof(callData.StartTime) : null;
        DateTime endDateTime = callData.EndTime != null ? DateTime.Valueof(callData.EndTime) : null;
        System.debug(callData);
        newTask.Subject = 'Call Scheduling'; 
        // newTask.ActivityDate = Date.today(); 
        newTask.Call_time__c = callDateTime!=null ? callDateTime.time() : null;
        //Actual_Call_Date__c is equal to StartTime to store date and time
        newTask.Actual_Call_Date__c = callDateTime;
        newTask.Call_date__c = Date.newInstance(callDateTime.year(), callDateTime.month(), callDateTime.day());
        newTask.Schedule_Call_Time__c = callDateTime;
        newTask.customer_status__c = callData.CustomerStatus;
        newTask.Call_status__c = callData.Status;
        newTask.Status = callData.Status=='Answered' ? 'Completed' : 'Not Connected';
        newTask.Call_Type__c = callData.Type;
        newTask.customer_call_duration__c = String.valueOf(gettotalMinutesAPI(callData.CallDuration));
        newTask.Call_duration__c = gettotalMinutesAPI(callData.Duration);
        newTask.Description = callData.Comments;
        newTask.Call_Recording_Url__c = callData.AudioFile;
        newTask.Agent_Code__c = callData.AgentID;
        newTask.AgentName__c = callData.AgentName;
        newTask.Campaign_Name__c = callData.CampaignName;
        newTask.Campaign_Status__c = callData.CampaignStatus;
        newTask.Dial_Status__c = callData.DialStatus;
        newTask.Location__c = callData.Location;
        newTask.Skill__c = callData.Skill;
        newTask.Transferred_To__c = callData.TransferredTo;
        newTask.Customer_number__c = callData.CallerID.right(10);
        newTask.Conf_Duration__c = gettotalMinutesAPI(callData.ConfDuration);
        newTask.End_Time__c = endDateTime!=null ? endDateTime.time() : null;
        newTask.Time_To_Answer__c = gettotalMinutesAPI(callData.TimeToAnswer);
        return newTask;
    } 

    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @param String duration 
    * @return Decimal 
    **/
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

    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @return Map<String, List<Task>> 
    **/
    public Map<String,List<Task>> getScheduledTask() {
        Map<String,List<Task>> mapOfNumberVsTasks = new Map<String,List<Task>>();
        List<Task> lstTask = [SELECT id,Subject,Call_uuid__c,Actual_Call_Date__c,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status,Schedule_Call_Time__c,Call_Scheduled_Key__c FROM Task WHERE Subject='Call Scheduling' AND Call_date__c=YESTERDAY];
        for (Task obj : lstTask) {
            List<Task> lst = mapOfNumberVsTasks.containsKey(obj.Customer_number__c) ? mapOfNumberVsTasks.get(obj.Customer_number__c) : new List<Task>();
            lst.add(obj);
            mapOfNumberVsTasks.put(obj.Customer_number__c, lst);
        }
        return mapOfNumberVsTasks;
    }

    /**
    * @description 
    * @author @BK | 27-02-2024 
    * @return List<CallBackUrlRequestWrapper> 
    **/
    public List<CallBackUrlRequestWrapper> fetchCallData() {
        List<CallBackUrlRequestWrapper> callDataList = new List<CallBackUrlRequestWrapper>();
        DateTime startDate = System.today().addDays(-1);
        DateTime endDate = System.today();
        String encodedStartDate = EncodingUtil.urlEncode(startDate.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8');
        String encodedEndDate = EncodingUtil.urlEncode(endDate.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8');
        String reqBoby = '&user_name=nmims_2&from_date=' + encodedStartDate + '&to_date=' + encodedEndDate + '&format=json';
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
                List<Object> lstCallData = (List<Object>)mapOfJsonResponse.get('message');
                for (Object obj : lstCallData) {
                    Map<String, Object> callMap = (Map<String, Object>)obj;
                    String callData = JSON.serialize(obj);
                    CallBackUrlRequestWrapper objWrapper = CallBackUrlRequestWrapper.parse(callData);
                    callDataList.add(objWrapper);
                }
            }
        }
        System.debug('callDataList size ==> '+callDataList.size());
        return callDataList;
    }
}