/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/callDetails/*')
global class CallBackUrlWebhook {

    @testVisible 
    static List<Call_Campaign__mdt> lstCampaigns { 
        get {
            if ( lstCampaigns == null )
                lstCampaigns = [SELECT MasterLabel FROM Call_Campaign__mdt]; 
            return lstCampaigns;
        } set; 
    }

    @HttpPost
    global static List<MessageWrapper> callDetails() {
        API_Request__c apiReq = new API_Request__c();
        List<MessageWrapper> lstMessageWrapper = new List<MessageWrapper>();
        try {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();
            Map<String,String> params = req.params;
            if(params.containsKey('data')) {
                requestString = params.get('data');
            }
            System.debug('requestString '+requestString);
            apiReq.Request__c = requestString;
            CallBackUrlRequestWrapper reqWrapper = CallBackUrlRequestWrapper.parse(requestString);
            System.debug(reqWrapper);
            List<String> lstCampaignNames = new List<String>();

            for (Call_Campaign__mdt objCC : lstCampaigns) {
                lstCampaignNames.add(objCC.MasterLabel);
            }
            if(!lstCampaignNames.contains(reqWrapper.CampaignName)) {
                return returnMessage(null,'200','Call details updated.',true);
            }
            if(String.isNotBlank(reqWrapper.UUI)) {
                String taskId = reqWrapper.UUI;
                //DateTime timeToAnswer = String.isNotBlank(reqWrapper.TimeToAnswer) ? DateTime.Valueof(reqWrapper.TimeToAnswer) : null;
                DateTime callDateTime = String.isNotBlank(reqWrapper.StartTime) ? DateTime.Valueof(reqWrapper.StartTime) : null;
                DateTime endDateTime = String.isNotBlank(reqWrapper.EndTime) ? DateTime.Valueof(reqWrapper.EndTime) : null;
                String query = getQueryAllFieldSql('Task', 'Id=:taskId AND Status!=\'Completed\' LIMIT 1', null);
                List<Task> lstTask = DataBase.query(query);
                if(lstTask.size() > 0) {
                    lstTask[0].Call_time__c = callDateTime!=null ? callDateTime.time() : null;
                    //Actual_Call_Date__c is equal to StartTime to store date and time
                    lstTask[0].Actual_Call_Date__c = callDateTime;
                    lstTask[0].customer_status__c = reqWrapper.CustomerStatus;
                    lstTask[0].Call_status__c = reqWrapper.Status;
                    lstTask[0].Status = reqWrapper.Status=='Answered' ? 'Completed' : 'Not Connected';
                    lstTask[0].Call_Type__c = reqWrapper.Type;
                    lstTask[0].customer_call_duration__c = String.valueOf(gettotalMinutes(reqWrapper.CallDuration));
                    lstTask[0].Call_duration__c = gettotalMinutes(reqWrapper.Duration);
                    lstTask[0].Description = reqWrapper.Comments;
                    lstTask[0].Call_Recording_Url__c = reqWrapper.AudioFile;
                    lstTask[0].Agent_Code__c = reqWrapper.AgentID;
                    lstTask[0].AgentName__c = reqWrapper.AgentName;
                    lstTask[0].Campaign_Name__c = reqWrapper.CampaignName;
                    lstTask[0].Campaign_Status__c = reqWrapper.CampaignStatus;
                    lstTask[0].Dial_Status__c = reqWrapper.DialStatus;
                    lstTask[0].Location__c = reqWrapper.Location;
                    lstTask[0].Skill__c = reqWrapper.Skill;
                    lstTask[0].Transferred_To__c = reqWrapper.TransferredTo;
                    lstTask[0].Conf_Duration__c = gettotalMinutes(reqWrapper.ConfDuration);
                    lstTask[0].End_Time__c = endDateTime!=null ? endDateTime.time() : null;
                    lstTask[0].Time_To_Answer__c = gettotalMinutes(reqWrapper.TimeToAnswer);
                    
                    update lstTask;
                    apiReq.Success__c = true;
                } 
            }
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            return returnMessage(apiReq,'504',error.getMessage(),false);
        }
        return returnMessage(apiReq,'200','Call details updated.',apiReq.Success__c);
    }

    public static Decimal gettotalMinutes(String duration) {
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

    public static String getQueryAllFieldSql(String SObjectAPIName, String conditionString, String relatedFields) {
        Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
        Map<String, schema.SObjectField> fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List<String> fieldNames = new  List<String>(fieldMap.keySet());
        if(relatedFields != null && relatedFields != '')
        {
            fieldNames.add(relatedFields);
        }
        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + SObjectAPIName + ' WHERE ' + conditionString;
        return query;
    }

    global class MessageWrapper{
        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
    }

    public static List<MessageWrapper> returnMessage(API_Request__c apiReq, String code, String msg, Boolean isSuccess) {
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        if(!isSuccess) {
            apiReq.Response__c = messageWrapper.toString();
            apiReq.Type_of_Request__c= 'Ozontel';
            apiReq.API_Name__c='CallBackUrlWebhook';
            apiReq.Success__c = isSuccess;
            apiRequestsInsertion(apiReq);
        }
        return lstmessageWrapper;
    }

    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }
}