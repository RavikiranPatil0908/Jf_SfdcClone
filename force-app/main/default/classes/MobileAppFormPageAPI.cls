/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 05--09--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   08--08--2025   @Ravi   Initial Version
**/
@RestResource(urlMapping='/api/FetchLeadAccountDetails/*')
global without sharing class MobileAppFormPageAPI {
    
    public static Boolean inActive =false;
    public static Boolean isAlreadyQualified=false;
    
    /**
    * @description  GET endpoint to fetch form data
    * @author @Ravi
    **/
    @HttpGet
    global static void fetchRecordData() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        
        try {
            res.addHeader('Content-Type', 'application/json;charset=UTF-8');
            String registrationNumber = req.params.get('registrationNumber').trim();
            if (String.isBlank(registrationNumber)) {
              
                res.responseBody = Blob.valueOf(JSON.serialize(
                    new BaseResponse('Error', 'Registration number is required.', null)
                ));
                return;
            }
            // Get object type and record ID
             Map<String, String> recordInfo = getRecordDetails(registrationNumber);
            if (recordInfo.isEmpty()) {
                res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Error', 'No match found for entered Registration no.', null)));
                return;
            }
            if (inActive) {
                res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Error', 'Provided Registration Number had been expired.', null)));
                return;
            }
            if (isAlreadyQualified) {
                res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Error', 'Lead already qualified with another partner.', null)));
                return;
            }
            FormPageController controller = new FormPageController();
            if (recordInfo.get('objectType') == 'Lead') {
                controller.setLeadId(recordInfo.get('recordId'));
            } else {
                controller.setAccountId(recordInfo.get('recordId'));
            }
            // Prepare response
            LeadData responseData = new LeadData();
            responseData.leadId = controller.getLeadId();
            responseData.accountId = controller.getAccountId();
            responseData.objLead = controller.objLead;
            responseData.objAccount = controller.objAccount;
            responseData.lstWorkExperience = convertWorkExpToApi(controller.lstWorkExperience);
            responseData.isLateral = controller.isLateral;
            responseData.isVerified = controller.isVerified;
            responseData.copyPermanantAddressFromTo = controller.copyPermanantAddressFromTo;
            responseData.isRecordQueried = controller.isRecordQueried;
            responseData.studentNumber = controller.studentNumber;
            responseData.yearsEligibility = controller.yearsEligibility;
            responseData.errorMsg = controller.errorMsg;
            responseData.lateralMessage = controller.lateralMessage;
            responseData.lateraleditablefields =controller.lateraleditablefields;
    
            System.debug('controller.debDetailObject==>'+controller.debDetailObject);
            if (controller.debDetailObject != null) {
                responseData.debDetailObject = (DEBDetails)JSON.deserialize(
                    JSON.serialize(controller.debDetailObject),
                    DEBDetails.class
                );
            }
            res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Success', 'Student record fetched successfully.', responseData)
            ));
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse('Error', 'Error while fetching data: ' + e.getMessage(), null) ));
        }
    }

    /**
    * @description 
    * @author @Ravi | 05--09--2025 
    **/
    @HttpPost
    global static void updateRecordetails() {
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        resp.addHeader('Content-Type', 'application/json;charset=UTF-8');
        
        String requestBody = req.requestBody != null ? req.requestBody.toString() : '';
        Id recordId;
        try {
            Lead leadRecord = (Lead) JSON.deserialize(requestBody, Lead.class);
            recordId = leadRecord.Id;
            
            // Record Id validation
            if (String.isBlank(recordId)) {
                sendResponse('Error', 'Record Id is required.', null);
                return;
            }
            // Duplicate check
            String dupCheck = isDuplicateAccountExist(leadRecord);
            if (dupCheck == 'Duplicate') {
                sendResponse('Error', 'Duplicate record found, kindly contact our Support Team.', null);
                return;
            }
            // Update Lead
            leadRecord.Partial_form_filled__c = true;
            leadRecord.StudentLogin__c = false;
            update leadRecord;
            sendResponse('Success', 'Lead updated successfully.', leadRecord.Id);

        } catch (Exception ex) {
            String errorMsg = ex.getMessage();
            if (String.valueOf(ex).contains('duplicate value found') && String.valueOf(ex).contains('nm_CheckforDuplicacy__c')) {
                errorMsg = 'Mobile number or Email Id already exists. Please enter a valid Mobile number or Email Id.';
            }
            APIRequestHandler.insertAPIRequest(requestBody, errorMsg, 'LeadUpdateMobileAPI', false, recordId, 'Lead', 'Update');
            sendResponse('Error', errorMsg, null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 05--09--2025 
    * @param Lead leadRecord 
    * @return String 
    **/
    private static String isDuplicateAccountExist(Lead leadRecord) {
        if (leadRecord == null) return 'Non-Duplicate';
        List<Account> lstAccount;
        if ('Certificate Programs'.equalsIgnoreCase(leadRecord.nm_ChooseaProgram__c)) {
            lstAccount = [SELECT Id FROM Account WHERE (PersonEmail = :leadRecord.Email OR PersonMobilePhone = :leadRecord.MobilePhone) AND nm_ChooseaProgram__c = :leadRecord.nm_ChooseaProgram__c AND Pass_Out__c = false AND Active_account__c = true LIMIT 1];
        } else {
            lstAccount = [SELECT Id FROM Account WHERE (PersonEmail = :leadRecord.Email OR PersonMobilePhone = :leadRecord.MobilePhone) AND nm_ChooseaProgram__c != 'Certificate Programs' AND Pass_Out__c = false AND Active_account__c = true LIMIT 1];
        }
        return lstAccount.isEmpty() ? 'Non-Duplicate' : 'Duplicate';
    } 

    /**
    * @description 
    * @author @Ravi | 13--08--2025 
    * @param String registrationNumber 
    * @return Map<String, String> 
    **/
    private static Map<String, String> getRecordDetails(String registrationNumber) {
        Map<String, String> result = new Map<String, String>();
        List<Lead> lstLead = [SELECT Id, MobilePhone, Email, nm_IsEmailVerified__c,Program_Type__c,nm_Session__c,nm_Year__c,nm_ChooseaProgram__c, Is_Mobile_Verified__c, InactiveLead__c, Is_Already_Qualified__c FROM Lead WHERE nm_RegistrationNo__c = :registrationNumber AND isConverted = FALSE LIMIT 1];
        System.debug('lead====> '+lstLead);
        if (!lstLead.isEmpty()) {
            result.put('objectType', 'Lead');
            result.put('recordId', lstLead[0].Id);
            Lead objLead = lstLead[0];
            detailsWrapper objWrapper = new detailsWrapper();
            objWrapper.chooseProgram = objLead.nm_ChooseaProgram__c;
            objWrapper.programType = objLead.Program_Type__c;
            objWrapper.session = objLead.nm_Session__c;
            objWrapper.year = objLead.nm_Year__c.intValue();
            objWrapper.isValid = setValid(objWrapper);
            if(!objWrapper.isValid) {
                update objLead;
            }
            inActive = lstLead[0].InactiveLead__c;
            isAlreadyQualified = lstLead[0].Is_Already_Qualified__c;
            return result; 
        }

        List<Account> lstAccount = [SELECT Id, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c, nm_IsEmailVerified__c FROM Account WHERE (nm_RegistrationNumber__c =:registrationNumber OR nm_StudentNo__c = :registrationNumber) AND nm_StudentStatus__c != 'Closed Lost' LIMIT 1];
        if (!lstAccount.isEmpty()) {
            result.put('objectType', 'Account');
            result.put('recordId', lstAccount[0].Id);
        }
        return result;
    }

    public static Boolean setValid(detailsWrapper objWrapper) {
        List<Calender__c> lstCalender = getActiveCalender(objWrapper.chooseProgram,objWrapper.programType);
        if (lstCalender.size() > 0) { 
            return String.isNotBlank(objWrapper.session) && objWrapper.year!=null && objWrapper.session == lstCalender[0].Session__c && objWrapper.year == lstCalender[0].Year__c ? true : false;
        }
        return false;
    }

    public static List<Calender__c> getActiveCalender(String program,String specialization) {
        List<Calender__c> lstCalender = [SELECT Id, Year__c, Specialisation__c, Session_End_Date__c, Session__c, Category__c, Session_Start_Date__c FROM Calender__c WHERE Category__c='Admission' AND nm_Type__c=:program AND Specialisation__c=:specialization AND Session_Start_Date__c <= Today AND Session_End_Date__c >= Today LIMIT 1];
        return lstCalender;
    }

    // POST endpoint to save form data
    // @HttpPost
    // global static String saveFormData() {
    //     try {
    //         RestRequest req = RestContext.request;
    //         LeadData formData = (LeadData)JSON.deserialize(req.requestBody.toString(), LeadData.class);
            
    //         FormPageController controller = new FormPageController();
            
    //         // Set record ID
    //         if(formData.leadId != null) {
    //             controller.setLeadId(formData.leadId);
    //         } else if(formData.accountId != null) {
    //             controller.setAccountId(formData.accountId);
    //         }
            
    //         // Update lead/account data
    //         if(formData.objLead != null) {
    //             controller.objLead = formData.objLead;
    //         }
            
    //         // Handle work experience
    //         if(formData.lstWorkExperience != null) {
    //             controller.lstWorkExperience = convertWorkExperienceList(formData.lstWorkExperience);
    //         }
            
    //         // Handle other operations based on request parameters
    //         if(formData.sectionName == 'nextPage') {
    //             controller.nextPage();
    //         } else if(formData.sectionName == 'confirmation') {
    //             controller.goToConfirmationForm();
    //         } else if(formData.sectionName == 'verifyDEB') {
    //             controller.verifyDEBID();
    //         } else if(formData.sectionName == 'updateAddress') {
    //             controller.postalCode = formData.postalCode;
    //             controller.updateAddressDetails();
    //         } else if(formData.sectionName == 'lateralOTP') {
    //             controller.studentNumber = formData.studentNumber;
    //             controller.getLateralStudentDetailsAPI();
    //         }

    //         //  else if(formData.sectionName == 'verifyLateralOTP') {
    //         //     // Convert OTPFields using JSON serialization
    //         //     if(formData.objOTP != null) {
    //         //         // String otpJson = JSON.serialize(formData.objOTP);
    //         //         controller.objOTP = new FormPageController.OTPFields();
    //         //         controller.objOTP.Otp = formData.objOTP.Otp;
    //         //         controller.objOTP.OtpCode = formData.objOTP.OtpCode;
    //         //         controller.objOTP.EmailId = formData.objOTP.EmailId;
    //         //         controller.objOTP.mobileNo = formData.objOTP.mobileNo;
    //         //     }
    //         //     controller.verifyLateralStudentOTP();
    //         // } 

    //         else if(formData.sectionName == 'nonLateral') {
    //             controller.updateAsNonLateral();
    //         }
            
    //         // Prepare response
    //         LeadData responseData = new LeadData();
    //         responseData.errorMsg = controller.errorMsg;
    //         responseData.lateralMessage = controller.lateralMessage;
    //         responseData.isVerified = controller.isVerified;
    //         responseData.objLead = controller.objLead;
            
    //         // Convert DEBDetails using JSON serialization
    //         if(controller.debDetailObject != null) {
    //             String debJson = JSON.serialize(controller.debDetailObject);
    //             responseData.debDetailObject = (DEBDetails)JSON.deserialize(debJson, DEBDetails.class);
    //         }
    //          BaseResponse response = new BaseResponse('Success', 'Operation completed successfully' , responseData);
    //          return JSON.serialize(response); 
    //     } catch(Exception e) {
    //         BaseResponse errorResponse = new BaseResponse('Error', 'Error inserting data: ' + e.getMessage(), null);
    //         return JSON.serialize(errorResponse);
    //     }
    // }

    /**
    * @description 
    * @author @Ravi | 08--08--2025 
    * @param List<WorkExperience> weList 
    * @return List<nm_WorkExperience__c> 
    **/
    private static List<nm_WorkExperience__c> convertWorkExperienceList(List<WorkExperience> weList) {
        List<nm_WorkExperience__c> result = new List<nm_WorkExperience__c>();
        if (weList != null) {
            for (WorkExperience we : weList) {
                nm_WorkExperience__c weObj = new nm_WorkExperience__c();
                weObj.Id = we.id;
                weObj.nm_Student__c = we.studentId;
                weObj.nm_Lead__c = we.leadId;
                weObj.Currently_Working_Here__c = we.isCurrent;
                weObj.nm_StartDate__c = we.startDate;
                weObj.nm_EndDate__c = we.endDate;
                weObj.Total_Work_Experience__c = we.totalExperience;
                weObj.Industry__c = we.industry;
                weObj.OtherIndustry__c = we.otherIndustry;
                weObj.nm_CompanyName__c = we.companyName;
                weObj.nm_Other_Company_Name__c = we.otherCompanyName;
                weObj.nm_Department__c = we.department;
                weObj.Department__c = we.departmentName;
                weObj.nm_Designation__c = we.designation;
                weObj.nm_OtherDesignation__c = we.otherDesignation;
                weObj.Annual_Income__c = we.annualIncome;
                weObj.Experience_Level__c = we.experienceLevel;
                result.add(weObj);
            }
        }
        return result;
    }

    /**
    * Converts sObject WorkExperience to API list
    */
    private static List<WorkExperience> convertWorkExpToApi(List<nm_WorkExperience__c> weList) {
        List<WorkExperience> result = new List<WorkExperience>();
        if (weList != null) {
            for (nm_WorkExperience__c we : weList) {
                WorkExperience weObj = new WorkExperience();
                weObj.id = we.Id;
                weObj.studentId = we.nm_Student__c;
                weObj.leadId = we.nm_Lead__c;
                weObj.isCurrent = we.Currently_Working_Here__c;
                weObj.startDate = we.nm_StartDate__c;
                weObj.endDate = we.nm_EndDate__c;
                weObj.totalExperience = we.Total_Work_Experience__c;
                weObj.industry = we.Industry__c;
                weObj.otherIndustry = we.OtherIndustry__c;
                weObj.companyName = we.nm_CompanyName__c;
                weObj.otherCompanyName = we.nm_Other_Company_Name__c;
                weObj.department = we.nm_Department__c;
                weObj.departmentName = we.Department__c;
                weObj.designation = we.nm_Designation__c;
                weObj.otherDesignation = we.nm_OtherDesignation__c;
                weObj.annualIncome = we.Annual_Income__c;
                weObj.experienceLevel = we.Experience_Level__c;
                weObj.name = we.Name;
                weObj.recordId = we.RecordId__c;
                result.add(weObj);
            }
        }
        return result;
    }

        // Response Wrapper
        private static void sendResponse(String status, String message, Object data) {
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new BaseResponse(status, message, data)));
        }

    // Helper method to convert Lead to Map
    // private static Map<String, Object> leadToMap(Lead ld) {
    //     Map<String, Object> leadMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ld));
    //     return leadMap;
    // }
    
    // // Helper method to convert Account to Map
    // private static Map<String, Object> accountToMap(Account acc) {
    //     Map<String, Object> accountMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(acc));
    //     return accountMap;
    // }

    // request/response structures
    global class BaseResponse {
        public String status;
        public String message;
        public Object data;
        public BaseResponse(String status, String message, Object data) {
            this.status = status;
            this.message = message;
            this.data = data;
        }
    }
    
    global class DEBDetails {
        public Boolean isAPICalled;
        public Boolean isDEBActive;
        public Boolean isDOBMatched;
        public Boolean isDebMatched;
        public Boolean isABCMatched;
        public Date dateOfBirthDEB;
        public String debUniqueId;
        public String abcUniqueId;
        public Boolean isDebInvalid;
    }
    
    global class OTPFields {
        public String Otp;
        public String OtpCode;
        public String EmailId;
        public String mobileNo;
        public String PersonContactId;
        public Boolean isEmailVerified;
        public Boolean isMobileVerified;
        public String recordObject;
        public String recordId;
        public String OtpMode;
        public Boolean isOTPSent;
        public Boolean isSuccess;
    }
       
  global class WorkExperience {
        public String id;
        public String studentId;          // was nm_Student__c
        public String leadId;            // was nm_Lead__c
        public Boolean isCurrent;        // was Currently_Working_Here__c
        public Date startDate;           // was nm_StartDate__c
        public Date endDate;             // was nm_EndDate__c
        public String totalExperience;   // was Total_Work_Experience__c
        public String industry;          // was Industry__c
        public String otherIndustry;     // was OtherIndustry__c
        public String companyName;       // was nm_CompanyName__c
        public String otherCompanyName;  // was nm_Other_Company_Name__c
        public String department;        // was nm_Department__c
        public String departmentName;    // was Department__c
        public String designation;       // was nm_Designation__c
        public String otherDesignation;  // was nm_OtherDesignation__c
        public String annualIncome;      // was Annual_Income__c
        public String experienceLevel;   // was Experience_Level__c
        public String name;
        public String recordId;          // was RecordId__c
    }
    
    global class LeadData {
        public String leadId;
        public String accountId;
        public Boolean isEditFormConfirmation;
        public String sectionName;
        public String reloadPageBlock;
        public Boolean passout;
        public String yearOfPassing;
        public String monthOfPassing;
        public String program;
        public String Status;
        public List<WorkExperience> lstWorkExperience;
        public List<String> lateraleditablefields;
        public Map<String,String> mapOfNameVsId;
        public Lead objLead;
        public Account objAccount;
        public OTPFields objOTP;
        public Boolean isRecordQueried;
        public String studentNumber;
        public Boolean isLateral;
        public Boolean isVerified;
        public String copyPermanantAddressFromTo;
        public String programNameForSpecialization;
        public String jsonMapOfEligibilityVsWorkExp;
        public String jsonMapOfEligibilityVsRequiredAcademic;
        public String jsonMapOfEligibilityVsRequiredAcademicPercentage;
        public String jsonMapOfSpecialisationVsId;
        public String jsonMapOfEligibilityVsMaster;
        public String isDupChecked;
        public String postalCodeMessage;
        public String postalCode;
        public String alumniMessage;
        public String lateralMessage;
        public String OtpMode;
        public Boolean isLateralData;
        public String sectionPageBlock;
        public String isConfirm;
        public String errorMsg;
        public Integer yearsEligibility;
        public Set<String> removedWorkExperience;
        public DEBDetails debDetailObject;
    }

    global class detailsWrapper {
        public String chooseProgram;
        public String programType;
        public String session;
        public Integer year; 
        public Boolean isConfirmed;
        public Boolean isValid; 
        public String studentno;
        public Boolean isInterviewEnabled ;
        public Boolean showPayment;
        public Boolean showRereg;
        public Boolean showVideoCall;

       public detailsWrapper(){
        isConfirmed = false;
        isValid = false;
        studentno = '';
        isInterviewEnabled = false;
        showPayment = false;
        showRereg = false;
        showVideoCall = true;
       }

    }

    global class SelectOption {
        public String value;
        public String label;
        
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

}