/**
     * @File Name          : nmRegistration_Controller.cls
     * @Description        :
     * @Author             : shubhranshu
     * @Group              :
     * @Last Modified By   : @BK
     * @Last Modified On   : 06-04-2024
     * @Modification Log   :
     * Ver       Date            Author                 Modification
     * 1.0    8/31/2019   shubhranshu     Initial Version
     **/

     public class nmRegistration_Controller {
        public lead objLead { get; set; }
        public String jsonMapOfEligibilityVsWorkExp { get; set; }
        public String jsonMapOfEligibilityVsRequiredAcademic { get; set; }
        public String jsonMapOfEligibilityVsRequiredAcademicPercentage { get; set; }
        public Map<String, String> mapOfFieldAPIVsFieldLabel { get; set; }
        public String strSecToShow { get; set; }
        public String message { get; set; }
        public Boolean IsReLogin { get; set; }
        public Boolean IsLeadJustInserted { get; set; }
        public String ipAddress { get; set; }
        public String LeadId { get; set; }
        public Boolean disabledIC { get; set; }
        public Boolean IsICForMakingPayment { get; set; }
        public String billingToShippingCopyAddress { get; set; }
        public String CopyPermanantAddressFromTo { get; set; }
        public String Postalcode { get; set; }
        public String icValue { get; set; }
        public String sectionName { get; set; }
        public Boolean IsEditFormConfirmation { get; set; }
        public List<nm_WorkExperience__c> lstWorkExperience { get; set; }
        public Map<String, Id> mapOfNameVsId { get; set; }
        public nm_WorkExperience__c objWorkExpNew { get; set; }
        public String PostalCodeMessage { get; set; }
        public Map<String, nm_Centers__c> mapOfCenterIdVsCenter { get; set; }
        public Map<String, String> mapOfCenterIdAndCenterName { get; set; }
        public Map<String, nm_Program__c> mapOfProgramIdAndProgram { get; set; }
        public String totalWorkExperience { get; set; }
        public Integer yearsEligibility { get; set; }
        public Set<Id> RemovedWorkExperience { get; set; }
        public String FormConfigName { get; set; }
        public NM_Orgnisation_Based_FormConfiguration__c org_formConfig { get; set; }
        public String program_Name { get; set; }
        public String IC_name { get; set; }
        public String formConfigId { get; set; }
        public List<String> eligiblitylist { get; set; }
        public String LeadSource { get; set; }
        public String corporateBatchName { get; set; }
        public Boolean checkExpireDateforBatch { get; set; }
        public String isDupChecked { get; set; }
        public Boolean allowLateral {get; set; }
        public String imageURL {get;set;}
        public String registrationNo {get;set;}
        
        //---- Select Options ---------------//
        public List<SelectOption> globalStateValue { get; set; }
        public List<SelectOption> globalCountryValue { get; set; }
        public List<SelectOption> getWorkExpTimeList { get; set; }
        public List<SelectOption> getElegibilityCriteriaList { get; set; }
        public List<SelectOption> getLateralOptions { get; set; }
        public List<SelectOption> getDomicileList { get; set; }
        // public List<SelectOption> getUniversityList {get;set;}
        public List<SelectOption> getCompanyList { get; set; }
        public List<SelectOption> getProgramsList { get; set; }

        //For OTP Verification Login
        public String registrationButton {get;set;}
        public OTPFields objOTP {get;set;}
        public list<string> lstMsg  { get; set; }

    
        public String jsonMapOfCenterVsAllowPG { get; set; }
        public String jsonMapOfCenterVsAllowMaster { get; set; }
    
        public nmRegistration_Controller() {
            objLead = new Lead();
            objLead.id = null;
            icValue = 'false';
            sectionName = '';
            jsonMapOfEligibilityVsWorkExp = null;
            jsonMapOfEligibilityVsRequiredAcademic = null;
            jsonMapOfEligibilityVsRequiredAcademicPercentage = null;
            mapOfFieldAPIVsFieldLabel = new Map<String, String>();
            mapOfCenterIdAndCenterName = new Map<String, String>();
            mapOfProgramIdAndProgram = new Map<String, nm_Program__c>();
            jsonMapOfCenterVsAllowPG = null;
            jsonMapOfCenterVsAllowMaster = null;
            strSecToShow = '';
            isDupChecked = '';
            disabledIC = false;
            message = null;
            IsReLogin = false;
            Postalcode = '';
            ipAddress = null;
            LeadId = null;
            IsICForMakingPayment = false;
            billingToShippingCopyAddress = '';
            CopyPermanantAddressFromTo = '';
            IsEditFormConfirmation = false;
            lstWorkExperience = new List<nm_WorkExperience__c>();
            mapOfNameVsId = new Map<String, Id>();
            objWorkExpNew = new nm_WorkExperience__c();
            PostalCodeMessage = '';
            totalWorkExperience = '';
            yearsEligibility = 0;
            RemovedWorkExperience = new Set<Id>();
            org_formConfig = new NM_Orgnisation_Based_FormConfiguration__c();
            program_Name = '';
            IC_name = '';
            formConfigId = '';
            eligiblitylist = new List<String>();
            LeadSource = '';
            registrationNo = '';
            imageURL = '';

            // OTP
            registrationButton = '';
            IsLeadJustInserted = false;
            objOTP = new OTPFields();
            lstMsg = new List<String>();
            LeadId = ApexPages.currentPage().getParameters().get('id');
            sectionName = ApexPages.currentPage().getParameters().get('sectionName');
            FormConfigName = ApexPages.currentPage().getParameters().get('FormId');
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            allowLateral = false;
            if (ApexPages.currentPage().getParameters().get('IC') != null && ApexPages.currentPage().getParameters().get('IC') != '') {
                IsICForMakingPayment = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IC'));
            }
    
            if (ApexPages.currentPage().getParameters().get('ReLogin') != null && ApexPages.currentPage().getParameters().get('ReLogin') != '') {
                IsReLogin = Boolean.valueOf(ApexPages.currentPage().getParameters().get('ReLogin'));
            }

            if (ApexPages.currentPage().getParameters().get('skipOTP') != null && ApexPages.currentPage().getParameters().get('skipOTP') != '') {
                objOTP.skipOTP = Boolean.valueOf(ApexPages.currentPage().getParameters().get('skipOTP'));
            }
    
            if (
                ApexPages.currentPage().getParameters().get('IsEditFormConfirmation') != null &&
                ApexPages.currentPage().getParameters().get('IsEditFormConfirmation') != ''
            ) {
                IsEditFormConfirmation = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IsEditFormConfirmation'));
            }
    
            if (String.isNotBlank(ApexPages.currentPage().getParameters().get('batch'))) {
                corporateBatchName = ApexPages.currentPage().getParameters().get('batch');
                checkExpireDateforBatch = calenderCheckForCorporate(corporateBatchName);
                System.debug('checkExpireDateforBatch ' + checkExpireDateforBatch);
            }
    
            if(String.isBlank(LeadId)) {
                LeadId = getCookie();
            }
    
            if (String.isNotBlank(LeadId)) {
                QueryLeadData();
            } 
            // else {
            //     AddExperience();
            // }
    
            if (String.isNotBlank(FormConfigName)) {
                QueryOrgFormConfigData();
            }
            //To put all the active center in the map
            getAllProgramMap();
            getAllCenterMap();
        }
    
        public void ErrorMessage(String msg, String secToShow) {
            message = msg;
            strSecToShow = secToShow;
        }
    
        public Map<String, String> getMapOfEditableVsDataTypeOfFieldForSObject(String ObjectAPIName) {
            Map<String, String> mapOfEditableFieldAPIVsDataType = new Map<String, String>();
            Map<String, Boolean> mapOfFieldVsPermission = getMapOfFieldVsPermission(ObjectAPIName);
            Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
            Map<String, schema.SObjectField> fieldMap = scemapMap.get(ObjectAPIName).getDescribe().fields.getMap();
            for (String fieldName : fieldMap.keySet()) {
                // if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                if (mapOfFieldVsPermission.containsKey(fieldName)) {
                    System.debug('fieldName 2 -->' + fieldName);
                    mapOfEditableFieldAPIVsDataType.put(fieldName.toLowerCase(), String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
                }
                // }
            }
    
            return mapOfEditableFieldAPIVsDataType;
        }
    
        public Map<String, Boolean> getMapOfFieldVsPermission(String ObjectAPIName) {
            String ProfileId = userinfo.getProfileId();
            Map<String, Boolean> mapOfFieldVsPermission = new Map<String, Boolean>();
            List<FieldPermissions> lstFieldPermissions = [
                SELECT Field
                FROM FieldPermissions
                WHERE SobjectType = :ObjectAPIName AND Parent.ProfileId = :ProfileId AND PermissionsEdit = TRUE
            ];
            if (lstFieldPermissions.size() > 0) {
                for (FieldPermissions objFieldPermissions : lstFieldPermissions) {
                    String fieldName = objFieldPermissions.Field;
                    fieldName = fieldName.substringAfterLast('.');
                    System.debug('fieldName -->' + fieldName);
                    mapOfFieldVsPermission.put(fieldName.toLowerCase(), true);
                }
            }
            return mapOfFieldVsPermission;
        }
    
        public String getQueryAllFieldSql(String ObjectAPIName, String conditionString, String relatedField) {
            Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
            Map<String, schema.SObjectField> fieldMap = scemapMap.get(ObjectAPIName).getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            if (relatedField != null && relatedField != '') {
                fieldNames.add(relatedField);
            }
            String query = 'Select ' + String.join(fieldNames, ',') + ' from ' + ObjectAPIName + ' where ' + conditionString;
            return query;
        }
    
        public void QueryLeadData() {
            String leadQuery = LeadQuery();
            leadQuery = leadQuery + ' WHERE id=: LeadId';
            // String leadQuery = getQueryAllFieldSql('Lead',' id=: LeadId',' nm_Program__r.Name,nm_InformationCenter__r.Allow_Executive__c,nm_InformationCenter__r.Address__c');
            List<Lead> lstLead = DataBase.query(leadQuery);
            if (lstLead.size() > 0) {
                objLead = lstLead[0];
                objLead.id = null;
                IsReLogin = true;
                registrationNo = objLead.nm_RegistrationNo__c;
                imageURL = objLead.nm_StudentImageUrl__c;
    
                system.debug('objLead ----> ' + objLead);
                system.debug('objLead.Country_Shipping__c ----> ' + objLead.Country_Shipping__c);
    
                //to get the List of work experience from leadid.
                String WorkExpQuery = getQueryAllFieldSql('nm_WorkExperience__c', 'nm_Lead__c=: LeadId', null);
                // lstWorkExperience = DataBase.query(WorkExpQuery);
                System.debug('WorkExpQuery ==>' + WorkExpQuery);
                List<nm_WorkExperience__c> lstWorkExperienceRecord = DataBase.query(WorkExpQuery);
                for (nm_WorkExperience__c objWp : lstWorkExperienceRecord) {
                    nm_WorkExperience__c objWpClone = objWp;
                    objWpClone.id = null;
                    lstWorkExperience.add(objWpClone);
                    mapOfNameVsId.put(objWp.Name, objWp.RecordId__c);
                    System.debug('mapOfNameVsId==>');
                    System.debug(mapOfNameVsId);
                }
                if (lstWorkExperienceRecord.size() == 0 || lstWorkExperienceRecord == null) {
                    AddExperience();
                }
                CallValidate();
                checkShippingSamePermanent();
    
                if (String.isBlank(sectionName)) {
                    System.debug('sectionName -->' + sectionName);
                    sectionName = 'Generate Registration No';
                }
    
                System.debug('sectionName -->' + sectionName);

                // to create the cookie
                if(String.isBlank(getCookie())) {
                    setCookie(LeadId);
                }
            }
        }
    
        public void QueryOrgFormConfigData() {
            String formConfigQuery = getQueryAllFieldSql(
                'NM_Orgnisation_Based_FormConfiguration__c',
                'Configuration_Id__c=:FormConfigName ',
                'Program__r.nm_ProgramName__c,Centers__r.Name'
            );
            List<NM_Orgnisation_Based_FormConfiguration__c> lstofFormConfig = Database.query(formConfigQuery);
            if (lstofFormConfig.size() > 0) {
                org_formConfig = lstofFormConfig[0];
                program_Name = org_formConfig.Program__r.nm_ProgramName__c;
                IC_name = org_formConfig.Centers__r.Name;
                formConfigId = org_formConfig.Configuration_Id__c;
                allowLateral = org_formConfig.Allow_Lateral__c;
                eligiblitylist = org_formConfig.Eligiblity__c.split(';');
            }
            System.debug('org_formConfig ' + org_formConfig);
        }
    
        public List<SelectOption> getAllInformationCenters() {
            List<SelectOption> lstICOptions = new List<SelectOption>();
            Map<String, Boolean> mapOfCenterVsAllowPG = new Map<String, Boolean>();
            Map<String, Boolean> mapOfCenterVsAllowMaster = new Map<String, Boolean>();
            lstICOptions.add(new SelectOption('', string.isNotBlank(formConfigId) ? 'Choose Center' : 'Choose City'));
            if (String.isBlank(IC_name)) {
            List<nm_Centers__c> lstActiveCenters = [
                SELECT id, Name, nm_Active__c, RegistrationClosed__c, Allow_Executive__c, Allow_Degree__c, Allow_PG__c, Registration_City__c
                FROM nm_Centers__c
                WHERE
                    // recordtype.Name = 'Learning Center' AND 
                    nm_Active__c = TRUE
                    AND RegistrationClosed__c = FALSE
                ORDER BY name ASC
                ];
            if(lstActiveCenters.size() > 0) {
                Map<String, String> mapOfCityAndCenterId = new Map<String, String>();
                for(nm_Centers__c objCenter : lstActiveCenters) {
                    if(String.isNotBlank(objCenter.Registration_City__c)) {
                        List < String > lstAssignityToLc = objCenter.Registration_City__c.split(';');
                        Set<String> setAssignityToLc = new Set<String>(lstAssignityToLc);
                        for (string assignIcTOLC: setAssignityToLc) {
                            mapOfCityAndCenterId.put(assignIcTOLC.trim(),objCenter.Id);
                            // lstICOptions.add(new SelectOption(objCenter.Id, assignIcTOLC.trim()));
                        }
                    }
                }
                if(!mapOfCityAndCenterId.isEmpty()) {
                    List<String> lstOfCen = new List<String>(mapOfCityAndCenterId.keySet());
                    lstOfCen.sort();
                    for (string city: lstOfCen) {
                        lstICOptions.add(new SelectOption(mapOfCityAndCenterId.get(city), city));
                    }
                }
            }
            } else {
                List<nm_Centers__c> lstActiveCenters = [
                SELECT id, Name, nm_Active__c, RegistrationClosed__c, Allow_Executive__c, Allow_Degree__c, Allow_PG__c
                FROM nm_Centers__c
                WHERE recordtype.Name = 'Information Center' AND Name = :IC_name
                ORDER BY name ASC
                ];
                if (lstActiveCenters.size() > 0) {
                for (nm_Centers__c objCenter : lstActiveCenters) {
                    if ('Executive Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c)) {
                        if (objCenter.Allow_Executive__c == true) {
                            lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
                            mapOfCenterVsAllowPG.put(objCenter.id, objCenter.Allow_PG__c);
                            mapOfCenterVsAllowMaster.put(objCenter.id, objCenter.Allow_Degree__c);
                        }
                    } else {
                        lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
                        mapOfCenterVsAllowPG.put(objCenter.id, objCenter.Allow_PG__c);
                        mapOfCenterVsAllowMaster.put(objCenter.id, objCenter.Allow_Degree__c);
                    }
                }
            }
    
            
            }
            if (!mapOfCenterVsAllowPG.isEmpty()) {
                jsonMapOfCenterVsAllowPG = JSON.serialize(mapOfCenterVsAllowPG);
            }
    
            if (!mapOfCenterVsAllowMaster.isEmpty()) {
                jsonMapOfCenterVsAllowMaster = JSON.serialize(mapOfCenterVsAllowMaster);
            }

            return lstICOptions;
        }


    
        //To check if the executive program is avilable to the center before changing the program.
        public void checkICValid() {
            Boolean AllowExecutive = false;
            AllowExecutive = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).Allow_Executive__c;
            if (String.isNotBlank(objLead.nm_InformationCenter__c) && 'Executive Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) && !AllowExecutive) {
                String previousProgramType = null;
                String LCContactNo = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__r.Contact_No_1__c;
                System.debug('LCContactNo--->' + LCContactNo);
                if (objLead.nm_ProgramForOpp__c != null) {
                    if (mapOfProgramIdAndProgram.containsKey(objLead.nm_ProgramForOpp__c)) {
                        previousProgramType = mapOfProgramIdAndProgram.get(objLead.nm_ProgramForOpp__c).nm_Type__c;
                    }
                } else if (objLead.nm_SelectedProgram__c != null) {
                    if (mapOfProgramIdAndProgram.containsKey(objLead.nm_SelectedProgram__c)) {
                        previousProgramType = mapOfProgramIdAndProgram.get(objLead.nm_SelectedProgram__c).nm_Type__c;
                    }
                }
    
                if ('Executive Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c)) {
                    System.debug('check if condition2--->' + previousProgramType);
                    if (!'Executive Programs'.equalsIgnoreCase(previousProgramType) && previousProgramType != null) {
                        objLead.nm_ChooseaProgram__c = previousProgramType;
                        System.debug('previousProgramType-->' + previousProgramType);
                        ErrorMessage('Contact Learning Center (' + LCContactNo + ') to change this program.', 'PopUpError');
                    }
                } else {
                    if (!'Executive Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c)) {
                        if ('Executive Programs'.equalsIgnoreCase(previousProgramType)) {
                            objLead.nm_ChooseaProgram__c = previousProgramType;
                            System.debug('previousProgramType-->' + previousProgramType);
                            ErrorMessage('Contact Learning Center (' + LCContactNo + ') to change this program.', 'PopUpError');
                        }
                    }
                }
            } else {
                ErrorMessage('', '');
                System.debug('No ' + AllowExecutive);
            }
        }
    
        public void getAllCenterMap() {
            mapOfCenterIdAndCenterName = new Map<String, String>();
            mapOfCenterIdVsCenter = new Map<String, nm_Centers__c>();
            List<nm_Centers__c> lstCenters = [
                SELECT id, Name, nm_Active__c, RecordType.Name, Allow_Executive__c, nm_LearningCenter__r.Contact_No_1__c
                FROM nm_Centers__c
                ORDER BY name ASC
            ];
    
            if (lstCenters.size() > 0) {
                for (nm_Centers__c objCenter : lstCenters) {
                    if (objCenter.RecordType.Name == 'Information Center' && objCenter.nm_Active__c == true) {
                        mapOfCenterIdAndCenterName.put(objCenter.id, objCenter.Name);
                        mapOfCenterIdAndCenterName.put(objCenter.Name, objCenter.id);
                    }
                    mapOfCenterIdVsCenter.put(objCenter.id, objCenter);
                }
            }
        }
    
        public void getAllProgramMap() {
            mapOfProgramIdAndProgram = new Map<String, nm_Program__c>();
            List<nm_Program__c> lstPrograms = [
                SELECT id, nmIsActive__c, nm_ProgramName__c, nm_Type__c, Specialisation__c
                FROM nm_Program__c
                WHERE nmIsActive__c = TRUE
            ];
    
            if (lstPrograms.size() > 0) {
                for (nm_Program__c objProgram : lstPrograms) {
                    mapOfProgramIdAndProgram.put(objProgram.id, objProgram);
                    mapOfProgramIdAndProgram.put(objProgram.nm_ProgramName__c, objProgram);
                }
            }
        }
    
        public List<SelectOption> getProgramsList() {
            List<SelectOption> lstProgramsOptions = new List<SelectOption>();
            lstProgramsOptions.add(new SelectOption('', 'Choose Program'));
            String chooseProgram = objLead.nm_ChooseaProgram__c;
            String queryProgram = '';
            System.debug('chooseProgram---------->' + chooseProgram);
            System.debug('program_Name---------->' + program_Name);
            if (String.isBlank(program_Name)) {
                List<nm_Program__c> lstActiveProgram = [
                    SELECT id, nm_ProgramName__c
                    FROM nm_Program__c
                    WHERE nm_Type__c = :chooseProgram AND nmIsActive__c = TRUE
                    ORDER BY Name ASC
                ];
                System.debug('lstActiveProgram--' + lstActiveProgram);
                if (lstActiveProgram.size() > 0) {
                    for (nm_Program__c objProgram : lstActiveProgram) {
                        lstProgramsOptions.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
                    }
                }
            } else {
                List<nm_Program__c> lstActiveProgram = [
                    SELECT id, nm_ProgramName__c
                    FROM nm_Program__c
                    WHERE nm_ProgramName__c = :program_Name
                    ORDER BY Name ASC
                ];
                System.debug('lstActiveProgram--' + lstActiveProgram);
                if (lstActiveProgram.size() > 0) {
                    for (nm_Program__c objProgram : lstActiveProgram) {
                        lstProgramsOptions.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
                    }
                }
            }
            return lstProgramsOptions;
        }
    
        public PageReference nextPage() {
            System.debug('objLead Email---' + objLead.Email);
            checkExistingLead();
            if(validateFormOnServerSide()) {
                return null;
            }
            if (LeadId == '' || LeadId == null) {
                objLead.Status = 'Not Contacted';
                if (String.isNotBlank(corporateBatchName)) {
                    objLead.LeadSource = 'Corporate';
                } else if (String.isBlank(LeadSource) ) {
                    objLead.LeadSource = 'Web';
                }
                objLead.nm_IPForLead__c = ipAddress;
                objLead.nm_PaymentStatus__c = '';
                objLead.Partial_form_filled__c = true;
                objLead.StudentLogin__c = false;
                objLead.nm_SelectedIC__c = objLead.nm_InformationCenter__r.Name;
                if(String.isNotBlank(FormConfigName)){
                    objLead.Form_Id__c = FormConfigName;
                }
                // Lead Routing
                LeadRouting();
                try {
                    insert objLead;
                    LeadId = objLead.id;
                    objLead.id = null;
                    QueryLeadData();
                    if(objOTP.optStatus != 'OTP Verified' && System.label.Allow_OTP_For_Registration == 'TRUE' && !objOTP.skipOTP) {
                        IsLeadJustInserted = true;
                        validateOTPStatus();
                    }
                    // List<Lead> lstLeadDuplicate = [SELECT nm_RegistrationNo__c,id FROM Lead WHERE id=:LeadId];
                    // registrationNo = lstLeadDuplicate[0].nm_RegistrationNo__c;
                } catch (Exception e) {
                    ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
                    System.debug('Error-->' + String.valueof(e));
                    if (String.valueof(e).contains('duplicate value found') && String.valueof(e).contains('nm_CheckforDuplicacy__c')) {
                        ErrorMessage('Mobile no already exist. Please enter valid mobile no.', 'PopUpError');
                    }
                }
            } else {
                try {
                    CopyAddress();
                    isDupChecked = isDuplicateAccountExist();
                    if (isDupChecked == 'Duplicate') {
                        System.debug('isDuplicateAccountExist--->');
                        if(registrationButton == 'registrationButton') {
                            LeadId = null;
                        }
                        ErrorMessage('Duplicate record found. Kindly contact ngasce@nmims.edu', 'PopUpError');
                        return null;
                    } 
                    // else if(registrationButton != 'registrationButton' && validateImageUrl()) {
                    //     System.debug('Student Image is Missing--->');
                    //     ErrorMessage('Please Upload Photo.','PopUpError');
                    //     return null;
                    // }
                    if(objOTP.optStatus != 'OTP Verified' && System.label.Allow_OTP_For_Registration == 'TRUE' && !objOTP.skipOTP && registrationButton == 'registrationButton') {
                        IsLeadJustInserted = true;
                        validateOTPStatus();
                    }
                    // objLead.id = LeadId;
                    Lead objNewLead = objLead.clone();
                    objNewLead.id = LeadId;
                    objLead.Partial_form_filled__c = true;
                    objLead.StudentLogin__c = false;
                    System.debug('updating record -->');
                    update objNewLead;
                    System.debug('record updated-->' + objLead.Partial_form_filled__c);
                    objLead.id = null;
                    if (lstWorkExperience.size() == 0) {
                        QueryLeadData();
                    }
                    // goToTabNextAfterUpdate();
                } catch (Exception e) {
                    ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
                    System.debug('Error-->' + String.valueof(e));
                    if (String.valueof(e).contains('duplicate value found') && String.valueof(e).contains('nm_CheckforDuplicacy__c')) {
                        ErrorMessage('Mobile no already exist. Please enter valid mobile no.', 'PopUpError');
                    }
                }
            }
            return null;
        }
    
        // method call from Confirmation Page
        public PageReference GoToEditTab() {
            String page = 'nmcompleteFormRevised?';
            String EditUrl = '';
            if (objLead.IC_Name__c == 'Vertiv') {
                page = 'nmCompleteFormVertiv?';
            } else if (objLead.IC_Name__c == 'BAJAJ') {
                page = 'nmCompleteFormBajaj?';
            }
            if (objLead.LeadSource != '' && objLead.LeadSource != null && objLead.LeadSource == 'Corporate') {
                page = 'corporatecompleteForm?batch=' + System.Label.Conneqt_Batch + '&';
            }
            System.debug('Form Id'+FormConfigName);
            if(String.isNotBlank(FormConfigName)){
                page = 'NM_CompleteOrginzationForm?FormId=' + FormConfigName + '&';
            }
            System.debug('page '+page);
            EditUrl = '/apex/' + page + 'id=' + LeadId + '&sectionName=' + sectionName + '&IsEditFormConfirmation=true';
            PageReference pg = new PageReference(EditUrl);
            pg.setRedirect(true);
            return pg;
        }
    
        public PageReference GoToConfirmationForm() {
            try {
                String page = System.Label.Preview_Form;
                isDupChecked = isDuplicateAccountExist();
                System.debug('isDupChecked--->' + isDupChecked);
                if (isDupChecked == 'Duplicate') {
                    System.debug('isDuplicateAccountExist--->');
                    ErrorMessage('Duplicate record found. Kindly contact ngasce@nmims.edu', 'PopUpError');
                    return null;
                }  
                // else if(validateImageUrl()) {
                //     System.debug('Student Image is Missing--->');
                //     ErrorMessage('Please Upload Photo.','PopUpError');
                //     return null;
                // }
                //to save work expereience
                Boolean SaveWorkExp = SaveWorkExp();
                system.debug('SaveWorkExp -->' + SaveWorkExp);
                objLead.Partial_form_filled__c = false;
                Lead objNewLead = objLead.clone();
                objNewLead.id = LeadId;
                objNewLead.nm_PaymentStatus__c = '';
                if (objNewLead.Status != 'Registration Fee Paid' && objNewLead.Status != 'Admission Fee Paid' && objNewLead.Status != 'Registration Form Filled') {
                    objNewLead.Status = 'Registration Form Filled';
                }
    
                if (SaveWorkExp) {
                    update objNewLead;
                    System.debug('FormConfigName '+FormConfigName);
                    if(String.isNotBlank(FormConfigName)){
                        page = page + '?id=' + LeadId + '&FormId=' +FormConfigName;
                    }else{
                        page = page + '?id=' + LeadId;
                    }
                    PageReference pg = new PageReference('/apex/' + page);
                    pg.setRedirect(true);
                    return pg;
                } else {
                    ErrorMessage('All the fields are Manadatory for Work Experience !!', 'PopUpError');
                    return null;
                }
            } catch (Exception e) {
                ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
                return null;
            }
        }
    
        public PageReference GotoPrintFormEdit() {
            String RedirectURL = '/apex/nm_PrintRegistrationForm?id=' + LeadId;
            PageReference pg = new PageReference(RedirectURL);
            pg.setRedirect(true);
            return pg;
        }
    
        /*public void LeadRouting() {
            Map<String,String> mapOfKeyVsCenterId = new Map<String,String>();
            Map<String,String> mapOfKeyVsCenterName = new Map<String,String>();
            List<String> lstProgramList = new List<String>();
            Schema.DescribeFieldResult fieldResult = Lead_Routing__c.Choose_a_Program__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple) {
                lstProgramList.add(f.getValue());
            }
            System.debug(lstProgramList);    
            List <Lead_Routing__c> lstActiveLeadRouting = [SELECT id, From_IC__c, To_IC__c, Agency__c,Choose_a_Program__c,CounselorProfile__c,From_Center__c,To_Center__c FROM Lead_Routing__c WHERE Active__c = true];
            if(lstActiveLeadRouting.size() > 0) {
                for (Lead_Routing__c objLeadRouting : lstActiveLeadRouting) {
                    List<String> lstProgram = new List<String>();
                    List<String> lstAgency = new List<String>();
                    if(objLeadRouting.Choose_a_Program__c!=null && objLeadRouting.Choose_a_Program__c!='') {
                        lstProgram = objLeadRouting.Choose_a_Program__c.split(';');
                    }
                    if(objLeadRouting.Agency__c!=null && objLeadRouting.Agency__c!='') {
                        lstAgency = objLeadRouting.Agency__c.split(',');
                    }
                    if(lstProgram.size() == 0 && lstAgency.size() == 0) {
                        for (String program : lstProgramList) {
                            String key = objLeadRouting.From_Center__c +'_'+program+'_null';
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        }
                    } else if(lstProgram.size() > 0 && lstAgency.size() == 0) {
                        for (String program : lstProgram) {
                            String key = objLeadRouting.From_Center__c +'_'+program+'_null';
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        }
                    }
                }
                System.debug(mapOfKeyVsCenterId.size());
                String key = objLead.nm_InformationCenter__c +'_'+ objLead.nm_ChooseaProgram__c +'_null';
                System.debug('Map Key for Lead Routing');
                System.debug(key);
                if(mapOfKeyVsCenterId.containsKey(key)) {
                    objLead.nm_StudentSelectedIC__c = mapOfKeyVsCenterName.get(key);
                    objLead.nm_InformationCenter__c = mapOfKeyVsCenterId.get(key);
                }
            }
        }*/

        // public void continueFormField() {
        //     IsLeadJustInserted = false;
        //     // QueryLeadData();
        //     if(optStatus != 'OTP Verified' && System.label.Allow_OTP_For_Registration == 'TRUE' && !skipOTP) {
        //         validateOTPStatus();
        //     }
        // }

        public void validateOTPStatus() {
            lstMsg.clear();
            objOTP.modalToShow = 'otpVerify';
            if(String.isBlank(objOTP.optStatus)) {
                sendOTP();
                // lstMsg.add('OTP has been sent to your mobile no ******'+objLead.MobilePhone.right(4));
            } else if(objOTP.optStatus == '903') {
                sendOTP();
                lstMsg.add('Incorrect OTP Entered, kindly try again.');
            } else if(objOTP.optStatus == '907') {
                sendOTP();
                lstMsg.add('OTP has been expired, kindly try again.');
            } else {
                sendOTP();
                lstMsg.add('OTP Verification has been failed, kindly try again');
            }
            system.debug('optStatus --> '  + objOTP.optStatus);
        }

        public void sendOTP() {
            String smsMessage = generateOTPMSG();
            if(objOTP.OtpMode == 'E') {
                sendEmailOTP();
            } else {
                System.debug('SMS triggered');
                sendmGageSMSFuture(objLead.MobilePhone.left(10),smsMessage);
                // String result = SMSSenderWebService.sendmGageSMS(objLead.MobilePhone.left(10),smsMessage);
                // System.debug('result ==>'+result);
                objOTP.alertMsg = 'OTP has been sent to your mobile no ******'+objLead.MobilePhone.right(4);
            }
            objOTP.optStatus = 'OTP Sent';
            lstMsg.add(objOTP.alertMsg);
            System.debug('optStatus-->'+objOTP.optStatus);
        }

        @future(callout=true)
        public static void sendmGageSMSFuture(String mobileNumber, String msg){        
            SMSSenderWebService.sendmGageSMS(mobileNumber, msg) ;
        }

        public void sendEmailOTP() {
            String recordId = String.isBlank(objLead.id) ? LeadId : objLead.id;
            try {
                // To Query Organisation Details.
                OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(owe.id);
                mail.setReplyTo(owe.Address);
                    // To Query the Email Template.
                EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Lead' LIMIT 1];
                Lead objupdateLead = new Lead();
                objupdateLead.Email_Verification_Token__c = objOTP.OtpCode;
                objupdateLead.id = recordId;
                update objupdateLead;

                mail.setTargetObjectId(recordId);
                mail.setTemplateId(emailTemplate.Id);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
                String s2 = objLead.Email.substringBefore('@');
                String s1 = '';
                Integer count = s2.length() - 4;
                Integer loopCount = 0;
                while (loopCount < count) {
                    s1 = s1 + '*';
                    loopCount++;
                }
                s2 = s2.substring(0,2) + s1 + s2.right(2) +'@';
                objOTP.alertMsg = 'OTP has been sent to your Email Id '+ s2 + objLead.Email.substringAfter('@');
            } catch (Exception ex) {
                System.debug('Error Msg =>'+ex.getMessage());
                System.debug('Error No =>'+ex.getLineNumber());
            }
        }

        public void VerifyOTP() {
        // String mobileNo = objLead.MobilePhone;
            system.debug('VerifyOTP --> called');
            if(String.isNotBlank(objOTP.Otp)) {
                Long otpEnteredTime = DateTime.now().getTime();
                Long milliseconds = otpEnteredTime - objOTP.otpSentTime;
                Long seconds = milliseconds / 1000;
                if(objOTP.OtpCode == objOTP.Otp && seconds <= 180){
                    objOTP.optStatus = 'OTP Verified';
                    objOTP.modalToShow = 'OTP Verified';
                    IsLeadJustInserted = false;
                    String recordId = String.isBlank(objLead.id) ? LeadId : objLead.id;
                    if(String.isNotBlank(recordId)) {
                        List<Lead> mbLead = [SELECT Id,Is_Mobile_Verified__c,nm_IsEmailVerified__c FROM Lead WHERE Id = :recordId LIMIT 1];
                        if (mbLead.size() > 0 &&  !mbLead[0].Is_Mobile_Verified__c && objOTP.OtpMode == 'M') {
                            Lead upLead = new Lead(Id = recordId, Is_Mobile_Verified__c = true, Mobile_Verification_Token__c = objOTP.OtpCode);
                            update upLead;
                        } else if(mbLead.size() > 0 &&  !mbLead[0].nm_IsEmailVerified__c && objOTP.OtpMode == 'E') {
                            Lead upLead = new Lead(Id = recordId, nm_IsEmailVerified__c = true);
                            update upLead;
                        }
                    }
                }else if(objOTP.OtpCode != objOTP.Otp) {
                    objOTP.optStatus = '903';
                    lstMsg.clear();
                    lstMsg.add('Incorrect OTP Entered, kindly try again.');
                }else if(seconds > 180){
                    objOTP.optStatus = '907';
                    lstMsg.clear();
                    lstMsg.add('OTP has been expired, kindly try again.');
                }else{
                    objOTP.optStatus = '906';
                    lstMsg.clear();
                    lstMsg.add('OTP Verification has been failed, kindly try again.');
                }
                system.debug('seconds --> ' + seconds);
            }
            system.debug('Otp --> ' + objOTP.Otp);
            system.debug('objOTP.OtpCode --> ' + objOTP.OtpCode);
            system.debug('optStatus --> ' + objOTP.optStatus);
            system.debug('modalToShow --> ' + objOTP.modalToShow);
            system.debug('IsLeadJustInserted --> ' + IsLeadJustInserted);
        }

        public String generateOTPMSG() {
            Integer STRING_LENGTH = 5;
            Integer MAX = Integer.valueOf(Math.pow(10,STRING_LENGTH) - 1); // Returns 99999
            objOTP.OtpCode = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
            // objOTP.OtpCode = '11111';
            System.debug('OtpCode-->'+objOTP.OtpCode);
            String smsMessage = objOTP.OtpCode +' is your verification code for SVKM\'s NGASCE.';
            objOTP.otpSentTime = DateTime.now().getTime();
            return smsMessage;
            // return '';
        }
        
         public void LeadRouting() {
            Map<String,String> mapOfKeyVsCenterId = new Map<String,String>();
            Map<String,String> mapOfKeyVsCenterName = new Map<String,String>();
            List<String> lstProgramTypeList = new List<String>();
       

            List<String> lstProgramList = new List<String>();
            Schema.DescribeFieldResult fieldResult = Lead_Routing__c.Choose_a_Program__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple) {
                lstProgramList.add(f.getValue());
            }
            System.debug(lstProgramList); 
            Schema.DescribeFieldResult fieldResultForProgramType = Lead_Routing__c.Program_Type__c.getDescribe();
                    ple = fieldResultForProgramType.getPicklistValues();
                    for( Schema.PicklistEntry f : ple) {
                        lstProgramTypeList.add(f.getValue());
                    }   
            System.debug(lstProgramTypeList); 
            
            List <Lead_Routing__c> lstActiveLeadRouting = [SELECT id,From_IC__c,To_Center__c,From_Center__c ,Agency__c,Choose_a_Program__c,CounselorProfile__c,Program_Type__c FROM Lead_Routing__c WHERE Active__c=true];
            
            
            
            if(lstActiveLeadRouting.size() > 0) {
                
            Map<String,List<String>> mapOfChooseProgranVsProgramType = new Map<String,List<String>>();
            List<String> lstMasterProgram = new List<String>{'MBA (WX)','MBA (X)','M.Sc.','M.Sc. (AI)','M.Sc. (AI & ML Ops)'};
            List<String> lstBachelorProgram = new List<String>{'BBA','BCom','BA'};
            List<String> lstProfessionalProgram = new List<String>{'Professional Diploma Term 4','Professional Diploma','PD Term 4'};
            List<String> lstCertificateProgram = new List<String>{'PC Term 2','Certificate Term 1','Certificate Term 2','Certificate Term 3'};
            mapOfChooseProgranVsProgramType.put('Master Programs',lstMasterProgram);
            mapOfChooseProgranVsProgramType.put('Bachelor Programs',lstBachelorProgram);
            mapOfChooseProgranVsProgramType.put('Professional Programs',lstProfessionalProgram);
            mapOfChooseProgranVsProgramType.put('Certificate Programs',lstCertificateProgram);
            
                          for (Lead_Routing__c objLeadRouting : lstActiveLeadRouting) {
                List<String> lstProgram = new List<String>();
                List<String> lstProgramType = new List<String>();
                List<String> lstAgency = new List<String>();
                if(objLeadRouting.Choose_a_Program__c!=null && objLeadRouting.Choose_a_Program__c!='') {
                    lstProgram = objLeadRouting.Choose_a_Program__c.split(';');
                }
                if(objLeadRouting.Program_Type__c!=null && objLeadRouting.Program_Type__c!='') {
                    lstProgramType = objLeadRouting.Program_Type__c.split(';');
                }
                if(objLeadRouting.Agency__c!=null && objLeadRouting.Agency__c!='') {
                    lstAgency = objLeadRouting.Agency__c.split(',');
                }
                if(lstProgram.size() == 0 && lstAgency.size() == 0 && lstProgramType.size() == 0) {
                    for (String program : lstProgramList) {
                        // to insert Default Program Keys
                        String key = objLeadRouting.From_Center__c  +'_'+program+'_null_null';
                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                        mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        
                        // to insert All the specializationTypes Keys
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        for(String programType : lstprogramTypes) {
                            String key2 = objLeadRouting.From_Center__c  +'_'+program+'_'+programType+'_null';
                            mapOfKeyVsCenterId.put(key2,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key2,objLeadRouting.From_IC__c);
                        }
                    }
                } else if(lstProgram.size() > 0 && lstAgency.size() == 0 && lstProgramType.size() == 0) {
                    for (String program : lstProgram) {
                        // to insert Default Program Keys
                        String key = objLeadRouting.From_Center__c  +'_'+program+'_null_null';
                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                        mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        
                        // to insert All the specializationTypes Keys
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        for(String programType : lstprogramTypes) {
                            String key2 = objLeadRouting.From_Center__c  +'_'+program+'_'+programType+'_null';
                            mapOfKeyVsCenterId.put(key2,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key2,objLeadRouting.From_IC__c);
                        }
                    }
                } else if(lstProgram.size() == 0 && lstAgency.size() == 0 && lstProgramType.size() > 0) {
                    for (String programType : lstProgramType) {
                        for(String programKey : mapOfChooseProgranVsProgramType.keySet()){
                            List<String> lPType = mapOfChooseProgranVsProgramType.get(programKey);
                            if(lPType.contains(programType)) {
                                String key3 = objLeadRouting.From_Center__c +'_'+programKey+'_'+programType+'_null';
                                mapOfKeyVsCenterId.put(key3,objLeadRouting.To_Center__c);
                                mapOfKeyVsCenterName.put(key3,objLeadRouting.From_IC__c);
                                break;
                            }
                        }
                    }
                } else if(lstProgram.size() > 0 && lstAgency.size() == 0 && lstProgramType.size() > 0) {
                    for (String program : lstProgram) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            Boolean checkExists = false;
                            List<String> lstSpecilaization = new List<String>();
                            for(Integer i=0; i<lstprogramTypes.size(); i++) {
                                if(lstProgramType.contains(String.valueof(lstprogramTypes[i]))) {
                                    checkExists = true;
                                    lstSpecilaization.add(String.valueof(lstprogramTypes[i]));
                                }
                            } 
                            if(checkExists) {
                                for(String programType : lstSpecilaization) {
                                    String key2 = objLeadRouting.From_Center__c +'_'+program+'_'+programType+'_null';
                                    mapOfKeyVsCenterId.put(key2,objLeadRouting.To_Center__c);
                                    mapOfKeyVsCenterName.put(key2,objLeadRouting.From_IC__c);
                                } 
                            } else {
                                for(String programType : lstprogramTypes) {
                                    String key2 = objLeadRouting.From_Center__c  +'_'+program+'_'+programType+'_null';
                                    mapOfKeyVsCenterId.put(key2,objLeadRouting.To_Center__c);
                                    mapOfKeyVsCenterName.put(key2,objLeadRouting.From_IC__c);
                                }
                            }
                        } else {
                            String key = objLeadRouting.From_Center__c  +'_'+program+'_null_null';
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        }
                    }
                } else if(lstProgram.size() == 0 && lstProgramType.size() == 0 && lstAgency.size() > 0) {
                    for (String program : lstProgramList) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            for(String programType : lstprogramTypes) {
                                for (String agency : lstAgency) {
                                    String key = objLeadRouting.From_Center__c  +'_'+ program +'_'+programType+'_' + agency.trim();
                                    mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                                    mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                                }
                            }
                        }
            
                        for (String agency : lstAgency) {
                            String key = objLeadRouting.From_Center__c  +'_'+ program +'_null_' + agency.trim();
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        }
                    }
                } else if(lstProgram.size() > 0 && lstProgramType.size() == 0 && lstAgency.size() > 0) {
                    for (String program : lstProgram) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            for(String programType : lstprogramTypes) {
                                for (String agency : lstAgency) {
                                    String key = objLeadRouting.From_Center__c  +'_'+ program +'_'+programType+'_' + agency.trim();
                                    mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                                    mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                                }
                            }
                        }
            
                        for (String agency : lstAgency) {
                            String key = objLeadRouting.From_Center__c +'_'+ program +'_null_' + agency.trim();
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                            mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                        }
                    }
                } else {
                    for (String program : lstProgram) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            Boolean checkExists = false;
                            List<String> lstSpecilaization = new List<String>();
                            for(Integer i=0; i<lstprogramTypes.size(); i++) {
                                if(lstProgramType.contains(String.valueof(lstprogramTypes[i]))) {
                                    checkExists = true;
                                    lstSpecilaization.add(String.valueof(lstprogramTypes[i]));
                                }
                            } 
                            if(checkExists) {
                                for(String programType : lstSpecilaization) {
                                    for (String agency : lstAgency) {
                                        String key = objLeadRouting.From_Center__c  +'_'+ program +'_'+programType+'_' + agency.trim();
                                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                                        mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                                    }
                                } 
                            } else {
                                Boolean checkLimit = false;
                                for(String programType : lstprogramTypes) {
                                    for (Integer i = 0; i < lstAgency.size(); i++) {
                                        String agency = lstAgency[i];
                                        System.debug('agency ==>'+agency);
                                        String key1 = objLeadRouting.From_Center__c  +'_'+ program +'_'+programType+'_' + agency.trim();
                                        mapOfKeyVsCenterId.put(key1,objLeadRouting.To_Center__c);
                                        mapOfKeyVsCenterName.put(key1,objLeadRouting.From_IC__c);
                                        
                                        // to insert default value as well
                                        if(!checkLimit) {
                                            String key2 = objLeadRouting.From_Center__c  +'_'+ program +'_null_' + agency.trim();
                                            mapOfKeyVsCenterId.put(key2,objLeadRouting.To_Center__c);
                                            mapOfKeyVsCenterName.put(key2,objLeadRouting.From_IC__c);
                                            if(i == (lstAgency.size()-1)) {
                                                checkLimit = true;
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            for (String agency : lstAgency) {
                                String key = objLeadRouting.From_Center__c  +'_'+ program +'_null_' + agency.trim();
                                mapOfKeyVsCenterId.put(key,objLeadRouting.To_Center__c);
                                mapOfKeyVsCenterName.put(key,objLeadRouting.From_IC__c);
                            }
                        }
                    }
                }           
                
            }
        }
                System.debug(mapOfKeyVsCenterId.size());
                String programType = objLead.Program_Type__c!=null && objLead.Program_Type__c!='' ? objLead.Program_Type__c : 'null';
                String agency = objLead.Agency__c!=null && objLead.Agency__c!='' ? objLead.Agency__c.trim() : 'Direct';
                String key = objLead.nm_InformationCenter__c  +'_'+ objLead.nm_ChooseaProgram__c +'_' + programType + '_'+ agency;
                String key2 = objLead.nm_InformationCenter__c  +'_'+ objLead.nm_ChooseaProgram__c +'_'+ programType +'_null';
                System.debug('Map Key for Lead Routing');
                System.debug(key);
                
                if(mapOfKeyVsCenterId.containsKey(key)) {
                    objLead.nm_StudentSelectedIC__c = mapOfKeyVsCenterName.get(key);
                    objLead.nm_InformationCenter__c = mapOfKeyVsCenterId.get(key);
                }
                
                    // for incase if the lead routing consists of any agencies.
                    else if(mapOfKeyVsCenterId.containsKey(key2)) {
                      objLead.nm_StudentSelectedIC__c = mapOfKeyVsCenterName.get(key2);
                    objLead.nm_InformationCenter__c = mapOfKeyVsCenterId.get(key2);
                    }
            }
        
    
    
    
        public Boolean validateFormOnServerSide() {
            ErrorMessage('','');
            List<String> errorMessage = new List<String>();
            Integer days = objLead.nm_DateOfBirth__c!=null ? objLead.nm_DateOfBirth__c.daysBetween(Date.Today()) : 1;
            Integer age = Integer.valueOf(days/365);
            List<String> lstOfAllowedProgram = new List<String>{'Certificate Programs','Diploma Programs','Professional Programs'};
            if(!(age >= 17 || (age >= 16 && objLead.nm_ChooseaProgram__c == 'Certificate Programs'))) {
                errorMessage.add('Date of Birth cannot be less than Eligible age years.');
            } else if(!lstOfAllowedProgram.contains(objLead.nm_ChooseaProgram__c)) {
                errorMessage.add('Invalid Details. Kindly contact your Authorized Enrolment Partner.');
            }
            System.debug('errorMessage---' + errorMessage);
            if (errorMessage.size() > 0) {
                ErrorMessage(String.join(errorMessage, '<br/>'), 'PopUpError');
                return true;
            }
            return false;
        }
    
        public void checkExistingLead() {
            String registrationNo = objLead.nm_RegistrationNo__c;
            String LeadEmail = objLead.Email;
            String LeadMobilePhone = objLead.MobilePhone;
            String RebornEmail = 'reborn_' + objLead.Email;
            String RebornPhone = objLead.MobilePhone + '0000';
            String LeadCenter = objLead.nm_InformationCenter__c;
            system.debug('LeadMobilePhone--->'+LeadMobilePhone);
            system.debug('LeadEmail--->'+LeadEmail);
            String LeadQuery = LeadQuery();
            String queryReLoginLead = LeadQuery + ' WHERE nm_RegistrationNo__c=:registrationNo AND isConverted=false LIMIT 1';
            String queryDuplicateLead = LeadQuery + ' WHERE (email=:LeadEmail OR MobilePhone=:LeadMobilePhone) AND LeadSource!=\'Partner\' AND IC_Name__c!=\'upGrad\' AND isConverted = false LIMIT 1';
            String queryRebornLead = LeadQuery + ' WHERE ((Email like \'reborn_%\' AND MobilePhone=:RebornPhone) OR email =: RebornEmail )AND IC_Name__c!=\'upGrad\' AND isConverted = false LIMIT 1';
    
            // String queryReLoginLead = getQueryAllFieldSql('Lead',' nm_RegistrationNo__c =: registrationNo and isConverted = false limit 1 ',null);
            // String queryDuplicateLead = getQueryAllFieldSql('Lead',' (email =: LeadEmail Or MobilePhone =: LeadMobilePhone) and isConverted = false limit 1',null);
    
            List<Lead> lstExistingLead = new List<Lead>();
            if (IsReLogin) {
                lstExistingLead = DataBase.query(queryReLoginLead);
            } else {
                List<Lead> lstRebornLead = DataBase.query(queryRebornLead);
                if (lstRebornLead != null && lstRebornLead.size() > 0) {
                    lstExistingLead = lstRebornLead;
                    objLead.Email = lstExistingLead[0].Email;
                    objLead.MobilePhone = lstExistingLead[0].MobilePhone;
                } else {
                    lstExistingLead = DataBase.query(queryDuplicateLead);
                    if (lstExistingLead.size() > 0) {
                        objLead.Email = lstExistingLead[0].Email;
                        objLead.MobilePhone = lstExistingLead[0].MobilePhone;
                    } else 
                    {
                        String queryDuplicateLead2 = LeadQuery + ' WHERE (email=:LeadEmail OR MobilePhone=:LeadMobilePhone) AND LeadSource=\'Partner\' AND IC_Name__c!=\'upGrad\' and nm_InformationCenter__c =:LeadCenter AND isConverted = false LIMIT 1';
                         System.debug('Partner Lead same AEP');
                        lstExistingLead = DataBase.query(queryDuplicateLead2);
                        if (lstExistingLead.size() > 0) {
                            objLead.Email = lstExistingLead[0].Email;
                            objLead.MobilePhone = lstExistingLead[0].MobilePhone;
                        }
                    }
                }
            }
            System.debug('lstExistingLead-->' + lstExistingLead);
    
            if (lstExistingLead != null && lstExistingLead.size() > 0) {
                String newLeadJsonString = JSON.serialize(objLead);
                System.debug('newLeadJsonString ---' + newLeadJsonString);
                Map<String, Object> mapOfNewLeadParameters = (Map<String, Object>) Json.deserializeUntyped(newLeadJsonString);
    
                for (Lead existingLead : lstExistingLead) {
                    String oldLeadJsonString = JSON.serialize(existingLead);
                    System.debug('oldLeadJsonString--' + oldLeadJsonString);
                    Map<String, Object> mapOfOldLeadParameters = (Map<String, Object>) Json.deserializeUntyped(oldLeadJsonString);
    
                    // allowed same student to registered for Master Program for upgrad and any other program at same time
                    if (
                        'Master Programs'.equalsIgnoreCase(existingLead.nm_ChooseaProgram__c) &&
                        String.isNotBlank(existingLead.Program_Type__c) &&
                        existingLead.Program_Type__c != objLead.Program_Type__c &&
                        'MBA (X)'.equalsIgnoreCase(existingLead.Program_Type__c) &&
                        existingLead.nm_InformationCenter__c != objLead.nm_InformationCenter__c
                    ) {
                        System.debug('choose program returned for upgrad');
                        return;
                    }
    
                    if (
                        existingLead.nm_InformationCenter__c != null &&
                        existingLead.nm_InformationCenter__r.Nm_Active__c &&
                        existingLead.Profile_Name__c != 'Jaro' &&
                        !existingLead.InactiveLead__c
                    ) {
                        System.debug('same ic selected');
                        objLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__c;
                    } else if (
                        (!existingLead.nm_InformationCenter__r.Nm_Active__c || existingLead.Profile_Name__c == 'Jaro') &&
                        existingLead.nm_InformationCenter__r.nm_LearningCenter__c != null
                    ) {
                        objLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__r.nm_LearningCenter__c;
                    } else if (existingLead.LeadSource == 'Partner') {
                        System.debug('partner selected');
                        return;
                    }
    
                    LeadId = existingLead.id;
                    IsReLogin = true;
                    Map<String, String> mapOfEditableFieldAPIVSDataType = getMapOfEditableVsDataTypeOfFieldForSObject('Lead');
                    if (!mapOfNewLeadParameters.isEmpty() && !mapOfOldLeadParameters.isEmpty()) {
                        for (String oldValueKey : mapOfOldLeadParameters.keySet()) {
                            if (!mapOfNewLeadParameters.containsKey(oldValueKey)) {
                                if (mapOfOldLeadParameters.get(oldValueKey) != null && mapOfEditableFieldAPIVSDataType.containsKey(oldValueKey.toLowerCase())) {
                                    System.debug('oldValueKey--' + oldValueKey + '----value---' + mapOfEditableFieldAPIVSDataType.get(oldValueKey.toLowerCase()));
                                    if ('DATETIME'.equalsIgnoreCase(mapOfEditableFieldAPIVSDataType.get(oldValueKey.toLowerCase()))) {
                                        objLead.put(oldValueKey, setStringToDateFormat(String.valueOf(mapOfOldLeadParameters.get(oldValueKey))));
                                    } else if (oldValueKey != 'Address') {
                                        objLead.put(oldValueKey, mapOfOldLeadParameters.get(oldValueKey));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
        private DateTime setStringToDateFormat(String myDate) {
            DateTime dt = DateTime.Valueof(myDate.replace('T', ' '));
            return dt;
        }
    
        public void getCountryStateCityFromPostalAPI() {
            System.debug('address choice-->' + objLead.Shipping_Address_Choice__c);
            System.debug('Zip code -->' + objLead.Zip_Postal_Code_Shipping__c);
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.SetEndPoint(System.Label.PostalCodeAPI + Postalcode);
            // request.setHeader('Accept','application/json');
            request.setMethod('GET');
    
            response = http.send(request);
            System.debug(response.getBody());
    
            String result = response.getBody();
            List<Object> lstOfApiResponse = (List<Object>) JSON.deserializeUntyped(result);
            System.debug('lstOfApiResponse ' + lstOfApiResponse);
            Map<String, Object> mapOfAPIResponse = (Map<String, Object>) lstOfApiResponse[0];
    
            if (mapOfAPIResponse.get('Status') == 'Success') {
                List<Object> postalOffice = (List<Object>) mapOfAPIResponse.get('PostOffice');
                Map<String, Object> mapOfAPiResponseParam = (Map<String, Object>) postalOffice[0];
                for (String key : mapOfAPiResponseParam.keySet()) {
                    System.debug('Key--->' + key);
                    System.debug('value-->' + mapOfAPiResponseParam.get(key));
    
                    if (objLead.Shipping_Address_Choice__c.equals('Shipping Address')) {
                        objLead.Country_Shipping__c = (String) mapOfAPiResponseParam.get('Country');
                        objLead.State_Province_Shipping__c = (String) mapOfAPiResponseParam.get('State');
                        objLead.Shipping_City__c = (String) mapOfAPiResponseParam.get('District');
                    } else if (objLead.Shipping_Address_Choice__c.equals('Permanent Address')) {
                        objLead.nm_Country_P__c = (string) mapOfAPiResponseParam.get('Country');
                        objLead.nm_StateProvince_P__c = (string) mapOfAPiResponseParam.get('State');
                        objLead.nm_City_P__c = (string) mapOfAPiResponseParam.get('District');
                    }
                }
                PostalCodeMessage = String.valueOf(mapOfAPIResponse.get('Status'));
            } else {
                PostalCodeMessage = String.valueOf(mapOfAPIResponse.get('Status'));
            }
        }

        public void getGeocodeFromZipCode() {
            system.debug('call From getGeocodeFromZipCode -->');
            System.debug('Postalcode -->' + Postalcode);
            System.debug('address choice-->' + objLead.Shipping_Address_Choice__c);
            System.debug('Zip code -->' + objLead.Zip_Postal_Code_Shipping__c);
            String Country = '';
            String State = '';
            String City = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            String URL = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + Postalcode +'&key=' + System.Label.GeocodeApIKey;
            request.SetEndPoint(URL);
            // request.setHeader('Accept','application/json');
            request.setMethod('GET');
            response = http.send(request);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(responseBody);
            String statusResponse = (String)responseBody.get('status');
            if(statusResponse == 'OK') {
                List<object> results = (List<Object>) responseBody.get('results');
                Map<String, Object> mapOfAddressResult = (Map<String, Object>) results[0];
                List<Object> address_components = (List<Object>) mapOfAddressResult.get('address_components');
                system.debug(address_components.size());
                Boolean isLocalNamePresent = false;
                Boolean isAdministerAreaLevel2Present = false;
                for(Object address : address_components) {
                    Map<String, Object> mapOfAddress = (Map<String, Object>) address;
                    List<Object> types = (List<Object>) mapOfAddress.get('types');
                    System.debug(types);
                    if(String.valueOf(types[0]) == 'locality') {
                        isLocalNamePresent = true;
                        City = (String)mapOfAddress.get('long_name');
                    }
                    if(String.valueOf(types[0]) == 'administrative_area_level_2' && !isLocalNamePresent ) {
                        isAdministerAreaLevel2Present = true;
                        City = (String)mapOfAddress.get('long_name');
                    }
                    if(String.valueOf(types[0]) == 'administrative_area_level_1') {
                        State = (String)mapOfAddress.get('long_name');
                        if(!isLocalNamePresent && !isAdministerAreaLevel2Present) {
                            City = (String)mapOfAddress.get('long_name');
                        }
                    }
                    if(String.valueOf(types[0]) == 'country') {
                        Country = (String)mapOfAddress.get('long_name');
                    }
                }
                if (objLead.Shipping_Address_Choice__c.equals('Shipping Address')) {
                    objLead.Country_Shipping__c = Country;
                    objLead.State_Province_Shipping__c = State;
                    objLead.Shipping_City__c = City;
                } else if (objLead.Shipping_Address_Choice__c.equals('Permanent Address')) {
                    objLead.nm_Country_P__c = Country;
                    objLead.nm_StateProvince_P__c = State;
                    objLead.nm_City_P__c = City;
                }
                PostalCodeMessage = 'Success';
            } else {
                PostalCodeMessage = 'Error';
            }

            System.debug('Country --> ' + Country);
            System.debug('State --> ' +  State);
            System.debug('City --> ' +  City);
        }
    
        // public void getCountryStateCityFromPostalAPI(){
        //     try {
        //         System.debug('address choice-->'+objLead.Shipping_Address_Choice__c);
        //         System.debug('Zip code -->'+objLead.Zip_Postal_Code_Shipping__c);
        //         String uri = System.Label.PostalCodeAPI_VII + 'api-key='+System.Label.Gov_API_Key+'&filters[pincode]='+Postalcode;
        //         Http http = new Http();
        //         HttpRequest request = new HttpRequest();
        //         HttpResponse response = new HttpResponse();
        //         request.SetEndPoint(uri);
        //         request.setHeader('Content-Type','application/json');
        //         request.setHeader('Accept','application/json');
        //         request.setMethod('GET');
    
        //         response = http.send(request);
        //         System.debug(response.getBody());
    
        //         String result = response.getBody();
        //         Map<String, Object> mapOfAPIResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
        //         Decimal totalCount = (Decimal)mapOfAPIResponse.get('total');
        //         if(totalCount > 0){
        //             List<Object> postalOffice = (List<Object>)mapOfAPIResponse.get('records');
        //             Map<String,Object> mapOfAPiResponseParam = (Map<String,Object>)postalOffice[0];
        //             for(String key :mapOfAPiResponseParam.keySet()){
        //                 System.debug('Key--->'+key);
        //                 System.debug('value-->'+mapOfAPiResponseParam.get(key));
        //                 String stateName = (string)mapOfAPiResponseParam.get('statename');
        //                 stateName = stateName.toLowerCase();
        //                 stateName = stateName.capitalize();
        //                 System.debug(stateName);
    
        //                 if(objLead.Shipping_Address_Choice__c.equals('Shipping Address')){
        //                     objLead.Country_Shipping__c = 'India';
        //                     objLead.State_Province_Shipping__c = stateName;
        //                     objLead.Shipping_City__c =(String) mapOfAPiResponseParam.get('districtname');
        //                 }else if(objLead.Shipping_Address_Choice__c.equals('Permanent Address')) {
        //                     objLead.nm_Country_P__c = 'India';
        //                     objLead.nm_StateProvince_P__c = stateName;
        //                     objLead.nm_City_P__c = (string)mapOfAPiResponseParam.get('districtname');
        //                 }
        //             }
        //             PostalCodeMessage = 'Success';
        //         }else{
        //             PostalCodeMessage = 'Error';
        //         }
        //     } catch (Exception error) {
        //         System.debug('Picode Error ==>'+error.getMessage());
        //         PostalCodeMessage = 'Error';
        //     }
        // }
    
        // public void getLateralStudentDetailsAPI(){
        //     try {
        //         System.debug('Student Lateral Number -->'+objLead.Student_Number_Lateral__c);
        //         String jsonBody = '{"sapid":"'+objLead.Student_Number_Lateral__c+'"}';
        //         Http http = new Http();
        //         HttpRequest request = new HttpRequest();
        //         HttpResponse response = new HttpResponse();
        //         request.SetEndPoint(System.Label.getPassedYearMonthBySapid);
        //         request.setHeader('Content-Type','application/json');
        //         request.setMethod('POST');
        //         request.setBody(jsonBody);
        //         response = http.send(request);
        //         System.debug(response.getBody());
        //         String result = response.getBody();
        //         Map<String, Object> mapOfAPIResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
        //         Boolean containsKey = mapOfAPIResponse.containsKey('status');
        //         if(containsKey && mapOfAPIResponse.get('status') == 'Success'){
        //             String lateralNo = objLead.Student_Number_Lateral__c;
        //             String queryClosedStudentProgramString = getQueryAllFieldSql('Account','nm_StudentStatus__c = \'Confirmed\' and nm_StudentNo__c!=null and nm_StudentNo__c=:lateralNo','nm_Program__r.nm_ProgramName__c,nm_Program__r.nm_Type__c,nm_Program__r.Name,nm_Program__r.nm_TotalSemesters__c');
        //             List<Account> lstClosedStudentProgram = DataBase.query(queryClosedStudentProgramString);
    
        //             if(lstClosedStudentProgram.size() > 0 && ((objLead.nm_ChooseaProgram__c.startsWith('Diploma') && lstClosedStudentProgram[0].nm_ChooseaProgram__c == 'Diploma Programs') ||
        //             ((objLead.nm_ChooseaProgram__c.startsWith('Diploma') || objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs')) && lstClosedStudentProgram[0].nm_ChooseaProgram__c == 'Certificate Programs' && lstClosedStudentProgram[0].nm_Program__r.Name == 'CBM' && lstClosedStudentProgram[0].BatchStartD__c > date.newinstance(2019,01,01))
        //             || (objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') && lstClosedStudentProgram[0].nm_ChooseaProgram__c == 'Diploma Programs' && lstClosedStudentProgram[0].nm_Program__r.Name != 'DGM') ||
        //             (objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') && (lstClosedStudentProgram[0].nm_ChooseaProgram__c == 'Post Graduate Diploma Programs' || lstClosedStudentProgram[0].nm_Program__r.Name == 'DGM'))
        //             ))
        //             {
        //                 objLead.Is_Lateral__c = true;
        //             }
        //             objLead.Year_Of_Passing_Lateral__c = (String)mapOfAPIResponse.get('yearOfPassing');
        //             objLead.Month_Of_Passing_Lateral__c = (String)mapOfAPIResponse.get('monthOfPassing');
        //             objLead.Course_Name_Lateral__c = (String)mapOfAPIResponse.get('program');
        //             ErrorMessage('','');
        //             if(objLead.Is_Lateral__c && (objLead.Student_Number_Lateral__c!=null && objLead.Student_Number_Lateral__c!='') && lstClosedStudentProgram.size() > 0 && !lstClosedStudentProgram[0].Pass_Out__c) {
        //                 // To mark the flag passout if lateral selected.
        //                 markPassout(objLead.Student_Number_Lateral__c,lstClosedStudentProgram[0]);
        //             }
        //         }else{
        //             objLead.Student_Number_Lateral__c = '';
        //             objLead.Year_Of_Passing_Lateral__c = '';
        //             objLead.Month_Of_Passing_Lateral__c = '';
        //             objLead.Course_Name_Lateral__c = '';
        //             objLead.Is_Lateral__c = false;
    
        //             if(containsKey && mapOfAPIResponse.get('status') =='Failed') {
        //                 ErrorMessage('Student has not cleared the program.','PopUpError');
        //             }else if(containsKey && mapOfAPIResponse.get('status') == 'Invalid') {
        //                 ErrorMessage('Invalid Student Number.','PopUpError');
        //             }else {
        //                 ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
        //             }
        //         }
        //     } catch (Exception e) {
        //         System.debug(e.getMessage());
        //         ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
        //     }
        // }
    
        public void getLateralStudentDetailsAPI() {
            try {
                System.debug('Student Lateral Number -->' + objLead.Student_Number_Lateral__c);
                String lateralNo = objLead.Student_Number_Lateral__c;
                String queryClosedStudentProgramString = getQueryAllFieldSql(
                    'Account',
                    'Student_ID__c!=null and Student_ID__c=:lateralNo LIMIT 1',
                    'nm_Program__r.nm_ProgramName__c,nm_Program__r.nm_Type__c,nm_Program__r.Name,nm_Program__r.nm_TotalSemesters__c'
                );
                List<Account> lstClosedStudentProgram = DataBase.query(queryClosedStudentProgramString);
                Account objAcc = lstClosedStudentProgram.size() > 0 ? lstClosedStudentProgram[0] : null;
                Boolean passout = false;
                String yearOfPassing = '';
                String monthOfPassing = '';
                String program = '';
                String Status = '';
                if (objAcc != null && objAcc.Pass_Out__c) {
                    passout = objAcc.Pass_Out__c;
                    program = objAcc.Program_Name__c;
                    yearOfPassing = objAcc.Passing_Year__c;
                    monthOfPassing = objAcc.Passing_Month__c;
                } else {
                    String jsonBody = '{"sapid":"' + lateralNo + '"}';
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    request.SetEndPoint(System.Label.getPassedYearMonthBySapid);
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    request.setBody(jsonBody);
                    response = http.send(request);
                    System.debug(response.getBody());
                    String result = response.getBody();
                    Map<String, Object> mapOfAPIResponse = (Map<String, Object>) JSON.deserializeUntyped(result);
                    Boolean containsKey = mapOfAPIResponse.containsKey('status');
                    Status = containsKey ? (String) mapOfAPIResponse.get('status') : '';
                    if (containsKey && Status == 'Success') {
                        passout = true;
                        yearOfPassing = (String) mapOfAPIResponse.get('yearOfPassing');
                        monthOfPassing = (String) mapOfAPIResponse.get('monthOfPassing');
                        program = (String) mapOfAPIResponse.get('program');
                    } else {
                        passout = false;
                    }
                }
    
                if (passout) {
                      if (
                        (objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objAcc.nm_ChooseaProgram__c == 'Diploma Programs') ||
                        ((objLead.nm_ChooseaProgram__c.startsWith('Diploma') || objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs')) &&
                        objAcc.nm_ChooseaProgram__c == 'Certificate Programs' &&
                        objAcc.nm_Program__r.Name == 'CBM' &&
                        objAcc.BatchStartD__c > date.newinstance(2019, 1, 1)) ||
                        (objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') &&
                        objAcc.nm_ChooseaProgram__c == 'Diploma Programs' 
                         ) 
                        
                    )  {
                        objLead.Is_Lateral__c = true;
                    }
    
                    objLead.Year_Of_Passing_Lateral__c = yearOfPassing;
                    objLead.Month_Of_Passing_Lateral__c = monthOfPassing;
                    objLead.Course_Name_Lateral__c = program;
                    ErrorMessage('', '');
                    if (objLead.Is_Lateral__c && (objLead.Student_Number_Lateral__c != null && objLead.Student_Number_Lateral__c != '') && !objAcc.Pass_Out__c) {
                        // To mark the flag passout if lateral selected.
                        markPassout(objLead.Student_Number_Lateral__c, objAcc);
                    }
                } else {
                    objLead.Student_Number_Lateral__c = '';
                    objLead.Year_Of_Passing_Lateral__c = '';
                    objLead.Month_Of_Passing_Lateral__c = '';
                    objLead.Course_Name_Lateral__c = '';
                    objLead.Is_Lateral__c = false;
    
                    if (Status == 'Failed') {
                        ErrorMessage('Student has not cleared the program.', 'PopUpError');
                    } else if (Status == 'Invalid') {
                        ErrorMessage('Invalid Student Number.', 'PopUpError');
                    } else {
                        ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
                    }
                }
            } catch (Exception e) {
                System.debug(e.getMessage());
                ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
            }
        }
    
        public void CopyAddress() {
            if (CopyPermanantAddressFromTo == 'SameAsShipping') {
                objLead.nm_HouseNumber_P__c = objLead.House_No_Name_Shipping__c;
                objLead.nm_LocalityName_P__c = objLead.Locality_Name_Shipping__c;
                objLead.nm_Street_P__c = objLead.Shipping_Street__c;
                objLead.nm_StateProvince_P__c = objLead.State_Province_Shipping__c;
                objLead.nm_Country_P__c = objLead.Country_Shipping__c;
                objLead.nm_City_P__c = objLead.Shipping_City__c;
                objLead.nm_PostalCode_P__c = objLead.Zip_Postal_Code_Shipping__c;
    
                objLead.nm_HouseNumber__c = objLead.House_No_Name_Shipping__c;
                objLead.nm_LocalityName__c = objLead.Locality_Name_Shipping__c;
                objLead.Street = objLead.Shipping_Street__c;
                objLead.State = objLead.State_Province_Shipping__c;
                objLead.Country = objLead.Country_Shipping__c;
                objLead.City = objLead.Shipping_City__c;
                objLead.PostalCode = objLead.Zip_Postal_Code_Shipping__c;
            } else if (CopyPermanantAddressFromTo == 'NewAddress') {
                //  Permament Address to Billing Address
                objLead.nm_HouseNumber__c = objLead.nm_HouseNumber_P__c;
                objLead.nm_LocalityName__c = objLead.nm_LocalityName_P__c;
                objLead.Street = objLead.nm_Street_P__c;
                objLead.State = objLead.nm_StateProvince_P__c;
                objLead.Country = objLead.nm_Country_P__c;
                objLead.City = objLead.nm_City_P__c;
                objLead.PostalCode = objLead.nm_PostalCode_P__c;
            }
        }
    
        public String isDuplicateAccountExist(){
            Map<String, List<String>> mapOfProgramVsLstProgram = new Map<String, List<String>>();
            mapOfProgramVsLstProgram.put('Master Programs', new List<String>{'Certificate Programs', 'Diploma Programs', 'Professional Programs'});
            mapOfProgramVsLstProgram.put('MBA (Distance) Programs', new List<String>{'Certificate Programs', 'Diploma Programs', 'Professional Programs'});
            mapOfProgramVsLstProgram.put('Bachelor Programs', new List<String>{'Certificate Programs', 'Diploma Programs', 'Professional Programs'});
            mapOfProgramVsLstProgram.put('Certificate Programs', new List<String>{'Certificate Programs', 'Diploma Programs', 'Professional Programs', 'Master Programs', 'MBA (Distance) Programs', 'Bachelor Programs'});
            mapOfProgramVsLstProgram.put('Diploma Programs', new List<String>{'Certificate Programs', 'Diploma Programs', 'Professional Programs', 'Master Programs', 'MBA (Distance) Programs', 'Bachelor Programs'});
            mapOfProgramVsLstProgram.put('Professional Programs', new List<String>{'Certificate Programs', 'Diploma Programs', 'Professional Programs', 'Master Programs', 'MBA (Distance) Programs', 'Bachelor Programs'});
            system.debug('isDupChecked-->'+isDupChecked);
            if(isDupChecked==null || isDupChecked=='' || isDupChecked=='Duplicate' ) {
                List<Account> lstAccount = new List<Account>();
                    lstAccount = [
                    SELECT id, nm_ChooseaProgram__c FROM Account WHERE
                        (PersonEmail = :objLead.Email
                        OR PersonMobilePhone = :objLead.MobilePhone)
                    // AND nm_ChooseaProgram__c = :chooseProgram
                        AND Pass_Out__c = FALSE
                        AND Active_account__c = TRUE
                        LIMIT 1
                    ];
                if ( lstAccount.size() > 0) {
                    List<Lead> objL = [SELECT Id,DualProgram__c FROM Lead WHERE Id=: LeadId LIMIT 1];
                    if(objL.size() > 0 && objL[0].DualProgram__c) {
                        String accountChooseProgram = lstAccount[0].nm_ChooseaProgram__c;
                        String leadChooseProgram = objLead.nm_ChooseaProgram__c;
                        List<String> lstProgramAllowed = mapOfProgramVsLstProgram.get(accountChooseProgram);
                        if(lstProgramAllowed.contains(leadChooseProgram)) {
                            lstAccount = new List<Account>();
                        }
                    }
                }
    
                // String chooseProgram = objLead.nm_ChooseaProgram__c;
                // List<Account> lstAccount = new List<Account>();
                // if('Certificate Programs'.equalsIgnoreCase(chooseProgram))
                // {
                //     lstAccount = [SELECT id FROM Account WHERE (PersonEmail=:objLead.Email OR PersonMobilePhone=:objLead.MobilePhone)
                //     AND nm_ChooseaProgram__c=:chooseProgram and  (Pass_Out__c = false and Active_account__c = true) LIMIT 1];
                // }else
                // {
                //     lstAccount = [SELECT id FROM Account WHERE (PersonEmail=:objLead.Email OR PersonMobilePhone=:objLead.MobilePhone)
                //     AND nm_ChooseaProgram__c!='Certificate Programs' and  (Pass_Out__c = false and Active_account__c = true) LIMIT 1];
                // }            
               
                if(lstAccount.size() > 0) {
                    isDupChecked = 'Duplicate';
                    return isDupChecked;
                } else{
                    isDupChecked = 'Non-Duplicate';
                    return isDupChecked;
                }
            }else {
                isDupChecked = 'Non-Duplicate';
                return isDupChecked;
            }
        }
    
        public void markPassout(String studentNumber, Account objAccount) {
            Integer sems = Integer.valueOf(objAccount.nm_Program__r.nm_TotalSemesters__c);
            System.debug('sems ==>' + sems);
            switch on sems {
                when 1 {
                    objAccount.Sem_1__c = true;
                }
                when 2 {
                    objAccount.Sem_1__c = true;
                    objAccount.Sem_2__c = true;
                }
                when 3 {
                    objAccount.Sem_1__c = true;
                    objAccount.Sem_2__c = true;
                    objAccount.Sem_3__c = true;
                }
                when 4 {
                    objAccount.Sem_1__c = true;
                    objAccount.Sem_2__c = true;
                    objAccount.Sem_3__c = true;
                    objAccount.Sem_4__c = true;
                }
            }
            System.debug(objAccount);
            objAccount.Pass_Out__c = true;
            update objAccount;
        }
    
        //check if shipping address is same as permanent address
        public void checkShippingSamePermanent() {
            String HouseNo = objLead.nm_HouseNumber_P__c;
            String PostalCode = objLead.nm_PostalCode_P__c;
            if (
                (houseNo != null &&
                PostalCode != null) &&
                houseNo.equalsIgnoreCase(objLead.House_No_Name_Shipping__c) &&
                PostalCode.equalsIgnoreCase(objLead.Zip_Postal_Code_Shipping__c)
            ) {
                CopyPermanantAddressFromTo = 'SameAsShipping';
            } else {
                CopyPermanantAddressFromTo = 'NewAddress';
            }
        }
    
        public List<SelectOption> getElegibilityCriteriaList() {
            List<SelectOption> lstECOptions = new List<SelectOption>();
            Map<String, String> mapOfEligibilityVsWorkExp = new Map<String, String>();
            Map<String, Boolean> mapOfEligibilityVsRequiredAcademic = new Map<String, Boolean>();
            Map<String, Decimal> mapOfEligibilityVsRequiredAcademicPercentage = new Map<String, Decimal>();
    
            String chooseProgram = objLead.nm_ChooseaProgram__c;
            String selectedProgram = objLead.nm_Program__c;
    
            lstECOptions.add(new SelectOption('', 'Choose Eligiblity Criteria'));
            String queryEligibilityCriteria = '';
            system.debug(chooseProgram);
            String progamSpecalisation = selectedProgram!=null && mapOfProgramIdAndProgram.containsKey(selectedProgram) ? mapOfProgramIdAndProgram.get(selectedProgram).Specialisation__c : null;
            
            system.debug('eligiblitylist.size() -->  ' + eligiblitylist.size());
            if (eligiblitylist.size() == 0) {
                queryEligibilityCriteria = getQueryAllFieldSql(
                    'nm_EligiblityCriteria__c',
                    ' nm_Program__c =:chooseProgram AND Program_Type__c = :progamSpecalisation AND Is_Active__c=true',
                    null
                );
            } else {
                progamSpecalisation = String.isBlank(progamSpecalisation) && String.isNotBlank(org_formConfig.Specialisation__c)  ? org_formConfig.Specialisation__c :  progamSpecalisation;
                for (String ellist : eligiblitylist) {
                    system.debug('ellist --> ' + ellist);
                }
                queryEligibilityCriteria = getQueryAllFieldSql(
                    'nm_EligiblityCriteria__c',
                    ' Name IN:eligiblitylist and nm_Program__c =:chooseProgram AND Program_Type__c = :progamSpecalisation AND Is_Active__c=true',
                    null
                );
            }
    
            system.debug('chooseProgram ---> '+ chooseProgram);
            system.debug('progamSpecalisation ---> '+ progamSpecalisation);
            system.debug('queryEligibilityCriteria ---> '+ queryEligibilityCriteria);
            List<nm_EligiblityCriteria__c> lstElegibility = DataBase.query(queryEligibilityCriteria);
            if (lstElegibility.size() > 0) {
                for (nm_EligiblityCriteria__c objEligibility : lstElegibility) {
                    lstECOptions.add(new SelectOption(objEligibility.id, objEligibility.nm_EligiblityCriteria__c));
                    mapOfEligibilityVsWorkExp.put(objEligibility.id, String.valueOf(objEligibility.Experience_Required_In_Year__c));
                    mapOfEligibilityVsRequiredAcademic.put(objEligibility.id + '-HSC', objEligibility.HSC_Re__c);
                    mapOfEligibilityVsRequiredAcademic.put(objEligibility.id + '-Diploma', objEligibility.Diploma_Required__c);
                    mapOfEligibilityVsRequiredAcademic.put(objEligibility.id + '-Graduation', objEligibility.Graduation_Required__c);
                    mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id + '-HSC', objEligibility.HSC_Percentage__c);
                    mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id + '-Diploma', objEligibility.Diploma_Percentage__c);
                    mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id + '-Graduation', objEligibility.Graduation_Percentage__c);
                }
    
                if (!mapOfEligibilityVsWorkExp.isEmpty()) {
                    jsonMapOfEligibilityVsWorkExp = JSON.serialize(mapOfEligibilityVsWorkExp);
                }
    
                if (!mapOfEligibilityVsRequiredAcademic.isEmpty()) {
                    jsonMapOfEligibilityVsRequiredAcademic = JSON.serialize(mapOfEligibilityVsRequiredAcademic);
                    System.debug('jsonMapOfEligibilityVsRequiredAcademic--' + jsonMapOfEligibilityVsRequiredAcademic);
                }
    
                if (!mapOfEligibilityVsRequiredAcademicPercentage.isEmpty()) {
                    jsonMapOfEligibilityVsRequiredAcademicPercentage = JSON.serialize(mapOfEligibilityVsRequiredAcademicPercentage);
                }
            }
            return lstECOptions;
        }
    
        public void CallValidate() {
            if (String.isNotBlank(objLead.nm_EligiblityCriteria__c)) {
                yearsEligibility = Integer.valueOf(
                    [SELECT Experience_Required_In_Year__c FROM nm_EligiblityCriteria__c WHERE id = :objLead.nm_EligiblityCriteria__c].Experience_Required_In_Year__c
                );
            } else {
                yearsEligibility = 0;
            }
    
            if (yearsEligibility > 0) {
                ErrorMessage('For this eligibility criteria its mandatory to submit Work experience proof of ' + yearsEligibility + ' years  .', 'PopUpError');
            } else {
                ErrorMessage('', '');
            }
        }
    
        public void showShippingPopup() {
            //ErrorMessage('Your study kit,ID card and Fee Receipt will be shipped on the below Address','PopUpError');
            if (objLead.Country_Shipping__c == 'Other' || objLead.State_Province_Shipping__c == 'Other') {
                ErrorMessage('Please change your Shipping address, Study Kit cannot be delivered to any other location outside India', 'PopUpAddressMsg');
            } else if (objLead.Shipping_Street__c != null && objLead.Locality_Name_Shipping__c == null) {
                ErrorMessage(
                    'Shipping Address: ' +
                    ' ' +
                    objLead.House_No_Name_Shipping__c +
                    ', ' +
                    objLead.Shipping_Street__c +
                    ', ' +
                    objLead.Shipping_City__c +
                    ', ' +
                    objLead.State_Province_Shipping__c +
                    ', ' +
                    objLead.Zip_Postal_Code_Shipping__c +
                    ', ' +
                    objLead.Country_Shipping__c,
                    'PopUpAddressMsg'
                );
            } else if (objLead.Locality_Name_Shipping__c != null && objLead.Shipping_Street__c == null) {
                ErrorMessage(
                    'Shipping Address: ' +
                    ' ' +
                    objLead.House_No_Name_Shipping__c +
                    ', ' +
                    objLead.Locality_Name_Shipping__c +
                    ', ' +
                    objLead.Shipping_City__c +
                    ', ' +
                    objLead.State_Province_Shipping__c +
                    ', ' +
                    objLead.Zip_Postal_Code_Shipping__c +
                    ', ' +
                    objLead.Country_Shipping__c,
                    'PopUpAddressMsg'
                );
            } else if (objLead.Locality_Name_Shipping__c == null && objLead.Shipping_Street__c == null) {
                ErrorMessage(
                    'Shipping Address: ' +
                    ' ' +
                    objLead.House_No_Name_Shipping__c +
                    ', ' +
                    objLead.Shipping_City__c +
                    ', ' +
                    objLead.State_Province_Shipping__c +
                    ', ' +
                    objLead.Zip_Postal_Code_Shipping__c +
                    ', ' +
                    objLead.Country_Shipping__c,
                    'PopUpAddressMsg'
                );
            } else {
                ErrorMessage(
                    'Shipping Address: ' +
                    ' ' +
                    objLead.House_No_Name_Shipping__c +
                    ', ' +
                    objLead.Locality_Name_Shipping__c +
                    ', ' +
                    objLead.Shipping_Street__c +
                    ', ' +
                    objLead.Shipping_City__c +
                    ', ' +
                    objLead.State_Province_Shipping__c +
                    ', ' +
                    objLead.Zip_Postal_Code_Shipping__c +
                    ', ' +
                    objLead.Country_Shipping__c,
                    'PopUpAddressMsg'
                );
            }
        }
    
        /*------- Method to Redirect to payment -----*/
        public pageReference MakePayment() {
            if (LeadId != null && LeadId != '') {
                String sitebaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                String fullURL = sitebaseURL + System.Label.GoToAdmissionPayment_Url + 'id=' + LeadId;
                if (icValue == 'true') {
                fullURL = fullURL + '&IC=true';
                }
                System.debug('siteURL ==>' + fullURL);
                PageReference pgURL = new PageReference(fullURL); //payOpt=3
                pgURL.setRedirect(true);
                return pgURL;
            }
            return null;
        }
        /*---- End Method to Redirect to payment ---*/
    
        public Boolean SaveWorkExp() {
            try {
                if (String.isNotBlank(objLead.nm_EligiblityCriteria__c)) {
                    yearsEligibility = Integer.valueOf(
                        [SELECT Experience_Required_In_Year__c FROM nm_EligiblityCriteria__c WHERE id = :objLead.nm_EligiblityCriteria__c]
                        .Experience_Required_In_Year__c
                    );
                } else {
                    yearsEligibility = 0;
                }
                System.debug('lstWorkExperience ->' + lstWorkExperience.size());
                System.debug('lstWorkExperience 1 ->' + lstWorkExperience[0]);
    
                if (yearsEligibility > 0 && (lstWorkExperience.size() < 1 || lstWorkExperience[0].id == null) && String.isNotBlank(objLead.Reason__c)) {
                    return false;
                }
                Integer monthDiff = 0;
                List<nm_WorkExperience__c> lstWEToUpsert = new List<nm_WorkExperience__c>();
                if (lstWorkExperience != null && lstWorkExperience.size() > 0 && String.isBlank(objLead.Reason__c)) {
                    System.debug('lstWorkExperience--' + lstWorkExperience);
                    for (nm_WorkExperience__c objWE : lstWorkExperience) {
                        objWE.nm_Lead__c = LeadId;
                        System.debug('objWE.Name==>' + objWE.Name);
                        objWE.Id = objWE.Name != null && mapOfNameVsId.containsKey(objWE.Name) ? mapOfNameVsId.get(objWE.Name) : null;
                        if ((objWE.nm_StartDate__c != null && objWE.nm_EndDate__c != null) || (objWE.nm_StartDate__c != null && objWE.Currently_Working_Here__c)) {
                            System.debug('objWE.Industry__c ==>' + objWE.Industry__c);
                            System.debug('objWE.Id ==>' + objWE.Id);
                            lstWEToUpsert.add(objWE);

                            Date a = objWE.nm_StartDate__c;
                            Date b = Date.today();
                            if(objWE.Currently_Working_Here__c == false) {
                                b = objWE.nm_EndDate__c;
                            }
                            monthDiff += a.monthsBetween(b);
                            if (b.day() > a.day()){
                                monthDiff++;
                            }
                        }
                    }
    
                    //update workexpereince.
                    if (lstWEToUpsert.size() > 0) {
                        //to delete removed workexpereince.
                        if (RemovedWorkExperience.size() > 0) {
                            delete [SELECT Id FROM nm_WorkExperience__c WHERE Id IN :RemovedWorkExperience];
                        }
                        System.debug('monthDiff--'+monthDiff);
                        if(monthDiff > 0) {
                            Integer months = math.MOD(monthDiff, 12);
                            Integer year = monthDiff/12;
                            System.debug(year + ' year ' +  months + 'Months');
                            objLead.Total_Work_Experience__c = year + ' year ' +  months + 'Months';
                            // Integer score = year*5;
                            // Integer maximumScore = Integer.valueOf(System.label.workExperienceScore);
                            // if(score > maximumScore) {
                            //     score = maximumScore;
                            // }
                            // objLead.Work_exp_Score__c = score;
                        }
                        upsert lstWEToUpsert;
                    }
                } else {
                    for (nm_WorkExperience__c objWE : lstWorkExperience) {
                        String RemoveExperienceId = objWE.Name != null && mapOfNameVsId.containsKey(objWE.Name) ? mapOfNameVsId.get(objWE.Name) : null;
                        if (RemoveExperienceId != '' && RemoveExperienceId != null) {
                            RemovedWorkExperience.add(RemoveExperienceId);
                        }
                    }
                    if (RemovedWorkExperience.size() > 0) {
                        delete [SELECT Id FROM nm_WorkExperience__c WHERE Id IN :RemovedWorkExperience];
                    }
                }
                return true;
            } catch (Exception e) {
                ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
                return false;
            }
        }
    
        // Method to add Experience
        public void AddExperience() {
            nm_WorkExperience__c objWE = new nm_WorkExperience__c();
            objWE.id = null;
            lstWorkExperience.add(objWE);
        }
    
        public void RemoveExperience() {
            Integer strRowNo = lstWorkExperience.size();
            if (strRowNo != null && strRowNo > 1) {
                Integer IndexVal = integer.valueOf(strRowNo) - 1;
                String WEXPName = lstWorkExperience[IndexVal].Name;
                System.debug('WEXPName ==>' + WEXPName);
                String RemoveExperienceId = String.isNotBlank(WEXPName) && mapOfNameVsId.containsKey(WEXPName) ? mapOfNameVsId.get(WEXPName) : null;
                if (RemoveExperienceId != '' && RemoveExperienceId != null) {
                    RemovedWorkExperience.add(RemoveExperienceId);
                }
                lstWorkExperience.remove(IndexVal);
            }
        }
    
        public list<SelectOption> getGraduationDegreeMode() {
            list<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', 'Graduation Degree Mode'));
            options.add(new SelectOption('Full Time', 'Full Time'));
            options.add(new SelectOption('Part Time', 'Part Time'));
            options.add(new SelectOption('Distance Learning', 'Distance Learning'));
            options.add(new SelectOption('Correspondence', 'Correspondence'));
            return options;
        }
    
        public List<SelectOption> getLateralOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', 'Do you want to opt for Lateral Admission?'));
            options.add(new SelectOption('true', 'Yes'));
            options.add(new SelectOption('false', 'No'));
            return options;
        }
    
        // public List<SelectOption> getUniversityList() {
        //     StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'UniversityNameJS' LIMIT 1];
        //     String body = sr.Body.toString();
        //     List<Object> lstResult = (List<Object>) JSON.deserializeuntyped(body);
        //     List<SelectOption> option = new List<SelectOption>();
        //     option.add(new SelectOption('','Choose University'));
    
        //     for(Object result: lstresult){
        //         Map<String,Object> mapOfResponseParameters = (Map<String, Object>)result;
        //         option.add(new SelectOption(String.valueOf(mapOfResponseParameters.get('name')),String.valueOf(mapOfResponseParameters.get('name'))));
        //     }
    
        //     return option;
        // }
    
        public List<SelectOption> getWorkExpTimeList() {
            List<SelectOption> options = new List<SelectOption>();
            Integer yearsEligibility = 0;
            if (String.isNotBlank(objLead.nm_EligiblityCriteria__c)) {
                yearsEligibility = Integer.valueOf(
                [SELECT Experience_Required_In_Year__c FROM nm_EligiblityCriteria__c WHERE id = :objLead.nm_EligiblityCriteria__c]
                .Experience_Required_In_Year__c
                );
            }
            if ((yearsEligibility == null || yearsEligibility == 0)) {
                options.add(new SelectOption('', 'Total Work Experience'));
                options.add(new SelectOption('0-1 Years', '0-1 Years'));
                options.add(new SelectOption('1-3 Years', '1-3 Years'));
                options.add(new SelectOption('3-5 Years', '3-5 Years'));
                options.add(new SelectOption('5-10 Years', '5-10 Years'));
                options.add(new SelectOption('10+ Years', '10+ Years'));
            } else if (yearsEligibility > 0) {
                options.add(new SelectOption('', 'Total Work Experience'));
                options.add(new SelectOption('1-3 Years', '1-3 Years'));
                options.add(new SelectOption('3-5 Years', '3-5 Years'));
                options.add(new SelectOption('5-10 Years', '5-10 Years'));
                options.add(new SelectOption('10+ Years', '10+ Years'));
            }
            return options;
        }
    
        //For domicile dropdown list
        public List<SelectOption> getDomicileList() {
            List<SelectOption> option = new List<SelectOption>();
            option.add(new SelectOption('', '---None--'));
            option.add(new SelectOption('India', 'India'));
            option.add(new SelectOption('Africa', 'Africa'));
            option.add(new SelectOption('America', 'America'));
            option.add(new SelectOption('Argentina', 'Argentina'));
            option.add(new SelectOption('Australia', 'Australia'));
            option.add(new SelectOption('Austria', 'Austria'));
            option.add(new SelectOption('Bangladesh', 'Bangladesh'));
            option.add(new SelectOption('Belgian', 'Belgian'));
            option.add(new SelectOption('Brazili', 'Brazili'));
            option.add(new SelectOption('British', 'British'));
            option.add(new SelectOption('Cambodia', 'Cambodia'));
            option.add(new SelectOption('Chile', 'Chile'));
            option.add(new SelectOption('China', 'China'));
            option.add(new SelectOption('Colombo', 'Colombo'));
            option.add(new SelectOption('Croatia', 'Croatia'));
            option.add(new SelectOption('Czech', 'Czech'));
            option.add(new SelectOption('Danish', 'Danish'));
            option.add(new SelectOption('Dutch', 'Dutch'));
            option.add(new SelectOption('French', 'French'));
            option.add(new SelectOption('German', 'German'));
            option.add(new SelectOption('Greek', 'Greek'));
            option.add(new SelectOption('Hungary', 'Hungary'));
            option.add(new SelectOption('Icelandic', 'Icelandic'));
            option.add(new SelectOption('Indonesia', 'Indonesia'));
            option.add(new SelectOption('Iran', 'Iran'));
            option.add(new SelectOption('Iraqi', 'Iraqi'));
            option.add(new SelectOption('Irish', 'Irish'));
            option.add(new SelectOption('Israeli', 'Israeli'));
            option.add(new SelectOption('Jamaica', 'Jamaica'));
            option.add(new SelectOption('Japanese', 'Japanese'));
            option.add(new SelectOption('Mexico', 'Mexico'));
            option.add(new SelectOption('Morocco', 'Morocco'));
            option.add(new SelectOption('Nepalese', 'Nepalese'));
            option.add(new SelectOption('Norwegian', 'Norwegian'));
            option.add(new SelectOption('Peruvian', 'Peruvian'));
            option.add(new SelectOption('Philippine', 'Philippine'));
            option.add(new SelectOption('Polish', 'Polish'));
            option.add(new SelectOption('Portuguese', 'Portuguese'));
            option.add(new SelectOption('Rumanian', 'Rumanian'));
            option.add(new SelectOption('Russian', 'Russian'));
            option.add(new SelectOption('Saudi, Saudi Arabia', 'Saudi, Saudi Arabia'));
            option.add(new SelectOption('Scottish', 'Scottish'));
            option.add(new SelectOption('Serbia', 'Serbia'));
            option.add(new SelectOption('Slovak', 'Slovak'));
            option.add(new SelectOption('Swedish', 'Swedish'));
            option.add(new SelectOption('Swiss', 'Swiss'));
            option.add(new SelectOption('Thai', 'Thai'));
            option.add(new SelectOption('Tunisia', 'Tunisia'));
            option.add(new SelectOption('Turkish', 'Turkish'));
            option.add(new SelectOption('Vietnamese', 'Vietnamese'));
            option.add(new SelectOption('Welsh', 'Welsh'));
            option.add(new SelectOption('Yugoslav', 'Yugoslav'));
            return option;
        }
    
        /**
         * @description
         * @author Balakrishnan | 18/3/2019
         * @return String of Lead Query
         */
        public String LeadQuery() {
            String LeadQueryField =
                'SELECT id,InactiveLead__c,nm_ChooseaProgram__c,nm_Program__r.Name,nm_Program__r.Specialisation__c,StudentLogin__c,nm_InformationCenter__r.Allow_Executive__c,nm_InformationCenter__r.Address__c,' +
                'Status,LeadSource,nm_IPForLead__c,nm_PaymentStatus__c,Partial_form_filled__c,Program_Type__c,nm_RegistrationNo__c,Email,MobilePhone,isConverted,' +
                'nm_InformationCenter__c,nm_StudentSelectedIC__c,Student_Number_Lateral__c,Year_Of_Passing_Lateral__c,Month_Of_Passing_Lateral__c,Course_Name_Lateral__c,' +
                'nm_HouseNumber_P__c,nm_LocalityName_P__c,nm_Street_P__c,nm_StateProvince_P__c,nm_Country_P__c,nm_City_P__c,nm_PostalCode_P__c,nm_Session__c,nm_Year__c,' +
                'House_No_Name_Shipping__c,Locality_Name_Shipping__c,nm_SelfLearningMaterial__c,Shipping_Street__c,State_Province_Shipping__c,Country_Shipping__c,' +
                'Shipping_City__c,Zip_Postal_Code_Shipping__c,nm_HouseNumber__c,nm_LocalityName__c,Street,State,Country,City,PostalCode,Profile_Name__c,' +
                'Shipping_Address_Choice__c,Address,nm_EligiblityCriteria__c,Salutation,FirstName,nm_MiddleName__c,LastName,nm_DateOfBirth__c,Father_Salutation__c,Father_First_Name__c,' +
                'Father_Last_Name__c,Mother_Salutation__c,Mother_First_Name__c,Mother_Last_Name__c,nm_Gender__c,nm_MaritalStatus__c,nm_SpouseName__c,nm_BloodGroup__c,' +
                'nm_Category__c,nm_OtherCategory__c,nm_Domicile__c,nm_Nationality__c,AadharCardNumber__c,Pancard_no__c,nm_Passport__c,nm_STDCode__c,Phone,nm_SecondryEmail__c,' +
                'IC_Name__c,Specialization_Type__c,nm_Program__c,Are_you_from_Defence__c,nm_ServiceNumber__c,Mother_Name__c,nm_Mother_Tongue__c,nm_Other_Mother_Tongue__c,' +
                'Relationship__c,nm_DateofCommission__c,Armed_Service__c,Rank__c,nm_NameofBoard__c,nm_10thClassStateBoardName__c,nm_10thPercentage__c,nm_YearofCompletion__c,' +
                'nm_NameofSchool__c,nm_Class12OrDiploma__c,nm_NameofBoard12__c,nm_12thClassStateBoardName__c,nm_12thPercentage__c,nm_YearofCompletion12__c,nm_Stream__c,' +
                'nm_NameofSchool12__c,nm_DiplomaSchoolCollegeUniversityname__c,Result_Diploma__c,nm_DiplomaYearOfCompletion__c,nm_DiplomaName__c,nm_StreamDiploma__c,nm_DurationOfDiploma__c,' +
                'nm_BachelorsDegreeName__c,nm_Specialization__c,nm_University_Type__c,nm_BachelorsDegreePercentage__c,nm_NameofUniversity__c,nm_Other_University_Name__c,nm_GraduationDegreeMode__c,' +
                'nm_YearofCollegeCompletion__c,nm_NameOfCollege__c,Name_of_Program1__c,Name_of_Program2__c,Name_of_Program3__c,Name_of_College1__c,Name_of_College2__c,' +
                'Name_of_College3__c,Name_of_University1__c,Name_of_University2__c,Name_of_University3__c,Year_of_Passing1__c,Year_of_Passing2__c,Year_of_Passing3__c,Percentage1__c,Percentage2__c,' +
                'Percentage3__c,Duration_of_Program1__c,Duration_of_Program2__c,Duration_of_Program3__c,Graduation_Degree_Mode1__c,Graduation_Degree_Mode2__c,Graduation_Degree_Mode3__c,' +
                'Total_Work_Experience__c,Reason__c,nm_Other_Reason__c,Father_Name__c,nm_ProgramName__c,nm_Eligibility_Criteria_Ref__c,nmm_BatchName__c,nm_InformationCenter__r.Nm_Active__c,' +
                'Father_s_Email_Id__c,Father_s_Mobile_number__c,Mother_s_Email_Id__c,Mother_s_Mobile_number__c,Differently_abled__c,Your_disability__c,nm_SSC_Rating_Type__c,SSC_Marks_obtained__c,SSC_Marks_Out_Off__c,' +
                'SSC_Examination_State__c,HSC_status__c,HSC_Marks_obtained__c,HSC_Marks_Out_Off__c,HSC_Examination_State__c,nm_HSC_Rating_Type__c,DualProgram__c,' +
                'Diploma_Examination_State__c,Diploma_Marks_obtained__c,Diploma_Marks_Out_Off__c,Diploma_Percentage__c,LinkedIn_URL__c,' +
                'nm_InformationCenter__r.nm_LearningCenter__c,nm_WorkExperience__c,Form_Id__c,nm_StudentImageUrl__c,Is_Lateral__c,nm_SelectedIC__c FROM Lead';
    
            return LeadQueryField;
        }
    
        public Boolean calenderCheckForCorporate(String BatchNamePara) {
            Date ExpireDate = Date.valueOf(System.Label.Conneqt_Expired_date);
            String BatchName = System.Label.Conneqt_Batch;
    
            if (ExpireDate != null && BatchName != null) {
                if (ExpireDate >= Date.today() && BatchNamePara.equalsIgnoreCase(BatchName)) {
                return true;
                }
            }
            return false;
        }

        /**
        * @description 
        * @author @BK | 04-11-2023 
        * @return String 
        **/
        public String getCookie() {
            String leadId = null;
            Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
            String SessionToken = sessionId!=null ? sessionId.getValue() : null;
            if(String.isNotBlank(SessionToken)) {
                Blob key = Blob.valueOf(System.Label.NgasceSessionKey);
                Blob decrypted = Crypto.decryptWithManagedIV('AES256', key, EncodingUtil.base64Decode(SessionToken));
                leadId = decrypted.toString();
            }
            return leadId;
        }

        /**
        * @description 
        * @author @BK | 04-11-2023 
        * @param leadId 
        **/
        public void setCookie(String leadId) {
            Blob key = Blob.valueOf(System.Label.NgasceSessionKey);
            Blob data = Blob.valueOf(leadId);
            Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);

            String sessionToken = EncodingUtil.base64Encode(encrypted);
            Cookie sessionId = ApexPages.currentPage().getCookies().get('JSESSIONID');
            sessionId = new Cookie('JSESSIONID',sessionToken,null,3600,true);
            ApexPages.currentPage().setCookies(new Cookie[]{sessionId});
        }

        public class OTPFields {
            public String optStatus {get;set;}
            public String Otp {get;set;}
            public String resendOtp {get;set;}
            public String OtpCode {get;set;}
            public Long otpSentTime {get;set;}
            public Boolean skipOTP {get;set;}
            public String OtpMode {get;set;}
            public String alertMsg {get;set;}
            public String modalToShow {get;set;}
    
            public OTPFields() {
                this.optStatus = '';
                this.Otp = '';
                this.resendOtp = 'false';
                this.OtpCode = '';
                this.otpSentTime = 0;
                this.skipOTP = false;
                this.OtpMode = 'E';
                this.alertMsg = '';
                this.modalToShow = '';
            }
        }

        // /**
        // * @description 
        // * @author @BK | 11-04-2022 
        // **/
        // public void ValidateStudentImage() {
        //     List<Lead> lstLead = [SELECT id,nm_StudentImageUrl__c FROM Lead WHERE id=:LeadId LIMIT 1];
        //     imageURL = lstLead[0].nm_StudentImageUrl__c;
        // }
        
        // /**
        // * @description 
        // * @author @BK | 11-04-2022 
        // * @return Boolean 
        // **/
        // public Boolean validateImageUrl() {
        //     ValidateStudentImage();
        //     return String.isBlank(imageURL) ? true : false;
        //     // return false;
        // }
    }