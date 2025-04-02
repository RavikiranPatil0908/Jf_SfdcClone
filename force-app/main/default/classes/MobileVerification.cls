/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-13-2021   @BK   Initial Version
**/
public without sharing class MobileVerification {

    public String registrationNo {get;set;}
    public String OtpCode {get;set;}
    public Long otpSentTime {get;set;}
    public String Otp {get;set;}
    public String resendOtp {get;set;}
    public String optStatus {get;set;}
    public Lead objLead {get;set;}
    public Account objAccount {get;set;}
    public list<String> lstMsg  { get; set; }
    public String strSecToShow { get; set; }
    public String HeaderMessage  { get; set; }
    public String strBtnURL  { get; set; }
    public String MobileNo {get;set;}
    public String recordType {get;set;}

    public MobileVerification() {
        registrationNo = '';
        OtpCode = '';
        otpSentTime = 0;
        optStatus = '';
        Otp = '';
        resendOtp = 'false';
        objLead = null;
        objAccount = null;
        MobileNo = '';
        recordType = '';
        msgInitialize();
    }

    public void msgInitialize()
    {
        strSecToShow = '';
        HeaderMessage = '';
        strBtnURL='';
        lstMsg = new list<string>();        
    }

    public void sendOTP() {
        msgInitialize();
        Boolean sendOTP = false;
        String PhoneNo = '';
        List<Lead> lstLead = [SELECT id,MobilePhone,nm_RegistrationNo__c,Name,Is_Mobile_Verified__c FROM Lead WHERE nm_RegistrationNo__c=:registrationNo AND IsConverted=false LIMIT 1];
        if(lstLead.size() > 0) {
            objLead = lstLead[0];
            recordType = 'Lead';
        } else {
            List<Account> lstAccount = [SELECT id,PersonMobilePhone,nm_RegistrationNumber__c,Is_Mobile_Verified__c FROM Account WHERE nm_RegistrationNumber__c=:registrationNo AND nm_StudentStatus__c!='Confirmed' LIMIT 1];
            objAccount = lstAccount.size() > 0 ? lstAccount[0] : null;
            recordType = objAccount!=null ? 'Account' : null;
        }   
        
        if(objLead != null) {
            if(objLead.Is_Mobile_Verified__c) {
                MobileNo = 'xxxxxx' + objLead.MobilePhone.right(4);
                setMsg(MobileNo);
                return;
            } else {
                sendOTP = true;
                PhoneNo = objLead.MobilePhone;
            }
        } else if(objAccount != null) {
            if(objAccount.Is_Mobile_Verified__c) {
                MobileNo = 'xxxxxx' + objAccount.PersonMobilePhone.right(4);
                setMsg(MobileNo);
                return;
            } else {
                PhoneNo = objAccount.PersonMobilePhone;
                sendOTP = true;
            }
        } else {
            strSecToShow = 'msg';
            HeaderMessage = 'Important Message';
            strBtnURL = '';
            lstMsg.add('Invalid Registration Number');
            return;
        }

        if(sendOTP) {
            triggerOTP(PhoneNo.left(10));
        }
    }

    public void setMsg(String mobileNo) {
        strSecToShow = 'msg';
        HeaderMessage = 'Important Message';
        strBtnURL = 'http://distance.nmims.edu';
        lstMsg.add('Mobile Number '+mobileNo+' is Verified');
    }

    public void triggerOTP(String mobileNo) {
        System.debug('mobileNo ==>'+mobileNo);
        if(System.Label.Enable_SMS_Service=='Yes'){
            String result = SMSSenderWebService.sendmGageSMS(mobileNo,generateOTPMSG());
            System.debug('result ==>'+result);
        }
        // if(String.isNotBlank(result) && result.containsIgnoreCase('Statuscode=200')) {
            optStatus = 'OTP Sent';
            System.debug('gupshupStatus-->'+optStatus);
        // }
    }

    public void VerifyOTP() {
        if(String.isNotBlank(Otp)) {
            Long otpEnteredTime = DateTime.now().getTime();
            Long milliseconds = otpEnteredTime - otpSentTime;
            Long seconds = milliseconds / 1000;
            if(OtpCode == Otp && seconds <= 120){
                optStatus = 'OTP Verified';
                msgInitialize();
                Boolean updateMsg = verifyMobile();
                if(updateMsg) {
                    setMsg(MobileNo);
                } else {
                    strSecToShow = 'msg';
                    HeaderMessage = 'Important Message';
                    strBtnURL = '';
                    lstMsg.add('Internal Error Occured, Kindly contact AEP');
                    return;
                }
            }else if(OtpCode != Otp) {
                optStatus = '903';
            }else if(seconds > 90){
                optStatus = '907';
            }else{
                optStatus = '906';
            }
        }
    }

    public Boolean verifyMobile() {
        try {
            if(recordType=='Lead') {
                objLead.Is_Mobile_Verified__c = true;
                update objLead;
            } else if(recordType=='Account') {
                objAccount.Is_Mobile_Verified__c = true;
                update objAccount;
            }
        } catch (Exception e) {
            System.debug('Error msg'+ e.getMessage());
            return false;
        }
        return true;
    }

    public String generateOTPMSG() {
        Integer STRING_LENGTH = 5;
        Integer MAX = Integer.valueOf(Math.pow(10,STRING_LENGTH) - 1); // Returns 99999
        OtpCode = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
        System.debug('OtpCode-->'+OtpCode);
        String smsMessage = OtpCode +' is your verification code for NMIMS CDOE.';
        otpSentTime = DateTime.now().getTime();
        System.debug(smsMessage);
        return smsMessage;
    }
}