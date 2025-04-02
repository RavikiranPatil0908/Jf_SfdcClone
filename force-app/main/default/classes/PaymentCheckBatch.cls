/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-01-2023
 * @last modified by  : @BK
**/
public class PaymentCheckBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Integer totalRecordsPending = 0;

    public void execute(SchedulableContext sc) {
        PaymentCheckBatch b = new PaymentCheckBatch();
        Database.executebatch(b, 50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> lstOfGatewayNames = System.Label.PaymentGatewayList.split(',');
        //Query will comapare using GMT time. Fetch Intiated Payment records created 30 minutes back and still in status of Payment Initiated 
        //String query = 'SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c,OrderId__c FROM nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c IN:lstOfGatewayNames AND is_Verified__c=false AND (nm_PaymentStatus__c=\'Payment Initiated\' OR nm_PaymentStatus__c=\'Transaction Failed\') AND CreatedDate=LAST_N_DAYS:15 ORDER BY CreatedDate';
        String query = 'SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c,OrderId__c, Payment_Gateway_Version__c, Additional_param3__c FROM nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c IN:lstOfGatewayNames AND (nm_PaymentStatus__c=\'Payment Initiated\' OR nm_PaymentStatus__c=\'Transaction Failed\') AND CreatedDate=LAST_N_DAYS:15 ORDER BY CreatedDate';
        System.debug('Query = '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<nm_Payment_Initiated__c> scope){
        Map<String, nm_Payment_Initiated__c> uniqueMerchantRefNoMap = new Map<String, nm_Payment_Initiated__c>();
        Integer counter = 0;
        System.debug('scope = '+scope.size());
        for(Sobject s : scope){
            counter++;
            if(counter < 70) {
                nm_Payment_Initiated__c initiatedPayment = (nm_Payment_Initiated__c)s;
                uniqueMerchantRefNoMap.put(initiatedPayment.nm_Merchant_Track_Id__c, initiatedPayment);
            } else {
                totalRecordsPending++;
            }
        }
        System.debug('counter ==>'+counter);
        System.debug('uniqueMerchantRefNoMap size'+uniqueMerchantRefNoMap.size());

        PaymentCheckHelperClass objHelper = new PaymentCheckHelperClass();
        objHelper.batchExecute(uniqueMerchantRefNoMap);
    }
    
    public void finish(Database.BatchableContext BC){
        // Make another callout
        if (totalRecordsPending > 0) {
            Database.executeBatch(new PaymentCheckBatch());
        }
        System.debug('Finished');
    }
}