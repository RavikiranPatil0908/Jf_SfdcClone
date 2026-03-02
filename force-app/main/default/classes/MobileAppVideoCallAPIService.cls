/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   10--11--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/api/VideoCallService/*')
global without sharing class MobileAppVideoCallAPIService {

    private static MobileAppVideoCallAPIHandler handler = new MobileAppVideoCallAPIHandler();
    
    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    **/
    @HttpPost
    global static void handleVVC() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;

        String jsonString = RestContext.request.requestBody.toString();
        String requestUri = RestContext.request.requestURI;
        String keyUrl = requestUri.substringAfterLast('/');
        
        RestContext.response.addHeader('Content-Type', 'application/json;charset=UTF-8');
        Blob result = redirectToURI(keyUrl, jsonString);
        res.responseBody = result;
    }

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public static Blob redirectToURI(String url, String jsonString){
        switch on url {
            when 'getCallDetails' {
                return handler.getCallDetails(url,jsonString);
            } when 'getSlotDetails' {
                return handler.getSlotDetails(url, jsonString);
            } when 'saveSlotDetails' {
                return handler.saveSlotDetails(url, jsonString); 
            } when 'rescheduleCall' {
                return handler.rescheduleCallDetails(url, jsonString); 
             } when else {
                return invalidURI();
            }
        }
        
    }

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @return Blob 
    **/
    public static Blob invalidURI() {
        return buildResponse('Error', 'Could not find a match for URL', null);
    }

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param String status 
    * @param String message 
    * @param Object data 
    * @return Blob 
    **/
    private static Blob buildResponse(String status, String message, Object data) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', status);
        response.put('message', message);
        if (data != null) {
            response.put('data', data);
        }
        return Blob.valueOf(JSON.serialize(response));
    }
}