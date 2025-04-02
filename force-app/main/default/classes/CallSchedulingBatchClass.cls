/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-01-2024
 * @last modified by  : @vickysahu
**/
public class CallSchedulingBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    // For Not Started
    public Map<String,AllowedStudentDetails> mapOfTimeRangeVsStudents = new Map<String,AllowedStudentDetails>();
    // For Not Connected
    public Map<String,AllowedStudentDetails> mapOfTimeRangeVsStudentsNC = new Map<String,AllowedStudentDetails>();
    // For (DND) In Progress
    public Map<String,Task> mapOfRowIdVsTask = new Map<String,Task>();
    // Task to Update
    public Map<String,Task> mapOfTaskToUpdate = new Map<String,Task>();
    // Total Active Slots List
    public List<Schedule_Time_Slot__c> lstScheduling = new List<Schedule_Time_Slot__c>();
    // Already queried Task Ids to avoid repeated queries.
    public Set<String> setTaskIds = new Set<String>();
    // Total days List.
    public List<String> workingDays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
    // To inset API Request.
    public List<API_Request__c> lstToInsetAPI = new List<API_Request__c>();
    
    public void execute(SchedulableContext sc) {
        CallSchedulingBatchClass b = new CallSchedulingBatchClass();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('CallSchedulingBatchClass Batch Class Started');
        lstScheduling = DataBase.query(getScheduleListQuery());
        DateTime currentDateTime = System.now().addMinutes(-30);
        String query = 'SELECT id,Subject,Call_uuid__c,Case__r.Student_Category__c,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Schedule_Time_Slot__r.Type_of_Call__c,Status,Schedule_Call_Time__c,Call_Scheduled_Key__c,Schedule_Time_Slot__r.RecordType.Name FROM Task WHERE Subject=\'Call Scheduling\' AND Call_date__c>=Today AND (Status =\'Not Started\' OR (Status=\'Not Connected\' AND Is_Call_Already_Connected__c=false AND Schedule_Time_Slot__r.RecordType.Name=\'Voice Call - Support\') OR (Status=\'In Progress\' AND Schedule_Call_Time__c<:currentDateTime)) LIMIT 200';
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 06-26-2023 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<Task> scope) {
        // To get exisitng schedule calls for that time range and date.
        System.debug('execute method');
        getExisitingCalls(scope);
        System.debug('scope ==>'+scope.size());
        for (Task objTask : scope) {
            if (objTask.Status == 'Not Started' && mapOfTimeRangeVsStudents.containsKey(objTask.Call_Scheduled_Key__c)) { 
                handleCallScheduling(objTask);
            } else if(objTask.Call_date__c == Date.today() && objTask.Status == 'Not Connected' && lstScheduling.size() > 0) {
                handleNotConnected(objTask);
            }
        }

        // To check the call status of fail calls and update the task.
        if(mapOfRowIdVsTask.size() > 0) {
            getStatusAPI();
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('CallSchedulingBatchClass Finished ---> ');
        // To get the Campaign Names.
        List<Call_Campaign__mdt> lstCallCampaigns = [ SELECT Type_of_Call__c,Category__c,DeveloperName,MasterLabel FROM Call_Campaign__mdt];
        Map<String,String> mapOfCallTypeVsCampaignName = new Map<String,String>();
        for (Call_Campaign__mdt objCC : lstCallCampaigns) {
            String mapKey = objCC.Type_of_Call__c +'_'+ objCC.Category__c;
            mapOfCallTypeVsCampaignName.put(mapKey, objCC.MasterLabel);
        }
        
        Map<String, List<List<String>>> MapOfCampaignNameVsStudents = new Map<String, List<List<String>>>();
        System.debug('mapOfTimeRangeVsStudents Size ==>'+mapOfTimeRangeVsStudents.size());
        if (!mapOfTimeRangeVsStudents.isEmpty()) {
            for (String timeRangeKey : mapOfTimeRangeVsStudents.keySet()) {
                AllowedStudentDetails allowedStudentDetails = mapOfTimeRangeVsStudents.get(timeRangeKey);
                System.debug('lstStudentDetails ==>'+allowedStudentDetails.lstStudentDetails.size());
                for (StudentDetails studentDetails : allowedStudentDetails.lstStudentDetails) {
                    if(!studentDetails.alreadyScheduled) {
                        String key = studentDetails.category == 'Learner Support Center' && studentDetails.callType  == 'Regular' ? studentDetails.callType  +'_'+ studentDetails.category : studentDetails.callType +'_'+ null; 
                        String campaignName = mapOfCallTypeVsCampaignName.containsKey(key) ? 
                            mapOfCallTypeVsCampaignName.get(key) : mapOfCallTypeVsCampaignName.get('Regular');
                        List<List<String>> lstOflstStudentDetails = MapOfCampaignNameVsStudents.containsKey(campaignName) ? 
                            MapOfCampaignNameVsStudents.get(campaignName) : new List<List<String>>();
                        
                        List<String> lstSt = new List<String>();
                        lstSt.add(StudentDetails.mobileNo);
                        lstSt.add(StudentDetails.taskId);
                        lstSt.add(StudentDetails.scheduleTimeIST);
                        lstSt.add(StudentDetails.skillId);
                        lstOflstStudentDetails.add(lstSt);
                        
                        MapOfCampaignNameVsStudents.put(campaignName, lstOflstStudentDetails);
                    }
                }
            }
        }
        
        // to call the call scheduling API
        if(MapOfCampaignNameVsStudents.size() > 0) {
            for (String campaignName : MapOfCampaignNameVsStudents.keySet()) {
                getSchedulingAPI(JSON.serialize(MapOfCampaignNameVsStudents.get(campaignName)),campaignName);
            }
        }

        if(lstToInsetAPI.size() > 0) {
            insert lstToInsetAPI;
        }

        System.debug('mapOfTaskToUpdate Size ==>'+mapOfTaskToUpdate.size());
        if (mapOfTaskToUpdate.size() > 0) {
            update mapOfTaskToUpdate.values();
        }
    }

    /**
    * @description 
    * @author @BK | 06-26-2023 
    * @param objTask 
    **/
    public void handleCallScheduling(Task objTask) {
        AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(objTask.Call_Scheduled_Key__c);
        DateTime dt = getCallTimeForStudent(objTask);
        List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
        StudentDetails studentDetails = new StudentDetails();
        studentDetails.mobileNo = objTask.Customer_number__c;
        studentDetails.name = objTask.Student_Name__c;
        if (dt != null && Datetime.now() < dt) {
            system.debug('dt --> ' + dt);
            studentDetails.scheduleTime = dt;
            studentDetails.scheduleTimeIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
            studentDetails.taskId = objTask.Id;
            studentDetails.recordId = objTask.WhatId;
            studentDetails.skillId = objTask.Schedule_Time_Slot__r.Skill_Name__c;
            studentDetails.callType = objTask.Schedule_Time_Slot__r.Type_of_Call__c;
            studentDetails.category = objTask.Case__r.Student_Category__c;
            lstStudentDetails.add(studentDetails);
            allStudentDetails.lstStudentDetails = lstStudentDetails;
            mapOfTimeRangeVsStudents.put(objTask.Call_Scheduled_Key__c, allStudentDetails);
        }
    }

    /**
    * @description 
    * @author @BK | 27-06-2023 
    * @param objTask 
    **/
    public void handleNotConnected(Task objTask) {
        
        for (Schedule_Time_Slot__c objSchedule : lstScheduling) {

            if(objSchedule.Type_of_Call__c == objTask.Schedule_Time_Slot__r.Type_of_Call__c && objSchedule.RecordType.Name == 'Voice Call - Support' && (objSchedule.Type_of_Call__c=='Regular' || objSchedule.Escalation_Level__c.contains(objTask.Escalation_Level__c)) && (objTask.Call_Scheduled_Key__c.split('_').size() <= 4 || (objSchedule.Program_Type__c != null && objTask.Call_Scheduled_Key__c.split('_').size() >= 5 && objTask.Call_Scheduled_Key__c.split('_')[4] == objSchedule.Program_Type__c))) {
                setSchduleSlotM1(objSchedule,objTask);
            }
        }

        if(!mapOfTaskToUpdate.containsKey(objTask.id)) {
            setSchduleSlotM2(lstScheduling,objTask);
        }
    }

    /**
    * @description 
    * @author @BK | 29-06-2023 
    **/
    public void getStatusAPI() {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('https://in1-ccaas-api.ozonetel.com/CAServices/scheduleCampaignData/scheduleDataStatus.php?api_key=' + System.Label.OzontelAPIKey);
        req.setMethod('GET');
        try {
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            String resBody = resp.getBody();
            System.debug('statusCode = '+statusCode);
            if(statusCode == 200) { 
                handleJsonResponse(resBody);
            }
        }catch (Exception e) {
            System.debug(e.getLineNumber() + ' --- '+e.getMessage());
        }
    }

    /**
    * @description 
    * @author @BK | 29-06-2023 
    * @param jsonResponse 
    **/
    public void handleJsonResponse(String jsonResponse) {
        // Remove special charecters.
        jsonResponse = jsonResponse.trim().replace('\\','');
        jsonResponse = jsonResponse.replace('"Response":"{','"Response":{');
        jsonResponse = jsonResponse.replace('"}"','"}');
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        List<Object> lstmessage = (List<Object>) responseBody.get('message');
        List<Object> message = (List<Object>) lstmessage[0];
        for (Object objMessgae : message) {
            Map<String, Object> mapOfObj = (Map<String, Object>)objMessgae;
            String rowId = (String) mapOfObj.get('Id');
            System.debug('mapOfRowIdVsTask---->' + mapOfRowIdVsTask);
            System.debug('mapOfObj---->' + mapOfObj);
            if(mapOfRowIdVsTask.containsKey(rowId) && mapOfObj.get('Response')!=null) {
                Task objTask = mapOfRowIdVsTask.get(rowId);
                Map<String,Object> mapOfResponse = (Map<String,Object>) mapOfObj.get('Response');
                if(mapOfResponse.containsKey('status') && (String)mapOfResponse.get('status')=='FAIL') {
                    String callDateTime = (String)mapOfResponse.get('RequestTime');
                    DateTime actualCallTime = String.isNotBlank(callDateTime) ? DateTime.Valueof(callDateTime) : null;
                    Task callTask = new Task(Id=objTask.Id, Status='Not Connected', Is_Call_Already_Connected__c=true, Call_status__c='NotAnswered',customer_status__c='DND',Description=(String)mapOfResponse.get('message'),Actual_Call_Date__c=actualCallTime);
                    mapOfTaskToUpdate.put(objTask.Id,callTask);
                }
            }
        }
    }

    /**
    * @description : Method 1 to get the 
    * @author @BK | 06-28-2023 
    * @param objSchedule 
    * @param objTask 
    **/
    public void setSchduleSlotM1(Schedule_Time_Slot__c objSchedule, Task objTask) {
        DateTime tomorrowDate = System.now().addDays(1);
        String weekOfDay = tomorrowDate.format('EEEE');
        Integer noOfDays = weekOfDay == 'Sunday' && (objSchedule.End_date__c >= System.today().addDays(2)) ? 2 : 1;
        List<String> customDays = objSchedule.Custom_Schedule_Days__c!=null && objSchedule.Custom_Schedule_Days__c!='' ? objSchedule.Custom_Schedule_Days__c.split(';') : workingDays;
        String mapKey = objTask.Call_Scheduled_Key__c;
        for (Integer i = 0; i < noOfDays; i++) {
            String objScheduleId = objSchedule.Id;
            // Integer addDays = i + 1;
            DateTime mapDateTime = System.today().addDays(i+1);
            String formatedDate = getStringFormatedDate(mapDateTime);
            List<String> timeRange = getTimeRange(objSchedule.Start_time__c,objSchedule.End_time__c);
            System.debug('timeRange-->'+ timeRange);
            if(timeRange.size()>0) {
                for(String range : timeRange) {
                    mapKey = formatedDate + '_' + range + '_' + objSchedule.Type_of_Call__c + '_' + objScheduleId.substring(0, objScheduleId.length() - 3);
                    mapKey = objTask.Call_Scheduled_Key__c.split('_').size() == 5 ? mapKey +'_' + objSchedule.Program_Type__c : mapKey;
                    System.debug('created mapkey-->'+mapkey);
                    System.debug('compare mapkey-->'+JSON.serialize(mapOfTimeRangeVsStudentsNC));
                    //To use Monday to saturday Schedule time slot only
                    if(i == 1 && objSchedule.Recurrence__c == 'Monday to Saturday') {
                        weekOfDay = System.now().addDays(2).format('EEEE');
                    }
                    if(objSchedule.Recurrence__c == 'Daily' || (objSchedule.Recurrence__c == 'Monday to Saturday' && weekOfDay!='Sunday') || (objSchedule.Recurrence__c == 'Custom' && customDays.contains(weekOfDay))) {
                        if(mapOfTimeRangeVsStudentsNC.containsKey(mapKey)) {
                            AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudentsNC.get(mapKey);
                            if(allStudentDetails.assignedStudents < allStudentDetails.maxCallPerHour) {
                                Task callTask = new Task(Id = objTask.Id, Call_date__c = (Date.today()).addDays(i+1), Time_Range__c = range, Schedule_Time_Slot__c = objSchedule.id, Status = 'Not Started', Is_Call_Already_Connected__c = true, Old_Schedule_Call_Time__c=objTask.Schedule_Call_Time__c);
                                mapOfTaskToUpdate.put(objTask.Id,callTask);
                                allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                                mapOfTimeRangeVsStudentsNC.put(mapKey,allStudentDetails);
                            } 
                        } else if(objSchedule.Start_date__c <= System.today().addDays(i+1) && objSchedule.End_date__c >= System.today().addDays(i+1)) {
                            Task callTask = new Task(Id = objTask.Id, Call_date__c = (Date.today()).addDays(i+1), Time_Range__c = range, Schedule_Time_Slot__c = objSchedule.id, Status = 'Not Started', Is_Call_Already_Connected__c = true, Old_Schedule_Call_Time__c=objTask.Schedule_Call_Time__c);
                            mapOfTaskToUpdate.put(objTask.Id,callTask);
                            AllowedStudentDetails allStudentDetails = new AllowedStudentDetails();
                            allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                            allStudentDetails.callPerMinute = Integer.valueOf(objTask.Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c);
                            allStudentDetails.maxCallPerHour = Integer.valueOf((60/allStudentDetails.callPerMinute) * objTask.Schedule_Time_Slot__r.Total_Counselors__c);
                            mapOfTimeRangeVsStudentsNC.put(mapKey,allStudentDetails);                              
                        }    
                    }
                    if(mapOfTaskToUpdate.containsKey(objTask.Id)) {
                        break;
                    }
                }
            }  
        }
    }

    /**
    * @description 
    * @author @BK | 06-28-2023 
    * @param objSchedule 
    * @param objTask 
    **/
    public void setSchduleSlotM2(List<Schedule_Time_Slot__c> lstScheduling, Task objTask) {
        DateTime recordStartTime = getStartDateTimeByString(objTask.Time_Range__c);
        Schedule_Time_Slot__c objScheduleForDateGap = new Schedule_Time_Slot__c();
        String rcId = '';
        for (Schedule_Time_Slot__c objSchedule : lstScheduling) {
            Integer startInt = Integer.valueOF((String.valueOF(objSchedule.Start_time__c)).split(':')[0]);
            Integer endInt = Integer.valueOF((String.valueOF(objSchedule.End_time__c)).split(':')[0]);
            DateTime startTime = DateTime.newInstance(date.today().year(),date.today().month(), date.today().day(),  startInt, 0, 0);
            DateTime endTime = DateTime.newInstance(date.today().year(),date.today().month(), date.today().day(),  endInt, 0, 0);
            if((startTime <= recordStartTime && endTime >= recordStartTime) && objSchedule.RecordType.Name == 'Voice Call - Support' && (objSchedule.Type_of_Call__c==objTask.Schedule_Time_Slot__r.Type_of_Call__c && (objSchedule.Type_of_Call__c=='Regular' || objSchedule.Escalation_Level__c.contains(objTask.Escalation_Level__c))) && (objTask.Call_Scheduled_Key__c.split('_').size() <=4 || (objSchedule.Program_Type__c != null && objTask.Call_Scheduled_Key__c.split('_').size() >= 5 && objTask.Call_Scheduled_Key__c.split('_')[4] == objSchedule.Program_Type__c))) {
                rcId = objSchedule.Id;
                objScheduleForDateGap = objSchedule;
                break;
            }
        }

        if (objScheduleForDateGap != null) {
            if(System.today().daysBetween(objScheduleForDateGap.Start_date__c) > 1){
                DateTime tomorrowDate = objScheduleForDateGap.Start_date__c;
                String weekOfDay = tomorrowDate.format('EEEE');
                Integer noOfDays = weekOfDay == 'Sunday' && (objScheduleForDateGap.Start_date__c.daysBetween(objScheduleForDateGap.End_date__c) >= 2) ? 2 : 1;
                List<String> customDays = objScheduleForDateGap.Custom_Schedule_Days__c!=null && objScheduleForDateGap.Custom_Schedule_Days__c!='' ? objScheduleForDateGap.Custom_Schedule_Days__c.split(';') : workingDays;
                String mapKey = objTask.Call_Scheduled_Key__c;
                for (Integer i = 0; i < noOfDays; i++) {
                    String objScheduleId = objScheduleForDateGap.Id;
                    DateTime mapDateTime = objScheduleForDateGap.Start_date__c.addDays(i);
                    String formatedDate = getStringFormatedDate(mapDateTime);
                    // String dateTimeString = String.valueOf(mapDateTime);
                    // String formatedDate = dateTimeString.substring(0, 10);
                    List<String> timeRange = getTimeRange(objScheduleForDateGap.Start_time__c,objScheduleForDateGap.End_time__c);
                    if(timeRange.size()>0) {
                        for(String range : timeRange) {
                            mapKey = formatedDate + '_' + range + '_' + objScheduleForDateGap.Type_of_Call__c + '_' + objScheduleId.substring(0, objScheduleId.length() - 3);
                            mapKey = objTask.Call_Scheduled_Key__c.split('_').size() == 5 ? mapKey +'_' + objScheduleForDateGap.Program_Type__c : mapKey;
                            System.debug('created mapkey-->'+mapkey);
                            System.debug('compare mapkey-->'+JSON.serialize(mapOfTimeRangeVsStudentsNC));
                            //To use Monday to saturday Schedule time slot only
                            if(i==1 && objScheduleForDateGap.Recurrence__c == 'Monday to Saturday'){
                                weekOfDay = tomorrowDate.addDays(1).format('EEEE');
                            }
                            if(objScheduleForDateGap.Recurrence__c == 'Daily' || (objScheduleForDateGap.Recurrence__c == 'Monday to Saturday' && weekOfDay!='Sunday') || (objScheduleForDateGap.Recurrence__c == 'Custom' && customDays.contains(weekOfDay))) {
                                if(mapOfTimeRangeVsStudentsNC.containsKey(mapKey)) {
                                    AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudentsNC.get(mapKey);
                                    if(allStudentDetails.assignedStudents < allStudentDetails.maxCallPerHour) {
                                        Task callTask = new Task(Id = objTask.Id, Call_date__c = objScheduleForDateGap.Start_date__c.addDays(i), Time_Range__c = range, Schedule_Time_Slot__c = objScheduleForDateGap.id, Status = 'Not Started', Is_Call_Already_Connected__c = true, Old_Schedule_Call_Time__c=objTask.Schedule_Call_Time__c);
                                        mapOfTaskToUpdate.put(objTask.Id,callTask);
                                        allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                                        mapOfTimeRangeVsStudentsNC.put(mapKey,allStudentDetails);
                                    } 
                                } else {
                                    Task callTask = new Task(Id = objTask.Id, Call_date__c = objScheduleForDateGap.Start_date__c.addDays(i), Time_Range__c = range, Schedule_Time_Slot__c = objScheduleForDateGap.id, Status = 'Not Started', Is_Call_Already_Connected__c = true, Old_Schedule_Call_Time__c=objTask.Schedule_Call_Time__c);
                                    mapOfTaskToUpdate.put(objTask.Id,callTask);
                                    AllowedStudentDetails allStudentDetails = new AllowedStudentDetails();
                                    allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                                    allStudentDetails.callPerMinute = Integer.valueOf(objTask.Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c);
                                    allStudentDetails.maxCallPerHour = Integer.valueOf((60/allStudentDetails.callPerMinute) * objTask.Schedule_Time_Slot__r.Total_Counselors__c);
                                    mapOfTimeRangeVsStudentsNC.put(mapKey,allStudentDetails);                                
                                }
                                if(mapOfTaskToUpdate.containsKey(objTask.Id)) {
                                    break;
                                }        
                            }
                        }
                    }  
                }                
            }
        }
    }

    public String getStringFormatedDate(DateTime mapDateTime) {
        String formatedDate = '';
        // DateTime mapDateTime = System.today().addDays(addDays);
        String dateTimeString = String.valueOf(mapDateTime);
        formatedDate = dateTimeString.substring(0, 10);
        return formatedDate;
    }

    public List<String> getTimeRange(Time startTime, Time endTime) {
        List<String> timeRanges = new List<String>();
        
        Time currentTime = startTime;
        while (currentTime < endTime) {
            Time nextTime = currentTime.addHours(1);
            String startAmPm = currentTime.hour() < 12 ? 'am' : 'pm';
            String endAmPm = nextTime.hour() < 12 ? 'am' : 'pm';
            
            // Construct start time string
            String startTimeString = '';
            if (currentTime.minute() == 0) {
                startTimeString = (currentTime.hour() == 0 ? 12 : currentTime.hour() > 12 ? currentTime.hour() - 12 : currentTime.hour()) + ' ' + startAmPm;
            } else {
                startTimeString = (currentTime.hour() == 0 ? 12 : currentTime.hour() > 12 ? currentTime.hour() - 12 : currentTime.hour()) + ':' + String.valueOf(currentTime.minute()) + ' ' + startAmPm;
            }
            
            // Construct end time string
            String nextTimeString = '';
            if (nextTime.minute() == 0) {
                nextTimeString = (nextTime.hour() == 0 ? 12 : nextTime.hour() > 12 ? nextTime.hour() - 12 : nextTime.hour()) + ' ' + endAmPm;
            } else {
                nextTimeString = (nextTime.hour() == 0 ? 12 : nextTime.hour() > 12 ? nextTime.hour() - 12 : nextTime.hour()) + ':' + String.valueOf(nextTime.minute()) + ' ' + endAmPm;
            }
            
            timeRanges.add(startTimeString + ' - ' + nextTimeString);
            currentTime = nextTime;
        }
        return timeRanges;
    }
    

    // public List<String> getTimeRange(Time startTime,Time endTime) {
    //     // Time startTime = sTime;
    //     // Time endTime = eTime;
    //     List<String> timeRanges = new List<String>();
        
    //     Time currentTime = startTime;
    //     while (currentTime < endTime) {
    //         Time nextTime = currentTime.addHours(1);
    //         String startAmPm = currentTime.hour() < 12 ? 'am' : 'pm';
    //         String endAmPm = nextTime.hour() < 12 ? 'am' : 'pm';
    //         String startTimeString = (currentTime.hour() == 0 ? 12 : currentTime.hour() > 12 ? currentTime.hour() - 12 : currentTime.hour()) + ':' + String.valueOf(currentTime.minute()) + ' ' + startAmPm;
    //         String nextTimeString = (nextTime.hour() == 0 ? 12 : nextTime.hour() > 12 ? nextTime.hour() - 12 : nextTime.hour()) + ':' + String.valueOf(nextTime.minute()) + ' ' + endAmPm;
    //         timeRanges.add(startTimeString + ' - ' + nextTimeString);
    //         currentTime = nextTime;
    //     }
    //     return timeRanges;        
    // }


    /**
    * @description 
    * @author @BK | 06-26-2023 
    * @param lstTask 
    **/
    public void getExisitingCalls(List<Task> lstTask) {
        Set<String> setOfCallScheduledKeys = new Set<String>();
        Map<String,Map<String,String>> mapOfKeyVsMapOfCallScheduleDetails = new Map<String,Map<String,String>>();
        Boolean checkNotConnectedCalls = false;
        for (Task objTask : lstTask) {
            if (objTask.Status == 'Not Started') {
                setTaskIds.add(objTask.id);
                System.debug('timeRangeKey --> ' + objTask.Call_Scheduled_Key__c);
                if(!setOfCallScheduledKeys.contains(objTask.Call_Scheduled_Key__c)) {
                    setOfCallScheduledKeys.add(objTask.Call_Scheduled_Key__c);
                    Map<String,String> mapOfCallScheduleDetails = new Map<String,String> {
                        'Per_Call_Schedule_Minutes__c' => String.valueOf(objTask.Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c),
                        'Total_Counselors__c' => String.valueOf(objTask.Schedule_Time_Slot__r.Total_Counselors__c),
                        'Time_Range__c' => objTask.Time_Range__c,
                        'Call_date__c' => String.valueOf(objTask.Call_date__c),
                        'Type_of_Call__c' => objTask.Schedule_Time_Slot__r.Type_of_Call__c
                    };
                    mapOfKeyVsMapOfCallScheduleDetails.put(objTask.Call_Scheduled_Key__c,mapOfCallScheduleDetails);
                }
            } else if(objTask.Call_date__c == Date.today() && objTask.Status == 'Not Connected' && lstScheduling.size() > 0 && !checkNotConnectedCalls) {
                checkNotConnectedCalls = true;
            } else if(objTask.Status == 'In Progress') {
                mapOfRowIdVsTask.put(objTask.Call_uuid__c,objTask);
            }
        }

        if(setOfCallScheduledKeys.size() > 0) {
            getCallDetails(mapOfKeyVsMapOfCallScheduleDetails);

            System.debug('setTaskIds ==>'+setTaskIds.size());
            List<Task> lstOfScheduledTasks = [SELECT id,Subject,Case__r.Student_Category__c,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Status,Schedule_Call_Time__c,Call_Scheduled_Key__c,Schedule_Time_Slot__r.Type_of_Call__c,Schedule_Time_Slot__r.RecordType.Name FROM Task WHERE Call_Scheduled_Key__c IN :setOfCallScheduledKeys AND Schedule_Call_Time__c!=null AND id Not IN :setTaskIds];
            System.debug('lstOfScheduledTasks ==>'+lstOfScheduledTasks.size());
            for(Task objTask :lstOfScheduledTasks) {
                if(mapOfTimeRangeVsStudents.containsKey(objTask.Call_Scheduled_Key__c)) {
                    AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(objTask.Call_Scheduled_Key__c);
                    List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
                    StudentDetails studentDetails = new StudentDetails();
                    studentDetails.mobileNo = objTask.Customer_number__c;
                    studentDetails.name = objTask.Student_Name__c;
                    studentDetails.scheduleTime = objTask.Schedule_Call_Time__c;
                    studentDetails.taskId = objTask.id;
                    studentDetails.recordId = objTask.WhatId;
                    studentDetails.callType = objTask.Schedule_Time_Slot__r.Type_of_Call__c;
                    studentDetails.alreadyScheduled = true;
                    studentDetails.category = objTask.Case__r.Student_Category__c;
                    lstStudentDetails.add(studentDetails);
                    allStudentDetails.lstStudentDetails = lstStudentDetails;
                    allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                    if(allStudentDetails.mapOfDateTimeVsCount.containsKey(studentDetails.scheduleTime)) {
                        Integer count = allStudentDetails.mapOfDateTimeVsCount.get(studentDetails.scheduleTime) + 1;
                        allStudentDetails.mapOfDateTimeVsCount.put(studentDetails.scheduleTime, count);
                    }
                    mapOfTimeRangeVsStudents.put(objTask.Call_Scheduled_Key__c, allStudentDetails);
                }
            }
        }

        if(checkNotConnectedCalls) {
            Set<String> setOfScheduleId = new Set<String>();
            for (Schedule_Time_Slot__c objSchedule : lstScheduling) {
                setOfScheduleId.add(objSchedule.id);
            }
            List<Task> lstTaskNC = [SELECT id,Subject,Time_Range__c,Student_Name__c,Schedule_Time_Slot__c,Customer_number__c,Escalation_Level__c,Call_date__c,WhatId,Schedule_Time_Slot__r.Skill_Name__c,Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c,Schedule_Time_Slot__r.Total_Counselors__c,Status,Schedule_Call_Time__c,Call_Scheduled_Key__c,Schedule_Time_Slot__r.RecordType.Name FROM Task WHERE Schedule_Time_Slot__c IN :setOfScheduleId AND Call_date__c=NEXT_N_DAYS:6 ];
            for (Task objTask : lstTaskNC) {
                AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudentsNC.containsKey(objTask.Call_Scheduled_Key__c) ? mapOfTimeRangeVsStudentsNC.get(objTask.Call_Scheduled_Key__c) : new AllowedStudentDetails();
                allStudentDetails.assignedStudents = allStudentDetails.assignedStudents + 1;
                allStudentDetails.callPerMinute = Integer.valueOf(objTask.Schedule_Time_Slot__r.Per_Call_Schedule_Minutes__c);
                allStudentDetails.maxCallPerHour = Integer.valueOf((60/allStudentDetails.callPerMinute) * objTask.Schedule_Time_Slot__r.Total_Counselors__c);
                mapOfTimeRangeVsStudentsNC.put(objTask.Call_Scheduled_Key__c, allStudentDetails);
            }
        }
    }  

    /**
    * @description 
    * @author @BK | 27-06-2023 
    * @param objTask 
    * @return DateTime 
    **/
    public DateTime getCallTimeForStudent(Task objTask) {
        DateTime avialableDt;
        if(mapOfTimeRangeVsStudents.containsKey(objTask.Call_Scheduled_Key__c)) {
            AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.get(objTask.Call_Scheduled_Key__c);
            List<StudentDetails> lstStudentDetails = allStudentDetails.lstStudentDetails;
            Map<DateTime, Integer> mapOfDateTimeVsCount = allStudentDetails.mapOfDateTimeVsCount;
            System.debug('mapOfDateTimeVsCount Before ===========================>');
            System.debug(mapOfDateTimeVsCount);

            avialableDt = mapOfDateTimeVsCount.isEmpty() ? null : new List<DateTime>(mapOfDateTimeVsCount.keyset())[0];
            for(DateTime s1 : mapOfDateTimeVsCount.keySet()) {
                avialableDt = mapOfDateTimeVsCount.get(s1) < mapOfDateTimeVsCount.get(avialableDt) ? s1 : avialableDt;
            }

            // To check if selected time is not null
            if(avialableDt!=null) {
                Integer count = mapOfDateTimeVsCount.get(avialableDt);
                mapOfDateTimeVsCount.put(avialableDt, count + 1);
                allStudentDetails.mapOfDateTimeVsCount = mapOfDateTimeVsCount;
                mapOfTimeRangeVsStudents.put(objTask.Call_Scheduled_Key__c,allStudentDetails);
            }
    
            System.debug('mapOfDateTimeVsCount After ===========================>');
            System.debug(mapOfDateTimeVsCount);
        }
        return avialableDt;
    }

 
    /**
    * @description 
    * @author @BK | 27-06-2023 
    * @param mapOfKeyVsMapOfCallScheduleDetails 
    **/
    public void getCallDetails(Map<String,Map<String,String>> mapOfKeyVsMapOfCallScheduleDetails) {
        for (String mapKey : mapOfKeyVsMapOfCallScheduleDetails.keySet()) {
            AllowedStudentDetails allStudentDetails = mapOfTimeRangeVsStudents.containsKey(mapKey) ? mapOfTimeRangeVsStudents.get(mapKey) : new AllowedStudentDetails();
            Map<String,String> mapOfCallScheduleDetails = mapOfKeyVsMapOfCallScheduleDetails.get(mapKey);

            allStudentDetails.callPerMinute = Integer.valueOf(mapOfCallScheduleDetails.get('Per_Call_Schedule_Minutes__c'));
            allStudentDetails.maxCallPerHour = Integer.valueOf((60/allStudentDetails.callPerMinute) *Integer.valueOf(mapOfCallScheduleDetails.get('Total_Counselors__c')));
            allStudentDetails.callType = mapOfCallScheduleDetails.get('Type_of_Call__c');
            Integer callPerMinute = allStudentDetails.callPerMinute;
            Date callDate = Date.valueOf(mapOfCallScheduleDetails.get('Call_date__c'));
            Integer getHours = getHours(mapOfCallScheduleDetails.get('Time_Range__c'));
            Map<DateTime, Integer> mapOfDateTimeVsCount = new Map<DateTime, Integer>();
            for (Integer i = 0; i < allStudentDetails.maxCallPerHour; i++) {
                Integer getMinutes = (i * callPerMinute) > 60 ? callPerMinute : (i * callPerMinute == 60 ? 0 : i * callPerMinute);
                mapOfDateTimeVsCount.put(DateTime.newInstance(callDate.year(), callDate.month(), callDate.day(), getHours, getMinutes, 0), 0);
            }
            // allStudentDetails.maxCallPerTime = allStudentDetails.maxCallPerHour / mapOfDateTimeVsCount.size();
            allStudentDetails.mapOfDateTimeVsCount = mapOfDateTimeVsCount;
            System.debug('allStudentDetails ==================>');
            System.debug(allStudentDetails);
            mapOfTimeRangeVsStudents.put(mapKey,allStudentDetails);
        }
    }

    /**
    * @description 
    * @author @BK | 06-26-2023 
    * @param timeRange 
    * @return Integer 
    **/
    public Integer getHours(String timeRange) {
        String startTimeStr = timeRange.split('-')[0];
        List<String> lstSplitOfTime = startTimeStr.split(' ');
        Integer hoursTime = Integer.valueOf(lstSplitOfTime[0].trim());
        
        // to convert hrs in 24 format.
        Integer callTime = lstSplitOfTime[1].trim() == 'am' ? (hoursTime == 12 ? 0 : hoursTime) : (hoursTime == 12 ? 12 : hoursTime + 12);
        return callTime;
    }

    /**
    * @description 
    * @author @BK | 27-06-2023 
    * @param jsonString 
    * @param jsonResponse 
    **/
    public void getSchedulingAPI(String jsonString, String campaignName) {
        String completeStatus = '';
        List<Task> lstTask = new List<Task>();
        if(String.isNotBlank(jsonString)) {
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            String uri =  'https://in1-ccaas-api.ozonetel.com/CAServices/scheduleCampaignData/scheduleCampaignData.php?api_key=' + System.Label.OzontelAPIKey;
            String reqBoby = '&campaign_name='+campaignName+'&bulkData={"map":["PhoneNumber","Name","ScheduledTime","skill"],"data":'+ jsonString +'}';
            String URL = uri + reqBoby;
            req.setEndpoint(Uri);
            req.setBody(reqBoby);
            req.setMethod('GET');
            String resBody = '';
            System.debug('jsonstring ==> ' + jsonstring);
            try {
                resp = http.send(req);
                Integer statusCode = resp.getStatusCode();
                resBody = resp.getBody();
                System.debug('statusCode = '+statusCode);
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                System.debug(resBody);
                System.debug(responseBody);
                String status = '';
                if(statusCode == 200) {
                    status = (String)responseBody.get('status');
                    if (status == 'success') {
                        List<Object> message = (List<Object>) responseBody.get('message');
                        for (Object obj : message) {
                            Map<String, Object> mapOfObj = (Map<String, Object>) obj;
                            String objRes = (String) mapOfObj.get('Response');
                            if (objRes == 'success') {
                                String rowId = (String)mapOfObj.get('rowId');
                                String ScheduleTime = (String) mapOfObj.get('ScheduleTime');
                                String dateStr = ScheduleTime.split(' ')[0];
                                String timeStr = ScheduleTime.split(' ')[1];
                                Integer yearStr = Integer.valueOf(dateStr.split('-')[0]);
                                Integer monthStr = Integer.valueOf(dateStr.split('-')[1]);
                                Integer dayStr = Integer.valueOf(dateStr.split('-')[2]);
                                Integer hourStr = Integer.valueOf(timeStr.split(':')[0]);
                                Integer minuteStr = Integer.valueOf(timeStr.split(':')[1]);
                                Datetime dtTime = Datetime.newInstance( yearStr,  monthStr,  dayStr,  hourStr,  minuteStr, 0);
                                String taskId = (String)mapOfObj.get('Name');
                                if (String.isNotBlank(taskId)) {
                                    Task objTask = new Task(Id=taskId, Status='In Progress', is_Call_Cancel__c = false, Schedule_Call_Time__c=dtTime, Call_uuid__c=rowId);
                                    mapOfTaskToUpdate.put(taskId,objTask);
                                }
                            }
                        }
                    }
                }
                insertAPIRequest(URL, resBody, status == 'success' ? true : false);
            }catch (Exception e) {
                System.debug(e.getLineNumber() + ' --- '+e.getMessage());
                insertAPIRequest(URL, resBody + ' -- ' + e.getLineNumber() + ' --- '+e.getMessage(),false);
            }
        }
    }

    public void insertAPIRequest(String req, String res, Boolean isSuccess) {
        API_Request__c apiReq = new API_Request__c();
        apiReq.API_Name__c = 'CallSchedulingAPI';
        apiReq.Request__c = String.isNotBlank(req) ? req.left(131072) : req;
        apiReq.Type_of_Request__c = 'Ozonetel';
        apiReq.Response__c = String.isNotBlank(res) ? res.left(131072) : res;
        apiReq.Success__c = isSuccess;
        lstToInsetAPI.add(apiReq);
    }

    /**
    * @description 
    * @author @BK | 27-06-2023 
    * @param timeRange 
    * @return DateTime 
    **/
    public DateTime getStartDateTimeByString(String timeRange) {
        Integer startTime = Integer.valueOf((timeRange.split(' ')[0]).trim()); 
        String hourString = (timeRange.split(' ')[1]).trim();
        Integer hourValue = Integer.valueOf(hourString == 'am' && startTime != 12 ? startTime : hourString == 'am' && startTime == 12 ? 0 : hourString == 'pm' && startTime != 12  ? startTime + 12 : 12  );
        return Datetime.newInstance(Date.today().year() ,Date.today().month(), Date.today().day(), hourValue,0,0);
    }

    /**
    * @description 
    * @author @BK | 06-26-2023 
    * @return String 
    **/
    public static String getScheduleListQuery() {
        DateTime dt = System.now().addDays(1);
        String weekOfDay = dt.format('EEEE');
        String query = 'SELECT Id,Start_time__c,End_time__c,Escalation_Level__c,Schedule_Date__c,Start_date__c,End_date__c,Recurrence__c,Custom_Schedule_Days__c,Type_of_Call__c, Program_Type__c, RecordType.Name FROM Schedule_Time_Slot__c WHERE IsActive__c=true AND (RecordType.Name =\'Voice Call - Support\' OR RecordType.Name =\'Voice Call - LC Support\') AND End_date__c>TODAY AND (Recurrence__c=\'Daily\'';
        // if(weekOfDay != 'Sunday') {
        //     query = query + ' OR Recurrence__c=\'Monday to Saturday\''; 
        // }
        query = query + ' OR Recurrence__c=\'Monday to Saturday\'';
        query = query + ' OR (Recurrence__c=\'Custom\' AND Custom_Schedule_Days__c includes (\''+weekOfDay+'\'))) ORDER BY Program_Type__c DESC';
        return query;
    }

    public class StudentDetails {
        public String name {get; set;}
        public String mobileNo {get; set;}
        public Datetime scheduleTime {get; set;}
        public String scheduleTimeIST {get; set;}
        public String taskId {get; set;}
        public String recordId {get; set;}
        public String skillId {get; set;}
        public Boolean alreadyScheduled {get; set;} 
        public String callType {get; set;}
        public String category {get; set;}

        public StudentDetails() {
            name = '';
            mobileNo = '';
            scheduleTime = null;
            scheduleTimeIST = '';
            taskId = '';
            recordId = '';
            skillId = '';
            alreadyScheduled = false;
            callType = '';
            category = '';
        }
    }

    public class AllowedStudentDetails {
        public Integer maxCallPerHour {get; set;}
        public Integer callPerMinute {get; set;}
        // public Integer maxCallPerTime {get; set;}
        public Integer assignedStudents {get;set; }
        public String callType {get;set;}
        public List<StudentDetails> lstStudentDetails{get; set;}
        public Map<DateTime,Integer> mapOfDateTimeVsCount  {get;set;}
            public AllowedStudentDetails() {
                callPerMinute = 0;
                maxCallPerHour = 0;
                // maxCallPerTime = 0;
                assignedStudents = 0;
                callType = '';
                lstStudentDetails = new List<StudentDetails>();
                mapOfDateTimeVsCount = new Map<DateTime,Integer>();
            }
    }

}