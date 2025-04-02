/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : @vickysahu
**/
public without sharing class DashboardPageController {

    public Id objectId;
    public String objectType;
    public RecordDetails objRecord {get; set;}
    public OTPFields objOTP {get;set;}
    public Boolean isDataFetched {get;set;}
    public Request objDEBRequest {get;set;}

    public DashboardPageController() {
        objRecord = new RecordDetails();
        objOTP = new OTPFields();
        isDataFetched = false;
        objDEBRequest = new Request();
    }

    public Id getObjectId() {
		return this.objectId;
	}

    public void setObjectId(Id objectId) {
        system.debug('setObjectId --> ' );
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId)) {
            queryRecordData(this.objectId);
            isDataFetched = true;
        }
	}

    public String getObjectType() {
        return this.objectType;
    }
    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    private void queryRecordData(Id recordId) {
        objOTP.recordId = recordId;
        if (this.objectType == 'Account') {
            List<Account> lstAccount = [SELECT id,is_Video_Call_Verified__c,nm_DateOfBirth__c,nm_Nationality__c,nm_StudentStatus__c,Name,PersonMobilePhone,nm_Program__r.Bachelor_Specialization__c,nm_Program__r.nm_ProgramName__c,PersonEmail,PersonContactId,Is_Mobile_Verified__c,nm_IsEmailVerified__c,City_Shipping_Account__c,nm_Program__r.Form_Specialisation__c,nm_RegistrationNumber__c,nm_ProgramType__c,Program_Name__c,OwnerId FROM Account WHERE id=:recordId LIMIT 1];
            objRecord.name = lstAccount[0].Name;
            objRecord.email = lstAccount[0].PersonEmail;
            objRecord.phone = lstAccount[0].PersonMobilePhone;
            objRecord.city = lstAccount[0].City_Shipping_Account__c;
            objRecord.registrationId = lstAccount[0].nm_RegistrationNumber__c;
            objRecord.dob = lstAccount[0].nm_DateOfBirth__c;
            objRecord.programCategory = lstAccount[0].nm_ProgramType__c;
            objRecord.programName = lstAccount[0].nm_Program__r.Bachelor_Specialization__c != null ? lstAccount[0].nm_Program__r.Bachelor_Specialization__c : lstAccount[0].nm_Program__r.nm_ProgramName__c;
            // objRecord.bechelorSpecilization =lstAccount[0].nm_Program__r.Bachelor_Specialization__c;
            objRecord.specialization = lstAccount[0].nm_Program__r.Form_Specialisation__c;
            // objRecord.nmProgramName = lstAccount[0].nm_Program__r.nm_ProgramName__c;
            objRecord.isEmailVerified = lstAccount[0].nm_IsEmailVerified__c;
            objRecord.isMobileVerified = lstAccount[0].Is_Mobile_Verified__c;
            objRecord.isVideoCallVerified = lstAccount[0].is_Video_Call_Verified__c;
            objRecord.ownerId = lstAccount[0].OwnerId;
            // OTP
            objOTP.isEmailVerified = lstAccount[0].nm_IsEmailVerified__c;
            objOTP.isMobileVerified = lstAccount[0].Is_Mobile_Verified__c;
            objOTP.PersonContactId = lstAccount[0].PersonContactId;
            objOTP.EmailId = lstAccount[0].PersonEmail;
            objOTP.mobileNo = lstAccount[0].PersonMobilePhone;
            objOTP.recordObject = 'Account';
            objRecord.isDebVerificationPending = checkDEBVerified(recordId) 
                                                ? true 
                                                : (lstAccount[0].nm_Nationality__c != 'Indian' ? true : false);
            getStatus(null,lstAccount[0]);

        } else if (this.objectType == 'Lead') {
            List<Lead> lstLead = [SELECT id,Name,MobilePhone,Email,Status,nm_DateOfBirth__c,nm_IsEmailVerified__c,Is_Mobile_Verified__c,nm_Program__r.Bachelor_Specialization__c,nm_Program__r.nm_ProgramName__c,nm_RegistrationNo__c,nm_City_P__c,nm_Program__r.Form_Specialisation__c,nm_ChooseaProgram__c,nm_ProgramName__c,Student_Number_Lateral__c,Year_Of_Passing_Lateral__c FROM Lead WHERE id=:recordId LIMIT 1];
            objRecord.name = lstLead[0].Name;
            objRecord.email = lstLead[0].Email;
            objRecord.phone = lstLead[0].MobilePhone;
            objRecord.city = lstLead[0].nm_City_P__c;
            objRecord.registrationId = lstLead[0].nm_RegistrationNo__c;
            objRecord.dob = lstLead[0].nm_DateOfBirth__c;
            objRecord.programCategory = lstLead[0].nm_ChooseaProgram__c;
            objRecord.programName = lstLead[0].nm_Program__r.Bachelor_Specialization__c != null ? lstLead[0].nm_Program__r.Bachelor_Specialization__c : lstLead[0].nm_Program__r.nm_ProgramName__c;
            // objRecord.bechelorSpecilization =lstLead[0].nm_Program__r.Bachelor_Specialization__c;
            // objRecord.nmProgramName = lstLead[0].nm_Program__r.nm_ProgramName__c;
            objRecord.specialization = lstLead[0].nm_Program__r.Form_Specialisation__c;
            objRecord.isEmailVerified = lstLead[0].nm_IsEmailVerified__c;
            objRecord.isMobileVerified = lstLead[0].Is_Mobile_Verified__c;
            objRecord.isLateral = String.isNotBlank(lstLead[0].Student_Number_Lateral__c) ? true : false;
            objRecord.oldStudentNo = lstLead[0].Student_Number_Lateral__c;
            objRecord.isLateralVerified = String.isNotBlank(lstLead[0].Year_Of_Passing_Lateral__c) ? true : false;
            // OTP
            objOTP.isEmailVerified = lstLead[0].nm_IsEmailVerified__c;
            objOTP.isMobileVerified = lstLead[0].Is_Mobile_Verified__c;
            objOTP.EmailId = lstLead[0].Email;
            objOTP.mobileNo = lstLead[0].MobilePhone;
            objOTP.recordObject = 'Lead';
            getStatus(lstLead[0],null);
        }
        System.debug(objRecord);
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
        if(objOTP.isSuccess) {
            queryRecordData(objOTP.recordId);
        }
    }

    private void getStatus(Lead objLead, Account objAccount) {
        if(objAccount != null) {
            if(objAccount.nm_StudentStatus__c == 'Confirmed') {
                for (String mapKey : objRecord.mapOfActionVsStatus.keySet()) {
                    objRecord.mapOfActionVsStatus.put(mapKey,true);
                }
            } else {
                List<Opportunity> lstOpps = [SELECT id,StageName FROM Opportunity WHERE AccountId=:objAccount.Id AND Is_Re_Registration_Payment__c=false ORDER BY nm_Semester__c ASC LIMIT 1];
                if(lstOpps.size() > 0 && lstOpps[0].StageName == 'Payment made' || lstOpps[0].StageName == 'Closed') {
                    objRecord.mapOfActionVsStatus.put('Tuition Fee Paid',true);
                }
                objRecord.mapOfActionVsStatus.put('Registration Form Filled',true);
                objRecord.mapOfActionVsStatus.put('Initial Fee Paid',true);
                objRecord.mapOfActionVsStatus.put('Video Call Verified',objRecord.isVideoCallVerified);

                if(objAccount.nm_StudentStatus__c == 'Admission form & documents Approved' 
                    || objAccount.nm_StudentStatus__c == 'Admission Form & Documents Provisional') {
                    objRecord.mapOfActionVsStatus.put('Documents Submitted',true);
                    objRecord.mapOfActionVsStatus.put('Documents Verified',true);
                }
    
                if(objAccount.nm_StudentStatus__c == 'Documents Re-submitted' 
                    || objAccount.nm_StudentStatus__c == 'Admission form & documents submitted') {
                    objRecord.mapOfActionVsStatus.put('Documents Submitted',true);
                }

                if(objAccount.nm_StudentStatus__c == 'Document approval pending, awaiting registration payment') {
                    objRecord.mapOfActionVsStatus.put('Initial Fee Paid',false);
                    objRecord.mapOfActionVsStatus.put('Documents Submitted',true);
                }
                
            }
        } else {
            if(objLead.Status == 'Registration Form Filled') {
                objRecord.mapOfActionVsStatus.put('Registration Form Filled',true);
            }

            if(objLead.Status == 'Registration Fee Paid') {
                objRecord.mapOfActionVsStatus.put('Registration Form Filled',true);
                objRecord.mapOfActionVsStatus.put('Initial Fee Paid',true);
            }

            if(objLead.Status == 'Admission Fee Paid') {
                objRecord.mapOfActionVsStatus.put('Registration Form Filled',true);
                objRecord.mapOfActionVsStatus.put('Initial Fee Paid',true);
                objRecord.mapOfActionVsStatus.put('Tuition Fee Paid',true);
            }
        }
    }

    /**
    * @description 
    * @author @BK | 09-16-2024 
    **/
    public void verifyDEBID() {
        DEBVerificationHandler.Request objRequest = new DEBVerificationHandler.Request();
        objRequest.recordId = getObjectId();
        objRequest.objType = getObjectType();
        objRequest.debId = objDEBRequest.debId;
        objRequest.dob = objRecord.dob;
        objRequest.ownerId = objRecord.ownerId;

        DEBVerificationHandler.Response objResponse = DEBVerificationHandler.verifyDEBID(objRequest);
        System.debug('isSuccess ==>'+objResponse.isSuccess);
        objDEBRequest.errorMsg = 'error';
        if(objResponse.isSuccess) {
            if(!objResponse.isDEBMatched) {
                objDEBRequest.errorMsg = 'mismatch-deb';
                return;
            }

            if(!objResponse.isDOBMatched) {
                objDEBRequest.errorMsg = 'mismatch-dob';
                return;
            }

            
            objDEBRequest.errorMsg = 'success';
            objRecord.isDebVerificationPending = false;
            if(objRequest.objType == 'Account') {
                Account objAccount = new Account(id=objRequest.recordId,DEBID__c=objDEBRequest.debId,is_Deb_verified__c=true);
                update objAccount;
            } else {
                Lead objLead = new Lead(id=objRequest.recordId,DEBID__c=objDEBRequest.debId);
                update objLead;
            }
        }
        System.debug('status--->' + objRecord.isDebVerificationPending);
    }

    /**
    * @description 
    * @author @BK | 09-16-2024 
    * @param recordId 
    * @return Boolean 
    **/
    private Boolean checkDEBVerified(Id recordId) {
        String subQuery = getObjectType() == 'Lead' ? 'Lead__c=:objRequest.recordId' : 'Account__c=:objRequest.recordId';
        String debQuery = DynamicQueryBuilder.getQueryAllFieldSql('DEB_Detail__c', 'Is_Active__c=true AND '+subQuery+' ORDER BY CreatedDate DESC', '');
        List<DEB_Detail__c> lstDebUpdate = DataBase.query(debQuery);
        if(lstDebUpdate.isEmpty()) {
            return true;
        }
        return false;
    }

    public PageReference validateSession() {
        HomePageController objHome = new HomePageController();
        return objHome.validateSession();
    }

    public class RecordDetails {
        public String name {get;set;}
        public String email {get;set;}
        public String phone {get;set;}
        public String city {get;set;}
        public String registrationId {get;set;}
        public String programCategory {get;set;}
        public String programName {get;set;}
        // public String bechelorSpecilization {get;set;}
        // public String nmProgramName {get;set;}
        public String specialization {get;set;}
        public Boolean isEmailVerified {get;set;}
        public Boolean isMobileVerified {get;set;}
        public Boolean isLateral {get;set;}
        public String oldStudentNo {get;set;}
        public Boolean isLateralVerified {get;set;}
        public String currentStage {get;set;}
        public Boolean isVideoCallVerified {get;set;}
        public Map<String,Boolean> mapOfActionVsStatus {get;set;}
        public list<String> lstOfActions {get;set;}
        public Boolean isDebVerificationPending {get;set;}
        public Date dob {get;set;}
        public String ownerId {get;set;}

        public RecordDetails() {
            this.isVideoCallVerified = false;
            this.isDebVerificationPending = false;
            this.dob = null;
            this.mapOfActionVsStatus = new Map<String,Boolean> {
                'Interested' => true,
                'Registration Form Filled' => false,
                'Initial Fee Paid' => false,
                'Documents Submitted' => false,
                'Documents Verified' => false,
                'Tuition Fee Paid' => false,
                'Video Call Verified' => false,
                'Confirmed' => false
            };
            this.lstOfActions = new List<String> {
                'Interested',
                'Registration Form Filled',
                'Initial Fee Paid',
                'Documents Submitted',
                'Documents Verified',
                'Tuition Fee Paid',
                'Video Call Verified',
                'Confirmed'
            };
        }
    }

    public class Request {
        public Request() {
            this.debId = '';
            this.errorMsg = '';
        }

        public String debId {get;set;}
        public String errorMsg {get;set;}
    }
    
}