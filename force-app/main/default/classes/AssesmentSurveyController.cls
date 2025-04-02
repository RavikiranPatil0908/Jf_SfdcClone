public with sharing class AssesmentSurveyController {
    @AuraEnabled(cacheable=true)
    public static List<Survey__c> getActiveSurveys() {
        return [SELECT Id, Name FROM Survey__c WHERE New_Survey__c = TRUE AND IsActive__c = TRUE];
    }
}