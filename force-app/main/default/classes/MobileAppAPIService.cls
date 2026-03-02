/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 21--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   08--08--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/api/LeadAccountService/*')
global without sharing class MobileAppAPIService {

    // POST endpoint to save form data
    @HttpPost
    global static void saveData() {
            RestResponse res = RestContext.response;
            RestRequest req = RestContext.request;
            String jsonString = RestContext.request.requestbody.toString();
            // Request URL Parameter
            String requestUri = RestContext.request.requestURI;
            String keyUrl = requestUri.substringAfterLast('/');
            // To set Header for response
            RestContext.response.addHeader('Content-Type', 'application/json;charset=UTF-8');
            Blob result = redirectToURI(keyUrl,jsonString);
            res.responseBody = result;
    }

    /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public static Blob redirectToURI(String url, String jsonString){
        MobileAppFormPageAPIHandler handler= new MobileAppFormPageAPIHandler();
        handler.reqURL ='';
        handler.reqURL = System.Label.Site_Url+'services/apexrest/'+url;
        switch on url {
            when 'getDashboardDetails' {
               return  handler.getDashboardDetails(url,jsonString);
            } when 'getLeadAccountDetails' {
               return  handler.fetchDetails(url,jsonString);
            } when 'updateLead' {
                return handler.updateLead(url,jsonString);    
            } when 'goToConfirmationForm' {
                return handler.goToConfirmationForm(url,jsonString);
            } when 'getDocuments' {
               return  handler.getDocuments(url,jsonString);
            } when 'getpickListvalues' {
                return handler.getPicklistValues(url,jsonString);
            } when 'getProgrampickListvalues' {
                return handler.getProgramPicklistValues(url,jsonString);
            } when 'validateLateral' {
                return handler.checkLateralValidations(url,jsonString);
            } when 'updateLateralDetails' {
                return handler.updateLateralDetails(url,jsonString);
            } when 'updateNonLateral' {
                return handler.updateAsNonLateral(url,jsonString);
            } when 'verifyDEB' {
                return handler.handleDEBVerification(url,jsonString);
            } when 'getInterviewDetails' {
                return handler.getInterviewDetails(url,jsonString);
            } when 'getInterviewTimeSlot' {
                return handler.getInterviewSlot(url,jsonString);
            } when 'saveCallDetails' {
                return handler.saveInterviewCallDetails(url,jsonString);
            } when 'getWelcomeLetter' {
                return handler.getWelcomeLetter(url,jsonString);
            } when 'uploaddocuments' {
                return handler.uploadDocuments(url,jsonString);
            }
             when else {
                return invalidURI();
            }
        }
    }

        /**
    * @description 
    * @author @Ravi | 22--09--2025 
    * @return Blob 
    **/
    public static Blob invalidURI() {
        return buildResponse('NOT_FOUND', 'Could not find a match for URL', null);
    }

    /**
    * @description 
    * @author @Ravi | 29--09--2025 
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