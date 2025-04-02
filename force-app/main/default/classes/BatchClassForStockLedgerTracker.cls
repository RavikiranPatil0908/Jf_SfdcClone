/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class BatchClassForStockLedgerTracker {

    @TestSetup    
    public static void makeData(){  
        Stock_Keeping_Units__c stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        insert stockUnit;
        
        nm_Centers__c centerLearningCenter = nmStockTriggerHandlerTracker.insertCenters();
        List<Stock__c> lstToInsert = new List<Stock__c>();
        for (Integer i = 0; i < 10; i++) {
            Stock__c stockFromCenter = new Stock__c();
            stockFromCenter.Centers__c = centerLearningCenter.id;
            stockFromCenter.Incoming_Quantity__c = 0;
            stockFromCenter.Outgoing_Quantity__c = 0;
            stockFromCenter.Quantity__c = i + 1;
            stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
            stockFromCenter.IsActive__c = true;
            lstToInsert.add(stockFromCenter);
        }
        insert lstToInsert;
        String idToSkip = lstToInsert[0].Id;
        List<Stock_Ledger__c> lstSTL = [SELECT id FROM Stock_Ledger__c WHERE Stock__c!=:idToSkip];
        delete lstSTL;
    }

    @isTest     
    static void UnitTest1() {   
        Test.startTest();
            Database.executeBatch(new BatchClassForStockLedger(),100);
        Test.stopTest();    
    }
}