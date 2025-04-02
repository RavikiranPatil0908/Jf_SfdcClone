/**
 * @File Name          : InterviewScheduleSetZoomLinkBatch.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @vickysahu
 * @Last Modified On   : 05-13-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/6/2019, 6:53:12 PM   @BK     Initial Version
**/
public class InterviewScheduleSetZoomLinkBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
	public Set<String> lstFailedRecords;
    public Map<String,String> mapOfAccountIdVsMeetingId;
    public String token;
    
	public void execute(SchedulableContext sc) {
        InterviewScheduleSetZoomLinkBatch b = new InterviewScheduleSetZoomLinkBatch();
        Database.executebatch(b, 1);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Interview Scheduler Batch started');
        ZoomWebService objService = new ZoomWebService();
        token = objService.getAccessToken();
        String query = 'SELECT id,Interview_Slot__c,InterviewDateTime__c,Zoom_Url__c,HostZoomURL__c,Interview_Meeting_Id__c,Interview_Zoom_Meeting_Id__c FROM Account WHERE Interview_Date__c>=TODAY AND Interview_Slot__c!=null AND Interview_Meeting_Id__c=null AND Zoom_Url__c=null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        if(scope.size() > 0) {
            List<Account> lstAccount = new List<Account>();
            for(Sobject s : scope){
                Account objAccount = (Account)s;
                if(String.isBlank(objAccount.Zoom_Url__c) && String.isBlank(objAccount.Interview_Meeting_Id__c)) {
                    lstAccount.add(objAccount);
                }
            }
            if(lstAccount.size() > 0){
                syncInterviewMeetingList(lstAccount);
            }
        }else{
            System.debug('No records found.');
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        callDeleteZoomMeetingQueue();
        System.debug('Finished');
    }

    /**
    * @description
    * @author @BK | 12/6/2019
    * @param List<Account> lstAccount
    * @return void
    */
    public void syncInterviewMeetingList(List<Account> lstAccount) {
        mapOfAccountIdVsMeetingId = new Map<String,String>();
        List<id> lstSlotId = new List<id>();
        for(Account objAccount : lstAccount) {
            lstSlotId.add(objAccount.Interview_Slot__c);
        }
        Map<Id,Map<DateTime,Id>> mapOfSlotVsMapOfTimeVsAccountId = new Map<Id,Map<DateTime,Id>>();
        Map<String,Interview_Slot__c> mapOfSlotIdVsInterviewSlot = new Map<String,Interview_Slot__c>();

        List<Interview_Slot__c> lstInterviewSlot = [SELECT id,Name,IsActive__c,Interview_Date__c,IntakeAlllowed__c,Per_Interview_minutes__c,Start_time__c,End_time__c,Schedule_in_reverse_order__c,Meeting_UserId_1__c,Meeting_UserId_2__c,
                                                    (SELECT id,InterviewDateTime__c FROM Accounts__r WHERE InterviewDateTime__c != null) FROM Interview_Slot__c WHERE id IN:lstSlotId];
        if(lstInterviewSlot.size() > 0) {
            for(Interview_Slot__c objIS :lstInterviewSlot) {
                System.debug('objIS -->'+objIS);
                Map<DateTime,Id> mapOfDateTimeVsAccountId = new Map<DateTime,Id>();
                if(objIS.Accounts__r.size() > 0) {
                    for(Account objAccount : objIS.Accounts__r) {
                        mapOfDateTimeVsAccountId.put(objAccount.InterviewDateTime__c,objAccount.id);
                    }
                }
                mapOfSlotVsMapOfTimeVsAccountId.put(objIS.id,mapOfDateTimeVsAccountId);
                System.debug('mapOfSlotVsMapOfTimeVsAccountId ---------------------------->');
                System.debug(mapOfSlotVsMapOfTimeVsAccountId);
                
                mapOfSlotIdVsInterviewSlot.put(objIS.id,objIS); 
            }
        }

        if(mapOfSlotVsMapOfTimeVsAccountId != null && !mapOfSlotVsMapOfTimeVsAccountId.isEmpty()) {
            setInterviewDateTime(mapOfSlotVsMapOfTimeVsAccountId, lstAccount, mapOfSlotIdVsInterviewSlot);
        }
    }

    /**
    * @description
    * @author @BK | 12/6/2019
    * @param Map<Id, Map<DateTime, Id>> mapOfSlotVsMapOfTimeVsAccountId
    * @param List<Account> lstAccount
    * @param Map<String, Interview_Slot__c> mapOfSlotIdVsInterviewSlot
    * @return void
    */
    public void setInterviewDateTime(Map<Id,Map<DateTime,Id>> mapOfSlotVsMapOfTimeVsAccountId,List<Account> lstAccount, Map<String,Interview_Slot__c> mapOfSlotIdVsInterviewSlot) {
        for (Account objAccount : lstAccount) {
            Interview_Slot__c interviewSlot = mapOfSlotIdVsInterviewSlot.get(objAccount.Interview_Slot__c);
            System.debug('interviewSlot -->'+interviewSlot);
            Boolean checkForReverseOrder = interviewSlot.Schedule_in_reverse_order__c;
            Integer perCandidateMinute = Integer.valueOf(interviewSlot.Per_Interview_minutes__c);
            System.debug('checkForReverseOrder -->'+checkForReverseOrder);
            Map<DateTime,Id> mapOfNewAddedDateTimeVsAccountId = new Map<DateTime,Id>();
            Map<DateTime,Id> mapOfTimeVsAccountId = null;
            if(mapOfSlotVsMapOfTimeVsAccountId.containsKey(objAccount.Interview_Slot__c) && !mapOfSlotVsMapOfTimeVsAccountId.get(objAccount.Interview_Slot__c).isEmpty()) {
                mapOfTimeVsAccountId = mapOfSlotVsMapOfTimeVsAccountId.get(objAccount.Interview_Slot__c);
                mapOfNewAddedDateTimeVsAccountId = mapOfTimeVsAccountId;
                objAccount.InterviewDateTime__c = setTimeRange(interviewSlot,perCandidateMinute,false,checkForReverseOrder,mapOfTimeVsAccountId);
            } else{
                objAccount.InterviewDateTime__c = setTimeRange(interviewSlot,perCandidateMinute,true,checkForReverseOrder,mapOfTimeVsAccountId);
            }
            
            Integer totalCandidateAllotedToSlot = mapOfNewAddedDateTimeVsAccountId.size();
            // To call zoom Web service for the meeting API.
            objAccount = callZoomWebService(objAccount,totalCandidateAllotedToSlot,interviewSlot);

            // To add the new added interview scheduled into the map.
            if(objAccount.InterviewDateTime__c != null) {   
                System.debug(' ----------------------------- to check before the updated maps ------------------------------------------');
                System.debug(mapOfNewAddedDateTimeVsAccountId);
                System.debug(mapOfNewAddedDateTimeVsAccountId.size());
                mapOfNewAddedDateTimeVsAccountId.put(objAccount.InterviewDateTime__c,objAccount.id);
                mapOfSlotVsMapOfTimeVsAccountId.put(objAccount.Interview_Slot__c,mapOfNewAddedDateTimeVsAccountId);
                System.debug(' ----------------------------- to check after the updated maps ------------------------------------------');
                System.debug(mapOfNewAddedDateTimeVsAccountId);
                System.debug(mapOfNewAddedDateTimeVsAccountId.size());
            }
        }

        if(lstAccount.size() > 0) {
            try {
                lstFailedRecords = new Set<String>();
                Database.SaveResult[] srList = Database.update(lstAccount, false);
                for (Integer i = 0; i < lstAccount.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Account origRecord = lstAccount[i];
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated Account. Account ID: ' + sr.getId());
                    } else {
                        System.debug('sr.getId() -->'+origRecord.id);
                        lstFailedRecords.add(origRecord.id);
                        // Operation failed, so get all errors.                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            } catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
            }
        }
    }

    /**
    * @description
    * @author @BK | 12/6/2019
    * @param Account objAccount
    * @return Account
    */
    public Account callZoomWebService(Account objAccount,Integer totalCandidateAllotedToSlot,Interview_Slot__c interviewSlot) {

        if(objAccount.InterviewDateTime__c != null) {

            // To check for mod of total candidates alloted against the slot to switch between zoom ids
            Integer modCandidateSize = 0;
            if(totalCandidateAllotedToSlot > 0) {
                modCandidateSize = math.mod(totalCandidateAllotedToSlot,2);
            }

            // To check for zoom 
            String zoomId = interviewSlot.Meeting_UserId_1__c;
            if(modCandidateSize > 0 && String.isNotBlank(interviewSlot.Meeting_UserId_2__c)) {
                zoomId = interviewSlot.Meeting_UserId_2__c;
            }

            Datetime gmtDate = objAccount.InterviewDateTime__c;
            String strConvertedDate = gmtDate.format('yyyy-MM-dd');
            String strConvertedTime = gmtDate.format('HH:mm:ss');
            String strDatetime = strConvertedDate+'T'+strConvertedTime;
            System.debug('strDatetime -->'+strDatetime);

            ZoomWebService objZoomWebService = new ZoomWebService();
            
            String topic = 'Interview';
            if(System.Label.Environment == 'Sandbox') {
                topic = 'Sandbox Interview';
            }
            String description = 'Interview Meeting';

            Map<String,String> mapOfJoinURLS = objZoomWebService.createMeeting(strDatetime,topic,description,zoomId,true,10,'none',token);
            if(mapOfJoinURLS.containsKey('Error')) {
                System.debug('Creeting Meeting Failed');
                objAccount.InterviewDateTime__c = null;
            }else{
                objAccount.Zoom_Url__c = mapOfJoinURLS.get('join_url');
                objAccount.HostZoomURL__c = mapOfJoinURLS.get('start_url');
                objAccount.Interview_Meeting_Id__c = mapOfJoinURLS.get('meetingid');
                objAccount.Interview_Zoom_Meeting_Id__c = mapOfJoinURLS.get('ZoomUserId');

                mapOfAccountIdVsMeetingId.put(objAccount.id,objAccount.Interview_Meeting_Id__c);
            }
        }

        return objAccount;
    }

    /**
    * @description
    * @author @BK | 6/7/2019
    * @param Interview_Slot__c interviewSlot
    * @param Integer perCandidateMinute
    * @param Boolean checkFirstRequest
    * @param Boolean checkForReverseOrder
    * @param Map<DateTime, Id> mapOfTimeVsAccountId
    * @return DateTime
    */
    public DateTime setTimeRange(
            Interview_Slot__c interviewSlot,
            Integer perCandidateMinute,
            Boolean checkFirstRequest,
            Boolean checkForReverseOrder,
            Map<DateTime,Id> mapOfTimeVsAccountId
        ) {

        DateTime exactInterviewDateTime = null;
        if(interviewSlot != null) {
            Integer intakeAllowed = Integer.valueOf(interviewSlot.IntakeAlllowed__c); 
            List<DateTime> listOfTimeRange = getListOfTimeRange(interviewSlot.Start_time__c,interviewSlot.End_time__c,interviewSlot.Interview_Date__c,perCandidateMinute,intakeAllowed);
            
            // To Sort the time range on ascending order.
            System.debug('list sorted.');
            listOfTimeRange.sort();

            // To Sort the time range on descending order.
            if(checkForReverseOrder) { 
                List<DateTime> listOfTimeRangeInReverse = new List<DateTime>();
                for(Integer i = listOfTimeRange.size()-1; i>=0;i--) {
                    listOfTimeRangeInReverse.add(listOfTimeRange.get(i));
                }
                listOfTimeRange = listOfTimeRangeInReverse;
                System.debug('listOfTimeRange -->'+listOfTimeRange);
            }
            for (DateTime interviewTime : listOfTimeRange) {
                if(mapOfTimeVsAccountId != null && !mapOfTimeVsAccountId.containsKey(interviewTime)) {
                    exactInterviewDateTime = interviewTime;
                    break;
                }else if(checkFirstRequest){
                    exactInterviewDateTime = listOfTimeRange[0];
                    break;
                }
            }
        }
        return exactInterviewDateTime;
    }

    /**
    * @description
    * @author @BK | 12/6/2019
    * @param Time startVal
    * @param Time endVal
    * @param Date InterviewDate
    * @param Integer perCandidateMinute
    * @param Integer intakeAllowed
    * @return List<DateTime>
    */
    public List<DateTime> getListOfTimeRange(
            Time startVal, 
            Time endVal, 
            Date interviewDate, 
            Integer perCandidateMinute, 
            Integer intakeAllowed
        ) {

        List<DateTime> setOfTimeRange = new List<DateTime>();
        String startTime = String.valueof(startVal);
        String endTime = String.valueof(endVal);
        DateTime d = interviewDate;
        String dateStr =  d.format('yyyy-MM-dd') ;
        String startDateTime = dateStr+' '+startTime;
        String endDateTime = dateStr+' '+endTime;
        DateTime sDateTime = DateTime.Valueof(startDateTime);
        DateTime eDateTime = DateTime.Valueof(endDateTime);
        setOfTimeRange.add(sDateTime);
        for (Integer i = 1; i <= intakeAllowed; i++) {
            Integer perMinute = perCandidateMinute * i;
            DateTime setStartTime = sDateTime.addMinutes(perMinute + 1);
            if(setStartTime < eDateTime) {
                setOfTimeRange.add(setStartTime);
            }
        }
        return setOfTimeRange;
    }

    /**
    * @description
    * @author @BK | 12/8/2019
    * @return void
    */
    public void callDeleteZoomMeetingQueue() {
        // To delete the failed zoom meetings.
        if(lstFailedRecords!= null && lstFailedRecords.size() > 0) {
            List<String> zoomMeetingIds = new List<String>();
            for(String accountId : lstFailedRecords) {
                if(mapOfAccountIdVsMeetingId.containsKey(accountId)) {
                    zoomMeetingIds.add(mapOfAccountIdVsMeetingId.get(accountId));
                }
            }
            if(zoomMeetingIds.size() > 0) {
                DeleteZoomMeetings deleteZoomMeetings = new DeleteZoomMeetings(zoomMeetingIds,token);
                // enqueue the job for processing
                ID jobID = System.enqueueJob(deleteZoomMeetings);
                System.debug('jobID -->'+jobID);
            }
        }
    }
}