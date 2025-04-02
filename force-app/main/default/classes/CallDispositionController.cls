/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-12-2023
 * @last modified by  : @BK
**/
public without sharing class CallDispositionController {

    @AuraEnabled(Cacheable=true)
    public static List<Task> getTaskDetails(String caseId){
        try {
            if(String.isBlank(caseId)) { 
                return null;
            }
            
            List<Task> lstTask = [Select Id,Purpose__c,Query_Resolved__c,Description,Call_Category__c,Disposition__c,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Case__c,Escalation_Level__c,Subject,Status FROM Task WHERE Subject='Call Scheduling' AND Case__c=:caseId];
            return lstTask;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Task> getChatTrancriptTasks(String chatId){
        try {
            if(String.isBlank(chatId)) { 
                return null;
            }
            List<LiveChatTranscript> lstChat = [SELECT Id, AccountId FROM LiveChatTranscript WHERE Id =:chatId AND AccountId!=null LIMIT 1];
            if(lstChat.size() == 0) {
                return null;
            }
            List<Task> lstTask = getTaskList(lstChat[0].AccountId);
            return lstTask;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<Task> getTaskList(String accountId){
        List<Task> lstTask = null;
        try {
            lstTask = [SELECT Id,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Subject,Status FROM Task WHERE Subject='Call Scheduling' AND WhatId=:accountId];
            System.debug(lstTask);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return lstTask;
    }


    @AuraEnabled(Cacheable=true)
    public static List<PicklistOptions> getTaskFieldOptions(String fieldAPIName) {
        List<PicklistOptions> pickListValuesList = new List<PicklistOptions>();
        String sobjectname = 'Task' ; //object api name
        Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('Task').getDescribe();
        List<Schema.PicklistEntry> entries = objResult.fields.getMap().get(fieldAPIName).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                PicklistOptions options = new PicklistOptions();
                options.label = entry.getLabel();
                options.value = entry.getValue();
                pickListValuesList.add(options);
            }
        }
        return pickListValuesList;
    }

    @AuraEnabled(Cacheable=true)
    public static List<PicklistOptions> getDependentPicklistValues(String fieldAPIName, String fieldValue) {
        Schema.DescribeFieldResult objResult =  Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap().get(fieldAPIName).getDescribe();
        Schema.sObjectField dependToken = objResult.getSObjectField();
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null || String.isBlank(fieldValue)) {
            return new List<PicklistOptions>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<PicklistOptions>> dependentPicklistValues = new Map<String,List<PicklistOptions>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<PicklistOptions>());
                    }
                    PicklistOptions options = new PicklistOptions();
                    options.label = entry.getLabel();
                    options.value = entry.getValue();
                    dependentPicklistValues.get((String) controlValue).add(options);
                }
            }
        }
        System.debug(dependentPicklistValues);
        return dependentPicklistValues.get(fieldValue);
    }


    public class PicklistOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    @AuraEnabled
    public static String updateTaskRecord(Id taskId, String purpose, String queryResolved, String status, String callCategory, String disposition, String description) {
        try {
            Task taskToUpdate = new Task(
                Id = taskId,
                Purpose__c = purpose,
                Query_Resolved__c = queryResolved,
                Status = status,
                Call_Category__c = callCategory,
                Disposition__c = disposition,
                Description = description
            );
            update taskToUpdate;
            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}
    

































      /*  @AuraEnabled
        public static void updateTaskRecord(Map<String, Object> taskFields) {
            try {
                // Prepare the task record
                Task taskRecord = new Task(
                    Id = (Id)taskFields.get('Id'),
                    Subject = (String)taskFields.get('Subject'),
                    Purpose__c = (String)taskFields.get('Purpose__c'),
                    Query_Resolved__c = (String)taskFields.get('Query_Resolved__c'),
                    Status = (String)taskFields.get('Status'),
                    Call_Category__c = (String)taskFields.get('Call_Category__c'),
                    Disposition__c = (String)taskFields.get('Disposition__c'),
                    Description = (String)taskFields.get('Description')
                );
    
                // Update the task record
                update taskRecord;
            } catch (Exception e) {
                throw new AuraHandledException('Error updating task: ' + e.getMessage());
            }
        }*/
    

    

    /* @AuraEnabled
     public static String updateTaskRecord(Id taskId, String subject, String purpose, String queryResolved, String status, String callCategory, String disposition, String description) {
            try {
                // Query the task record
                Task taskRecord = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
                if (taskRecord != null) {
                    // Update the task fields
                    taskRecord.Subject = subject;
                    taskRecord.Purpose__c = purpose;
                    taskRecord.Query_Resolved__c = queryResolved;
                    taskRecord.Status = status;
                    taskRecord.Call_Category__c = callCategory;
                    taskRecord.Disposition__c = disposition;
                    taskRecord.Description = description;
                    
                    // Perform the update
                    update taskRecord;
                    
                    return 'Success';
                } else {
                    return 'Task not found';
                }
            } catch (Exception e) {
                return 'Error: ' + e.getMessage();
            }
        }*/
    
    











    /*@AuraEnabled(Cacheable=true)
    public static List<Task> updateTask(String caseId){
        try {
            if(String.isBlank(caseId)) { 
                return null;
            }
            
            List<Task> lstTask = [Select Id,Purpose__c,Query_Resolved__c,Description,Call_Category__c,Disposition__c,Schedule_Call_Time__c,Call_date__c,Time_Range__c,Case__c,Escalation_Level__c,Subject,Status FROM Task WHERE Subject='Call Scheduling' AND Case__c=:caseId];
            return lstTask;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    /*@AuraEnabled
    
    public static void updateTask(Task updatedTask) {
       try {
           update updatedTask;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
     }
}*/




    // List<PicklistOptions> pickListValuesList = new List<PicklistOptions>();
    // String sobjectname = 'Task' ; //object api name
    // Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('Task').getDescribe();
    // List<Schema.PicklistEntry> entries = objResult.fields.getMap().get('Status').getDescribe().getPickListValues(); 
    // for (Schema.PicklistEntry entry : entries) {
    //     if (entry.isActive()) {
    //         PicklistOptions options = new PicklistOptions();
    //         options.label = entry.getLabel();
    //         options.value = entry.getValue();
    //         pickListValuesList.add(options);
    //     }
    // }
    // System.debug(pickListValuesList);