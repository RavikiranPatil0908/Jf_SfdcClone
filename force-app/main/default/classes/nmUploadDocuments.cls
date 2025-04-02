/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 01-10-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01-14-2021   @BK   Initial Version
**/
public class nmUploadDocuments  {
    public string accountId{get;set;}
    public string AccountUId{get;set;}
    public string accountName{get;set;}
    public string centerName{get;set;}
    public string recordId{get;set;}
    public boolean allowed {get;set;}
    public string objType {get;set;}
    public String mode {get;set;}

    public nmUploadDocuments() {
        allowed = false;
        String type = ApexPages.currentPage().getParameters().get('type');
        objType = ApexPages.currentPage().getParameters().get('objType');
        mode = ApexPages.currentPage().getParameters().get('mode');
        if(String.isBlank(mode)) {
            mode = '';
        } else {
            mode = '&mode=' + EncodingUtil.urlEncode(mode, 'UTF-8');
        }
        if(String.isNotBlank(type) && type == 'aep') {
            recordId = ApexPages.currentPage().getParameters().get('id');
            if(recordId != null) {
                List<AEP_site_inspection__c> lstAEPInspection = [select id,Name_of_the_Centre__c from AEP_site_inspection__c where id =: recordId];
                if(lstAEPInspection != null && lstAEPInspection.Size() > 0)
                {
                    centerName = lstAEPInspection[0].Name_of_the_Centre__c;
                    allowed =true;
                }
            }
        } else {
            recordId = ApexPages.currentPage().getParameters().get('id');
            
            if(String.isNotBlank(recordId)) {
                List<account> lstAccount = new List<account>();
                List<lead> lstLead = new List<lead>();

                if(String.isBlank(objType) || objType == 'Account') { 
                    objType = 'Account';
                    lstAccount = [select id, Name, Account_Unique_ID__c  from Account where id =: recordId limit 1];
                    if(lstAccount.size() > 0) {
                        accountName = lstAccount[0].Name;
                        AccountUId=lstAccount[0].Account_Unique_ID__c;
                    }
                } else if(objType == 'Lead') {
                    lstLead = [select id, Name, nm_LeadId__c from Lead where id =: recordId limit 1];
                    if(lstLead.size() > 0) {
                        accountName = lstLead[0].Name;
                        AccountUId = lstLead[0].nm_LeadId__c;
                    }
                }
            }
        }
        
    }
}