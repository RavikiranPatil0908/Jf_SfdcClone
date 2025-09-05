/**
 * @description       : REST API for fetching Document Page details
 * @author            : @Ravi
 * @last modified on  : 28--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   28-08-2025   @Ravi    Initial Version
 **/

 @RestResource(urlMapping = '/api/documentupload-service/*')
 global without sharing class MobileAppDocumentPageAPI {

      
     /** GET API to fetch document details
     * @description 
     * @author @Ravi | 28--08--2025 
     **/
     @HttpGet
     global static void handleDocuments() {
         RestResponse resp = RestContext.response;
         RestRequest req   = RestContext.request;
         resp.addHeader('Content-Type', 'application/json;charset=UTF-8');
 
         try {
             String recordId = req.params.get('recordId');
             if (String.isBlank(recordId)) {
                 sendResponse('Error', 'Record Id is required.', null);
                 return;
             }

             // Identify Object
             String objectType;
             if (recordId.startsWith('00Q')) {
                 objectType = 'Lead';
             } else if (recordId.startsWith('001')) {
                 objectType = 'Account';
             } else {
                 sendResponse('Error', 'Valid objectType (Account/Lead) is required.', null);
                 return;
             }
 
             // Initialize Controller
             DocumentPageController controller = new DocumentPageController();
             controller.setObjectType(objectType);
             controller.setObjectId(recordId);
 
             // Response Wrapper
             DocumentResponseWrapper response = new DocumentResponseWrapper();
             response.recordId                  = recordId;
             response.lstDocuments              = controller.lstDocuments;
             response.isRecordExists             = controller.isRecordExists;
             response.isProvisinalWithHold       = controller.isProvisinalWithHold;
             response.showOldDocument            = controller.showOldDocument;
             response.countOfUploadedDocuments   = controller.countOfUploadedDocuments;
             response.hideSubmitButton           = controller.hideSubmitButton;
 
             sendResponse('Success', 'Documents fetched successfully.', response);
 
         } catch (Exception ex) {
             System.debug('Error while fetching documents: ' + ex.getMessage());
             sendResponse('Error', 'Error while fetching documents: ' + ex.getMessage(), null);
         }
     }

     /**
     * @description   Helper method to send JSON response
     * @author @Ravi | 28--08--2025 
     * @param String status 
     * @param String message 
     * @param Object data 
     **/
     private static void sendResponse(String status, String message, Object data) {
         RestContext.response.responseBody = 
             Blob.valueOf(JSON.serialize(new BaseResponse(status, message, data)));
     }

     // Standard Response Wrapper
     global class BaseResponse {
         public String status;
         public String message;
         public Object data;
         
         public BaseResponse(String status, String message, Object data) {
             this.status  = status;
             this.message = message;
             this.data    = data;
         }
     }
 
     // Response Wrapper
     global class DocumentResponseWrapper {
         public String recordId;
         public List<DocumentPageController.DocumentWrapper> lstDocuments;
         public Boolean isRecordExists;
         public Boolean isProvisinalWithHold;
         public Boolean showOldDocument;
         public Integer countOfUploadedDocuments;
         public Boolean hideSubmitButton;
 
         public DocumentResponseWrapper() {
             recordId                 = '';
             lstDocuments             = new List<DocumentPageController.DocumentWrapper>();
             isRecordExists           = false;
             isProvisinalWithHold     = false;
             showOldDocument          = false;
             hideSubmitButton         = false;
             countOfUploadedDocuments = 0;
         }
     }
 
     // Request Wrapper 
     global class DocumentRequestWrapper {
         public String recordId; // Account or Lead Id
         public String debId;  
     }   
 }
 