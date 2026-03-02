/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 18-11-2025
 * @last modified by  : @Shailesh
**/
public without sharing class EmailandMobileUpdatePageController {
    public Id recordId;
    public String objectType;
    public String regNo { get; set; }
    public RecordDetails objRecord {get; set;}
    //public Map<String,String> options {get; set;}
    public String selectedOption { get; set; }
    //public String updateFieldvalue { get; set; }  //no use
    public String emailFieldvalue { get; set; }
    public String mobileFieldvalue { get; set; }
    public OTPFields objOTP {get;set;}
    public Boolean otpSendStatus {get;set;}
    public Boolean otpVerifiedStatus {get;set;}
    public String dupMessage {get;set;}

    public EmailandMobileUpdatePageController() {
        objRecord = new RecordDetails();
        //this.setOptions();
        selectedOption = 'none';
        emailFieldvalue = '';
        mobileFieldvalue = '';
        objOTP = new OTPFields();
        otpSendStatus = false;
        otpVerifiedStatus = false;
        dupMessage = '';
    }
     
    public PageReference doUpdatefield(){
        System.debug('selectedOption ::'+selectedOption);
        //System.debug('updateFieldvalue ::'+updateFieldvalue);
        objOTP = new OTPFields();
        Boolean dupflag = false;
           List<Lead> leadLst = [SELECT Id, Name, MobilePhone, Email, nm_RegistrationNo__c,nm_InformationCenter__c,LeadSource FROM Lead WHERE (Email =:emailFieldvalue OR MobilePhone =:mobileFieldvalue) AND IsConverted=false LIMIT 1];
           List<Account> accountLst = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c,PersonLeadSource FROM Account WHERE (PersonEmail =:emailFieldvalue OR PersonMobilePhone =:mobileFieldvalue) and Pass_Out__c = false LIMIT 1];

        if(!leadLst.isEmpty()){
        
            if(leadLst[0].LeadSource == 'Web' ){
                dupMessage = 'Email or Mobile already exist.';
                dupflag = true;
                return null;//error
            } else if(leadLst[0].LeadSource == 'Partner' ){
                if(leadLst[0].nm_InformationCenter__c == objRecord.informationCenter){
                    dupMessage = 'Email or Mobile already exist.';
                    dupflag = true;
                    return null;
                }
            }
        }
         else if (!accountLst.isEmpty()) {

            if(accountLst[0].PersonLeadSource == 'Web' ){
                dupMessage = 'Email or Mobile already exist.';
                dupflag = true;
                return null;//error
                
            } else if(accountLst[0].PersonLeadSource == 'Partner' ){
                if(accountLst[0].nm_Centers__c == objRecord.informationCenter){
                    dupMessage = 'Email or Mobile already exist.';
                    dupflag = true;
                    return null;//error
                }
            }       
        }
        if(dupflag == false){    
            objOTP.recordId = recordId;
            objOTP.isEmailMobileChange =true;
            objOTP.OtpMode = selectedOption == 'Email' ? 'E' : 'M';
            objOTP.EmailId = selectedOption == 'Email' ? emailFieldvalue : objRecord.email;
            objOTP.mobileNo = selectedOption == 'Email' ? objRecord.phone : mobileFieldvalue;
            if (getObjectType() == 'Lead') {
            objOTP.recordObject = 'Lead';
            } 
            else if (getObjectType() == 'Account') {
            objOTP.PersonContactId = objRecord.PersonContactId;
            objOTP.recordObject = 'Account';
            }
            sendOTP();
            dupMessage = '';
            otpSendStatus = true;
        }
       return null;
    }

    public void sendOTP() {
        OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
        objOTP = objVerifyHandler.triggerToSendOTP(objOTP);
        System.debug('isOTPSent ==>'+objOTP.isOTPSent);
    }

    public void verifyOTP() {
        OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
        objOTP = objVerifyHandler.verifyOTP(objOTP);
        System.debug('isSuccess ==>'+objOTP.isSuccess);
        System.debug('errorMsg ==>'+objOTP.errorMsg);
        System.debug('alertMsg ==>'+objOTP.alertMsg);
        otpVerifiedStatus = false;
        if(objOTP.isSuccess) {
            if (getObjectType() == 'Lead') {
            List<Lead> leadLst = [SELECT Id, Name, MobilePhone, Email, nm_RegistrationNo__c,nm_InformationCenter__c FROM Lead WHERE Id = :recordId LIMIT 1];
            if (!leadLst.isEmpty()) {
                if(selectedOption == 'Email' ){
                    leadLst[0].Email = emailFieldvalue.trim();
                } else if(selectedOption == 'Mobile' ){
                    leadLst[0].MobilePhone = mobileFieldvalue.trim();
                }
                update leadLst[0];
                }
            } else if (getObjectType() == 'Account') {
                List<Account> accountLst = [SELECT Id, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c FROM Account WHERE Id = :recordId and (nm_StudentNo__c = '' or nm_StudentNo__c = null)  LIMIT 1];
                if (!accountLst.isEmpty()) {
                    if(selectedOption == 'Email' ){
                    accountLst[0].PersonEmail = emailFieldvalue.trim();
                } else if(selectedOption == 'Mobile' ){
                    accountLst[0].PersonMobilePhone = mobileFieldvalue.trim();
                }
                update accountLst[0];
                }
            }
            if(objOTP.isSuccess == true){
                otpVerifiedStatus = true;
            }
            objOTP = new OTPFields();
            objOTP.OtpCode = '';
            objOTP.Otp = '';
            objOTP.isSuccess = false;
            objOTP.isOTPSent = false;
            objOTP.OtpMode = '';
            objOTP.EmailId = '';
            objOTP.mobileNo = '';
            objOTP.alertMsg = '';
            //objOTP.errorMsg = '';
            //selectedOption = 'none';
            emailFieldvalue = '';
            mobileFieldvalue = '';
            otpSendStatus = false;   
        }
    }

    public Boolean getOtpSendStatus() { 
        return otpSendStatus; 
    }
    
    public String getObjectType() { 
        return objectType; 
    }

   
    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

 
    public Id getRecordId() {
        return recordId;
    }

    public void setRecordId(Id recordId) {
        this.recordId = recordId;
        
        if (getObjectType() == 'Lead') {
            List<Lead> leadLst = [SELECT Id, Name, MobilePhone, Email, nm_RegistrationNo__c,nm_InformationCenter__c FROM Lead WHERE Id = :recordId LIMIT 1];
            if (!leadLst.isEmpty()) {
                regNo = leadLst[0].nm_RegistrationNo__c;
                objRecord.email = leadLst[0].Email;
                objRecord.phone = leadLst[0].MobilePhone;
                objRecord.informationCenter = leadLst[0].nm_InformationCenter__c;
            }
        } else if (getObjectType() == 'Account') {
            List<Account> accountLst = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c FROM Account WHERE Id = :recordId and (nm_StudentNo__c = '' or nm_StudentNo__c = null)  LIMIT 1];
            if (!accountLst.isEmpty()) {
                regNo = accountLst[0].nm_RegistrationNumber__c;
                objRecord.email = accountLst[0].PersonEmail;
                objRecord.phone = accountLst[0].PersonMobilePhone;
                objRecord.informationCenter = accountLst[0].nm_Centers__c;
                objRecord.PersonContactId = accountLst[0].PersonContactId;
            }
        }
    }
    // public void setOptions(){
    //     options = new Map<String,String> {
    //             'Select an Option' => 'none',
    //             'Change Email' => 'Email',
    //             'Change Mobile' => 'Mobile'
    //         };
    // }



    public class RecordDetails {
        public String name {get;set;}
        public String email {get;set;}
        public String phone {get;set;}
        public String informationCenter {get;set;}
        public String PersonContactId {get;set;}
        public String ownerId {get;set;}

        public RecordDetails() {

            this.email = '';
            this.name = '';
            this.phone = '';
            this.informationCenter = '';
            this.ownerId = '';
            this.PersonContactId = '';
        }
    }
}