/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 05-22-2021
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-22-2021   shubhranshu   Initial Version
**/
@isTest(SeeAllData=false)
public with sharing class StockQtyUpdateBatchTracker {
    @testSetup
    public static void setUpData(){
        Stock__c st = new Stock__c();
        st.Quantity__c = 10;
        st.Stock_Quantity_history__c = '';
        insert st;
    }

    static testmethod void testSuccessBatch(){
       Test.startTest();
        StockQtyUpdateBatch batchClass = new StockQtyUpdateBatch();
        Database.executeBatch(batchClass,200);
       Test.stopTest();
    }
}