@isTest(SeeAllData=false)
public without sharing class AsyncShootandJunctionHelperTracker {
    public AsyncShootandJunctionHelperTracker() {

    }
    @isTest
    static void Test1() {
        Test.startTest();
         AsyncShootandJunctionHelper asyncwrapp = new AsyncShootandJunctionHelper();
         asyncwrapp.getWrappervalue();
        Test.stopTest();

    }
}