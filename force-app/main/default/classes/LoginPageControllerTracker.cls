/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 21-08-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData = false)
public with sharing class LoginPageControllerTracker {
  

    @TestSetup    
    public static void makeData(){  

        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_RegistrationNo__c = 'TEST123';
        objLead.nm_IsEmailVerified__c = false;
        objLead.Is_Mobile_Verified__c = false;
        update objLead;
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_RegistrationNumber__c = 'TEST456';
        objAccount.nm_StudentStatus__c = 'Confirmed';
        objAccount.nm_IsEmailVerified__c = false;
        objAccount.Is_Mobile_Verified__c = false;
        update objAccount;
    }
     
    /**
    * @description 
    * @author Ravi | 07-23-2024 
    **/
    @isTest
    static void unitTest1() {
        LoginPageController  controller = new LoginPageController();
        controller.objRequest.registrationNumber = 'TEST123';
        Test.startTest();
        controller.objOTP.mobileNo = '1234567890'; 
        controller.objOTP.OtpMode = 'M'; 
        controller.objOTP.otpStatus = 'OTP Verified';
        controller.submitLogin();
        System.assertNotEquals(controller.objRequest.errorMsg, '', 'Error message should not be empty if login fails');
        Test.stopTest();
    }

   
 
    @isTest
    static void unitTest2() {
        LoginPageController  controller = new LoginPageController();
        List<Lead> lstLead = [SELECT id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        controller.objRequest.registrationNumber = lstLead[0].nm_RegistrationNo__c;
        
        Test.startTest();
        Boolean result = controller.getRecordDetails();
        System.assertEquals(result, true);    
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        LoginPageController  controller = new LoginPageController();
         List<Account> lstAccount= [SELECT id,nm_RegistrationNumber__c FROM Account LIMIT 1];
        controller.objRequest.registrationNumber = lstAccount[0].nm_RegistrationNumber__c;
        
        Test.startTest();
        Boolean result = controller.getRecordDetails(); 
        System.assertEquals(result, true);
        Test.stopTest();
    }


    @isTest
    static void unitTest4() {
        LoginPageController  controller = new LoginPageController();
        Test.startTest();
        controller.objOTP.OtpMode = 'M'; 
        controller.objOTP.mobileNo = '1234567890'; 
        Boolean result = controller.checkEmailMobile();
        System.assertEquals(result, true);
        Test.stopTest();
    }

  
    @isTest
    static void unitTest5() {
        LoginPageController  controller = new LoginPageController();
        Test.startTest();
        controller.objOTP.OtpMode = 'M'; 
        controller.objOTP.mobileNo = '1234567890'; 
        Boolean result = controller.sendOTP();
        Test.stopTest();
    }

    @isTest
    static void unitTest6() {
        LoginPageController  controller = new LoginPageController();
       Test.startTest();
        controller.objOTP.otpStatus = 'OTP Sent'; 
        controller.objOTP.otpCode = '123456'; 
        controller.objOTP.isSuccess=true;
         controller.verifyOTP();
        Test.stopTest();

    }

    
    @isTest
    static void unitTest7() {
        LoginPageController  controller = new LoginPageController();
        Test.startTest();
        controller.objRequest.registrationNumber = '123456';
        controller.objOTP.OtpMode = 'M';
        controller.reSendOTP();

        Test.stopTest();
    }

    @isTest
    static void unitTest8() {
        LoginPageController  controller = new LoginPageController();
       Test.startTest();
        controller.objOTP.otpStatus = 'OTP Sent'; 
        controller.objOTP.otpCode = '123456'; 
        controller.objOTP.isSuccess=false;
        controller.verifyOTP();
        Test.stopTest();
    }


    @isTest
    static void unitTest9() {
        LoginPageController  controller = new LoginPageController();
        Test.startTest();
        controller.validateSession();
        controller.skipOTP();
        Test.stopTest();
    }

    @isTest
    static void unitTest10() {
        
        Test.startTest();
            PageReference pageRef = Page.ApplicationInquiry;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('skipOTP','true');

            LoginPageController  controller = new LoginPageController();
            controller.objRequest.registrationNumber = 'TEST123';
            controller.objOTP.mobileNo = '1234567890'; 
            controller.objOTP.OtpMode = 'M'; 
            controller.objOTP.otpStatus = 'OTP Verified';
            controller.submitLogin();
        Test.stopTest();
    }

}