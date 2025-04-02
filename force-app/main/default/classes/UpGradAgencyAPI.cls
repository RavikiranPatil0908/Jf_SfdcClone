/**
 * @File Name          : UpGradAgencyAPI.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/10/2019, 4:57:20 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    13/4/2019, 11:53:43 AM   @BK     Initial Version
**/
@RestResource(urlMapping='/RestResource/v1/*')
global class UpGradAgencyAPI {
    
    /**
    * @description - Master Request Method. 
    * @author @BK | 13/4/2019
    * @return void
    */
    @HttpPost
    global static void show() {
        // Request Arguments.
        String jsonString = RestContext.request.requestbody.toString();
        
        // Request URL
        String requestUri = RestContext.request.requestURI;
        String keyUrl = requestUri.substringAfterLast('/');

        RestContext.response.addHeader('Content-Type', 'application/json');
        upGradAPIController objHelperClass = new upGradAPIController();

        Blob result = objHelperClass.redirectToURI(keyUrl,jsonString);
        RestContext.response.responseBody = result;
    }

}