/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : @vickysahu
**/
public with sharing class VVCRecordingUpdateBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    
    public void execute(SchedulableContext sc) {
        VVCRecordingUpdateBatchClass b = new VVCRecordingUpdateBatchClass();
        Database.executebatch(b, 90);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date callDate = System.today().addDays(-5);
        Datetime currentTime = System.now().addHours(-3);
        String query = 'SELECT id,Status__c,Meeting_Id__c,Is_Host_URL_Refresh__c FROM VVC_Junction__c WHERE Status__c =\'Completed\' AND Call_Date__c >= :callDate AND Schedule_Call_Time__c<=:currentTime AND Schedule_Time_Slot__c != null AND Meeting_Id__c != null AND (Zoom_User_Id__c = null OR Call_Transcript_Url__c = null) Order by Schedule_Call_Time__c Asc LIMIT 90';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<VVC_Junction__c> scope) {
        System.debug('scope--->' + scope.size());
        for (VVC_Junction__c objVVC : scope) {
            try {
                // Create an HTTP request
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setEndpoint('https://studentzone-ngasce.nmims.edu/acads/m/zoomUploadVideoSFDCByMeetingKey');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
    
                // Create request body
                Map<String, String> requestBody = new Map<String, String>();
                requestBody.put('meetingKey', objVVC.Meeting_Id__c);
                String body = JSON.serialize(requestBody);
                req.setBody(body);
    
                // Send the request
                Http http = new Http();
                if ((System.label.Environment == 'Production') && !Test.isRunningTest()) {
                    res = http.send(req);
                }
    
                // Process the response
                if (!Test.isRunningTest() && res.getStatusCode() == 200) {
                    System.debug('Success: ' + res.getBody());
                } else {
                    System.debug('Error: ' + res.getStatusCode() + ' ' + res.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
        }
        
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Finished');
    }
}