/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 25-01-2025
 * @last modified by  : @BK
**/
public class VVCAssignmentBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts {

    public Set<String> lstUnAssignedVVC = new Set<String>();

    public void execute(SchedulableContext sc) {
        VVCAssignmentBatch b = new VVCAssignmentBatch();
        Database.executebatch(b, 200);
    }
    
    // Start method to fetch the records to process
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query to fetch VVC records that need to be assigned to agents
        DateTime futureTime = getUpcomingQuarterHour(System.now());
        String query = 'SELECT Id, Name, Schedule_Call_Time__c, Status__c FROM VVC_Junction__c WHERE Status__c = \'In Progress\' AND Schedule_Call_Time__c = :futureTime';
        return Database.getQueryLocator(query);
    }

    // Execute method to process each VVC record
    public void execute(Database.BatchableContext bc, List<VVC_Junction__c> scope) {
        try {
            Id serviceChannelId = [SELECT Id FROM ServiceChannel WHERE MasterLabel = 'VVC' LIMIT 1].Id;
            List<Id> duplicateAssignmentIds = getAlreadyAssignedVVCIds(scope);

            // Fetch available agents with "VVC" skill
            Set<Id> agentsWithVVCSkill = fetchAvailableAgents();

            // Map to hold the PendingServiceRouting records with VVCId to be inserted
            Map<Id,PendingServiceRouting> pendingServiceRoutingToCreate = new Map<Id,PendingServiceRouting>();

            // Step 1: Query existing AgentWork records assigned today to these agents
            List<AgentWork> existingAssignments = [
                SELECT Id, UserId
                FROM AgentWork
                WHERE UserId IN :agentsWithVVCSkill
                AND AssignedDateTime = TODAY
                AND ServiceChannelId = :serviceChannelId
            ];

            // Step 2: Map of agentId to the count of their assigned work today
            Map<Id, Integer> mapOfUserIdVsCount = new Map<Id, Integer>();

            // If no existing assignments, no records will be added to the map
            for (AgentWork aw : existingAssignments) {
                Integer count = mapOfUserIdVsCount.containsKey(aw.UserId) ? mapOfUserIdVsCount.get(aw.UserId) + 1 : 1;
                mapOfUserIdVsCount.put(aw.UserId, count);
            }

            // Step 3: Sort the agents by their current work count (ascending order)
            // If mapOfUserIdVsCount is empty, all agents are treated as having 0 work assigned
            List<Id> sortedAgents = new List<Id>(agentsWithVVCSkill);

            // Create an instance of the custom comparator
            WorkCountCompare workCountCompare = new WorkCountCompare(mapOfUserIdVsCount);

            // Sort agents using the custom comparator
            sortedAgents.sort(workCountCompare);
            System.debug(sortedAgents);

            // Step 4: Assign VVC Junction records to the agents with the least work
            Integer agentIndex = 0;
            for (VVC_Junction__c vvcJunction : scope) {
                if (!sortedAgents.isEmpty() && !duplicateAssignmentIds.contains(vvcJunction.Id)) {
                    // Ensure agentIndex is within bounds before accessing the list
                    if (agentIndex < sortedAgents.size()) {
                        // Get the next available agent (with the least amount of work assigned)
                        Id assignedAgentId = sortedAgents[agentIndex];

                        PendingServiceRouting psr = new PendingServiceRouting(
                            CustomRequestedDateTime = System.now(),
                            IsReadyForRouting = false,
                            PreferredUserId = assignedAgentId,
                            RoutingModel = 'MostAvailable',
                            RoutingPriority = 1,
                            RoutingType = 'SkillsBased',
                            ServiceChannelId = serviceChannelId,
                            WorkItemId = vvcJunction.Id,
                            CapacityWeight = 25
                        );
                        pendingServiceRoutingToCreate.put(vvcJunction.Id,psr);

                        // Increment the agentIndex to move to the next agent
                        agentIndex++;

                        // If we've assigned work to all agents, loop back to the first agent (round-robin)
                        // if (agentIndex >= sortedAgents.size()) {
                        //     agentIndex = 0;
                        // }
                    } else {
                        lstUnAssignedVVC.add(vvcJunction.Name);
                        System.debug('Error: agentIndex exceeds the number of available agents');
                    }
                } else {
                    lstUnAssignedVVC.add(vvcJunction.Name);
                }
            }

            // Step 5: Insert the agent work records
            if (!pendingServiceRoutingToCreate.isEmpty()) {
                insertAgentWorkRecords(pendingServiceRoutingToCreate, serviceChannelId);
            }
        } catch (Exception error) {
            System.debug('Error ==>'+error.getMessage());
            System.debug('Error ==>'+error.getLineNumber());
        }
    }

    /**
    * @description 
    * @author @BK | 13-12-2024 
    **/
    private void insertAgentWorkRecords(Map<Id,PendingServiceRouting> mapOfVVCIdVsPSR, Id serviceChannelId){
        // to skip insert on test.
        if(!Test.isRunningTest()) {
            insert mapOfVVCIdVsPSR.values();
        }

        // List to hold the AgentWork records to be inserted
        List<AgentWork> agentWorksToCreate = new List<AgentWork>();

        for (PendingServiceRouting psr : mapOfVVCIdVsPSR.values()) {
            AgentWork newAgentWork = new AgentWork(
                UserId = psr.PreferredUserId,
                WorkItemId = psr.WorkItemId,
                ServiceChannelId = serviceChannelId, // Ensure this is set
                CapacityWeight = 25, // Set the capacity weight or any other necessary parameters
                PendingServiceRoutingId = Test.isRunningTest() ? null : psr.Id
            );

            agentWorksToCreate.add(newAgentWork);
        }

        // to skip insert on test.
        if(!agentWorksToCreate.isEmpty() && !Test.isRunningTest()) {
            insert agentWorksToCreate;
        }
    }

    /**
    * @description 
    * @author @BK | 12-12-2024 
    * @return Set<Id> 
    **/
    public static Set<Id> fetchAvailableAgents() {
        Set<Id> avialableAgents = new Set<Id>();
        // To Mock the records in Test class Query Class used
        List<UserServicePresence> lstUSP = Query.records(
            [SELECT Id,ConfiguredCapacity,IsAway,AtCapacityDuration,AverageCapacity,UserId FROM UserServicePresence WHERE IsCurrentState = true AND ServicePresenceStatus.MasterLabel IN ('Available - VVC')], 
            'UserServicePresence');

        if(lstUSP.isEmpty()) {
            return avialableAgents;
        }
        
        Set<Id> skilledAgents = new Set<Id>();
        List<ServiceResourceSkill> lstSRS = [SELECT id,ServiceResource.Name,ServiceResource.RelatedRecordId,SkillId,Skill.MasterLabel,SkillNumber FROM ServiceResourceSkill WHERE Skill.MasterLabel = 'VVC'];
        for (ServiceResourceSkill srs : lstSRS) {
            skilledAgents.add(srs.ServiceResource.RelatedRecordId);
        }

        if(skilledAgents.isEmpty()) {
            return avialableAgents;
        }

        // To Mock the records in Test class Query Class used
        List<AgentWork> lstAgentCapacity = Query.records(
            [SELECT CapacityWeight,UserId FROM AgentWork WHERE Status = 'Opened' AND UserId IN :skilledAgents],
            'AgentWork');
        Map<Id,Integer> mapOfUserIdVsAtCapacity = new Map<Id,Integer>();
        for (AgentWork aw : lstAgentCapacity) {
            Integer atCapacity = mapOfUserIdVsAtCapacity.containsKey(aw.UserId) ? Integer.valueOf(aw.CapacityWeight + mapOfUserIdVsAtCapacity.get(aw.UserId)) : Integer.valueOf(aw.CapacityWeight);
            mapOfUserIdVsAtCapacity.put(aw.UserId,atCapacity);
        }
        
        for (UserServicePresence usp : lstUSP) {
            Integer configuredCapacity = Test.isRunningTest() ? 100 : usp.ConfiguredCapacity;
            if(!mapOfUserIdVsAtCapacity.containsKey(usp.UserId) || (mapOfUserIdVsAtCapacity.containsKey(usp.UserId) 
                && (configuredCapacity - mapOfUserIdVsAtCapacity.get(usp.UserId)) >= 25) ) {
                avialableAgents.add(usp.UserId);
            }
        }

        // Filter the available agents based on the Ozontel API response
        avialableAgents = getActiveAgents(avialableAgents);

        return avialableAgents;
    } 

    /**
    * @description 
    * @author @BK | 12-12-2024 
    * @param List<VVC_Junction__c> scope 
    * @return List<Id> 
    **/
    public static List<Id> getAlreadyAssignedVVCIds(List<VVC_Junction__c> scope) {
        List<Id> duplicateVVCIds = new List<Id>();
        List<Id> vvcIds = new List<Id>();
        for (VVC_Junction__c vvc : scope) {
            vvcIds.add(vvc.Id);
        }

        List<AgentWork> duplicateAssignments = Query.records(
            [
                SELECT Id, WorkItemId
                FROM AgentWork
                WHERE WorkItemId IN :vvcIds
                AND Status = 'Opened'
            ],
            'AgentWork');
            
        if(!duplicateAssignments.isEmpty()) {
            for (AgentWork aw : duplicateAssignments) {
                if(vvcIds.contains(aw.WorkItemId)) {
                    duplicateVVCIds.add(aw.WorkItemId);
                }
            }
        }

        return duplicateVVCIds;
    }

   
    /**
    * @description  Function to get the UpComing 15-minute interval
    * @author @BK | 12-12-2024 
    * @return DateTime 
    **/
    public static DateTime getUpcomingQuarterHour(DateTime currentDateTime) {
        
        // Get the current minute
        Integer currentMinute = currentDateTime.minute();
        
        // Calculate the next quarter hour
        Integer nearestQuarter = (currentMinute / 15) * 15;
        
        // If the minute is between 0 and 14, it will round to 00, 15, 30, or 45
        if (currentMinute >= 0 && currentMinute < 15) {
            nearestQuarter = 15; // Rounds up to the next 15-minute mark
        } else if (currentMinute >= 15 && currentMinute < 30) {
            nearestQuarter = 30; // Rounds to 30-minute mark
        } else if (currentMinute >= 30 && currentMinute < 45) {
            nearestQuarter = 45; // Rounds to 45-minute mark
        } else if (currentMinute >= 45) {
            nearestQuarter = 0; // Next quarter hour is the start of the next hour
        }

        // Get other components of the current DateTime
        Integer hour = currentDateTime.hour();
        Integer year = currentDateTime.year();
        Integer month = currentDateTime.month();
        Integer day = currentDateTime.day();
        
        // Handle the case where the time goes into the next hour
        if (nearestQuarter == 0) {
            hour += 1;
            if (hour == 24) { // Handle the midnight case
                hour = 0;
                day += 1; // Adjust the day if necessary
            }
        }

        // Create a new DateTime object for the calculated nearest quarter
        DateTime upcomingQuarterHour = DateTime.newInstance(year, month, day, hour, nearestQuarter, 0);

        System.debug('Upcoming quarter hour: ' + upcomingQuarterHour);
        return upcomingQuarterHour;
    }

    // Finish method to handle post-processing (optional)
    public void finish(Database.BatchableContext BC) {
        // Optional: send a notification, log, or any cleanup tasks
        if(lstUnAssignedVVC!=null && !lstUnAssignedVVC.isEmpty() && (System.Label.Environment == 'Production' || Test.isRunningTest())) {
            sendErrorMail();
        }
    }

    /**
    * @description Filter the available agents based on the Ozontel API response
    * @author @BK | 25-01-2025 
    * @param Set<Id> avialableAgents 
    * @return Set<Id> 
    **/
    private static Set<Id> getActiveAgents(Set<Id> avialableAgents) {
        if(avialableAgents.isEmpty()) {
            return new Set<Id>();
        }

        List<ServiceResource> lstSR = [SELECT Id,Name,RelatedRecordId,Ozontel_Id__c FROM ServiceResource WHERE IsActive = TRUE AND RelatedRecordId IN :avialableAgents AND Ozontel_Id__c!=null];
        if(lstSR.isEmpty()) {
            return avialableAgents;
        }

        Map<String,Id> mapOfOzontelIdVsUserId = new Map<String,Id>();
        for (ServiceResource objSR : lstSR) {
            mapOfOzontelIdVsUserId.put(objSR.Ozontel_Id__c,objSR.RelatedRecordId);
        }

        Set<Id> activeAgents = new Set<Id>();

        // Find the difference between set B and set A (missing in A but present in B)
        Set<Id> setA = new Set<Id>(mapOfOzontelIdVsUserId.values());
        Set<Id> setB = new Set<Id>(avialableAgents);
        Set<Id> difference = new Set<Id>(setB);
        difference.removeAll(setA); // Removes all elements of setA from difference
        if(!difference.isEmpty()) {
            // Add the difference (missing IDs) to the new set
            activeAgents.addAll(difference);
        }
        
        activeAgents.addAll(AgentService.filterVoiceCallActive(mapOfOzontelIdVsUserId));

        return activeAgents;
    }

    /**
    * @description 
    * @author @BK | 26-12-2024 
    **/
    public void sendErrorMail() {
        String recordList = '';

        for(String s: lstUnAssignedVVC) {
            recordList += (recordList==''?'':',\n')+s;
        }

        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        String[] ccAddress = System.Label.setBccAdderess.split(',');
        String[] sendingToAddress = new List<String>{
            'khushboo.thakkar@nmims.edu',
            'sangeeta.shetty@nmims.edu',
            'farah.shaikh@nmims.edu',
            'neeta.vichare@nmims.edu',
            'hemal.doshi@nmims.edu'
        };
        mail.setCcAddresses(ccAddress);
        mail.setToAddresses(sendingToAddress);
        mail.setSubject('VVC Routing could not be assigned List');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below VVC Names Which Couldn\'t be assigned:\n'+
        'Here are the lists of failed records List:\n'+
        recordList +'\n\n'+
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}