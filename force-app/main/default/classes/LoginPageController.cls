/**
 * @description       : Controller for handling login and OTP verification logic
 * @author            : @BK
 * @group             : 
 * @last modified on  : 22-08-2024
 * @last modified by  : @BK
**/
public without sharing class LoginPageController {

    public RequestWrapper objRequest { get; set; }
    public OTPFields objOTP { get; set; }
    public String urlGenerate { get; set; }

    public LoginPageController() {
        initializeController();
    }

    private void initializeController() {
        objRequest = new RequestWrapper();
        objOTP = new OTPFields();
        handleNavigationParameters();
        configureOTPSettings();
    }

    private void handleNavigationParameters() {
        String navigationParam = ApexPages.currentPage().getParameters().get('nav');
        urlGenerate = String.isNotBlank(navigationParam) ? '?nav=' + navigationParam.escapeHtml4() : '';
    }

    private void configureOTPSettings() {
        objOTP.skipOTP = String.isNotBlank(ApexPages.currentPage().getParameters().get('skipOTP')) 
                            ? Boolean.valueOf(ApexPages.currentPage().getParameters().get('skipOTP'))
                            : false;
        if(!Test.isRunningTest()) {
            objOTP.checkToAllowOTP = String.isNotBlank(System.label.AllowOTP) && Boolean.valueOf(System.label.AllowOTP) && !objOTP.skipOTP;
        } else {
            objOTP.checkToAllowOTP = !objOTP.skipOTP;
        }
    }

    /**
    * @description Handles submission of login form.
    * @author @BK | 25-07-2024 
    * @return PageReference to navigate based on login success or failure. 
    **/
    public PageReference submitLogin() {
        objRequest.errorMsg = '';

        if (String.isBlank(objRequest.registrationNumber) || !getRecordDetails()) {
            objRequest.errorMsg = 'No match found for entered Registration no.';
            return null;
        }

        if(objRequest.inActive) {
            objRequest.errorMsg = 'Provided Registration Number had been expired.';
            return null;
        }

        if(objRequest.isAlreadyQualified) {
            objRequest.errorMsg = 'Lead already qualified with another partner.';
            return null;
        }

        if (!checkEmailMobile()) {
            objRequest.errorMsg = 'Email or Mobile No is Missing.';
            return null;
        }

        if (objOTP.checkToAllowOTP) {
            if (objOTP.otpStatus == 'OTP Verified') {
                objRequest.errorMsg = 'OTP Already Verified';
                return null;
            }

            if (!sendOTP()) {
                objRequest.errorMsg = 'OTP couldn\'t be sent';
                return null;
            }

            return null;
        }

        return skipOTP();
    }

    /**
    * @description Retrieves details of the record based on registration number.
    * @author @BK | 25-07-2024 
    * @return Boolean indicating if record details were successfully retrieved. 
    **/
    public Boolean getRecordDetails() {
        objRequest.registrationNumber = objRequest.registrationNumber.trim();

        List<Lead> lstLead = [SELECT Id, MobilePhone, Email, nm_IsEmailVerified__c, Is_Mobile_Verified__c, InactiveLead__c, Is_Already_Qualified__c 
                              FROM Lead 
                              WHERE nm_RegistrationNo__c = :objRequest.registrationNumber AND isConverted = FALSE 
                              LIMIT 1];

        if (!lstLead.isEmpty()) {
            objRequest.objectType = 'Lead';
            objRequest.recordId = lstLead[0].Id;
            objRequest.objLead = lstLead[0];
            objRequest.inActive = lstLead[0].InactiveLead__c;
            objRequest.isAlreadyQualified = lstLead[0].Is_Already_Qualified__c;
            populateOTPFieldsFromLead(lstLead[0]);
            return true;
        }

        List<Account> lstAccount = [SELECT Id, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c, nm_IsEmailVerified__c 
                                    FROM Account 
                                    WHERE nm_RegistrationNumber__c = :objRequest.registrationNumber AND nm_StudentStatus__c != 'Closed Lost' 
                                    LIMIT 1];

        if (!lstAccount.isEmpty()) {
            objRequest.objectType = 'Account';
            objRequest.recordId = lstAccount[0].Id;
            objRequest.objAccount = lstAccount[0];
            populateOTPFieldsFromAccount(lstAccount[0]);
            return true;
        }

        return false;
    }

    private void populateOTPFieldsFromLead(Lead lead) {
        objOTP.mobileNo = lead.MobilePhone;
        objOTP.EmailId = lead.Email;
        objOTP.isEmailVerified = lead.nm_IsEmailVerified__c;
        objOTP.isMobileVerified = lead.Is_Mobile_Verified__c;
        objOTP.recordObject = 'Lead';
        objOTP.recordId = lead.Id;
    }

    private void populateOTPFieldsFromAccount(Account account) {
        objOTP.PersonContactId = account.PersonContactId;
        objOTP.mobileNo = account.PersonMobilePhone;
        objOTP.EmailId = account.PersonEmail;
        objOTP.isEmailVerified = account.nm_IsEmailVerified__c;
        objOTP.isMobileVerified = account.Is_Mobile_Verified__c;
        objOTP.recordObject = 'Account';
        objOTP.recordId = account.Id;
    }

    /**
    * @description Checks if both email and mobile are present based on OTP mode.
    * @author @BK | 25-07-2024 
    * @return Boolean indicating if both email and mobile are present as required. 
    **/
    public Boolean checkEmailMobile() {
        return (objOTP.OtpMode == 'M' && !String.isBlank(objOTP.mobileNo)) ||
               (objOTP.OtpMode == 'E' && !String.isBlank(objOTP.EmailId)) ||
               objOTP.OtpMode == 'N';
    }

    /**
    * @description Sends OTP based on OTP mode.
    * @author @BK | 25-07-2024 
    * @return Boolean indicating if OTP was successfully sent. 
    **/
    public Boolean sendOTP() {
        OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
        objOTP = objVerifyHandler.triggerToSendOTP(objOTP);
        return objOTP.isOTPSent;
    }

    /**
    * @description OTP and redirects if successful.
    * @author @BK | 25-07-2024 
    * @return PageReference based on OTP verification success or failure. 
    **/
    public PageReference verifyOTP() {
        objRequest.errorMsg = '';
        OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
        objOTP = objVerifyHandler.verifyOTP(objOTP);

        if (objOTP.isSuccess) {
            SessionManager objSession = new SessionManager();
            Boolean isSuccess = objSession.loginSuccessFull(objRequest.recordId, objRequest.objectType, null);

            if (!isSuccess) {
                objRequest.errorMsg = 'Something went wrong, Kindly try again later.';
                return null;
            }

            if(objRequest.objectType == 'Lead' && objRequest.recordId!=null) {
                updateStudentLogin(objRequest.recordId);
            }

            return new PageReference('/apex/EnrollmentForm' + urlGenerate).setRedirect(true);
        } else {
            objRequest.errorMsg = objOTP.errorMsg;
        }

        return null;
    }

    /**
    * @description Skips OTP verification and initiates session login.
    * @author @BK | 25-07-2024 
    * @return PageReference to navigate to enrollment form. 
    **/
    public PageReference skipOTP() {
        objRequest.errorMsg = '';
        SessionManager objSession = new SessionManager();
        Boolean isSuccess = objSession.loginSuccessFull(objRequest.recordId, objRequest.objectType, null);

        if (!isSuccess) {
            objRequest.errorMsg = 'Something went wrong, Kindly try again later.';
            return null;
        }

        if(objRequest.objectType == 'Lead' && objRequest.recordId!=null) {
            updateStudentLogin(objRequest.recordId);
        }

        return new PageReference('/apex/EnrollmentForm' + urlGenerate).setRedirect(true);
    }

    /**
    * @description Re-sends OTP if it couldn't be sent previously.
    * @author @BK | 25-07-2024 
    * @return PageReference based on OTP re-send success or failure. 
    **/
    public PageReference reSendOTP() {
        if (!sendOTP()) {
            objRequest.errorMsg = 'OTP couldn\'t be sent';
        }
        return null;
    }

    /**
    * @description To update student Login
    * @author @BK | 21-08-2024 
    * @param Id leadId 
    **/
    public void updateStudentLogin(Id leadId) {
        try {
            Lead objLead = new Lead(StudentLogin__c=true, Id=leadId);
            update objLead;
        } catch (Exception error) {
            System.debug(error.getMessage());
        }
    }

    /**
    * @description Validates if a session is available and verified.
    * @author @BK | 25-07-2024 
    * @return PageReference to navigate based on session verification. 
    **/
    public PageReference validateSession() {
        SessionManager obj = new SessionManager();
        SessionUser objSessionUser = obj.isSessionAvailable();

        if (objSessionUser.isVerified) {
            return new PageReference('/apex/EnrollmentForm' + urlGenerate).setRedirect(true);
        }

        return null;
    }

    /**
     * Wrapper class to hold request details and error messages.
     **/
    public class RequestWrapper {
        public String registrationNumber { get; set; }
        public String objectType { get; set; }
        public Id recordId { get; set; }
        public Lead objLead { get; set; }
        public Account objAccount { get; set; }
        public String errorMsg { get; set; }
        public Boolean inActive { get; set; }
        public Boolean isAlreadyQualified { get; set; }

        public RequestWrapper() {
            this.errorMsg = '';
            this.inActive = false;
            this.isAlreadyQualified = false;
        }
    }
}