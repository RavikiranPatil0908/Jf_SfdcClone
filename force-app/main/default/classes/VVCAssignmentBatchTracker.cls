/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 25-01-2025
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
private class VVCAssignmentBatchTracker {

    @TestSetup
    static void makeData(){ 
        nm_Program__c prog = new nm_Program__c(Name='MBA(WX) - DM', nm_TotalSemesters__c=5, PVM__c=30);
        insert prog;

        Id personAccRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(FirstName='Test123', LastName='abc', RecordTypeId = personAccRecordTypeId, nm_StudentNo__c='77119958556', nm_RegistrationNumber__c='745123669000',nm_Program__c=prog.Id , PersonMobilePhone='8652532023',PersonEmail='priyankakorade22@gmail.com');
        insert acc;

        String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket, Account=acc);
        insert c1;

        DateTime currentDateTime = VVCAssignmentBatch.getUpcomingQuarterHour(System.now());
        VVC_Junction__c vvc1 = new VVC_Junction__c(Call_Date__c = System.today(), Schedule_Call_Time__c = currentDateTime, Status__c = 'In Progress');
        VVC_Junction__c vvc2 = new VVC_Junction__c(Call_Date__c = System.today().addDays(1), Schedule_Call_Time__c = currentDateTime, Status__c = 'In Progress');
        insert new List<VVC_Junction__c>{vvc1, vvc2};
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
            // Step 1: Create the mock class and set it
            CustomQueryMock mock = mockAgentData();
            Query.setMock(mock);
        
            // Instantiate the batch class and execute
            VVCAssignmentBatch batch = new VVCAssignmentBatch();
            Database.executeBatch(batch, 200);

