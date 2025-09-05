/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 25--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   11--08--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/api/FetchStudentDashboardDetails/*')
global with sharing class MobileAppDashboardPageAPI {
    
    @HttpPost
    global static ResponseWrapper fetchDashboardDetails() {
        RestRequest req = RestContext.request;
        ResponseWrapper res = new ResponseWrapper();
        try {
            String body = req.requestBody.toString();
            RequestWrapper input = (RequestWrapper)JSON.deserialize(body, RequestWrapper.class);
            if(String.isBlank(input.recordId)){
                res.status = 'Error';
                res.message ='Record ID is required';
                res.recordDetails = null;
                return res;
            }
            if(String.isBlank(input.objectType) || (input.objectType != 'Account' && input.objectType != 'Lead')) {
                res.status = 'Error';
                res.message = 'Valid objectType (Account/Lead) is required';
                res.recordDetails = null;
                return res;
            }

            DashboardPageController controller = new DashboardPageController();
            controller.setObjectType(input.objectType);
            controller.setObjectId(input.recordId);
            
            res.status = 'Success';
            res.message = 'Data fetched successfully';
            res.recordDetails = controller.objRecord;
            return res;
        } catch (Exception e) {
            res.status = 'Error';
            res.message = e.getMessage()+'-'+e.getLineNumber();
            res.recordDetails = null;
            return res;
        }  
    }

    global class RequestWrapper {
        public String recordId;
        public String objectType; // 'Lead' or 'Account'
    }

    global class ResponseWrapper {
        public String status;
        public String message;
        public DashboardPageController.RecordDetails recordDetails;
    }

}