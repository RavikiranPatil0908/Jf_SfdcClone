/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 09-05-2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public with sharing class CaseControllerTracker {
   
    @TestSetup
    static void makeData(){
    
    	String Internalticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId();
       
        Case c1 = new Case(Subject='Test', Status='New', InternalCategory__c='Admissions',Escalation_Level__c=0, RecordTypeId=Internalticket , Comments__c='New Case Comment' );
        insert c1;
    }

    @isTest
    static void unitTest1() {  
           List<Case> lst1 = [SELECT Id , Status FROM Case LIMIT 1];
           Test.startTest();
           String Response1 = CaseController.updateCaseStatus(lst1[0].Id, 'Escalated' , 'Test Comment' ,lst1[0].Status );
           System.debug(Response1);
           Test.stopTest();
    }
    
    @isTest
    static void unitTest2() {  
           List<Case> lst1 = [SELECT Id , Status FROM Case LIMIT 1];
           Test.startTest();
           String Response2 = CaseController.AddComment(lst1[0].Id,'Test Comment');
           System.debug(Response2);
           Test.stopTest();
    }
    @isTest
    static void unitTest3() {
        List<Case> lst1 = [SELECT Id , Status FROM Case LIMIT 1];
        Date todayDate =System.today();
        Test.startTest();
        String Response3 = CaseController.changeECDDate(lst1[0].Id, todayDate ,'Test ECD Date');
        System.debug(Response3);
        Test.stopTest();
    }

    @isTest
    static void unitTest4() {
        Date todayDate =System.today();
        Test.startTest();
        CaseController.changeECDDate('2', todayDate ,'Test ECD Date');
        CaseController.AddComment('2','Test Comment');
        CaseController.updateCaseStatus('2', 'Escalated' , 'Test Comment' ,'New' );
        Test.stopTest();
    }
    
        @isTest
    static void unitTest5() {
        List<Case> lst1 = [SELECT Id , Status FROM Case LIMIT 1];
        Date todayDate =System.today();
        Test.startTest();
        String Response3 = CaseController.changeDetails(lst1[0].Id, null ,'test','Escalated' ,'New' );
         String Response4 = CaseController.changeDetails(lst1[0].Id, todayDate ,'Test ECD Date',null ,'New' );
        String Response5 = CaseController.changeDetails(lst1[0].Id, todayDate ,'Test ECD Date','Esclated' ,'New' );
        String Response6 = CaseController.changeDetails(lst1[0].Id, todayDate ,'Test ECD Date','Esclated' ,'New' );
        // String Response3 = CaseController.changeDetails(lst1[0].Id, todayDate ,'Test ECD Date','' , );
        System.debug(Response3);
        Test.stopTest();
    }



      
    }