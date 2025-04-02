/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : @vickysahu
**/
public without sharing class VideoVerificationTaskController {
    public VideoVerificationTaskController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<VVC_Junction__c>  findVideoCallByStatus(String [] callStatus, Date fromDate, Date callDate){
        List<VVC_Junction__c> lstfinal  = new List<VVC_Junction__c>();
        // try{
        //System.debug('status ::>>>>> '+callStatus+' fromDate ::>>>> '+fromDate+' callDate ::>>>> '+callDate+'  rowLimit :::'+rowLimit+'  rowOffSet ::: '+rowOffSet);
        // if(fromDate == null)
        // {
        //     fromDate = Date.today();
        // }
        // if(callDate == null)
        // {
        //     callDate = Date.today().addDays(1);
        // }
        
        if(callStatus.size() == 0)
        {
            callStatus.add('In Progress');
        }
        System.debug('status ::>>>>> '+callStatus+' fromDate ::>>>> '+fromDate+' callDate.date() ::>>>> '+callDate);
        List<VVC_Junction__c> lst =  [SELECT Id,status__c,Call_Date__c,Schedule_Call_Time__c,Call_Recording_Url__c, Student_Name__c,
        Account__r.nm_AccountName__c,Account__r.nm_RegistrationNumber__c ,Account__r.is_Video_Call_Verified__c ,Account__c  FROM VVC_Junction__c where
        status__c In: callStatus and Call_Date__c >=: fromDate and Call_Date__c <=: callDate and Account__r.nm_AccountName__c != null];
        //return lst;
        System.debug('No of recored count lst.size() ::: '+lst.size());


        Integer  queryLimits = Limits.getLimitQueries()-1;
        Integer actualCount = lst.size();
        Integer count = 200;
        if(actualCount/count > queryLimits)
        {
           throw new AuraHandledException('error');
        }

        System.debug('queryLimits ::: '+queryLimits+ ' actualCount :: '+actualCount+' count :: '+count);
        List<Integer> queryListCount = new List<Integer>();
        while(actualCount > 0){
            if(actualCount > count)
            {
                queryListCount.add(count);
                actualCount -= count;
            }
            else {
                queryListCount.add(actualCount);
                actualCount -= count;
            }
        }
        System.debug('queryListCount ::: '+queryListCount.size()+'  queryListCount ::'+queryListCount.toString());
        
        Integer j = 0; 
        Integer k = 0;
        for (Integer sObj : queryListCount) {
            List<Id> newrecordlst = new List<Id>();
            List<VVC_Junction__c> newlst = new List<VVC_Junction__c>();
            j  += sObj;
            for (Integer i = k; i< j; i++) {
                newrecordlst.add(lst.get(i).Account__c);
                newlst.add(lst.get(i));
            }
            lstfinal.addAll(checkForRecordAssess(newrecordlst,newlst));
            System.debug('newrecordlst ::: '+newrecordlst.size()+'  newlst ::'+newlst.size()+ ' lstfinal ::'+lstfinal.size());
            k = j;        
        }
    return lstfinal;
    }


    public static List<VVC_Junction__c> checkForRecordAssess(List<Id> recordIds, List<VVC_Junction__c> allResults) {
        List<VVC_Junction__c> accessibleRecords = new List<VVC_Junction__c>();
        if(recordIds.isEmpty()) {
            return accessibleRecords;
        }

        if (!recordIds.isEmpty()) {
            List<UserRecordAccess> accessRecords = [
                SELECT RecordId 
                FROM UserRecordAccess 
                WHERE UserId = :UserInfo.getUserId() 
                AND HasReadAccess = true 
                AND RecordId IN :recordIds
            ];            
            List<Id> accessibleRecordIds = new List<Id>();
            for (UserRecordAccess accessRecord : accessRecords) {
                accessibleRecordIds.add(accessRecord.RecordId);
            }
    
            for (VVC_Junction__c resultWrapper : allResults) {
                if (accessibleRecordIds.contains(resultWrapper.Account__c)) {
                    accessibleRecords.add(resultWrapper);
                }
            }
        }
        System.debug('Found Accessible Records:::::::::::: ' + accessibleRecords);
        return accessibleRecords;
    }    
}