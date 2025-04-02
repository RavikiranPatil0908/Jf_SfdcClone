public with sharing class DateHelper {
    public List<Date> getAllDatesBetweenTwoDates(Date StartDate, Date EndDate) {
        // Date startDate = date.parse('26/11/2021');
        // String dtCheck = startDate.format('EEEE');
        // system.debug(dtCheck);
        system.debug('StartDate --> ' + StartDate);
        system.debug('EndDate --> ' + EndDate);
        List<Date> datesBetweenStartEnd = new List<Date>();
        if(String.isNotBlank(String.valueOf(StartDate)) &&  String.isNotBlank(String.valueOf(EndDate))) {
            
            while(StartDate < EndDate) {
                Date newDate = StartDate.addDays(1);
                datesBetweenStartEnd.add(newDate);
                StartDate = newDate;
            }
            system.debug('datesBetweenStartEnd --> '+ datesBetweenStartEnd);
            return datesBetweenStartEnd;
        } else {
            return new List<Date>();
        }

    }

    public List<Date> getDateIgnoringSunday(List<Date> lstDates) {
        system.debug('getDateIgnoringSunday --> '+ lstDates);
        if(lstDates.size() > 0) {
            List<Date> lstDateIgnoringSunday = new List<Date>();
            for(Date dat : lstDates) {
                DateTime myDateTime = (DateTime) dat;
                if(myDateTime.format('EEEE') != 'Sunday') {
                    lstDateIgnoringSunday.add(dat);
                }
            }
            system.debug('lstDateIgnoringSunday --> ' + lstDateIgnoringSunday);
            return lstDateIgnoringSunday;
        } else {
            return new List<Date>();
        }
    }

    public List<Date> getDateIgnoringHolidayList(List<Date> lstDates) {
        List<Date> lstDateIgnoringHoliday = new List<Date>();
        if(lstDates.size() > 0) {
            Date StartDate = lstDates[0];
            Date EndDate = lstDates[lstDates.size() - 1];
            List<Holiday_List__c> lstHolidayList = [SELECT Id, Holiday_Date__c FROM Holiday_List__c WHERE Holiday_Date__c >= :StartDate AND Holiday_Date__c <= :EndDate ];
            if(lstHolidayList.size() > 0) {
                system.debug('lstHolidayList --> ' + lstHolidayList);
                List<Date> lstOfHolidays = new List<Date>();
                for(Holiday_List__c objHoliday: lstHolidayList) {
                    lstOfHolidays.add(objHoliday.Holiday_Date__c);
                }
                for(Date dateOf: lstDates) {
                    if(!lstOfHolidays.contains(dateOf)) {
                        lstDateIgnoringHoliday.add(dateOf);
                    }
                }
                system.debug('lstDateIgnoringHoliday --> ' + lstDateIgnoringHoliday);
            } else {
                lstDateIgnoringHoliday.addAll(lstDates);
            }
            return lstDateIgnoringHoliday;
        } else {
            return new List<Date>();
        }
    }
}