/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-12-2024
 * @last modified by  : @BK
**/
public without sharing class CustomQueryMock extends Query {
    
    // Store the specific query to mock based on object type and query string
    public Map<String, List<SObject>> queryMocks = new Map<String, List<SObject>>();

    // Override the passThrough method to provide custom mock data for different queries
    protected override List<SObject> passThrough(List<SObject> input, String objectType) {
        // If we have mock data for the object type, return the corresponding mock data
        if (queryMocks.containsKey(objectType)) {
            return queryMocks.get(objectType);
        }
        // If no mock data exists, call the default passThrough behavior
        return super.passThrough(input, objectType);
    }

    // Method to add mock data for a query
    public void setQueryMock(String objectType, List<SObject> mockData) {
        queryMocks.put(objectType, mockData);
    }
}