/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-27-2024
 * @last modified by  : @BK
**/
public without sharing class EscalationHandler {

    /**
     * Main method to handle escalation dates and reminders for a list of leads.
     * @param lstLead      : List of leads to process.
     * @param oldMapLead   : Map of existing lead records before changes.
     */
    public static void handleEscalationDate(List<Lead> lstLead, Map<Id, Lead> oldMapLead) {
        Map<String, nm_EscalationMatrix__c> mapEscalationMatrix = getEscalationMatrixMap();
        
        for (Lead objLead : lstLead) {
            if (shouldProcessLead(objLead)) {
                processLead(objLead, oldMapLead, mapEscalationMatrix);
            }
        }
    }

    /**
     * Retrieves the escalation matrix settings from the database and stores them in a map.
     * @return Map<String, nm_EscalationMatrix__c> : Map of escalation matrix settings with names as keys.
     */
    private static Map<String, nm_EscalationMatrix__c> getEscalationMatrixMap() {
        Map<String, nm_EscalationMatrix__c> mapEscalationMatrix = new Map<String, nm_EscalationMatrix__c>();
        List<nm_EscalationMatrix__c> nmSettings = nm_EscalationMatrix__c.getAll().Values();
        if (nmSettings != null && !nmSettings.isEmpty()) {
            for (nm_EscalationMatrix__c objSetting : nmSettings) {
                mapEscalationMatrix.put(objSetting.Name.toLowerCase(), objSetting);
            }
        }
        return mapEscalationMatrix;
    }

    /**
     * Determines if the lead should be processed based on its contact status and planned start date.
     * @param objLead : Lead record to check.
     * @return Boolean : True if the lead should be processed, otherwise false.
     */
    private static Boolean shouldProcessLead(Lead objLead) {
        return objLead.nm_LeadContacted__c != 'Yes' && objLead.nm_PlantoStart__c != null;
    }

    /**
     * Processes the escalation and reminder dates for a given lead based on escalation settings.
     * @param objLead             : Lead record to process.
     * @param oldMapLead          : Map of existing lead records before changes.
     * @param mapEscalationMatrix : Map of escalation matrix settings.
     */
    private static void processLead(Lead objLead, Map<Id, Lead> oldMapLead, Map<String, nm_EscalationMatrix__c> mapEscalationMatrix) {
        DateTime dtEsc = getInitialEscalationDate(objLead);
        DateTime dtReminder = dtEsc;

        String strHours = getEscalationHours(objLead, oldMapLead, mapEscalationMatrix);
        String strMailHours = getReminderHours(objLead, oldMapLead, mapEscalationMatrix);

        if (String.isNotBlank(strHours)) {
            dtEsc = calculateDateTime(dtEsc, strHours);
            objLead.nm_Dateforescallation__c = dtEsc;
        }

        if (String.isNotBlank(strMailHours)) {
            dtReminder = calculateDateTime(dtReminder, strMailHours);
            objLead.nm_ReminderEmailTime__c = dtReminder;
        }
    }

    /**
     * Retrieves the initial escalation date for a lead. Defaults to the current system time if not set.
     * @param objLead : Lead record to check.
     * @return DateTime : Initial escalation date.
     */
    private static DateTime getInitialEscalationDate(Lead objLead) {
        return objLead.nm_Dateforescallation__c != null ? objLead.nm_Dateforescallation__c : System.now();
    }

    /**
     * Retrieves reminder hours based on the lead's escalation level and settings.
     * @param objLead             : Lead record to check.
     * @param oldMapLead          : Map of existing lead records before changes.
     * @param mapEscalationMatrix : Map of escalation matrix settings.
     * @return String : Escalation hours as a string in "HH:MM" format.
     */
    private static String getEscalationHours(Lead objLead, Map<Id, Lead> oldMapLead, Map<String, nm_EscalationMatrix__c> mapEscalationMatrix) {
        String key = objLead.nm_PlantoStart__c.toLowerCase();
        nm_EscalationMatrix__c settings = mapEscalationMatrix.get(key);

        if (settings == null) {
            return null;
        }

        if ((objLead.nm_EscallationDone__c == 0 || objLead.nm_EscallationDone__c == null) && objLead.nm_Dateforescallation__c == null) {
            return settings.nm_LCEscalationTime__c;
        } else if (objLead.nm_EscallationDone__c == 1 && oldMapLead.get(objLead.id).nm_EscallationDone__c != 1) {
            return settings.nm_HOEscalationTime__c;
        } else if (objLead.nm_EscallationDone__c == 2 && oldMapLead.get(objLead.id).nm_EscallationDone__c != 2) {
            return settings.nm_SMLCEscalationTime__c;
        }
        return null;
    }

    /**
     * Retrieves reminder hours based on the lead's escalation level and settings.
     * @param objLead             : Lead record to check.
     * @param oldMapLead          : Map of existing lead records before changes.
     * @param mapEscalationMatrix : Map of escalation matrix settings.
     * @return String : Escalation hours as a string in "HH:MM" format.
     */
    private static String getReminderHours(Lead objLead, Map<Id, Lead> oldMapLead, Map<String, nm_EscalationMatrix__c> mapEscalationMatrix) {
        String key = objLead.nm_PlantoStart__c.toLowerCase();
        nm_EscalationMatrix__c settings = mapEscalationMatrix.get(key);

        if (settings == null) {
            return null;
        }

        if ((objLead.nm_EscallationDone__c == 0 || objLead.nm_EscallationDone__c == null) && objLead.nm_Dateforescallation__c == null) {
            return settings.nm_RemidertoIC__c;
        } else if (objLead.nm_EscallationDone__c == 1 && oldMapLead.get(objLead.id).nm_EscallationDone__c != 1) {
            return settings.nm_RemidertoLC__c;
        } else if (objLead.nm_EscallationDone__c == 2 && oldMapLead.get(objLead.id).nm_EscallationDone__c != 2) {
            return settings.nm_RemidertoHO__c;
        }
        return null;
    }

    /**
     * Calculates the escalation or reminder date by adding hours and minutes to a given DateTime.
     * Handles business hours and holidays.
     * @param dtCheck : Initial DateTime to adjust.
     * @param strTime : String representing hours and minutes in "HH:MM" format.
     * @return DateTime : Updated DateTime after adding hours and minutes.
     */
    private static DateTime calculateDateTime(DateTime dtCheck, String strTime) {
        String[] arrTime = strTime.split(':');
        Integer intHours = Integer.valueOf(arrTime[0]);
        Integer intMins = Integer.valueOf(arrTime[1]);
        return adjustDateTimeForBusinessHours(dtCheck.addHours(intHours).addMinutes(intMins), intHours, intMins);
    }


    /**
    * Adjusts the DateTime considering business hours and holidays.
    * @param dtCheck 
    * @param intHours 
    * @param intMins 
    * @return DateTime 
    **/
    private static DateTime adjustDateTimeForBusinessHours(DateTime dtCheck, Integer intHours, Integer intMins) {
        List<SystemConfiguration__c> nmConfigSettings = SystemConfiguration__c.getAll().Values();
        if (nmConfigSettings.isEmpty()) {
            return dtCheck;
        }

        SystemConfiguration__c config = nmConfigSettings[0];
        Time tmStartTime = Time.newInstance(Integer.valueOf(config.nm_BusinessHoursStartTime__c.substring(0, 2)),
                                             Integer.valueOf(config.nm_BusinessHoursStartTime__c.substring(3, 5)), 0, 0);
        Time tmEndTime = Time.newInstance(Integer.valueOf(config.nm_BusinessHoursEndTime__c.substring(0, 2)),
                                           Integer.valueOf(config.nm_BusinessHoursEndTime__c.substring(3, 5)), 0, 0);

        Time tmCheck = Time.newInstance(dtCheck.hour(), dtCheck.minute(), 0, 0);

        if (!isBusinessDay(dtCheck) || tmCheck > tmEndTime) {
            return adjustForNonBusinessHours(dtCheck, tmStartTime);
        }

        if (tmCheck < tmStartTime) {
            return adjustForEarlyArrival(dtCheck, tmStartTime);
        }

        return adjustForEscalation(dtCheck, tmStartTime, tmEndTime, intHours, intMins);
    }

    /**
     * Adjusts the DateTime if it is outside of business hours or on a non-business day.
     * @param dtCheck : Initial DateTime to adjust.
     * @param tmStartTime : Business start time.
     * @return DateTime : Adjusted DateTime.
     */
    private static DateTime adjustForNonBusinessHours(DateTime dtCheck, Time tmStartTime) {
        DateTime adjustedDt = generateDateTime(dtCheck, tmStartTime);
        adjustedDt = adjustedDt.addDays(1);

        while (!isBusinessDay(adjustedDt)) {
            adjustedDt = adjustedDt.addDays(1);
        }

        return adjustedDt;
    }

    /**
     * Adjusts the DateTime if it is before business hours.
     * @param dtCheck : Initial DateTime to adjust.
     * @param tmStartTime : Business start time.
     * @return DateTime : Adjusted DateTime.
     */
    private static DateTime adjustForEarlyArrival(DateTime dtCheck, Time tmStartTime) {
        DateTime adjustedDt = generateDateTime(dtCheck, tmStartTime);

        while (!isBusinessDay(adjustedDt)) {
            adjustedDt = adjustedDt.addDays(1);
        }

        return adjustedDt;
    }


    /**
    * Adjusts the DateTime if the time is during business hours but exceeds the end time.
    * @param dtCheck 
    * @param tmStartTime 
    * @param tmEndTime 
    * @param intHours 
    * @param intMins 
    * @return DateTime 
    **/
    private static DateTime adjustForEscalation(DateTime dtCheck, Time tmStartTime, Time tmEndTime, Integer intHours, Integer intMins) {
        dtCheck = dtCheck.addHours(intHours);
        dtCheck = dtCheck.addMinutes(intMins);
        Time tmCheck = Time.newInstance(dtCheck.hour(), dtCheck.minute(), 0, 0);

        if (tmCheck > tmEndTime) {
            DateTime adjustedDt = generateDateTime(dtCheck, tmStartTime);
            adjustedDt = adjustedDt.addDays(1);
            tmCheck = tmCheck.addHours(-tmEndTime.hour());
            tmCheck = tmCheck.addMinutes(-tmEndTime.minute());
            adjustedDt = adjustedDt.addMinutes(tmCheck.hour() * 60 + tmCheck.minute());

            while (!isBusinessDay(adjustedDt)) {
                adjustedDt = adjustedDt.addDays(1);
            }

            return adjustedDt;
        }

        while (!isBusinessDay(dtCheck)) {
            dtCheck = dtCheck.addDays(1);
        }

        return dtCheck;
    }

    /**
    * @description 
    * @author @BK | 08-27-2024 
    * @param dtCheck 
    * @param tmStartTime 
    * @return DateTime 
    **/
    private static DateTime generateDateTime(DateTime dtCheck, Time tmStartTime) {
        return DateTime.newInstance(
            dtCheck.year(), dtCheck.month(), dtCheck.day(),
            tmStartTime.hour(), tmStartTime.minute(), 0
        );
    }

    /**
     * Checks if a given date is a business day (i.e., not a weekend).
     * @param dtCheck : DateTime to check.
     * @return Boolean : True if it is a business day, otherwise false.
     */
    private static Boolean isBusinessDay(DateTime dtCheck) {
        return dtCheck != null && dtCheck.format('EEEE') != 'Sunday';
    }
}