/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 24-01-2025
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
private class QualityRatingCalculationTracker {

    @isTest
    static void unitTest1() {
        Test.startTest();
            List<Quality_Rating__c> qrList = new List<Quality_Rating__c>();
            qrList.add(getTicketRecord());
            qrList.add(getLeadChatRecord());
            qrList.add(getLeadCallRecord());
            qrList.add(getServiceChatRecord());
            qrList.add(getServiceCallRecord());
            qrList.add(getVideoVerificationRecord());
            insert qrList;

            Quality_Rating__c qr = qrList[0];
            qr.Was_the_most_appropriate_solu_Evaluator__c = 'No';
            update qr;

        Test.stopTest();
    }

    private static Quality_Rating__c getTicketRecord() {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Quality_Rating__c');
        Schema.RecordTypeInfo rtInfoTicket = objType.getDescribe().getRecordTypeInfosByName().get('Ticket');
        Quality_Rating__c qr = new Quality_Rating__c(
            RecordTypeId = rtInfoTicket.getRecordTypeId(),
            Was_the_most_appropriate_solu_Evaluator__c = 'Yes',
            Were_all_questions_answered_Evaluator__c = 'Yes',
            Were_alternate_options_Value_Evaluator__c = 'Yes',
            Was_the_student_guided_how_to_Evaluator__c = 'Yes',
            Query_Resolution_Timelines_Evaluator__c ='Yes',
            Was_the_ticket_responded_with_Evaluator__c = 'Yes',
            Was_the_reason_for_escalation_Evaluator__c ='Yes',
            Were_there_any_power_Empathy_Evaluator__c = 'Yes',
            Was_the_response_clear_conci_Evaluator__c = 'Yes',
            Was_any_jargons_used_Evaluator__c = 'Yes',
            Was_the_response_grammaticall_Evaluator__c = 'Yes',
            Was_the_response_drafted_manu_Evaluator__c = 'Yes',
            Disposition_done_correctly_Evaluator__c = 'Yes',
            Counsellor_Name__c = 'Grace'
        );
        return qr;
    }

    private static Quality_Rating__c getLeadChatRecord() {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Quality_Rating__c');
        Schema.RecordTypeInfo rtInfo = objType.getDescribe().getRecordTypeInfosByName().get('Lead Chat');
        Quality_Rating__c qr = new Quality_Rating__c(
            RecordTypeId = rtInfo.getRecordTypeId(),
            Paraphrased_the_query_Evaluator__c = 'Yes',
            Probed_correctly_Evaluator__c = 'Yes',
            Eligibility_confirmed_Evaluator__c = 'Yes',
            Did_check_SFDC_Portal_for_mor_Evaluator__c = 'Yes',
            Was_the_most_appropriate_info_Evaluator__c ='Yes',
            Were_all_questions_answered_Evaluator__c = 'Yes',
            Were_alternate_options_Value_Evaluator__c ='Yes',
            Was_the_student_guided_how_to_Evaluator__c = 'Yes',
            Resolution_Timelines_Informed_Evaluator__c ='Yes',
            Reponse_Time_is_less_than_or_Evaluator__c ='Yes',
            Comments_updated_Evaluator__c = 'Yes',
            Was_the_counsellor_prof_chat_Evaluator__c = 'Yes',
            Was_the_student_informed_of_Evaluator__c = 'Yes',
            Were_there_any_power_words_us_Evaluator__c ='Yes',
            Sentence_Formation_Punctuatio_Evaluator__c ='Yes',
            Spelling_Mistakes_Use_of_Ja_Evaluator__c = 'Yes',
            Is_there_anything_else_asked_Evaluator__c = 'Yes',
            Were_the_student_detail_verif_Evaluator__c ='Yes',
            Chat_attached_to_the_account_Evaluator__c ='Yes',
            Logs_Disposition_Lead_cre_Evaluator__c = 'Yes',
            Counsellor_Name__c = 'Grace'
        );
        return qr;
    }

