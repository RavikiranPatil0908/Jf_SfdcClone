/**
 * @description       : 
 * @author            : @Monikac
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : @Monikac
**/
@isTest(SeeAllData=false)
public class PersonAccountDetailsControllerTracker {

    @TestSetup
    static void makeData(){
        nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Confirmed');
    }

    @isTest
    public static void unitTest1() {
        Account objAccount = [SELECT Id,PersonEmail,PersonMobilePhone, nm_SecondryEmail__c, Phone FROM Account LIMIT 1];
        Test.startTest();
        PersonAccountDetailsController.getPersonAccountDetails(objAccount.Id);
        Test.stopTest();
    }
}