/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 07-24-2024
 * @last modified by  : @vickysahu
**/

@isTest(SeeAllData = false)
public class OTPVerificationHandlerTracker {

    @TestSetup    
    public static void makeData() { 
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        
    }

    @isTest
    static void unitTest1() {
        // Setup
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.recordObject ='Lead';
        otpFields.mobileNo ='1234567890';
        otpFields.recordId = '00Q1I0000037YvU';
       
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
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';    
        otpFields.EmailId = 'test@example.com';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '12345';
        otpFields.otpSentTime = DateTime.now().getTime();

        Test.startTest();
        OTPFields result = handler.verifyOTP(otpFields);
      
        otpFields.OtpMode = 'M';
        handler.verifyOTP(otpFields);
       
        otpFields.OtpMode = 'M';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '123456';
        handler.verifyOTP(otpFields);

        otpFields.OtpMode = 'M';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '123456';
        otpFields.otpSentTime = DateTime.now().addMinutes(-4).getTime();
        handler.verifyOTP(otpFields);
        
        Test.stopTest();
        System.assertEquals('903', result.otpStatus);
    
    }
 
 
    @isTest
    static void unitTest3() {
        // Setup
        OTPVerificationHandler handler= new OTPVerificationHandler();
        OTPFields otpFields = new OTPFields();
        otpFields.OtpMode = 'E';
        otpFields.EmailId = 'test@example.com';
        otpFields.OtpCode = '12345';
        otpFields.Otp = '12345';
        otpFields.otpSentTime = DateTime.now().addMinutes(-4).getTime();

        Test.startTest();
        OTPFields result = handler.verifyOTP(otpFields);
        Test.stopTest();

        // Verify
        System.assertEquals('907', result.otpStatus);
        System.assertEquals('OTP has been expired, kindly try again.', result.errorMsg);
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


}