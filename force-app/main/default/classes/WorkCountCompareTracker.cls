/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-12-2024
 * @last modified by  : @BK
**/
@isTest
public class WorkCountCompareTracker {

    @isTest
    static void testWorkCountCompare() {
        // Step 1: Set up mock data
        // Create users
        Id userId1 = UserInfo.getUserId(); // Simulate existing user
        Id userId2 = '005xx000001Sv6WAAR'; // Simulate another user ID (replace with a valid Id)
        Id userId3 = '005xx000001Sv6XAAZ'; // Simulate another user ID (replace with a valid Id)

        // Create a map of user work counts
        Map<Id, Integer> mapOfUserIdVsCount = new Map<Id, Integer>();
        mapOfUserIdVsCount.put(userId1, 2);
        mapOfUserIdVsCount.put(userId2, 0);
        mapOfUserIdVsCount.put(userId3, 5);

        // Step 2: Instantiate the comparator
        WorkCountCompare comparator = new WorkCountCompare(mapOfUserIdVsCount);

        // Step 3: Create a list of user IDs to sort
        List<Id> userIds = new List<Id>{userId1, userId2, userId3};

        // Step 4: Sort the list using the comparator
        userIds.sort(comparator);

        // Step 5: Assert that the list is sorted correctly by work count
        System.assertEquals(userIds[0], userId2, 'User with 0 work should be first');
        System.assertEquals(userIds[1], userId1, 'User with 2 works should be second');
        System.assertEquals(userIds[2], userId3, 'User with 5 works should be last');
    }

    @isTest
    static void testWorkCountCompareWithMissingCounts() {
        // Step 1: Set up mock data with missing work counts
        Id userId1 = UserInfo.getUserId(); // Simulate existing user
        Id userId2 = '005xx000001Sv6WAAR'; // Simulate another user ID (replace with a valid Id)
        Id userId3 = '005xx000001Sv6XAAZ'; // Simulate another user ID (replace with a valid Id)

        // Create a map of user work counts (userId3 is missing from the map)
        Map<Id, Integer> mapOfUserIdVsCount = new Map<Id, Integer>();
        mapOfUserIdVsCount.put(userId1, 2);
        mapOfUserIdVsCount.put(userId2, 0);

        // Step 2: Instantiate the comparator
        WorkCountCompare comparator = new WorkCountCompare(mapOfUserIdVsCount);

        // Step 3: Create a list of user IDs to sort
        List<Id> userIds = new List<Id>{userId1, userId2, userId3};

        // Step 4: Sort the list using the comparator
        userIds.sort(comparator);

        // Step 5: Assert that the list is sorted correctly by work count, 
        // assuming that missing counts default to 0 work count
        System.assertEquals(userIds[0], userId2, 'User with 0 work should be first');
        System.assertEquals(userIds[1], userId3, 'User with missing work count should be treated as 0 and 2nd');
        System.assertEquals(userIds[2], userId1, 'User with 2 works should be second');
    }
}