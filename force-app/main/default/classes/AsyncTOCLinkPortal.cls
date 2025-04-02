public class AsyncTOCLinkPortal {
    
    public static HttpCalloutMock mock = null;
    
    @InvocableMethod(label='Call portal api on Current download link update' description='Current download link update')
    public static void callSaveEmailToPortalAPI(List<FlowInputs> request) {
        if (!System.isFuture()) {
            callApiObj(request[0].recordId);
        }
    }

    public static void callApiObj(String recordId) {
        
        List <AsyncTOCLink__c> TOCdata =[select TOC__r.Id__c,Async_Shoot_Post_Production__r.Current_Download_Link__c from AsyncTOCLink__c where Async_Shoot_Post_Production__r.Id =: recordId ];
        Set<Integer> data = new Set<Integer>();
        for(AsyncTOCLink__c  Idvalue: TOCdata)
        {
            if(String.isNotBlank(Idvalue.TOC__r.Id__c) && Idvalue.Async_Shoot_Post_Production__r.Current_Download_Link__c != null  && Idvalue.Async_Shoot_Post_Production__r.Current_Download_Link__c != '') {
                data.add(integer.valueof(Idvalue.TOC__r.Id__c));
            }
        }
       
        if(data != null && !data.isEmpty())
        {
            sendTOCIdToPortal(data);
        }
    }

    @future (callout=true)
    Public static void sendTOCIdToPortal(Set<Integer> data)
    { //System.Label.Student_Portal +
    try {
       String baseURL =  System.Label.Student_Zone_Base_Url +'acads/m/admin/uploadVideosContentFromSFDC';
       HttpRequest req = new HttpRequest();
       req.setEndpoint(baseURL);
       req.setMethod('POST');
       req.setHeader('Content-Type', 'application/json');
       Map<String, Object> requestBodyMap = new Map<String, Object>();
       requestBodyMap.put('TOCIds', data);

       String requestBody = JSON.serialize(requestBodyMap);
       req.setBody(requestBody);
       System.debug('AsyncTOCLinkTriggerHandler requestBody :: '+requestBody);
       
       Http http = new Http();
       HttpResponse response = new HttpResponse();
       if(system.label.Environment != 'Sandbox'){
           response = http.send(req);
       }
       if (Test.isRunningTest() || response.getStatusCode() == 200) {
           // API call was successful
           System.debug('response.getBody() :: '+response.getBody());
           insertAPIRequest(requestBody, response.getBody(), 'CallAsyncTOCLinktoPortal', true, null, '', 'PortalAPI');
       } else {
           // API call failed
           insertAPIRequest(requestBody, response.getBody(), 'CallAsyncTOCLinktoPortal', false, null, '', 'PortalAPI');
           System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
       }
    } catch (Exception error) {
        System.debug('sendTOCIdToPortal API Request Error');
        System.debug(error.getMessage());
    }
    }
    public static void insertAPIRequest(String req, String res, String apiName, Boolean isSuccess, Id recordId, String sObjName, String typeOfRequest) {
       try {
           API_Request__c apiReq = new API_Request__c();
           apiReq.API_Name__c = apiName;
           apiReq.Request__c = req;
           apiReq.Response__c = res;
           apiReq.Success__c = isSuccess;
           apiReq.Type_of_Request__c = typeOfRequest;
           apiReq.Lead__c = sObjName == 'Lead' ? recordId : null;
           apiReq.Account__c = sObjName == 'Account' ? recordId : null;
           insert apiReq;
       } catch (Exception error) {
           System.debug('Insert API Request Error');
           System.debug(error.getMessage());
       }
   }
   public class FlowInputs {
    @InvocableVariable(required=true)
     public String recordId;
   }
}