    private static Quality_Rating__c getLeadCallRecord() {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Quality_Rating__c');
        Schema.RecordTypeInfo rtInfo = objType.getDescribe().getRecordTypeInfosByName().get('Lead Call');
        Quality_Rating__c qr = new Quality_Rating__c(
            RecordTypeId = rtInfo.getRecordTypeId(),
            Was_the_correct_greeting_prov_Evaluator__c = 'Yes',
            Were_the_student_detail_verif_Evaluator__c ='Yes',
            Eligibility_confirmed_Evaluator__c = 'Yes',
            Probed_correctly_Evaluator__c ='Yes',
            Did_check_SFDC_Portal_for_mor_Evaluator__c ='Yes',
            Was_the_most_appropriate_info_Evaluator__c = 'Yes',
            Were_all_questions_answered_Evaluator__c = 'Yes',
            Were_alternate_options_Value_Evaluator__c ='Yes',
            Was_the_student_guided_how_to_Evaluator__c = 'Yes',
            Comments_updated_Evaluator__c ='Yes',
            Timelines_Informed_Evaluator__c ='No',
            Was_the_counsellor_profession_Evaluator__c ='Yes',
            Was_the_student_name_used_app_Evaluator__c = 'Yes',
            Were_there_any_power_words_us_Evaluator__c = 'Yes',
            Hold_Procedure_Dead_Air_Evaluator__c ='Yes',
            Sentence_Formation_Jargons_Evaluator__c ='Yes',
            Listening_Skills_Overtalking_Evaluator__c ='Yes',
            Was_the_correct_closing_provi_Evaluator__c ='Yes',
            Is_there_anything_else_asked_Evaluator__c ='Yes',
            Lead_created_on_SFDC_Call_lo_Evaluator__c = 'Yes',
            Counsellor_Name__c = 'Grace'
        );
        return qr;
    }

    private static Quality_Rating__c getServiceChatRecord() {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Quality_Rating__c');
        Schema.RecordTypeInfo rtInfo = objType.getDescribe().getRecordTypeInfosByName().get('Service Chat');
        Quality_Rating__c qr = new Quality_Rating__c(
            RecordTypeId = rtInfo.getRecordTypeId(),
            Paraphrased_the_query_Evaluator__c = 'Yes',
            Probed_correctly_Evaluator__c = 'Yes',
            Did_check_SFDC_Portal_for_mor_Evaluator__c = 'Yes',
            Was_the_most_appropriate_solu_Evaluator__c = 'Yes',
            Were_all_questions_answered_Evaluator__c = 'No',
            Were_alternate_options_Value_Evaluator__c = 'Yes',
            Was_the_student_guided_how_to_Evaluator__c = 'Yes',
            Resolution_Timelines_Informed_Evaluator__c = 'Yes',
            Ownership_Actioned_tickets_Evaluator__c = 'Yes',
            Reponse_Time_is_less_than_or_Evaluator__c = 'Yes',
            Was_the_counsellor_prof_chat_Evaluator__c = 'Yes',
            Was_the_student_informed_of_Evaluator__c = 'Yes',
            Were_there_any_power_words_us_Evaluator__c = 'Yes',
            Sentence_Formation_Punctuatio_Evaluator__c = 'Yes',
            Spelling_Mistakes_Use_of_Ja_Evaluator__c = 'Yes',
            Is_there_anything_else_asked_Evaluator__c = 'Yes',
            Logs_Disposition_Chat_attac_Evaluator__c = 'Yes',
            Counsellor_Name__c = 'Grace'
        );
        return qr;
    }

    private static Quality_Rating__c getServiceCallRecord() {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Quality_Rating__c');
        Schema.RecordTypeInfo rtInfo = objType.getDescribe().getRecordTypeInfosByName().get('Service Call');
        Quality_Rating__c qr = new Quality_Rating__c(
            RecordTypeId = rtInfo.getRecordTypeId(),
            Was_the_correct_greeting_prov_Evaluator__c = 'Yes',
            Were_the_student_detail_verif_Evaluator__c = 'Yes',
            Paraphrased_the_query_Evaluator__c = 'Yes',
            Probed_correctly_Evaluator__c = 'No',
            Did_check_SFDC_Portal_for_mor_Evaluator__c = 'Yes',
            Was_the_most_appropriate_solu_Evaluator__c = 'Yes',
            Were_all_questions_answered_Evaluator__c = 'Yes',
            Were_alternate_options_Value_Evaluator__c = 'Yes',
            Was_the_student_guided_how_to_Evaluator__c = 'Yes',
            Ownership_Actioned_tickets_Evaluator__c = 'Yes',
            Query_Resolution_Timelines_Evaluator__c = 'Yes',
            Was_the_counsellor_profession_Evaluator__c = 'Yes',
            Was_the_student_name_used_app_Evaluator__c = 'Yes',
            Were_there_any_power_words_us_Evaluator__c = 'Yes',
            Hold_Procedure_Dead_Air_Evaluator__c = 'Yes',
            Sentence_Formation_Jargons_Evaluator__c = 'Yes',
            Listening_Skills_Overtalking_Evaluator__c = 'Yes',
            Was_the_correct_closing_provi_Evaluator__c = 'Yes',
            Is_there_anything_else_asked_Evaluator__c = 'Yes',
            Call_log_Disposition_Evaluator__c = 'Yes',
            Counsellor_Name__c = 'Grace'
        );
        return qr;
    }
    
