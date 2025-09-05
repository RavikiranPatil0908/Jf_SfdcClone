/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--08--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   07--08--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/auth/MobileAppStudentAuthAPI/*')
global with sharing class MobileAppLoginPageAPI {
  
    /**
    * @description 
    * @author @Ravi | 29--08--2025 
    * @return APIResponseWrapper 
    **/
    @HttpPost
    global static APIResponseWrapper handleStudentLogin() {
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        APIResponseWrapper response = new APIResponseWrapper();
        LoginPageController controller = new LoginPageController(true);
        controller.objOTP = new OTPFields();
        try {
            APIRequestWrapper input = (APIRequestWrapper)JSON.deserialize(req.requestBody.toString(), APIRequestWrapper.class);
            controller.objRequest = input.data;
            controller.objOTP = setOTPFields(input.otp);
            
            switch on input.action {
                when 'Login' {
                    controller.submitLogin();
                }
                when 'verifyOTP' {
                    if (String.isNotBlank(controller.objOTP.Otp)) {
                        controller.verifyOTP();
                    } else {
                        controller.objRequest.errorMsg = 'Please enter OTP.';    
                    }   
                }
                when 'resendOTP' {
                    controller.submitLogin();
                }
                when else {
                    response.status='Error';
                    response.message = 'Invalid Action';
                }
            }
             setResponse(response, controller);
        } catch (Exception e) {
            System.debug('Exception:===> ' + e.getMessage() + ' (Line: ' + e.getLineNumber() + ')');
            response.status='Error';
            response.message = 'Exception: ' + e.getMessage() + ' (Line: ' + e.getLineNumber() + ')';
        }
        return response;
    }

    // Helper method for response handling
    private static void setResponse(APIResponseWrapper response, LoginPageController controller) {
        response.message = String.isNotBlank(controller.objRequest.errorMsg)  ? controller.objRequest.errorMsg : controller.objOTP.errorMsg;
        response.status = String.isBlank(response.message) ? 'Success' : 'Error';
        response.recordId =controller.objOTP.recordId;
        response.otpobj = controller.objOTP;
    }

    /**
    * @description 
    * @author @Ravi | 29--08--2025 
    * @param OTPFields input 
    * @return OTPFields 
    **/
    private static OTPFields setOTPFields(OTPFields input) {
        OTPFields otp = new OTPFields(); // constructor defaults
        if (input == null) return otp;

        // Override only if JSON had values
        otp.otpStatus           = input.otpStatus;
        otp.Otp                 = input.Otp;
        otp.resendOtp           = input.resendOtp;
        otp.LoginType           = String.isNotBlank(input.LoginType) ? input.LoginType : otp.LoginType;
        otp.recordObject        = String.isNotBlank(input.recordObject) ? input.recordObject : otp.recordObject;
        otp.OtpCode             = input.OtpCode;
        otp.otpSentTime         = input.otpSentTime != null ? input.otpSentTime : otp.otpSentTime;
        otp.mobileNo            = input.mobileNo;
        otp.EmailId             = input.EmailId;
        otp.checkToAllowOTP     = input.checkToAllowOTP != null ? input.checkToAllowOTP : otp.checkToAllowOTP;
        otp.skipOTP             = input.skipOTP != null ? input.skipOTP : otp.skipOTP;
        otp.OtpMode             = String.isNotBlank(input.OtpMode) ? input.OtpMode : otp.OtpMode;
        otp.PersonContactId     = input.PersonContactId;
        otp.alertMsg            = input.alertMsg;
        otp.isEmailVerified     = input.isEmailVerified != null ? input.isEmailVerified : otp.isEmailVerified;
        otp.isMobileVerified    = input.isMobileVerified != null ? input.isMobileVerified : otp.isMobileVerified;
        otp.errorMsg            = input.errorMsg;
        otp.recordId            = input.recordId;
        otp.isOTPSent           = input.isOTPSent != null ? input.isOTPSent : otp.isOTPSent;
        otp.isSuccess           = input.isSuccess != null ? input.isSuccess : otp.isSuccess;
        otp.isModeVerified      = input.isModeVerified;
        otp.isEmailMobileChange = input.isEmailMobileChange != null ? input.isEmailMobileChange : otp.isEmailMobileChange;
        return otp;
    }

    global class APIRequestWrapper {
        public String action;
        public LoginPageController.RequestWrapper data;
        public OTPFields otp;
    }

    global class APIResponseWrapper {
        public String recordId;
        public String message;
        public String status;
        public OTPFields otpobj;
    }
}