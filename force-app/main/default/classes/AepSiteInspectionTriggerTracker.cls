/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 11-18-2020
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-18-2020   @BK   Initial Version
**/
@istest (SeeAllData=false)
public class AepSiteInspectionTriggerTracker {

    @testSetup
    public static void setUpData(){
        AEP_site_inspection__c objRd = new AEP_site_inspection__c();
        objRd.Entity__c = 'Trust';
        insert objRd;
    }

    @isTest
    static void unitTest1() {
        Test.startTest();
        AEP_site_inspection__c objRd = [SELECT id,Entity__c FROM AEP_site_inspection__c LIMIT 1];
        objRd.Entity__c = 'Society';
        update objRd;

        AepSiteInspectionTriggerHandler objcontroller = new AepSiteInspectionTriggerHandler();
        Test.stopTest();
    }
}