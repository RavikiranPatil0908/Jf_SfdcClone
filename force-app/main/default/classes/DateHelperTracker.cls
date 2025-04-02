@IsTest
public with sharing class DateHelperTracker {
    @TestSetup
    static void makeData(){
        Date todayDate = Date.today();

        Holiday_List__c objHolidayList1 = new Holiday_List__c();
        objHolidayList1.Holiday_Date__c = todayDate.addDays(5);
        insert objHolidayList1;

        Holiday_List__c objHolidayList2 = new Holiday_List__c();
        objHolidayList2.Holiday_Date__c = todayDate.addDays(8);
        insert objHolidayList2;

        Holiday_List__c objHolidayList3 = new Holiday_List__c();
        objHolidayList3.Holiday_Date__c = todayDate.addDays(13);
        insert objHolidayList3;
    }

    @IsTest
    static void methodName(){
        Date TodayDate = Date.Today(); 
        Date StartDate = TodayDate;
        Date EndDate = TodayDate.addDays(38);
        Test.startTest();
        DateHelper dateHelper = new DateHelper();
        List<Date> lstDate = dateHelper.getAllDatesBetweenTwoDates(StartDate, EndDate);
        dateHelper.getDateIgnoringHolidayList(lstDate);
        dateHelper.getDateIgnoringHolidayList(lstDate);
        
        Test.stopTest();
        
    }


}