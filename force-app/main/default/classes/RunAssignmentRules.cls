public class RunAssignmentRules {

    @InvocableMethod
    public static void assignCases(List<Id> leadIds){
       
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        List<Case> toAssign = [SELECT Id FROM Case WHERE Id = :leadIds];
        Database.update(toAssign,dmlOpts);
    }
    
}