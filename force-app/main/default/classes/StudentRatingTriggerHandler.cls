public  class StudentRatingTriggerHandler {
    public static boolean IsAfterInsertRunOnce = false;
    public static boolean IsAfterUpdateRunOnce = false;


     public void addAccountOnRating(List<Student_Rating__c> lstStudentRating) {
         if(IsAfterInsertRunOnce){
            return;
        }   
        IsAfterInsertRunOnce = true;
        Set<Id> AccountIds = new Set<Id>();
        system.debug('lstStudentRating --> ' + lstStudentRating);
        for (Student_Rating__c objStudentRating : lstStudentRating) {
            if( String.isNotBlank(objStudentRating.imageUpload__c ) && String.isNotBlank(objStudentRating.Student__c) ) {
                system.debug('inside --> ');
                AccountIds.add(objStudentRating.Student__c);
            }
            
        }
        
        if(AccountIds.size() > 0) {
            updateAccount(AccountIds);
        }
    }
     public void UpdateAccountOnRating(List<Student_Rating__c> lstStudentRating, map<id, Student_Rating__c> mapOldOpportunity) {
         if(IsAfterUpdateRunOnce){
            return;
        }   
        IsAfterUpdateRunOnce = true;
        Set<Id> AccountIds = new Set<Id>();
        system.debug('lstStudentRating --> ' + lstStudentRating);
        for (Student_Rating__c objStudentRating : lstStudentRating) {
            if( String.isNotBlank(objStudentRating.imageUpload__c ) &&objStudentRating.imageUpload__c != mapOldOpportunity.get(objStudentRating.Id).imageUpload__c && String.isNotBlank(objStudentRating.Student__c) ) {
                system.debug('inside --> ');
                AccountIds.add(objStudentRating.Student__c);
            }
            
        }
        
        if(AccountIds.size() > 0) {
            updateAccount(AccountIds);
        }
    }
    @future
    public static void updateAccount(Set<Id> Accounts) {
        List<Account> lstAccountToUpdate = new List<Account>();
        if(Accounts.size() > 0) {
            List<Account> lstAccounts = [SELECT Id, Interview_Status__c, Program_Type__c FROM Account WHERE Id IN :Accounts];
            if(lstAccounts.size() > 0) {
                system.debug('lstAccounts ---> ' + lstAccounts);
                for(Account objAccount: lstAccounts) {
                    if(objAccount.Interview_Status__c != 'Selected' && objAccount.Program_Type__c == 'MBA (WX)') {
                       system.debug('inside --> ');
                       Account upAccount = new Account();
                       upAccount.Id = objAccount.Id;
                       upAccount.Interview_Status__c = 'Approval Pending';
                       lstAccountToUpdate.add(upAccount);  

                   }
               } 
            }
        }
        if(lstAccountToUpdate.size() > 0) {
            update lstAccountToUpdate;
        }
    }
}