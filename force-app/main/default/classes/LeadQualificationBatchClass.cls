/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 22-08-2024
 * @last modified by  : @BK
**/
public with sharing class LeadQualificationBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    Map<String,String> mapOfGroup1MobileVsIC = new Map<String,String>(); 
    Map<String,String> mapOfGroup1EmailVsIC = new Map<String,String>(); 
    Map<String,String> mapOfGroup2MobileVsIC = new Map<String,String>(); 
    Map<String,String> mapOfGroup2EmailVsIC = new Map<String,String>(); 
    Set<String> setOfGroup1program = new Set<String>{'Certificate Programs','Diploma Programs', 'Post Graduate Diploma Programs', 'Professional Programs' };
    Set<String> setOfGroup2program = new Set<String>{'MBA (Online) Programs','Master Programs', 'Bachelor Programs' };

    public void execute(SchedulableContext sc) {
        LeadQualificationBatchClass b = new LeadQualificationBatchClass();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('LeadQualificationBatchClass Batch Class Started');
        Set<String> setOfActiveProgram = new Set<String>();
        Set<String> setOfEmail = new Set<String>();
        Set<String> setOfMobile = new Set<String>();
        String a ='1';
        String b ='1';
        String c ='1';
        String d ='1';
        for (Calender__c objCalender : [SELECT Id, Session__c, Year__c, nm_Type__c, Specialisation__c FROM calender__c WHERE Session_Start_Date__c<= TODAY AND Session_End_Date__c >= TODAY AND Category__c = 'Admission']) {
            String spec = objCalender.Specialisation__c == null ? 'null' : objCalender.Specialisation__c;
            setOfActiveProgram.add(  objCalender.Session__c.left(3).toUpperCase() + ' ' + objCalender.Year__c + ' ' + spec);
        }
        for (nm_StudentProgram__c objStPr : [SELECT Id, nm_Student__r.Id, nm_Student__r.PersonEmail, nm_Student__r.PersonMobilePhone, nm_Student__r.nm_Program__r.nm_Type__c, nm_Student__r.nm_Centers__c  FROM nm_StudentProgram__c WHERE Drive_Key__c IN :setOfActiveProgram]) {
            setOfEmail.add(objStPr.nm_Student__r.PersonEmail);
            setOfMobile.add(objStPr.nm_Student__r.PersonMobilePhone);
            if (setOfGroup1program.contains(objStPr.nm_Student__r.nm_Program__r.nm_Type__c)) {
                mapOfGroup1MobileVsIC.put(objStPr.nm_Student__r.PersonMobilePhone, objStPr.nm_Student__r.nm_Centers__c);
                mapOfGroup1EmailVsIC.put(objStPr.nm_Student__r.PersonEmail, objStPr.nm_Student__r.nm_Centers__c);
            } else if (setOfGroup2program.contains(objStPr.nm_Student__r.nm_Program__r.nm_Type__c)) {
                mapOfGroup2MobileVsIC.put(objStPr.nm_Student__r.PersonMobilePhone, objStPr.nm_Student__r.nm_Centers__c);
                mapOfGroup2EmailVsIC.put(objStPr.nm_Student__r.PersonEmail, objStPr.nm_Student__r.nm_Centers__c);            
            }
        }
        String query = '';
        if(!Test.isRunningTest()) {
            query = 'SELECT Id, nm_ChooseaProgram__c,nm_InformationCenter__c, Email, MobilePhone  FROM Lead WHERE (MobilePhone IN : setOfMobile OR Email IN : setOfEmail) AND Form_Id__c = Null AND IsConverted = false AND Is_Already_Qualified__c = false' ;
        } else {
            query = 'SELECT Id, nm_ChooseaProgram__c,nm_InformationCenter__c, Email, MobilePhone  FROM Lead' ;
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Lead> updateLstLead = new List<Lead>();
        for(SObject sc : scope){
            Lead objLead = (Lead)sc;
            if (objLead.nm_InformationCenter__c != null && objLead.nm_ChooseaProgram__c != null && objLead.Email != null && objLead.MobilePhone != null ) {
                if (isLeadAlreadyQualified(objLead)) {
                    objLead.Is_Already_Qualified__c = true;
                    objLead.Status = 'Enrolled with other LC/IC';
                    updateLstLead.add(objLead);
                }
            }

            
        }
        if (updateLstLead.size() > 0) {
            update updateLstLead;
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('LeadQualificationBatchClass Finished ---> ');
    }

    public Boolean isLeadAlreadyQualified(Lead objLead) {
        if (setOfGroup1program.contains(objLead.nm_ChooseaProgram__c)) {
            if ((mapOfGroup1MobileVsIC.containsKey(objLead.MobilePhone) && (mapOfGroup1MobileVsIC.get(objLead.MobilePhone) != objLead.nm_InformationCenter__c ) ) ||
            (mapOfGroup1EmailVsIC.containsKey(objLead.Email) && (mapOfGroup1EmailVsIC.get(objLead.Email) != objLead.nm_InformationCenter__c ) ) ) {
                return true;
            } else if ((mapOfGroup2MobileVsIC.containsKey(objLead.MobilePhone) && (mapOfGroup2MobileVsIC.get(objLead.MobilePhone) != objLead.nm_InformationCenter__c ) ) ||
                (mapOfGroup2EmailVsIC.containsKey(objLead.Email) && (mapOfGroup2EmailVsIC.get(objLead.Email) != objLead.nm_InformationCenter__c ) ) ) {
                return true;
            }
        } else if(setOfGroup2program.contains(objLead.nm_ChooseaProgram__c)) {
            if (mapOfGroup2MobileVsIC.containsKey(objLead.MobilePhone) || mapOfGroup2EmailVsIC.containsKey(objLead.Email)) {
                return true;
            } else if ((mapOfGroup1MobileVsIC.containsKey(objLead.MobilePhone) && (mapOfGroup1MobileVsIC.get(objLead.MobilePhone) != objLead.nm_InformationCenter__c ) ) ||
                (mapOfGroup1EmailVsIC.containsKey(objLead.Email) && (mapOfGroup1EmailVsIC.get(objLead.Email) != objLead.nm_InformationCenter__c ) ) ) {
                return true;
            }
        }
        return false;
    }

}