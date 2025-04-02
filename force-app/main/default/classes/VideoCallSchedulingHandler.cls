/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-24-2025
 * @last modified by  : @vickysahu
**/
public class VideoCallSchedulingHandler {
    // For Not Started
    //public Map<String,AllowedStudentDetails> mapOfTimeRangeVsStudents = new Map<String,AllowedStudentDetails>();
    
    // Map for created meeeting of VVC and meeting id
    //public Map<String,String> mapOfTaskIdVsMeetingId = new Map<String,String>();
    
    // public Map<String,List<String>> mapOfExistingTimeSlotVsLstOfCouncellors = new Map<String,List<String>>();
    
    public List<VVC_Junction__c> lstOfScheduledCalls = new List<VVC_Junction__c>();
    //String videoCallKey = '';
    Schedule_Time_Slot__c objScheduling = new Schedule_Time_Slot__c();
    Map<String,Integer> mapNameVsCount = new Map<String,Integer>();
    Map<String,List<String>> mapOfKeyVsLstOfCouncellors = new Map<String,List<String>>();
    List<String> lstZoomIds = new List<String>();
    String msg = '';
    private String token = '';

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objVVC 
    * @return String 
    **/
    public String scheduleMeeting(VVC_Junction__c objVVC,Boolean isReschedule,String callTime) {
        ZoomWebService objService = new ZoomWebService();
        objScheduling = [SELECT Id,Start_time__c,End_time__c,Total_Counselors__c,Per_Call_Schedule_Minutes__c,Start_date__c,End_date__c,Selected_Counselors__c,Zoom_Id__c FROM Schedule_Time_Slot__c WHERE RecordType.Name = 'Video Call' AND IsActive__c=true AND End_date__c>=TODAY AND Id =:objVVC.Schedule_Time_Slot__c LIMIT 1];
        // videoCallKey = objVVC.Call_Date__c.year() + '-' + String.valueOf(objVVC.Call_Date__c.month()).leftPad(2, '0') + '-' + String.valueOf(objVVC.Call_Date__c.day()).leftPad(2, '0') + '_' + objVVC.Time_Range__c + '_' + String.valueOf(objVVC.Schedule_Time_Slot__c).left(15);
        // System.debug('videoCallKey===>' + videoCallKey);
        token = objService.getAccessToken();
        //getCallDateTime(objVVC,callTime);
        getExisitingCalls(objVVC,callTime);
       
        
        // if (objVVC.Status__c == 'Not Started' && mapOfTimeRangeVsStudents.containsKey(videoCallKey)) { 
        //     System.debug('Time_Range__c===>' + objVVC.Time_Range__c);
        //     handleCallScheduling(objVVC);            
        // }
       
        // VideoCallSchedulingForZoomId objCall = new VideoCallSchedulingForZoomId();
        // mapOfTimeRangeVsStudents = objCall.addZoomIdInMap(mapOfTimeRangeVsStudents,objVVC,objScheduling.Zoom_Id__c,videoCallKey,token);
        // System.debug('mapOfTimeRangeVsStudents after zoomId===>' + mapOfTimeRangeVsStudents);

        // VideoCallSchedulingHandler.AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(videoCallKey);
        // List<VideoCallSchedulingHandler.StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
        // VideoCallSchedulingHandler.StudentDetails studentDetails = new VideoCallSchedulingHandler.StudentDetails();
        // for(VideoCallSchedulingHandler.StudentDetails objSD : lstStudentDetails) {
        //     if(objSD.alreadyScheduled == false) {
        //         studentDetails = objSD;
        //     }
        // }
        System.debug('Video Call record===>' + JSON.serialize(objVVC));
        String agentKey = objVVC.Schedule_Call_Time__c + '_' + objVVC.Agent_Name__c;
        String  zoomIdKey = objVVC.Schedule_Call_Time__c + '_' + objVVC.Zoom_User_Id__c;
        System.debug('agentKey====>' + agentKey);
        System.debug('zoomIdKey====>' + zoomIdKey);
        List<VVC_Junction__c> lst = [SELECT Id,Schedule_Call_Time__c,Zoom_User_Id__c,Agent_Key__c,ZoomId_Key__c FROM VVC_Junction__c WHERE Agent_Key__c =:agentKey OR ZoomId_Key__c =:zoomIdKey];
        if(objVVC != null && lst.size() == 0) {
            List<VVC_Junction__c> lstVVC = [SELECT Id FROM VVC_Junction__c WHERE Status__c='In Progress' AND Call_Date__c>=TODAY AND Account__c=:objVVC.Account__c];
            if (lstVVC.size() > 0) {
                msg = 'Slot is alerady Booked';
                return msg;
            }
            callApiToCreateMeeting(objVVC,isReschedule);
        }
        else {
            System.debug('slot is full try another slot');
            msg = 'Slot is full.Kindly try another slot';
        }
        return msg;
    }

