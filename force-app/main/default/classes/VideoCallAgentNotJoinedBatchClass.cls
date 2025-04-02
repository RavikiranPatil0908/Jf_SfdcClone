/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : @vickysahu
**/
public class VideoCallAgentNotJoinedBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    //List Of Task to Update
    List<Task> lstTaskUpdate = new List<Task>();

    public void execute(SchedulableContext sc) {
        VideoCallAgentNotJoinedBatchClass b = new VideoCallAgentNotJoinedBatchClass();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('VideoCallAgentNotJoinedBatchClass Batch Class Started');
        DateTime currentDateTime = System.now().addMinutes(-30);
        String query = 'SELECT id,Subject,Schedule_Time_Slot__c,Call_date__c,Status,Schedule_Call_Time__c,CreatedDate FROM Task WHERE Subject=\'Video Call Scheduling\' AND Call_date__c=Today AND Status =\'In Progress\' AND Schedule_Time_Slot__c != null AND Schedule_Call_Time__c <=:currentDateTime ORDER BY Created_Date_Time__c ASC LIMIT 200';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Task> scope) {
       for (Task objTask : scope) {
            objTask.Status = 'Not Connected';
            objTask.Agent_Joined_Status__c = 'Not Joined';
            lstTaskUpdate.add(objTask);
       }
    }

    public void finish(Database.BatchableContext bc) {
       try {
            if (lstTaskUpdate.size() > 0 ) {
                update lstTaskUpdate;
            }
       } catch (Exception e) {
            System.debug('Error--->' + e.getMessage());
            System.debug('Error Line No--->' + e.getLineNumber());
       }
    } 

}