/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 09-03-2024
 * @last modified by  : @Ravi
**/
public class DEBUniqueIdentifierWebService {
    private static final String PRODUCTION_URL = 'http://45.124.184.101/deb.ugc.ac.in';
    private static final String SANDBOX_URL = '';

    /**
    * @description 
    * @author @vickysahu | 08-31-2024 
    * @param debUniqueId 
    * @param apiKey 
    * @param leadId 
    * @return DEBStudentDetailsWrapper 
    **/
    public static DEBStudentDetailsWrapper getStudentDetails(String debUniqueId, String apiKey, String leadId) {
        System.debug('call webservice.getStudentDetails :::');
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        String baseUrl = getBaseUrl();
        String endPoint = baseUrl + '/api/DebUniqueID/GetStudentDetails?DEBUniqueID=' + debUniqueId;
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('APIKey',apiKey);
        String result = '';

        DEBStudentDetailsWrapper response = new DEBStudentDetailsWrapper();
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            result = resp.getBody();
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            if(statusCode == 200 && resultMap.containsKey('status') && resultMap.get('status') == 'success') {
                response = DEBStudentDetailsWrapper.parse(result);
                system.debug('response--->'+response);
                insertAPIRequest(endPoint,result,'StudentDatailsFromDEB',true,leadId);
                return response;
            }else{
                System.debug('Error===>' + String.valueof(resp.getBody()));
                insertAPIRequest(endPoint,result,'StudentDatailsFromDEB',false,leadId);
            }
        } catch (Exception e) {
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
            System.debug('line error===>' + e.getLineNumber());
            insertAPIRequest(endPoint,result + ' -- ' + e.getLineNumber() + ' --- '+e.getMessage(),'StudentDatailsFromDEB',false,leadId);
        }
        return null;
    }

    public static Boolean getAdmissionDetails(String abcId,String debUniqueId,String admissionDetails,String universityName,String courseName,String admissionDate,String apiKey,String leadId) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        String baseUrl = getBaseUrl();
        String endPoint = baseUrl + '/api/DebUniqueID/GetAdmissionDetails?ABCID=' + abcId + '&DEBuniqueID=' + debUniqueId + '&AdmissionDetails=' + admissionDetails + '&UniversityName=' + universityName + '&CourseName=' + courseName + '&AdmissionDate=' + admissionDate;
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('APIKey',apiKey);
        String result = '';

        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            result = resp.getBody();
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            if(statusCode == 200 && resultMap.containsKey('status') && resultMap.get('status') == 'Process Success') {
                insertAPIRequest(endPoint,result,'AdmissionDetailsFromDEB',true,leadId);
                return true;
            }else{
                System.debug('Error===>' + String.valueof(resp.getBody()));
                insertAPIRequest(endPoint,result,'AdmissionDetailsFromDEB',false,leadId);
            }
        } catch (Exception e) {
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
            System.debug('line error===>' + e.getLineNumber());
            insertAPIRequest(endPoint,result + ' -- ' + e.getLineNumber() + ' --- '+e.getMessage(),'AdmissionDetailsFromDEB',false,leadId);
        }
        return false;

    }

    public static void insertAPIRequest(String req, String res, String apiName ,Boolean isSuccess, String leadId) {
        API_Request__c apiReq = new API_Request__c();
        apiReq.API_Name__c = apiName;
        apiReq.Request__c = req;
        //apiReq.Type_of_Request__c = typeOfRequest;
        apiReq.Response__c = res;
        apiReq.Success__c = isSuccess;
        apiReq.Lead__c = leadId;
        insert apiReq;
    }

    public static String getBaseUrl() {
        String url = PRODUCTION_URL;
        if (system.label.Environment == 'Sandbox') {
            url = SANDBOX_URL;
        }
        return url;
    }

}