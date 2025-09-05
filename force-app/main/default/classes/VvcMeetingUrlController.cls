/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 18-07-2025
 * @last modified by  : @Shailesh
**/
public without sharing class VvcMeetingUrlController {

    @AuraEnabled(cacheable=false)
    public static String checkForRefreshUrl(String recordId){
        try {
            
        DateTime thresholdtime = System.now().addHours(-1); 
         System.debug('thresholdtime: ' + thresholdtime+'recordId :'+recordId);
        List<VVC_Junction__c> records = [
        SELECT Id, Status__c, HostUrlRefreshdatetime__c, Meeting_Id__c, Host_Joining_Link__c
        FROM VVC_Junction__c
        WHERE (HostUrlRefreshdatetime__c = null OR HostUrlRefreshdatetime__c < :thresholdtime)
            AND Status__c = 'In Progress' and Id =: recordId
        ];

        if(records.size() > 0){
            ZoomWebService zws = new ZoomWebService();
            String tokenvalue = '';
            tokenvalue = zws.getAccessToken();
            String startUrl = zws.getZoomMeetingHostUrl(records[0].Meeting_Id__c, tokenvalue);
            if(!String.isEmpty(startUrl)){
                System.debug('startUrl: ' + startUrl);
                records[0].HostUrlRefreshdatetime__c = System.now();
                records[0].Host_Joining_Link__c = startUrl;
                update records[0];
                return 'true';
            }
            return 'false';
        }else{
            return 'false';
        }
         } catch (Exception e) {

            System.debug(e.getMessage());
            throw new AuraHandledException('error occurred' + e.getMessage());
            
        }

    }
}