    // public Datetime getCallDateTime(VVC_Junction__c objVVC,String callTime) {
    //     // Parse the time string to extract hours, minutes, and AM/PM
    //     List<String> timeParts = callTime.split(':');
    //     Integer hour = Integer.valueOf(timeParts[0]);
    //     Integer minute = Integer.valueOf(timeParts[1].substring(0, 2));
    //     Boolean isPM = callTime.contains('PM');

    //     // Adjust hour for 12-hour to 24-hour conversion
    //     if (hour == 12 && !isPM) {
    //         hour = 0; // 12 AM case
    //     } else if (isPM && hour != 12) {
    //         hour += 12; // PM case but not 12 PM
    //     }

    //     // Create a Time object
    //     Time timeValue = Time.newInstance(hour, minute, 0, 0);

    //     // Combine the Date and Time into a Datetime
    //     objVVC.Schedule_Call_Time__c = Datetime.newInstance(objVVC.Call_Date__c, timeValue);

    //     System.debug('Datetime Value: ' + objVVC.Schedule_Call_Time__c);
    // }

    public void getExisitingCalls(VVC_Junction__c objVVC,String callTime) { 
        lstOfScheduledCalls = [SELECT id,Time_Range__c,Zoom_User_Id__c,Student_Name__c,Schedule_Time_Slot__c,Account__c,Mobile_Number__c,Call_Date__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c FROM VVC_Junction__c WHERE  Call_Date__c=:objVVC.Call_Date__c AND Time_Range__c=:objVVC.Time_Range__c AND Schedule_Call_Time__c!=null AND Status__c = 'In Progress']; 
        System.debug('lstOfScheduledCalls ==>'+lstOfScheduledCalls.size());
        List<String> lstCouncellorsInSTS = new List<String>();
        lstCouncellorsInSTS = String.isNotBlank(objScheduling.Selected_Counselors__c) ? objScheduling.Selected_Counselors__c.split(';') : new List<String>();
        // Map<String,Integer> mapNameVsCount = getInitializedCousellors();
        // Map<String,List<String>> mapOfKeyVsLstOfCouncellors = new Map<String,List<String>>();
        getInitializedCousellors();
        lstZoomIds = shuffleList(objScheduling.Zoom_Id__c);
    
        for(VVC_Junction__c obj : lstOfScheduledCalls) {
            String mapkey = obj.Time_Range__c +'_'+obj.Schedule_Call_Time__c;
            System.debug('mapkey---->' + mapkey);
            List<String> lstCouncellors = new List<String>();
            lstCouncellors = mapOfKeyVsLstOfCouncellors.containsKey(mapkey) ? mapOfKeyVsLstOfCouncellors.get(mapkey) : new List<String>();
            lstCouncellors.add(obj.Agent_Name__c);
            mapOfKeyVsLstOfCouncellors.put(mapkey,lstCouncellors);
            Integer count = 0;
            //count = mapNameVsCount.containsKey(obj.Agent_Name__c) ? mapNameVsCount.get(obj.Agent_Name__c) : 0;
            if (lstCouncellorsInSTS.size() > 0 && lstCouncellorsInSTS.contains(obj.Agent_Name__c)) {
                count = mapNameVsCount.get(obj.Agent_Name__c);
                mapNameVsCount.put(obj.Agent_Name__c, count+1);
                System.debug('mapNameVsCount---->' + JSON.serialize(mapNameVsCount));
            }
            if (objVVC.Call_Date__c == obj.Call_Date__c && objVVC.Schedule_Call_Time__c == obj.Schedule_Call_Time__c && lstZoomIds.contains(obj.Zoom_User_Id__c)) {
                lstZoomIds.remove(lstZoomIds.indexOf(obj.Zoom_User_Id__c));
            }
            System.debug('objVVC.Call_Date__c---->' + objVVC.Call_Date__c + 'obj.Call_Date__c--->' + obj.Call_Date__c + 'objVVC.Schedule_Call_Time__c--->' + objVVC.Schedule_Call_Time__c + 'obj.Schedule_Call_Time__c--->' + obj.Schedule_Call_Time__c);
        }
        List<CounsellorCountWrapper> lstWrapper = new List<CounsellorCountWrapper>();
        for(String cs: mapNameVsCount.keyset()) {
            lstWrapper.add(new CounsellorCountWrapper(cs, mapNameVsCount.get(cs)));  
        }
        lstWrapper.sort();
        System.debug('lstWrapper====>' + lstWrapper);
        assignAvailableZoomIdAndCouncellors(lstWrapper,objVVC);
    }

