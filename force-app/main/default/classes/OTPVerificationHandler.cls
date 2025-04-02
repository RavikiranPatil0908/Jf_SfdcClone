/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28--03--2025
 * @last modified by  : @Ravi
**/
public without sharing class OTPVerificationHandler {

    public OTPFields sendOTP(OTPFields objOTP) {
        try {
            objOTP.errorMsg = '';
            System.debug('OtpMode --> ' + objOTP.OtpMode);
            if (objOTP.OtpMode == 'E') {
                String smsMessage = generateOTPMSG(objOTP);
                sendEmailOTP(objOTP);
                objOTP.otpStatus = 'OTP Sent';
                System.debug('otpStatus-->'+objOTP.otpStatus);
                objOTP.isOTPSent = true;
            } else if(objOTP.OtpMode == 'M' && System.Label.Enable_SMS_Service=='Yes') {
                String smsMessage = generateOTPMSG(objOTP);
                System.debug('smsMessage-->'+smsMessage);
                System.debug('mobile No-->'+objOTP.mobileNo.left(10));
                sendSMS sendSMS = new sendSMS(objOTP.mobileNo.left(10),smsMessage);
                // enqueue the job for processing
                Id jobID = System.enqueueJob(sendSMS);
                System.debug('jobID -->'+jobID);
                
                objOTP.alertMsg = '******'+objOTP.mobileNo.right(4);
                objOTP.otpStatus = 'OTP Sent';
                System.debug('otpStatus-->'+objOTP.otpStatus);
                objOTP.isOTPSent = true;
            } else {
                objOTP.OtpMode = 'N';
                System.debug('otpStatus-->'+objOTP.otpStatus);
                objOTP.isOTPSent = false;
                objOTP.errorMsg = 'Incorrect service selected.';
            }
        } catch (Exception er) {
            System.debug('Error ==>'+er.getMessage());
            System.debug('Error Line No.==>'+er.getLineNumber());
            objOTP.errorMsg = 'OTP couldn\'t be able to send';
        }
        return objOTP;
    } 

    public String generateOTPMSG(OTPFields objOTP) {
        Integer STRING_LENGTH = 5;
        Integer MAX = Integer.valueOf(Math.pow(10,STRING_LENGTH) - 1); // Returns 99999
        objOTP.OtpCode = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
        // objOTP.OtpCode = '111111';
        System.debug('OtpCode-->'+objOTP.OtpCode);
        String smsMessage = objOTP.OtpCode +' is your verification code for NMIMS CDOE.';
        objOTP.otpSentTime = DateTime.now().getTime();
        return smsMessage;
    }

    public OTPFields verifyEmailAndMobile(OTPFields objOTP) {
        try {
            objOTP.isModeVerified = objOTP.OtpMode;
            if((!objOTP.isEmailVerified || !objOTP.isMobileVerified)) {
                System.debug('objOTP.PersonContactId ==>'+objOTP.PersonContactId);
                if(String.isBlank(objOTP.PersonContactId)) {
                    objOTP = updateLead(objOTP);
                } else if(String.isNotBlank(objOTP.PersonContactId)) {
                    objOTP = updateAccount(objOTP);
                }
            }
            objOTP.isSuccess = true;
        } catch (Exception er) {
            System.debug('Error ==>'+er.getMessage());
            System.debug('Error Line No.==>'+er.getLineNumber());
            objOTP.errorMsg = er.getMessage();
        }
        return objOTP;
    }

    public OTPFields updateLead(OTPFields objOTP) {
        Lead objLead = new Lead(id=objOTP.recordId);
        Boolean updateRec = false;
        System.debug('objOTP.OtpMode ==>'+objOTP.OtpMode);
        if(objOTP.OtpMode == 'E' && !objOTP.isEmailVerified) {
            objLead.nm_IsEmailVerified__c = true;
            objOTP.isEmailVerified = true;
            updateRec = true;
            objOTP.OtpMode = '';
            System.debug('objOTP.isEmailVerified ==>'+objOTP.isEmailVerified);
        } else if(objOTP.OtpMode == 'M' && !objOTP.isMobileVerified) {
            objLead.Is_Mobile_Verified__c = true;
            objOTP.isMobileVerified = true;
            updateRec = true;
            objOTP.OtpMode = '';
            System.debug('objOTP.isMobileVerified ==>'+objOTP.isMobileVerified);
        }
        if(updateRec) {
            update objLead;
        }
        return objOTP;
    }

    public OTPFields updateAccount(OTPFields objOTP) {
        Account objAccount = new Account(id=objOTP.recordId);
        Boolean updateRec = false;
        if(objOTP.OtpMode == 'E' && !objOTP.isEmailVerified) {
            objAccount.nm_IsEmailVerified__c = true;
            objOTP.isEmailVerified = true;
            objOTP.OtpMode = '';
            updateRec = true;
        } else if(objOTP.OtpMode == 'M' && !objOTP.isMobileVerified) {
            objAccount.Is_Mobile_Verified__c = true;
            objOTP.isMobileVerified = true;
            objOTP.OtpMode = '';
            updateRec = true;
        }
        if(updateRec) {
            update objAccount;
        }
        return objOTP;
    }

    public OTPFields sendEmailOTP(OTPFields objOTP) {
        try {
            String mailRecordId = '';
            String mailTemplateId = '';
            if(objOTP.recordObject == 'Lead') {
                // To Query the Email Template.
                EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Lead' LIMIT 1];
                Lead objLead = new Lead(id=objOTP.recordId, Email_Verification_Token__c= objOTP.OtpCode);
                update objLead;

                mailRecordId = objOTP.recordId;
                mailTemplateId = emailTemplate.Id;
            } else if(objOTP.recordObject == 'Account') {
                EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Account' LIMIT 1];
                Account objAccount = new Account(id=objOTP.recordId, Email_Verification_Token__c= objOTP.OtpCode);
                update objAccount;

                mailRecordId = objOTP.PersonContactId;
                mailTemplateId = emailTemplate.Id;
            }
            SendEmailForOTP.callEmailAlertFlow(mailRecordId, mailTemplateId);
            String s2 = objOTP.EmailId.substringBefore('@');
            String s1 = '';
            Integer count = s2.length() - 4;
            Integer loopCount = 0;
            while (loopCount < count) {
                s1 = s1 + '*';
                loopCount++;
            }
            s2 = s2.substring(0,2) + s1 + s2.right(2) +'@';
            objOTP.alertMsg = s2 + objOTP.EmailId.substringAfter('@');
        } catch (Exception ex) {
            System.debug('Error Msg =>'+ex.getMessage());
            System.debug('Error No =>'+ex.getLineNumber());
            objOTP.errorMsg = ex.getMessage();
        }
        return objOTP;
    }

    public OTPFields triggerToSendOTP(OTPFields objOTP) {
        objOTP = sendOTP(objOTP);
        if(!objOTP.isOTPSent) {
            objOTP.errorMsg = 'OTP couldn\'t be able to send';
            return objOTP;
        }
        return objOTP;
    }

    public OTPFields verifyOTP(OTPFields objOTP) {
        objOTP.errorMsg = '';
        if(String.isNotBlank(objOTP.Otp)) {
            Long otpEnteredTime = DateTime.now().getTime();
            Long milliseconds = otpEnteredTime - objOTP.otpSentTime;
            Long seconds = milliseconds / 1000;
            if( (System.Label.Environment == 'Sandbox' && (objOTP.Otp== '11111')) || (objOTP.OtpCode == objOTP.Otp && seconds <= 180)){
                objOTP.otpStatus = 'OTP Verified';
                objOTP = verifyEmailAndMobile(objOTP);
                if(!objOTP.isSuccess) {
                    objOTP.errorMsg = 'Something went wrong, Kindly try again later.';
                    return objOTP;
                }
            }else if(objOTP.OtpCode != objOTP.Otp) {
                objOTP.otpStatus = '903';
                objOTP.errorMsg = 'Incorrect OTP Entered, kindly try again.';
            }else if(seconds > 180){
                objOTP.otpStatus = '907';
                objOTP.errorMsg = 'OTP has been expired, kindly try again.';
            }else{
                objOTP.otpStatus = '906';
                objOTP.errorMsg = 'OTP Verification has been failed, kindly try again';
                
            }
        }
        objOTP.Otp = '';
        return objOTP;
    }

    public class sendSMS implements Queueable, Database.AllowsCallouts {

        private String mobileNumber;
        private String mobileNumberVerificationMsg;

        public sendSMS(String mobileNumber,String mobileNumberVerificationMsg) {
            this.mobileNumber = mobileNumber;
            this.mobileNumberVerificationMsg = mobileNumberVerificationMsg;
        }

        public void execute(QueueableContext context) {
            // update Token on object
            String smsResponse = SMSSenderWebService.sendmGageSMS(mobileNumber,mobileNumberVerificationMsg.stripHtmlTags());
            System.debug('smsResponse ==>'+smsResponse);
        }

    }
}