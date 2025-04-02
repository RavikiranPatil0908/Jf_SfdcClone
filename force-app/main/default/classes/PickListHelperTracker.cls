@isTest
public class PickListHelperTracker {
    public PickListHelperTracker() {

    }
    @isTest
    static void unitTest1() {
        Test.startTest();
        PickListHelper.getPickListValuesForAccountCategory();
        PickListHelper.getPickListValuesForLeadCategory();
        Test.stopTest();

    }
}