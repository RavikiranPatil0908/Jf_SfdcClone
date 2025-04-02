/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
public without sharing class GenerateCloudfrontLinks {
    
    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param List<String> lstUrls 
    * @param Id recordId 
    **/
    public static CloudfrontUrlOnFileUpload generateLinks(List<String> lstUrls, Id recordId) {
        HttpRequest req = new HttpRequest();
        // Setting up the request endpoint and headers
        req.setEndpoint(System.Label.Student_Zone_Base_Url + 'studentportal/m/getCloudfrontUrlOnFileUpload');
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');

        // Constructing the JSON body for the POST request
        String jsonBody = '{"id": "' + String.escapeSingleQuotes(recordId) + '",'+
                            '"links":['; 
        // Start of JSON array
        List<String> jsonObjects = new List<String>();
        
        for (String url : lstUrls) {
            String jsonObject = '{"fileUrl": "' + url + '", "awsUrl": ""}';
            jsonObjects.add(jsonObject);
        }
        
        // Join all JSON objects with a comma
        jsonBody += String.join(jsonObjects, ',');
        jsonBody += ']}'; // End of JSON array
        
        // Output the final JSON body
        System.debug(jsonBody);

        req.setBody(jsonBody);

        // Handling the API response
        return handleCloudfrontUrlOnFileUpload(req, 'CloudfrontUrlOnFileUpload', recordId);        
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param HttpRequest req 
    * @param String apiName 
    * @param Id recordId 
    * @return CloudfrontUrlOnFileUpload 
    **/
    private static CloudfrontUrlOnFileUpload handleCloudfrontUrlOnFileUpload(HttpRequest req, String apiName, Id recordId) {
        Http http = new Http();
        HttpResponse resp;
        CloudfrontUrlOnFileUpload response = new CloudfrontUrlOnFileUpload();
        String sObjName = APIRequestHandler.getObjName(recordId);

        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                response = CloudfrontUrlOnFileUpload.parse(resp.getBody());
                // APIRequestHandler.insertAPIRequest(req.getBody(), resp.getBody(), apiName, true, recordId, sObjName, 'PortalAPI');
                return response;
            } 
            // else {
                // APIRequestHandler.insertAPIRequest(req.getBody(), resp.getBody(), apiName, false, recordId, sObjName, 'PortalAPI');
            // }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' -- ' + e.getLineNumber());
            // APIRequestHandler.insertAPIRequest(req.getBody(), e.getMessage() + ' -- ' + e.getLineNumber(), apiName, false, recordId, sObjName, 'PortalAPI');
        }
        return null;
    }
}