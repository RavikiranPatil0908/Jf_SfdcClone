/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 25--05--2025
 * @last modified by  : @Ravi
**/
public without sharing class APIRequestHandler {

    private static List<API_Request__c> apiLogsBuffer = new List<API_Request__c>();

    /**
     * @description Logs API requests and responses into a custom Salesforce object for auditing purposes.
     * @param req The request body or endpoint.
     * @param res The response body or status code.
     * @param apiName The name of the API being logged.
     * @param isSuccess Indicates whether the API call was successful.
     * @param recordId The Salesforce record ID related to this operation.
     * @param sObjName The Salesforce object name derived from the record ID.
     */
    public static void insertAPIRequest(String req, String res, String apiName, Boolean isSuccess, Id recordId, String sObjName, String typeOfRequest) {
        try {
            if(recordId == null) {
                return;
            }
            API_Request__c apiReq = new API_Request__c();
            apiReq.API_Name__c = apiName;
            apiReq.Request__c = req;
            apiReq.Response__c = res;
            apiReq.Success__c = isSuccess;
            apiReq.Type_of_Request__c = typeOfRequest;
            apiReq.Lead__c = sObjName == 'Lead' ? recordId : null;
            apiReq.Account__c = sObjName == 'Account' ? recordId : null;
            apiReq.Opportunity__c = sObjName == 'Opportunity' ? recordId : null;
            insert apiReq;
        } catch (Exception error) {
            System.debug('Insert API Request Error');
            System.debug(error.getMessage());
        }
        
    }

    public static void queueAPIRequest(String req, String res, String apiName, Boolean isSuccess, Id recordId, String sObjName, String typeOfRequest) {
        try {
      
        if (recordId == null) return;

        API_Request__c apiReq = new API_Request__c();
        apiReq.API_Name__c = apiName;
        apiReq.Request__c = req;
        apiReq.Response__c = res;
        apiReq.Success__c = isSuccess;
        apiReq.Type_of_Request__c = typeOfRequest;
        apiReq.Lead__c = sObjName == 'Lead' ? recordId : null;
        apiReq.Account__c = sObjName == 'Account' ? recordId : null;
        apiReq.Opportunity__c = sObjName == 'Opportunity' ? recordId : null;

        apiLogsBuffer.add(apiReq);
        
      } catch (Exception error) {
        System.debug('Insert API Request Error');
        System.debug(error.getMessage());
    }
    }

    public static void flushLogs() {
        try {
            if (!apiLogsBuffer.isEmpty()) {
                insert apiLogsBuffer;
                apiLogsBuffer.clear();
            }
        } catch (Exception e) {
            System.debug('Error flushing API logs: ' + e.getMessage());
        }
    }
    
    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param Id recordId 
    * @return String 
    **/
    public static String getObjName(Id recordId) {
        return recordId!=null ? recordId.getSObjectType().getDescribe().getName() : null;
    }
}