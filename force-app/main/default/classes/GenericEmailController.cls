public class GenericEmailController {

    @AuraEnabled(cacheable=true)
    public static List<GenericEmailWrapper.Responsedata> getEmailMessage(String parentId) { 
        List<GenericEmailWrapper.Responsedata> lstOfEmails = new List<GenericEmailWrapper.Responsedata>();
        lstOfEmails = getCaseEmailsEmail(parentId).response;
        System.debug(lstOfEmails);
        return lstOfEmails;
    }
    public static GenericEmailWrapper getCaseEmailsEmail(String parentId) {
        Map<String,String> mapOfRequestParam = new Map<String,String>();
        System.debug('parentId ===>'+parentId);
        Id myId = (Id)parentId;
        mapOfRequestParam.put('parentId',myId);   //001In000005G3Ka
        string jsonString = JSON.serialize(mapOfRequestParam);
        System.debug('jsonString ===>'+jsonString);
        HttpRequest req = new HttpRequest();
        String EndPoint = System.Label.Student_Zone_Base_Url+'salesforce-emailLogs/m/getSfdcEmailLog';
        //'https://studentzone-ngasce.nmims.edu/salesforce-emailLogs/m/getSfdcEmailLog'
        req.setMethod('POST');
        req.setEndpoint(EndPoint);
        req.setHeader('Content-Type','application/json');
        req.setBody(jsonString);
       // req.setTimeout(120000);
      System.debug('req ===>'+req.getBody());
        Http http = new Http();
        HttpResponse resp;
        try {
        
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            System.debug('Email API statusCode = '+statusCode);
   
            if(statusCode == 200){
                GenericEmailWrapper lstWrapper = GenericEmailWrapper.parse(resp.getBody());
                return lstWrapper;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return new GenericEmailWrapper();
    }
}