/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : @BK
**/
@isTest
public class DynamicQueryBuilderTracker {

    @isTest
    static void testGetQueryAllFieldSqlValidInputs() {
        // Setup: Define test parameters
        String sObjectAPIName = 'Account'; // Ensure this SObject exists in your org
        String conditionString = 'Name = \'Acme\'';
        String relatedFields = 'Industry, AnnualRevenue';
        
        // Call the method
        String query = DynamicQueryBuilder.getQueryAllFieldSql(sObjectAPIName, conditionString, relatedFields);
        
        // Assert
        System.assertNotEquals('', query, 'The generated query is not Blank.');
    }

    @isTest
    static void testGetQueryAllFieldSqlEmptyConditionString() {
        // Setup: Define test parameters
        String sObjectAPIName = 'Contact'; // Ensure this SObject exists in your org
        String conditionString = '';
        String relatedFields = 'Email';
        
        try {
            DynamicQueryBuilder.getQueryAllFieldSql(sObjectAPIName, conditionString, relatedFields);
            System.assert(false, 'conditionString cannot be null or empty.');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('conditionString cannot be null or empty.'), 'Exception message does not match for invalid SObject.');
        }
    }

    @isTest
    static void testGetQueryAllFieldSqlNoRelatedFields() {
        // Setup: Define test parameters
        String sObjectAPIName = 'Opportunity'; // Ensure this SObject exists in your org
        String conditionString = 'StageName = \'Closed Won\'';
        String relatedFields = '';
        
        // Call the method
        String query = DynamicQueryBuilder.getQueryAllFieldSql(sObjectAPIName, conditionString, relatedFields);
        
        // Assert
        System.assertNotEquals('', query, 'The generated query is not Blank.');
    }

    @isTest
    static void testGetQueryAllFieldSqlInvalidSObject() {
        // Setup: Define test parameters
        String sObjectAPIName = 'NonExistentObject'; // This SObject does not exist
        String conditionString = 'SomeField = \'SomeValue\'';
        String relatedFields = '';
        
        // Expected exception
        try {
            DynamicQueryBuilder.getQueryAllFieldSql(sObjectAPIName, conditionString, relatedFields);
            System.assert(false, 'An exception should have been thrown for an invalid SObject.');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Invalid SObject API name'), 'Exception message does not match for invalid SObject.');
        }
    }

    @isTest
    static void testGetQueryAllFieldSqlEmptySObjectName() {
        // Setup: Define test parameters
        String sObjectAPIName = ''; // Empty SObject name
        String conditionString = 'SomeField = \'SomeValue\'';
        String relatedFields = '';
        
        // Expected exception
        try {
            DynamicQueryBuilder.getQueryAllFieldSql(sObjectAPIName, conditionString, relatedFields);
            System.assert(false, 'An exception should have been thrown for an empty SObject name.');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('SObject API name cannot be null or empty'), 'Exception message does not match for empty SObject name.');
        }
    }
}