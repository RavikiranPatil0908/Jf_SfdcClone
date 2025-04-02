/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-03-2024
 * @last modified by  : @BK
**/
global without sharing class UpdateCaseOwner {

    WebService Static Boolean caseTransfer(String caseId) {
        System.debug('Case called --> ' + caseId);
        try {
            List<Case> lstCase = [SELECT id,FirstCaseAssigned__c,OwnerId,Status FROM Case WHERE id=:caseId AND FirstCaseAssigned__c!=null LIMIT 1];
            if(lstCase.size() > 0) {
                String userName = lstCase[0].FirstCaseAssigned__c;
                List<User> lstUsers = [SELECT Id,Name,IsActive,Profile.Name FROM User WHERE Name=:userName AND IsActive=true];
                if(lstUsers.size() > 0) {
                    lstCase[0].OwnerId = lstUsers[0].Id;
                    if(lstCase[0].Status == 'Escalated') {
                        lstCase[0].Status = 'Internal Response Received';
                    }
                    update lstCase;
                    return true;
                }
            }
        } catch (Exception error) {
            System.debug('Error ==>'+ error.getMessage());
            System.debug('Error Line No :==>'+ error.getLineNumber());
        }
        return false;
    }

}