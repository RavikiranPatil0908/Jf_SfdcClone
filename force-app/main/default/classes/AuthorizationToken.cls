/**
 * @description       : 
 * @author            : @Suyog
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : @BK
**/
public class AuthorizationToken {

    /**
    * @description 
    * @author @Suyog | 07-12-2023 
    * @param type 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getCashFreeAuthorizationToken(String type) {
        Map<String, Object> mapOfResponse = new Map<String, Object>();
        try{
            String apiUrl = 'https://studentzone-ngasce.nmims.edu/studentportal/m/getCashFreeTokenForSFDC?type=' + type;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiUrl);
            request.setMethod('POST');
            
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            response = http.send(request);
            system.debug('response.getBody() --> ' + response.getBody());
            system.debug('response.getStatusCode() --> '+ response.getStatusCode());
            if (response.getStatusCode() == 200) {
                mapOfResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            } 
        }catch(Exception e){
            system.debug(e);
        }
        return mapOfResponse;
    }
}