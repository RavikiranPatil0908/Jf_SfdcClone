/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-01-2025
 * @last modified by  : @BK
**/
public without sharing class LeadActivityHelper {
    /**
    * @description Maps lead fields to a map object
    * @author @BK | 27-12-2024 
    * @param LeadData objLead 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> mapLeadFields(LeadData leadData, String activity) { 
        Map<String,Object> mapOfLeadVsDetail = new Map<String,Object>{
            'asset_id' => '87fc65f73a4a4ca69ba466114caa00c1',
            'activity_name' => activity,
            'timestamp' => System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
            'identity' => leadData.leadId,
            'activity_source' => 'web'
        };
        
        Map<String,Object> mapOfFieldVsLead = new Map<String,Object>();
        mapOfFieldVsLead.put('lead_id',leadData.leadId);
        mapOfFieldVsLead.put('lead_status',leadData.status);
        mapOfFieldVsLead.put('lead_description',leadData.leadDescription);
        mapOfFieldVsLead.put('choose_a_program',leadData.chooseProgram);
        mapOfFieldVsLead.put('program_name',leadData.programName);
        mapOfFieldVsLead.put('program_type',leadData.programType);
        mapOfFieldVsLead.put('lead_created_date',leadData.leadCreatedDate);
        mapOfFieldVsLead.put('batch_name',leadData.batchName);
        mapOfFieldVsLead.put('last_update_status_date',leadData.lastUpdateStatusDate);
        mapOfFieldVsLead.put('description_last_updated_date',leadData.descriptionLastUpdatedDate);

        mapOfLeadVsDetail.put('activity_params', mapOfFieldVsLead);

        return mapOfLeadVsDetail;
    }

    /**
    * @description Calls an external API with the provided data
    * @param List<Map<String,Object>> lstData 
    **/
    public static void callQueryAPI(List<Map<String,Object>> lstData) {
        String postData = JSON.serialize(lstData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api2.netcoresmartech.com/v1/activity/upload');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer 8c6a823f040cd09421f2a785db8445a6');
        req.setBody(postData);
        System.debug('request body-->'+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode =' + statusCode);
        String result = res.getBody();
        System.debug('result ==>'+result);
        Map<String,Object> mapOfResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.debug(mapOfResponse);
    }

    public class LeadData {
        public String leadId;
        public String status;
        public String leadDescription;
        public String chooseProgram;
        public String programName;
        public String programType;
        public Date leadCreatedDate;
        public String batchName;
        public Date lastUpdateStatusDate;
        public Date descriptionLastUpdatedDate;
    }
}