    private static Quality_Rating__c getVideoVerificationRecord() {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Quality_Rating__c');
        Schema.RecordTypeInfo rtInfo = objType.getDescribe().getRecordTypeInfosByName().get('Video Verification');
        Quality_Rating__c qr = new Quality_Rating__c(
            RecordTypeId = rtInfo.getRecordTypeId(),
            The_counsellor_joined_on_time_Evaluator__c = 'No',
            Complete_Greeting_with_Name_Evaluator__c = 'Yes',
            Confirmed_Students_Name_and_Evaluator__c = 'Yes',

            Was_the_correct_verbiage_used_while_on_t__c = 'No',
            Did_the_Counsellor_answer_all_Evaluator__c = 'Yes',
            Was_the_correct_information_Evaluator__c = 'Yes',

            Reminder_Call_done_Evaluator__c = 'No',
            Counsellor_waited_for_7min_Evaluator__c = 'No',
            Were_the_comments_updated_Evaluator__c = 'Yes',
            VVC_google_sheet_updated_for_Evaluator__c = 'Yes',

            Counsellor_was_professional_Evaluator__c = 'Yes',
            Grammatical_Error_Word_Format_Evaluator__c = 'No',
            Listening_Skills_Overtalking_Evaluator__c = 'No',
            Counsellor_Name__c = 'Grace'
        );
        return qr;
    } 

