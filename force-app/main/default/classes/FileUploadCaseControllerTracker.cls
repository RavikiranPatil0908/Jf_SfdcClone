/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--10--2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class FileUploadCaseControllerTracker {
   
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
                recordTypeId =ticket
            ),
            new Case(
                Query_Type__c = 'Enquiry',
                Student_Category__c = 'Need More Information',
                Student_Sub_Categories__c = 'Regarding Program',
                Status = 'New',
                Description = 'test',
                Subject = 'Marketing-Loan Query',
                Lead__c = objLead.Id,
                recordTypeId =ticket
            )
            ,new Case( 
                Query_Type__c = 'Enquiry',
                Subject='Test',
                Status='New', 
                Tech_Issue__c='No',
               	Student_Category__c='Need More Information',
                Student_Sub_Categories__c = 'Regarding Program',
                Student_No__c='77119958556',
                Escalation_Level__c=3, RecordTypeId=feedback, Account=objAccount
            )
        };
        insert caseRecords;

    }

    @isTest
    static void unitTest1(){
        Case c =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        FileUploadCaseController.uploadFile('doc1.pdf','Regarding Program',c.Id);
        Test.stopTest();
    }
}