/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 04-13-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData=false)
public class KitReorderReminderBatchClassTracker {
    
    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
        Stock_Keeping_Units__c  stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S1-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='1';
        
        insert stockUnit;
        
        RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
          
        nm_Centers__c  centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Name='Transit Center';
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
        
        List<Stock__c> lstToInsert = new List<Stock__c>();

        Stock__c stockFromCenter = new Stock__c();
        stockFromCenter.Centers__c = centerLearningCenter.id;
        stockFromCenter.Incoming_Quantity__c = 0;
        stockFromCenter.Outgoing_Quantity__c = 0;
        stockFromCenter.Quantity__c = 500;
        stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
        stockFromCenter.Re_order_Quantity__c = 520;
        stockFromCenter.IsActive__c = true;
        lstToInsert.add(stockFromCenter);

        insert lstToInsert;        
    }

    @isTest
    static void unitTest1() {
        // Stock__c objStock = [SELECT Id,Email_Count__c,Is_Quantity_Below_Reorder__c FROM Stock__c];
        Test.startTest();
        KitReorderReminderBatchClass b = new KitReorderReminderBatchClass();
        Database.executebatch(b, 200);
        Test.stopTest();
    }
}