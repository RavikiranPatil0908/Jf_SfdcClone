/**
 * @File Name          : SalesforceFetchDataAPI.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 01-20-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/4/2020   shubhranshu     Initial Version
**/
@RestResource(urlMapping='/salesforceFetchData/*')
global without sharing class SalesforceFetchDataAPI  {
    
    @HttpPost
    global static void show() {
        // Request Arguments.
        String jsonString = RestContext.request.requestbody.toString();
        
        // Request URL Parameter
        String requestUri = RestContext.request.requestURI;
        String keyUrl = requestUri.substringAfterLast('/');

        // To set Header for response
        RestContext.response.addHeader('Content-Type', 'application/json');
        ChatBotAPIController objHelperClass = new ChatBotAPIController();

        Blob Result = objHelperClass.RedirectToURI(keyUrl,jsonString);
        RestContext.response.responseBody = Result;
    }
}