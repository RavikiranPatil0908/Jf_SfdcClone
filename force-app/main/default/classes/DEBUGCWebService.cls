/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-09-2024
 * @last modified by  : @BK
**/
public class DEBUGCWebService {

    /**
    * @description Fetches a student details from UGC for a given student DEB Id. 
    * @author @BK | 05-09-2024 
    * @param String debUniqueID 
    * @param String recordId 
    * @return DEBStudentDetailsWrapper 
    **/
    public static DEBStudentDetailsWrapper getStudentDetails(String debUniqueID, Id recordId) {
        HttpRequest req = new HttpRequest();

        // Setting up the request endpoint and headers
        req.setEndpoint(System.Label.Student_Zone_Base_Url + 'salesforce/m/getStudentDetails/' + debUniqueID);
        req.setMethod('GET');

        // Handling the API response
        return handleUGCStudentDetails(req, 'GetDEBStudentDetails', recordId);
    }

    /**
    * @description 
    * @author @BK | 05-09-2024 
    * @param HttpRequest req 
    * @param String apiName 
    * @param Id recordId 
    * @return DEBStudentDetailsWrapper 
    **/
    private static DEBStudentDetailsWrapper handleUGCStudentDetails(HttpRequest req, String apiName, Id recordId) {
        Http http = new Http();
        HttpResponse resp;
        DEBStudentDetailsWrapper response = new DEBStudentDetailsWrapper();
        String sObjName = APIRequestHandler.getObjName(recordId);

        try {
            resp = http.send(req);
            if (resp.getStatusCode() == 200) {
                response = DEBStudentDetailsWrapper.parse(resp.getBody());
                APIRequestHandler.insertAPIRequest(req.getBody(), resp.getBody(), apiName, true, recordId, sObjName, 'UGCAPI');
                return response;
            } else {
                APIRequestHandler.insertAPIRequest(req.getBody(), resp.getBody(), apiName, false, recordId, sObjName, 'UGCAPI');
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' -- ' + e.getLineNumber());
            APIRequestHandler.insertAPIRequest(req.getBody(), e.getMessage() + ' -- ' + e.getLineNumber(), apiName, false, recordId, sObjName, 'UGCAPI');
        }
        return null;
    }

}