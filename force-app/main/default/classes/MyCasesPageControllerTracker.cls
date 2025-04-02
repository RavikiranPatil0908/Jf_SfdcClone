/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--10--2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class MyCasesPageControllerTracker {


    @TestSetup
    static void makeData(){

        String feedback = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Student Feedbacks').getRecordTypeId();
        String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');

        List<Case> caseRecords = new List<Case>{
            new Case(
                Query_Type__c = 'Enquiry',
                Student_Category__c = 'Need More Information',
                Student_Sub_Categories__c = 'Regarding Program',
                Status = 'New',
                Description = 'test',
                Subject = 'Product-test',
                Lead__c = objLead.Id,
                recordTypeId =ticket,
                Expected_Close_Date__c = System.today().addDays(2)
            ),
            new Case(
                Query_Type__c = 'Feedback',
                Student_Category__c = 'Need More Information',
                Student_Sub_Categories__c = 'Regarding Program',
                Status = 'New',
                Description = 'test',
                Subject = 'Marketing-Loan Query',
                Lead__c = objLead.Id,
                recordTypeId =feedback
            )
            ,new Case( 
                Query_Type__c = 'Enquiry',
                Subject='Test',
                Status='New', 
                Tech_Issue__c='No',
                Student_Category__c='Admissions',
                Student_No__c='77119958556',
                Escalation_Level__c=3, RecordTypeId=ticket, Account=objAccount)
        };
        insert caseRecords;
    }

    /**
    * @description 
    * @author @Ravi | 26--10--2024 
    **/
    @isTest
    static void unitTest1() {
        MyCasesPageController obj = new MyCasesPageController();
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        obj.queryRecordData();
        obj.setObjectId(lead.Id);
        obj.getSearchList();
        obj.getQueryTypes();
        obj.getCategories();
        obj.getSubCategories();
        Test.stopTest();
    }

    /**
    * @description 
    * @author @Ravi | 26--10--2024 
    **/
    @isTest
    static void unitTest2() {
        Test.startTest();
        MyCasesPageController obj = new MyCasesPageController();
        obj.insertCase();
        Test.stopTest();
    }
    
    /**
    * @description 
    * @author @Ravi | 26--10--2024 
    **/
    @isTest
    static void unitTest3() {
        MyCasesPageController obj = new MyCasesPageController();
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
         obj.setObjectType('Lead');
        obj.validateStudent(lead.Id);
        Test.stopTest();
    }

    /**
    * @description 
    * @author @Ravi | 26--10--2024 
    **/
   @isTest
    static void unitTest4() {
        MyCasesPageController obj = new MyCasesPageController();
        Account account = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        obj.setObjectType('Account');
        obj.validateStudent(account.Id);
        Test.stopTest();
    }

    /**
    * @description 
    * @author @Ravi | 26--10--2024 
    **/
    @isTest
    static void unitTest5() {
        MyCasesPageController controller = new MyCasesPageController();
        controller.caseFilterType = 'Close';
        controller.objectId = [SELECT Id FROM Lead LIMIT 1].Id; 
        Test.startTest();
        controller.queryRecordData();
        controller.objectId = [SELECT Id FROM Account LIMIT 1].Id; 
        controller.queryRecordData();
        Test.stopTest();

    }

    @isTest
    static void unitTest6(){
       MyCasesPageController obj  = new MyCasesPageController();
       Test.startTest();
       obj.setObjectType('Lead');
       obj.validateStudent(null);
       Test.stopTest();
   }

      /**
    * @description 
    * @author @Ravi | 26--10--2024 
    **/
    @isTest
    static void unitTest7(){
        MyCasesPageController obj = new MyCasesPageController();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        obj.setObjectType('Account');
        obj.validateStudent(acc.Id);
        Test.stopTest();
    }

  @isTest
    static void unitTest8() {
         Case case1 = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        MyCasesPageController obj = new MyCasesPageController();
        obj.insertCase();
        obj.escalateTicket(case1.Id);
        Test.stopTest();
    }
 
}