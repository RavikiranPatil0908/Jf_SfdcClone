/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : @vickysahu
**/
public class VideoCallSchedulingForZoomId {

    //public List<VVC_Junction__c> lstVCC = new List<VVC_Junction__c>();

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param timeRangeVsStudents 
    * @param objVVC 
    * @param zoomIds 
    * @param videoCallKey 
    * @param token 
    * @return Map<String, VideoCallSchedulingHandler.AllowedStudentDetails> 
    **/
    /*public Map<String,VideoCallSchedulingHandler.AllowedStudentDetails> addZoomIdInMap(Map<String,VideoCallSchedulingHandler.AllowedStudentDetails> timeRangeVsStudents,VVC_Junction__c objVVC,String zoomIds,String videoCallKey,String token) {
        
        lstVCC = [SELECT Id,Schedule_Time_Slot__c,Call_Date__c,Call_Scheduled_Time__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status__c,Schedule_Call_Time__c,Video_Call_Scheduled_Key__c,Schedule_Time_Slot__r.Selected_Counselors__c,Agent_Name__c,Zoom_User_Id__c,Time_Range__c FROM VVC_Junction__c WHERE Call_Date__c =:objVVC.Call_Date__c AND Schedule_Call_Time__c != null AND Status__c = 'In Progress' AND Time_Range__c =:objVVC.Time_Range__c];
        ZoomWebService objWebService = new ZoomWebService();
        System.debug('timeRangeVsStudents===>' + timeRangeVsStudents);
        VideoCallSchedulingHandler.AllowedStudentDetails allSD = timeRangeVsStudents.get(videoCallKey);
        List<VideoCallSchedulingHandler.StudentDetails> lstSD = allSD.lstStudentDetails;
        VideoCallSchedulingHandler.StudentDetails sD = new VideoCallSchedulingHandler.StudentDetails();
        sD = getStudentDetails(lstSD);
        Map<Datetime,Integer> mapOfDtVsCount = allSD.mapOfDateTimeVsCount;
        List<MeetingWrapper> lstDateTime = new List<MeetingWrapper>();
        for(Datetime dt: mapOfDtVsCount.keyset()) {
            if(mapOfDtVsCount.get(dt) < allSD.totalCounselors) {
                lstDateTime.add(new MeetingWrapper(dt, mapOfDtVsCount.get(dt)));
            }
        }
        lstDateTime.sort();
        System.debug('lstDateTime====>' + lstDateTime);
        Map<String,ScheduledMettingsWrapper> mapOfZoomIdVsWrapper = new Map<String,ScheduledMettingsWrapper>();
            
        Map<String,VideoCallSchedulingHandler.AllowedStudentDetails> mapOfTimeRangeVsStudents = new Map<String,VideoCallSchedulingHandler.AllowedStudentDetails>();

        for (MeetingWrapper scheduleTime : lstDateTime) {
            System.debug('scheduleTime====>' + scheduleTime);
            sD.scheduleTime = scheduleTime.dt;
            System.debug('sD.scheduleTime===>' + sD.scheduleTime);
            System.debug('sD.scheduleTime===>' + sD.scheduleTime.format('yyyy-MM-dd HH:mm:ss', 'IST'));
            VideoCallSchedulingHandler objHandler = new VideoCallSchedulingHandler();
            mapOfTimeRangeVsStudents = objHandler.addOrgainizerInMap(objVVC,timeRangeVsStudents,lstVCC);
            System.debug('mapOfTimeRangeVsStudents===>' + mapOfTimeRangeVsStudents);
            VideoCallSchedulingHandler.AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(videoCallKey);
            List<VideoCallSchedulingHandler.StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
            VideoCallSchedulingHandler.StudentDetails studentDetails = new VideoCallSchedulingHandler.StudentDetails();
            studentDetails = getStudentDetails(lstStudentDetails);
            
            List<String> lstOfZoomId = getListOfNotUsedZoomId(zoomIds,studentDetails,objVVC);
            System.debug('lstOfZoomId====>' + lstOfZoomId);
            
            for(String zoomId : lstOfZoomId) {
                String minDate = objVVC.Call_Date__c.year() + '-' + String.valueOf(objVVC.Call_Date__c.month()).leftPad(2, '0') + '-' + String.valueOf(objVVC.Call_Date__c.day()).leftPad(2, '0');
                ScheduledMettingsWrapper objScheduled = mapOfZoomIdVsWrapper.containsKey(zoomId) ? mapOfZoomIdVsWrapper.get(zoomId) : objWebService.getListOfScheduledMeetings(minDate,minDate,300,zoomId,token);
                System.debug('objScheduled===>' + objScheduled);
                if(objScheduled != null) {
                    List<ScheduledMettingsWrapper.Meetings> lstMeetingsData = objScheduled.meetings;
                    Boolean isMeetingScheduled = false;
                    Datetime callStartTime = studentDetails.scheduleTime;
                    Datetime callEndTime = callStartTime.addMinutes(allStudentDetails.callPerMinute);
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
                        studentDetails.zoomId = zoomId;
                        break;
                    }
                }
            }
            if (String.isNotBlank(studentDetails.zoomId)) {
                break;
            }
        }
        
        return mapOfTimeRangeVsStudents;
    }*/

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param zoomIds 
    * @param studentDetails 
    * @param objVVC 
    * @return List<String> 
    **/
    // public List<String> getListOfNotUsedZoomId(String zoomIds,VideoCallSchedulingHandler.StudentDetails studentDetails,VVC_Junction__c objVVC) {
    //     List<String> lstZoomIds = new List<String>();
    //     if(String.isNotBlank(zoomIds)) {
    //         lstZoomIds = zoomIds.split(';');           
    //         for(VVC_Junction__c obj : lstVCC) {
    //             System.debug('obj.Schedule_Call_Time__c===>' + obj.Schedule_Call_Time__c + ' ' + 'studentDetails.scheduleTime===>' + studentDetails.scheduleTime);
    //             System.debug('obj.Schedule_Call_Time__c===>' + obj.Schedule_Call_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + ' ' + 'studentDetails.scheduleTime===>' + studentDetails.scheduleTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
    //             if(lstZoomIds.contains(obj.Zoom_User_Id__c) && obj.Schedule_Call_Time__c == studentDetails.scheduleTime) {
    //                 Integer index = lstZoomIds.indexOf(obj.Zoom_User_Id__c);
    //                 if(index != -1) {
    //                     lstZoomIds.remove(index);
    //                 }
    //             }
    //         }
    //     }
    //     return lstZoomIds;
    // }
    
    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param lstStudentDetails 
    * @return VideoCallSchedulingHandler.StudentDetails 
    **/
    // public VideoCallSchedulingHandler.StudentDetails getStudentDetails(List<VideoCallSchedulingHandler.StudentDetails> lstStudentDetails) {
    //     VideoCallSchedulingHandler.StudentDetails studentDetails = new VideoCallSchedulingHandler.StudentDetails();
    //     for(VideoCallSchedulingHandler.StudentDetails objSD : lstStudentDetails) {
    //         if(objSD.alreadyScheduled == false) {
    //             studentDetails = objSD;
    //         }
    //     }
    //     return studentDetails;
    // }

    // public class MeetingWrapper implements Comparable {
    //     public Datetime dt;
    //     public Integer counter;
    //     public MeetingWrapper(Datetime dt, Integer counter) {
    //         this.dt = dt;
    //         this.counter = counter;
    //     }
    //     public Integer compareTo(Object other) {
    //         return counter-((MeetingWrapper)other).counter;
    //     }
    // }

}