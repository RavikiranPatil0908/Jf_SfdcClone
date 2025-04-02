/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 04-13-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-13-2021   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class MobileVerificationTracker {
    
    @TestSetup
    static void makeData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2021;
        objCal.Session_End_Date__c = system.today()+1;
        insert objCal;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
    }

    @isTest
    static void unitTest1() {
        Lead objLead = [SELECT id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        Test.startTest();
            MobileVerification objClass = new MobileVerification();
            objClass.registrationNo = objLead.nm_RegistrationNo__c;
            objClass.sendOTP();
            objClass.Otp = objClass.OtpCode;
            objClass.VerifyOTP();
        Test.stopTest();
    }

    @isTest
    static void unitTest2() { 
        Account objAccount = [SELECT id,nm_RegistrationNumber__c FROM Account LIMIT 1];
        Test.startTest();
            MobileVerification objClass = new MobileVerification();
            objClass.registrationNo = objAccount.nm_RegistrationNumber__c;
            objClass.sendOTP();
            objClass.Otp = objClass.OtpCode;
            objClass.VerifyOTP();
        Test.stopTest();
    }
}