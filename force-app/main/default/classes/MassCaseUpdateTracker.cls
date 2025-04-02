@isTest(SeeAllData=false)
public class MassCaseUpdateTracker {
    @testSetup
    public static void setUpData(){
        nm_Program__c prog = new nm_Program__c(Name='MBA(WX) - DM', nm_TotalSemesters__c=5, PVM__c=30);
        insert prog;
        Case c = new Case( purpose__c='Test', Status='New', Subject='Test123');
        insert c;
    }
    
    @isTest
    static void testUnit1() {
        Case c = [Select Id, CaseNumber FROM Case limit 1];  
        Map<String,String> fieldMap = new Map<String,String>{'nos'=> c.CaseNumber ,'comment'=> 'Test1234', 'Status' => 'Escalated'};
        MassUpdateCases.UpdateCases(fieldMap);
        LookupController.fetchLookupData('Likesh' , 'User');
        MassUpdateCases.getProgram(c.Id);
        MassUpdateCases.addComment(fieldMap, c.Id);
        MassUpdateCases.getDependentPicklistValues('Admissions', 'MBA(WX) - DM');
    }
}