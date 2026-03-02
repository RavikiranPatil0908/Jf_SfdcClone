/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 20--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   20--01--2026   @Ravi   Initial Version
**/
@isTest(SeeAllData=false)
public class OTPVerificationAPITracker {

    @TestSetup
    public static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    @IsTest
    static void unitTest1() {
        // createPersonAccount();
        Account acc =[SELECT id,nm_RegistrationNumber__c  FROM Account LIMIT 1];
        OTPVerificationAPI.RequestWrapper req =new OTPVerificationAPI.RequestWrapper();
        req.regNumber = acc.nm_RegistrationNumber__c;
        req.action = 'SendOTP';
        req.OtpMode = 'M';
        setUpData(JSON.serialize(req));
        Test.startTest();
        OTPVerificationAPI.ResponseWrapper response = OTPVerificationAPI.handleSendOTP();
        Test.stopTest();
    }

    @IsTest
    static void unitTest2() {
        // createPersonAccount();
        Account acc =[SELECT id,nm_RegistrationNumber__c  FROM Account LIMIT 1];
        OTPVerificationAPI.RequestWrapper req = new OTPVerificationAPI.RequestWrapper();
        req.regNumber = acc.nm_RegistrationNumber__c;
        req.action = 'verifyOTP';
        req.studentOTP = '123456';
        req.OtpMode = 'M';
        setUpData(JSON.serialize(req));
        Test.startTest();
        OTPVerificationAPI.ResponseWrapper response = OTPVerificationAPI.handleSendOTP();
        Test.stopTest();
    }


    @IsTest
    static void unitTest3() {
        // createPersonAccount();
        Account acc =[SELECT id ,nm_RegistrationNumber__c FROM Account LIMIT 1];
        OTPVerificationAPI.RequestWrapper req = new OTPVerificationAPI.RequestWrapper();
        req.regNumber = acc.nm_RegistrationNumber__c;
        req.action = 'verifyOTP';
        setUpData(JSON.serialize(req));
        Test.startTest();
        OTPVerificationAPI.ResponseWrapper response =OTPVerificationAPI.handleSendOTP();
        Test.stopTest();
    }

    @IsTest
    static void unitTest4() {
        // createLead();
        Lead lead = [SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        OTPVerificationAPI.RequestWrapper req = new OTPVerificationAPI.RequestWrapper();
        req.regNumber = lead.nm_RegistrationNo__c;
        req.action = 'resendOTP';
        req.OtpMode = 'E';
        setUpData(JSON.serialize(req));
        Test.startTest();
        OTPVerificationAPI.ResponseWrapper response = OTPVerificationAPI.handleSendOTP();
        Test.stopTest();
    }

    @IsTest
    static void unitTest5() {
        Account acc =[SELECT id ,nm_RegistrationNumber__c FROM Account LIMIT 1];
        OTPVerificationAPI.RequestWrapper req = new OTPVerificationAPI.RequestWrapper();
        req.regNumber = acc.nm_RegistrationNumber__c;
        req.action = 'N';
        setUpData(JSON.serialize(req));
        Test.startTest();
        OTPVerificationAPI.ResponseWrapper response = OTPVerificationAPI.handleSendOTP();
        Test.stopTest();

    }

    // @IsTest
    // static void testMissingRegistration() {
    //     OTPVerificationAPI.RequestWrapper req =
    //         new OTPVerificationAPI.RequestWrapper();
    //     req.action = 'SendOTP';

    //     setUpData(JSON.serialize(req));

    //     Test.startTest();
    //     OTPVerificationAPI.ResponseWrapper response =
    //         OTPVerificationAPI.handleSendOTP();
    //     Test.stopTest();

    //     System.assertEquals('Error', response.status);
    //     System.assertEquals(
    //         'Registration/Student Number Required.',
    //         response.message
    //     );
    // }

    public static void setUpData(String body) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/api/salesforce-otpservice/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;
    }

    
}