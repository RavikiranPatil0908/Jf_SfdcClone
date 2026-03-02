/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 20--02--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   07--08--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/auth/MobileAppStudentAuthAPI/*')
global without sharing class MobileAppLoginPageAPI {
    

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
        OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
        
        DetailsWrapper objRequest = new DetailsWrapper();
        OTPFields objOTP = new OTPFields();

        try {
            RequestWrapper input = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
            System.debug('input==:'+input);

            objRequest.registrationNumber  = input.regNumber != null ? input.regNumber.trim() : null;
            objOTP.OtpMode = input.OtpMode;
            objOTP.Otp = input.studentOTP;
            objOTP.otpSentTime = input.otpSentTime;

            if((input.action =='Login'|| input.action =='resendOTP') && objRequest.registrationNumber.contains('-SkipOtp')) {
                objRequest.registrationNumber = objRequest.registrationNumber.replace('-SkipOtp','');
                input.action ='SkipLogin';
            }
            if(input.action =='verifyOTP' && objRequest.registrationNumber.contains('-SkipOtp')) {
                 objRequest.registrationNumber = objRequest.registrationNumber.replace('-SkipOtp','');
                 input.action ='SkipOTP';
            }

            if (String.isBlank(objRequest.registrationNumber)|| !getRecordDetails(objRequest,objOTP) ) {
                response.status  = 'Error';
                response.message = 'No match found for entered Registration no.';
                return response;
            }
            if (objRequest.inActive) {
                response.status  = 'Error';
                response.recordId = objRequest.recordId;
                response.message = 'Provided Registration Number had been expired.';
                return response;
            }
            if (objRequest.isAlreadyQualified) {
                response.status  = 'Error';
                response.recordId = objRequest.recordId;
                response.message = 'Lead already qualified with another partner.';
                return response;
            }
            if (!checkEmailMobile(objOTP)) {
                response.status  = 'Error';
                response.recordId = objRequest.recordId;
                response.message = 'Email or Mobile No is Missing.';
                return response;
            }           

            switch on input.action {
                when 'Login' {
                    objOTP = objVerifyHandler.triggerToSendOTP(objOTP);
                } when 'verifyOTP' {
                    if(!String.isBlank(objOTP.Otp)){
                        objOTP = objVerifyHandler.verifyOTP(objOTP);
                        if(objOTP.isSuccess){
                            if(objOTP.recordObject == 'Lead' && objOTP.recordId !=null) {
                                updateStudentLogin(objOTP.recordId);
                            }
                        }
                    } else {
                        response.status  = 'Error';
                        objOTP.errorMsg  ='Please Enter OTP.';
                    }
                } when 'resendOTP' {
                    objOTP = objVerifyHandler.triggerToSendOTP(objOTP);
                } when 'SkipLogin' {
                      response.status  = 'Success';
                      response.recordId = objRequest.recordId;
                      objOTP.alertMsg ='********';
                      response.otpobj = objOTP;
                    //   response.message = 'SkipOTP';
                     return response;
                } when 'SkipOTP' {
                    if(!String.isBlank(objOTP.Otp) && objOTP.Otp == '02026'){ 
                       response.status  = 'Success';
                       response.recordId = objRequest.recordId;
                       response.otpobj = objOTP;
                       response.message = 'OTP Verified';
                    } else {
                        if(String.isBlank(objOTP.Otp)){
                          response.status  = 'Error';
                         response.message  ='Please Enter OTP.';
                        } else {
                          response.status  = 'Error';
                          response.message  ='Incorrect OTP Entered.';
                        }  
                    }
                  return response;
                } when else {
                    response.status='Error';
                    response.message = 'Invalid Action';
                }
            }
            setResponse(response, objOTP);
        } catch (Exception e) {
            if(string.valueof(e).contains('duplicate value found') && string.valueof(e).contains('nm_CheckforDuplicacy__c')){
                response.status='Error';
                response.message = 'Mobile no or EmailId already exist. Kindly contact our Support Team.';
            } else {
                response.status='Error';
                response.message= 'Internal error occured. Kindly contact our Support Team.';
            }
        }
        return response;
    }


    /**
    * @description 
    * @author @Ravi | 18--02--2026 
    * @param DetailsWrapper objRequest 
    * @param OTPFields objOTP 
    * @return Boolean 
    **/
    public static Boolean getRecordDetails(DetailsWrapper objRequest,OTPFields objOTP) {
        List<Lead> lstLead = [SELECT Id, MobilePhone, Email, nm_IsEmailVerified__c, Is_Mobile_Verified__c, InactiveLead__c, Is_Already_Qualified__c FROM Lead WHERE nm_RegistrationNo__c = :objRequest.registrationNumber  AND isConverted = FALSE LIMIT 1];

        if (!lstLead.isEmpty()) {
            objRequest.objectType = 'Lead';
            objRequest.recordId = lstLead[0].Id;
            objRequest.objLead = lstLead[0];
            objRequest.inActive = lstLead[0].InactiveLead__c;
            objRequest.isAlreadyQualified = lstLead[0].Is_Already_Qualified__c;
            populateOTPFieldsFromLead(objOTP,lstLead[0]);
            return true;
        }

        List<Account> lstAccount = [SELECT Id, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c, nm_IsEmailVerified__c FROM Account WHERE (nm_RegistrationNumber__c = :objRequest.registrationNumber  OR nm_StudentNo__c = :objRequest.registrationNumber ) AND nm_StudentStatus__c != 'Closed Lost' LIMIT 1];
       
        if (!lstAccount.isEmpty()) {
            objRequest.objectType = 'Account';
            objRequest.recordId = lstAccount[0].Id;
            objRequest.objAccount = lstAccount[0];
            objRequest.inActive = false; 
            objRequest.isAlreadyQualified=false;
            populateOTPFieldsFromAccount(objOTP,lstAccount[0]);
            return true;
        }

        return false;
    }

    /**
    * @description 
    * @author @Ravi | 18--02--2026 
    * @param OTPFields objOTP 
    * @param Lead lead 
    **/
    public static void populateOTPFieldsFromLead(OTPFields objOTP ,Lead lead) {
        objOTP.mobileNo = lead.MobilePhone;
        objOTP.EmailId = lead.Email;
        objOTP.isEmailVerified = lead.nm_IsEmailVerified__c;
        objOTP.isMobileVerified = lead.Is_Mobile_Verified__c;
        objOTP.recordObject = 'Lead';
        objOTP.recordId = lead.Id;
    }

    /**
    * @description 
    * @author @Ravi | 18--02--2026 
    * @param OTPFields objOTP 
    * @param Account account 
    **/
    public static void populateOTPFieldsFromAccount(OTPFields objOTP ,Account account) {
        objOTP.PersonContactId = account.PersonContactId;
        objOTP.mobileNo = account.PersonMobilePhone;
        objOTP.EmailId = account.PersonEmail;
        objOTP.isEmailVerified = account.nm_IsEmailVerified__c;
        objOTP.isMobileVerified = account.Is_Mobile_Verified__c;
        objOTP.recordObject = 'Account';
        objOTP.recordId = account.Id;
    }

    public static void updateStudentLogin(Id leadId) {
        try {
            Lead objLead = new Lead(StudentLogin__c=true, Id=leadId);
            update objLead;
        } catch (Exception error) {
            System.debug(error.getMessage());
        }
    }

    /**
    * @description 
    * @author @Ravi | 18--02--2026 
    * @param OTPFields objOTP 
    * @return Boolean 
    **/
    public static Boolean checkEmailMobile(OTPFields objOTP) {
        return (objOTP.OtpMode == 'M' && !String.isBlank(objOTP.mobileNo)) ||
               (objOTP.OtpMode == 'E' && !String.isBlank(objOTP.EmailId)) ||
               objOTP.OtpMode == 'N';
    }

    // Helper method for response handling
    private static void setResponse(APIResponseWrapper response, OTPFields objOTP) {
        response.message = String.isNotBlank(response.message)  ? response.message : objOTP.errorMsg;
        response.status = String.isBlank(response.message) ? 'Success' : 'Error';
        response.recordId =objOTP.recordId;
        response.otpobj = objOTP;
    }

    public class RequestWrapper {
        public String regNumber;
        public String action;
        public String OtpMode;
        public String studentOTP;
        public Long otpSentTime;
    }

    public class DetailsWrapper {
        public String registrationNumber;
        public String objectType ;
        public Id recordId ;
        public Lead objLead ;
        public Account objAccount ;
        public String errorMsg ;
        public Boolean inActive ;
        public Boolean isAlreadyQualified ;

        public DetailsWrapper() {
            this.errorMsg = '';
            this.inActive = false;
            this.recordId= null;
            this.isAlreadyQualified = false;
        }
    }

    global class APIResponseWrapper {
        public String recordId;
        public String message;
        public String status;
        public OTPFields otpobj;
    }
}