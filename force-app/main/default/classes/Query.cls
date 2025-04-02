/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-12-2024
 * @last modified by  : @BK
**/
public virtual class Query {
    static Query instance = new Query();

    @TestVisible static void setMock(Query mock) {
        instance = mock;
    }

    public static List<SObject> records(List<SObject> input, String objectType) {
        return instance.passThrough(input, objectType);
    }

    protected virtual List<SObject> passThrough(List<SObject> input, String objectType) {
        return input; // Default behavior, can be overridden in mock
    }
}