/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 07--11--2024
 * @last modified by  : @Ravi
**/
public without sharing class UploadDocumentByLcController {

    /**
    * @description 
    * @author @Ravi | 06--11--2024 
    * @param sapId 
    * @return Account
    **/
    @AuraEnabled
    public static Account getAccountDetails(string sapId){
        try {
            Account studentAccount = verifyStudent(sapId);
            return studentAccount; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author @Ravi | 06--11--2024 
    * @param sapId 
    * @return Account 
    **/
    public static Account verifyStudent(string sapId) {
        List<Account> accList = [SELECT Id, Name, nm_StudentNo__c, OwnerId ,nm_Centers__r.Name FROM Account WHERE nm_StudentNo__c = :sapId LIMIT 1];
        return accList.isEmpty() ? null : accList[0];
    }
  
}