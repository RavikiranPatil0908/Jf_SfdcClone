@RestResource(urlMapping='/ChangeBusinessOwner/*')
global without sharing class ChangeBusinessOwner
{


    @HttpPOST
    global static string ChangeBusinessOwner(String ContactId,String NewAccountId)
    {
      
        System.debug('ContactId==>'+ContactId);
        System.debug('NewAccountId ==>'+NewAccountId);
        
        
        list<contact> lstRecords = [select id,AccountId,Counselor_Profile__c, Email from contact where Id=:ContactId];
        
        list<Account> lstNewAccount = [select id,nm_Centers__c  from Account where Id=:NewAccountId LIMIT 1];
        
        String centerId = lstNewAccount[0].nm_Centers__c;
        System.debug('centerId ==>'+centerId);
       List<Counsellor_Profile__c> lstCounsellor = new List<Counsellor_Profile__c>();

        if(lstRecords.size() > 0) {
            List<User> lstUser = [select Id, Name From User Where Email = :lstRecords[0].Email LIMIT 1];
            lstRecords[0].AccountId = NewAccountId;
            if(String.isNotBlank(lstRecords[0].Counselor_Profile__c)) {
                lstCounsellor.add(new Counsellor_Profile__c(Id= lstRecords[0].Counselor_Profile__c, AEP_Name__c = centerId, BusinessAccount__c = NewAccountId));
            }
            if(lstCounsellor.size() > 0) {
                update lstCounsellor;
            }
            if(lstUser.size() > 0) {
                List<nm_UserMapping__c> lstCenterUser = [select Id, Name from nm_UserMapping__c where nm_User__c = :lstUser[0].Id AND nm_Centers__c = :centerId AND nm_Head__c = false LIMIT 1];
                if(lstCenterUser.size() > 0) {
                    lstCenterUser[0].nm_Centers__c = centerId;
                    update lstCenterUser;
                } 

            }
       try {
            RestResponse res = RestContext.response;
            RestRequest req = RestContext.request;
            update lstRecords;
            return 'Successfully update';
        } catch (DmlException e) {
                System.debug(e.getMessage());
                  return e.getMessage();
            }
      
        }
        return 'Failed to update';
    }
    
    
}