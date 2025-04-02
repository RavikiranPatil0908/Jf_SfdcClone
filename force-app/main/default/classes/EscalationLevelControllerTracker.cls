/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 07-15-2024
 * @last modified by  : Ravi
**/
@isTest(SeeAllData=false)
public with sharing class EscalationLevelControllerTracker {
    @TestSetup
    static void makeData() {
    	String internalTicket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId();
        Case c1 = new Case(Subject='Test', Status='New', InternalCategory__c='Admissions', Escalation_Level__c= 0, RecordTypeId=internalTicket , Comments__c='New Case Comment', Expected_Close_Date__c=System.today());
        insert c1;
    }

    @isTest
    static void unittest1() {
        List<Case> lst1 =[SELECT Id , Escalation_Level__c , Expected_Close_Date__c FROM Case LIMIT 1 ];
        Test.startTest();
        String  Response = EscalationLevelController.EscalateCase(lst1[0].Id , 1 , lst1[0].Expected_Close_Date__c , 3);
        system.debug(Response);
        Test.stopTest();
    }

    @isTest
    static void unittest2() {
        List<Case> lst1 =[SELECT Id , Escalation_Level__c , Expected_Close_Date__c FROM Case LIMIT 1 ];
        Test.startTest();
        String  Response = EscalationLevelController.EscalateCase(lst1[0].Id , 5 , lst1[0].Expected_Close_Date__c , 3);
        system.debug(Response);
        Test.stopTest();
    }
}