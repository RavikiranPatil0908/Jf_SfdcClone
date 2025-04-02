/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 10-14-2024
 * @last modified by  : @vickysahu
**/
public class MigrateStudentRatingBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public List<VVC_Question__c> lstQues = new List<VVC_Question__c>();
    public List<VVC_Junction__c> lstJunc = new List<VVC_Junction__c>();
    public Map<Id,Account> mapOfIdAndAccount = new Map<Id,Account>();
    public Map<Id,Opportunity> mapOfIdAndOpportunity = new Map<Id,Opportunity>();
    public Map<String,String> mapOfCancel1 = new Map<String,String>();
    public Map<String,String> mapOfCancel2 = new Map<String,String>();
    public List<Student_Rating__c> lstRating = new List<Student_Rating__c>();
    public List<Task> lstTaskUpdate = new List<Task>();

    public void execute(SchedulableContext sc) {
        MigrateStudentRatingBatchClass b = new MigrateStudentRatingBatchClass();
        Database.executeBatch(b,200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        getCancelDate();
        String query = 'SELECT Id,WhatId,StudentRating__r.Does_Photo_Matched__c,StudentRating__r.Confirm_Correct_DOB__c,StudentRating__r.Confirm_Correct_Program__c,StudentRating__r.Confirm_Loan_Details__c,StudentRating__r.Confirm_Session__c,StudentRating__r.Confirm_Examination_Component__c,StudentRating__r.Confirm_Exam_Evaluation__c,StudentRating__r.Confirm_Term_End_Examination__c,StudentRating__r.Confirm_Exam_Fee__c,StudentRating__r.Confirm_Validity_Of_Program__c,StudentRating__r.Confirm_Passing_Marks__c,StudentRating__r.Confirm_Reexam_Process__c,StudentRating__r.Confirm_Exam_Conduction_Process__c,StudentRating__r.Confirm_Special_Case__c,StudentRating__r.Confirm_No_Placement_Service__c,StudentRating__r.Confirm_Mandatory_Engagement__c,StudentRating__r.Confirm_Cancellation_date__c,StudentRating__r.Comments__c,StudentRating__r.Confirm_Correct_Duration__c FROM Task WHERE Subject=\'Video Call Scheduling\' AND StudentRating__c != null AND StudentRating__r.is_Migrated__c = false AND Status = \'Completed\' AND VVC_Junction__c = null AND whatId != null LIMIT 60';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc,List<Task> scope) {
        getListOfAccount(scope);
        if (scope.size() > 0) {
            for (Task objTask : scope) {
                Account objAccount = new Account();
                Opportunity objOpp = new Opportunity();
                Student_Rating__c objRating = new Student_Rating__c();
                if (!mapOfIdAndAccount.containsKey(objTask.WhatId)) {
                    return;
                }
                objOpp = mapOfIdAndOpportunity.get(objTask.WhatId);
                objAccount = mapOfIdAndAccount.get(objTask.WhatId);
                VVC_Junction__c obj = new VVC_Junction__c();
                //obj.is_video_call_verified__c = false;
                obj.is_video_call_verified__c = checkVerified(objTask,objAccount);
                insert obj;

                if (String.isNotBlank(objTask.StudentRating__r.Does_Photo_Matched__c)) {
                    VVC_Question__c objQues1 = new VVC_Question__c();
                    objQues1.Question__c = 'Does the student photo in our database match the person on the video call?';
                    objQues1.Answer__c = objTask.StudentRating__r.Does_Photo_Matched__c;
                    objQues1.Display_to_Student__c = false;
                    objQues1.VVC_Junction__c = obj.Id;
                    objQues1.Account__c = objTask.WhatId;
                    lstQues.add(objQues1);
                    //obj.is_video_call_verified__c = objQues1.Answer__c == 'Yes, the photo matches – Proceed with questionnaire' ? true : false;
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Correct_DOB__c)) {
                    VVC_Question__c objQues2 = new VVC_Question__c();
                    objQues2.Question__c = 'Please could you confirm your Date of Birth? ' + '(' + formateDate(objAccount.nm_DateOfBirth__c) + ')';
                    objQues2.Answer__c = objTask.StudentRating__r.Confirm_Correct_DOB__c;
                    objQues2.Display_to_Student__c = true;
                    objQues2.VVC_Junction__c = obj.Id;
                    objQues2.Account__c = objTask.WhatId;
                    lstQues.add(objQues2);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Correct_Program__c)) {
                    VVC_Question__c objQues3 = new VVC_Question__c();
                    objQues3.Question__c = getProgramQuestion(objAccount);
                    objQues3.Answer__c = objTask.StudentRating__r.Confirm_Correct_Program__c;
                    objQues3.Display_to_Student__c = true;
                    objQues3.VVC_Junction__c = obj.Id;
                    objQues3.Account__c = objTask.WhatId;
                    lstQues.add(objQues3);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Correct_Duration__c)) {
                    VVC_Question__c objQues19 = new VVC_Question__c();
                    objQues19.Question__c = 'Are you aware that the duration of the program is ' + objAccount.nm_Program__r.nm_ProgramDuration__c + ' year and mode of delivery is online? Do you want to continue? ';
                    objQues19.Answer__c = objTask.StudentRating__r.Confirm_Correct_Duration__c;
                    objQues19.Display_to_Student__c = true;
                    objQues19.VVC_Junction__c = obj.Id;
                    objQues19.Account__c = objTask.WhatId;
                    lstQues.add(objQues19);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Loan_Details__c)) {
                    VVC_Question__c objQues4 = new VVC_Question__c();
                    objQues4.Question__c = 'We understand that you have opted for loan from ' + objOpp.Loan_Type__c + ' for Rs.' + objOpp.Loan_Amount__c + '/- for a period of ' + objOpp.Tenure__c + ' months) please note that the University has only facilitated this loan for you and your agreement is directly with the loan provider - ' + objOpp.Loan_Type__c + '. You have to abide by the terms of the loan agreement and any further issue due to this agreement is not the University\'s responsibility and you will have to directly deal with the loan provider.';
                    objQues4.Answer__c = objTask.StudentRating__r.Confirm_Loan_Details__c;
                    objQues4.Display_to_Student__c = true;
                    objQues4.VVC_Junction__c = obj.Id;
                    objQues4.Account__c = objTask.WhatId;
                    lstQues.add(objQues4);
                }

                //MBA (WX)
                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Session__c)) {
                    VVC_Question__c objQues14 = new VVC_Question__c();
                    objQues14.Question__c = 'Are you aware that sessions are conducted - Monday to Friday – (07:00PM to 09:30 PM) every evening? In case of any public holidays, these sessions will be rescheduled to weekends. ';
                    objQues14.Answer__c = objTask.StudentRating__r.Confirm_Session__c;
                    objQues14.Display_to_Student__c = true;
                    objQues14.VVC_Junction__c = obj.Id;
                    objQues14.Account__c = objTask.WhatId;
                    lstQues.add(objQues14);
                }

                //MBA (WX)
                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Examination_Component__c)) {
                    VVC_Question__c objQues15 = new VVC_Question__c();
                    objQues15.Question__c = 'Are you aware that examination has two components internal assessment of 60 marks and Term End examination of 40 marks? ';
                    objQues15.Answer__c = objTask.StudentRating__r.Confirm_Examination_Component__c;
                    objQues15.Display_to_Student__c = true;
                    objQues15.VVC_Junction__c = obj.Id;
                    objQues15.Account__c = objTask.WhatId;
                    lstQues.add(objQues15);
                }

                //MBA (WX)
                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Exam_Evaluation__c)) {
                    VVC_Question__c objQues16 = new VVC_Question__c();
                    objQues16.Question__c = 'Each subject will have has 6 internal assessments (12 marks each). Out of which Best 5 IAs, will be considered for the final evaluation. These will be conducted in the evening from 09:45 PM to 10:30 PM post live sessions. Note: Missed IAs cannot be rescheduled';
                    objQues16.Answer__c = objTask.StudentRating__r.Confirm_Exam_Evaluation__c;
                    objQues16.Display_to_Student__c = true;
                    objQues16.VVC_Junction__c = obj.Id;
                    objQues16.Account__c = objTask.WhatId;
                    lstQues.add(objQues16);
                }

                //MBA (WX)
                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Term_End_Examination__c)) {
                    VVC_Question__c objQues17 = new VVC_Question__c();
                    objQues17.Question__c = 'Term end examination is conducted on Saturday/Sunday at 11:00AM. You can select either of the one slot as per your convenience. The dates of these slots will be provided in the batch planner. Note: Missed TEE cannot be rescheduled. ';
                    objQues17.Answer__c = objTask.StudentRating__r.Confirm_Term_End_Examination__c;
                    objQues17.Display_to_Student__c = true;
                    objQues17.VVC_Junction__c = obj.Id;
                    objQues17.Account__c = objTask.WhatId;
                    lstQues.add(objQues17);
                }

                // Not MBA (WX)
                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Exam_Fee__c)) {
                    VVC_Question__c objQues5 = new VVC_Question__c();
                    objQues5.Question__c = 'Please note the examination fee is Rs‘800’ per subject per attempt and Project fee is Rs‘1500’ applicable in the respective term (in case of MBA student). This is not part of tuition fees. Also note the first two assignment submissions are free however any submissions post that for the failed subject(s) will be Rs. 500/-.per submission per subject per examination';
                    objQues5.Answer__c = objTask.StudentRating__r.Confirm_Exam_Fee__c;
                    objQues5.Display_to_Student__c = true;
                    objQues5.VVC_Junction__c = obj.Id;
                    objQues5.Account__c = objTask.WhatId;
                    lstQues.add(objQues5);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Validity_Of_Program__c)) {
                    VVC_Question__c objQues6 = new VVC_Question__c();
                    String validityDate =  getProgramValidity(objAccount,objOpp);
                    objQues6.Question__c = 'Please note the program validity is until ' + validityDate + '. You have to complete your program by validity date.';
                    objQues6.Answer__c = objTask.StudentRating__r.Confirm_Validity_Of_Program__c;
                    objQues6.Display_to_Student__c = true;
                    objQues6.VVC_Junction__c = obj.Id;
                    objQues6.Account__c = objTask.WhatId;
                    lstQues.add(objQues6);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Passing_Marks__c)) {
                    VVC_Question__c objQues7 = new VVC_Question__c();
                    objQues7.Question__c = objAccount.nm_Program__r.Specialisation__c != 'MBA (WX)' ? 'Are you aware that passing marks is 40 marks per subject and there is no grace marks' : 'Are you aware that passing marks is 40 marks per subject and there is no grace marks. Also, you need to score minimum of 16 marks in Term end examination to clear the subject.';
                    objQues7.Answer__c = objTask.StudentRating__r.Confirm_Passing_Marks__c;
                    objQues7.Display_to_Student__c = true;
                    objQues7.VVC_Junction__c = obj.Id;
                    objQues7.Account__c = objTask.WhatId;
                    lstQues.add(objQues7);
                }

                //MBA (WX)
                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Reexam_Process__c)) {
                    VVC_Question__c objQues18 = new VVC_Question__c();
                    objQues18.Question__c = 'If a student is not able not able to clear a TERM, he/she has to either repeat the subject or appear for a Re-exam by paying the applicable fees. Student will be allowed to progress to the next TERM only if they clear all subjects.';
                    objQues18.Answer__c = objTask.StudentRating__r.Confirm_Reexam_Process__c;
                    objQues18.Display_to_Student__c = true;
                    objQues18.VVC_Junction__c = obj.Id;
                    objQues18.Account__c = objTask.WhatId;
                    lstQues.add(objQues18);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Exam_Conduction_Process__c)) {
                    VVC_Question__c objQues8 = new VVC_Question__c();
                    objQues8.Question__c = objAccount.nm_Program__r.Specialisation__c != 'MBA (WX)' ? 'Currently our examination can be attempted either online from any location or at our designated examination centres. If you are found to indulge in any malpractices during examinations, the paper will be marked as ‘null and void’ and you will have to appear for examination only at the examination centre. Note- The University reserves the right to change this and switch to center-based examinations at its discretion at any point of time.' : 'Currently our examinations are online from any location. However If you are found to indulge in any malpractices during examinations, the paper will be marked as ‘null and void’ and you will have to appear for examination only at the examination centre. Note- The University reserves the right to change this and switch to center-based examinations at its discretion at any point of time. ';
                    objQues8.Answer__c = objTask.StudentRating__r.Confirm_Exam_Conduction_Process__c;
                    objQues8.Display_to_Student__c = true;
                    objQues8.VVC_Junction__c = obj.Id;
                    objQues8.Account__c = objTask.WhatId;
                    lstQues.add(objQues8);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Special_Case__c)) {
                    VVC_Question__c objQues9 = new VVC_Question__c();
                    objQues9.Question__c = 'Since you have opted for special needs, are you aware that you would have to attempt the examination at our examination centre only.';
                    objQues9.Answer__c = objTask.StudentRating__r.Confirm_Special_Case__c;
                    objQues9.Display_to_Student__c = true;
                    objQues9.VVC_Junction__c = obj.Id;
                    objQues9.Account__c = objTask.WhatId;
                    lstQues.add(objQues9);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_No_Placement_Service__c)) {
                    VVC_Question__c objQues10 = new VVC_Question__c();
                    objQues10.Question__c = 'There are no placement services or referral bonus offered by the University. Do you wish to continue ';
                    objQues10.Answer__c = objTask.StudentRating__r.Confirm_No_Placement_Service__c;
                    objQues10.Display_to_Student__c = true;
                    objQues10.VVC_Junction__c = obj.Id;
                    objQues10.Account__c = objTask.WhatId;
                    lstQues.add(objQues10);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Mandatory_Engagement__c)) {
                    VVC_Question__c objQues11 = new VVC_Question__c();
                    objQues11.Question__c = 'As per UGC guidelines, you need to have 75% engagement throughout the program .i.e 90 hours per subject per semester. This can be achieved by attending live sessions, viewing recordings and E-Books, participating in discussion forums, quizzes, posting queries and assignment submissions. Note: Students will not be allowed to attempt the TEE if the engagement is less than 75% ';
                    objQues11.Answer__c = objTask.StudentRating__r.Confirm_Mandatory_Engagement__c;
                    objQues11.Display_to_Student__c = true;
                    objQues11.VVC_Junction__c = obj.Id;
                    objQues11.Account__c = objTask.WhatId;
                    lstQues.add(objQues11);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Confirm_Cancellation_date__c)) {
                    VVC_Question__c objQues12 = new VVC_Question__c();
                    String cancelDate = mapOfCancel1.get(objAccount.nm_Program__r.Specialisation__c);
                    String cancelDate2 = mapOfCancel2.get(objAccount.nm_Program__r.Specialisation__c);
                    objQues12.Question__c = 'Please note that if admission is cancelled by ' + cancelDate + ', full program fee will be refunded. Post that a processing fee of Rs. 1000 will be deducted until ' + cancelDate2 + '. No refund is allowed after that. Please note -Registration fees Rs. 1200/- is non-refundable.';
                    objQues12.Answer__c = objTask.StudentRating__r.Confirm_Cancellation_date__c;
                    objQues12.Display_to_Student__c = true;
                    objQues12.VVC_Junction__c = obj.Id;
                    objQues12.Account__c = objTask.WhatId;
                    lstQues.add(objQues12);
                }

                if (String.isNotBlank(objTask.StudentRating__r.Comments__c)) {
                    VVC_Question__c objQues13 = new VVC_Question__c();
                    objQues13.Question__c = objTask.StudentRating__r.Comments__c;
                    objQues13.Display_to_Student__c = false;
                    objQues13.VVC_Junction__c = obj.Id;
                    objQues13.Account__c = objTask.WhatId;
                    lstQues.add(objQues13);
                }

                //lstJunc.add(obj);
                objRating.Id = objTask.StudentRating__c;
                objRating.is_Migrated__c = true;
                lstRating.add(objRating);

                objTask.VVC_Junction__c = obj.Id;
                lstTaskUpdate.add(objTask);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
       try {
        // if (lstJunc.size() > 0) {
        //     insert lstJunc;
        // }
        if (lstQues.size() > 0) {
            insert lstQues;
        }
        if (lstRating.size() > 0) {
            update lstRating;
        }
        if (lstTaskUpdate.size() > 0) {
            update lstTaskUpdate;
        }

       }
       catch(Exception e) {
        System.debug('Error--->' + e.getMessage());
       }
    }

    public String getProgramValidity(Account objAccount,Opportunity objOpp) {
        List<String> months = new List<String>{
            'January', 'February', 'March', 'April', 'May', 'June', 
            'July', 'August', 'September', 'October', 'November', 'December'
        };

        Integer validityYear = Integer.valueOf(objOpp.nm_Year__c) + Integer.valueOf(objAccount.nm_Program__r.nm_ProgramValidity__c);
        Integer month = months.indexOf(objOpp.nm_Session__c) == 0 ? 12 : months.indexOf(objOpp.nm_Session__c);
        Integer numberOfDays = Date.daysInMonth(validityYear, month);
        String validityDate = numberOfDays + '/' + month + '/' + validityYear;
        return validityDate;
    } 

    public String getProgramQuestion(Account objAccount) {
        String ques = '';
        if (objAccount.nm_Program__r.Specialisation__c == 'MBA (WX)') {
            ques = objAccount.Specialization_Type__c == 'Single Specialisation' ? 'You have enrolled for ' + objAccount.nm_Program__r.nm_ProgramName__c : 'You have enrolled for ' + objAccount.nm_Program__r.nm_ProgramName__c + ' and ' + objAccount.nm_Program2__r.nm_ProgramName__c;
        }
        if (objAccount.nm_Program__r.Specialisation__c != 'MBA (WX)') {
            ques = 'You have enrolled for ' + objAccount.nm_Program__r.nm_ProgramName__c;
        }
        return ques;
    }

    public String formateDate(Date dt) {
        return dt.Day() + '-' + dt.Month() + '-' + dt.Year();
    }

    public void getListOfAccount(List<Task> lstTask) {
        Set<Id> setOfId = new Set<Id>();
        List<Account> lstAccount = new List<Account>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        if (lstTask.size() > 0) {
            for (Task objTask : lstTask) {
                if (String.isNotBlank(objTask.WhatId)) {
                    setOfId.add(objTask.WhatId);    
                }
                System.debug('setOfId--->' + setOfId);
                lstAccount = [SELECT Id,nm_DateOfBirth__c,Specialization_Type__c,nm_Program__r.nm_ProgramName__c,nm_Program2__r.nm_ProgramName__c,nm_Program__r.Specialisation__c,nm_Program__r.nm_ProgramValidity__c,nm_Program__r.nm_ProgramDuration__c FROM Account WHERE Id IN :setOfId];
                lstOpp = [SELECT Id,Tenure__c,Loan_Amount__c,Loan_Type__c,nm_Year__c,nm_Session__c,AccountId FROM Opportunity WHERE Is_Re_Registration_Payment__c = false AND AccountId In :setOfId];
            }
        }

        if (lstAccount.size() > 0) {
            for (Account objAccount : lstAccount) {
                mapOfIdAndAccount.put(objAccount.Id, objAccount);
            }

            for (Opportunity objOpp : lstOpp) {
                mapOfIdAndOpportunity.put(objOpp.AccountId,objOpp);
            }
        }
    }

    public Boolean checkVerified(Task objTask,Account objAccount) {
        Boolean isVerified = false; 
        if (objAccount.nm_Program__r.Specialisation__c == 'MBA (WX)') {
            if (//objTask.StudentRating__r.Does_Photo_Matched__c == 'Yes, the photo matches – Proceed with questionnaire' &&
                objTask.StudentRating__r.Confirm_Correct_DOB__c == 'Yes, it is correct' &&
                objTask.StudentRating__r.Confirm_Correct_Program__c == 'Yes, it is correct' &&
                objTask.StudentRating__r.Confirm_Correct_Duration__c == 'Yes, continue, the student is aware' &&
                (String.isBlank(objTask.StudentRating__r.Confirm_Loan_Details__c) || objTask.StudentRating__r.Confirm_Loan_Details__c == 'Yes, I agree') &&
                objTask.StudentRating__r.Confirm_Session__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Examination_Component__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Exam_Evaluation__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Term_End_Examination__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Passing_Marks__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Reexam_Process__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Validity_Of_Program__c == 'Yes, the student is aware' &&
                (objTask.StudentRating__r.Confirm_Exam_Conduction_Process__c == 'Yes, I agree' ||
                objTask.StudentRating__r.Confirm_Special_Case__c == 'Yes, the student is aware') &&
                objTask.StudentRating__r.Confirm_No_Placement_Service__c == 'Yes, continue, the student is aware' &&
                objTask.StudentRating__r.Confirm_Mandatory_Engagement__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Cancellation_date__c == 'Yes, the student is aware') {
                isVerified = true;
            }
        }
        if (objAccount.nm_Program__r.Specialisation__c != 'MBA (WX)') {
            if (
                objTask.StudentRating__r.Confirm_Correct_DOB__c == 'Yes, it is correct' &&
                objTask.StudentRating__r.Confirm_Correct_Program__c == 'Yes, it is correct' &&
                objTask.StudentRating__r.Confirm_Correct_Duration__c == 'Yes, continue, the student is aware' &&
                (String.isBlank(objTask.StudentRating__r.Confirm_Loan_Details__c) || objTask.StudentRating__r.Confirm_Loan_Details__c == 'Yes, I agree') &&
                objTask.StudentRating__r.Confirm_Passing_Marks__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Validity_Of_Program__c == 'Yes, the student is aware' &&
                (objTask.StudentRating__r.Confirm_Exam_Conduction_Process__c == 'Yes, I agree' ||
                objTask.StudentRating__r.Confirm_Special_Case__c == 'Yes, the student is aware') &&
                objTask.StudentRating__r.Confirm_No_Placement_Service__c == 'Yes, continue, the student is aware' &&
                objTask.StudentRating__r.Confirm_Mandatory_Engagement__c == 'Yes, the student is aware' &&
                objTask.StudentRating__r.Confirm_Cancellation_date__c == 'Yes, the student is aware') {
                isVerified = true;
            }
        }
        return isVerified;
    }

    public void getCancelDate() {
        mapOfCancel1.put('BCom', '30/9/2024');
        mapOfCancel1.put('BBA', '30/9/2024');
        mapOfCancel1.put('MBA', '30/9/2024');
        mapOfCancel1.put('MBA (WX)', '30/9/2024');

        mapOfCancel2.put('BCom','31/10/2024');
        mapOfCancel2.put('BBA','31/10/2024');
        mapOfCancel2.put('MBA','31/10/2024');
        mapOfCancel2.put('MBA (WX)','4/11/2024');

    }
}