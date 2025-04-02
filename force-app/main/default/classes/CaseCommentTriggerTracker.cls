/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 27--11--2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class CaseCommentTriggerTracker {

    @TestSetup
    static void makeData(){ 
      String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
      Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket);
        insert c1;
        CaseComment cc = new CaseComment(CommentBody='Test', ParentId=c1.Id);
        insert cc;
    }

    @isTest
    static void unitTest1() {
       CaseComment ccobj = [SELECT Id,CommentBody FROM CaseComment LIMIT 1];
        ccobj.CommentBody = 'Updated comment'; 
        Test.startTest();
        try {
            update ccobj; 
        } catch (Exception e) {
          System.debug('You can not Update Case Comment.');
        }
        Test.stopTest();  
    }
    
    @isTest
    static void unitTest2() {
         User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
         CaseComment ccobj = [SELECT Id,CommentBody FROM CaseComment LIMIT 1];
            Test.startTest();
            try {
                delete ccobj;
            } catch (Exception e) {
                System.debug('You can not Delete Case Comment.');
            }
            Test.stopTest();
        
    }
}