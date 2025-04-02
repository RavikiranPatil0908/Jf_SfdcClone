/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 23-08-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class WelcomeLetterPageControllerTracker {

    @testSetup
    public static void setUpData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
    }
  
    @isTest
    public static void testGetEmailBody() {
        Test.startTest();
            Account testAccount = [SELECT Id FROM Account LIMIT 1];
            WelcomeLetterPageController controller = new WelcomeLetterPageController();
            controller.setObjectId(testAccount.Id);
            String result = controller.getObjectId();
            System.assertEquals(testAccount.Id, result, 'The two Ids are not the same');
        Test.stopTest();
    }

    @isTest
    public static void testGetEmailBodyNoObjectId() {
        Test.startTest();
            WelcomeLetterPageController controller = new WelcomeLetterPageController();
        Test.stopTest();
    }
}