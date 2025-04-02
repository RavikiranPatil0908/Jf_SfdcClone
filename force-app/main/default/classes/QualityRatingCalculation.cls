/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-01-2025
 * @last modified by  : @BK
**/
public without sharing class QualityRatingCalculation {

    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @param list<Quality_Rating__c> lstQualityRatings 
    * @param map<id Quality_Rating__c> triggerOldMap 
    * @param Boolean isUpdate 
    **/
    public static void updateScore(list<Quality_Rating__c> lstQualityRatings, map<id,Quality_Rating__c> triggerOldMap, Boolean isUpdate) {
        if (!lstQualityRatings.isEmpty()) {
            for (Quality_Rating__c objRating : lstQualityRatings) {
                Quality_Rating__c priorRecord = isUpdate && triggerOldMap.containsKey(objRating.Id) ? triggerOldMap.get(objRating.Id) : null;
                getTotalScore(objRating, priorRecord);
            }
        }
    }

    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @param Quality_Rating__c objRating 
    * @param Quality_Rating__c objPriorRating 
    **/
    public static void getTotalScore(Quality_Rating__c objRating, Quality_Rating__c objPriorRating) {
        FieldWrapper obj = new FieldWrapper();
        if (objRating.RTN__c == 'Service Call') {
            obj = getServiceCallFields();
        } else if (objRating.RTN__c == 'Service Chat') {
            obj = getServiceChatFields();
        }else if (objRating.RTN__c == 'Lead Call') {
            obj = getLeadCallFields();
        }else if (objRating.RTN__c == 'Lead Chat') {
            obj = getLeadChatFields();
        }else if (objRating.RTN__c == 'Ticket') {
            obj = getTicketFields();
        }else if (objRating.RTN__c == 'Video Verification') {
            obj = getVideoVerificationFields();
        }

        ScoresWrapper objScore = getScores(obj, objRating);
        // Directly setting Actual_Score__c to 100%
        objRating.Actual_Score__c = 100; 
        objRating.Total_Score__c = objScore.totalScoreForReviewer;
        objRating.Obtained_Score__c = Integer.valueOf(objScore.obtainedScoreForReviewer);

        // Update the fields with appropriate scores
        objRating.Amended_Score__c = Integer.valueOf(objScore.obtainedScoreForEvaluator); // Amended Score
        objRating.Amended_Total_Score__c = objScore.totalScoreForEvaluator;
        objRating.Counsellor_Email_Id__c = getEmailAddress(objRating.Counsellor_Name__c);
        if(System.Label.Environment != 'Production') {
            objRating.Counsellor_Email_Id__c = objRating.Counsellor_Email_Id__c + '.invalid';
        }

        // Call method to handle comment field updates
        updateCommentFields(objRating, objPriorRating);
        // return objWrapper;
    }

    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @param Quality_Rating__c objRating 
    * @param Quality_Rating__c objPriorRating 
    **/
    public static void updateCommentFields(Quality_Rating__c objRating, Quality_Rating__c objPriorRating) {
        if(objPriorRating == null) {
            return;
        }
        Map<String, String> mapOfReviewerFields = mapOfReviewerFieldVsEvaluator();
        String comments = objRating.Comments__c == null ? 'Changed\n' : objRating.Comments__c + '\n\nChanged\n';
        Map<String,Schema.SObjectField> mfields = Schema.Quality_Rating__c.SObjectType.getDescribe().fields.getMap();
        Boolean isFieldChanged = false;
        Boolean isEvaluator = false;
        for (String evalField : mapOfReviewerFields.keySet()) {
            String revField = mapOfReviewerFields.get(evalField);
            if(String.isNotBlank((String)objPriorRating.get(revField)) 
                && objPriorRating.get(revField) != objRating.get(revField)) {
                Schema.DescribeFieldResult fieldResult = mfields.get(revField).getDescribe();
                comments += fieldResult.getLabel() + ' from ' + objPriorRating.get(revField) + ' to ' + objRating.get(revField) + '\n';
                isFieldChanged = true;
            }
            
            if(String.isNotBlank((String)objPriorRating.get(evalField)) 
                && objPriorRating.get(evalField) != objRating.get(evalField)) {
                Schema.DescribeFieldResult fieldResult = mfields.get(evalField).getDescribe();
                comments += fieldResult.getLabel() + ' from ' + objPriorRating.get(evalField) + ' to ' + objRating.get(evalField) + '\n';
                isEvaluator = true;
                isFieldChanged = true;
            }
        }

        System.debug('isFieldChanged ==>'+isFieldChanged);
        if(isFieldChanged) {
            String currentUser = UserInfo.getName();
            String currentTime = DateTime.now().format('MM/dd/yyyy h:mm a');
            comments += 'Updated By ' + currentUser + ' (' + currentTime + ')\n';
            objRating.Comments__c = comments;
        }

        //Update the field with current user
        if(isEvaluator) {
            objRating.Evaluator_Name_2__c = UserInfo.getName();
        } else {
            objRating.Reviewer_Name__c = UserInfo.getName();
        }
    }

    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @param String counselorName 
    * @return String 
    **/
    public static String getEmailAddress(String counselorName) {
        Map<String,String> mapOfNameVsEmailId = new Map<String,String>{
            'Abishek'=>'abishekh.vitta@nmims.edu',
            'Anjali'=>'anjali.mishra@nmims.edu',
            'Aradhana'=>'aradhana.waghela@nmims.edu',
            'Bradley'=>'bradley.fernandes@nmims.edu',
            'Devika'=>'devika.salvi@nmims.edu',
            'Diksha'=>'diksha.goswami@nmims.edu',
            'Grace'=>'grace.john@nmims.edu',
            'Hasmita'=>'hasmita.tanwani@nmims.edu',
            'Kinita'=>'kinita.moraes@nmims.edu',
            'Maksad'=>'maksad.qureshi@nmims.edu',
            'Mohammad'=>'mohammad.khatri@nmims.edu',
            'Nida'=>'nida.vasaikar@nmims.edu',
            'Nikesh'=>'nikesh.parmar@nmims.edu',
            'Princy'=>'princy.raimond@nmims.edu',
            'Priyanka'=>'priyanka.gandhi@nmims.edu',
            'Rashmi'=>'rashmi.patankar@nmims.edu',
            'Raunak'=>'raunak.datta@nmims.edu',
            'Riddhi'=>'riddhi.gundye@nmims.edu',
            'Rinku'=>'rinku.patel@nmims.edu',
            'Sana'=>'sana.mukhi@nmims.edu',
            'Sanjana'=>'sanjana.singh@nmims.edu',
            'Smita'=>'smita.bhutak@nmims.edu',
            'Supriya'=>'supriya.dubey@nmims.edu',
            'Vidhi'=>'vidhi.waghela@nmims.edu',
            'Vishal'=>'vishal.bal@nmims.edu',
            'Yoshua'=>'yoshua.nethala@nmims.edu',
            'Farah'=>'farah.shaikh@nmims.edu',
            'Khushboo'=>'khushboo.thakkar@nmims.edu',
            'Hemal'=>'hemal.doshi@nmims.edu',
            'Shruti'=>'shruti.nair@nmims.edu',
            'Jinal'=>'jinal.gala@nmims.edu',
            'Shukrana'=>'shukrana.shaikh@nmims.edu',
            'Sebastian'=>'dnyanesh.sonawane@nmims.edu',
            'Shruti'=>'Shruti.Nair@nmims.edu'
        };
        return mapOfNameVsEmailId.containsKey(counselorName) ? mapOfNameVsEmailId.get(counselorName) : null;
    }

    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @param FieldWrapper obj 
    * @param Quality_Rating__c objRating 
    * @return ScoresWrapper 
    **/
    public static ScoresWrapper getScores(FieldWrapper obj, Quality_Rating__c objRating) {
        Map<String, String> mapOfReviewerFields = mapOfReviewerFieldVsEvaluator();
        ScoresWrapper objScore = new ScoresWrapper();
        for (String category : obj.mapOfCategoryVsFields.keySet()) {
            List<String> questions = obj.mapOfCategoryVsFields.get(category);
            List<String> lstOfIterations = new List<String>{'Reviewer', 'Evaluator'};
            for (String mode : lstOfIterations) {
                Decimal obtainedScore = 0;
                Boolean isAnyNo = false;
                Boolean isAnyNA = false;
                Integer highValQuestionCount = 0; // Initialize high value question count
                for (String question : questions) {
                    Decimal score = obj.mapOfFieldVsScore.get(question);
                    objScore.actualScore += score;
                    String fieldName = mode == 'Reviewer' ? mapOfReviewerFields.get(question) : question;
                    String fieldValue = (String) objRating.get(fieldName);
                    if (fieldValue == 'Yes') {
                        if (mode == 'Reviewer') {
                            objScore.totalScoreForReviewer += score;
                        } else {
                            objScore.totalScoreForEvaluator += score;
                        }
                        obtainedScore += score;
                    } else if (fieldValue == 'No') {
                        if (mode == 'Reviewer') {
                            objScore.totalScoreForReviewer += score;
                        } else {
                            objScore.totalScoreForEvaluator += score;
                        }
                        isAnyNo = true;
                        highValQuestionCount += obj.highValQuestions.contains(question) ? 1 : 0;
                    } else if (fieldValue == 'NA' || fieldValue == 'N/A') {
                        isAnyNA = true;
                    }
                }

                // Check if it is dependent and if any value is no or N/A on dependent question then the whole section will get 0
                // If the high value questions which is marked no more than 1 then the score will be set to 0
                if ((obj.lstOfDependentCategory.size() > 0 && obj.lstOfDependentCategory.contains(category) 
                    && (isAnyNo || isAnyNA)) || highValQuestionCount > 1) {
                    obtainedScore = 0;
                }

                if (mode == 'Reviewer') {
                    objScore.obtainedScoreForReviewer += obtainedScore;
                } else {
                    objScore.obtainedScoreForEvaluator += obtainedScore;
                }
            }
        }
        return objScore;
    }

    public static FieldWrapper getServiceCallFields() {
        FieldWrapper obj = new FieldWrapper();
        obj.mapOfFieldVsScore = new Map<String, Decimal>{
            'Was_the_correct_greeting_prov_Evaluator__c' => 2.5,
            'Were_the_student_detail_verif_Evaluator__c' => 2.5,

            'Paraphrased_the_query_Evaluator__c' => 5,
            'Probed_correctly_Evaluator__c' => 10,
            'Did_check_SFDC_Portal_for_mor_Evaluator__c' => 5,

            'Was_the_most_appropriate_solu_Evaluator__c' => 10,
            'Were_all_questions_answered_Evaluator__c' => 5,
            'Were_alternate_options_Value_Evaluator__c' => 5,
            'Was_the_student_guided_how_to_Evaluator__c' => 5,
            'Ownership_Actioned_tickets_Evaluator__c' => 5,
            'Query_Resolution_Timelines_Evaluator__c' => 5,

            'Was_the_counsellor_profession_Evaluator__c' => 5,
            'Was_the_student_name_used_app_Evaluator__c' => 5,
            'Were_there_any_power_words_us_Evaluator__c' => 5,
            'Hold_Procedure_Dead_Air_Evaluator__c' => 5,
            'Sentence_Formation_Jargons_Evaluator__c' => 5,
            'Listening_Skills_Overtalking_Evaluator__c' => 5,

            'Was_the_correct_closing_provi_Evaluator__c' => 2.5,
            'Is_there_anything_else_asked_Evaluator__c' => 2.5,

            'Call_log_Disposition_Evaluator__c' => 5
        };

        obj.mapOfCategoryVsFields = new Map<String, List<String>>{
            'Greeting' => new List<String>{'Was_the_correct_greeting_prov_Evaluator__c',
                                           'Were_the_student_detail_verif_Evaluator__c'},
            'Understanding the Query' => new List<String>{'Paraphrased_the_query_Evaluator__c',
                                                          'Probed_correctly_Evaluator__c', 'Did_check_SFDC_Portal_for_mor_Evaluator__c'},
            'Solution Providing - FCR' => new List<String>{'Was_the_most_appropriate_solu_Evaluator__c',
                                                           'Were_all_questions_answered_Evaluator__c',
                                                           'Were_alternate_options_Value_Evaluator__c',
                                                           'Was_the_student_guided_how_to_Evaluator__c',
                                                           'Ownership_Actioned_tickets_Evaluator__c',
                                                           'Query_Resolution_Timelines_Evaluator__c'},
            'Soft Skills' => new List<String>{'Was_the_counsellor_profession_Evaluator__c',
                                              'Was_the_student_name_used_app_Evaluator__c',
                                              'Were_there_any_power_words_us_Evaluator__c',
                                              'Hold_Procedure_Dead_Air_Evaluator__c',
                                              'Sentence_Formation_Jargons_Evaluator__c',
                                              'Listening_Skills_Overtalking_Evaluator__c'},
            'Closing' => new List<String>{'Was_the_correct_closing_provi_Evaluator__c',
                                          'Is_there_anything_else_asked_Evaluator__c'},
            'Completion' => new List<String>{'Call_log_Disposition_Evaluator__c'}
        };

        obj.lstOfDependentCategory = new List<String>{'Greeting', 'Closing'};
        obj.highValQuestions = new List<String>{
            'Probed_correctly_Evaluator__c',
            'Was_the_most_appropriate_solu_Evaluator__c',
            'Were_all_questions_answered_Evaluator__c',
            'Was_the_counsellor_profession_Evaluator__c',
            'Listening_Skills_Overtalking_Evaluator__c'
        };

        return obj;
    }

    public static FieldWrapper getServiceChatFields() {
        FieldWrapper obj = new FieldWrapper();
        obj.mapOfFieldVsScore = new Map<String, Decimal>{
            'Paraphrased_the_query_Evaluator__c' => 5,
            'Probed_correctly_Evaluator__c' => 10,
            'Did_check_SFDC_Portal_for_mor_Evaluator__c' => 5,

            'Was_the_most_appropriate_solu_Evaluator__c' => 10,
            'Were_all_questions_answered_Evaluator__c' => 5,
            'Were_alternate_options_Value_Evaluator__c' => 5,
            'Was_the_student_guided_how_to_Evaluator__c' => 5,
            'Resolution_Timelines_Informed_Evaluator__c' => 5,
            'Ownership_Actioned_tickets_Evaluator__c' => 5,
            'Reponse_Time_is_less_than_or_Evaluator__c' => 10,

            'Was_the_counsellor_prof_chat_Evaluator__c' => 5,
            'Was_the_student_informed_of_Evaluator__c' => 5,
            'Were_there_any_power_words_us_Evaluator__c' => 5,
            'Sentence_Formation_Punctuatio_Evaluator__c' => 5,
            'Spelling_Mistakes_Use_of_Ja_Evaluator__c' => 5,

            'Is_there_anything_else_asked_Evaluator__c' => 5,

            'Logs_Disposition_Chat_attac_Evaluator__c' => 5
        };

        obj.mapOfCategoryVsFields = new Map<String, List<String>>{
            'Understanding the Query' => new List<String>{'Paraphrased_the_query_Evaluator__c',
                                                          'Probed_correctly_Evaluator__c',
                                                          'Did_check_SFDC_Portal_for_mor_Evaluator__c'},
            'Solution Providing - FCR' => new List<String>{'Was_the_most_appropriate_solu_Evaluator__c',
                                                           'Were_all_questions_answered_Evaluator__c',
                                                           'Were_alternate_options_Value_Evaluator__c',
                                                           'Was_the_student_guided_how_to_Evaluator__c',
                                                           'Resolution_Timelines_Informed_Evaluator__c',
                                                           'Ownership_Actioned_tickets_Evaluator__c',
                                                           'Reponse_Time_is_less_than_or_Evaluator__c'},
            'Soft Skills' => new List<String>{'Was_the_counsellor_prof_chat_Evaluator__c',
                                              'Was_the_student_informed_of_Evaluator__c',
                                              'Were_there_any_power_words_us_Evaluator__c',
                                              'Sentence_Formation_Punctuatio_Evaluator__c',
                                              'Spelling_Mistakes_Use_of_Ja_Evaluator__c'},
            'Closing' => new List<String>{'Is_there_anything_else_asked_Evaluator__c'},
            'Completion' => new List<String>{'Logs_Disposition_Chat_attac_Evaluator__c'}
        };

        obj.lstOfDependentCategory = new List<String>{'Closing'};
        obj.highValQuestions = new List<String>{
            'Was_the_most_appropriate_solu_Evaluator__c',
            'Were_all_questions_answered_Evaluator__c',
            'Was_the_counsellor_prof_chat_Evaluator__c',
            'Sentence_Formation_Punctuatio_Evaluator__c'
        };

        return obj;
    }

    public static FieldWrapper getLeadCallFields() {
        FieldWrapper obj = new FieldWrapper();
        obj.mapOfFieldVsScore = new Map<String, Decimal>{
            'Was_the_correct_greeting_prov_Evaluator__c' => 2.5,
            'Were_the_student_detail_verif_Evaluator__c' => 2.5,

            'Eligibility_confirmed_Evaluator__c' => 10,
            'Probed_correctly_Evaluator__c' => 5,
            'Did_check_SFDC_Portal_for_mor_Evaluator__c' => 5,
            
            'Was_the_most_appropriate_info_Evaluator__c' => 10,
            'Were_all_questions_answered_Evaluator__c' => 5,
            'Were_alternate_options_Value_Evaluator__c' => 5,
            'Was_the_student_guided_how_to_Evaluator__c' => 5,
            'Comments_updated_Evaluator__c' => 5,
            'Timelines_Informed_Evaluator__c' => 5,

            'Was_the_counsellor_profession_Evaluator__c' => 5,
            'Was_the_student_name_used_app_Evaluator__c' => 5,
            'Were_there_any_power_words_us_Evaluator__c' => 5,
            'Hold_Procedure_Dead_Air_Evaluator__c' => 5,
            'Sentence_Formation_Jargons_Evaluator__c' => 5,
            'Listening_Skills_Overtalking_Evaluator__c' => 5,

            'Was_the_correct_closing_provi_Evaluator__c' => 2.5,
            'Is_there_anything_else_asked_Evaluator__c' => 2.5,

            'Lead_created_on_SFDC_Call_lo_Evaluator__c' => 5

            
        };

        obj.mapOfCategoryVsFields = new Map<String, List<String>>{
            'Greeting' => new List<String>{'Was_the_correct_greeting_prov_Evaluator__c',
                                           'Were_the_student_detail_verif_Evaluator__c'},
            'Understanding the Requirement' => new List<String>{'Eligibility_confirmed_Evaluator__c',
                                                          'Probed_correctly_Evaluator__c', 
                                                          'Did_check_SFDC_Portal_for_mor_Evaluator__c'},
            'Solution Providing - FCR' => new List<String>{'Was_the_most_appropriate_info_Evaluator__c',
                                                           'Were_all_questions_answered_Evaluator__c',
                                                           'Were_alternate_options_Value_Evaluator__c',
                                                           'Was_the_student_guided_how_to_Evaluator__c',
                                                           'Comments_updated_Evaluator__c',
                                                           'Timelines_Informed_Evaluator__c'},
            'Soft Skills' => new List<String>{'Was_the_counsellor_profession_Evaluator__c',
                                              'Was_the_student_name_used_app_Evaluator__c',
                                              'Were_there_any_power_words_us_Evaluator__c',
                                              'Hold_Procedure_Dead_Air_Evaluator__c',
                                              'Sentence_Formation_Jargons_Evaluator__c',
                                              'Listening_Skills_Overtalking_Evaluator__c'},
            'Closing' => new List<String>{'Was_the_correct_closing_provi_Evaluator__c',
                                          'Is_there_anything_else_asked_Evaluator__c'},
            'Completion' => new List<String>{'Lead_created_on_SFDC_Call_lo_Evaluator__c'}
        };

        obj.lstOfDependentCategory = new List<String>{'Greeting', 'Closing'};
        obj.highValQuestions = new List<String>{
            'Eligibility_confirmed_Evaluator__c',
            'Probed_correctly_Evaluator__c',
            'Was_the_most_appropriate_info_Evaluator__c',
            'Were_all_questions_answered_Evaluator__c',
            'Was_the_counsellor_profession_Evaluator__c',
            'Listening_Skills_Overtalking_Evaluator__c'
        };

        return obj;
    }

    public static FieldWrapper getLeadChatFields() {
        FieldWrapper obj = new FieldWrapper();
        obj.mapOfFieldVsScore = new Map<String, Decimal>{
            'Paraphrased_the_query_Evaluator__c' => 5,
            'Probed_correctly_Evaluator__c' => 5,
            'Eligibility_confirmed_Evaluator__c' => 5,
            'Did_check_SFDC_Portal_for_mor_Evaluator__c' => 5,

            'Was_the_most_appropriate_info_Evaluator__c' => 5,
            'Were_all_questions_answered_Evaluator__c' => 5,
            'Were_alternate_options_Value_Evaluator__c' => 5,
            'Was_the_student_guided_how_to_Evaluator__c' => 5,
            'Resolution_Timelines_Informed_Evaluator__c' => 5,
            'Reponse_Time_is_less_than_or_Evaluator__c' => 5,
            'Comments_updated_Evaluator__c' => 5,

            'Was_the_counsellor_prof_chat_Evaluator__c' => 5,
            'Was_the_student_informed_of_Evaluator__c' => 5,
            'Were_there_any_power_words_us_Evaluator__c' => 5,
            'Sentence_Formation_Punctuatio_Evaluator__c' => 5,
            'Spelling_Mistakes_Use_of_Ja_Evaluator__c' => 5,

            'Is_there_anything_else_asked_Evaluator__c' => 5,

            'Were_the_student_detail_verif_Evaluator__c' => 5,
            'Chat_attached_to_the_account_Evaluator__c' => 5,
            'Logs_Disposition_Lead_cre_Evaluator__c' => 5
        };

        obj.mapOfCategoryVsFields = new Map<String, List<String>>{
            'Understanding the Query' => new List<String>{'Paraphrased_the_query_Evaluator__c',
                                                          'Probed_correctly_Evaluator__c',
                                                          'Eligibility_confirmed_Evaluator__c',
                                                          'Did_check_SFDC_Portal_for_mor_Evaluator__c'},
            'Solution Providing - FCR' => new List<String>{'Was_the_most_appropriate_info_Evaluator__c',
                                                           'Were_all_questions_answered_Evaluator__c',
                                                           'Were_alternate_options_Value_Evaluator__c',
                                                           'Was_the_student_guided_how_to_Evaluator__c',
                                                           'Resolution_Timelines_Informed_Evaluator__c',
                                                           'Reponse_Time_is_less_than_or_Evaluator__c',
                                                           'Comments_updated_Evaluator__c'},
            'Soft Skills' => new List<String>{'Was_the_counsellor_prof_chat_Evaluator__c',
                                              'Was_the_student_informed_of_Evaluator__c',
                                              'Were_there_any_power_words_us_Evaluator__c',
                                              'Sentence_Formation_Punctuatio_Evaluator__c',
                                              'Spelling_Mistakes_Use_of_Ja_Evaluator__c'},
            'Closing' => new List<String>{'Is_there_anything_else_asked_Evaluator__c'},
            'Completion' => new List<String>{'Were_the_student_detail_verif_Evaluator__c',
                                             'Chat_attached_to_the_account_Evaluator__c',
                                             'Logs_Disposition_Lead_cre_Evaluator__c' }
        };

        obj.lstOfDependentCategory = new List<String>();
        obj.highValQuestions = new List<String>{
            'Probed_correctly_Evaluator__c',
            'Eligibility_confirmed_Evaluator__c',
            'Was_the_most_appropriate_info_Evaluator__c',
            'Were_all_questions_answered_Evaluator__c',
            'Was_the_counsellor_prof_chat_Evaluator__c',
            'Sentence_Formation_Punctuatio_Evaluator__c'
        };

        return obj;
    }

    public static FieldWrapper getTicketFields() {
        FieldWrapper obj = new FieldWrapper();
        obj.mapOfFieldVsScore = new Map<String, Decimal>{
            'Was_the_most_appropriate_solu_Evaluator__c' => 20,
            'Were_all_questions_answered_Evaluator__c' => 10,
            'Were_alternate_options_Value_Evaluator__c' => 5,
            'Was_the_student_guided_how_to_Evaluator__c' => 5,
            'Query_Resolution_Timelines_Evaluator__c' => 5,
            'Was_the_ticket_responded_with_Evaluator__c' => 10,
            'Was_the_reason_for_escalation_Evaluator__c' => 5,

            'Were_there_any_power_Empathy_Evaluator__c' => 5,
            'Was_the_response_clear_conci_Evaluator__c' => 10,
            'Was_any_jargons_used_Evaluator__c' => 5,
            'Was_the_response_grammaticall_Evaluator__c' => 10,
            'Was_the_response_drafted_manu_Evaluator__c' => 5,

            'Disposition_done_correctly_Evaluator__c' => 5
        };

        obj.mapOfCategoryVsFields = new Map<String, List<String>>{
          
            'Solution Providing - FCR' => new List<String>{'Was_the_most_appropriate_solu_Evaluator__c',
                                                           'Were_all_questions_answered_Evaluator__c',
                                                           'Were_alternate_options_Value_Evaluator__c',
                                                           'Was_the_student_guided_how_to_Evaluator__c',
                                                           'Query_Resolution_Timelines_Evaluator__c',
                                                           'Was_the_ticket_responded_with_Evaluator__c',
                                                           'Was_the_reason_for_escalation_Evaluator__c'},
            'Soft Skills' => new List<String>{'Were_there_any_power_Empathy_Evaluator__c',
                                              'Was_the_response_clear_conci_Evaluator__c',
                                              'Was_any_jargons_used_Evaluator__c',
                                              'Was_the_response_grammaticall_Evaluator__c',
                                              'Was_the_response_drafted_manu_Evaluator__c'},
            
            'Completion' => new List<String>{'Disposition_done_correctly_Evaluator__c' }
        };

        obj.lstOfDependentCategory = new List<String>();
        obj.highValQuestions = new List<String>{
            'Was_the_most_appropriate_solu_Evaluator__c',
            'Were_all_questions_answered_Evaluator__c',
            'Was_the_ticket_responded_with_Evaluator__c',
            'Was_the_response_clear_conci_Evaluator__c',
            'Was_the_response_grammaticall_Evaluator__c'
        };

        return obj;
    }

    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @return FieldWrapper 
    **/
    public static FieldWrapper getVideoVerificationFields() {
        FieldWrapper obj = new FieldWrapper();
        obj.mapOfFieldVsScore = new Map<String, Decimal>{
            'The_counsellor_joined_on_time_Evaluator__c' => 5,
            'Complete_Greeting_with_Name_Evaluator__c' => 10,
            'Confirmed_Students_Name_and_Evaluator__c' => 10,

            'Was_the_correct_verbiage_used_while_on_t__c' => 5,
            'Did_the_Counsellor_answer_all_Evaluator__c' => 10,
            'Was_the_correct_information_Evaluator__c' => 10,

            'Reminder_Call_done_Evaluator__c' => 5,
            'Counsellor_waited_for_7min_Evaluator__c' => 5,
            'Were_the_comments_updated_Evaluator__c' => 10,
            'VVC_google_sheet_updated_for_Evaluator__c' => 10,

            'Counsellor_was_professional_Evaluator__c' => 10,
            'Grammatical_Error_Word_Format_Evaluator__c' => 5,
            'Listening_Skills_Overtalking_Evaluator__c' => 5
            
        };

        obj.mapOfCategoryVsFields = new Map<String, List<String>>{
          
            'Opening' => new List<String>{'The_counsellor_joined_on_time_Evaluator__c',
                                                           'Complete_Greeting_with_Name_Evaluator__c',
                                                           'Confirmed_Students_Name_and_Evaluator__c'},
            'Information' => new List<String>{'Was_the_correct_verbiage_used_while_on_t__c',
                                              'Did_the_Counsellor_answer_all_Evaluator__c',
                                              'Was_the_correct_information_Evaluator__c'},

            'Closure' => new List<String>{'Reminder_Call_done_Evaluator__c',
                                          'Counsellor_waited_for_7min_Evaluator__c',
                                          'Were_the_comments_updated_Evaluator__c',
                                          'VVC_google_sheet_updated_for_Evaluator__c'},
            
            'Soft Skill' => new List<String>{'Counsellor_was_professional_Evaluator__c',
                                              'Grammatical_Error_Word_Format_Evaluator__c',
                                              'Listening_Skills_Overtalking_Evaluator__c'}
        };

        obj.lstOfDependentCategory = new List<String>();
        obj.highValQuestions = new List<String>();

        return obj;
    }


    /**
    * @description 
    * @author @BK | 28-01-2025 
    * @return Map<String, String> 
    **/
    public static Map<String, String> mapOfReviewerFieldVsEvaluator() {
         
        return new Map<String, String>{
            'Was_the_correct_greeting_prov_Evaluator__c' => 'Was_the_correct_greeting_provided__c',
            'Were_the_student_detail_verif_Evaluator__c' => 'Were_the_student_detail_verified__c',
            'Paraphrased_the_query_Evaluator__c' => 'Paraphrased_the_query__c',
            'Probed_correctly_Evaluator__c' => 'Probed_correctly__c',
            'Did_check_SFDC_Portal_for_mor_Evaluator__c' => 'Did_check_SFDC_Portal_for_more_informati__c',
            'Was_the_most_appropriate_solu_Evaluator__c' => 'Was_the_most_appropriate_solution_provid__c',
            'Were_all_questions_answered_Evaluator__c' => 'Were_all_questions_answered__c',
            'Were_alternate_options_Value_Evaluator__c' => 'Were_alternate_options_Value_add_provide__c',
            'Was_the_student_guided_how_to_Evaluator__c' => 'Was_the_student_guided_how_to_access_thi__c',
            'Ownership_Actioned_tickets_Evaluator__c' => 'Ownership_Actioned_tickets_if_any_wit__c',
            'Query_Resolution_Timelines_Evaluator__c' => 'Query_Resolution_Timelines_Informed__c',
            'Was_the_counsellor_profession_Evaluator__c' => 'Was_the_counsellor_professional_througho__c',
            'Was_the_student_name_used_app_Evaluator__c' => 'Was_the_student_name_used_appropriately__c',
            'Were_there_any_power_words_us_Evaluator__c' => 'Were_there_any_power_words_used__c',
            'Hold_Procedure_Dead_Air_Evaluator__c' => 'Hold_Procedure_Dead_Air__c',
            'Sentence_Formation_Jargons_Evaluator__c' => 'Sentence_Formation_Jargons__c',
            'Listening_Skills_Overtalking_Evaluator__c' => 'Listening_Skills_Overtalking__c',
            'Was_the_correct_closing_provi_Evaluator__c' => 'Was_the_correct_closing_provided__c',
            'Is_there_anything_else_asked_Evaluator__c' => 'Is_there_anything_else_asked__c',
            'Call_log_Disposition_Evaluator__c' => 'Call_log_Disposition__c',
            'Resolution_Timelines_Informed_Evaluator__c' => 'Resolution_Timelines_Informed__c',
            'Was_the_counsellor_prof_chat_Evaluator__c' => 'Was_the_counsellor_professional_thr_chat__c',
            'Reponse_Time_is_less_than_or_Evaluator__c' => 'Reponse_Time_is_less_than_or_equal_to_1__c',
            'Was_the_student_informed_of_Evaluator__c' => 'Was_the_student_informed_of_the_delay_in__c',
            'Sentence_Formation_Punctuatio_Evaluator__c' => 'Sentence_Formation_Punctuation__c',
            'Spelling_Mistakes_Use_of_Ja_Evaluator__c' => 'Spelling_Mistakes_Use_of_Jargons__c',
            'Logs_Disposition_Chat_attac_Evaluator__c' => 'Logs_Disposition_Chat_attached_to_the__c',
            'Eligibility_confirmed_Evaluator__c' =>'Eligibility_confirmed__c',
            'Was_the_most_appropriate_info_Evaluator__c' => 'Was_the_most_appropriate_information_pro__c',
            'Comments_updated_Evaluator__c' => 'Comments_updated__c',
            'Timelines_Informed_Evaluator__c' => 'Timelines_Informed__c',
            'Lead_created_on_SFDC_Call_lo_Evaluator__c' => 'Lead_created_on_SFDC_Call_log_Disposi__c',
            'Chat_attached_to_the_account_Evaluator__c' => 'Chat_attached_to_the_account__c',
            'Logs_Disposition_Lead_cre_Evaluator__c' => 'Logs_Disposition_Lead_created_on_SFD__c',
            'Was_the_ticket_responded_with_Evaluator__c' => 'Was_the_ticket_responded_within_2_hours__c',
            'Was_the_reason_for_escalation_Evaluator__c' => 'Was_the_reason_for_escalation_and_delay__c',
            'Were_there_any_power_Empathy_Evaluator__c' => 'Were_there_any_power_Empathy_words_used__c',
            'Was_the_response_clear_conci_Evaluator__c' => 'Was_the_response_clear_concise_and_easy__c',
            'Was_any_jargons_used_Evaluator__c' => 'Was_any_jargons_used__c',
            'Was_the_response_grammaticall_Evaluator__c' => 'Was_the_response_grammatically_correct_S__c',
            'Was_the_response_drafted_manu_Evaluator__c' => 'Was_the_response_drafted_manully_Chat__c',
            'Disposition_done_correctly_Evaluator__c' => 'Disposition_done_correctly__c',
            'The_counsellor_joined_on_time_Evaluator__c'=>'The_counsellor_joined_the_VVC_on_time__c',
            'Complete_Greeting_with_Name_Evaluator__c'=>'Complete_Greeting_with_Name_mentioned__c',
            'Confirmed_Students_Name_and_Evaluator__c'=>'Confirmed_Students_Name_and_Identity__c',
            'Was_the_correct_verbiage_used_while_on_t__c'=>'Was_correct_verbiage_used_on_the_call__c',
            'Did_the_Counsellor_answer_all_Evaluator__c'=>'Did_the_Counsellor_answer_all_queries__c',
            'Was_the_correct_information_Evaluator__c'=>'Was_the_correct_information_provided__c',
            'Reminder_Call_done_Evaluator__c'=>'Reminder_Call_done__c',
            'Counsellor_waited_for_7min_Evaluator__c'=>'Counsellor_waited_7_minutes_before_endin__c',
            'Were_the_comments_updated_Evaluator__c'=>'Were_the_comments_updated__c',
            'VVC_google_sheet_updated_for_Evaluator__c'=>'VVC_Google_Sheet_updated_for_missing_inf__c',
            'Counsellor_was_professional_Evaluator__c'=>'Counsellor_was_professional__c',
            'Grammatical_Error_Word_Format_Evaluator__c'=>'Grammatical_Errors_Sentence_Formation__c',
            'Listening_Skills_Overtalking_Evaluator__c'=>'Listening_Skills_Overtalking__c'
        };
    }

    public class FieldWrapper {
        public Map<String, Decimal> mapOfFieldVsScore { get; set; }
        public Map<String, List<String>> mapOfCategoryVsFields { get; set; }
        public List<String> lstOfDependentCategory { get; set; }
        public List<String> highValQuestions { get; set; }
    }

    public class ScoresWrapper {
        public Decimal obtainedScoreForEvaluator { get; set; }
        public Decimal totalScoreForEvaluator { get; set; }
        public Decimal actualScore { get; set; }
        public Decimal obtainedScoreForReviewer { get; set; }
        public Decimal totalScoreForReviewer { get; set; }

        public ScoresWrapper() {
            this.obtainedScoreForEvaluator = 0;
            this.totalScoreForEvaluator = 0;
            this.actualScore = 0;
            this.obtainedScoreForReviewer = 0;
            this.totalScoreForReviewer = 0;
        }
    }
}