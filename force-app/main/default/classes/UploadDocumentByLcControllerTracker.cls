/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 07--11--2024
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public class UploadDocumentByLcControllerTracker {

    
    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Confirmed');
    }

    @IsTest
    static void unitTest1(){
       Account acc=[SELECT Id ,nm_StudentNo__c FROM Account LIMIT 1];
       Test.startTest();
       UploadDocumentByLcController.getAccountDetails(acc.nm_StudentNo__c);
       Test.stopTest();
    }
     
}