/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-16-2021
 * @last modified by  : @BK
**/
public without sharing class Survey {

    @AuraEnabled(cacheable = true)
    public static List<Question_Bank__c> getSurveyRecord(){
        try {
            return [SELECT Id,Active__c,Activity__c,Answer__c,Choices__c,Function__c,Program_Type__c,Question__c,Name,Type__c,Mark__c FROM Question_Bank__c ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static QBWrappers getQuestionBanks(String surveyId){
        try {
            QBWrappers qBWrapr = new QBWrappers();
            qBWrapr.objSurvey = null;
            List<Survey__c> lstSurvey = [SELECT Id,Name,Activity__c,Function__c,New_Survey__c,Program_Type__c,Show_Result__c,Submit_Response__c,Survey_Header__c,Thank_You_Text__c,Timer__c,showResponseAfterSubmit__c FROM Survey__c WHERE Id =: surveyId LIMIT 1];
            if(lstSurvey.size() > 0) {
                qBWrapr.lstQBank = [SELECT q.Id,q.Name,q.Active__c,q.Answer__c,q.Choices__c,q.Question__c,q.Type__c,q.Mark__c FROM Question_Bank__c q WHERE q.Active__c = true AND q.Id IN (SELECT s.Question_Bank__c FROM Survey_Question__c s WHERE s.Survey__c=:surveyId)];
                List<Survey_Question__c> lstSurveyQuestion = [SELECT Id,Question_Bank__c FROM Survey_Question__c WHERE Survey__c=:surveyId];
                qBWrapr.objSurvey = lstSurvey[0];
                qBWrapr.lstSurveyQuestion = lstSurvey.size() > 0 ? lstSurveyQuestion : null;
            }
            System.debug(qBWrapr);
            return qBWrapr;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    
    @AuraEnabled(cacheable=true)
    public static List<Survey__c> getAssessments(){
        try {
            return [SELECT Id,Name,Activity__c,Function__c,New_Survey__c,Program_Type__c,Show_Result__c,Submit_Response__c,Survey_Header__c,Thank_You_Text__c,Timer__c,showResponseAfterSubmit__c,IsActive__c FROM Survey__c WHERE New_Survey__c=true ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static SurveyWrapper getAssessmentRecords(Integer pageNumber,Integer recordsPerPage,String keyword,String sortedField,String sortDirection,String sortType){
        try {
            SurveyWrapper objSurveyWrapper = new SurveyWrapper();
            List<Survey__c> lstResults = new List<Survey__c>();
            Map<Integer,List<Survey__c>> mapOfNumberVsSurvey = new Map<Integer,List<Survey__c>>();
            Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
            Map<String, schema.SObjectField> fieldMap = scemapMap.get('Survey__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());

            String query = 'SELECT ' + String.join( fieldNames, ',') + ' FROM Survey__c WHERE New_Survey__c=true';
            if(String.isNotBlank(sortedField)) {
                query += ' ORDER BY ' + sortedField + ' ' + sortDirection;
            } else {
                query += ' ORDER BY CreatedDate DESC';
            }
            List<Survey__c> lstSurveys = DataBase.query(query);
            if(lstSurveys.size() > 0) {
                List<Survey__c> lstTemp;
                for(Integer i = 0 ; i < (lstSurveys.size() / recordsPerPage)+1 ; i++){
                    lstTemp = new List<Survey__c>();
                    for(Integer j=(i*recordsPerPage);(j<(i*recordsPerPage)+recordsPerPage) && j<lstSurveys.size() ; j++){
                        lstTemp.add(lstSurveys.get(j));
                    }
                    System.debug('i ==>'+i);
                    mapOfNumberVsSurvey.put(i+1,lstTemp);
                }
            }
            objSurveyWrapper.totalRecordCount = lstSurveys.size();
            objSurveyWrapper.totalPageCount = mapOfNumberVsSurvey.size();
            objSurveyWrapper.currentRecords = mapOfNumberVsSurvey.containsKey(pageNumber) ? mapOfNumberVsSurvey.get(pageNumber) : mapOfNumberVsSurvey.get(1);
            return objSurveyWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Question_Bank__c Createrecord(Question_Bank__c QbRecObje){
        try {
            // insert QbRecObje;
            upsert QbRecObje;
        // return QbRecObje;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getmessage());
        }
        return QbRecObje;
    }

    @AuraEnabled
    public static Survey__c upsertAssessment(Survey__c objSurvey) {
        try {
            // upserting Survey Record.
            upsert objSurvey;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return objSurvey;
    }

    @AuraEnabled(cacheable=true)
    public static QuestionBankWrapper getQuestionBank(String function, String activity, String programType, String surveyId) {
        try {
            QuestionBankWrapper qbWrapper = new QuestionBankWrapper();
            List<String> lstFunction = new List<String>();
            List<String> lstActivity = new List<String>();
            List<String> lstProgramType = new List<String>();
            List<String> preExistingQB = new List<String>();
            if(String.isNotBlank(function)) {
                lstFunction = function.split(';');
            }
            if(String.isNotBlank(activity)) {
                
                lstActivity = activity.split(';');
            }
            if(String.isNotBlank(programType)) {
                lstProgramType = programType.split(';');
            }
            List<Question_Bank__c> lstQuestionBank = [SELECT Id,Name,Active__c,Activity__c,Answer__c,Choices__c,Function__c,Program_Type__c,Question__c,Type__c FROM Question_Bank__c 
                WHERE (Function__c IN :lstFunction OR Activity__c IN :lstActivity OR Program_Type__c IN :lstProgramType) AND Active__c=true ORDER BY CreatedDate DESC];
            if(String.isNotBlank(surveyId)) {
                List<Survey_Question__c> lstSurveyQuestions = [SELECT Id,Question_Bank__c,Survey__c FROM Survey_Question__c WHERE Survey__c=:surveyId];
                for (Survey_Question__c objSQ : lstSurveyQuestions) {
                    preExistingQB.add(objSQ.Question_Bank__c);
                }
                qbWrapper.preExistingQB = preExistingQB;
            }
            qbWrapper.lstQuestionBank = lstQuestionBank;
            return qbWrapper;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean addQuestions(List<Question_Bank__c> lstQB,String surveyId) {
        try {
            if(String.isNotBlank(surveyId)) {
                List<Survey_Question__c> lstSurveyQuestions = new List<Survey_Question__c>();
                Map<Id, Survey_Question__c> mapOfQBVsSurveyQuestions = new Map<Id, Survey_Question__c>(); 
                for(Survey_Question__c objSQ : [SELECT id,Question_Bank__c,Survey__c FROM Survey_Question__c WHERE Survey__c=:surveyId]) {
                    mapOfQBVsSurveyQuestions.put(objSQ.Question_Bank__c, objSQ);
                }
                for (Question_Bank__c objQB : lstQB) {
                    if(mapOfQBVsSurveyQuestions.containsKey(objQB.Id)) {
                        mapOfQBVsSurveyQuestions.remove(objQB.Id);
                    } else {
                        Survey_Question__c objSQ = new Survey_Question__c();
                        objSQ.Question_Bank__c = objQB.Id;
                        objSQ.Survey__c = surveyId;
                        lstSurveyQuestions.add(objSQ);
                    }
                }
                if(mapOfQBVsSurveyQuestions.size() > 0) {
                    delete mapOfQBVsSurveyQuestions.values();
                }
                if(lstSurveyQuestions.size() > 0) {
                    insert lstSurveyQuestions;
                }
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static SurveyTakerWrapper createNewSurveyTaker(String SurveyId, String CounselorId) {
        try {
            SurveyTakerWrapper wrapperSurveyTaker = new SurveyTakerWrapper();
            if(String.isNotBlank(CounselorId)) {
                List<Counsellor_Profile__c> lstCounselorProfiles = [SELECT Id,Full_Name__c,Employee_Image_URL__c,Gender__c,Name FROM Counsellor_Profile__c WHERE Id=:CounselorId LIMIT 1];
                if(lstCounselorProfiles.size() > 0) {
                    List<SurveyTaker__c> lstSurveyTaker = [SELECT Id,Time_Taken__c,Counselor_Profile__c,Survey__c,Assessment_Submitted__c FROM SurveyTaker__c WHERE Counselor_Profile__c=:CounselorId AND Survey__c=:SurveyId LIMIT 1];
                    if(lstSurveyTaker.size() > 0) {
                        List<SurveyQuestionResponse__c> lstSurveyQuestionResponse = [SELECT Id,Answer__c,Survey_Question__c FROM SurveyQuestionResponse__c WHERE SurveyTaker__c=:lstSurveyTaker[0].Id];
                        wrapperSurveyTaker.surveyTakerId = lstSurveyTaker[0].Id;
                        wrapperSurveyTaker.lstSurveyQuestionResponse = lstSurveyQuestionResponse;
                        wrapperSurveyTaker.counselorName = lstCounselorProfiles[0].Full_Name__c;
                        wrapperSurveyTaker.objAEPProfile = lstCounselorProfiles[0];
                        wrapperSurveyTaker.objSurveyTaker = lstSurveyTaker[0];
                        return wrapperSurveyTaker;
                    } else {
                        SurveyTaker__c objSurveyTaker = new SurveyTaker__c();
                        system.debug('SurveyId--> ' + SurveyId);
                        objSurveyTaker.Survey__c = SurveyId;
                        objSurveyTaker.Counselor_Profile__c = CounselorId;
                        insert objSurveyTaker;
                        wrapperSurveyTaker.surveyTakerId = objSurveyTaker.Id;
                        wrapperSurveyTaker.objAEPProfile = lstCounselorProfiles[0];
                        wrapperSurveyTaker.counselorName = lstCounselorProfiles[0].Full_Name__c;
                        wrapperSurveyTaker.objSurveyTaker = objSurveyTaker;
                        system.debug('wrapperSurveyTaker --> ' + wrapperSurveyTaker);
                        return wrapperSurveyTaker;
                    }
                } else {
                    wrapperSurveyTaker.objSurveyTaker = createSurveyTaken(SurveyId);
                    wrapperSurveyTaker.surveyTakerId = wrapperSurveyTaker.objSurveyTaker.Id;
                    return wrapperSurveyTaker;
                }
            } else {
                wrapperSurveyTaker.objSurveyTaker = createSurveyTaken(SurveyId);
                wrapperSurveyTaker.surveyTakerId = wrapperSurveyTaker.objSurveyTaker.Id;
                return wrapperSurveyTaker;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static SurveyTaker__c createSurveyTaken(String SurveyId) {
        try {
            SurveyTaker__c objSurveyTaker = new SurveyTaker__c();
            System.debug('SurveyId--> ' + SurveyId);
            objSurveyTaker.Survey__c = SurveyId;
            insert objSurveyTaker;
            system.debug('objSurveyTaker--> ' + objSurveyTaker);
            system.debug('objSurveyTaker.Id--> ' + objSurveyTaker.Id);
            return objSurveyTaker;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static SurveyQuestionResponse__c upsertSurveyQuestionResponse(SurveyQuestionResponse__c objSurveyQuestionResponse, Integer timeTaken) {
        try {
            upsert objSurveyQuestionResponse;
            System.debug(objSurveyQuestionResponse);
            // update time taken to complete the assessment
            SurveyTaker__c objSurveyTaker = new SurveyTaker__c();
            objSurveyTaker.Id = objSurveyQuestionResponse.SurveyTaker__c;
            objSurveyTaker.Time_Taken__c = timeTaken;
            update objSurveyTaker;
            return objSurveyQuestionResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static SurveyTaker__c submitAssessment(SurveyTaker__c objSurveyTaker) {
        try {
            objSurveyTaker.Assessment_Submitted__c = true;
            update objSurveyTaker;
            return objSurveyTaker;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public with sharing class QuestionBankWrapper {
        @auraEnabled public List<String> preExistingQB {get;set;}
        @auraEnabled public List<Question_Bank__c> lstQuestionBank {get;set;}
    }

    public with sharing class SurveyWrapper {
        @auraEnabled public Integer totalRecordCount {get;set;}
        @auraEnabled public Integer totalPageCount {get;set;}
        @auraEnabled public List<Survey__c> currentRecords {get;set;}
    }

    public with sharing class SurveyTakerWrapper {
        @auraEnabled public String surveyTakerId {get;set;}
        @auraEnabled public String counselorName {get;set;}
        @auraEnabled public List<SurveyQuestionResponse__c> lstSurveyQuestionResponse {get;set;}
        @auraEnabled public Counsellor_Profile__c objAEPProfile {get;set;}
        @auraEnabled public SurveyTaker__c objSurveyTaker {get;set;}
    }

    public with sharing class QBWrappers{
        @auraEnabled public Survey__c objSurvey {get;set;}
        @auraEnabled public List<Question_Bank__c> lstQBank {get;set;}
        @auraEnabled public List<Survey_Question__c> lstSurveyQuestion {get;set;}
    }
    


}