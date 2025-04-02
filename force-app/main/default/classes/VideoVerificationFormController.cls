/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : @vickysahu
**/
public class VideoVerificationFormController {
    
    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param recordId 
    * @return VideoWrapper 
    **/
    @AuraEnabled(Cacheable=true)
    public static VideoWrapper getAccount(String recordId) {
        try {
            VideoWrapper wrapper = new VideoWrapper();
            List<Opportunity> lstOpp = new List<Opportunity>();
            // Calender__c objCalender = new Calender__c();
            //wrapper.cancelDate = '';
            wrapper.validityDate = '';
            // wrapper.cancelDate2 = '';
            List<Account> lstAccount = [SELECT Id, Differently_abled__c, nm_StudentImageUrl__c, nm_Program__r.nm_ProgramValidity__c, nm_Program__r.Specialisation__c, nm_Program__r.nm_ProgramDuration__c, nm_Program__r.nm_ProgramName__c, is_Video_Call_Verified__c, Salutation, FirstName, nm_DateOfBirth__c, LastName, nm_RegistrationNumber__c, nm_Program__r.Name, IC_Name__c, PersonMobilePhone, PersonEmail,nm_ProgramType__c,nm_Gender__c,Specialization_Type__c,nm_Program2__r.nm_ProgramName__c,OwnerId FROM Account WHERE Id=:recordId LIMIT 1];
            if (lstAccount.size() > 0) {
                lstOpp = [SELECT Id,Applied_For_Loan__c,Loan_Type__c,Tenure__c,Loan_Amount__c,Is_Re_Registration_Payment__c,nm_Session__c,nm_Year__c,nm_Semester__c,nm_Category__c,Loan_Order_Status__c,Loan_Approved__c,Down_Payment_Made__c FROM Opportunity WHERE AccountId=: recordId AND Is_Re_Registration_Payment__c=false AND (nm_Category__c='Admission' OR nm_Category__c='Lateral Admission') LIMIT 1];
                wrapper.acc = lstAccount[0];
                if (lstOpp.size() > 0) {
                    //Calender__c obj = new Calender__c();
                    /*List<Calender__c> lstCalender = [SELECT Id,Last_Date_for_Cancellation__c,Session__c,Year__c,Category__c,nm_Type__c,Specialisation__c FROM Calender__c WHERE Category__c='Admission' AND Session_Start_Date__c <= Today AND Session_End_Date__c >= Today];
                    objCalender = getCalender(lstCalender,lstAccount[0]);
                    System.debug('objCalender--->' + objCalender);
                    if (objCalender != null) {
                        List<String> months = new List<String>{
                            'January', 'February', 'March', 'April', 'May', 'June', 
                            'July', 'August', 'September', 'October', 'November', 'December'
                        };
                        System.debug('objCalender.Last_Date_for_Cancellation__c---->' + objCalender.Last_Date_for_Cancellation__c);
                    
                        Date lastDate = objCalender.Last_Date_for_Cancellation__c == null ? Date.today().addDays(-1) : objCalender.Last_Date_for_Cancellation__c;
                        wrapper.cancelDate = lastDate.Day() + '/' + lastDate.Month() + '/' + lastDate.Year();
                        Integer validityYear = Integer.valueOf(objCalender.Year__c) + Integer.valueOf(lstAccount[0].nm_Program__r.nm_ProgramValidity__c);
                        Integer month = months.indexOf(objCalender.Session__c) == 0 ? 12 : months.indexOf(objCalender.Session__c);
                        Integer numberOfDays = Date.daysInMonth(validityYear, month);
                        wrapper.validityDate = numberOfDays + '/' + month + '/' + validityYear;
                    }
                    if (objCalender == null) {
                        wrapper.cancelDate = String.valueOf(Date.today().addDays(-1));
                        wrapper.validityDate = String.valueOf(Date.today().year() + Integer.valueOf(lstAccount[0].nm_Program__r.nm_ProgramValidity__c));
                    }
                    List<NM_Payment_Form_Configuration__c> lstnmPayment = [SELECT Id, Cancellation_to_date_2__c, Program_Type__c, Payment_Type__c, Current_Admission_Year__c, Session__c FROM NM_Payment_Form_Configuration__c WHERE Payment_Type__c='Admission' AND Current_Admission_Year__c=:String.valueOf(lstOpp[0].nm_Year__c) AND Session__c=:lstOpp[0].nm_Session__c AND Program_Type__c=:lstAccount[0].nm_Program__r.Specialisation__c LIMIT 1];*/
                    // Date lastDate2 = lstnmPayment.size() > 0 && String.isNotBlank(lstnmPayment[0].Cancellation_to_date_2__c) ? Date.valueOf(lstnmPayment[0].Cancellation_to_date_2__c) : null;
                    // wrapper.cancelDate2 = lastDate2 != null ? lastDate2.Day() + '/' + lastDate2.Month() + '/' + lastDate2.Year() : '';
                    
                    //Map<String,Date> mapOfCancelDate = new Map<String,Date>();
                    Map<String,Cancelation_Date__c> mapOfCancelDate = new Map<String,Cancelation_Date__c>();
                    
                    List<Cancelation_Date__c> lstCancelDate = [SELECT Id,Amount__c,Percentage__c,Admission_Fee__c,To_Date__c,From_Date__c,NM_Payment_Form_Configuration__r.Payment_Type__c,NM_Payment_Form_Configuration__r.Program_Type__c,NM_Payment_Form_Configuration__r.Current_Admission_Year__c,NM_Payment_Form_Configuration__r.Session__c FROM Cancelation_Date__c WHERE NM_Payment_Form_Configuration__r.Payment_Type__c='Admission' AND NM_Payment_Form_Configuration__r.Program_Type__c=:lstAccount[0].nm_Program__r.Specialisation__c AND NM_Payment_Form_Configuration__r.Current_Admission_Year__c=:String.valueOf(lstOpp[0].nm_Year__c) AND NM_Payment_Form_Configuration__r.Session__c=:lstOpp[0].nm_Session__c ORDER BY From_Date__c ASC];
                    // if (lstCancelDate.size() > 0) {
                    //     for (Cancelation_Date__c objCancelDate : lstCancelDate) {
                    //         System.debug('objCancelDate.Amount__c-->' + objCancelDate.Amount__c + ' objCancelDate.Percentage__c--->' + objCancelDate.Percentage__c + ' objCancelDate.Admission_Fee__c-->' + objCancelDate.Admission_Fee__c);
                    //         if (objCancelDate.Amount__c == null && objCancelDate.Percentage__c == null && objCancelDate.Admission_Fee__c == false) {
                    //             mapOfCancelDate.put('cancel1', objCancelDate.To_Date__c);
                    //         }
                    //         if (objCancelDate.Amount__c != null && objCancelDate.Percentage__c == null && objCancelDate.Admission_Fee__c == false) {
                    //             mapOfCancelDate.put('cancel2', objCancelDate.To_Date__c);
                    //         }
                    //     }
                    //     Date dt1 = mapOfCancelDate.containsKey('cancel1') ? mapOfCancelDate.get('cancel1') : null;
                    //     wrapper.cancelDate = dt1 != null ? dt1.Day() + '/' + dt1.Month() + '/' + dt1.Year() : '';
                    //     Date dt2 = mapOfCancelDate.containsKey('cancel2') ? mapOfCancelDate.get('cancel2') : null;
                    //     wrapper.cancelDate2 = dt2 != null ? dt2.Day() + '/' + dt2.Month() + '/' + dt2.Year() : '';
                    // }
                    for (Cancelation_Date__c objCancelDate : lstCancelDate) {
                        if (objCancelDate.Amount__c > 0) {
                            mapOfCancelDate.put('Amount',objCancelDate);
                        }
                        else if (objCancelDate.Admission_Fee__c) {
                            mapOfCancelDate.put('Admisssion',objCancelDate);
                        }
                        else if (objCancelDate.Percentage__c != null) {
                            mapOfCancelDate.put('PostDeduction' + objCancelDate.Percentage__c,objCancelDate);
                        }
                    }

                    List<String> months = new List<String>{
                        'January', 'February', 'March', 'April', 'May', 'June', 
                        'July', 'August', 'September', 'October', 'November', 'December'
                    };

                    Integer validityYear = Integer.valueOf(lstOpp[0].nm_Year__c) + Integer.valueOf(lstAccount[0].nm_Program__r.nm_ProgramValidity__c);
                    validityYear = months.indexOf(lstOpp[0].nm_Session__c) == 0 ? validityYear - 1 : validityYear;
                    Integer month = months.indexOf(lstOpp[0].nm_Session__c) == 0 ? 12 : months.indexOf(lstOpp[0].nm_Session__c);
                    Integer numberOfDays = Date.daysInMonth(validityYear, month);
                    wrapper.validityDate = numberOfDays + '/' + month + '/' + validityYear;
                    
                    //wrapper.cancelDate2 = lstnmPayment.size() > 0 && String.isNotBlank(lstnmPayment[0].Cancellation_to_date_2__c) ? lstnmPayment[0].Cancellation_to_date_2__c.replace('.','/') : '';
                    wrapper.opp = lstOpp[0];
                    System.debug('cancel date');
                    wrapper.mapOfConditionVsCancellationDate = mapOfCancelDate;
                    //wrapper.calender = objCalender;
                }
            }
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param lstCalender 
    * @param objAccount 
    * @return Calender__c 
    **/
    /*public static Calender__c getCalender(List<Calender__c> lstCalender,Account objAccount) {
        Map<String,Calender__c> mapOfKeyVsCalender = new Map<String,Calender__c>();
        String mapKey = objAccount.nm_ProgramType__c + '_' + objAccount.nm_Program__r.Specialisation__c;
        Calender__c objCalender = new Calender__c();
        for (Calender__c objCal : lstCalender) {
            if ((String.isNotBlank(objCal.nm_Type__c) && String.isNotBlank(objCal.Specialisation__c)) || (String.isBlank(objCal.Specialisation__c) && String.isNotBlank(objCal.nm_Type__c))) {
                String calMapKey = objCal.nm_Type__c + '_' + objCal.Specialisation__c;
                mapOfKeyVsCalender.put(calMapKey,objCal);
            }
            if (String.isBlank(objCal.Specialisation__c) && String.isBlank(objCal.nm_Type__c)) {
                mapOfKeyVsCalender.put('All',objCal);
            }
        }

        System.debug('mapOfKeyVsCalender---->' + mapOfKeyVsCalender);

        objCalender = mapOfKeyVsCalender.containsKey(mapKey) ? mapOfKeyVsCalender.get(mapKey) : mapOfKeyVsCalender.containsKey('All') ? mapOfKeyVsCalender.get('All') : null;
        System.debug('objCalender---->' + objCalender);
        return objCalender;
    }*/

    /**
    * @description 
    * @author @vickysahu | 07-02-2024 
    * @param rating 
    * @param verify 
    * @param recordId 
    * @param taskId 
    * @return VideoWrapper 
    **/
    @AuraEnabled
    public static VideoWrapper createStudentRating(Boolean verify,String recordId,String vvcId,Map<String,String> mapOfQuestionAndAns,String userName){
        VideoWrapper wrapper = new VideoWrapper();
        List<VVC_Question__c> lstResponse = new List<VVC_Question__c>();
        List<Task> lstTask = new List<Task>();
       
        wrapper.msg = '';
        try {
            System.debug('mapOfQuestionAndAns-->' + mapOfQuestionAndAns);
            System.debug('Obj Student Rating--->' );
            if (mapOfQuestionAndAns != null ) {
                for (String key : mapOfQuestionAndAns.keySet()) {
                    if (String.isNotBlank(mapOfQuestionAndAns.get(key))) {
                        VVC_Question__c objQuest = new VVC_Question__c();
                        objQuest.Question__c = key == 'comments' ? mapOfQuestionAndAns.get('comments') : key;
                        objQuest.Answer__c = key == 'comments' ? '' : mapOfQuestionAndAns.get(key);
                        //objQuest.Account__c = recordId;
                        objQuest.Display_to_Student__c = key == 'comments' || key == 'Does the student photo in our database match the person on the video call?' ? false : true; 
                        objQuest.VVC_Junction__c = vvcId;
                        //objQuest.ownerId = ownerId;
                        lstResponse.add(objQuest);
                    }
                }

                if(lstResponse.isEmpty()){
                    wrapper.msg = 'Please provide the answers for the questions';
                    return wrapper;
                }

                insert lstResponse;

                VVC_Junction__c objJunc = new VVC_Junction__c(); 
                objJunc.Id = vvcId;
                objJunc.is_video_call_verified__c = verify == true ? true : false;
                objJunc.Status__c = 'Completed';
                objJunc.Agent_Joined_Status__c = 'Joined';
                objJunc.Completed_By_Agent__c = userName;
                update objJunc;

                if(!verify) {
                    wrapper.msg = 'Record created Successfully!';
                    return wrapper;
                }

                Account objAccount = new Account();
                objAccount.Id = recordId;
                objAccount.is_Video_Call_Verified__c = true;
                objAccount.Video_Verification_Date_Time__c = System.now();
                update objAccount;

                wrapper.msg = 'Account updated Successfully!';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrapper;
    }

    @AuraEnabled(Cacheable=true)
    public static String getStudentImage(String recordId){
        String imageUrl = '';
        try {
            List<Account> lstAccount = [SELECT Id, nm_StudentImageUrl__c FROM Account WHERE Id=:recordId LIMIT 1];
            if (lstAccount.size() > 0) {
                imageUrl = lstAccount[0].nm_StudentImageUrl__c; 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return imageUrl;
    }

    public class VideoWrapper {
        @AuraEnabled
        public Account acc {get;set;}

        @AuraEnabled
        public Opportunity opp {get;set;}

        // @AuraEnabled
        // public Calender__c calender {get;set;}

        // @AuraEnabled
        // public String cancelDate {get;set;}

        // @AuraEnabled
        // public String cancelDate2 {get;set;}

        @AuraEnabled
        public String validityDate {get;set;}

        @AuraEnabled
        public String msg {get;set;}

        // @AuraEnabled
        // public String ratingId {get;set;}

        @AuraEnabled
        public Map<String,Cancelation_Date__c> mapOfConditionVsCancellationDate {get;set;}
    }
    
}