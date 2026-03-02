/**
 * @description       :
 * @author            : @Ravi
 * @group             :
 * @last modified on  : 20--02--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   19--01--2026   @Ravi   Initial Version
**/
@istest (SeeAllData=false)
public class MobileAppLoginPageAPITracker {

    @TestSetup
    static void setupData() {
     Account acc = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
     acc.nm_RegistrationNumber__c ='2222';
     update acc;
     Lead led =nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
     led.nm_RegistrationNo__c ='1111';
     update led;
    }

    private static void setRestRequest(String body) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/auth/MobileAppStudentAuthAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @IsTest
    static void unitTest1() {

        String body = '{"regNumber":"1111","action":"Login","OtpMode":"M"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();
    }

    @IsTest
    static void unitTest2() {

        String body = '{"regNumber":"1111","action":"verifyOTP","OtpMode":"M","studentOTP":"123456"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();
    }
  

    /* ================= RESEND OTP ================= */

    @IsTest
    static void unitTest3() {

        String body = '{"regNumber":"1111","action":"resendOTP","OtpMode":"M"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();

    }

    /* ================= SKIP LOGIN ================= */

    @IsTest
    static void unitTest4() {

        String body = '{"regNumber":"1111-SkipOtp","action":"Login","OtpMode":"M"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();

    }

    /* ================= SKIP OTP FAILURE ================= */

    @IsTest
    static void unitTest5() {

        String body = '{"regNumber":"1111-SkipOtp","action":"verifyOTP","OtpMode":"M","studentOTP":"000000"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();
    }

    /* ================= ACCOUNT LOGIN ================= */

    @IsTest
    static void unitTest6() {

        String body = '{"regNumber":"2222","action":"Login","OtpMode":"M"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res =MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();

    }

    /* ================= INVALID REG ================= */

    @IsTest
    static void unitTest7() {

        String body = '{"regNumber":"INVALID","action":"Login","OtpMode":"M"}';
        setRestRequest(body);

        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();
    }
    
        @IsTest
    static void unitTest8() {
        Lead led =[SELECT id FROM Lead LIMIT 1];
        Test.startTest();
        MobileAppLoginPageAPI.updateStudentLogin(led.Id);
        Test.stopTest();
    }
    
         @IsTest
    static void unitTest9() {
        Lead led =[SELECT id FROM Lead LIMIT 1];
        led.nm_RegistrationNo__c ='1212';
        led.InactiveLead__c =true;
        update led; 
        String body = '{"regNumber":"1212","action":"Login","OtpMode":"M","studentOTP":"123456"}';
        setRestRequest(body);
        Test.startTest();
        MobileAppLoginPageAPI.APIResponseWrapper res = MobileAppLoginPageAPI.handleStudentLogin();
        Test.stopTest();
    }

 
}