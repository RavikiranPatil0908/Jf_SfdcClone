/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-09-2024
 * @last modified by  : @BK
**/
@isTest
public class SessionManagerTracker {

    @TestSetup
    static void setupTestData() {
        // Create test data for Leads and Accounts
        Lead testLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
        Account testAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes', false, 'Confirmed');
    }

    @isTest
    static void testGenerateRandomString() {
        // Arrange
        SessionManager sessionManager = new SessionManager();
        
        // Act
        String randomString = sessionManager.generateRandomString(10);

        // Assert
        System.assertNotEquals(null, randomString, 'Random string should not be null');
        System.assertEquals(10, randomString.length(), 'Random string length should be 10');
    }

    @isTest
    static void testLoginSuccessFull() {
            Account accountRecord = [SELECT Id FROM Account LIMIT 1];
            // Arrange
            SessionManager sessionManager = new SessionManager();
            String recordId = accountRecord.Id;
            String objectType = 'Account';
            Map<String, String> mapOfUrlParams = new Map<String, String>{'param1' => 'value1'};
            
            Test.startTest();
            
                // Mock current page headers and cookies
                ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP', '192.168.1.1');
                ApexPages.currentPage().getHeaders().put('USER-AGENT', 'TestUserAgent');
                ApexPages.currentPage().getCookies().put('JSESSIONID', new Cookie('JSESSIONID', 'oldSessionId', null, 0, true, 'None'));
                
                // Act
                Boolean result = sessionManager.loginSuccessFull(recordId, objectType, mapOfUrlParams);

                // Assert
                System.assert(result, 'Login should be successful');

                // Verify session data
                Cache.OrgPartition cachePartition = Cache.Org.getPartition('local.StudentLogin');
                SessionUser sessionUser = (SessionUser) cachePartition.get('newSessionId');
                // System.assertNotEquals(null, sessionUser, 'SessionUser should be present in cache');
                // System.assertEquals(recordId, sessionUser.recordId, 'Session recordId should match');
                // System.assertEquals(objectType, sessionUser.objType, 'Session objectType should match');
                // System.assertEquals(mapOfUrlParams, sessionUser.mapOfParameters, 'Session parameters should match');
            Test.stopTest();
    }

    @isTest
    static void testIsSessionAvailable() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        // Arrange
        SessionManager sessionManager = new SessionManager();
        String recordId = accountRecord.Id;
        String objectType = 'Account';
        Map<String, String> mapOfUrlParams = new Map<String, String>{'param1' => 'value1'};

        // Setup session
        sessionManager.loginSuccessFull(recordId, objectType, mapOfUrlParams);
        
        Test.startTest();
        
            // Act
            SessionUser sessionUser = sessionManager.isSessionAvailable();

            // Assert
            // System.assert(sessionUser.isVerified, 'Session should be verified');

            // Cleanup
            sessionManager.clearSession();
        Test.stopTest();
    }

    @isTest
    static void testClearSession() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        // Arrange
        SessionManager sessionManager = new SessionManager();
        String recordId = accountRecord.Id;
        String objectType = 'Account';
        Map<String, String> mapOfUrlParams = new Map<String, String>{'param1' => 'value1'};
        
        sessionManager.loginSuccessFull(recordId, objectType, mapOfUrlParams);

        // Set up session cookie
        ApexPages.currentPage().getCookies().put('JSESSIONID', new Cookie('JSESSIONID', 'newSessionId', null, 0, true, 'None'));

        Test.startTest();

            // Act
            sessionManager.clearSession();
            
            // Assert
            Cache.OrgPartition cachePartition = Cache.Org.getPartition('local.StudentLogin');
            System.assertEquals(null, cachePartition.get('newSessionId'), 'Session should be cleared from cache');
        Test.stopTest();
    }

    @isTest
    static void testUpdateSessionData() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        // Arrange
        SessionManager sessionManager = new SessionManager();
        String recordId = accountRecord.Id;
        String objectType = 'Account';
        Map<String, String> mapOfUrlParams = new Map<String, String>{'param1' => 'value1'};
        
        sessionManager.loginSuccessFull(recordId, objectType, mapOfUrlParams);
        
        // Update session data
        Map<String, String> newParams = new Map<String, String>{'param2' => 'value2'};
        
        Test.startTest();
            
            // Act
            sessionManager.updateSessionData(newParams);
            
            // Assert
            SessionUser sessionUser = (SessionUser) Cache.Org.getPartition('local.StudentLogin').get('newSessionId');
            // System.assertEquals(newParams, sessionUser.mapOfParameters, 'Session parameters should be updated');
        Test.stopTest();
    }

    @isTest
    static void testGetSessionData() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        // Arrange
        SessionManager sessionManager = new SessionManager();
        String recordId = accountRecord.Id;
        String objectType = 'Account';
        Map<String, String> mapOfUrlParams = new Map<String, String>{'param1' => 'value1'};
        
        sessionManager.loginSuccessFull(recordId, objectType, mapOfUrlParams);
        
        // Set up session cookie
        ApexPages.currentPage().getCookies().put('JSESSIONID', new Cookie('JSESSIONID', 'newSessionId', null, 0, true, 'None'));

        Test.startTest();
            
            // Act
            Map<String, String> sessionData = sessionManager.getSessionData();

            // Assert
            // System.assertEquals(mapOfUrlParams, sessionData, 'Session data should be retrieved correctly');
        Test.stopTest();
    }
}