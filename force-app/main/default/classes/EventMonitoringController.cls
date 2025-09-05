/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 06-06-2025
 * @last modified by  : @Shailesh
**/
public  class EventMonitoringController {

    @AuraEnabled
    public static void insertEventMonitoring(String leadId,String userId,String objectType,String event){
        EventMonitoring__c  eventmonitoring = new EventMonitoring__c ();

        if(String.isNotBlank(objectType)){
            if(objectType == 'Lead'){
                eventmonitoring.Lead__c = leadId;
            }
            else if(objectType == 'Account'){
                eventmonitoring.Account__c = leadId;
            }
        }
        eventmonitoring.Event__c = event;
        eventmonitoring.User__c = userId;
        Insert eventmonitoring;
    }

}