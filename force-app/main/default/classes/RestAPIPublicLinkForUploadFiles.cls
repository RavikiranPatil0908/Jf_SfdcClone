/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : @vickysahu
**/
@RestResource(urlMapping='/UploadFilesFromPortal/*')
global without sharing class RestAPIPublicLinkForUploadFiles {
    
    @HttpPost
    global static List<MessageWrapper> doPost() {
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        List<Case> lstCase = new List<Case>();
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        
        try {
            RestRequest req = RestContext.request;
            requestString = req.requestBody.toString();
            System.debug('requestString ' + requestString);
            
            RequestWrapper wrapper = parse(requestString);
            apiReq.Request__c = requestString;
            
            if (wrapper.fileContent == null) { 
                return returnMessage(apiReq, requestString, '501', 'File is required.');
            }
            if (wrapper.fileName == null) { 
                return returnMessage(apiReq, requestString, '501', 'File name is required.');
            }
            if (String.isBlank(wrapper.caseId)) {
                return returnMessage(apiReq, requestString, '501', 'caseId is required.');
            }

            System.debug('wrapper--->' + JSON.serialize(wrapper));
            System.debug('caseId--->' + wrapper.caseId);
            System.debug('file--->' + wrapper.fileContent);

            lstCase = [SELECT Id, CaseNumber FROM Case WHERE Id =: wrapper.caseId];
            // if (lstCase.size() == 0) {
            //     return returnMessage(apiReq, requestString, '404', 'No cases found with this caseId.');
            // }
            // Decode Base64 to Blob
            Blob fileBlob = EncodingUtil.base64Decode(wrapper.fileContent);
            System.debug('Decoded Blob Size: ' + fileBlob.size());
            List<Map<String,Object>> lstFiles = new List<Map<String,Object>>();
            Map<String,Object> mapOfFileParameter = new Map<String,Object>();
            mapOfFileParameter.put('Title', wrapper.fileName);
            mapOfFileParameter.put('PathOnClient', wrapper.fileName);
            mapOfFileParameter.put('VersionData', fileBlob);
            lstFiles.add(mapOfFileParameter);
            System.debug('filename---->' + wrapper.fileName);
            System.debug('content---->' + wrapper.fileContent);
            Boolean status = MyCasesController.uploadFiles(lstFiles,wrapper.caseId);
            System.debug('status--->' + status);
            if(!status) {
                return returnMessage(apiReq, requestString, '500', 'Error while uploading files.');
            }
            return returnMessage(apiReq, requestString, '200', 'Public links created for uploaded files.');
            
        } catch (Exception e) {
            return returnMessage(apiReq, requestString, '500', 'Error: ' + e.getMessage());
        }
    }

    public static List<MessageWrapper> returnMessage(API_Request__c apiReq, String requestString, String code, String msg) {
        if(apiReq == null) {
            apiReq = new API_Request__c();
        }
        MessageWrapper messageWrapper = new MessageWrapper(code, msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        //String jsonResponse = JSON.serialize(messageWrapper);
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c = 'FileUpload';
        apiReq.API_Name__c = 'RestAPIPublicLinkForUploadFiles';
        apiReq.Success__c = code == '200' ? true : false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    public static void apiRequestsInsertion(API_Request__c apiRequest) {
        if(apiRequest != null) {
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

    // Parse method moved to top level class
    public static RequestWrapper parse(String json) {
        return (RequestWrapper) System.JSON.deserialize(json, RequestWrapper.class);
    }

    global class MessageWrapper {
        public String responseCode;
        public String message;        
        
        global MessageWrapper(String responseCode, String message) {
            this.responseCode = responseCode;
            this.message = message;
        }
        
        public override String toString() {
            return JSON.serialize(this);
        }
    }

    public class RequestWrapper {
        public String fileContent;
        public String fileName;
        public String caseId;
        public RequestWrapper() {
            fileContent = null;
            fileName = '';
            caseId = '';
        }
    }
}