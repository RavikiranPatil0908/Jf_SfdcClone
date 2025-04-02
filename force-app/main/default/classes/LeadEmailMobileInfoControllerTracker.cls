/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : @Monikac
**/
@isTest(SeeAllData=false)
public class LeadEmailMobileInfoControllerTracker {

    @TestSetup
    static void makeData(){
        nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    @isTest
    public static void unitTest1() {
        Lead objLead = [SELECT Id,Email,MobilePhone, nm_SecondryEmail__c, Phone FROM Lead LIMIT 1];
        Test.startTest();
        LeadEmailMobileInfoController.getLeadEmailMobileInfo(objLead.Id);
        LeadEmailMobileInfoController.updateLeadInfo(objLead.Id,'test123@gmail.com.invalid','8377985721','test1234@gmail.com.invalid','9377985521');
        Test.stopTest();
    }
}