    public static List<String> lstOfFields(String recordTypeName) {
        List<String> lstOfFields;
        if(String.isNotBlank(recordTypeName)) {
            switch on recordTypeName {
                when 'Ticket' {
                    lstOfFields = new List<String>{
                        'Was_the_most_appropriate_solu_Evaluator__c',
                        'Were_all_questions_answered_Evaluator__c',
                        'Were_alternate_options_Value_Evaluator__c',
                        'Was_the_student_guided_how_to_Evaluator__c',
                        'Query_Resolution_Timelines_Evaluator__c',
                        'Was_the_ticket_responded_with_Evaluator__c',
                        'Was_the_reason_for_escalation_Evaluator__c',
                        'Were_there_any_power_Empathy_Evaluator__c',
                        'Was_the_response_clear_conci_Evaluator__c',
                        'Was_any_jargons_used_Evaluator__c',
                        'Was_the_response_grammaticall_Evaluator__c',
                        'Was_the_response_drafted_manu_Evaluator__c',
                        'Disposition_done_correctly_Evaluator__c'
                    };
                }
                when 'Lead Chat' {
                    lstOfFields = new List<String>{
                        'Paraphrased_the_query_Evaluator__c',
                        'Probed_correctly_Evaluator__c',
                        'Eligibility_confirmed_Evaluator__c',
                        'Did_check_SFDC_Portal_for_mor_Evaluator__c',
                        'Was_the_most_appropriate_info_Evaluator__c',
                        'Were_all_questions_answered_Evaluator__c',
                        'Were_alternate_options_Value_Evaluator__c',
                        'Was_the_student_guided_how_to_Evaluator__c',
                        'Resolution_Timelines_Informed_Evaluator__c',
                        'Reponse_Time_is_less_than_or_Evaluator__c',
                        'Comments_updated_Evaluator__c',
                        'Was_the_counsellor_prof_chat_Evaluator__c',
                        'Was_the_student_informed_of_Evaluator__c',
                        'Were_there_any_power_words_us_Evaluator__c',
                        'Sentence_Formation_Punctuatio_Evaluator__c',
                        'Spelling_Mistakes_Use_of_Ja_Evaluator__c',
                        'Is_there_anything_else_asked_Evaluator__c',
                        'Were_the_student_detail_verif_Evaluator__c',
                        'Chat_attached_to_the_account_Evaluator__c',
                        'Logs_Disposition_Lead_cre_Evaluator__c'
                    };
                }
                when 'Lead Call' {
                    lstOfFields = new List<String>{
                        'Paraphrased_the_query_Evaluator__c',
                        'Probed_correctly_Evaluator__c',
                        'Eligibility_confirmed_Evaluator__c',
                        'Did_check_SFDC_Portal_for_mor_Evaluator__c',
                        'Was_the_most_appropriate_info_Evaluator__c',
                        'Were_all_questions_answered_Evaluator__c',
                        'Were_alternate_options_Value_Evaluator__c',
                        'Was_the_student_guided_how_to_Evaluator__c',
                        'Resolution_Timelines_Informed_Evaluator__c',
                        'Reponse_Time_is_less_than_or_Evaluator__c',
                        'Comments_updated_Evaluator__c',
                        'Was_the_counsellor_prof_chat_Evaluator__c',
                        'Was_the_student_informed_of_Evaluator__c',
                        'Were_there_any_power_words_us_Evaluator__c',
                        'Sentence_Formation_Punctuatio_Evaluator__c',
                        'Spelling_Mistakes_Use_of_Ja_Evaluator__c',
                        'Is_there_anything_else_asked_Evaluator__c',
                        'Were_the_student_detail_verif_Evaluator__c',
                        'Chat_attached_to_the_account_Evaluator__c',
                        'Logs_Disposition_Lead_cre_Evaluator__c'
                    };
                }
                when 'Service Chat' {
                    lstOfFields = new List<String>{
                        'Paraphrased_the_query_Evaluator__c',
                        'Probed_correctly_Evaluator__c',
                        'Eligibility_confirmed_Evaluator__c',
                        'Did_check_SFDC_Portal_for_mor_Evaluator__c',
                        'Was_the_most_appropriate_info_Evaluator__c',
                        'Were_all_questions_answered_Evaluator__c',
                        'Were_alternate_options_Value_Evaluator__c',
                        'Was_the_student_guided_how_to_Evaluator__c',
                        'Resolution_Timelines_Informed_Evaluator__c',
                        'Reponse_Time_is_less_than_or_Evaluator__c',
                        'Comments_updated_Evaluator__c',
                        'Was_the_counsellor_prof_chat_Evaluator__c',
                        'Was_the_student_informed_of_Evaluator__c',
                        'Were_there_any_power_words_us_Evaluator__c',
                        'Sentence_Formation_Punctuatio_Evaluator__c',
                        'Spelling_Mistakes_Use_of_Ja_Evaluator__c',
                        'Is_there_anything_else_asked_Evaluator__c',
                        'Were_the_student_detail_verif_Evaluator__c',
                        'Chat_attached_to_the_account_Evaluator__c',
                        'Logs_Disposition_Lead_cre_Evaluator__c'
                    };
                }
                when 'Service Call' {
                    lstOfFields = new List<String>{
                        'Paraphrased_the_query_Evaluator__c',
                        'Probed_correctly_Evaluator__c',
                        'Eligibility_confirmed_Evaluator__c',
                        'Did_check_SFDC_Portal_for_mor_Evaluator__c',
                        'Was_the_most_appropriate_info_Evaluator__c',
                        'Were_all_questions_answered_Evaluator__c',
                        'Were_alternate_options_Value_Evaluator__c',
                        'Was_the_student_guided_how_to_Evaluator__c',
                        'Resolution_Timelines_Informed_Evaluator__c',
                        'Reponse_Time_is_less_than_or_Evaluator__c',
                        'Comments_updated_Evaluator__c',
                        'Was_the_counsellor_prof_chat_Evaluator__c',
                        'Was_the_student_informed_of_Evaluator__c',
                        'Were_there_any_power_words_us_Evaluator__c',
                        'Sentence_Formation_Punctuatio_Evaluator__c',
                        'Spelling_Mistakes_Use_of_Ja_Evaluator__c',
                        'Is_there_anything_else_asked_Evaluator__c',
                        'Were_the_student_detail_verif_Evaluator__c',
                        'Chat_attached_to_the_account_Evaluator__c',
                        'Logs_Disposition_Lead_cre_Evaluator__c'
                    };
                }
                when else {
                    lstOfFields = new List<String>(); 
                }
            }
        }
        return lstOfFields;
    }
}