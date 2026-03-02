/**
 * @description       : REST service for mobile app payment handling and redirection to various payment APIs.
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 02--03--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   29--09--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/api/PaymentService/*')
global without sharing class MobileAppPaymentService {

    // Instance of handler class responsible for processing payment operations
    private static MobileAppPaymentAPIHandler handler = new MobileAppPaymentAPIHandler();
    public  static Map<String,String> mapOfDevice = new Map<String,String>();

    /**
    * @description 
    * @author @Ravi | 16--10--2025 
    **/
    @HttpPost
    global static void handlePayment() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;

        String jsonString = RestContext.request.requestBody.toString();
        String requestUri = RestContext.request.requestURI;
        String keyUrl = requestUri.substringAfterLast('/');
        
        RestContext.response.addHeader('Content-Type', 'application/json;charset=UTF-8');
        mapOfDevice.put('ip',req.remoteAddress);
        mapOfDevice.put('user-Agent',req.headers.get('User-Agent'));
        Blob result = redirectToURI(keyUrl, jsonString);
        res.responseBody = result;
    }

    /**
    * @description  Routes the incoming REST call to the corresponding payment handler method.
    * @author @Ravi | 16--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public static Blob redirectToURI(String url, String jsonString){
        handler.reqURL='';
        handler.reqURL = System.Label.Site_Url+'services/apexrest/'+url;
        switch on url {
            when 'getPaymentDetails' {
                return handler.getPaymentDetails(url,jsonString);   
            } when 'applyForLoan' {  //add objDetails object later for livelecture and backlogs 
                return handler.proceedDirectToLoan(url,jsonString);
            } when 'makeOnlinePayment' {  
                return handler.makeOnlinePayment(url,jsonString,mapOfDevice);
            } when 'handlePaymentResponse' {  
                return handler.handlePaymentResponse(url,jsonString);
            } when 'proceedWithLoanApplicaation' {  
                return handler.proceedWithLoanApplication(url,jsonString);
            } when 'cancelLoanApplication' {  
                return handler.cancelLoanApplication(url,jsonString);
            }when else {
                return invalidURI();
            }
        }
    }  

    public static Blob invalidURI() {
        return buildResponse('NOT_FOUND', 'Could not find a match for URL', null);
    }

    /**
    * @description 
    * @author @Ravi | 16--10--2025 
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