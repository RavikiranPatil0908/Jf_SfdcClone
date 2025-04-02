/**
 * @File Name          : ZoomWebService.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 08-24-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    13/5/2019, 3:54:19 PM   @BK     Initial Version
**/
public without sharing class ZoomWebService {

    public String getAccessToken() {
        String clientId = System.Label.Zoom_ClientId;
        String clientSecret = System.Label.Zoom_Client_Secret;
        
        // Make a callout to get the access token using OAuth 2.0
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://zoom.us/oauth/token?grant_type=account_credentials&account_id=' + System.Label.Zoom_AccountId);
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret)));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('token===>' + responseMap.get('access_token'));
            return (String) responseMap.get('access_token');
        } else {
            System.debug('Error getting access token: ' + res.getBody());
            return null;
        }
    
    }

    /**
    * @description
    * @author @BK | 15/5/2019
    * @param String DateTimeSt
    * @param String topic
    * @param String agenda
    * @return Map<String, String>
    */
    public Map<String,String> createMeeting(String DateTimeSt, String topic , String agenda, String zoomId, Boolean joinBeforeHost, Integer duration, String autoRecording,String token) {

        Map<String,String> mapOfResponsehostUrl = new Map<String,String>();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint('https://api.zoom.us/v2/users/'+zoomId+'/meetings');
        req.setMethod('POST');
        req.setHeader('authorization','bearer' + ' ' + token);// set Authorization in All web service 
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept','application/json, application/xml');

        String jsonBody = createMeetingJson(DateTimeSt,topic,agenda,joinBeforeHost,duration,autoRecording);
          
        req.setBody(jsonBody);
        System.debug('jsonBody---'+jsonBody);
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            if(statusCode == 201){
                String result = resp.getBody();
                System.debug('zoom response-->'+result);
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
                system.debug('mapOfResponseParameters--->'+mapOfResponseParameters);
                if(!mapOfResponseParameters.isEmpty()){
                    if(mapOfResponseParameters.containsKey('host_id') )
                    {
                        mapOfResponsehostUrl.put('start_url',String.valueof(mapOfResponseParameters.get('start_url')));
                        mapOfResponsehostUrl.put('join_url',String.valueof(mapOfResponseParameters.get('join_url')));
                        mapOfResponsehostUrl.put('meetingid',String.valueof(mapOfResponseParameters.get('id')));
                        mapOfResponsehostUrl.put('ZoomUserId',String.valueOf(mapOfResponseParameters.get('host_email')));
                        mapOfResponsehostUrl.put('start_time',String.valueOf(mapOfResponseParameters.get('start_time')));
                        mapOfResponsehostUrl.put('duration',String.valueOf(mapOfResponseParameters.get('duration')));
                        mapOfResponsehostUrl.put('uuid',String.valueOf(mapOfResponseParameters.get('uuid')));
                    }
                }
                return mapOfResponsehostUrl;
            }else{
                mapOfResponsehostUrl.put('Error',String.valueof(resp.getBody()));
            }
        } catch (Exception e) {
            mapOfResponsehostUrl.put('Error',String.valueof(e.getMessage()));
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
            return mapOfResponsehostUrl;
        }
        return mapOfResponsehostUrl;
    }

    /**
    * @description
    * @author @BK | 15/5/2019
    * @param String DateTimeSt
    * @param String topic
    * @param String agenda
    * @return String
    */
    public String createMeetingJson(String DateTimeSt, String topic, String agenda, Boolean joinBeforeHost, Integer duration, String autoRecording) {      
        
        Map<String,Object> MapToSerializeParam2 = new Map<String,Object>{
            'host_video' => true,
            'participant_video' => true,
            'in_meeting' => true,
            'join_before_host' => joinBeforeHost,
            'approval_type' => 2,
            'registration_type' => 2,
            'audio' => 'voip',
            'enforce_login' => false
        };
        if (autoRecording == 'cloud') {
            MapToSerializeParam2.put('auto_recording',autoRecording);
        }
        
        Map<string, object> mapToSerialize = new Map<string, object>();
        mapToSerialize.put('topic', topic);
        mapToSerialize.put('type', 2);
        mapToSerialize.put('start_time', DateTimeSt);
        mapToSerialize.put('duration', duration);
        mapToSerialize.put('timezone', 'Asia/Kolkata');
        mapToSerialize.put('agenda', agenda);
        mapToSerialize.put('settings',MapToSerializeParam2);
        
        String jsonstring = SYSTEM.JSON.serialize(mapToSerialize);
        return  jsonstring;
    }

    /**
    * @description To Delete the zoom api
    * @author @BK | 17/6/2019
    * @param String MeetingId
    * @return Boolean
    */
    public Boolean deleteMeeting(String MeetingId,String token) {
        if(String.isNotBlank(MeetingId)) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint('https://api.zoom.us/v2/meetings/'+MeetingId);
            req.setMethod('DELETE');
            req.setHeader('authorization','bearer' + ' ' + token);// set Authorization in All web service 
            req.setHeader('content-type', 'application/json');
            req.setHeader('Accept','application/json, application/xml');

            try {
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                System.debug('statusCode -->'+statusCode);
                String result = resp.getBody();
                // Integer statusCode = 204;
                if(statusCode == 204) { 
                    System.debug('result -->'+result);
                    return true;
                }else{
                    System.debug('result -->'+result);
                }
            }catch (Exception e) {
                System.debug(e);
            }
        }
        return false;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param minDate 
    * @param maxDate 
    * @param pageSize 
    * @param zoomId 
    * @param token 
    * @return ScheduledMettingsWrapper 
    **/
    public ScheduledMettingsWrapper getListOfScheduledMeetings(String minDate,String maxDate,Integer pageSize,String zoomId,String token) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            
            req.setEndpoint('https://api.zoom.us/v2/users/'+zoomId+'/meetings?type=upcoming&page_size=300&to='+maxDate+'&from='+mindate+'&timezone=Asia/Kolkata');
            req.setMethod('GET');
            req.setHeader('authorization','bearer' + ' ' + token);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Accept','application/json, application/xml');

            ScheduledMettingsWrapper mapOfResponseParameters = new ScheduledMettingsWrapper();
            try {
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                if(statusCode == 200){
                    String result = resp.getBody();
                    System.debug('Sheduled meeting zoom response-->'+result);
                    mapOfResponseParameters = ScheduledMettingsWrapper.parse(result);
                    system.debug('mapOfResponseParameters--->'+mapOfResponseParameters);
                }else{
                    System.debug('Error===>' + String.valueof(resp.getBody()));
                }
            } catch (Exception e) {
                System.debug('Callout Exception Authentication_API :'+e.getMessage());
                System.debug('line error===>' + e.getLineNumber());
            }
        return mapOfResponseParameters;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param meetingId 
    * @param token 
    * @return ZoomRecordingWrapper 
    **/
    public ZoomRecordingWrapper getMeetingRecording(String meetingId,String token) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId+'/recordings');
        req.setMethod('GET');
        req.setHeader('authorization','bearer' + ' ' + token);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept','application/json, application/xml');

        ZoomRecordingWrapper mapOfResponseParameters = new ZoomRecordingWrapper();
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            if(statusCode == 200){
                String result = resp.getBody();
                mapOfResponseParameters = ZoomRecordingWrapper.parse(result);
                system.debug('mapOfResponseParameters--->'+mapOfResponseParameters);
            }else{
                System.debug('Error===>' + String.valueof(resp.getBody()));
            }
        } catch (Exception e) {
            System.debug('Callout Exception Authentication_API :'+e.getMessage());
            System.debug('line error===>' + e.getLineNumber());
        }
        return mapOfResponseParameters;
    }

    public String getZoomMeetingHostUrl(String meetingId, String token) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();

        req.setEndpoint('https://api.zoom.us/v2/meetings/'+meetingId);
        req.setMethod('GET');
        req.setHeader('authorization','bearer' + ' ' + token);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept','application/json, application/xml');
        String startUrl = '';
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            if (statusCode == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                System.debug('startUrl===>' + responseMap.get('start_url'));
                startUrl = (String) responseMap.get('start_url');
            }
            
        } catch (Exception e) {
            System.debug('error--->' +  e.getMessage() + ' ' + e.getLineNumber());
        }
        return startUrl;
    }

}