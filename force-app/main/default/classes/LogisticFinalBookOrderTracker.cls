/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 06-19-2024
 * @last modified by  : @vickysahu
**/
@istest (SeeAllData=false)
public class LogisticFinalBookOrderTracker {
    
    @TestSetup
    static void makeData(){
        Order_Book__c objOB = new Order_Book__c();
        objOB.Order_Status__c = 'Created';
        objOB.Publisher__c = 'Wiley; Pearson';
        objOB.Session__c = 'January';
        objOB.Year__c = '2024';
        objOB.Type__c = 'New';
        objOB.Final_Order__c = 1000;
        insert objOB;
    }

    @isTest
    public static void test1() {
        List<Order_Book__c> lstOrder = [SELECT Id FROM Order_Book__c LIMIT 1];
        LogisticFinalBookOrder.updatefinalBooksOrder(lstOrder[0].Id,6477,'74647','oldRemarks','newRemark','editor');
    }
}