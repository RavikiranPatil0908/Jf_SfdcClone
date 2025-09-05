/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 04-04-2025
 * @last modified by  : @Shailesh
**/
public  class AsyncTransferApiRequest implements Queueable  {

    private List<Account> lstAccount;

    /**
    * @description 
    * @author @Shailesh | 04-04-2025 
    * @param List<Account> accounts 
    **/
    public AsyncTransferApiRequest(List<Account> accounts) {
        this.lstAccount = accounts;
    }

    public void execute(QueueableContext context) {

        Map<String,Id> mapLeadAccountId = new Map<String,Id>();
        List<API_Request__c> lstApiRequestToUpdate = new List<API_Request__c>();
        for (Account objAccount : lstAccount) {
            if(String.isNotBlank(objAccount.nm_LeadId__c))  {
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }

        for(API_Request__c objapirequest : [SELECT id,Account__c,Lead__c FROM API_Request__c WHERE Lead__c IN : mapLeadAccountId.keyset()]) {
            //updating id of account
            Id leadId = objapirequest.Lead__c; 
            objapirequest.Account__c = mapLeadAccountId.get(String.valueOf(leadId));
            System.debug('<---- student for objapirequest ----->'+objapirequest.Account__c);
            objapirequest.Lead__c = null;
            System.debug('<--- objapirequest.Lead__c--->'+ objapirequest.Lead__c);
            //Adding updated data in list           
            lstApiRequestToUpdate.add(objapirequest);
        }
        //Updating List of ApiRequest
        if(!lstApiRequestToUpdate.isEmpty()) {
            update lstApiRequestToUpdate;
        }
        

    }
}