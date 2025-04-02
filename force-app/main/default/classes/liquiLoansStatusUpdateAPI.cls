/**
 * @File Name          : liquiLoansStatusUpdateAPI.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 20-10-2023
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/6/2019   shubhranshu     Initial Version
**/
global without sharing class liquiLoansStatusUpdateAPI {

    webservice static string statusUpdateForLoan(String LOSId,String LoanStatus,String recordId, String recordType){
        
        String result = '';
        API_Request__c apiReq = new API_Request__c();
        try {
            HttpRequest req=new HttpRequest();
            HttpResponse res=new HttpResponse();
            Http http=new Http();
            System.debug(System.Label.LiquiLoans_status_update_URL);
            req.setEndpoint(System.Label.LiquiLoans_status_update_URL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            String JsonPostData = createJsonRequest(LOSId,LoanStatus,'statusUpdate');
            System.debug('JsonPostData '+JsonPostData);
            apiReq.Request__c = JsonPostData;
            req.setBody(JsonPostData);
            System.debug(req);
            res=http.send(req);
            Integer httpStatusCode = res.getStatusCode();
            System.debug('httpStatusCode '+httpStatusCode);
            if(httpStatusCode == 200){
                
                String jsonString = res.getBody();
                System.debug('jsonString '+jsonString);
                apiReq.Response__c = jsonString;
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(jsonString);
                System.debug('mapOfResponseParameters -->'+mapOfResponseParameters);
                result = String.valueOf(mapOfResponseParameters.get('status'));
                apiReq.API_Name__c = 'liquiLoansStatusUpdateAPI';
                apiReq.Type_of_Request__c = 'LiquiLoans';
                if(result == 'true'){
                    apiReq.Success__c = true;
                }
                if(recordType == 'Opportunity'){
                    apiReq.Opportunity__c = recordId;
                }else if(recordType == 'Lead'){
                    apiReq.Lead__c = recordId;
                }
                String message = String.valueOf(mapOfResponseParameters.get('message'));  
                System.debug('message '+message);
            }
        } catch (Exception e) {
            System.debug('Exception occured-->'+e.getMessage());
            if(String.isBlank(apiReq.Response__c)){
                apiReq.Response__c = e.getMessage();
            }
        }
        apiRequestsInsertion(apiReq);
        // return LoanStatus == 'N' ? 'true' : result;
        return result;
        
    }

    webservice static string CheckStatus(String LOSId,String recordId, String recordType){
        
        String result = '';
        API_Request__c apiReq = new API_Request__c();
        try {
            HttpRequest req=new HttpRequest();
            HttpResponse res=new HttpResponse();
            Http http=new Http();
            System.debug(System.Label.LiquiLoans_Check_Status_URL);
            req.setEndpoint(System.Label.LiquiLoans_Check_Status_URL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            String JsonPostData = createJsonRequest(LOSId,'','CheckStatus');
            System.debug('JsonPostData '+JsonPostData);
            apiReq.Request__c = JsonPostData;
            req.setBody(JsonPostData);
            System.debug(req);
            res=http.send(req);
            Integer httpStatusCode = res.getStatusCode();
            System.debug('httpStatusCode '+httpStatusCode);
            if(httpStatusCode == 200){
                
                String jsonString = res.getBody();
                System.debug('jsonString '+jsonString);
                apiReq.Response__c = jsonString;
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(jsonString);
                System.debug('mapOfResponseParameters -->'+mapOfResponseParameters);
                if(!mapOfResponseParameters.isEmpty()){
                    Map<String,Object> mapOfDataParameters = (Map<String,Object>)mapOfResponseParameters.get('data');
                    Map<String,Object> mapOfStatusParameters = (Map<String,Object>)mapOfDataParameters.get('status');
                    
                    result = String.valueOf(mapOfStatusParameters.get('status'));
                    apiReq.API_Name__c = 'liquiLoansCheckStatusAPI';
                    apiReq.Type_of_Request__c = 'LiquiLoans';
                    if(Boolean.valueOf(mapOfResponseParameters.get('status'))){
                        apiReq.Success__c = true;
                    }
                    if(recordType == 'Opportunity'){
                        apiReq.Opportunity__c = recordId;
                    }else if(recordType == 'Lead'){
                        apiReq.Lead__c = recordId;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception occured-->'+e.getMessage());
            if(String.isBlank(apiReq.Response__c)){
                apiReq.Response__c = e.getMessage();
            }
        }
        apiRequestsInsertion(apiReq);
        return result;
        
    }

     /**
    * @description for log generation in API Request .
    * @author shubhranshu | 12/3/2019 
    * @param apiRequest 
    * @return void 
    **/
    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                System.debug('apiRequest ==>'+apiRequest);
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static String createJsonRequest(String LOSId , String LoanStatus,String Type){
        String sid = System.Label.LiquiLoans_SID;
        Datetime myDT = Datetime.now();
        String Timestamp = myDT.format('yyyy-MM-dd hh:mm:ss');
        System.debug('Timestamp ==>'+Timestamp);
        Map<String,String> liquiLoasParams = new Map<String,String>();
        if(Type == 'statusUpdate'){
            String checksum = generateChecksum(sid,LOSId,LoanStatus,Timestamp,'statusUpdate');
            liquiLoasParams.put('sid', sid);
            liquiLoasParams.put('checksum', checksum);
            liquiLoasParams.put('application_id', LOSId);
            liquiLoasParams.put('application_status', LoanStatus);
            liquiLoasParams.put('timestamp', Timestamp);
        }else if(Type == 'CheckStatus'){
            String checksum = generateChecksum(sid,LOSId,'',Timestamp,'CheckStatus');
            liquiLoasParams.put('SID', sid);
            liquiLoasParams.put('Checksum', checksum);
            liquiLoasParams.put('application_id', LOSId);
            liquiLoasParams.put('Timestamp', Timestamp);
        }

        String postData = JSON.serialize(liquiLoasParams);
        System.debug('Post Data request-->'+postData);

		return postData;
    }

    public static String generateChecksum(String sid,String ApplicationId,String ApplicationStatus,String TimeStamp,String Type){
        String salt ='';
        if(Type == 'statusUpdate'){
            salt = sid+'|'+ApplicationId+'|'+ApplicationStatus+'|'+TimeStamp;
        }else if(Type == 'CheckStatus'){
            salt = sid+'||'+TimeStamp+'||'+ApplicationId;
        }
        System.debug('salt value '+salt);
        String key = System.Label.LiquiLoans_Api_Key;
        Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
        System.debug('checksum ==>'+ EncodingUtil.convertToHex(data));
        return  EncodingUtil.convertToHex(data);
    }
}