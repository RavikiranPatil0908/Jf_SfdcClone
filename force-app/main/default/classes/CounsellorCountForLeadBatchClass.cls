public  class CounsellorCountForLeadBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    AssignCounsellorHelper AssignCounsellorHelper = new AssignCounsellorHelper();
    public String Group1 = AssignCounsellorHelper.Group1;
    public void execute(SchedulableContext sc) {
        CounsellorCountForLeadBatchClass b = new CounsellorCountForLeadBatchClass();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        AssignCounsellorHelper.getLeadWithCounsellor();
        System.debug('CounsellorCountForLeadBatchClass started');
        // String leadId = '00QO0000008ZKfM';
        Date todayDate = Date.today(); 
        String query = 'SELECT id, nm_InformationCenter__c,Counselor_Profile__c,OwnerId,nm_ChooseaProgram__c FROM Lead WHERE CreatedDate= Today  AND IsConverted=false AND IsDeleted = false AND nm_InformationCenter__r.GroupName__c = :Group1';
        if(Test.isRunningTest()) {
            query =  'SELECT id, nm_InformationCenter__c,Counselor_Profile__c,OwnerId,nm_ChooseaProgram__c FROM Lead';
        }
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        
        
        List <Lead> leadToUpdate = new List<Lead>();
        if(scope.size() > 0) { 
            for(SObject sc : scope){
                Lead objLead = (Lead)sc;
                if(objLead.nm_InformationCenter__c != null && objLead.Counselor_Profile__c == null)
                {
                    system.debug('objLead.Id ===>' + objLead.Id);
                   Lead upLead = AssignCounsellorHelper.getLeadToUpdate(objLead);
                   if(upLead != null ) {
                       leadToUpdate.add(upLead);  
                   }
                }

            }
        } else {
            System.debug('No records found.');
        }
        if(leadToUpdate.size() > 0) {
            update leadToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }







    
}