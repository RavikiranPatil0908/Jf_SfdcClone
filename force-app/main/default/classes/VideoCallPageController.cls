/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-24-2025
 * @last modified by  : @vickysahu
**/
public without sharing class VideoCallPageController {
    public Account objAccount {get; set;}
    // public Lead objLead {get; set;}
    public Opportunity objOpp {get; set;}
    public List<SelectOption> getVideoCallDate {get;set;}
    public List<SelectOption> videoCallTime {get;set;}
    public List<SelectOption> videoCallTimeRange {get;set;}
    public String strSecToShow {get; set;}
    public String message {get;set;}
    public Map<String, List<Map<String,String>>> mapOfDateVsTimeRange {get;set;}
    public ObjWrapper wrapper {get; set;}
    public String scheduleTimeSlotId {get; set;}
    public Id objectId;
    public String objectType;
    public Boolean isDataFetched;
    public String formStatus {get; set;}
    public VVC_Junction__c objSlotBooked {get; set;}
    public String callDate {get;set;}
    public String callTime {get;set;}
    public String sectionHeader {get;set;}
    public String meetingUrl {get;set;}
    public Boolean isReschedule {get;set;}
    public Boolean showReScheduleButton {get;set;}
    public Datetime newTime {get;set;}
    // public Student_Rating__c objRating {get;set;}
    public String cancelDate {get;set;}
    public List<VVC_Junction__c> lstVVCTranscript {get;set;}
    public String vvcJunctionId {get;set;}
    public String validityDate {get;set;}
    public Boolean isVideoVerificationEnabled {get;set;}
    public Boolean isSlotAvailable {get;set;}
    public String cancelDate2 {get;set;}
    public Boolean isDebVerified {get;set;}
    public Boolean validAccStatus {get;set;}
    public Boolean isDownPaymentMade {get;set;}
    public Boolean showBookingForm {get;set;}
    public Map<Id,List<VVC_Question__c>> mapOfIdAndQuestion {get;set;}
    public List<VVC_Question__c> lstQuestion {get;set;}
    public Map<String,List<String>> mapOfKeyVsTime {get;set;}
    public VideoCallWrapper objVideoCall {get;set;}
    public Boolean isVVCNotExpired {get;set;}

    public VideoCallPageController(){
        objAccount = null;
        objOpp = null;
        objSlotBooked = new VVC_Junction__c();
        isSlotAvailable = false;
        //lstScheduling = null;
        mapOfDateVsTimeRange = new Map<String, List<Map<String,String>>>();
        mapOfIdAndQuestion = new Map<Id,List<VVC_Question__c>>();
        lstQuestion = new List<VVC_Question__c>(); 
        strSecToShow = '';
        message = '';
        scheduleTimeSlotId = '';
        isDataFetched = false;
        formStatus = '';
        callDate = '';
        callTime = '';
        sectionHeader = '';
        meetingUrl = '';
        showReScheduleButton = false;
        newTime = null;
        // objRating = new Student_Rating__c();
        cancelDate = '';
        lstVVCTranscript = new List<VVC_Junction__c>();
        vvcJunctionId = '';
        validityDate = '';
        isReschedule = false;
        isVideoVerificationEnabled = false;
        cancelDate2 = '';
        isDebVerified = false;
        validAccStatus = false;
        showBookingForm = false;
        isDownPaymentMade=false;
        mapOfKeyVsTime = new Map<String,List<String>>();
        objVideoCall = new VideoCallWrapper();
        isVVCNotExpired = false;
    }


    /**
    * @description
    * @author @BK | 24-05-2024 
    * @return Id 
    **/
    public Id getObjectId() {
        System.debug('get Id');
    return this.objectId;
  }

    /**
    * @description 
    * @author @BK | 24-05-2024 
    * @param Id objectId 
    **/
    public void setObjectId(Id objectId) {
        system.debug('setObjectId --> ' );
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId) && !isDataFetched) {
            queryRecordData(this.objectId);
            getSchedulingVVCCall(this.objectId);
            isDataFetched = true;
        }
    }

    /**
    * @description 
    * @author @BK | 24-05-2024 
    * @return Id 
    **/
    public String getObjectType() {
        System.debug('get type');
        return this.objectType;
    }
    /**
    * @description 
    * @author @BK | 24-05-2024 
    * @param String objectType 
    **/
    public void setObjectType(String objectType) {
        System.debug('set type');
        this.objectType = objectType;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param msg 
    * @param secToShow 
    **/
    public void ErrorMessage(String msg,String secToShow){
        message = msg;
        strSecToShow = secToShow; 
    }
    
    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param recordId 
    **/
    public void queryRecordData(Id recordId){
        List<Account> lstAccount = [SELECT Id, nm_DateOfBirth__c, nm_ChooseaProgram__c, nm_StudentStatus__c, nm_Program__r.nm_ProgramValidity__c, nm_Program__r.Specialisation__c, nm_Program__r.nm_ProgramDuration__c, nm_Program__r.nm_ProgramName__c, is_Video_Call_Verified__c, FirstName, LastName, nm_Program__r.Name, PersonMobilePhone, PersonEmail,nm_ProgramType__c,Specialization_Type__c,nm_Program2__r.nm_ProgramName__c,nm_Nationality__c,nm_Domicile__c,DEBID__c,OwnerId FROM Account WHERE Id=:recordId LIMIT 1];
        List<Schedule_Time_Slot__c> lstScheduling = [SELECT Id,Start_time__c,End_time__c,Total_Counselors__c,Per_Call_Schedule_Minutes__c,Start_date__c,End_date__c,Recurrence__c,Custom_Schedule_Days__c FROM Schedule_Time_Slot__c WHERE RecordType.Name = 'Video Call' AND IsActive__c=true AND End_date__c>=TODAY];
        List<DEB_Detail__c> lstDebDetails = [SELECT Id, Is_Active__c FROM DEB_Detail__c WHERE Is_Active__c=true AND Account__c=:recordId ORDER BY CreatedDate DESC LIMIT 1];
        isSlotAvailable = lstScheduling.size() > 0 ? true : false;
        if(lstAccount.size() > 0){
            objAccount = lstAccount[0];
            isDebVerified = (lstDebDetails.size() > 0 && String.isNotBlank(objAccount.DEBID__c)) || (objAccount.nm_Nationality__c != 'Indian' && objAccount.nm_Nationality__c != 'India') ? true : false;
            wrapper = new ObjWrapper(objAccount);
            List<Opportunity> lstOpp = [SELECT Id,Applied_For_Loan__c,Specialisation__c,Loan_Type__c,Tenure__c,Loan_Amount__c,Down_Payment_Made__c,Is_Re_Registration_Payment__c,nm_Session__c,nm_Year__c,nm_Semester__c,nm_Category__c,StageName FROM Opportunity WHERE AccountId=: objAccount.Id AND Is_Re_Registration_Payment__c=false AND (nm_Category__c='Admission' OR nm_Category__c='Lateral Admission') LIMIT 1];
            objOpp = lstOpp.size() > 0 ? lstOpp[0] : new Opportunity();
            checkVVCLastDate();
            
            isDownPaymentMade= objOpp.Down_Payment_Made__c;
            showBookingForm = (lstOpp.size() > 0 && isDownPaymentMade && isDebVerified ) ? true : (lstOpp.size() > 0 && !isDownPaymentMade && objOpp.StageName == 'Closed'  ); 
            validAccStatus= (objAccount.nm_StudentStatus__c == 'Admission form & documents Approved' || objAccount.nm_StudentStatus__c == 'Admission Form & Documents Provisional'); 
           
            isVideoVerificationEnabled = objOpp != null && validAccStatus && showBookingForm;
            isDataFetched = true;
            formStatus = objAccount.is_Video_Call_Verified__c ? 'Verified' : '';
            //getCancellationDate();
            getVVCQuestion();
            //List<Task> lstTask = [Select Id, Schedule_Call_Time__c, CreatedDate, Zoom_Url__c, Meeting_Id__c, Call_Scheduled_Time__c,Schedule_Time_Slot__c, Call_date__c, Time_Range__c, WhatId, WhoId, Status, Video_Call_Scheduled_Key__c FROM Task WHERE Subject='Video Call Scheduling' AND Schedule_Time_Slot__c!=null AND Status In ('In Progress','Completed') AND WhatId=:objAccount.Id Order by CreatedDate Desc];
            List<VVC_Junction__c> lstVVC = getScheduledVVC();
            if (lstVVC.size() > 0) {
                if (formStatus == 'Verified' || objSlotBooked.Status__c == 'Completed' || objSlotBooked.Status__c == 'In Progress') {
                    // getListTask();
                    for (VVC_Junction__c objVVC : lstVVC) {
                        if (objVVC.Status__c == 'Completed') {
                            lstVVCTranscript.add(objVVC);
                        }
                    }
                }
                //System.debug(' objRating--->' + JSON.serialize(objRating));
            }
            
            if (!objAccount.is_Video_Call_Verified__c) {
                if (lstVVC.size() > 0) {
                    formStatus = lstVVC[0].Status__c == 'In Progress' ? 'Slot Booked' : lstVVC[0].Status__c == 'Completed' && !objAccount.is_Video_Call_Verified__c ? 'Not Verified' : '';
                }
                else {
                    formStatus = 'Pending';
                }        
            }
            if (formStatus == 'Slot Booked') {
                DateTime currentDt = System.now().addHours(24);
                // hideButton = objTaskBooked.Schedule_Call_Time__c > currentDt || objTaskBooked.Call_date__c < Date.today() ? '' : 'hide';
                showReScheduleButton = objSlotBooked.Schedule_Call_Time__c > currentDt || objSlotBooked.Call_date__c < Date.today() ? true : false;
                System.debug(currentDt + ' ' + objSlotBooked.Schedule_Call_Time__c + ' ' + objSlotBooked.Call_date__c);
            }
            sectionHeader = formStatus == 'Pending' ? 'BOOK YOUR SLOT FOR VIDEO VERIFICATION CALL' : formStatus == 'Slot Booked' || formStatus == 'Not Verified' ? 'SLOT DETAILS FOR VIDEO VERIFICATION CALL' : formStatus == 'Verified' ? 'VIDEO VERIFICATION FORM DETAILS' : '';
        } else {
            return;
        }
        System.debug('wrapper ==>');
        System.debug(wrapper);
    } 

    public Void checkVVCLastDate() {
        List<NM_Payment_Form_Configuration__c> lstNMConfig = new List<NM_Payment_Form_Configuration__c>();
        lstNMConfig = [SELECT Id,Last_Date_For_Video_Verification__c FROM NM_Payment_Form_Configuration__c WHERE Session__c =: objOpp.nm_Session__c AND Current_Admission_Year__c =: String.valueOf(objOpp.nm_Year__c) AND Payment_Type__c = 'Admission' AND Program_Category__c =: objAccount.nm_ChooseaProgram__c AND Program_Type__c =: objOpp.Specialisation__c LIMIT 1];
        isVVCNotExpired  = lstNMConfig.size() > 0 && lstNMConfig[0].Last_Date_For_Video_Verification__c >= Date.today() ? true : false;
    }

    public List<VVC_Junction__c> getScheduledVVC() {
        List<VVC_Junction__c> lstVVC = [Select Id, is_Call_Cancel__c,Not_Joined__c, Schedule_Call_Time__c, Zoom_Url__c, Meeting_Id__c, Call_Scheduled_Time__c,Schedule_Time_Slot__c, Call_Date__c, Time_Range__c, Status__c, Video_Call_Scheduled_Key__c FROM VVC_Junction__c WHERE Schedule_Time_Slot__c != null AND Status__c In ('In Progress','Completed') AND Account__c=:objAccount.Id Order by CreatedDate Desc];
        if (lstVVC.size() > 0) {
            objSlotBooked = lstVVC[0];
            String callDateTime = objSlotBooked.Schedule_Call_Time__c.format('yyyy/MM/dd hh:mm a');
            callDate = callDateTime.split(' ')[0];
            calltime = callDateTime.split(' ')[1] + ' ' + callDateTime.split(' ')[2];
            meetingUrl = String.valueOf(objSlotBooked.Zoom_Url__c);
            formatDateTime(objSlotBooked.Schedule_Call_Time__c);
        }
        return lstVVC;
    }

    public void getVVCQuestion() {
        //List<VVC_Question__c> lstQuestion = new List<VVC_Question__c>();
        lstQuestion = [SELECT Id,Answer__c,Question__c,VVC_Junction__c,Account__c,Display_to_Student__c FROM VVC_Question__c WHERE VVC_Junction__r.Account__c=:objAccount.Id order by CreatedDate ASC];
        if (lstQuestion.size() > 0) {
            for (VVC_Question__c obj : lstQuestion) {
                if (obj.Display_to_Student__c) {
                    List<VVC_Question__c> lst = mapOfIdAndQuestion.containsKey(obj.VVC_Junction__c) ? mapOfIdAndQuestion.get(obj.VVC_Junction__c) : new List<VVC_Question__c>();
                    lst.add(obj);
                    mapOfIdAndQuestion.put(obj.VVC_Junction__c,lst);
                }
                
            }
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    **/
    // public void getListTask() {
    //     lstTaskTranscript = [SELECT Id,CreatedDate,Not_Joined__c,is_Call_Cancel__c,Schedule_Call_Time__c,Subject,Schedule_Time_Slot__c,Status,WhatId,Call_date__c,Call_Scheduled_Time__c,StudentRating__c FROM Task WHERE Subject='Video Call Scheduling' AND Schedule_Time_Slot__c!=null AND Status In ('Completed','Not Connected') AND WhatId=:objAccount.Id Order by CreatedDate Desc];
    // }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    **/
    // public void getStudentRating() {
    //     List<Student_Rating__c> lstStudentRating = [SELECT Id,Student__c,Confirm_Special_Case__c,Does_Photo_Matched__c,Confirm_Correct_Program__c,Confirm_Correct_DOB__c,Confirm_Correct_Duration__c,Confirm_Loan_Details__c,Confirm_Exam_Fee__c,Confirm_Validity_Of_Program__c,Confirm_Passing_Marks__c,Confirm_Exam_Conduction_Process__c,Confirm_No_Placement_Service__c,Confirm_Mandatory_Engagement__c,Confirm_Cancellation_date__c,CreatedDate,Confirm_Session__c,Confirm_Examination_Component__c,Confirm_Exam_Evaluation__c,Confirm_Term_End_Examination__c,Confirm_Reexam_Process__c FROM Student_Rating__c WHERE Student__c=:objAccount.Id AND Id=:ratingId AND  RecordType.Name='Video Verification' Order By CreatedDate Desc LIMIT 1];
    //     objRating = lstStudentRating.size() > 0 ? lstStudentRating[0] : new Student_Rating__c();
    //     System.debug('test--->' + objRating);
    // }

    public void getVideoTranscript() {
        System.debug('vvcJunctionId-->' + vvcJunctionId);
        if (String.isNotBlank(vvcJunctionId)) {
            lstQuestion = mapOfIdAndQuestion.containsKey(vvcJunctionId) ? mapOfIdAndQuestion.get(vvcJunctionId) : new List<VVC_Question__c>();
        }
        else {
            lstQuestion = null;
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param lstCalender 
    **/
    /*public void getCalender(List<Calender__c> lstCalender) {
        Map<String,Calender__c> mapOfKeyVsCalender = new Map<String,Calender__c>();
        String mapKey = objAccount.nm_ProgramType__c + '_' + objAccount.nm_Program__r.Specialisation__c;
        Calender__c objCalender = new Calender__c();
        for (Calender__c objCal : lstCalender) {
            if ((String.isNotBlank(objCal.nm_Type__c) && String.isNotBlank(objCal.Specialisation__c)) || (String.isBlank(objCal.Specialisation__c) && String.isNotBlank(objCal.nm_Type__c))) {
                String calMapKey = objCal.nm_Type__c + '_' + objCal.Specialisation__c;
                mapOfKeyVsCalender.put(calMapKey,objCal);
            }
            if (String.isBlank(objCal.Specialisation__c) && String.isBlank(objCal.nm_Type__c)) {
                mapOfKeyVsCalender.put('All',objCal);
            }
        }

        objCalender = mapOfKeyVsCalender.containsKey(mapKey) ? mapOfKeyVsCalender.get(mapKey) : mapOfKeyVsCalender.containsKey('All') ? mapOfKeyVsCalender.get('All') : null;
        System.debug('objCalender---->' + objCalender);
        if (objCalender != null) {
            List<String> months = new List<String>{
                'January', 'February', 'March', 'April', 'May', 'June', 
                'July', 'August', 'September', 'October', 'November', 'December'
            };
            Date lastDate = objCalender.Last_Date_for_Cancellation__c != null ? objCalender.Last_Date_for_Cancellation__c : null;
            cancelDate = lastDate != null ? lastDate.Day() + '/' + lastDate.Month() + '/' + lastDate.Year() : '';
            Integer validityYear = Integer.valueOf(objCalender.Year__c) + Integer.valueOf(objAccount.nm_Program__r.nm_ProgramValidity__c);
            Integer month = months.indexOf(objCalender.Session__c) == 0 ? 12 : months.indexOf(objCalender.Session__c);
            Integer numberOfDays = Date.daysInMonth(validityYear, month);
            validityDate = numberOfDays + '/' + month + '/' + validityYear;
        }
    }*/

    // public void getCancellationDate() {
    //     Map<String,Date> mapOfCancelDate = new Map<String,Date>();
    //     if (objOpp != null) {
    //         List<Cancelation_Date__c> lstCancelDate = [SELECT Id,Amount__c,Percentage__c,Admission_Fee__c,To_Date__c,NM_Payment_Form_Configuration__r.Payment_Type__c,NM_Payment_Form_Configuration__r.Program_Type__c,NM_Payment_Form_Configuration__r.Current_Admission_Year__c,NM_Payment_Form_Configuration__r.Session__c FROM Cancelation_Date__c WHERE NM_Payment_Form_Configuration__r.Payment_Type__c='Admission' AND NM_Payment_Form_Configuration__r.Program_Type__c=:objAccount.nm_Program__r.Specialisation__c AND NM_Payment_Form_Configuration__r.Current_Admission_Year__c=:String.valueOf(objOpp.nm_Year__c) AND NM_Payment_Form_Configuration__r.Session__c=:objOpp.nm_Session__c AND Admission_Fee__c=false AND Percentage__c=null];
    //         if (lstCancelDate.size() > 0) {
    //             for (Cancelation_Date__c objCancelDate : lstCancelDate) {
    //                 if (objCancelDate.Amount__c == null && objCancelDate.Percentage__c == null && objCancelDate.Admission_Fee__c == false) {
    //                     mapOfCancelDate.put('cancel1', objCancelDate.To_Date__c);
    //                 }
    //                 if (objCancelDate.Amount__c != null && objCancelDate.Percentage__c == null && objCancelDate.Admission_Fee__c == false) {
    //                     mapOfCancelDate.put('cancel2', objCancelDate.To_Date__c);
    //                 }
    //             }
    //             Date dt1 = mapOfCancelDate.containsKey('cancel1') ? mapOfCancelDate.get('cancel1') : null;
    //             cancelDate = dt1 != null ? dt1.Day() + '/' + dt1.Month() + '/' + dt1.Year() : '';
    //             Date dt2 = mapOfCancelDate.containsKey('cancel2') ? mapOfCancelDate.get('cancel2') : null;
    //             cancelDate2 = dt2 != null ? dt2.Day() + '/' + dt2.Month() + '/' + dt2.Year() : '';
    //         }

    //         List<String> months = new List<String>{
    //             'January', 'February', 'March', 'April', 'May', 'June', 
    //             'July', 'August', 'September', 'October', 'November', 'December'
    //         };

    //         Integer validityYear = Integer.valueOf(objOpp.nm_Year__c) + Integer.valueOf(objAccount.nm_Program__r.nm_ProgramValidity__c);
    //         Integer month = months.indexOf(objOpp.nm_Session__c) == 0 ? 12 : months.indexOf(objOpp.nm_Session__c);
    //         Integer numberOfDays = Date.daysInMonth(validityYear, month);
    //         validityDate = numberOfDays + '/' + month + '/' + validityYear;
    //     }
    // }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param recordId 
    **/
    public void getSchedulingVVCCall(Id recordId){ 
        // Map<String, Integer> mapOfTimeRangeVsAssignedStudent = new Map<String, Integer>();
        // Map<String,Integer> mapOfKeyVsSlotAssigned = new Map<String, Integer>();
        objVideoCall.mapOfKeyVsSlotAssigned = new Map<String,Integer>();
        objVideoCall.mapOfTimeRangeVsAssignedStudent = new Map<String,Integer>();
        if(objAccount != null){
            try {
                List<VVC_Junction__c> lstVVCCall = [Select Id, Schedule_Call_Time__c, Schedule_Time_Slot__c, Call_Date__c, Time_Range__c, Status__c, Video_Call_Scheduled_Key__c, Call_Scheduled_Time__c FROM VVC_Junction__c WHERE Schedule_Time_Slot__c != null AND Status__c = 'In Progress' AND Call_Date__c >= TODAY];
                for(VVC_Junction__c objVVC : lstVVCCall) {
                    Set<String> status = new Set<String>{'In Progress'};
                    System.debug('Video Verivication call-->'+ JSON.serialize(objVVC));
                    String mapKey = objVVC.Video_Call_Scheduled_Key__c +'_'+ objVVC.Call_Scheduled_Time__c;
                    System.debug('mapKey----->' + mapKey);
                    //To store student count for time range
                    Integer assignedStudents = objVideoCall.mapOfTimeRangeVsAssignedStudent.containsKey(objVVC.Video_Call_Scheduled_Key__c) ? objVideoCall.mapOfTimeRangeVsAssignedStudent.get(objVVC.Video_Call_Scheduled_Key__c) : 0;
                    assignedStudents++;
                    objVideoCall.mapOfTimeRangeVsAssignedStudent.put(objVVC.Video_Call_Scheduled_Key__c,assignedStudents);
                    //To store student count for particular time slot
                    Integer studentCount = objVideoCall.mapOfKeyVsSlotAssigned.containsKey(mapKey) ? objVideoCall.mapOfKeyVsSlotAssigned.get(mapKey) : 0;
                    studentCount++;
                    objVideoCall.mapOfKeyVsSlotAssigned.put(mapKey, studentCount);
                }
                // To get map of Date Vs TimeRange
                mapOfDateVsTimeRange = getSchedulingList();
                System.debug('mapOfDateVsTimeRange--->' + JSON.serialize(mapOfDateVsTimeRange));
            } catch (Exception err) {
                System.debug('Error Message ==>'+err.getMessage());
                System.debug('Error Line No.==>'+err.getLineNumber());
            }
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @return PageReference 
    **/
    public PageReference getCallSchedulingPage() {
        formStatus = 'Pending (Needs Re-booking)';
        sectionHeader = 'VIDEO VERIFICATION FORM DETAILS';
        isReschedule = true;
        return null;
    }
        

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @return PageReference 
    **/
    public PageReference checkValidityOfMeeting() {
        try {
            // formatDateTime(objTaskBooked.Schedule_Call_Time__c);
            // System.debug('newTime--->' + newTime);
            // Datetime currentDt = System.now();
            // Datetime meetingJoinDt = newTime;
            // meetingJoinDt = newTime.addHours(-3);
            // System.debug('addHours--->'+ meetingJoinDt);
            // meetingJoinDt = meetingJoinDt.addMinutes(-5);
            // System.debug('addMinutes--->'+ meetingJoinDt);
            // if (currentDt <= newTime && currentDt >= meetingJoinDt) {
            //     System.debug('redirect');
                PageReference pg =new PageReference(meetingUrl);
                pg.setRedirect(true);
                return pg;
            // }
            // else {
            //     ErrorMessage('You cannot Join Meeting! Either more than 5 mins after or 3 hours early', 'PopUpError');
            // }
        } catch (Exception e) {
            System.debug('Exception--->' + e);
        }
        
        return null;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param mapOfRangeVsStudents 
    * @return Map<String, List<Map<String, String>>> 
    **/
    public Map<String,List<Map<String,String>>> getSchedulingList() {
        Map<String,List<Map<String,String>>> mapOfDateVsTimeRange = new Map<String, List<Map<String,String>>>();
        try {
            List<Schedule_Time_Slot__c> lstScheduling = [SELECT Id,Start_time__c,End_time__c,Total_Counselors__c,Per_Call_Schedule_Minutes__c,Start_date__c,End_date__c,Recurrence__c,Custom_Schedule_Days__c,Zoom_Id__c,sameDayBookingDate__c,Time_Gap__c FROM Schedule_Time_Slot__c WHERE RecordType.Name = 'Video Call' AND IsActive__c=true AND End_date__c>=TODAY];
            
            for (Schedule_Time_Slot__c objSlot : lstScheduling) {
                Date startDate = objSlot.Start_date__c > System.today() ? objSlot.Start_date__c : System.today().addDays(1);
                Date endDate = objSlot.End_date__c;
                System.debug('objSlot.Start_date__c >= System.today()--->' + (objSlot.Start_date__c >= System.today()) +' '+ objSlot.Start_date__c +' '+ System.today());
                System.debug('System.today() == objSlot.sameDayBookingDate__c--->' + (System.today() == Date.valueOf(objSlot.sameDayBookingDate__c)));
                if (objSlot.Start_date__c <= System.today() && System.today() == objSlot.sameDayBookingDate__c) {
                    startDate = System.today();
                }
                //Max allowed per time range according to councellor available in schedule time slot
                Integer maxAllowedPerTimeRange = Integer.valueOf(objSlot.Total_Counselors__c * (60 / objSlot.Per_Call_Schedule_Minutes__c));
                //Max allowed per time range according to Available ZoomId in schedule time slot
                Integer zoomIdAvailable = String.isNotBlank(objSlot.Zoom_Id__c) ? Integer.valueOf(objSlot.Zoom_Id__c.split(';').size() * (60 / objSlot.Per_Call_Schedule_Minutes__c)) : 0;
                List<String> workingDays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
                List<String> customDays = objSlot.Custom_Schedule_Days__c!=null && objSlot.Custom_Schedule_Days__c!='' ? objSlot.Custom_Schedule_Days__c.split(';') : workingDays;
                if(startDate < endDate) {
                    while (startDate <= endDate) {
                        DateTime dt = startDate;
                        String weekOfDay = dt.format('EEEE');
                        if(objSlot.Recurrence__c == 'Daily' || (objSlot.Recurrence__c == 'Monday to Saturday' && workingDays.contains(weekOfDay)) || (objSlot.Recurrence__c == 'Custom' && customDays.contains(weekOfDay))) {
                            mapOfDateVsTimeRange = getDateWithTimeRange(startDate,objSlot,mapOfDateVsTimeRange,maxAllowedPerTimeRange,zoomIdAvailable);
                        }
                        startDate = startDate.addDays(1);
                    }
                } else {
                    DateTime dt = startDate;
                    String weekOfDay = dt.format('EEEE');
                    if(objSlot.Recurrence__c == 'Daily' || (objSlot.Recurrence__c == 'Monday to Saturday' && workingDays.contains(weekOfDay)) || (objSlot.Recurrence__c == 'Custom' && customDays.contains(weekOfDay))) {
                        mapOfDateVsTimeRange = getDateWithTimeRange(startDate,objSlot,mapOfDateVsTimeRange,maxAllowedPerTimeRange,zoomIdAvailable);
                    }
                }
            }
        } catch (Exception err) {
            System.debug('Error Message ==>'+err.getMessage());
            System.debug('Error Line No: ==>'+err.getLineNumber());
        }
        return mapOfDateVsTimeRange;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param startDate 
    * @param objSlot 
    * @param mapOfDateVsTimeRange 
    * @param mapOfTimeRangeVsStudent 
    * @param maxAllowedPerTimeRange 
    * @return Map<String, List<Map<String, String>>> 
    **/
    public Map<String,List<Map<String,String>>> getDateWithTimeRange(Date startDate,Schedule_Time_Slot__c objSlot, Map<String,List<Map<String,String>>> mapOfDateVsTimeRange, Integer maxAllowedPerTimeRange, Integer zoomIdAvailable) {
        try {
            Datetime startDateTime = Datetime.newInstance(startDate, objSlot.Start_time__c);
            System.debug('startDateTime---> ' + startDateTime);
            Datetime endDateTime = Datetime.newInstance(startDate, objSlot.End_time__c);
            if (System.today() == objSlot.sameDayBookingDate__c) {
                Datetime currentTime = Datetime.now();
                currentTime = Datetime.newInstance(
                    currentTime.year(), 
                    currentTime.month(), 
                    currentTime.day(), 
                    currentTime.hour(), 
                    currentTime.minute(), 
                    0 // Set seconds to 0 (milliseconds are automatically 0)
                );
                Integer timeGap = Integer.valueOf(objSlot.Time_Gap__c);
                startDateTime =  currentTime.addMinutes(timeGap) > startDateTime ? currentTime.addMinutes(timeGap) : startDateTime;
                 // Ensure Per_Call_Schedule_Minutes__c is treated as an Integer
                Integer scheduleMinutes = Integer.valueOf(objSlot.Per_Call_Schedule_Minutes__c);
                Integer minutes = startDateTime.minute();
                Integer minutesToAdd = scheduleMinutes - Math.mod(minutes, scheduleMinutes); // Use Math.mod() instead of %

                if (minutesToAdd != scheduleMinutes) { // Only adjust if not already at the correct interval
                    startDateTime = startDateTime.addMinutes(minutesToAdd);
                }
                System.debug('Adjusted Start Time for Same-Day Booking (Rounded to ' + scheduleMinutes + '-min interval): ' + startDateTime);
            }
            List<Map<String,String>> lstTimeRange = mapOfDateVsTimeRange.containsKey(String.valueOf(startDate)) ? mapOfDateVsTimeRange.get(String.valueOf(startDate)) : new List<Map<String,String>>();
            while (startDateTime < endDateTime && startDate <= objSlot.End_date__c) {
                Time rangeStartTime = startDateTime.time();
                String timeRange = timeRangeFormat(startDateTime, startDateTime.addHours(+1));
                //Time rangeEndTime = startDateTime.time().addHours(1);
                Integer extractedHour = startDateTime.addHours(1).hour();
                Time rangeEndTime = Time.newInstance(extractedHour, 0, 0, 0);
                String mapKey = startDate.year() + '-' + String.valueOf(startDate.month()).leftPad(2, '0') + '-' + String.valueOf(startDate.day()).leftPad(2, '0') + '_' + timeRange + '_' + String.valueOf(objSlot.id).left(15);
                System.debug('mapkey created-->'+ mapkey);

                Boolean isTimeRangeExists = true;
                for (Object mapOfTimeRangeAndIdObject : lstTimeRange) {
                    Map<String,String> mapOfTimeRangeAndIdAlready = (Map<String,String>) mapOfTimeRangeAndIdObject;
                    for(String keyValue : mapOfTimeRangeAndIdAlready.keySet()) {
                        if (keyValue == 'timeRange' && timeRange == mapOfTimeRangeAndIdAlready.get(keyValue)) {
                            isTimeRangeExists = false;
                        }
                    }
                }

                if (isTimeRangeExists && 
                    ((!objVideoCall.mapOfTimeRangeVsAssignedStudent.containsKey(mapKey)) 
                    || (objVideoCall.mapOfTimeRangeVsAssignedStudent.containsKey(mapKey) && maxAllowedPerTimeRange > objVideoCall.mapOfTimeRangeVsAssignedStudent.get(mapKey)
                    && zoomIdAvailable > objVideoCall.mapOfTimeRangeVsAssignedStudent.get(mapKey)))) {

                    Map<String,String> mapOfTimeRangeAndId = new Map<String,String>();
                    mapOfTimeRangeAndId.put('timeRange', timeRange);
                    mapOfTimeRangeAndId.put('schedulingId', objSlot.Id);
                    getSlotFromTimeRange(rangeStartTime,rangeEndTime,objSlot,mapkey,startDate);
                    //mapOfKeyVsTime = mapOfKeyVsTime.containsKey(mapKey) ? mapOfKeyVsTime.get(mapKey) : new Map<String,List<String>>();
                    lstTimeRange.add(mapOfTimeRangeAndId);
                    System.debug('lstTimeRange ==================>');
                    System.debug(lstTimeRange);
                }
                //System.debug('compare-->'+ JSON.serialize(mapOfTimeRangeVsStudent));
                System.debug('max-->' + maxAllowedPerTimeRange +' '+ rangeStartTime.minute());
                //startDateTime = startDateTime.addHours(1);
                startDateTime = startDateTime.addMinutes(-startDateTime.minute()).addHours(1);
            }
            System.debug('mapOfKeyVsTime date----> ' + JSON.serialize(mapOfKeyVsTime));
            if(lstTimeRange.size() > 0) {
                mapOfDateVsTimeRange.put(String.valueOf(startDate), lstTimeRange);
            }
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage());
            System.debug('Error Line No: ==>'+e.getLineNumber());
        }
        return mapOfDateVsTimeRange;
    }

    public void getSlotFromTimeRange(Time rangeStartTime,Time rangeEndTime,Schedule_Time_Slot__c objSlot,String mapKey,Date startDate) {
        List<String> lstOfTimeSlot = new List<String>();
        Time startTime = objSlot.Start_time__c;
        Time endtime = objSlot.End_time__c;
        Date today = Date.today();
        // if (startDate == objSlot.sameDayBookingDate__c && Date.today() == objSlot.sameDayBookingDate__c) {
        //     startTime = startTime.addMinutes(objSlot.Time_Gap__c);
        // }
        lstOfTimeSlot = mapOfKeyVsTime.containsKey(mapKey) ? mapOfKeyVsTime.get(mapKey) : new List<String>();
        String mapKeyForTime = mapKey +'_'+ rangeStartTime;
        System.debug('rangeStartTime-->' + rangeStartTime + ' startTime-->' + startTime + ' rangeEndTime--->' + rangeEndTime + ' endtime-->' + endtime);
        System.debug('mapKeyForTime---->' + mapKeyForTime);
        Integer zoomIdCount = objSlot.Zoom_Id__c.contains(';') ? objSlot.Zoom_Id__c.split(';').size() : 1;
        //System.debug('objSlot.Zoom_Id__c.split().size()---->' +objSlot.Zoom_Id__c.split(';').size());
        Boolean isTimeValid = checkTimeDifferenceIsValid(rangeStartTime,rangeEndTime,endtime,Integer.valueOf(objSlot.Per_Call_Schedule_Minutes__c));
        //Integer totalTimeDifference = getDateTimeDifference(rangeStartTime,endtime);
        System.debug('Difference in minutes: ' + isTimeValid);
        System.debug('Integer.valueOf(objSlot.Per_Call_Schedule_Minutes__c)---->' + Integer.valueOf(objSlot.Per_Call_Schedule_Minutes__c));
        while (rangeStartTime >= startTime && rangeStartTime < rangeEndTime && rangeStartTime < endtime && isTimeValid) {
            if (!objVideoCall.mapOfKeyVsSlotAssigned.containsKey(mapKeyForTime)) {
                System.debug('mapKeyForTime12---->' + mapKeyForTime);
            }
            if (!objVideoCall.mapOfKeyVsSlotAssigned.containsKey(mapKeyForTime) 
            || (objVideoCall.mapOfKeyVsSlotAssigned.containsKey(mapKeyForTime) && objVideoCall.mapOfKeyVsSlotAssigned.get(mapKeyForTime) < zoomIdCount && objVideoCall.mapOfKeyVsSlotAssigned.get(mapKeyForTime) < objSlot.Total_Counselors__c)) 
            {
                Datetime dateTimeSlot = Datetime.newInstance(today, rangeStartTime);

                // Format the Datetime to display time in 12-hour format with AM/PM
                String formattedTime = dateTimeSlot.format('hh:mm a');
                if (!lstOfTimeSlot.contains(formattedTime)) {
                    lstOfTimeSlot.add(formattedTime);
                }
            }
            rangeStartTime = rangeStartTime.addMinutes(Integer.valueOf(objSlot.Per_Call_Schedule_Minutes__c));
            mapKeyForTime = mapKey + '_' + rangeStartTime;
            isTimeValid = checkTimeDifferenceIsValid(rangeStartTime,rangeEndTime,endtime,Integer.valueOf(objSlot.Per_Call_Schedule_Minutes__c));
            System.debug('Difference in minutes: ' + isTimeValid);
        }
        mapOfKeyVsTime.put(mapKey,lstOfTimeSlot);
        System.debug('lstTimeSot--->' + JSON.serialize(lstOfTimeSlot));
        System.debug('mapOfKeyVsTime---->' + JSON.serialize(mapOfKeyVsTime));
    }

    public Boolean checkTimeDifferenceIsValid(Time startTime,Time endTime,Time dayEndTime,Integer callMinutes) {
        Boolean isTimeValid = false;
        // Convert both times to seconds
        Integer startSeconds = startTime.hour() * 3600 + startTime.minute() * 60 + startTime.second();
        Integer endSeconds = endTime.hour() * 3600 + endTime.minute() * 60 + endTime.second();
        Integer dayEndSeconds = dayEndTime.hour() * 3600 + dayEndTime.minute() * 60 + dayEndTime.second();
        // Get difference in minutes
        Integer slotMinutesDiff = Integer.valueOf((endSeconds - startSeconds) / 60);
        Integer dayMinutesDiff = Integer.valueOf((dayEndSeconds - startSeconds) / 60);
        isTimeValid = slotMinutesDiff >= callMinutes && dayMinutesDiff >= callMinutes ? true : false;
        return isTimeValid;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getVideoCallDate() {
        getSchedulingVVCCall(this.objectId);
        List<SelectOption> lstDate = new List<SelectOption>();
        lstDate.add(new SelectOption('', 'Select Date'));
        if(mapOfDateVsTimeRange != null && !mapOfDateVsTimeRange.isEmpty()) {
            for (String callDate : mapOfDateVsTimeRange.keySet()) {
                lstDate.add(new SelectOption(callDate, callDate));
            }
        }
        System.debug('meeting date --> ' + lstDate);
        return lstDate;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @return List<SelectOption> 
    **/
    public void getVideoCallTimeRange() {
        List<SelectOption> lstTimeSlot = new List<SelectOption>();
        lstTimeSlot.add(new SelectOption('', 'Select Time Range'));
        System.debug('wrapper.meetingDate---->'  + wrapper.meetingDate);
        List<Map<String,String>> lstTimeRange = mapOfDateVsTimeRange.containsKey(wrapper.meetingDate) ? mapOfDateVsTimeRange.get(wrapper.meetingDate) : new List<Map<String,String>>();
        if(lstTimeRange.size()>0){
            for (Map<String, String> timeRange : lstTimeRange) {
                for (String mapKey : timeRange.keySet()) {
                    if(mapKey == 'timeRange') {
                        lstTimeSlot.add(new SelectOption(timeRange.get(mapKey), timeRange.get(mapKey)));
                    }
                }
            }
        }
        System.debug('metting time --> ' + lstTimeSlot);   
        videoCallTime = new List<SelectOption>();   
        videoCallTime.add(new SelectOption('', 'Select Time'));  
        videoCallTimeRange = lstTimeSlot;
    }

    public void getVideoCallTime() {
        System.debug('videocalltime');
        List<SelectOption> lstTimeOption = new List<SelectOption>();
        lstTimeOption.add(new SelectOption('', 'Select Time'));
        scheduleTimeSlotId = '';
        Boolean checkTimeRange = getScheduleTimeSlotId(false);
        System.debug('checkTimeRange--->' + checkTimeRange + 'scheduleTimeSlotId--->' + scheduleTimeSlotId);
        if (String.isNotBlank(scheduleTimeSlotId) && checkTimeRange) {
            String mapkey = wrapper.meetingDate +'_'+ wrapper.meetingTimeRange +'_'+ String.valueOf(scheduleTimeSlotId).left(15);
            System.debug('mapkey---->' + mapkey);
            List<String> lstTime = mapOfKeyVsTime.containsKey(mapkey) ? mapOfKeyVsTime.get(mapkey) : new List<String>();
            for (String timeSlot : lstTime) {
                lstTimeOption.add(new SelectOption(timeSlot,timeSlot));
            }
            System.debug('lstTimeOption---->' + lstTimeOption);
        }
        videoCallTime = lstTimeOption;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param startDateTime 
    * @param endDateTime 
    * @return String 
    **/
    public Static String timeRangeFormat(Datetime startDateTime, DateTime endDateTime) {
        Integer getStartHour = startDateTime.hour();
        Integer getEndHour = endDateTime.hour();
        String startHour = getStartHour > 12 ? getStartHour - 12 + ' pm' :
            getStartHour == 12 ? '12 pm' :
            getStartHour == 0 ? '12 am' :
            getStartHour + ' am';
        String endHour = getEndHour> 12 ? getEndHour - 12 + ' pm' : 
        getEndHour == 12 ? '12 pm' :
        getEndHour == 0 ? '12 am' :
        getEndHour + ' am';
        return startHour + ' - ' + endHour;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @return PageReference 
    **/
    public PageReference saveDetail(){
        try{
            Boolean checkGap = false;
            VideoCallSchedulingHandler objHandler = new VideoCallSchedulingHandler();
            VVC_Junction__c objVVC = new VVC_Junction__c();
            objVVC.Call_Date__c = Date.valueOf(wrapper.meetingDate);
            checkGap = checkTimeGap(objVVC);
            if(checkForSlotAvalialbility() && checkGap && String.isNotBlank(wrapper.meetingDate) && String.isNotBlank(wrapper.meetingTime) && String.isNotBlank(wrapper.meetingTimeRange)){
                System.debug('acc-->'+ objAccount);
                objVVC.Account__c = objAccount.Id;
                // objVVC.Call_Date__c = Date.valueOf(wrapper.meetingDate);
                objVVC.Time_Range__c = wrapper.meetingTimeRange;
                objVVC.Schedule_Time_Slot__c = scheduleTimeSlotId;
                objVVC.Status__c = 'Not Started';
                objVVC.Mobile_Number__c = wrapper.phoneNumber;
                objVVC.Student_Name__c = wrapper.firstName + ' ' +  wrapper.lastName;
                objVVC.Student_Email__c = wrapper.email;
                objVVC.Opportunity__c = objOpp.Id;
                objVVC.OwnerId = objAccount.OwnerId;
                System.debug('VVC_Junction__c-->'+ JSON.serialize(objVVC));
                System.debug('wrapper-->'+JSON.serialize(wrapper));
                String msg = objHandler.scheduleMeeting(objVVC,isReschedule,wrapper.meetingTime);
                if(String.isNotBlank(msg)) {
                    ErrorMessage(msg,'PopUpError');
                }
                else {
                    wrapper.isCallScheduled = true;
                    List<VVC_Junction__c> lstVVCRecord = getScheduledVVC();
                    formStatus = 'Slot Booked';
                    sectionHeader = 'SLOT DETAILS FOR VIDEO VERIFICATION CALL V2';
                    DateTime currentDt = System.now().addHours(24);
                    showReScheduleButton = objSlotBooked.Schedule_Call_Time__c > currentDt || objSlotBooked.Call_Date__c < Date.today() ? true : false;
                    ErrorMessage('Video Call Meeting Schedule Successfully!','Success');
                }
            }
            else{
                ErrorMessage('The selected slot is not available.','PopUpError');
            }

        }catch(Exception e) {
            System.debug('System error '+e);
            ErrorMessage('Something Went Wrong','PopUpError');
        }
        return null;
    }

    public Boolean checkTimeGap(VVC_Junction__c objVVC) {
        List<Schedule_Time_Slot__c> lstSTS = new List<Schedule_Time_Slot__c>();
        lstSTS = [SELECT Id,Time_Gap__c FROM Schedule_Time_Slot__c WHERE Id=:scheduleTimeSlotId LIMIT 1];
        Integer timeGap = Integer.valueOf(lstSTS[0].Time_Gap__c);
        getCallDateTime(objVVC,wrapper.meetingTime);
        //Datetime callDateTime = Datetime.newInstance(objVVC.Call_Date__c,time);
        if (timeGap == null || timeGap <= 0) {
            return true;
        }
        if (timeGap > 0 && System.now().addMinutes(timeGap) < objVVC.Schedule_Call_Time__c) {
            return true;
        }
        return false;
    }

    public void getCallDateTime(VVC_Junction__c objVVC,String callTime) {
        // Parse the time string to extract hours, minutes, and AM/PM
        List<String> timeParts = callTime.split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1].substring(0, 2));
        Boolean isPM = callTime.contains('PM');

        // Adjust hour for 12-hour to 24-hour conversion
        if (hour == 12 && !isPM) {
            hour = 0; // 12 AM case
        } else if (isPM && hour != 12) {
            hour += 12; // PM case but not 12 PM
        }

        // Create a Time object
        Time timeValue = Time.newInstance(hour, minute, 0, 0);

        // Combine the Date and Time into a Datetime
        objVVC.Schedule_Call_Time__c = Datetime.newInstance(objVVC.Call_Date__c, timeValue);

        System.debug('Datetime Value: ' + objVVC.Schedule_Call_Time__c);
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @return Boolean 
    **/
    public Boolean checkForSlotAvalialbility(){
        System.debug('recordId-->'+ this.objectId);
        getSchedulingVVCCall(this.objectId);
        scheduleTimeSlotId = '';
        return getScheduleTimeSlotId(true);
    }

    public Boolean getScheduleTimeSlotId(Boolean checkAvaliability) {
        Boolean status = false;
        System.debug('mapOfDateVsTimeRange.isEmpty()--->' + mapOfDateVsTimeRange.isEmpty() + wrapper.meetingDate);
        if(mapOfDateVsTimeRange != null && !mapOfDateVsTimeRange.isEmpty() && wrapper.meetingDate!=null){
            List<Map<String,String>> lstTimeRange = mapOfDateVsTimeRange.containsKey(wrapper.meetingDate) ? mapOfDateVsTimeRange.get(wrapper.meetingDate) : new List<Map<String,String>>();
            System.debug('timeRange-->'+JSON.serialize(lstTimeRange));
            if(lstTimeRange.size()>0){
                for(Map<String, String> timeRange : lstTimeRange) {
                    if(timeRange.containsKey('timeRange') && timeRange.get('timeRange') == wrapper.meetingTimeRange){
                        status = true;
                        scheduleTimeSlotId = timeRange.get('schedulingId');
                    }
                }
            } 
        }
        if (!checkAvaliability) {
            return status;
        }

        String mapkey = wrapper.meetingDate +'_'+ wrapper.meetingTimeRange +'_'+ String.valueOf(scheduleTimeSlotId).left(15);
        System.debug('mapkey2---->' + mapkey);
        List<String> lstTime = mapOfKeyVsTime.containsKey(mapkey) ? mapOfKeyVsTime.get(mapkey) : new List<String>();
        status = lstTime.size() > 0 && lstTime.contains(wrapper.meetingTime) ? true : false;
        return status;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    **/
    public void checkReschedule() {
        System.debug('reschedule');
        DateTime currentDt = System.now().addHours(24);
        if (objSlotBooked.Schedule_Call_Time__c > currentDt || objSlotBooked.Call_Date__c < Date.today()) {
            ZoomWebService objService = new ZoomWebService();
            String token = objService.getAccessToken();
            Boolean isDeleted = objService.deleteMeeting(objSlotBooked.Meeting_Id__c, token);
            if (Test.isRunningTest()) {
                isDeleted = true;
            }
            if (isDeleted) {
                objSlotBooked.Status__c = 'Not Connected';
                objSlotBooked.ZoomId_Key__c = '';
                objSlotBooked.Agent_Key__c = '';
                objSlotBooked.is_Call_Cancel__c = true;
                update objSlotBooked;
        
                objSlotBooked = new VVC_Junction__c();
                formStatus = 'Pending (Needs Re-booking)';
                sectionHeader = 'VIDEO VERIFICATION FORM DETAILS';
                wrapper.meetingTimeRange = '';
                wrapper.meetingDate = '';
                wrapper.meetingTime = '';
                message = 'Meeting Cancel Successfully. You can Re-Schedule!';
                strSecToShow = 'Success';
                isReschedule = true;
            }
            else {
                ErrorMessage('Try Again! Unable to cancel meeting','PopUpError');
            }
        }
        else {
            ErrorMessage('You cannot Re-Schedule meeting, Scheduled Meeting is less than 24 hours.','PopUpError');
        }
        
    }

    // public void handelDateChange() {
    //     wrapper.meetingTime = '';
    //     wrapper.meetingTimeRange = '';
    // }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param callDateTime 
    **/
    public void formatDateTime(Datetime callDateTime) {
        System.debug('callDateTime--->' + callDateTime);
        Datetime now = System.now();
        newTime = callDateTime.addMinutes(5);
        System.debug(newTime);
    }

    public class ObjWrapper {
        
        public objWrapper(){
            this.firstName = firstName;
            this.lastName = lastName;
            this.programName = programName;
            this.phoneNumber = phoneNumber;
            this.email = email;
            this.meetingDate = meetingDate;
            this.meetingTimeRange = meetingTimeRange;
            this.meetingTime = meetingTime;
            this.isScheduleCallTimeNull = isScheduleCallTimeNull;
            this.errorMsg = '';
            this.isCallScheduled = false;
        }

        public ObjWrapper(Account acc){
            if(acc!=null) {
                firstName = acc.FirstName;
                lastName = acc.LastName;
                programName = acc.nm_Program__r.Name;
                phoneNumber = acc.PersonMobilePhone;
                email = acc.PersonEmail;
            }
        }

        public String firstName{get;set;}
        public String lastName{get;set;}
        public String programName{get;set;}
        public String phoneNumber{get;set;}
        public String email{get;set;}
        public String meetingDate{get;set;}
        public String meetingTimeRange{get;set;}
        public String meetingTime{get;set;}
        public Boolean isScheduleCallTimeNull{get;set;}
        public String errorMsg {get;set;}
        public Boolean isCallScheduled {get;set;}
    }

    public class VideoCallWrapper {
        public Map<String,Integer> mapOfTimeRangeVsAssignedStudent {get;set;}
        public Map<String,Integer> mapOfKeyVsSlotAssigned {get;set;}

        public VideoCallWrapper() {
            mapOfTimeRangeVsAssignedStudent = new Map<String,Integer>();
            mapOfKeyVsSlotAssigned = new Map<String,Integer>();
        }
    }
}