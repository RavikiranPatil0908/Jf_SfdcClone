/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-06-2023
 * @last modified by  : @BK
**/
public without sharing class CPTriggerHandler {

    public void BeforeInsert(List<Counsellor_Profile__c> triggerNew) {
        aepAutoSelection(triggerNew);
    }

    public void aepAutoSelection (list<Counsellor_Profile__c> lstcp){
        String currentUserId = userinfo.getuserid();
        User objuser = [SELECT Id,ContactId ,Profile.Name FROM user WHERE id=:currentUserId];
        Set<Id> setOfAccountId = new Set<Id>();
        Map<String,String> mapOfAccountVsInfoCenter = new Map<String,String>();

        for (Counsellor_Profile__c obj : lstcp) {
            setOfAccountId.add(obj.BusinessAccount__c);
        }

        List<Account> lstAccount = [SELECT id,Name,nm_Centers__c, nm_Centers__r.Name FROM Account WHERE RecordType.Name='Business Account' AND Id IN :setOfAccountId]; 
        for(Account ob : lstAccount) {
            mapOfAccountVsInfoCenter.put(ob.Id,ob.nm_Centers__c);
        }
        
        for(Counsellor_Profile__c obj:lstcp) {
            //if(objuser.Profile.Name=='pp profile' && String.isBlank(obj.BusinessAccount__c)) {
            if(objuser.Profile.Name=='Information Center Partner Community User' && String.isBlank(obj.BusinessAccount__c)) {
                obj.addError('please add Business Account'); 
            }

            if(String.isNotBlank(obj.BusinessAccount__c) && mapOfAccountVsInfoCenter.containsKey(obj.BusinessAccount__c)) {
                System.debug('Inside cp loop 2');
                System.debug('mapOfAccountVsInfoCenter.get(obj.BusinessAccount__c)==>'+mapOfAccountVsInfoCenter.get(obj.BusinessAccount__c));
                obj.AEP_Name__c = mapOfAccountVsInfoCenter.get(obj.BusinessAccount__c);
            }
        }
    }
}