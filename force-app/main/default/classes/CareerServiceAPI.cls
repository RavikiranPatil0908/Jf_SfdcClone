/**
 * @File Name          : CareerServiceAPI.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : Bala
 * @Last Modified On   : 9/4/2019, 11:29:21 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    18/3/2019, 1:56:37 PM   Balakrishnan     Initial Version
**/
@RestResource(urlMapping='/CS/v2/*')
global with sharing class CareerServiceAPI  {
    
    /**
    * @description Career Service master Request method.
    * @author Balakrishnan | 18/3/2019
    * @return @HttpPost
    */
    @HttpPost
    global static void show() {
        // Request Arguments.
        String jsonString = RestContext.request.requestbody.toString();
        
        // Request URL Parameter
        String requestUri = RestContext.request.requestURI;
        String keyUrl = requestUri.substringAfterLast('/');

        // To set Header for response
        RestContext.response.addHeader('Content-Type', 'application/json');
        CareerServiceAPIController objHelperClass = new CareerServiceAPIController();

        Blob Result = objHelperClass.RedirectToURI(keyUrl,jsonString);
        RestContext.response.responseBody = Result;
    }
}