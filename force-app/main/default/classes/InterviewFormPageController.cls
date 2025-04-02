/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-11-2024
 * @last modified by  : @BK
**/
public without sharing class InterviewFormPageController {
    public Id objectId;
    public String objectType;

    public Boolean isDataFetched {get;set;}
    public Set<id> slotfullIds {get;set;}
    public String statusCode { get; set; }
    public String message { get;set; }   
    public Account objAccount {get;set;}
    public StudentDetails objStudentDetails {get;set;}
    public Date today {get;set;}
    public Boolean isSlotBooked {get;set;}
    public Boolean isSlotAvailable {get;set;}
    public Date bookedInterviewDate {get;set;}
    public String bookedTimeRange {get;set;}
    public String joinLink {get;set;}
    public DateTime bookedTime {get;set;}
    public InterviewDetails objInterviewDetails {get;set;}

    public Map<String,String> mapOfInterviewDateTimeVsSlotId {get;set;}
    public Map<String,Integer> mapOfSlotVsAccountlistSize {get;set;}

    // Picklist Options
    public list<SelectOption> getInterviewTime {get;set;}
    public List<SelectOption> getInterviewDate {get;set;}

    public InterviewFormPageController() {
        isDataFetched = false;
        slotfullIds = new Set<id>();
        objAccount = new Account();
        statusCode = '';
        message = null;
        isSlotBooked = false;
        objStudentDetails = new StudentDetails();
        objInterviewDetails = new InterviewDetails();

        mapOfSlotVsAccountlistSize = new Map<String,Integer>();
        mapOfInterviewDateTimeVsSlotId = new Map<String,String>();

        Integer addDaysforToday= Integer.ValueOf(System.Label.AddDays);
        today = Date.today().addDays(addDaysforToday);
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @return Id 
    **/
    public Id getObjectId() {
        System.debug('get Id');
        return this.objectId;
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @param Id objectId 
    **/
    public void setObjectId(Id objectId) {
        system.debug('setObjectId --> ' );
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId) && !isDataFetched) {
            queryRecordData(this.objectId);
            isDataFetched = true;
        }
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @return String 
    **/
    public String getObjectType() {
        System.debug('get type');
        return this.objectType;
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @param String objectType 
    **/
    public void setObjectType(String objectType) {
        System.debug('set type');
        this.objectType = objectType;
    }

    /**
    * @description 
    * @author @BK | 23-11-2024 
    * @param String msg 
    * @param String errorCode 
    **/
    public void errorMessage(String msg,String errorCode){
        message = msg;
        statusCode = errorCode; 
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @param Id recordId 
    **/
    private void queryRecordData(Id recordId){
        List<Account> lstAccount = [SELECT Id,Interview_Date__c,Interview_Slot__c,Time_Range__c,nm_RegistrationNumber__c,FirstName,LastName,Program_Type__c,nm_Program__r.Bachelor_Specialization__c,nm_Program__r.Form_Specialisation__c,InterviewDateTime__c,Zoom_Url__c FROM Account WHERE Id=:recordId LIMIT 1];
        if(!lstAccount.isEmpty()) {
            objAccount = lstAccount[0];
            objStudentDetails.studentNo = objAccount.nm_RegistrationNumber__c;
            objStudentDetails.studentName = objAccount.FirstName +' '+objAccount.LastName;
            objStudentDetails.program = objAccount.nm_Program__r.Bachelor_Specialization__c;
            objStudentDetails.programCategory = objAccount.Program_Type__c;
            objStudentDetails.programSpecialisaton = objAccount.nm_Program__r.Form_Specialisation__c;
            getInterviewDate();
            // Interview Details
            setInterviewDetails();
            slotFullCheck();
        }
    } 

    /**
    * @description 
    * @author @BK | 22-11-2024 
    **/
    private void slotFullCheck() {
        // Step 1: Get list of accounts with valid interview slots
        List<Account> lstAccSlotAlloted = getAccountsWithInterviewSlots();
        if (lstAccSlotAlloted.isEmpty()) {
            return; // No accounts to process
        }
        
        // Step 2: Collect unique interview slots
        Set<Id> setofInterview = getUniqueInterviewSlots(lstAccSlotAlloted);
        
        // Step 3: Aggregate and get slot sizes
        Map<Id, Integer> mapOfSlotVsAccountlistSize = getSlotAccountSizes(setofInterview);
        
        // Step 4: Check if any interview slots are full
        checkSlotsFull(mapOfSlotVsAccountlistSize, setofInterview);
    }
    
    // Helper method to get accounts with valid interview slots
    private List<Account> getAccountsWithInterviewSlots() {
        return [SELECT id, Interview_Slot__c FROM Account WHERE Interview_Date__c >: today AND Time_Range__c != null];
    }
    
    // Helper method to get unique interview slots from accounts
    private Set<Id> getUniqueInterviewSlots(List<Account> lstAccSlotAlloted) {
        Set<Id> setofInterview = new Set<Id>();
        for (Account obcc : lstAccSlotAlloted) {
            setofInterview.add(obcc.Interview_Slot__c);
        }
        return setofInterview;
    }
    
    // Helper method to aggregate the number of accounts per interview slot
    private Map<Id, Integer> getSlotAccountSizes(Set<Id> setofInterview) {
        Map<Id, Integer> mapOfSlotVsAccountlistSize = new Map<Id, Integer>();
        
        AggregateResult[] groupedResults = [SELECT count(id) lstsize, Interview_Slot__c 
                                            FROM Account 
                                            WHERE Interview_Slot__c IN :setofInterview 
                                            GROUP BY Interview_Slot__c];
        
        for (AggregateResult ar : groupedResults) {
            Integer lstsize = (Integer) ar.get('lstsize');
            Id slotId = (Id) ar.get('Interview_Slot__c');
            mapOfSlotVsAccountlistSize.put(slotId, lstsize);
        }
        
        return mapOfSlotVsAccountlistSize;
    }
    
    // Helper method to check if slots are full and add to the set of full slots
    private void checkSlotsFull(Map<Id, Integer> mapOfSlotVsAccountlistSize, Set<Id> setofInterview) {
        List<Interview_Slot__c> lstinterviewSlot = [SELECT id, IntakeAlllowed__c FROM Interview_Slot__c WHERE Id IN :setofInterview];
        
        for (Interview_Slot__c objSlot : lstinterviewSlot) {
            Decimal slotIntakecapacity = objSlot.IntakeAlllowed__c;
            Id slotId = objSlot.id;
            
            if (mapOfSlotVsAccountlistSize.containsKey(slotId) && mapOfSlotVsAccountlistSize.get(slotId) >= slotIntakecapacity) {
                slotfullIds.add(slotId);
            }
        }
    }
    

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getInterviewTime(){
        List<SelectOption> lstVenueTimeOption = new List<SelectOption>();
        String programType = objAccount.Program_Type__c;
        lstVenueTimeOption.add(new SelectOption('', 'Select Time'));
        Date interviewDate = objInterviewDetails.interviewDate;
        System.debug('objAccount.Interview_Date__c---------->'+objInterviewDetails.interviewDate);
        System.debug('InterviewDate---------->'+interviewDate);
        String conditionString = 'Interview_Date__c =:interviewDate and id !=:slotfullIds and IsActive__c = TRUE and Slot_Type__c !=\'Counselling\'';
        if(String.isNotBlank(programType)) {
            conditionString += ' and Program_Type__c=:programType';
        }
        String querytime = DynamicQueryBuilder.getQueryAllFieldSql('Interview_Slot__c',conditionString,null);
        // if(isActiveCheck) {
        //     querytime = DynamicQueryBuilder.getQueryAllFieldSql('Interview_Slot__c','Interview_Date__c =:interviewDate and id !=:slotfullIds and Slot_Type__c !=\'Counselling\'' ,null);
        // }
        List<Interview_Slot__c> lstVenueSlot = DataBase.query(querytime);
        System.debug('lstVenueSlot Time --'+lstVenueSlot);
        if(lstVenueSlot.size() > 0){
            for(Interview_Slot__c objInterviewSlot : lstVenueSlot){
                
                String timeRange = getFormattedTime(objInterviewSlot.Start_time__c) +' - '+ getFormattedTime(objInterviewSlot.end_time__c);
                String mapKey = timeRange+'-'+String.valueof(objInterviewSlot.Interview_Date__c);
                mapOfInterviewDateTimeVsSlotId.put(mapKey,objInterviewSlot.id);
                lstVenueTimeOption.add(new SelectOption(timeRange, timeRange));
            }
        }
        return lstVenueTimeOption;
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getInterviewDate(){
        List<SelectOption> lstVenueDateOption = new List<SelectOption>();
        String programType = objAccount.Program_Type__c;
        lstVenueDateOption.add(new SelectOption('', 'Select Date'));
        Set<Date> dateRange = new Set<Date>();
        String conditionString = 'Interview_Date__c > :today and id!=:slotfullIds and IsActive__c = TRUE and Slot_Type__c !=\'Counselling\'';
        if(String.isNotBlank(programType)) {
            conditionString += ' and Program_Type__c=:programType';
        }
        String querydate = DynamicQueryBuilder.getQueryAllFieldSql('Interview_Slot__c',conditionString,null);
        // if(isActiveCheck) {
        //     querydate = DynamicQueryBuilder.getQueryAllFieldSql('Interview_Slot__c','Interview_Date__c>:today and id!=:slotfullIds and Slot_Type__c !=\'Counselling\'',null);
        // }
        List<Interview_Slot__c> lstVenueSlot = DataBase.query(querydate);
        System.debug('lstVenueSlot--'+lstVenueSlot);
        isSlotAvailable = !lstVenueSlot.isEmpty();
        if(isSlotAvailable){
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

    /**
    * @description 
    * @author @BK | 22-11-2024 
    **/
    public void saveDetail(){
        try {
            String mapKey = objInterviewDetails.timeRange + '-' + String.valueOf(objInterviewDetails.interviewDate);
            System.debug('mapOfInterviewDateTimeVsSlotId -->'+mapOfInterviewDateTimeVsSlotId.keySet());
            System.debug('MapKey -->'+mapKey);
            if(mapOfInterviewDateTimeVsSlotId.containsKey(mapKey)) {
                String slotId = mapOfInterviewDateTimeVsSlotId.get(mapKey);
                System.debug('SlotId -->'+slotId);
                objAccount.Interview_Slot__c = slotId;
            } else {
                System.debug('Interview Slot id is missing');
                errorMessage('Internal Error Occured, Kindly try again later.','error');
                return;
            }
            
            if(checkForSlotAvalialbility(objAccount.Interview_Slot__c)) {
                objAccount.Time_Range__c = objInterviewDetails.timeRange;
                objAccount.Interview_Date__c = objInterviewDetails.interviewDate;
                update objAccount;
                setInterviewDetails();
                errorMessage('Interview Slot Booked Successfully.','success');
            }else{
                errorMessage('The selected Interview slot is not available.','error');
            }
        } catch (Exception e) {
            System.debug('System error '+e);
            errorMessage('Internal Error Occured, Kindly Raise a Query.','error');
        }
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @param String slotId 
    * @return Boolean 
    **/
    private Boolean checkForSlotAvalialbility(String slotId) {
        try {
            Integer lstsize = 0;
            AggregateResult[] groupedResults = [SELECT count(id)lstsize FROM Account WHERE Interview_Slot__c=:slotId];
            for (AggregateResult ar : groupedResults)  {
                lstsize = (Integer)ar.get('lstsize');
                System.debug('AccountSize -->'+lstsize);
            }
            Interview_Slot__c objSlot = new Interview_Slot__c(id = slotId);
            objSlot.Account_Assigned__c = lstsize + 1; 
            System.debug('objSlot.Account_Assigned__c -->'+objSlot.Account_Assigned__c);
            update objSlot;
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
        return true;
    }

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @param Date dateValue 
    * @return String 
    **/
    private String getFormattedDate(Date dateValue) {
        Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
        return String.valueOf(dt.format('dd MMMM yyyy'));
    } 

    /**
    * @description 
    * @author @BK | 22-11-2024 
    * @param Time timeVal 
    * @return String 
    **/
    private String getFormattedTime(Time timeVal) {
        String timeValue = String.valueof(timeVal);
        DateTime d = Date.Today() ;
        String dateStr =  d.format('yyyy-MM-dd') ;
        String inpputString = dateStr+' '+timeValue;
        DateTime resultDateTime = DateTime.ValueofGmt(inpputString);
        return String.valueOf(resultDateTime.formatGMT('h:mm a'));
    }

    /**
    * @description 
    * @author @BK | 23-11-2024 
    **/
    private void setInterviewDetails() {
        isSlotBooked = objAccount.Interview_Slot__c != null ? true : false;
        bookedInterviewDate = objAccount.Interview_Date__c;
        bookedTimeRange = objAccount.Time_Range__c;
        joinLink = objAccount.Zoom_Url__c;
        bookedTime = objAccount.InterviewDateTime__c;

    }

    public class InterviewDetails {
        public InterviewDetails() {
            this.interviewDate = null;
            this.timeRange = '';
        }
        public Date interviewDate {get;set;}
        public String timeRange {get;set;}
    }
}