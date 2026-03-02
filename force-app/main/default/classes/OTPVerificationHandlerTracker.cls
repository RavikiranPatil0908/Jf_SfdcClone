/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 10--02--2026
 * @last modified by  : @Ravi
**/

@isTest(SeeAllData = false)
public class OTPVerificationHandlerTracker {

    @TestSetup    
    public static void makeData() { 
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No', false);
        
    }

    @isTest
    static void unitTest1() {
        // Setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.recordObject ='Account';
        otpFields.mobileNo ='1234567890';
        otpFields.recordId = acc.Id;
       
        Test.startTest();
        handler.sendOTP(otpFields);
       
        otpFields.recordObject ='Account';
        handler.sendOTP(otpFields);
       
        otpFields.OtpMode = 'M';
        handler.sendOTP(otpFields);
      
        otpFields.OtpMode = 'X';
        handler.sendOTP(otpFields);
        Test.stopTest();
    }
  
    @isTest
    static void unitTest2() {
        // Setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Lead led =[SELECT Id FROM Lead LIMIT 1];
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';    
        otpFields.EmailId = 'test@example.com';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '12345';
        otpFields.recordObject ='Account';
        otpFields.recordId = acc.Id;
        otpFields.otpSentTime = DateTime.now().getTime();

        Test.startTest();
        OTPFields result = handler.verifyOTP(otpFields);
      
        otpFields.OtpMode = 'M';
        otpFields.recordObject ='Account';
        otpFields.recordId = acc.Id;
        handler.verifyOTP(otpFields);
       
        otpFields.OtpMode = 'M';
        otpFields.recordObject ='Account';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '123456';
        otpFields.recordId = acc.Id;
        handler.verifyOTP(otpFields);

        otpFields.OtpMode = 'M';
        otpFields.recordObject ='Lead';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '123456';
        otpFields.recordId = led.Id;
        handler.verifyOTP(otpFields);

        otpFields.OtpMode = 'E';
        otpFields.recordObject ='Lead';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '123456';
        otpFields.recordId = led.Id;
        handler.verifyOTP(otpFields);

        otpFields.OtpMode = 'M';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '123456';
        otpFields.recordObject ='Account';
        otpFields.recordId = acc.Id;
        otpFields.otpSentTime = DateTime.now().addMinutes(-5).getTime();
        handler.verifyOTP(otpFields);
        
        Test.stopTest();
    }
 
 
    @isTest
    static void unitTest3() {
        // Setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.recordId = acc.Id;
        otpFields.recordObject ='Account';
        otpFields.EmailId = 'test@example.com';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '12345';
        otpFields.otpSentTime = DateTime.now().addMinutes(-4).getTime();

        Test.startTest();
        OTPFields result = handler.verifyOTP(otpFields);
        Test.stopTest();

    }

 
    @isTest
    static  void unitTest4() {
        // Setup
        OTPVerificationHandler handler= new OTPVerificationHandler();
        Account acc= [SELECT Id FROM Account LIMIT 1 ];
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.recordObject = 'Account';
        otpFields.recordId = acc.Id;
        otpFields.isEmailVerified = false;

        Test.startTest();
        handler.updateAccount(otpFields);
        otpFields.OtpMode = 'M';
     
        handler.updateAccount(otpFields);
        
        handler.triggerToSendOTP(otpFields);
        OTPVerificationHandler.sendSMS obj = new OTPVerificationHandler.sendSMS('test','test1');
        Test.stopTest();

    }
  @isTest
    static void unitTest5() {
        Lead led = [SELECT Id FROM Lead LIMIT 1];
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.recordId = led.Id;
        otpFields.recordObject ='Account';
        otpFields.EmailId = 'test@example.com';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '12345';
        otpFields.otpSentTime = DateTime.now().addMinutes(-4).getTime();

        Test.startTest();
        OTPFields result = handler.verifyEmailAndMobile(otpFields);
        Test.stopTest();
    }

    @isTest
    static void unitTest7() {
        Lead led = [SELECT Id FROM Lead LIMIT 1];
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'M';
        otpFields.recordId = led.Id;
        otpFields.recordObject ='Account';
        otpFields.EmailId = 'test@example.com';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '12345';
        otpFields.otpSentTime = DateTime.now().addMinutes(-4).getTime();

        Test.startTest();
        OTPFields result = handler.verifyEmailAndMobile(otpFields);
        Test.stopTest();
    }

    @isTest
    static void unitTest6() {
        // Setup
        Lead led = [SELECT Id FROM Lead LIMIT 1];
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.recordObject ='Lead';
        otpFields.mobileNo ='1234567890';
        otpFields.recordId = led.Id;
       
        Test.startTest();
        handler.sendOTP(otpFields);
       
        otpFields.recordObject ='Lead';
        handler.sendOTP(otpFields);
       
        otpFields.OtpMode = 'M';
        handler.sendOTP(otpFields);
      
        otpFields.OtpMode = 'X';
        handler.sendOTP(otpFields);
        Test.stopTest();
    }


}