        Test.stopTest();
    }

    @isTest
    static void testFetchAvailableAgents() {
        Test.startTest();
            // Step 1: Create the mock class and set it
            CustomQueryMock mock = mockAgentData();
            Query.setMock(mock);

            // Step 3: Call the method to test
            Set<Id> availableAgents = VVCAssignmentBatch.fetchAvailableAgents();
        Test.stopTest();

        // Step 4: Assert the behavior
        // Ensure the mock is working and the method returns the mocked agents
        System.assertNotEquals(true, availableAgents.isEmpty(), 'Available agents should be returned');
    }

    @isTest
    static void testGetUpcomingQuarterHour() {
        
        // Test case 1: Current time is 5 minutes past the hour (e.g., 12:05)
        DateTime currentTime = DateTime.newInstance(2024, 12, 12, 12, 5, 0); // 12:05:00
        DateTime upcomingQuarterHour = VVCAssignmentBatch.getUpcomingQuarterHour(currentTime);
        DateTime expectedTime1 = DateTime.newInstance(2024, 12, 12, 12, 15, 0); // Expect 12:15
        System.debug('Upcoming Quarter Hour (12:05) -> ' + upcomingQuarterHour);
        System.assertEquals(expectedTime1, upcomingQuarterHour, 'Test failed: Expected 12:15');
        
        // Test case 2: Current time is 20 minutes past the hour (e.g., 12:20)
        currentTime = DateTime.newInstance(2024, 12, 12, 12, 20, 0); // 12:20:00
        upcomingQuarterHour = VVCAssignmentBatch.getUpcomingQuarterHour(currentTime);
        DateTime expectedTime2 = DateTime.newInstance(2024, 12, 12, 12, 30, 0); // Expect 12:30
        System.debug('Upcoming Quarter Hour (12:20) -> ' + upcomingQuarterHour);
        System.assertEquals(expectedTime2, upcomingQuarterHour, 'Test failed: Expected 12:30');
        
        // Test case 3: Current time is 45 minutes past the hour (e.g., 12:45)
        currentTime = DateTime.newInstance(2024, 12, 12, 12, 45, 0); // 12:45:00
        upcomingQuarterHour = VVCAssignmentBatch.getUpcomingQuarterHour(currentTime);
        DateTime expectedTime3 = DateTime.newInstance(2024, 12, 12, 13, 0, 0); // Expect 13:00
        System.debug('Upcoming Quarter Hour (12:45) -> ' + upcomingQuarterHour);
        System.assertEquals(expectedTime3, upcomingQuarterHour, 'Test failed: Expected 13:00');
        
        // Test case 4: Current time is 59 minutes past the hour (e.g., 12:59)
        currentTime = DateTime.newInstance(2024, 12, 12, 12, 59, 0); // 12:59:00
        upcomingQuarterHour = VVCAssignmentBatch.getUpcomingQuarterHour(currentTime);
        DateTime expectedTime4 = DateTime.newInstance(2024, 12, 12, 13, 0, 0); // Expect 13:00
        System.debug('Upcoming Quarter Hour (12:59) -> ' + upcomingQuarterHour);
        System.assertEquals(expectedTime4, upcomingQuarterHour, 'Test failed: Expected 13:00');
        
        // Test case 5: Midnight boundary case (e.g., 23:59)
        currentTime = DateTime.newInstance(2024, 12, 12, 23, 59, 0); // 23:59:00
        upcomingQuarterHour = VVCAssignmentBatch.getUpcomingQuarterHour(currentTime);
        DateTime expectedTime5 = DateTime.newInstance(2024, 12, 13, 0, 0, 0); // Expect 00:00 of the next day
        System.debug('Upcoming Quarter Hour (23:59) -> ' + upcomingQuarterHour);
        System.assertEquals(expectedTime5, upcomingQuarterHour, 'Test failed: Expected 00:00 on 2024-12-13');

        // Test case 6: Current time is 45 minutes past the hour (e.g., 12:30)
        currentTime = DateTime.newInstance(2024, 12, 12, 12, 30, 0); // 12:30:00
        upcomingQuarterHour = VVCAssignmentBatch.getUpcomingQuarterHour(currentTime);
        DateTime expectedTime6 = DateTime.newInstance(2024, 12, 12, 12, 45, 0); // Expect 12:45
        System.debug('Upcoming Quarter Hour (12:30) -> ' + upcomingQuarterHour);
        System.assertEquals(expectedTime6, upcomingQuarterHour, 'Test failed: Expected 12:45');
    }
    
    @isTest
    static void testFetchAvailableAgentsWithNoAgents() {
        Test.startTest();
            // Simulate the agent is not available
            Set<Id> availableAgents = VVCAssignmentBatch.fetchAvailableAgents();
        Test.stopTest();
        
        // Ensure that there are available agents returned
        System.assertEquals(true, availableAgents.isEmpty(), 'There should be no agents returned by fetchAvailableAgents');
    }

    @isTest
    static void testFetchAvailableAgentsWithNoSkills() {
        Test.startTest();
            Id servicePresenceStatusId = [SELECT Id FROM ServicePresenceStatus WHERE MasterLabel = 'Available - VVC' LIMIT 1].Id;

            // Step 1: Create the mock class and set it
            CustomQueryMock mock = new CustomQueryMock();

            // Create a test User record (agents)
            User agent1 = new User(Alias = 'agen1', Email = 'agent1@test.com', ProfileId = UserInfo.getProfileId(), 
                                TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LastName = 'texst',
                                LanguageLocaleKey = 'en_US', UserName = 'agent1.omni@test.com', EmailEncodingKey='UTF-8');
            insert agent1;

            // Mock Data for the first query (UserServicePresence)
            List<UserServicePresence> userServicePresenceMock = new List<UserServicePresence>{
                new UserServicePresence(
                    UserId = agent1.Id,
                    ServicePresenceStatusId = servicePresenceStatusId
                )
            };
            mock.setQueryMock('UserServicePresence', userServicePresenceMock);
            
            Query.setMock(mock);

            // Simulate the agent is not available
            Set<Id> availableAgents = VVCAssignmentBatch.fetchAvailableAgents();
        Test.stopTest();
        // Ensure that there are available agents returned
        System.assertEquals(true, availableAgents.isEmpty(), 'There should be no agents returned by fetchAvailableAgents');
    }

    @isTest
    static void testGetAlreadyAssignedVVCIds() {
        Test.startTest();
            List<VVC_Junction__c> scope = [SELECT Id, Name, Schedule_Call_Time__c, Status__c FROM VVC_Junction__c LIMIT 1];
            Id serviceChannelId = [SELECT Id FROM ServiceChannel WHERE MasterLabel = 'VVC' LIMIT 1].Id;

            // Step 1: Create the mock class and set it
            CustomQueryMock mock = new CustomQueryMock();
            // Mock Data for the first query (AgentWork)
            List<AgentWork> lstAgentWork = new List<AgentWork>{
                new AgentWork(
                    UserId = UserInfo.getUserId(),
                    WorkItemId = scope[0].Id,
                    ServiceChannelId = serviceChannelId, // Ensure this is set
                    CapacityWeight = 25 // Set the capacity weight or any other necessary parameters
                )
            };
            mock.setQueryMock('AgentWork', lstAgentWork);

            Query.setMock(mock);
            
            List<Id> duplicateVVCIds = VVCAssignmentBatch.getAlreadyAssignedVVCIds(scope);
        Test.stopTest();
        // Verify that the duplicate VVC Id is returned
        System.assertEquals(1, duplicateVVCIds.size(), 'There should be one duplicate VVC Id');
        System.assertEquals(scope[0].Id, duplicateVVCIds[0], 'The duplicate VVC Id should match the inserted work item');
    }

    /**
    * @description 
    * @author @BK | 13-12-2024 
    * @return CustomQueryMock 
    **/
    public static CustomQueryMock mockAgentData() {
        List<VVC_Junction__c> lstVVC = [SELECT id FROM VVC_Junction__c WHERE Call_Date__c = TOMORROW LIMIT 1];
        Id serviceChannelId = [SELECT Id FROM ServiceChannel WHERE MasterLabel = 'VVC' LIMIT 1].Id;
        Id servicePresenceStatusId = [SELECT Id FROM ServicePresenceStatus WHERE MasterLabel = 'Available - VVC' LIMIT 1].Id;

        // Step 1: Create the mock class and set it
        CustomQueryMock mock = new CustomQueryMock();

        // Create a test User record (agents)
        User agent1 = new User(Alias = 'agen1', Email = 'agent1@test.com', ProfileId = UserInfo.getProfileId(), 
                            TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LastName = 'texst',
                            LanguageLocaleKey = 'en_US', UserName = 'agent1.omni@test.com', EmailEncodingKey='UTF-8');
        insert agent1;

        // Mock Data for the first query (UserServicePresence)
        List<UserServicePresence> userServicePresenceMock = new List<UserServicePresence>{
            new UserServicePresence(
                UserId = agent1.Id,
                ServicePresenceStatusId = servicePresenceStatusId
            )
        };
        mock.setQueryMock('UserServicePresence', userServicePresenceMock);

        // Mock Data for the first query (AgentWork)
        List<AgentWork> lstAgentWork = new List<AgentWork>{
            new AgentWork(
                UserId = agent1.Id,
                WorkItemId = lstVVC[0].Id,
                ServiceChannelId = serviceChannelId, // Ensure this is set
                CapacityWeight = 25 // Set the capacity weight or any other necessary parameters
            )
        };
        mock.setQueryMock('AgentWork', lstAgentWork);

        Skill skillVVC = [SELECT Id FROM Skill WHERE MasterLabel = 'VVC' LIMIT 1];

        ServiceResource sr = new ServiceResource(RelatedRecordId = agent1.Id, Name = agent1.LastName, Ozontel_Id__c = 'testtest',
                                                    IsActive = true,ResourceType = 'A');
        insert sr;

        insert new ServiceResourceSkill(EffectiveStartDate = System.now(),
                                            ServiceResourceId = sr.Id,
                                            SkillId = skillVVC.Id);

        return mock;
    }
}