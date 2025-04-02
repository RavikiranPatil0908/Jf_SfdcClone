/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-07-2024
 * @last modified by  : @BK
**/
global without sharing class GetUniversityList {

    /**
    * @description 
    * @author @BK | 20-07-2024 
    * @return List<University_List__c> 
    **/
    webservice static List<University_List__c> getUniversityDetails(){
        List<University_List__c> universityList = [SELECT Id, Is_Active__c, University_Name__c, University_Type__c FROM University_List__c WHERE Is_Active__c = true];
        System.debug('University List --> ' + JSON.serialize(universityList));
        return universityList;
    }
}