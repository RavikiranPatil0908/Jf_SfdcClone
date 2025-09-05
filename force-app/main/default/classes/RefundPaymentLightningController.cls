/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 11--06--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   11--06--2025   @Ravi   Initial Version
**/
public without sharing class RefundPaymentLightningController {
  
      /**
      * @description 
      * @author @Ravi | 11--06--2025 
      * @param String oppsid 
      * @return Decimal 
      **/
       @AuraEnabled
      public static  Decimal sendRegfee(String oppsid) {
            system.debug('refund called --> ' + oppsid);
            List<OpportunityLineItem> lstLineItem = new List<OpportunityLineItem>();
            Decimal regfee = 0;
            if(String.isNotBlank(oppsid)){
                lstLineItem = [SELECT id,OpportunityId ,Product_Name__c,PriceBookEntryId ,UnitPrice FROM OpportunityLineItem WHERE OpportunityId =:oppsid AND Product_Name__c = 'Registration Fee' LIMIT 1];       
                if(lstLineItem.size() > 0){
                regfee = lstLineItem[0].UnitPrice;
                }       
            }
            return regfee;         
        }
}