@isTest
private class GetUniversityListTracker {

    @isTest
    static void testGetUniversityDetails() {

        University_List__c activeUniversity = new University_List__c(
            University_Name__c = 'Test University',
            University_Type__c = 'Public',
            Is_Active__c = true
        );
        insert activeUniversity;
        
        University_List__c inactiveUniversity = new University_List__c(
            University_Name__c = 'Inactive University',
            University_Type__c = 'Private',
            Is_Active__c = false
        );
        insert inactiveUniversity;

        Test.startTest();
        List<University_List__c> result = GetUniversityList.getUniversityDetails();
        Test.stopTest();
       
    }
}