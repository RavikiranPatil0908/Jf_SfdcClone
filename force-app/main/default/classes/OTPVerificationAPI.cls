/**
 * @description       : OTP Verification API 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 02--03--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   24--08--2025   @Ravi    Initial Version
**/
@RestResource(urlMapping='/api/salesforce-otpservice/*')
global without sharing class OTPVerificationAPI {
    
    /**
    * @description 
    * @author @Ravi | 25--08--2025 
    * @return ResponseWrapper 
    **/
    @HttpPost
    global static ResponseWrapper handleSendOTP() {
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;

        ResponseWrapper response = new ResponseWrapper();
        OTPFields objOTP = new OTPFields();
        OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
        try {
            // Deserialize request body
            RequestWrapper input = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
            System.debug('input==:'+input);

            // Validate registration number
            String registrationNumber = input.regNumber != null ? input.regNumber.trim() : null;
            if (String.isBlank(registrationNumber)) {
                response.status  = 'Error';
                response.message = 'Registration/Student Number Required.';
                return response;
            }
            objOTP.OtpMode =input.OtpMode;
            objOTP.Otp =input.studentOTP;
            objOTP.otpSentTime =input.otpSentTime;
            List<Account> accList = [ SELECT Id, is_Video_Call_Verified__c, nm_DateOfBirth__c, nm_Nationality__c, nm_StudentStatus__c, Name, PersonMobilePhone, nm_Program__r.Bachelor_Specialization__c,nm_Program__r.nm_ProgramName__c, PersonEmail, PersonContactId, Is_Mobile_Verified__c,
                           nm_IsEmailVerified__c, City_Shipping_Account__c, nm_Program__r.Form_Specialisation__c,nm_RegistrationNumber__c, nm_ProgramType__c, Program_Name__c, OwnerId
                    FROM Account WHERE (nm_RegistrationNumber__c = :registrationNumber OR nm_StudentNo__c =:registrationNumber) AND nm_StudentStatus__c != 'Closed Lost' LIMIT 1];
            
            List<Lead> leadRecList = [SELECT Id, Name, MobilePhone, Email, Status, nm_DateOfBirth__c,nm_IsEmailVerified__c, Is_Mobile_Verified__c,nm_Program__r.Bachelor_Specialization__c, nm_Program__r.nm_ProgramName__c,nm_RegistrationNo__c, nm_City_P__c, nm_Program__r.Form_Specialisation__c,
                           nm_ChooseaProgram__c, nm_ProgramName__c,Student_Number_Lateral__c, Year_Of_Passing_Lateral__c
                    FROM Lead WHERE nm_RegistrationNo__c = :registrationNumber AND IsConverted=FALSE LIMIT 1];

            // Populate Account details
            if (!accList.isEmpty()) {
                objOTP.recordId=accList[0].Id;
                objOTP.isEmailVerified  = accList[0].nm_IsEmailVerified__c;
                objOTP.isMobileVerified = accList[0].Is_Mobile_Verified__c;
                objOTP.PersonContactId  = accList[0].PersonContactId;
                objOTP.EmailId          = accList[0].PersonEmail.contains('de-registered_') ? accList[0].PersonEmail.remove('de-registered_') : accList[0].PersonEmail;
                objOTP.mobileNo         = accList[0].PersonMobilePhone.contains('de-registered_') ? accList[0].PersonMobilePhone.remove('de-registered_') : accList[0].PersonMobilePhone;
                objOTP.recordObject     = 'Account';

            // Populate Lead details
            } else if (!leadRecList.isEmpty()) {
                objOTP.recordId=leadRecList[0].Id;
                objOTP.isEmailVerified = leadRecList[0].nm_IsEmailVerified__c;
                objOTP.isMobileVerified = leadRecList[0].Is_Mobile_Verified__c;
                objOTP.EmailId          = leadRecList[0].Email;
                objOTP.mobileNo         = leadRecList[0].MobilePhone;
                objOTP.recordObject     = 'Lead';
            } else {
                response.status  = 'Error';
                response.message = 'No match found for this registration/Student Number, Please verify and try again.';
                return response;
            }
            // Handle action
            switch on input.action {
                when 'SendOTP'{
                    objOTP = objVerifyHandler.triggerToSendOTP(objOTP); 
                }
                when 'verifyOTP' {
                    if(!String.isBlank(objOTP.Otp)){
                        objOTP = objVerifyHandler.verifyOTP(objOTP);
                    } else {
                        response.status  = 'Error';
                        objOTP.errorMsg  ='Please Enter OTP.';
                    }
                }
                when 'resendOTP' {
                    objOTP = objVerifyHandler.triggerToSendOTP(objOTP);
                }
                when else {
                    response.status  = 'Error';
                    response.message = 'Invalid Action';
                }
            }
            setResponse(response, objOTP);
            return response;
        } catch (Exception error) {
            response.status  = 'Error';
            response.message = error.getMessage();
            System.debug('Error:' + error.getMessage() + ' | Line:' + error.getLineNumber());
            return response;
        }
    }

    /**
    * @description -- Utility method to set response fields from OTPFields
    * @author @Ravi | 25--08--2025 
    * @param ResponseWrapper response 
    * @param OTPFields objOTP 
    **/
    private static void setResponse(ResponseWrapper response, OTPFields objOTP) {
        response.message = objOTP.errorMsg;
        response.status  = String.isBlank(response.message) ? 'Success' : 'Error';
        response.otpobj =objOTP;
        response.otpobj.OtpCode ='';
    }

    // Request Wrapper
    global class RequestWrapper {
        public String regNumber;
        public String action;
        public String OtpMode;
        public String studentOTP;
        public Long otpSentTime;
    }
    // Response Wrapper
    global class ResponseWrapper {
        public String status;
        public String message;
        public OTPFields otpobj;
        public ResponseWrapper() {
            otpobj = new OTPFields(); // to avoid null reference
        }
    }

    
}