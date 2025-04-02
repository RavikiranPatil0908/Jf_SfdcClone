/**
 * @File Name          : InterviewScheduleController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 12-07-2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    13/5/2019, 4:44:08 PM   @BK     Initial Version
**/
public without sharing class InterviewScheduleController{
    public Account objAccount {get; set;}
    public Account objAccountclone {get; set;}
    public String AccountID {get;set;}
    public String ipAddress {get;set;}
    public String programType {get;set;}
    public set<id> Slotfull {get;set;}
    public list<SelectOption> getInterviewTime{get;set;}
    public List<SelectOption> getInterviewDate{get;set;}
    public string strSecToShow { get; set; }
    public string message { get;set; }   
    public Map<String,String> MapOfInterviewDateTimeVsSlotId {get;set;}
    public list<Interview_Slot__c> lstVenueDateOption{get;set;}
    public Date today{get;set;}
    public Boolean isActiveCheck {get;set;}
    public Map<String,Integer> MapOfSlotVsAccountlistSize {get;set;}
    //Interview Schedule.
    public String DisallowedWeekDays {get;set;}
    public String interviewStartDate {get;set;}
    public String interviewEndDate {get;set;}
    
    public InterviewScheduleController(){
        objAccount = new Account();
        objAccountclone = new Account ();
        AccountID = null;
        objAccount.id = null;
        strSecToShow = '';
        message = null;  
        Slotfull = new Set<id>();  
        MapOfInterviewDateTimeVsSlotId = new Map<String,String>();
        lstVenueDateOption = new list<Interview_Slot__c>();
        AccountID = ApexPages.currentPage().getParameters().get('id');
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        // programType = ApexPages.currentPage().getParameters().get('program');
        programType = '';
        interviewStartDate = '';
        interviewEndDate = '';
        MapOfSlotVsAccountlistSize = new Map<String,Integer>();
        Integer addDaysforToday= Integer.ValueOf(System.Label.AddDays);
        today = Date.today().addDays(addDaysforToday);
        isActiveCheck = false;
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('type')) && ApexPages.currentPage().getParameters().get('type') == 'admin') {
            today = Date.today().addDays(-1);
            isActiveCheck = true;
        }
        
        if(AccountID !=null && AccountID !=''){
            QueryAccountData();
            SlotFullCheck();
        }
    }

    public void ErrorMessage(String msg,String secToShow){
        message = msg;
        strSecToShow = secToShow; 
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
    
    public void QueryAccountData (){
        String accountQuery = getQueryAllFieldSql('Account',' id=: AccountID',null);
        List<Account> lstAccount = DataBase.query(accountQuery);
        System.debug('lstAccount-->'+lstAccount);
        if(lstAccount.size() > 0){
            objAccount = lstAccount[0];
            objAccount.id = null;
            objAccountclone = lstAccount[0];            
            objAccountclone.id = null;
            programType = objAccount.Program_Type__c;
        }
    }
      
    public void SlotFullCheck () {
        double  slotIntakecapacity;
        String accountslotalloted = getQueryAllFieldSql('Account','Interview_Date__c > today and Time_Range__c != null',null);
        List<Account> lstAccSlotAlloted = DataBase.query(accountslotalloted);
        System.debug('lstAccSlotAlloted-->'+lstAccSlotAlloted);
       
        Set<id> setofInterview = new Set<id>();
        if(lstAccSlotAlloted.size() > 0) {
            for(Account obcc :lstAccSlotAlloted) {
                setofInterview.add(obcc.Interview_Slot__c);
            }
            System.debug('setofInterview-->'+setofInterview);
            if(setofInterview.size() > 0) {
                AggregateResult[] groupedResults = [SELECT count(id)lstsize, Interview_Slot__c FROM Account WHERE Interview_Slot__c IN:setofInterview GROUP BY Interview_Slot__c];
                for (AggregateResult ar : groupedResults)  {
                    Integer lstsize = (Integer)ar.get('lstsize');
                    Id SlotId = (Id)ar.get('Interview_Slot__c');
                    MapOfSlotVsAccountlistSize.put(SlotId,lstsize);
                    System.debug('Interview Slot ID' + ar.get('Interview_Slot__c'));
                    System.debug('Total candidate size' + ar.get('lstsize'));
                }

                String interviewSlotQuery = getQueryAllFieldSql('Interview_Slot__c','Id IN:setofInterview',null);
                List<Interview_Slot__c> lstinterviewSlot = DataBase.query(interviewSlotQuery);
                if(lstinterviewSlot.size() > 0) {
                    for(Interview_Slot__c Slot : lstinterviewSlot) {
                        System.debug('Slot-->'+Slot);
                        slotIntakecapacity = Slot.IntakeAlllowed__c;
                        id slotId = Slot.id;
                        if(MapOfSlotVsAccountlistSize.containsKey(slotId) && MapOfSlotVsAccountlistSize.get(slotId) >= slotIntakecapacity) {
                            Slotfull.add(slotId);
                        }
                    }
                }
            }
        }
    }
      
    public List<SelectOption> getInterviewTime(){
        List<SelectOption> lstVenueTimeOption = new List<SelectOption>();
        lstVenueTimeOption.add(new SelectOption('', 'Select Time'));
        Date InterviewDate = objAccount.Interview_Date__c;
        System.debug('objAccount.Interview_Date__c---------->'+objAccount.Interview_Date__c);
        System.debug('InterviewDate---------->'+InterviewDate);
        String conditionString = 'Interview_Date__c =:InterviewDate and id !=:Slotfull and IsActive__c = TRUE and Slot_Type__c !=\'Counselling\'';
        if(String.isNotBlank(programType)) {
            conditionString += ' and Program_Type__c=:programType';
        }
        String querytime = getQueryAllFieldSql('Interview_Slot__c',conditionString,null);
        if(isActiveCheck) {
            querytime = getQueryAllFieldSql('Interview_Slot__c','Interview_Date__c =:InterviewDate and id !=:Slotfull and Slot_Type__c !=\'Counselling\'' ,null);
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
        String conditionString = 'Interview_Date__c>:today and id!=:Slotfull and IsActive__c = TRUE and Slot_Type__c !=\'Counselling\'';
        if(String.isNotBlank(programType)) {
            conditionString += ' and Program_Type__c=:programType';
        }
        String querydate = getQueryAllFieldSql('Interview_Slot__c',conditionString,null);
        if(isActiveCheck) {
            querydate = getQueryAllFieldSql('Interview_Slot__c','Interview_Date__c>:today and id!=:Slotfull and Slot_Type__c !=\'Counselling\'',null);
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

    public PageReference SaveDetail(){
        try {

            //To return directly to print page if already interview scheduled
            if(objAccount.Interview_Slot__c != null) {
                PageReference pg =new PageReference('/apex/InterviewSchedulePrintForm?id='+AccountID);
                pg.setRedirect(true);
                return pg; 
            }

            objAccount.id = AccountID;
            String MapKey = objAccount.Time_Range__c + '-' + String.valueOf(objAccount.Interview_Date__c);
            System.debug('MapOfInterviewDateTimeVsSlotId -->'+MapOfInterviewDateTimeVsSlotId.keySet());
            System.debug('MapKey -->'+MapKey);
            if(MapOfInterviewDateTimeVsSlotId.containsKey(MapKey)) {
                String SlotId = MapOfInterviewDateTimeVsSlotId.get(MapKey);
                System.debug('SlotId -->'+SlotId);
                objAccount.Interview_Slot__c = SlotId;
            }else{
                System.debug('Interview Slot id is missing');
                return null;
            }
            
            if(checkForSlotAvalialbility(objAccount.Interview_Slot__c)) {
                update objAccount;
                PageReference pg =new PageReference('/apex/InterviewSchedulePrintForm?id='+AccountID);
                pg.setRedirect(true);
                return pg; 
            }else{
                ErrorMessage('The selected Interview slot is not available.','PopUpError');
            }
            
        } catch (Exception e) {
            System.debug('System error '+e);
        }
        return null;
    }

    /**
    * @description
    * @author @BK | 12/6/2019
    * @param String SlotId
    * @return Boolean
    */
    public Boolean checkForSlotAvalialbility(String SlotId) {
        try {
            Integer lstsize = 0;
            AggregateResult[] groupedResults = [SELECT count(id)lstsize FROM Account WHERE Interview_Slot__c=:SlotId];
            for (AggregateResult ar : groupedResults)  {
                lstsize = (Integer)ar.get('lstsize');
                System.debug('AccountSize -->'+lstsize);
            }
            Interview_Slot__c objSlot = new Interview_Slot__c(id = SlotId);
            objSlot.Account_Assigned__c = lstsize + 1; 
            System.debug('objSlot.Account_Assigned__c -->'+objSlot.Account_Assigned__c);
            update objSlot;
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
        return true;
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