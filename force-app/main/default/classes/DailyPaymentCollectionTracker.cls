/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 03-03-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   03-03-2021   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class DailyPaymentCollectionTracker {
    
    @isTest
    static void testMethod1() {
        DailyPaymentCollectionController objController = new DailyPaymentCollectionController();
        objController.getPaymentRecords();
    }
}