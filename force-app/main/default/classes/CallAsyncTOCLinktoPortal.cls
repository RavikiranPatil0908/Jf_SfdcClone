public class CallAsyncTOCLinktoPortal {
    public CallAsyncTOCLinktoPortal() {

    }

    public static HttpCalloutMock mock = null;
    
    @InvocableMethod(label='Save Ids to Portal Using API call' description='Save Ids to Portal Using API call' category='EmailMessage')
    public static void callSaveIdsToPortalAPI(List<FlowInputs> request) {
        if (!System.isFuture()) {
            CallWebService(request[0].recordIds);
        }
    }

    @future(callout=true)
    public static void callWebService(List<String> recordIds) {
    System.debug('CallAsyncTOCLinktoPortal :: '+recordIds);
    //System.debug('CallAsyncTOCLinktoPortalsize :: '+recordIds.size());
    String baseURL = System.Label.Student_Portal + 'acads/m/admin/uploadVideosContentFromSFDC';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(baseURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            Map<String, Object> requestBodyMap = new Map<String, Object>();
            requestBodyMap.put('TOCIds', recordIds);
    
            String requestBody = JSON.serialize(requestBodyMap);
            req.setBody(requestBody);
            Http http = new Http();
            //HttpResponse response = http.send(req);

            // if (response.getStatusCode() == 200) {
            //     // API call was successful
            //     String responseBody = response.getBody(); 
            //     System.debug('response.getBody() :: '+response.getBody());
            //     //APIRequestHandler.insertAPIRequest(requestBody, response.getBody(), 'SendEmailToPortal', true, recordId, 'Account', 'PortalAPI');
            // } else {
            //     // API call failed
            //     //APIRequestHandler.insertAPIRequest(requestBody, response.getBody(), 'SendEmailToPortal', false, recordId, 'Account', 'PortalAPI');
            //     System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
            // }

            }

    public class FlowInputs {
        @InvocableVariable(required=true)
         public List<String> recordIds;

    }
}