/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-06-2024
 * @last modified by  : @BK
**/
public class OTPFields {
    public String otpStatus {get;set;}
    public String Otp {get;set;}
    public String resendOtp {get;set;}
    public String LoginType {get;set;}
    public String recordObject {get;set;}
    public String OtpCode {get;set;}
    public Long otpSentTime {get;set;}
    public String mobileNo {get;set;}
    public String EmailId {get;set;}
    public Boolean checkToAllowOTP {get;set;}
    public Boolean skipOTP {get;set;}
    public String OtpMode {get;set;}
    public String PersonContactId {get;set;}
    public String alertMsg {get;set;}
    public Boolean isEmailVerified {get;set;}
    public Boolean isMobileVerified {get;set;}
    public String errorMsg {get;set;}
    public Id recordId {get;set;}
    public Boolean isOTPSent {get;set;}
    public Boolean isSuccess {get;set;}
    public String isModeVerified {get;set;}

    public OTPFields() {
        this.otpStatus = '';
        this.Otp = '';
        this.resendOtp = 'false';
        this.LoginType = 'Lead';
        this.recordObject = 'Lead';
        this.OtpCode = '';
        this.otpSentTime = 0;
        this.mobileNo = null;
        this.EmailId = null;
        this.checkToAllowOTP = false;
        this.skipOTP = false;
        this.OtpMode = 'N';
        this.PersonContactId = '';
        this.alertMsg = '';
        this.isEmailVerified = false;
        this.isMobileVerified = false;
        this.errorMsg = '';
        this.recordId = null;
        this.isOTPSent = false;
        this.isSuccess = false;
        this.isModeVerified = '';
    }
}