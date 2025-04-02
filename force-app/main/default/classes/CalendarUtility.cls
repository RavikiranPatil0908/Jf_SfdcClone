/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-12-2023
 * @last modified by  : @BK
**/
public without sharing class CalendarUtility {
    private static CalendarUtility utils { get; private set; }
    public List<Calender__c> lstCalendar { get; private set; }

    public CalendarUtility() {
        this.lstCalendar = getCalendar();
    }

    public static CalendarUtility getInstance() {
        if(utils == null) {
            utils = new CalendarUtility();
        }
        return utils;
    }

    public List<Calender__c> getCalendar() {
        List<Calender__c> lstCalendar = [SELECT id,Session_End_Date__c,Session_Start_Date__c,Name,Closed_Date__c,Category__c,Closure_Message__c,Year__c,
            FinalDateForCancellation__c,Last_Date_for_Cancellation__c,Last_Date_To_Change_Lecture__c,LectureDeliveryStartRange__c,Live_Lecture_Switch_Date__c,
            Live_Lecture_Switch_Date_2__c,Live_Lecture_Switch_Date_3__c,Live_Lecture_Switch_Date_4__c,nm_Semester__c,Session__c,Specialisation__c,nm_Type__c
            FROM Calender__c WHERE Session_End_Date__c>=Today AND Session_Start_Date__c<=Today AND Category__c='Admission'];
        System.debug('On Util ==>'+lstCalendar.size());
        return lstCalendar;
    }

}