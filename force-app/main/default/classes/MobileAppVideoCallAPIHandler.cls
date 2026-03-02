/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 02--03--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   10-11-2025     @Ravi    Initial Version
**/
public without sharing class MobileAppVideoCallAPIHandler {
    
    public String recid ='';
    public String reqURL ='';

    /**
    * @description 
    * @author @Ravi | 12--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getCallDetails(String url, String jsonString) {
        Map<String,Object> mapOfRequestParameters =(Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId'};
        recId = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            VideoCallPageController controller = new VideoCallPageController();
            controller.setObjectId(recId);
            controller.getVideoCallTimeRange();
            controller.getVideoCallTime();
            VVCDetailsWrapper VVCDetails =fectchCallDetails(recId,controller);
            return buildResponse('Success','Success',VVCDetails);
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error: ' + e.getMessage()+'Line : '+e.getLineNumber(), url, false, recid);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 14--11--2025 
    * @return VVCDetailsWrapper 
    **/
    public VVCDetailsWrapper fectchCallDetails(String recordId, VideoCallPageController controller ){

        VVCDetailsWrapper detailsWrapper = new VVCDetailsWrapper();
        detailsWrapper.VideoCallDate = convertSelectOptions(controller.getVideoCallDate());
        detailsWrapper.videoCallTime = convertSelectOptions(controller.videoCallTime);
        detailsWrapper.videoCallTimeRange = convertSelectOptions(controller.videoCallTimeRange);
        detailsWrapper.strSecToShow =controller.strSecToShow;
        detailsWrapper.message = controller.message;
        // detailsWrapper.mapOfDateVsTimeRange = controller.mapOfDateVsTimeRange;
        detailsWrapper.wrapper = controller.wrapper;
        detailsWrapper.formStatus = controller.formStatus;
        detailsWrapper.callDate = controller.callDate;
        detailsWrapper.callTime = controller.callTime;
        detailsWrapper.sectionHeader =controller.sectionHeader;
        detailsWrapper.meetingUrl = controller.meetingUrl;
        detailsWrapper.showReScheduleButton = controller.showReScheduleButton;
        detailsWrapper.newTime = controller.newTime;
        detailsWrapper.lstVVCTranscript = controller.lstVVCTranscript;
        detailsWrapper.vvcJunctionId =controller.vvcJunctionId;
        detailsWrapper.isVideoVerificationEnabled =controller.isVideoVerificationEnabled;
        detailsWrapper.isSlotAvailable = controller.isSlotAvailable;
        detailsWrapper.isDebVerified= controller.isDebVerified;
        detailsWrapper.validAccStatus = controller.validAccStatus;
        detailsWrapper.isDownPaymentMade = controller.isDownPaymentMade;
        detailsWrapper.showBookingForm = controller.showBookingForm;
        detailsWrapper.lstQuestion = controller.lstQuestion;
        detailsWrapper.isVVCNotExpired = controller.isVVCNotExpired;
        detailsWrapper.allowVVCAfterLastDate = controller.allowVVCAfterLastDate;
        // detailsWrapper.mapOfIdAndQuestion = controller.mapOfIdAndQuestion;

        return detailsWrapper;
    }

    /**
    * @description 
    * @author @Ravi | 12--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getSlotDetails(String url, String jsonString) {
        Map<String,Object> mapOfRequestParameters =(Map<String,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId'};
        VVCDetailsWrapper detailsWrapper = new VVCDetailsWrapper();
        recId = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            
            VideoCallPageController controller = new VideoCallPageController();
            controller.setObjectId(recId);
            if (mapOfRequestParameters.containsKey('CallDate') && String.isNotBlank(String.valueOf(mapOfRequestParameters.get('CallDate'))) && mapOfRequestParameters.containsKey('CallRange') && String.isBlank(String.valueOf(mapOfRequestParameters.get('CallRange')))) {
                controller.wrapper.meetingDate = String.valueOf(mapOfRequestParameters.get('CallDate'));
                controller.getVideoCallTimeRange();
                detailsWrapper.videoCallTimeRange = convertSelectOptions(controller.videoCallTimeRange);
                return buildResponse('Success','Success', detailsWrapper);

            } else if(mapOfRequestParameters.containsKey('CallDate') && String.isNotBlank(String.valueOf(mapOfRequestParameters.get('CallDate'))) && mapOfRequestParameters.containsKey('CallRange') && String.isNotBlank(String.valueOf(mapOfRequestParameters.get('CallRange')))) {

                controller.wrapper.meetingDate = String.valueOf(mapOfRequestParameters.get('CallDate'));
                controller.wrapper.meetingTimeRange = String.valueOf(mapOfRequestParameters.get('CallRange'));
                controller.getVideoCallTime();
                detailsWrapper.videoCallTime = convertSelectOptions(controller.videoCallTime);
                return buildResponse('Success','Success', detailsWrapper);
            }
            detailsWrapper.VideoCallDate= convertSelectOptions(controller.getVideoCallDate());
            return buildResponse('Success','Success', detailsWrapper);
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error : ' + e.getMessage()+'Line: '+ e.getLineNumber(), url, false, recid);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob saveSlotDetails(String url, String jsonString) {
        Map<String, Object> mapOfRequestParameters = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId', 'wrapper'};
        try {
            if (!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            Map<String, Object> slotDetailsMap = (Map<String, Object>) mapOfRequestParameters.get('wrapper');
            if (slotDetailsMap == null || slotDetailsMap.isEmpty()) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
           // validation for wrapper’s required fields
            Set<String> wrapperRequiredParams = new Set<String>{
                'meetingDate', 'meetingTimeRange', 'meetingTime', 'phoneNumber', 'firstName', 'lastName', 'email'
            };
            for (String param : wrapperRequiredParams) {
                if (!slotDetailsMap.containsKey(param) || String.isBlank(String.valueOf(slotDetailsMap.get(param)))) {
                    return  buildResponse('Error','Internal error occured. Missing required data', null);
                }
            }
            // Initialize controller
            VideoCallPageController controller = new VideoCallPageController();
            controller.setObjectId(String.valueOf(mapOfRequestParameters.get('recordId')));
            
            // Populate wrapper data
            controller.wrapper = (VideoCallPageController.ObjWrapper)JSON.deserialize(JSON.serialize(slotDetailsMap), VideoCallPageController.ObjWrapper.class);
            controller.isReschedule = (Boolean)slotDetailsMap.get('isReschedule');
            // Call controller logic
            Map<String, Object> resultMap = controller.saveVVCDetailFromAdmApp();
            return buildResponse( String.valueOf(resultMap.get('status')), String.valueOf(resultMap.get('message')), resultMap.get('data') );
    
        } catch (Exception e) {
            insertAPIRequest2(reqURL, 'Error: ' + e.getMessage() + ' Line ==>' + e.getLineNumber(),url,false, String.valueOf(mapOfRequestParameters.get('recordId')));
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }
    
    /**
    * @description 
    * @author @Ravi | 14--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob rescheduleCallDetails(String url, String jsonString) {
        Map<String, Object> mapOfRequestParameters = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParameters = new Set<String>{'recordId'};
        recId = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if (!validateRequest(setRequiredParameters, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
        
            VideoCallPageController controller = new VideoCallPageController();
            controller.setObjectId(recId);
            controller.checkReschedule();
            controller.getVideoCallTimeRange();
            controller.getVideoCallTime();
            VVCDetailsWrapper VVCDetails = fectchCallDetails(recId,controller);

            return buildResponse('Success','Success',VVCDetails);
        } catch (Exception e) {
            insertAPIRequest2(reqURL, 'Error :' + e.getMessage() + ' Line ==>' + e.getLineNumber(),url,false, String.valueOf(mapOfRequestParameters.get('recordId')));
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }
    

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param List<System.SelectOption> options 
    * @return List<Map<String, String>> 
    **/
    private List<Map<String, String>> convertSelectOptions(List<System.SelectOption> options) {
        if (options == null) return null;
        List<Map<String, String>> result = new List<Map<String, String>>();
        for (System.SelectOption opt : options) {
            result.add(new Map<String, String>{
                'label' => opt.getLabel(),
                'value' => opt.getValue()
            });
        }
        return result;
    }

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param String status 
    * @param String message 
    * @param Object data 
    * @return Blob 
    **/
    private Blob buildResponse(String status, String message, Object data) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', status);
        response.put('message', message);
        response.put('data', data);
        System.debug('==>'+response);
        return Blob.valueOf(JSON.serialize(response));
    }

    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param String req 
    * @param String res 
    * @param String apiName 
    * @param Boolean isSuccess 
    * @param Id recordId 
    **/
    private static void insertAPIRequest2(String req, String res, String apiName, Boolean isSuccess, Id recordId) {
        if(!Test.isRunningTest()) {
            String objectName=APIRequestHandler.getObjName(recordId);
            APIRequestHandler.insertAPIRequest(req, res, apiName, isSuccess, recordId, objectName, 'MobileApp');
        } 
    }
    
    /**
    * @description 
    * @author @Ravi | 13--11--2025 
    * @param Set<String> requiredParams 
    * @param Map<String Object> requestParams 
    * @return Boolean 
    **/
    private Boolean validateRequest(Set<String> requiredParams, Map<String,Object> requestParams) {
        for (String param : requiredParams) {
            if (!requestParams.containsKey(param) ||  requestParams.get(param) == null || String.valueOf(requestParams.get(param)).trim().length() == 0) {
                return false;
            }
        }
        return true;
    }

    public class VVCDetailsWrapper {
        public List<Map<String, String>> VideoCallDate;
        public List<Map<String, String>> videoCallTime;
        public List<Map<String, String>> videoCallTimeRange;
        public String strSecToShow;
        public String message;
        public Map<String, List<Map<String, String>>> mapOfDateVsTimeRange;
        public VideoCallPageController.ObjWrapper wrapper;
        public String formStatus;
        public String callDate;
        public String callTime;
        public String sectionHeader;
        public String meetingUrl;
        public Boolean showReScheduleButton;
        public Datetime newTime;
        public List<VVC_Junction__c> lstVVCTranscript;
        public String vvcJunctionId;
        public Boolean isVideoVerificationEnabled;
        public Boolean isSlotAvailable;
        public Boolean isDebVerified;
        public Boolean validAccStatus;
        public Boolean isDownPaymentMade;
        public Boolean showBookingForm;
        public List<VVC_Question__c> lstQuestion;
        public Boolean isVVCNotExpired;
        public Boolean allowVVCAfterLastDate;
    //    public Map<Id,List<VVC_Question__c>> mapOfIdAndQuestion;

        public VVCDetailsWrapper() {
            isSlotAvailable = false;
            mapOfDateVsTimeRange = new Map<String, List<Map<String, String>>>();
            lstQuestion = new List<VVC_Question__c>();
            strSecToShow = '';
            message = '';
            formStatus = '';
            callDate = '';
            callTime = '';
            sectionHeader = '';
            meetingUrl = '';
            showReScheduleButton = false;
            newTime = null;
            lstVVCTranscript = new List<VVC_Junction__c>();
            vvcJunctionId = '';
            isVideoVerificationEnabled = false;
            isDebVerified = false;
            validAccStatus = false;
            showBookingForm = false;
            isDownPaymentMade = false;
            isVVCNotExpired = false;
            allowVVCAfterLastDate = false;
        }
    }
}
