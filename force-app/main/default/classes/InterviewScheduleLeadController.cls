/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 05-13-2024
 * @last modified by  : @vickysahu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   03-13-2021   shubhranshu   Initial Version
**/
public with sharing class InterviewScheduleLeadController {
    public Lead objLead {get; set;}
    public String LeadID {get;set;}
    public String programType {get;set;}
    public String slotType {get;set;}
    public list<SelectOption> getInterviewTime{get;set;}
    public List<SelectOption> getInterviewDate{get;set;}
    public Date today{get;set;}
    public Boolean isActiveCheck {get;set;}
    public Map<String,String> MapOfInterviewDateTimeVsSlotId {get;set;}
    public Map<String,Integer> MapOfSlotVsLeadlistSize {get;set;}
    public set<id> Slotfull {get;set;}
    public string message { get;set; }
    public string strSecToShow { get; set; }

    public string successmessage { get;set; }
    public string strToShow { get; set; }

    public InterviewScheduleLeadController() {
        objLead = new Lead();
        // LeadID = '';
        message = null;
        strSecToShow = '';
        successmessage = null;
        strToShow = '';
        MapOfInterviewDateTimeVsSlotId = new Map<String,String>();
        MapOfSlotVsLeadlistSize = new Map<String,Integer>();
        Slotfull = new Set<id>();  
        LeadID = ApexPages.currentPage().getParameters().get('id');
        // programType = ApexPages.currentPage().getParameters().get('program');
        programType = 'M.Sc. (AI)';
        slotType = 'Counselling';
        Integer addDaysforToday= Integer.ValueOf(System.Label.AddDays);
        today = Date.today().addDays(addDaysforToday);
        isActiveCheck = false;
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('type')) && ApexPages.currentPage().getParameters().get('type') == 'admin') {
            today = Date.today().addDays(-1);
            isActiveCheck = true;
        }
        if(LeadID !=null && LeadID !=''){
            QueryLeadData();
            SlotFullCheck();
        }
    }

    public void ErrorMessage(String msg,String secToShow){
        message = msg;
        strSecToShow = secToShow; 
    }

    public void QueryLeadData (){
        String leadQuery = getQueryAllFieldSql('Lead',' id=: LeadID','nm_InformationCenter__r.Name');
        List<Lead> lstLead = DataBase.query(leadQuery);
        System.debug('lstLead-->'+lstLead);
        if(lstLead.size() > 0){
            objLead = lstLead[0];
            objLead.id = null;
        }
    }

    public void SlotFullCheck () {
        double  slotIntakecapacity;
        String leadslotalloted = getQueryAllFieldSql('Lead','Interview_Date__c >= today and Time_Range__c != null',null);
        List<Lead> lstLdSlotAlloted = DataBase.query(leadslotalloted);
        System.debug('lstLdSlotAlloted-->'+lstLdSlotAlloted);
       
        Set<id> setofInterview = new Set<id>();
        if(lstLdSlotAlloted.size() > 0) {
            for(Lead obj :lstLdSlotAlloted) {
                setofInterview.add(obj.Interview_Slot__c);
            }
            System.debug('setofInterview-->'+setofInterview);
            if(setofInterview.size() > 0) {
                AggregateResult[] groupedResults = [SELECT count(id)lstsize, Interview_Slot__c FROM Lead WHERE Interview_Slot__c IN:setofInterview GROUP BY Interview_Slot__c];
                for (AggregateResult ar : groupedResults)  {
                    Integer lstsize = (Integer)ar.get('lstsize');
                    Id SlotId = (Id)ar.get('Interview_Slot__c');
                    MapOfSlotVsLeadlistSize.put(SlotId,lstsize);
                    System.debug('Expert Counselling Slot ID' + ar.get('Interview_Slot__c'));
                    System.debug('Total candidate size' + ar.get('lstsize'));
                }

                String interviewSlotQuery = getQueryAllFieldSql('Interview_Slot__c','Id IN:setofInterview',null);
                List<Interview_Slot__c> lstinterviewSlot = DataBase.query(interviewSlotQuery);
                if(lstinterviewSlot.size() > 0) {
                    for(Interview_Slot__c Slot : lstinterviewSlot) {
                        System.debug('Slot-->'+Slot);
                        slotIntakecapacity = Slot.IntakeAlllowed__c;
                        id slotId = Slot.id;
                        if(MapOfSlotVsLeadlistSize.containsKey(slotId) && MapOfSlotVsLeadlistSize.get(slotId) >= slotIntakecapacity) {
                            Slotfull.add(slotId);
                        }
                    }
                }
            }
        }
    }

    public void SaveDetail(){
        SlotFullCheck();
        Interview_Slot__c interviewSlot = new Interview_Slot__c();
        try{

            if(objLead.Interview_Date_Time__c != null) {
                successmessage = 'Expert Counselling Slot already defined!';
                strToShow = 'SUCCESS';
            }
            String SlotId;
            objLead.id = LeadID;
            String MapKey = objLead.Time_Range__c + '-' + String.valueOf(objLead.Interview_Date__c);
            System.debug('MapOfInterviewDateTimeVsSlotId -->'+MapOfInterviewDateTimeVsSlotId.keySet());
            System.debug('MapKey -->'+MapKey);
            if(MapOfInterviewDateTimeVsSlotId.containsKey(MapKey) && ((Slotfull.size() > 0 && !Slotfull.contains(MapOfInterviewDateTimeVsSlotId.get(MapKey))) || Slotfull.isEmpty()) ) {
                SlotId = MapOfInterviewDateTimeVsSlotId.get(MapKey);
                System.debug('SlotId -->'+SlotId);
                objLead.Interview_Slot__c = SlotId;
                System.debug('MapOfSlotVsLeadlistSize -->'+MapOfSlotVsLeadlistSize.keySet());
                String interviewSlotQuery = getQueryAllFieldSql('Interview_Slot__c','Id =:SlotId',null);
                List<Interview_Slot__c> lstinterviewSlot = DataBase.query(interviewSlotQuery);
                interviewSlot = lstinterviewSlot[0];

                // To set the current interview date time.
                String startTime = String.valueof(interviewSlot.Start_time__c);
                DateTime d = interviewSlot.Interview_Date__c;
                String dateStr =  d.format('yyyy-MM-dd') ;
                String startDateTime = dateStr+' '+startTime;
                DateTime SDateTime = DateTime.Valueof(startDateTime);

                if(MapOfSlotVsLeadlistSize.containsKey(SlotId)) {
                    Decimal Candidatesize = MapOfSlotVsLeadlistSize.get(SlotId);
                    Decimal totalMinutes = getMinutesBetweenStartVsEndTime(interviewSlot.Start_time__c,interviewSlot.End_time__c);
                    System.debug('totalMinutes -->'+totalMinutes);
                    Decimal PerCandidateMinute = interviewSlot.Per_Interview_minutes__c;
                    Decimal TotalInteviewMinutesAlloted = PerCandidateMinute * Candidatesize;
                    Decimal ToAlotSize = totalMinutes - TotalInteviewMinutesAlloted;
                    if(ToAlotSize > 0) {
                        System.debug('ToAlotSize -->'+ToAlotSize);
                        
                        System.debug('SDateTime -->'+SDateTime);
                        //To set the start date time for the interview.
                        objLead.Interview_Date_Time__c = SDateTime;
                        if(TotalInteviewMinutesAlloted > 0){
                            //To update the start date time for the interview if candidates already taken the slot.
                            Integer addMinutes = Integer.ValueOf(TotalInteviewMinutesAlloted)+1;
                            objLead.Interview_Date_Time__c = SDateTime.addMinutes(addMinutes);
                            System.debug('addMinutes -->'+addMinutes);
                            System.debug('SDateTime.addMinutes(addMinutes) ->'+SDateTime.addMinutes(addMinutes));
                        }
                    }
                }else {
                    objLead.Interview_Date_Time__c = SDateTime;
                }
            }else{
                System.debug('Expert Counselling Slot id is missing');
                successmessage = 'Slot is already full, try again!';
                strToShow = 'ERROR';
                return;
            }
            
            Datetime GMTDate = objLead.Interview_Date_Time__c;
            String strConvertedDate = GMTDate.format('yyyy-MM-dd');
            String strConvertedTime = GMTDate.format('HH:mm:ss');
            String strDatetime = strConvertedDate+'T'+strConvertedTime;
            System.debug('strDatetime -->'+strDatetime);
            String zoomId = interviewSlot.Meeting_UserId_1__c;
            if(String.isNotBlank(interviewSlot.Meeting_UserId_2__c)) {
                zoomId = interviewSlot.Meeting_UserId_2__c;
            }
            // To call zoom Web service for the meeting API.
            ZoomWebService objZoomWebService = new ZoomWebService();
            String Topic = 'Interview';
            String Description = 'Interview Meeting';
            
            String token = objZoomWebService.getAccessToken();
            Map<String,String> MapOfJoinURLS = objZoomWebService.createMeeting(strDatetime,Topic,Description,zoomId,true,10,'none',token);
            if(MapOfJoinURLS.containsKey('Error')) {
                System.debug('Creeting Meeting Failed');
                successmessage = 'Internal Error Occured, Kindly contact!';
                strToShow = 'ERROR';
                return;
            }else{
                objLead.Zoom_Url__c = MapOfJoinURLS.get('join_url');
                objLead.Host_Zoom_URL__c = MapOfJoinURLS.get('start_url');
                objLead.Interview_Meeting_Id__c = MapOfJoinURLS.get('meetingid');
                // check duplicacy
                objLead.Interview_Meeting_Unique_check__c = objLead.Interview_Date_Time__c +' '+objLead.Time_Range__c+' '+objLead.Interview_Slot__c;
            }
            Interview_Slot__c objSlot = new Interview_Slot__c(id=SlotId);
            objSlot.Lead_Assigned__c =  objSlot.Lead_Assigned__c > 0 ? objSlot.Lead_Assigned__c + 1 : 1; 
            try{
                update objLead;
                update objSlot;
                successmessage = 'Expert Counselling Slot updated successfully!';
                strToShow = 'SUCCESS';
            }catch(DMLException e){
                System.debug('error '+e.getMessage());
                successmessage = 'Internal Error Occured, Kindly contact!';
                strToShow = 'ERROR';
            }
            
        } catch (Exception e) {
            System.debug('System error '+e);
            successmessage = 'Internal Error Occured, Kindly contact!';
            strToShow = 'ERROR';
        }
    }

    public Boolean checkForSlotAvalialbility(String SlotId) {
        try {
            Integer lstsize = 0;
            AggregateResult[] groupedResults = [SELECT count(id)lstsize FROM Lead WHERE Interview_Slot__c=:SlotId];
            for (AggregateResult ar : groupedResults)  {
                lstsize = (Integer)ar.get('lstsize');
                System.debug('AccountSize -->'+lstsize);
            }
            // Interview_Slot__c objSlot = new Interview_Slot__c(id = SlotId);
            // objSlot.Account_Assigned__c = lstsize + 1; 
            // System.debug('objSlot.Account_Assigned__c -->'+objSlot.Account_Assigned__c);
            // update objSlot;
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
        return true;
    }

    public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedField){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedField !=null && relatedField !=''){
            fieldNames.add(relatedField);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        return query;
    }

    public List<SelectOption> getInterviewTime(){
        List<SelectOption> lstVenueTimeOption = new List<SelectOption>();
        lstVenueTimeOption.add(new SelectOption('', 'Select Time'));
        Date InterviewDate = objLead.Interview_Date__c;
        System.debug('objLead.Interview_Date__c---------->'+objLead.Interview_Date__c);
        System.debug('InterviewDate---------->'+InterviewDate);
        String conditionString = 'Interview_Date__c =:InterviewDate and id !=:Slotfull and IsActive__c = TRUE';
        if(String.isNotBlank(programType) && String.isNotBlank(slotType)) {
            conditionString += ' and Program_Type__c=:programType and Slot_Type__c=:slotType';
        }
        String querytime = getQueryAllFieldSql('Interview_Slot__c',conditionString,null);
        if(isActiveCheck) {
            querytime = getQueryAllFieldSql('Interview_Slot__c','Interview_Date__c =:InterviewDate and id !=:Slotfull' ,null);
        }
        List<Interview_Slot__c> lstVenueSlot = DataBase.query(querytime);
        System.debug('lstVenueSlot Time --'+lstVenueSlot);
        if(lstVenueSlot.size() > 0){
            for(Interview_Slot__c objInterviewSlot : lstVenueSlot){
                
                String timeRange = getFormattedTime(objInterviewSlot.Start_time__c) +' - '+ getFormattedTime(objInterviewSlot.end_time__c);
                String MapKey = timeRange+'-'+String.valueof(objInterviewSlot.Interview_Date__c);
                MapOfInterviewDateTimeVsSlotId.put(MapKey,objInterviewSlot.id);
                lstVenueTimeOption.add(new SelectOption(timeRange, timeRange));
            }
        }
        return lstVenueTimeOption;
    }

    public List<SelectOption> getInterviewDate(){
        List<SelectOption> lstVenueDateOption = new List<SelectOption>();
        lstVenueDateOption.add(new SelectOption('', 'Select Date'));
        Set<Date> dateRange = new Set<Date>();
        String conditionString = 'Interview_Date__c>:today and id!=:Slotfull and IsActive__c = TRUE';
        if(String.isNotBlank(programType) && String.isNotBlank(slotType)) {
            conditionString += ' and Program_Type__c=:programType and Slot_Type__c=:slotType';
        }
        String querydate = getQueryAllFieldSql('Interview_Slot__c',conditionString,null);
        if(isActiveCheck) {
            querydate = getQueryAllFieldSql('Interview_Slot__c','Interview_Date__c>:today and id!=:Slotfull',null);
        }
        List<Interview_Slot__c> lstVenueSlot = DataBase.query(querydate);
        System.debug('lstVenueSlot--'+lstVenueSlot);
        if(lstVenueSlot.size() > 0){
            for(Interview_Slot__c objInterviewSlot : lstVenueSlot) {
                dateRange.add(objInterviewSlot.Interview_Date__c);
            }
            for(Date venueDate: dateRange)
            {
                lstVenueDateOption.add(new SelectOption(String.valueOf(venueDate.format()) , getFormattedDate(venueDate) ));
            }
        }
        return lstVenueDateOption;
    }

    public String getFormattedTime(Time timeVal) {
        String timeValue = String.valueof(timeVal);
        DateTime d = Date.Today() ;
        String dateStr =  d.format('yyyy-MM-dd') ;
        String inpputString = dateStr+' '+timeValue;
        DateTime resultDateTime = DateTime.ValueofGmt(inpputString);
        return String.valueOf(resultDateTime.formatGMT('h:mm a'));
    }

    public Decimal getMinutesBetweenStartVsEndTime(Time startVal, Time endVal) {
        String startTime = String.valueof(startVal);
        String endTime = String.valueof(endVal);
        DateTime d = Date.Today() ;
        String dateStr =  d.format('yyyy-MM-dd') ;
        String startDateTime = dateStr+' '+startTime;
        String endDateTime = dateStr+' '+endTime;
        DateTime SDateTime = DateTime.ValueofGmt(startDateTime);
        DateTime EDateTime = DateTime.ValueofGmt(endDateTime);
        Long dt1Long = SDateTime.getTime();
        Long dt2Long = EDateTime.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        return minutes;
    }

    public String getFormattedDate(Date dateValue) {
        Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
        return String.valueOf(dt.format('dd MMMM yyyy'));
    }
}