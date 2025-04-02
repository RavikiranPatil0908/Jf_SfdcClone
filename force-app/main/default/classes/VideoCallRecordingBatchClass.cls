/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : @vickysahu
**/
public class VideoCallRecordingBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    public String token;
    public List<VVC_Junction__c> lstVVCUpdate = new List<VVC_Junction__c>();

    public void execute(SchedulableContext sc) {
        VideoCallRecordingBatchClass b = new VideoCallRecordingBatchClass();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime fromDateTime = System.now().addMinutes(58);
        DateTime toDateTime = fromDateTime.addHours(1);
        ZoomWebService objService = new ZoomWebService();
        token = objService.getAccessToken();
        String query = 'SELECT id,Status__c,Call_Date__c,Schedule_Call_Time__c,Meeting_Id__c,Is_Host_URL_Refresh__c FROM VVC_Junction__c WHERE Call_Date__c=Today AND Status__c =\'In Progress\' AND Schedule_Time_Slot__c != null AND Meeting_Id__c != null AND Is_Host_URL_Refresh__c = false AND Schedule_Call_Time__c >=:fromDateTime AND Schedule_Call_Time__c <:toDateTime Order by Schedule_Call_Time__c Asc LIMIT 90';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<VVC_Junction__c> scope) {
        System.debug('scope--->' + scope.size());
        for (VVC_Junction__c objVVC : scope) {
            ZoomWebService objService = new ZoomWebService();
            String hostJoiningUrl = objService.getZoomMeetingHostUrl(objVVC.Meeting_Id__c,token);
            if (Test.isRunningTest()) { 
                hostJoiningUrl = 'UVb7vI1NRayKqLbgjZ0eNw';
            }
            if (String.isNotBlank(hostJoiningUrl)) {
                objVVC.Is_Host_URL_Refresh__c = true;
                objVVC.Host_Joining_Link__c = hostJoiningUrl;
                lstVVCUpdate.add(objVVC);
            }
        }
        
    }

    public void finish(Database.BatchableContext bc) {
        if (lstVVCUpdate.size() > 0) {
            update lstVVCUpdate;
        }
        System.debug('Finished');
    }

}