    public void assignAvailableZoomIdAndCouncellors(List<CounsellorCountWrapper> lstWrapper,VVC_Junction__c objVVC) {
        for (CounsellorCountWrapper objWrapper : lstWrapper) {
            String mapKey = objVVC.Call_Date__c +'_'+ objVVC.Schedule_Call_Time__c;
            System.debug('mapKey1---->' + mapKey);
            objVVC.Agent_Name__c = '';
            if (mapOfKeyVsLstOfCouncellors.containsKey(mapKey)) {
                List<String> lstCouncellors = new List<String>();
                lstCouncellors = mapOfKeyVsLstOfCouncellors.get(mapKey);
                Boolean checkForCouncellor = lstCouncellors.contains(objWrapper.counselor) ? true : false;
                if (checkForCouncellor) {
                    continue;
                } 
            }
            objVVC.Agent_Name__c = objWrapper.counselor;
            break;
        }
        assignAvailableZoomId(objVVC);
    }

    public void assignAvailableZoomId(VVC_Junction__c objVVC) {
        if (String.isNotBlank(objVVC.Agent_Name__c)) {
            Map<String,ScheduledMettingsWrapper> mapOfZoomIdVsWrapper = new Map<String,ScheduledMettingsWrapper>();
            ZoomWebService objWebService = new ZoomWebService();
            for(String zoomId : lstZoomIds) {
                String minDate = objVVC.Call_Date__c.year() + '-' + String.valueOf(objVVC.Call_Date__c.month()).leftPad(2, '0') + '-' + String.valueOf(objVVC.Call_Date__c.day()).leftPad(2, '0');
                ScheduledMettingsWrapper objScheduled = mapOfZoomIdVsWrapper.containsKey(zoomId) ? mapOfZoomIdVsWrapper.get(zoomId) : objWebService.getListOfScheduledMeetings(minDate,minDate,300,zoomId,token);
                System.debug('objScheduled===>' + objScheduled);
                if(objScheduled != null && objScheduled.page_size > 0) {
                    List<ScheduledMettingsWrapper.Meetings> lstMeetingsData = objScheduled.meetings;
                    Boolean isMeetingScheduled = false;
                    Datetime callStartTime = objVVC.Schedule_Call_Time__c;
                    Datetime callEndTime = objVVC.Schedule_Call_Time__c.addMinutes(Integer.valueOf(objScheduling.Per_Call_Schedule_Minutes__c));
                    System.debug('taskStartTime===>' + callStartTime.format('yyyy-MM-dd HH:mm:ss') + ' ' + 'taskEndTime===>' + callEndTime.format('yyyy-MM-dd HH:mm:ss'));
                    if(!mapOfZoomIdVsWrapper.containsKey(zoomId)) {
                        mapOfZoomIdVsWrapper.put(zoomId, objScheduled);
                    }
                    if(lstMeetingsData != null) {
                        for(ScheduledMettingsWrapper.Meetings meeting : lstMeetingsData) {
                            String dateStr = meeting.start_time;
                            Datetime meetingStartTime = (DateTime)JSON.deserialize('"' + dateStr + '"', DateTime.class);
                            // DateTime meetingStartTime = dateTime.valueOf(dateStr.replace('T',' '));
                            Datetime meetingEndTime = meetingStartTime.addMinutes(meeting.duration);
                            System.debug('meetingStartTime===>' + meetingStartTime.format('yyyy-MM-dd HH:mm:ss') + ' ' + 'meetingEndTime===>' + meetingEndTime.format('yyyy-MM-dd HH:mm:ss'));
    
                            if ((callStartTime >= meetingStartTime && callStartTime < meetingEndTime) || (meetingStartTime < callEndTime && meetingEndTime >= callEndTime)) {
                                isMeetingScheduled = true;
                                break;
                            }
                        }
                    }
                    
                    if (!isMeetingScheduled) {
                        // Schedule the meeting here
                        System.debug('Scheduling a meeting...');
                        objVVC.Zoom_User_Id__c = zoomId;
                        break;
                    }
                }
            } 
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objVVC 
    * @param token 
    **/
    public void callApiToCreateMeeting(VVC_Junction__c objVVC,Boolean isReschedule) {
        // AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(videoCallKey);
        // List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
        // StudentDetails studentDetails = new StudentDetails();
        String scheduleStartDateTme = '';
        String scheduleEndDateTme = '';
        String topic = 'Video Verification';
        String agenda = 'Video Verification Survey';
       
        Integer duration = Integer.valueOf(objScheduling.Per_Call_Schedule_Minutes__c);
        
        if(objVVC != null && objVVC.Schedule_Call_Time__c != null && String.isNotBlank(objVVC.Agent_Name__c) && String.isNotBlank(objVVC.Zoom_User_Id__c)) {
            scheduleStartDateTme =  objVVC.Schedule_Call_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss', 'IST');

            ZoomWebService objWebService = new ZoomWebService();
            Map<String,String> mapOfJoinURLS = objWebService.createMeeting(scheduleStartDateTme,topic,agenda,objVVC.Zoom_User_Id__c,false,duration,'cloud',token);
            if(mapOfJoinURLS.containsKey('Error')) {
                System.debug('Create Zoom Meeting Failed');
                objVVC.Schedule_Call_Time__c = null;
                msg = 'Some thing went wrong, Please Try Again!';
            }else{
                objVVC.Zoom_Url__c = mapOfJoinURLS.get('join_url');
                objVVC.Host_Joining_Link__c = mapOfJoinURLS.get('start_url');
                objVVC.Meeting_Id__c = mapOfJoinURLS.get('meetingid');
                objVVC.Zoom_User_Id__c = mapOfJoinURLS.get('ZoomUserId');
                String scheduledTime = (String) mapOfJoinURLS.get('start_time');
                Datetime dt = (DateTime)JSON.deserialize('"' + scheduledTime + '"', DateTime.class);
                objVVC.Schedule_Call_Time__c = dt;
                //objVVC.Agent_Name__c = studentDetails.councellorName;
                objVVC.Call_duration__c = Decimal.valueOf(mapOfJoinURLS.get('duration'));
                objVVC.Status__c = 'In Progress';
            }
        }
        else {
            System.debug('Slot is full, try another');
            msg = 'Slot is full.Kindly try another slot.';
        }
               

        if(objVVC != null && String.isNotBlank(objVVC.Zoom_Url__c)) {
            try {
                String agentKey = objVVC.Schedule_Call_Time__c + '_' + objVVC.Agent_Name__c;
                String  zoomIdKey = objVVC.Schedule_Call_Time__c + '_' + objVVC.Zoom_User_Id__c;
                System.debug('agentKey====>' + agentKey);
                System.debug('zoomIdKey====>' + zoomIdKey);
                List<VVC_Junction__c> lst = [SELECT Id,Schedule_Call_Time__c,Zoom_User_Id__c FROM VVC_Junction__c WHERE Agent_Key__c =:agentKey OR ZoomId_Key__c =:zoomIdKey];
                if(lst.size() > 0) {
                    System.debug('Slot is full try another Slot');
                    callDeleteZoomMeeting(objVVC);
                    msg = 'Slot is full.Kindly try another slot.';
                    return;
                }
                objVVC.Agent_Key__c = agentKey;
                objVVC.ZoomId_Key__c = zoomIdKey;
                insert objVVC;

                //Create VVCJuntion record
                // VVC_Junction__c objJunction = new VVC_Junction__c();
                // objJunction.Account__c = objTask.WhatId;
                // objJunction.Opportunity__c = objTask.Opportunity__c;
                // objJunction.Status__c = 'In Progress';
                // objJunction.OwnerId = objTask.OwnerId;
                // objJunction.Call_Date__c = objTask.Call_date__c;
                // objJunction.Schedule_Call_Time__c = objTask.Schedule_Call_Time__c;
                // insert objJunction;

                // Task obj = new Task();
                // obj.Id = objTask.Id;
                // obj.VVC_Junction__c = objJunction.Id;
                // update obj;

                // if (objTask.Customer_number__c != null && System.Label.Enable_SMS_Service == 'Yes') {
                //     String smsMessage = '10100' +' is your verification code for NMIMS CDOE.';
                //     OTPVerificationHandler.sendSMS sendSMS = new OTPVerificationHandler.sendSMS(objTask.Customer_number__c.left(10),smsMessage);
                //     // enqueue the job for processing
                //     Id jobID = System.enqueueJob(sendSMS);
                //     System.debug('jobID -->'+jobID);
                // }
                
            } catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
                callDeleteZoomMeeting(objVVC);
                System.debug('Insert Failed====>' + e.getMessage());
                msg = 'Slot is full.Kindly try another slot.';
                return;
            }
            Map<String, Object> params = new Map<String, Object>();
            params.put('objVVC', objVVC);
            params.put('isReschedule', isReschedule);
            Flow.Interview.Send_Email_to_student_for_Video_Verification objFlow = new Flow.Interview.Send_Email_to_student_for_Video_Verification(params);
            objFlow.start();
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objVVC 
    * @param token 
    **/
    public void callDeleteZoomMeeting(VVC_Junction__c objVVC) {
        // To delete the failed zoom meetings.
        if(objVVC != null && String.isNotBlank(objVVC.Meeting_Id__c)) {
            ZoomWebService obj = new ZoomWebService();
            Boolean status = obj.deleteMeeting(objVVC.Meeting_Id__c,token);
            String str = status == true ? 'Successfully deleted Meeting' : 'Failed to delete Meeting';
            System.debug('Zoom Delete status===>' + str);
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objVVC 
    * @param timeRangeVsStudents 
    * @param lst 
    * @return Map<String, AllowedStudentDetails> 
    **/
    /*public Map<String,AllowedStudentDetails> addOrgainizerInMap(VVC_Junction__c objVVC,Map<String,AllowedStudentDetails> timeRangeVsStudents,List<VVC_Junction__c> lst) {
        mapOfTimeRangeVsStudents = timeRangeVsStudents;
        videoCallKey = objVVC.Call_Date__c.year() + '-' + String.valueOf(objVVC.Call_Date__c.month()).leftPad(2, '0') + '-' + String.valueOf(objVVC.Call_Date__c.day()).leftPad(2, '0') + '_' + objVVC.Time_Range__c + '_' + String.valueOf(objVVC.Schedule_Time_Slot__c).left(15);
        System.debug('videoCallKey===>' + videoCallKey);
        AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(videoCallKey);
        List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
        StudentDetails studentDetails = new StudentDetails();
        for(StudentDetails objSD : lstStudentDetails) {
            if(objSD.alreadyScheduled == false) {
                studentDetails = objSD;
            }
        }
        String mapKey = objVVC.Call_Date__c + '_' + studentDetails.scheduleTime + '_' + String.valueOf(objVVC.Schedule_Time_Slot__c).left(15);
        System.debug('mapkey===>' + mapKey);
        // Map<String,List<String>> mapOfKeyVsCounsellor = mapOfExistingTimeSlotVsLstOfCouncellors.containsKey(mapKey) ? mapOfExistingTimeSlotVsLstOfCouncellors.get(mapKey) : new Map<String,List<String>>();
        
        if(lstStudentDetails.size() > 0) {
            Map<String,Integer> mapNameVsCount = new Map<String,Integer>();
            List<String> lstCouncellors = shuffleList(lstStudentDetails[0].selectedCouncellors);
            mapNameVsCount = getInitializedCousellors(lstCouncellors); 
            mapNameVsCount = getExistingCounsellors(objVVC,mapNameVsCount,lst);
            System.debug('mapOfExistingTimeSlotVsLstOfCouncellors===>' + mapOfExistingTimeSlotVsLstOfCouncellors);
            List<CounsellorCountWrapper> lstWrapper = new List<CounsellorCountWrapper>();
            for(String cs: mapNameVsCount.keyset()) {
                lstWrapper.add(new CounsellorCountWrapper(cs, mapNameVsCount.get(cs)));  
            }
            lstWrapper.sort();
            System.debug('lstWrapper====>' + lstWrapper);
            List<String> lstCounsellors = mapOfExistingTimeSlotVsLstOfCouncellors.containsKey(mapKey) ? mapOfExistingTimeSlotVsLstOfCouncellors.get(mapKey) : new List<String>();
            System.debug('lstCounsellors====>' + lstCounsellors);
            for (CounsellorCountWrapper wrapper : lstWrapper) {
                if (lstCounsellors == null || !lstCounsellors.contains(wrapper.counselor)) {
                    studentDetails.councellorName = wrapper.counselor;
                    System.debug('name===>' + wrapper.counselor);
                    break;
                }
            }
        }
        return mapOfTimeRangeVsStudents;
    }*/

    public List<String> shuffleList(String shuffleStr) {
        List<String> lstOfStr = new List<String>();
        System.debug('shuffleStr--->' + shuffleStr);
        if (shuffleStr.contains(';')) {
            lstOfStr = shuffleStr.split(';'); // Assign the result of split
        } else {
            lstOfStr.add(shuffleStr); // Add the single string to the list
            return lstOfStr;
        }
        Integer n = lstOfStr.size();
        Integer i = 0;

        while (i < n) {
            Integer j = i + (Math.random() * (n - i)).intValue();
            // Swap elements at indices i and j
            String temp = lstOfStr[i];
            lstOfStr[i] = lstOfStr[j];
            lstOfStr[j] = temp;
            i++;
        }
        return lstOfStr;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param lstCouncellors 
    * @return Map<String, Integer> 
    **/
    public void getInitializedCousellors() {
        List<String> lstCouncellors = shuffleList(objScheduling.Selected_Counselors__c);
        //Map<String,Integer> mapOfCoun = new Map<String,Integer>();
        for(String coun : lstCouncellors) {
            mapNameVsCount.put(coun, 0);
        }
        System.debug('mapNameVsCount---->' + JSON.serialize(mapNameVsCount));
        //return mapOfCoun;
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objSchedulingCall 
    * @param mapNameVsCount 
    * @param lstVCC 
    * @return Map<String, Integer> 
    **/
    /*public Map<String,Integer> getExistingCounsellors(VVC_Junction__c objSchedulingCall,Map<String,Integer> mapNameVsCount,List<VVC_Junction__c> lstVCC) {
        if(lstVCC.size() > 0 ) {
            for(VVC_Junction__c objVCC : lstVCC) {
                if(objVCC.Time_Range__c == objSchedulingCall.Time_Range__c) {
                    // String mapKey = objTask.Call_date__c + '_' + objTask.Call_Scheduled_Time__c + '_' + String.valueOf(objTask.Schedule_Time_Slot__c).left(15);
                    String mapKey = objVCC.Call_Date__c + '_' + objVCC.Schedule_Call_Time__c + '_' + String.valueOf(objVCC.Schedule_Time_Slot__c).left(15);
                    System.debug('mapkey===>' + mapKey);
                    List<String> lstCouncellorsName = mapOfExistingTimeSlotVsLstOfCouncellors != null && mapOfExistingTimeSlotVsLstOfCouncellors.containsKey(mapKey) ? mapOfExistingTimeSlotVsLstOfCouncellors.get(mapKey) : new List<String>();
                    lstCouncellorsName.add(objVCC.Agent_Name__c);
                    mapOfExistingTimeSlotVsLstOfCouncellors.put(mapKey, lstCouncellorsName);
                    System.debug('mapOfExistingTimeSlotVsLstOfCouncellors-->' + mapOfExistingTimeSlotVsLstOfCouncellors);
                    Integer count = mapNameVsCount.containsKey(objVCC.Agent_Name__c) ? mapNameVsCount.get(objVCC.Agent_Name__c) : 0;
                    mapNameVsCount.put(objVCC.Agent_Name__c, count + 1);
                }
            }
        }
        return mapNameVsCount;
    }*/

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objVVC 
    **/
    /*public void handleCallScheduling(VVC_Junction__c objVVC) {
        AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(videoCallKey);
        List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
        StudentDetails studentDetails = new StudentDetails();
        studentDetails.mobileNo = objVVC.Mobile_Number__c;
        studentDetails.name = objVVC.Student_Name__c;
        studentDetails.selectedCouncellors = objScheduling.Selected_Counselors__c;
        studentDetails.recordId = objVVC.Account__c;
        lstStudentDetails.add(studentDetails);
        allStudentDetails.lstStudentDetails = lstStudentDetails;
        mapOfTimeRangeVsStudents.put(videoCallKey, allStudentDetails); 
    }*/

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param objVVC 
    **/
    /*public void getExisitingCalls(VVC_Junction__c objVVC) {
        Set<String> setOfCallScheduledKeys = new Set<String>();
        Map<String,Map<String,String>> mapOfKeyVsMapOfCallScheduleDetails = new Map<String,Map<String,String>>();
        
        if (objVVC.Status__c == 'Not Started') {
            System.debug('timeRangeKey --> ' + videoCallKey);
            if(!setOfCallScheduledKeys.contains(videoCallKey)) {
                setOfCallScheduledKeys.add(videoCallKey);
                Map<String,String> mapOfCallScheduleDetails = new Map<String,String> {
                    'Per_Call_Schedule_Minutes__c' => String.valueOf(objScheduling.Per_Call_Schedule_Minutes__c),
                    'Total_Counselors__c' => String.valueOf(objScheduling.Total_Counselors__c),
                    'Time_Range__c' => objVVC.Time_Range__c,
                    'Call_date__c' => String.valueOf(objVVC.Call_Date__c)
                };
                mapOfKeyVsMapOfCallScheduleDetails.put(videoCallKey,mapOfCallScheduleDetails);
            }
        }
        System.debug('mapOfKeyVsMapOfCallScheduleDetails===>' + mapOfKeyVsMapOfCallScheduleDetails);

        if(setOfCallScheduledKeys.size() > 0) {
            getCallDetails(mapOfKeyVsMapOfCallScheduleDetails);

            lstOfScheduledCalls = [SELECT id,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Account__c,Mobile_Number__c,Call_Date__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c FROM VVC_Junction__c WHERE Video_Call_Scheduled_Key__c IN :setOfCallScheduledKeys AND Schedule_Call_Time__c!=null AND Status__c = 'In Progress'];
            System.debug('lstOfScheduledCalls ==>'+lstOfScheduledCalls.size());
            for(VVC_Junction__c obj :lstOfScheduledCalls) {
                if(mapOfTimeRangeVsStudents.containsKey(obj.Video_Call_Scheduled_Key__c)) {
                    AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(obj.Video_Call_Scheduled_Key__c);
                    List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
                    StudentDetails studentDetails = new StudentDetails();
                    studentDetails.mobileNo = obj.Mobile_Number__c;
                    studentDetails.name = obj.Student_Name__c;
                    studentDetails.scheduleTime = obj.Schedule_Call_Time__c;
                    studentDetails.vvcId = obj.id;
                    studentDetails.recordId = obj.Account__c;
                    studentDetails.alreadyScheduled = true;
                    studentDetails.councellorName = obj.Agent_Name__c;
                    studentDetails.selectedCouncellors = obj.Schedule_Time_Slot__r.Selected_Counselors__c;
                    lstStudentDetails.add(studentDetails);
                    allStudentDetails.lstStudentDetails = lstStudentDetails;
                    allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                    if(allStudentDetails.mapOfDateTimeVsCount.containsKey(studentDetails.scheduleTime)) {
                        Integer count = allStudentDetails.mapOfDateTimeVsCount.get(studentDetails.scheduleTime) + 1;
                        allStudentDetails.mapOfDateTimeVsCount.put(studentDetails.scheduleTime, count);
                    }
                    System.debug('Existing-->'+ JSON.serialize(allStudentDetails.mapOfDateTimeVsCount));
                    mapOfTimeRangeVsStudents.put(obj.Video_Call_Scheduled_Key__c, allStudentDetails);
                }
            }
        }
    }*/

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param mapOfKeyVsMapOfCallScheduleDetails 
    **/
    /*public void getCallDetails(Map<String,Map<String,String>> mapOfKeyVsMapOfCallScheduleDetails) {
        for (String mapKey : mapOfKeyVsMapOfCallScheduleDetails.keySet()) {
            AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.containsKey(mapKey) ? mapOfTimeRangeVsStudents.get(mapKey) : new AllowedStudentDetails();
            Map<String,String> mapOfCallScheduleDetails = mapOfKeyVsMapOfCallScheduleDetails.get(mapKey);

            allStudentDetails.callPerMinute = Integer.valueOf(mapOfCallScheduleDetails.get('Per_Call_Schedule_Minutes__c'));
            allStudentDetails.maxCallPerHour = Integer.valueOf((60/allStudentDetails.callPerMinute) *Integer.valueOf(mapOfCallScheduleDetails.get('Total_Counselors__c')));
            allStudentDetails.totalCounselors = Integer.valueOf(mapOfCallScheduleDetails.get('Total_Counselors__c'));
            Integer callPerMinute = allStudentDetails.callPerMinute;
            Date callDate = Date.valueOf(mapOfCallScheduleDetails.get('Call_date__c'));
            Integer getHours = getHours(mapOfCallScheduleDetails.get('Time_Range__c'));
            Map<DateTime, Integer> mapOfDateTimeVsCount = new Map<DateTime, Integer>();
            for (Integer i = 0; i < allStudentDetails.maxCallPerHour; i++) {
                Integer getMinutes = (i * callPerMinute) > 60 ? callPerMinute : (i * callPerMinute == 60 ? 0 : i * callPerMinute);
                mapOfDateTimeVsCount.put(DateTime.newInstance(callDate.year(), callDate.month(), callDate.day(), getHours, getMinutes, 0), 0);
            }
            System.debug('mapOfDateTimeVsCount--->'+ mapOfDateTimeVsCount);
            // allStudentDetails.maxCallPerTime = allStudentDetails.maxCallPerHour / mapOfDateTimeVsCount.size();
            allStudentDetails.mapOfDateTimeVsCount = mapOfDateTimeVsCount;
            System.debug('allStudentDetails ==================>');
            System.debug(allStudentDetails);
            mapOfTimeRangeVsStudents.put(mapKey,allStudentDetails);
        }
    }*/

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param timeRange 
    * @return Integer 
    **/
    /*public Integer getHours(String timeRange) {
        String startTimeStr = timeRange.split('-')[0];
        List<String> lstSplitOfTime = startTimeStr.split(' ');
        Integer hoursTime = Integer.valueOf(lstSplitOfTime[0].trim());
        
        // to convert hrs in 24 format.
        Integer callTime = lstSplitOfTime[1].trim() == 'am' ? (hoursTime == 12 ? 0 : hoursTime) : (hoursTime == 12 ? 12 : hoursTime + 12);
        return callTime;
    }

    public class StudentDetails {
        public String name {get; set;}
        public String mobileNo {get; set;}
        public Datetime scheduleTime {get; set;}
        public String scheduleTimeIST {get; set;}
        public String vvcId {get; set;}
        public String recordId {get; set;}
        public Boolean alreadyScheduled {get; set;} 
        public String selectedCouncellors {get; set;}
        public String councellorName {get; set;}
        public String zoomId {get; set;}

        public StudentDetails() {
            name = '';
            mobileNo = '';
            scheduleTime = null;
            scheduleTimeIST = '';
            vvcId = '';
            recordId = '';
            alreadyScheduled = false;
            selectedCouncellors = '';
            councellorName = '';
            zoomId = '';
        }
    }

    public class AllowedStudentDetails {
        public Integer maxCallPerHour {get; set;}
        public Integer callPerMinute {get; set;}
        public Integer assignedStudents {get;set;}
        public Integer totalCounselors {get;set;}
        public List<StudentDetails> lstStudentDetails {get; set;}
        public Map<DateTime,Integer> mapOfDateTimeVsCount {get;set;}

        public AllowedStudentDetails() {
            callPerMinute = 0;
            maxCallPerHour = 0;
            assignedStudents = 0;
            lstStudentDetails = new List<StudentDetails>();
            mapOfDateTimeVsCount = new Map<DateTime,Integer>();
        }
    }*/

    public class CounsellorCountWrapper implements Comparable {
        public String counselor;
        public Integer counter;
        public CounsellorCountWrapper(String counselor, Integer counter) {
            this.counselor = counselor;
            this.counter = counter;
        }
        public Integer compareTo(Object other) {
            return counter-((CounsellorCountWrapper)other).counter;
        }
    }
}