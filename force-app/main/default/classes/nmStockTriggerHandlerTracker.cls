/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-02-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class nmStockTriggerHandlerTracker {

    @TestSetup
    static void makeData(){ 
        Stock_Keeping_Units__c stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        insert stockUnit;
        
        nm_Centers__c centerLearningCenter = insertCenters();

        Stock__c stockFromCenter = new Stock__c();
        stockFromCenter.Centers__c = centerLearningCenter.id;
        stockFromCenter.Incoming_Quantity__c = 0;
        stockFromCenter.Outgoing_Quantity__c = 0;
        stockFromCenter.Quantity__c = 500;
        stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
        insert stockFromCenter;
    }

    @isTest 
    static void unitTest1(){ 
        List<nm_Centers__c> lstCenter = [SELECT id FROM nm_Centers__c WHERE Name='Transit Center' LIMIT 1];
        List<Stock_Keeping_Units__c> lstSKU = [SELECT id FROM Stock_Keeping_Units__c LIMIT 1];
        Test.startTest();
            Stock__c stockFromCenter2 = new Stock__c();
            stockFromCenter2.Centers__c = lstCenter[0].id;
            stockFromCenter2.Incoming_Quantity__c = 0;
            stockFromCenter2.Outgoing_Quantity__c = 0;
            stockFromCenter2.Quantity__c = 500;
            stockFromCenter2.Stock_Keeping_Unit__c = lstSKU[0].id;
            insert stockFromCenter2;

            stockFromCenter2.Quantity__c = 600;
            update stockFromCenter2;
        Test.stopTest();
    }

    @isTest 
    static void unitTest2(){ 
        List<Stock__c> lstSTK = [SELECT id,Quantity__c FROM Stock__c LIMIT 1];
        Test.startTest();
            lstSTK[0].Quantity__c = 200;
            update lstSTK;
        Test.stopTest();
    }

    public static nm_Centers__c insertCenters() {
        RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
        nm_Centers__c centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Name='Mumbai';
        centerLearningCenter.Nm_Active__c = true;
        centerLearningCenter.nm_CenterCode__c = 'abcd';
        centerLearningCenter.nm_City__c = 'Mumbai';
        centerLearningCenter.Contact_No_1__c = '9867167685';
        centerLearningCenter.nm_Country__c = 'India';
        centerLearningCenter.nm_StateProvince__c = 'Maharashtra';
        centerLearningCenter.nm_Street__c = 'Altmount Road';
        centerLearningCenter.nm_PostalCode__c = '400601';
        centerLearningCenter.RecordTypeID = learningCenter.id;
        insert centerLearningCenter;

        nm_Centers__c centerInformationCenter = new nm_Centers__c();
        centerInformationCenter.Name='Transit Center';
        centerInformationCenter.Nm_Active__c = true;
        centerInformationCenter.nm_CenterCode__c = 'abcd234';
        centerInformationCenter.nm_City__c = 'Mumbai - Mira Road East';
        centerInformationCenter.Contact_No_1__c = '9867167685';
        centerInformationCenter.nm_Country__c = 'India';
        centerInformationCenter.nm_StateProvince__c = 'Maharashtra';
        centerInformationCenter.nm_LearningCenter__c = centerLearningCenter.id;
        centerInformationCenter.nm_Street__c = 'Altmount Road';
        centerInformationCenter.nm_PostalCode__c = '400601';
        insert centerInformationCenter;
        return centerLearningCenter;
    }
}