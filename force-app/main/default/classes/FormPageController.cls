/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08--04--2025
 * @last modified by  : @Ravi
**/
public without sharing class FormPageController {

    public Id leadId;
    public Id accountId;
    public Boolean isEditFormConfirmation;
    public String sectionName;
    public String reloadPageBlock ;

    public Boolean passout = false;
    public String yearOfPassing = '';
    public String monthOfPassing = '';
    public String program = '';
    public String Status ='';
    // public boolean IsvalidateDEBId  = false;

    public list<nm_WorkExperience__c> lstWorkExperience {get;set;}
    // public String studentImage {get;set;}
    public List<String> lateraleditablefields {get; set;}
    public Map<String,Id> mapOfNameVsId {get;set;}
    public Lead objLead {get;set;}
    public Account objAccount {get;set;}
    public OTPFields objOTP {get; set;}
    public LateralDataAssigmentWrapper assigmentWrapper {get; set;}
     
    public Boolean isRecordQueried {get;set;}
    public String studentNumber {get;set;}
    public Boolean isLateral {get;set;}
    public Boolean isVerified { get; set; }
    public String copyPermanantAddressFromTo {get;set;}
    public String programNameForSpecialization {get; set;}
    public String jsonMapOfEligibilityVsWorkExp {get;set;}
    public String jsonMapOfEligibilityVsRequiredAcademic {get;set;}
    public String jsonMapOfEligibilityVsRequiredAcademicPercentage {get;set;}
    public String jsonMapOfSpecialisationVsId {get;set;}
    public String jsonMapOfEligibilityVsMaster {get;set;}
    public String isDupChecked {get;set;}
    public String postalCodeMessage {get;set;}
    public String postalCode {get;set;}
    public Map<String,Boolean> mapOfEligibilityVsRequiredAcademic {get;set;}
    public Map<String,nm_Program__c> mapOfIdVsProgram {get;set;}
    public String alumniMessage {get;set;}
    public String lateralMessage {get;set;}
    public String OtpMode {get;set;}
    public Boolean isLateralData {get;set;}
    public String sectionPageBlock {get;set;}
    public String isConfirm {get;set;}
    public String errorMsg {get;set;}
    public Integer yearsEligibility { get; set; }
    public Set<Id> removedWorkExperience {get;set;}
    public DEBDetails debDetailObject {get;set;}

    public List<SelectOption> getDomicile {get;set;}
    public List<SelectOption> getProgramsList {get;set;}
    public List<SelectOption> globalStateValue {get;set;}
    public List<SelectOption> globalCountryValue {get;set;}
    public List<SelectOption> getWorkExpTimeList{get;set;}
    public List<SelectOption> getProgramTypePicklistValues { get; set; }
    public list<SelectOption> getElegibilityCriteriaList{get;set;}
    public List<SelectOption> getLateralOptions {get;set;}
    public List<SelectOption> getSpecializationList {get; set;}
    public List<SelectOption> getGraduationDegreeModeMBA {get; set;}
    public List<SelectOption> getGlobalLocalityOptionValues {get;set;}

    public FormPageController() {
        assigmentWrapper=new LateralDataAssigmentWrapper();
        objLead = new Lead();
        objOTP = new OTPFields();
        mapOfNameVsId = new Map<String,Id>();
        lstWorkExperience = new list<nm_WorkExperience__c>();
        lateraleditablefields = new List<String>();
        copyPermanantAddressFromTo = '';
        jsonMapOfEligibilityVsWorkExp = null;
        jsonMapOfEligibilityVsRequiredAcademic = null;
        jsonMapOfEligibilityVsRequiredAcademicPercentage = null;
        jsonMapOfSpecialisationVsId = null;
        jsonMapOfEligibilityVsMaster = null;
        isDupChecked = null;
        isVerified=false;
        isLateral =false;
        isLateralData = false;
        postalCodeMessage = '';
        postalCode = '';
        alumniMessage = '';
        isRecordQueried = false;
        yearsEligibility = 0;
        removedWorkExperience = new Set<Id>();
        mapOfIdVsProgram = new Map<String,nm_Program__c>();
        debDetailObject = new DEBDetails();
        // studentImage = null;
    }


    /**
    * @description Id getter Setter
    * @author @BK | 19-07-2024 
    * @return Id 
    **/
    public Id getLeadId() {
    return this.leadId;
  }

    /**
    * @description Id getter Setter
    * @author @BK | 19-07-2024 
    * @param Id leadId 
    **/
    public void setLeadId(Id leadId) {
        System.debug('setObjectId --> ' );
        this.leadId = leadId;
        if(this.reloadPageBlock == 'ReviewForm'){
            isRecordQueried=false;
            lstWorkExperience.clear();

        }
        if(String.isNotBlank(this.leadId) && !isRecordQueried) {
            queryLeadData(this.leadId);
            System.debug('setObjectId --> ' );
        }
    }

    public Id getAccountId() {
        return this.accountId;
    }


    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @param Id accountId 
    **/
    public void setAccountId(Id accountId) {
        System.debug('setObjectId --> ' );
        this.accountId = accountId;
        if(String.isNotBlank(this.accountId) && !isRecordQueried) {
            queryAccountData(this.accountId);
            System.debug('setObjectId --> ' );
        }
    }
     
    /**
    * @description 
    * @author @Ravi | 10-08-2024 
    * @return String 
    **/
    public String getReloadPageBlock() {
        return this.reloadPageBlock;
    }
    
    /**
    * @description 
    * @author @Ravi | 10-08-2024 
    * @param reloadPageBlock 
    **/
    public void setReloadPageBlock(String reloadPageBlock) {
        this.reloadPageBlock = reloadPageBlock;
    }
    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return Boolean 
    **/
    public Boolean getIsEditFormConfirmation() {
    return this.isEditFormConfirmation;
  }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @param Boolean isEditFormConfirmation 
    **/
    public void setIsEditFormConfirmation(Boolean isEditFormConfirmation) {
        this.isEditFormConfirmation = isEditFormConfirmation;
  }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return String 
    **/
    public String getSectionName() {
        return this.sectionName;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @param String sectionName 
    **/
    public void setSectionName(String sectionName) {
        this.sectionName = sectionName;
        if(String.isBlank(this.sectionName)) {
            this.sectionName = 'form1';
        }
    }

    /**
    * @description 
    * @author @BK | 23-07-2024 
    * @param Id accountRecordId 
    **/
    public void queryAccountData(Id accountRecordId) {
        String accountQuery = accountQuery();
        accountQuery = accountQuery+' WHERE id=:accountRecordId LIMIT 1';
        List<Account> lstAccount = DataBase.query(accountQuery);
        System.debug(lstAccount[0]);
        if(lstAccount.size() > 0){ 
            objAccount = lstAccount[0];
            //getProgramsList();
        }
        isRecordQueried = true;
    }

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    * @return PageReference 
    **/
    public PageReference verifyLateralStudentOTP() { 
        try {
            OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
            System.debug('Input OTP: ' + objOTP.Otp + ' Sent OTP: ' + objOTP.OtpCode);
            objOTP = objVerifyHandler.verifyOTP(objOTP);
            if (objOTP.isSuccess) {         
                Boolean isAccountValid = queryLateralAccountRecord(objOTP.recordId);
                if (isAccountValid) {
                    PageReference pg = new PageReference('/EnrollmentForm?nav=form');
                    pg.setRedirect(true);
                    isVerified = true;
                    return pg;
                } else {
                    isVerified=false;
                    return null;
                }
            } else {
                lateralMessage = 'OTP verification failed. Please try again.';
                isVerified = false;
                System.debug('OTP Verification Failed.');
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            lateralMessage = 'Internal error occurred. Kindly contact our Support Team.';
            return null;
        }
    }
    

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    * @param accountRecordId 
    * @return Boolean 
    **/
    public Boolean queryLateralAccountRecord( Id accountRecordId) {
        String accountQuery = accountQuery();
        accountQuery = accountQuery+' WHERE id=:accountRecordId LIMIT 1';
        List<Account> lstAccount = DataBase.query(accountQuery);
        System.debug(lstAccount[0]);
            if(lstAccount.size() > 0) {
                Account accountRecord = lstAccount[0]; 
                    objLead.Student_Number_Lateral__c = accountRecord.Student_ID__c;
                    objLead.Year_Of_Passing_Lateral__c = yearOfPassing;
                    objLead.Month_Of_Passing_Lateral__c = monthOfPassing;
                    objLead.Course_Name_Lateral__c = program;
                    objLead.Is_Lateral__c =true;
                    assigmentWrapper.leadIdRecordId=leadId;
                    assigmentWrapper.updateLeadData(accountRecord,leadId,objLead);
                    assigmentWrapper.addLateralStudentWkExperience(accountRecord.Id);   
                    assigmentWrapper.populateApporovedDefaultDocs(accountRecord.Id);
                    isLateralData = true;
                    return true; 
            } else{
                lateralMessage = 'No match found for entered Student Number.';
                return false;
            }
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @param Id leadRecordId 
    **/
    public void queryLeadData(Id leadRecordId) { 
        System.debug('=======>leadData');
        String leadQuery = leadQuery();
        leadQuery = leadQuery+' WHERE id=:leadRecordId LIMIT 1';
        List<Lead> lstLead = DataBase.query(leadQuery);
        System.debug(lstLead[0]);
        //to get the List of work experience from leadid.
        if(lstLead.size() > 0){
            objLead = lstLead[0].clone();
            checkLateralDetails();
            // studentImage = objLead.nm_StudentImageUrl__c;
            List<nm_WorkExperience__c> lstWorkExperienceRecord = [SELECT id,nm_Student__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c,Experience_Level__c,Name,RecordId__c FROM nm_WorkExperience__c WHERE nm_Lead__c=:leadRecordId ORDER BY nm_StartDate__c ASC];
            System.debug('---------------------lstWorkExperience---------------');
            System.debug(lstWorkExperienceRecord);
            resetWXPList(lstWorkExperienceRecord);
            if(lstWorkExperience.isEmpty()){
                addExperience();
            }
            checkShippingSamePermanent();
            fetchDEBDetails();
        }
        getProgramTypePicklistValues();
        getProgramsList();
        getElegibilityCriteriaList();
        getGlobalStateAndCountryValues();
        isRecordQueried = true;
    }

    /**
    * @description 
    * @author @Ravi | 08--03--2025 
    * @param objectName 
    * @param fieldName 
    * @param lateralCoureName 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getProgramTypePicklistValues() {
        List<SelectOption> options = new List<SelectOption>();
        String lateralCoureName=objLead.Course_Name_Lateral__c;
        options.add(new SelectOption('', '--None--')); 
        Schema.DescribeFieldResult programTypeList = Lead.nm_ChooseaProgram__c.getDescribe();
        List<Schema.PicklistEntry> result = programTypeList.getPicklistValues();
        Set<String> allowedProgramsForDiplomandDistanceProgram = new Set<String>{'MBA (Online) Programs'};
        Set<String> allowedProgramsForCBM =new Set<String>{'Diploma Programs', 'MBA (Online) Programs'};
        Set<String> allowedProgramsForCBAorCGM =new Set<String>{'Bachelor Programs'};
        try {
            for (Schema.PicklistEntry entry : result) {
                if(objLead.Is_Lateral__c) {
                    System.debug('lateralCourse ==>'+lateralCoureName);
                    if (lateralCoureName.startsWith('Diploma') || lateralCoureName.startsWith('MBA') ) {
                        if (allowedProgramsForDiplomandDistanceProgram.contains(entry.getValue())) {
                            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
                        }
                    } else if(lateralCoureName =='Certificate in Business Management'){
                        if (allowedProgramsForCBM.contains(entry.getValue())) {
                            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
                        }
                    } else if(lateralCoureName =='Certificate in Business Administration' || lateralCoureName == 'Certificate in General Management') {
                        if (allowedProgramsForCBAorCGM.contains(entry.getValue())) {
                            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
                        }
                    } else {
                        // If condition doesn't match, add all options as usual
                        options.add(new SelectOption(entry.getValue(), entry.getLabel()));
                    }
                } else {
                        options.add(new SelectOption(entry.getValue(), entry.getLabel()));
                }
            }
            System.debug('Options==>'+options);
            return options;
        } catch (Exception error) {
            System.debug('Line No===>'+error.getLineNumber());
            System.debug('message==>'+error.getMessage());
            return null;
        }
       
    }
    /**
    * @description 
    * @author @BK | 19-07-2024 
    **/
    public void checkShippingSamePermanent() {   
        String houseNo = objLead.nm_HouseNumber_P__c;
        String postalCodeForPAddress = objLead.nm_PostalCode_P__c;
        if((String.isNotBlank(houseNo) && String.isNotBlank(postalCodeForPAddress)) && houseNo.equalsIgnoreCase(objLead.House_No_Name_Shipping__c) && postalCodeForPAddress.equalsIgnoreCase(objLead.Zip_Postal_Code_Shipping__c) ){
            copyPermanantAddressFromTo = 'SameAsShipping';
        }else{
            copyPermanantAddressFromTo = 'NewAddress';
        }
    }

    /**
    * @description 
    * @author @Ravi | 07--03--2025 
    **/
    public void checkLateralDetails(){
        if(objLead.Is_Non_Lateral__c == 'No' && objLead.Is_Lateral__c){
            isLateralData=true;
           System.debug('isLateralData Data : '+ isLateralData);
       }
       if(objLead.Is_Non_Lateral__c == 'No' && String.isNotBlank(objLead.Lateral_Editable_set__c)) {
          String fields = objLead.Lateral_Editable_set__c;
          String[] fieldArray = fields.split(',');
          for(String fieldName : fieldArray){
             lateraleditablefields.add(fieldName);   
            }
         } 
    }

    /**
    * @description 
    * @author @BK | 05-09-2024 
    **/
    public void fetchDEBDetails() {
        String debQuery = DynamicQueryBuilder.getQueryAllFieldSql('DEB_Detail__c', 'Is_Active__c=true AND Lead__c=:leadId ORDER BY CreatedDate DESC', '');
        List<DEB_Detail__c> lstDEBs = DataBase.query(debQuery);
        System.debug(lstDEBs);
        if(!lstDEBs.isEmpty()) {
            System.debug('Called on re-render');
            debDetailObject.dateOfBirthDEB = lstDEBs[0].Date_of_Birth__c;
            debDetailObject.debUniqueId = lstDEBs[0].DEB_Unique_ID__c;
            // debDetailObject.abcUniqueId = lstDEBs[0].ABCID__c;
            debDetailObject.isDEBActive = true;
            debDetailObject.isDOBMatched = debDetailObject.dateOfBirthDEB == objLead.nm_DateOfBirth__c ? true : false;
            debDetailObject.isDebMatched = debDetailObject.debUniqueId == objLead.DEBID__c ? true : false;
            // debDetailObject.isABCMatched = debDetailObject.abcUniqueId == objLead.ABCID__c ? true : false;
        }
    }

    /**
    * @description 
    * @author @BK | 06-08-2024 
    * @param List<nm_WorkExperience__c> lstWorkExperienceRecord 
    **/
    public void resetWXPList(List<nm_WorkExperience__c> lstWorkExperienceRecord) {
        for (nm_WorkExperience__c objWp : lstWorkExperienceRecord) {
            nm_WorkExperience__c objWpClone = objWp;
            System.debug('resetWXPList objWpClone'+ objWpClone.id);
             objWpClone.id = null;
            System.debug('resetWXPList objWpClone to check null'+ objWpClone.id);
            lstWorkExperience.add(objWpClone);
            System.debug('lstWorkExperience to check ID'+ lstWorkExperience);
            System.debug('objWE.Name----'+objWp.Name);
            System.debug('objWp.RecordId__c--'+objWp.RecordId__c);
            System.debug('lstWorkExperience to check Put'+ mapOfNameVsId.put(objWp.Name,objWp.RecordId__c));
           
            System.debug('mapOfNameVsId==>');
            System.debug(mapOfNameVsId);
        }
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getProgramsList(){
        List<SelectOption> lstProgramsOptions = new List<SelectOption>();
        Map<String,Id> MapOfSpecialisationVsId = new Map<String,Id>();
        String chooseProgram = objLead.nm_ChooseaProgram__c;
        String specalization = objLead.Program_Type__c;
        
        List<nm_Program__c> lstActiveProgram = new List<nm_Program__c>();
        system.debug('programNameForSpecialization ---> ' + specalization);
        if(chooseProgram == 'Master Programs' || chooseProgram == 'Bachelor Programs' || chooseProgram == 'MBA (Online) Programs') {
            lstActiveProgram = [SELECT id,nm_ProgramName__c, Form_Specialisation__c,Specialisation__c FROM nm_Program__c WHERE nm_Type__c=:chooseProgram AND Specialisation__c=:specalization AND nmIsActive__c=true ORDER BY Name ASC];
            lstProgramsOptions.add(new SelectOption('', 'Choose Specialization'));
        } 
        else {
            chooseProgram = String.isBlank(chooseProgram) ? 'Certificate Programs' : chooseProgram;
            lstActiveProgram = [SELECT id,nm_ProgramName__c,Specialisation__c,Form_Specialisation__c FROM nm_Program__c WHERE nm_Type__c=:chooseProgram AND nmIsActive__c=true ORDER BY Name ASC];
            lstProgramsOptions.add(new SelectOption('', 'Choose Program'));
        }
        System.debug('lstActiveProgram--'+lstActiveProgram);
        if(lstActiveProgram.size() > 0){
            for(nm_Program__c objProgram : lstActiveProgram){
                List<String> lstPrograms = new List<String>{'Master Programs','Bachelor Programs','Diploma Programs','MBA (Online) Programs'};
                if((lstPrograms.contains(chooseProgram)) && objProgram.Form_Specialisation__c!=null) {
                    String prgName = objProgram.Form_Specialisation__c!=null ? objProgram.Form_Specialisation__c : objProgram.nm_ProgramName__c;
                    lstProgramsOptions.add(new SelectOption(objProgram.id, prgName));
                } else {
                    lstProgramsOptions.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
                }
                mapOfIdVsProgram.put(objProgram.id,objProgram);
                if(objProgram.Specialisation__c != null) {
                    MapOfSpecialisationVsId.put(objProgram.Specialisation__c,objProgram.Id);
                }
            }

            if(MapOfSpecialisationVsId.size() > 0) {
                jsonMapOfSpecialisationVsId = JSON.serialize(MapOfSpecialisationVsId);
            }
        }
        return lstProgramsOptions;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getSpecializationList(){
        Map<String,String> mapOfSpecialisationForMaster = new Map<String,String>{
            'MBA (WX)' => 'Master of Business Administration (Working Executive)'
        };
        Map<String,String> mapOfSpecialisationForBachelor = new Map<String,String>{
            'BCom' => 'Bachelor of Commerce',
            'BBA' => 'Bachelor of Business Administration'
        };
        Map<String,String> mapOfSpecialisationForMBAOnline = new Map<String,String>{
            'MBA' => 'Master of Business Administration'
        };

        List<SelectOption> lstProgramsOptions = new List<SelectOption>();
        lstProgramsOptions.add(new SelectOption('', 'Choose Program'));
        if(objLead.nm_ChooseaProgram__c == 'Master Programs') {
            for (String spec : mapOfSpecialisationForMaster.keySet()) {
                lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForMaster.get(spec)));
            }
        } else if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs') {
            for (String spec : mapOfSpecialisationForBachelor.keySet()) {
                if(objLead.Is_Lateral__c){
                    if(objLead.Course_Name_Lateral__c =='Certificate in Business Administration' && spec=='BBA' ) {
                        lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForBachelor.get(spec))); 
                    } else if (objLead.Course_Name_Lateral__c =='Certificate in General Management' && spec=='BCom') {
                        lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForBachelor.get(spec))); 
                    }
                } else {
                        lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForBachelor.get(spec)));
                }   
            }
        }  else if(objLead.nm_ChooseaProgram__c == 'MBA (Online) Programs') {
            for (String spec : mapOfSpecialisationForMBAOnline.keySet()) {
                lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForMBAOnline.get(spec)));
            }
        }
        return lstProgramsOptions;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    **/
    public void nextPage(){
        errorMsg = '';
        System.debug('objLead---'+objLead);
        if(validateFormOnServerSide()) {
            return;
        }
        try{
            copyAddress();
            isDupChecked = isDuplicateAccountExist();
            if(isDupChecked=='Duplicate') {
                System.debug('isDuplicateAccountExist--->');
               errorMsg = 'Duplicate record found, Kindly contact our Support Team.';
                return;
            } 
            // objLead.nm_StudentImageUrl__c = studentImage;
            objLead.Partial_form_filled__c = true;
            objLead.StudentLogin__c=false;
            updateLead();
            System.debug('Before ==>'+sectionPageBlock);
        }catch(Exception e){
            System.debug('Error-->' + String.valueof(e));
            if(string.valueof(e).contains('duplicate value found') && string.valueof(e).contains('nm_CheckforDuplicacy__c')){
                errorMsg = 'Mobile no or EmailId already exist. Please enter valid mobile no. or EmailId.';
            } else {
                errorMsg = 'Internal error occured. Kindly contact our Support Team.';
            }
        }
        System.debug('After ==>'+sectionPageBlock);
        return;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    **/
    public void goToConfirmationForm() {
        try{
             copyAddress();
            System.debug('GoToConfirmationForm ---> ');
            System.debug('Lead permanent Address===>'+objLead.nm_HouseNumber_P__c+'==='+objLead.nm_Street_P__c+'==='+objLead.nm_City_P__c);
            //to save work expereience
            Boolean saveWorkExp = saveWorkExp();
            Boolean calculateAcademicScore = calculateAcademicScore();

            objLead.nm_PaymentStatus__c='';
            // objLead.nm_StudentImageUrl__c = studentImage;
            if(objLead.Status!='Registration Fee Paid' && objLead.Status!='Admission Fee Paid'){
                objLead.Status ='Registration Form Filled';
            }

            if(saveWorkExp && calculateAcademicScore){
                objLead.id = null;
                return;
            }
            updateLead();
        }catch(Exception e){
            System.debug('error Msg on Submit 1==>'+e.getMessage());
            System.debug('error Msg on Submit 2==>'+e.getLineNumber());
            objLead.id = null;
            errorMsg = 'Internal error occured. Kindly contact our Support Team.';
            return;
        }
    }

    /**
    * @description 
    * @author @BK | 9-08-2024 
    **/
    public void updateLead() {
        System.debug('Lead permanent Address'+objLead.nm_HouseNumber_P__c+'==='+objLead.nm_Street_P__c);
        objLead.id = leadId;
        update objLead;
        objLead.id = null;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return Boolean 
    **/
    public Boolean validateFormOnServerSide(){
        List<String> errorMessage = new List<String>();
        Integer days = objLead.nm_DateOfBirth__c!=null ? objLead.nm_DateOfBirth__c.daysBetween(Date.Today()) : 1;
        Integer age = Integer.valueOf(days/365);
        if(!(age >= 16 || (age >= 16 && objLead.nm_ChooseaProgram__c == 'Bachelor Programs'))) {
            errorMessage.add('Date of Birth cannot be less than Eligible age years.');
        }
        System.debug('errorMessage---'+errorMessage);
        if(errorMessage.size() > 0){
            errorMsg = String.join(errorMessage,'<br/>');
            return true;
        }
        return false;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return String 
    **/
    public String isDuplicateAccountExist(){
        System.debug('isDupChecked-->'+isDupChecked);
        if(String.isNotBlank(isDupChecked) || isDupChecked=='Duplicate') {
            String chooseProgram = objLead.nm_ChooseaProgram__c;
            List<Account> lstAccount = new List<Account>();
            if('Certificate Programs'.equalsIgnoreCase(chooseProgram)) {
                lstAccount = [SELECT id FROM Account WHERE (PersonEmail=:objLead.Email OR PersonMobilePhone=:objLead.MobilePhone)
                AND nm_ChooseaProgram__c=:chooseProgram AND (Pass_Out__c=false AND Active_account__c=TRUE) LIMIT 1];
            } else {
                lstAccount = [SELECT id FROM Account WHERE (PersonEmail=:objLead.Email OR PersonMobilePhone=:objLead.MobilePhone)
                AND nm_ChooseaProgram__c!='Certificate Programs' AND (Pass_Out__c=false AND Active_account__c=TRUE) LIMIT 1];
            }            
           
            if(lstAccount.size() > 0) {
               isDupChecked = 'Duplicate';
            } else{
                isDupChecked = 'Non-Duplicate';
            }
        } else {
            isDupChecked = 'Non-Duplicate';
        }
        return isDupChecked;
    } 

    /**
    * @description 
    * @author @BK | 09-17-2024 
    **/
    public void verifyDEBID() {
        debDetailObject.isAPICalled = true;
        if(String.isBlank(objLead.DEBID__c)) {
            return;
        }
        try {
            // to set the request
            DEBVerificationHandler.Request objRequest = new DEBVerificationHandler.Request();
            objRequest.recordId = getLeadId();
            objRequest.objType = 'Lead';
            objRequest.debId = objLead.DEBID__c;
            objRequest.dob = objLead.nm_DateOfBirth__c;
            objRequest.ownerId = objLead.OwnerId;

            // After calling the function saving response
            DEBVerificationHandler.Response objResponse = DEBVerificationHandler.verifyDEBID(objRequest);
            System.debug('isSuccess ==>'+objResponse.isSuccess);
            debDetailObject.isDebInvalid = objResponse.isDebInvalid;
            if (objResponse.isSuccess) {
                debDetailObject.isDEBActive = objResponse.isDEBActive;
                debDetailObject.isDOBMatched = objResponse.isDOBMatched;
                debDetailObject.isDebMatched = objResponse.isDebMatched;
                debDetailObject.dateOfBirthDEB = objResponse.dateOfBirthDEB;
                debDetailObject.debUniqueId = objResponse.debUniqueId;
                debDetailObject.abcUniqueId = objResponse.abcUniqueId;
            }
            else {
                debDetailObject.debUniqueId = '';
            }
            
        } catch (Exception error) {
            System.debug('Error on => verifyDEBID');
            System.debug('Error Messgae =>'+error.getMessage());
            System.debug('Error Line Number =>'+error.getLineNumber());
            return;
        }
    }

    /**
    * @description 
    * @author @BK | 08-18-2024 
    * @param serviceType 
    **/
    public void updateAddressDetails() {
        if(String.isNotBlank(postalCode)) {
            // Create an instance of GeocodeController
            GeocodeController geocodeController = new GeocodeController();
                    
            // Call the processGeocode method
            GeocodeResult result = geocodeController.processGeocode(postalCode, System.Label.GeoCodeServiceType);

            // Handle the result
            handleGeocodeResult(result);
        }
    }

    // Method to process the result
    private void handleGeocodeResult(GeocodeResult result) {
        // Example of processing the result
        System.debug('City: ' + result.city);
        System.debug('State: ' + result.state);
        System.debug('Country: ' + result.country);
        System.debug('Message: ' + result.postalCodeMessage);
        
        if(objLead.Shipping_Address_Choice__c.equals('Shipping Address')){
            objLead.Country_Shipping__c = result.country;
            objLead.State_Province_Shipping__c = result.state;
            objLead.Shipping_City__c = result.city;
        }else if(objLead.Shipping_Address_Choice__c.equals('Permanent Address')){
            objLead.nm_Country_P__c = result.country;
            objLead.nm_StateProvince_P__c = result.state;
            objLead.nm_City_P__c = result.city;
        }
        postalCodeMessage = result.postalCodeMessage;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    **/
    public void copyAddress(){
        if(copyPermanantAddressFromTo == 'SameAsShipping'){
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
        }else if(copyPermanantAddressFromTo == 'NewAddress') {
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
    
    //         if(passout) {
    //             if((objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objAcc.nm_ChooseaProgram__c == 'Diploma Programs') ||
    //             ((objLead.nm_ChooseaProgram__c.startsWith('Diploma') || (objLead.nm_ChooseaProgram__c.contains('Master Programs') && objLead.Program_Type__c=='MBA')) &&
    //             objAcc.nm_ChooseaProgram__c == 'Certificate Programs' && objAcc.nm_Program__r.Name == 'C-BM' && objAcc.BatchStartD__c > date.newinstance(2019, 1, 1)) ||
    //             ((objLead.nm_ChooseaProgram__c.contains('Master Programs') && objLead.Program_Type__c=='MBA') && objAcc.nm_ChooseaProgram__c == 'Diploma Programs'))  {
    //                 objLead.Is_Lateral__c = true;
    //             }

    /**
     * @description getLateralStudentDetailsFromStudentNo
     * @author @Ravi | 15--01--2025 
     **/
    public void getLateralStudentDetailsAPI() {
        try {
            List<Student_Lateral_Sem_Mapping__c> objLateralSemMapping = new List<Student_Lateral_Sem_Mapping__c>();
            Student_Lateral_Sem_Mapping__c objSemMapping = new Student_Lateral_Sem_Mapping__c();
            String lateralNo = studentNumber.trim();
            isLateral = false;
            lateralMessage = '';
            
            System.debug('Student Lateral Number ---->' + studentNumber);

            List<Account> lstAccount = [ SELECT Id, FirstName, LastName, nm_Program__r.nm_TotalSemesters__c, Program_Name__c, nm_DateOfBirth__c,PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c, nm_IsEmailVerified__c,
                    Passing_Year__c, Passing_Month__c, Pass_Out__c, nm_ChooseaProgram__c FROM Account WHERE Student_ID__c != null AND Student_ID__c LIKE :lateralNo LIMIT 1];
            Account objAcc = lstAccount.size() > 0 ? lstAccount[0] : null;

            if (objAcc != null ) {
                List<nm_StudentProgram__c> objStudentProg = [ SELECT id, nm_Student__c, Certificate_Issue__c,Certificate_Issue__r.nm_ProgramName__c, Certificate_Issue__r.nm_Type__c, ProgramType__c,nm_Program__c, nm_Program__r.nm_ProgramName__c, nm_Program__r.prgst__c, Certificate_Issue__r.prgst__c
                FROM nm_StudentProgram__c WHERE nm_Student__r.Student_ID__c = :lateralNo ];
                nm_StudentProgram__c objstuProg = objStudentProg.size() > 0 ? objStudentProg[0] : null;
                System.debug('objStudentProg -->' + objstuProg);

                String mappedProg = objstuProg.Certificate_Issue__c != null ? objstuProg.Certificate_Issue__c : objstuProg.nm_Program__c;
                objLateralSemMapping = [SELECT Id, Lateral_Admission_to_the_Program__c, Old_Program__c, Future_Lateral_Sem__c  FROM Student_Lateral_Sem_Mapping__c WHERE Lateral_Admission_to_the_Program__c = :objLead.nm_ChooseaProgram__c 
                            AND Old_Program__c = :mappedProg ];
                objSemMapping = objLateralSemMapping.size() > 0 ? objLateralSemMapping[0] : null;

                String progStructure = objstuProg != null ? objstuProg.nm_Program__r.prgst__c : null;
                String CertifiStructure = (objstuProg != null && objstuProg.Certificate_Issue__c != null) ? objstuProg.Certificate_Issue__r.prgst__c : null;
                Integer yearInt = progStructure != null ? Integer.valueOf(progStructure.right(4)) : null;
                Integer certYearInt = CertifiStructure != null ? Integer.valueOf(CertifiStructure.right(4)) : null;
                

                if ( objstuProg.Certificate_Issue__c == null && yearInt!=null && yearInt < 2019 ) {
                    setStudentAsNonLateral();
                    lateralMessage = 'You are not eligible for lateral admission.';
                    return;
                } else if (objstuProg.Certificate_Issue__c != null && certYearInt != null && certYearInt < 2019) {
                    setStudentAsNonLateral();
                    lateralMessage = 'You are not eligible for lateral admission.';
                    return;
                }

                if (objAcc.Pass_Out__c) {
                    System.debug('Stage 3');
                    passout = objAcc.Pass_Out__c;
                } else {
                    String jsonBody = '{"sapid":"' + studentNumber + '"}';
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    
                    request.SetEndPoint(System.Label.getPassedYearMonthBySapid);
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    request.setBody(jsonBody);
                    response = http.send(request);
                    
                    System.debug('Response Body====>' + response.getBody());
                    String result = response.getBody();
                    Map<String, Object> mapOfAPIResponse = (Map<String, Object>) JSON.deserializeUntyped(result);
                    
                    Status = mapOfAPIResponse.containsKey('status') ? (String) mapOfAPIResponse.get('status') : '';
                    if (Status == 'Success') {
                        passout = true;
                        yearOfPassing = (String) mapOfAPIResponse.get('yearOfPassing');
                        monthOfPassing = (String) mapOfAPIResponse.get('monthOfPassing');
                        program = (String) mapOfAPIResponse.get('program');
                    } else {
                        passout = false;
                    }
                }

                if (passout) {
                    System.debug('Stage 4');
                    if (!objAcc.Pass_Out__c) {
                        markPassout(studentNumber, objAcc);
                    }
                    
                    if ((objstuProg.Certificate_Issue__c == null && objstuProg.ProgramType__c == 'Post Graduate Diploma Programs') 
                        || (objstuProg.Certificate_Issue__c != null && objstuProg.Certificate_Issue__r.nm_Type__c == 'Post Graduate Diploma Programs')) {
                        setStudentAsNonLateral();
                        System.debug('Stage 5');
                        lateralMessage = 'You are not eligible for lateral admission.';
                        return;
                    }
                    
                    if ((objstuProg.Certificate_Issue__c == null && (objstuProg.ProgramType__c == 'MBA (Distance) Programs' || objstuProg.nm_Program__r.nm_ProgramName__c == 'Diploma in Business Management'))) {
                        objLead.Sem__c = '3';
                        objLead.nm_Semester__c ='3';
                       
                    } else if (objstuProg.Certificate_Issue__c == null && objstuProg.nm_Program__r.nm_ProgramName__c == 'Certificate in Business Management') {
                        objLead.Sem__c = '2';
                        objLead.nm_Semester__c ='2';
                       
                    } else if (objSemMapping != null) {
                        objLead.Sem__c = objSemMapping.Future_Lateral_Sem__c;
                        objLead.nm_Semester__c =objSemMapping.Future_Lateral_Sem__c;
                      
                    } else {
                        setStudentAsNonLateral();
                        lateralMessage = 'You are not eligible for lateral admission.';
                        return;
                    }
                    objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                    program = objstuProg.Certificate_Issue__c == null ? objstuProg.nm_Program__r.nm_ProgramName__c : objstuProg.Certificate_Issue__r.nm_ProgramName__c;
                    yearOfPassing = objAcc.Passing_Year__c;
                    monthOfPassing = objAcc.Passing_Month__c;
                    setOTPFields(objAcc);
                } else {
                    System.debug('Stage 6');
                    if(objstuProg.Certificate_Issue__c == null) {
                         setStudentAsNonLateral();
                         lateralMessage = 'You are not eligible for lateral admission.';
                         return;
                     } else if ((objstuProg.Certificate_Issue__c != null && objstuProg.Certificate_Issue__r.nm_Type__c =='Post Graduate Diploma Programs') ){
                        setStudentAsNonLateral();
                        lateralMessage = 'You are not eligible for lateral admission.';
                        return;
                     } else if (objstuProg.Certificate_Issue__c != null && objSemMapping !=null) {
                        objLead.Sem__c = objSemMapping.Future_Lateral_Sem__c;
                        objLead.nm_Semester__c =objSemMapping.Future_Lateral_Sem__c;
                        objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        program = objstuProg.Certificate_Issue__r.nm_ProgramName__c;
                        yearOfPassing = objAcc.Passing_Year__c;
                        monthOfPassing = objAcc.Passing_Month__c;
                        setOTPFields(objAcc);
                     } else {
                        setStudentAsNonLateral();
                        lateralMessage = 'You are not eligible for lateral admission.';
                        return;
                     }
                }
            } else {
                System.debug('Stage 7');
                setStudentAsNonLateral();
                lateralMessage = 'No match found for entered student number.';
                return;
            }
        } catch (Exception e) {
            System.debug('Error Message => ' + e.getMessage());
            System.debug('Error Line Number => ' + e.getLineNumber());
            lateralMessage = 'Internal error occurred. Kindly contact our Support Team.';
        }
    }


    /**
    * @description 
    * @author @Ravi | 18--02--2025 
    * @param objAcc 
    **/
    public void setOTPFields(Account objAcc){
        isLateral = true;
        objOTP.EmailId = objAcc.PersonEmail.contains('de-registered_') ? objAcc.PersonEmail.remove('de-registered_') : objAcc.PersonEmail;
        objOTP.mobileNo = objAcc.PersonMobilePhone.contains('de-registered_') ? objAcc.PersonMobilePhone.remove('de-registered_') : objAcc.PersonMobilePhone;
        objOTP.PersonContactId = objAcc.PersonContactId;
        objOTP.isEmailVerified = objAcc.nm_IsEmailVerified__c;
        objOTP.isMobileVerified = objAcc.Is_Mobile_Verified__c;
        objOTP.recordObject = 'Account';
        objOTP.recordId = objAcc.Id;
        System.debug('objOTP.EmailId==>'+objOTP.EmailId+'objOTP.mobileNo==>'+objOTP.mobileNo);
    }

    public void updateAsNonLateral(){
        try { 
            lateralMessage='';
            objLead.Id =leadId;
            objLead.Sem__c='';
            objLead.Student_Number_Lateral__c = '';
            objLead.Year_Of_Passing_Lateral__c = '';
            objLead.Month_Of_Passing_Lateral__c = '';
            objLead.Course_Name_Lateral__c = '';
            objLead.Is_Lateral__c = false;
            objLead.Is_Non_Lateral__c ='Yes';
            updateLead(); 
        } catch (Exception e) {
            System.debug('Error at Line ==>'+e.getLineNumber());
            System.debug(e.getMessage());
            lateralMessage = 'Internal error occurred. Kindly contact our Support Team.';
        }
    }
    
    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    **/
    public void setStudentAsNonLateral() {
            lateralMessage='';
            objLead.Id =leadId;
            objLead.Sem__c='';
            objLead.Student_Number_Lateral__c = '';
            objLead.Is_Lateral__c = false;
    }

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    **/
    public void submitForOtp() {
           try {
            if (!sendOTP()) {
            lateralMessage= 'OTP couldn\'t be sent';
            }
           } catch (Exception e) {
            System.debug(e.getMessage());
            lateralMessage = 'Internal error occurred. Kindly contact our Support Team.';
           }
    }

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    * @return Boolean 
    **/
    public Boolean sendOTP() {
            OTPVerificationHandler objVerifyHandler = new OTPVerificationHandler();
            objOTP.OtpMode=OtpMode;
            System.debug('in send OTP verification handler'+objOTP.OtpMode);
            objOTP = objVerifyHandler.triggerToSendOTP(objOTP);
            return objOTP.isOTPSent;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @param String studentNumber 
    * @param Account objAccount 
    **/
    public void markPassout(String studentNumber, Account objAccount) {
        Account objAcc =new Account();
        objAcc.Id = objAccount.Id;
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

    /**
    * @description 
    * @author @BK | 19-07-2024 
    **/
    public void callValidate() {
        if (String.isNotBlank(objLead.nm_EligiblityCriteria__c)) {
            yearsEligibility = Integer.valueOf(
                [SELECT Experience_Required_In_Year__c FROM nm_EligiblityCriteria__c WHERE id = :objLead.nm_EligiblityCriteria__c].Experience_Required_In_Year__c
            );
        } else {
            yearsEligibility = 0;
        }

        if (yearsEligibility > 0) {
            errorMsg = 'For this eligibility criteria its mandatory to submit Work experience proof of ' + yearsEligibility + ' years  .';
        } else {
            errorMsg = '';
        }
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    **/
    public void getGlobalStateAndCountryValues(){
        list<Schema.PicklistEntry> CountryPicklistEntries = Lead.Country__c.getDescribe().getPicklistValues();
        String commaSeparatedCountry ='';
        for (Schema.PicklistEntry pe : CountryPicklistEntries){
           commaSeparatedCountry +=pe.getValue()+'|';
        }
        globalCountryValue = new List<SelectOption>();
        globalCountryValue.clear();
        globalCountryValue.add(new SelectOption('','---None---'));
        stringToSelectOptions(commaSeparatedCountry,globalCountryValue);
        
        
        list<Schema.PicklistEntry> StatePicklistEntries = Lead.State__c.getDescribe().getPicklistValues();
        String commaSeparatedState ='';
        for (Schema.PicklistEntry pe : StatePicklistEntries){
            commaSeparatedState +=pe.getValue()+'|';
        }
        globalStateValue = new List<SelectOption>();
        globalStateValue.clear();
        globalStateValue.add(new SelectOption('','---None---'));
        stringToSelectOptions(commaSeparatedState,globalStateValue);
    }

    public List<SelectOption> getGlobalLocalityOptionValues(){
        System.debug('getGlobalLocalityOptionValues ==>' + '');
        List<Schema.PicklistEntry> localityPicklistEntries = Lead.Locality__c.getDescribe().getPicklistValues();
        String commaSeparatedLocalities ='';
        for (Schema.PicklistEntry pe : localityPicklistEntries){
            commaSeparatedLocalities +=pe.getValue()+'|';
            System.debug('commaSeparatedLocalities ==>' + commaSeparatedLocalities);
        }
        List<SelectOption> globalLocalityValue = new List<SelectOption>();
        globalLocalityValue.clear();
        globalLocalityValue.add(new SelectOption('','---None---'));
        return stringToSelectOptions(commaSeparatedLocalities,globalLocalityValue);
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @param String Choices 
    * @param List<SelectOption> Option 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> stringToSelectOptions(String Choices,List<SelectOption> Option){
        if(Choices !=null && Choices !=''){
            for(String Opt : Choices.split('\\|')){
                Option.add(new SelectOption(Opt.trim(),Opt.trim()));
            }
        }
        return Option;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getDomicile() {
        List<SelectOption> option = new List<SelectOption>();
        option.add(new SelectOption('','---None--'));
        option.add(new SelectOption('India','India'));
        option.add(new SelectOption('Africa','Africa'));
        option.add(new SelectOption('America','America'));
        option.add(new SelectOption('Argentina','Argentina'));
        option.add(new SelectOption('Australia','Australia'));
        option.add(new SelectOption('Austria','Austria'));
        option.add(new SelectOption('Bangladesh','Bangladesh'));
        option.add(new SelectOption('Belgian','Belgian'));
        option.add(new SelectOption('Brazili','Brazili'));
        option.add(new SelectOption('British','British'));
        option.add(new SelectOption('Cambodia','Cambodia'));
        option.add(new SelectOption('Chile','Chile'));
        option.add(new SelectOption('China','China'));
        option.add(new SelectOption('Colombo','Colombo'));
        option.add(new SelectOption('Croatia','Croatia'));
        option.add(new SelectOption('Czech','Czech'));
        option.add(new SelectOption('Danish','Danish'));
        option.add(new SelectOption('Dutch','Dutch'));
        option.add(new SelectOption('French','French'));
        option.add(new SelectOption('German','German'));
        option.add(new SelectOption('Greek','Greek'));
        option.add(new SelectOption('Hungary','Hungary'));
        option.add(new SelectOption('Icelandic','Icelandic'));
        option.add(new SelectOption('Indonesia','Indonesia'));
        option.add(new SelectOption('Iran','Iran'));
        option.add(new SelectOption('Iraqi','Iraqi'));
        option.add(new SelectOption('Irish','Irish'));
        option.add(new SelectOption('Israeli','Israeli'));
        option.add(new SelectOption('Jamaica','Jamaica'));
        option.add(new SelectOption('Japanese','Japanese'));
        option.add(new SelectOption('Mexico','Mexico'));
        option.add(new SelectOption('Morocco','Morocco'));
        option.add(new SelectOption('Nepalese','Nepalese'));
        option.add(new SelectOption('Norwegian','Norwegian'));
        option.add(new SelectOption('Peruvian','Peruvian'));
        option.add(new SelectOption('Philippine','Philippine'));
        option.add(new SelectOption('Polish','Polish'));
        option.add(new SelectOption('Portuguese','Portuguese'));
        option.add(new SelectOption('Rumanian','Rumanian'));
        option.add(new SelectOption('Russian','Russian'));
        option.add(new SelectOption('Saudi, Saudi Arabia','Saudi, Saudi Arabia'));
        option.add(new SelectOption('Scottish','Scottish'));
        option.add(new SelectOption('Serbia','Serbia'));
        option.add(new SelectOption('Slovak','Slovak'));
        option.add(new SelectOption('Swedish','Swedish'));
        option.add(new SelectOption('Swiss','Swiss'));
        option.add(new SelectOption('Thai','Thai'));
        option.add(new SelectOption('Tunisia','Tunisia'));
        option.add(new SelectOption('Turkish','Turkish'));
        option.add(new SelectOption('Vietnamese','Vietnamese'));
        option.add(new SelectOption('Welsh','Welsh'));
        option.add(new SelectOption('Yugoslav','Yugoslav'));
        return option;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getElegibilityCriteriaList(){
        List<SelectOption> lstECOptions = new List<SelectOption>();
        Map<String,String> mapOfEligibilityVsWorkExp = new Map<String,String>();
        Map<String,Decimal> mapOfEligibilityVsRequiredAcademicPercentage = new Map<String,Decimal>();
        mapOfEligibilityVsRequiredAcademic = new Map<String,Boolean>();
        Map<String,Boolean> mapOfEligibilityVsMaster = new Map<String,Boolean>();
        
        String chooseProgram = objLead.nm_ChooseaProgram__c;
        String programType;
        if(String.isNotBlank(chooseProgram) && chooseProgram.equals('Master Programs')) {
            programType = objLead.Program_Type__c;
        }
        System.debug('chooseProgram ==>'+chooseProgram +'  programType ==>'+programType);
        
        lstECOptions.add(new SelectOption('', '---None--'));
        List<nm_EligiblityCriteria__c> lstElegibility = [SELECT id,nm_EligiblityCriteria__c,Experience_Required_In_Year__c,HSC_Re__c,Diploma_Required__c,Graduation_Required__c,Post_Graduation_Required__c,
        Post_Graduation_Percentage__c,Graduation_Percentage__c,nm_Program__c,Is_Active__c,Program_Type__c,HSC_Percentage__c,Diploma_Percentage__c,Enable_Master__c FROM nm_EligiblityCriteria__c 
        WHERE Program_Type__c=:programType AND nm_Program__c=:chooseProgram AND Is_Active__c=true];
        if(lstElegibility.size() > 0 ){
            for(nm_EligiblityCriteria__c objEligibility : lstElegibility){
                lstECOptions.add(new SelectOption(objEligibility.id, objEligibility.nm_EligiblityCriteria__c)); 
                mapOfEligibilityVsWorkExp.put(objEligibility.id,String.valueOf(objEligibility.Experience_Required_In_Year__c));
                mapOfEligibilityVsRequiredAcademic.put(objEligibility.id+'-HSC',objEligibility.HSC_Re__c);
                mapOfEligibilityVsRequiredAcademic.put(objEligibility.id+'-Diploma',objEligibility.Diploma_Required__c);
                mapOfEligibilityVsRequiredAcademic.put(objEligibility.id+'-Graduation',objEligibility.Graduation_Required__c);
                mapOfEligibilityVsRequiredAcademic.put(objEligibility.id+'-Professional',objEligibility.Post_Graduation_Required__c);
                mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id+'-HSC',objEligibility.HSC_Percentage__c);
                mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id+'-Diploma',objEligibility.Diploma_Percentage__c);
                mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id+'-Graduation',objEligibility.Graduation_Percentage__c);
                mapOfEligibilityVsRequiredAcademicPercentage.put(objEligibility.id+'-Professional',objEligibility.Post_Graduation_Percentage__c);
                mapOfEligibilityVsMaster.put(objEligibility.Id,objEligibility.Enable_Master__c);
            }
            
            if(!mapOfEligibilityVsWorkExp.isEmpty()){
                jsonMapOfEligibilityVsWorkExp = JSON.serialize(mapOfEligibilityVsWorkExp);
                System.debug('jsonMapOfEligibilityVsWorkExp -->'+jsonMapOfEligibilityVsWorkExp);
            }
            
            if(!mapOfEligibilityVsRequiredAcademic.isEmpty()){
                jsonMapOfEligibilityVsRequiredAcademic  = JSON.serialize(mapOfEligibilityVsRequiredAcademic);
                System.debug('jsonMapOfEligibilityVsRequiredAcademic--'+jsonMapOfEligibilityVsRequiredAcademic);
            }

            if(!mapOfEligibilityVsRequiredAcademicPercentage.isEmpty()) {
                jsonMapOfEligibilityVsRequiredAcademicPercentage = JSON.serialize(mapOfEligibilityVsRequiredAcademicPercentage);
            }

            if(!mapOfEligibilityVsMaster.isEmpty()) {
                jsonMapOfEligibilityVsMaster = JSON.serialize(mapOfEligibilityVsMaster);
            }
        }
        return lstECOptions;
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return Boolean 
    **/
    public Boolean calculateAcademicScore() {
        try {
            
            Boolean result = false;
            Map<String,Decimal> MapOfAcademicPercentage = new Map<String,Decimal>{'SSC_Score__c'=>objLead.nm_10thPercentage__c};
            
            // For 12th or diploma
            if(objLead.nm_Class12OrDiploma__c == 'XII/HSC' || objLead.nm_Class12OrDiploma__c == '12th Grade') {
                MapOfAcademicPercentage.put('HSCOrDiploma_Score__c',objLead.nm_12thPercentage__c);
            }else{
                MapOfAcademicPercentage.put('HSCOrDiploma_Score__c',objLead.Result_Diploma__c);
            }

            //For Graduation or Professional Degree
            if(mapOfEligibilityVsRequiredAcademic.containsKey(objLead.nm_EligiblityCriteria__c+'-Professional') && mapOfEligibilityVsRequiredAcademic.get(objLead.nm_EligiblityCriteria__c+'-Professional')) {
                Decimal percentage = Decimal.valueOf(objLead.Percentage1__c);
                MapOfAcademicPercentage.put('Grad_Score__c',percentage);
            }else{
                MapOfAcademicPercentage.put('Grad_Score__c',objLead.nm_BachelorsDegreePercentage__c);
            }
            System.debug('MapOfAcademicPercentage -->'+MapOfAcademicPercentage);

            for(String mapKey : MapOfAcademicPercentage.keySet()) {
                if(MapOfAcademicPercentage.get(mapKey) != null) {
                Integer percent = Math.round(MapOfAcademicPercentage.get(mapKey));
                Integer Score = 0;
                System.debug('MapOfAcademicPercentage -->'+mapKey+' -->'+percent);
                if(percent >= 40 && percent < 45) {
                    Score = 2;
                }else if(percent >= 45 && percent < 50){ 
                    Score = 3;
                }else if(percent >= 50 && percent < 55) {
                    Score = 4;
                }else if(percent >= 55 && percent < 60) {
                    Score = 5;
                }else if(percent >= 60 && percent < 65) {
                    Score = 6;
                }else if(percent >= 65 && percent < 70) {
                    Score = 7;
                }else if(percent >= 70 && percent < 75) {
                    Score = 8;
                }else if(percent >= 75 && percent < 80){
                    Score = 9;
                }else if(percent >= 80) {
                    Score = 10;
                }
                objLead.put(mapKey,Score);
            }
            }
            return result;
        } catch (Exception e) {
            System.debug(e);
            errorMsg = 'Internal error occured. Kindly try again later';
            return true;
        }
    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getWorkExpTimeList(){
        List<SelectOption> options = new List<SelectOption>();
        Integer yearsEligibility = null;
        if(objLead.nm_EligiblityCriteria__c !=null){
            yearsEligibility = integer.valueOf([SELECT Experience_Required_In_Year__c FROM nm_EligiblityCriteria__c WHERE id=:objLead.nm_EligiblityCriteria__c].Experience_Required_In_Year__c);
        }
        System.debug('yearsEligibility ->'+yearsEligibility);
        
        if(yearsEligibility ==null || yearsEligibility == 0){
            options.add(new SelectOption('','--None--'));
            options.add(new SelectOption('0-1 Years','0-1 Years'));
            options.add(new SelectOption('1-3 Years','1-3 Years'));
            options.add(new SelectOption('3-5 Years','3-5 Years'));
            options.add(new SelectOption('5-10 Years','5-10 Years'));
            options.add(new SelectOption('10+ Years','10+ Years'));
        }else if(yearsEligibility != null && yearsEligibility > 0){
            options.add(new SelectOption('','--None--'));
            options.add(new SelectOption('1-3 Years','1-3 Years'));
            options.add(new SelectOption('3-5 Years','3-5 Years'));
            options.add(new SelectOption('5-10 Years','5-10 Years'));
            options.add(new SelectOption('10+ Years','10+ Years'));
        }
        return options;
    }
    
    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return List<SelectOption> 
    **/
    // public List<SelectOption> getLateralOptions(){
    //     List<SelectOption> options = new List<SelectOption>();
    //     options.add(new SelectOption('','Do you want to opt for Lateral Admission?'));
    //     options.add(new SelectOption('true','Yes'));
    //     options.add(new SelectOption('false','No'));
    //     return options; 
    // } 


    /**
    * @description for MBA Executive Programs
    * @author @BK | 19-07-2024 
    * @return list<SelectOption> 
    **/
    public list<SelectOption> getGraduationDegreeModeMBA(){
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('','---None--'));
        options.add(new SelectOption('Full Time','Full Time'));
        options.add(new SelectOption('Part Time','Part Time'));
        options.add(new SelectOption('Distance Learning','Distance Learning'));
        options.add(new SelectOption('Online','Online'));
        options.add(new SelectOption('Any Other','Any Other'));
        return options;
    }
    
    /**
    * @description method to add Experience 
    * @author @BK | 19-07-2024 
    */
    public void addExperience() { 
        nm_WorkExperience__c objWE = new nm_WorkExperience__c();
        objWE.id = null;
        lstWorkExperience.add(objWE);
    }


    /**
    * @description method to remove Experience 
    * @author @BK | 19-07-2024 
    **/
    public void removeExperience() {
        Integer strRowNo = lstWorkExperience.size();
        if(strRowNo != null && strRowNo > 1){
            Integer IndexVal = integer.valueOf(strRowNo) - 1;
            String WEXPName = lstWorkExperience[IndexVal].Name;
            System.debug('WEXPName ==>'+WEXPName);
            // String removeExperienceId = lstWorkExperience[IndexVal].Id;
            String removeExperienceId = String.isNotBlank(WEXPName) && mapOfNameVsId.containsKey(WEXPName) ? mapOfNameVsId.get(WEXPName) : null;
            if(removeExperienceId != '' && removeExperienceId != null){
                removedWorkExperience.add(removeExperienceId);
            }
            lstWorkExperience.remove(IndexVal);
        }  
    }
    
    /*------- Method to Redirect to payment -----*/
    // public pageReference MakePayment() {
    //     if( LeadId != null && LeadId != '') {    
    //         String sitebaseURL = URL.getSalesforceBaseUrl().toExternalForm();
    //         String fullURL = sitebaseURL + System.Label.GoToAdmissionPayment_Url + 'id=' + LeadId;
    //         if(icValue == 'true') {
    //             fullURL = fullURL + '&IC=true';
    //         }
    //         System.debug('siteURL ==>'+fullURL);
    //         PageReference pgURL = new PageReference(fullURL);//payOpt=3
    //         pgURL.setRedirect(true);
    //         return pgURL;
            
    //     }
    //     return null;
    // }
    /*---- End Method to Redirect to payment ---*/

    /**
    * @description to save workexpereince
    * @author @BK | 19-07-2024 
    * @return boolean 
    **/
    public boolean saveWorkExp(){
        try {
            Integer monthDiff = 0;
            List<nm_WorkExperience__c> lstWEToUpsert = new List<nm_WorkExperience__c>();
        
            System.debug('lstWorkExperience--'+lstWorkExperience);
            for(nm_WorkExperience__c objWE : lstWorkExperience) {
                objWE.nm_Lead__c = LeadId;
                System.debug('mapOfNameVsId--'+mapOfNameVsId);
                System.debug('mapOfNameVsId.containsKey(objWE.Name) '+mapOfNameVsId.containsKey(objWE.Name));
                System.debug('objWE.Name'+objWE.Name);
                
                objWE.Id = objWE.Name!=null && mapOfNameVsId.containsKey(objWE.Name) ? mapOfNameVsId.get(objWE.Name) : null;
                 System.debug('duplicate WEId: '+objWE.Id);
                if((objWE.nm_StartDate__c != null && objWE.nm_EndDate__c != null) || objWE.Currently_Working_Here__c == true){
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

            if( lstWEToUpsert.size() > 0 ){ 
                getWXPListToUpsert(monthDiff, lstWEToUpsert);
            }
            resetAfterUpsert();
            return false;
        }
        catch( Exception e){
            resetAfterUpsert();
            errorMsg = 'Internal error occured. Kindly try again later';
            return true;
        }
    }

    /**
    * @description 
    * @author @BK | 06-08-2024 
    * @param Integer monthDiff 
    * @param List<nm_WorkExperience__c> lstWEToUpsert 
    **/
    private void getWXPListToUpsert(Integer monthDiff, List<nm_WorkExperience__c> lstWEToUpsert) {
        try {
            //to delete removed workexpereince.
            System.debug('lstWEToUpsert Records: ' + lstWEToUpsert);
            System.debug('removedWorkExperience size:'+removedWorkExperience.size() );
            if(removedWorkExperience.size() > 0){              
                delete [select Id from nm_WorkExperience__c where Id in :removedWorkExperience];
            }
            
            //to make string of total months into years and month
            System.debug('monthDiff--'+monthDiff);
            if(monthDiff > 0) {
                Integer months = math.MOD(monthDiff, 12);
                Integer year = monthDiff/12;
                System.debug(year + ' year ' +  months + 'Months');
                objLead.Total_Work_Experience__c = year + ' year ' +  months + 'Months';
                Integer score = year*5;
                Integer maximumScore = Integer.valueOf(System.label.workExperienceScore);
                if(score > maximumScore) {
                    score = maximumScore;
                }
                objLead.Work_exp_Score__c = score;
            }
                
            upsert lstWEToUpsert;
        } catch (Exception error) {
            System.debug('Error ==>'+error.getMessage());
            resetAfterUpsert();
        }
    }

    /**
    * @description 
    * @author @BK | 06-08-2024 
    **/
    public void resetAfterUpsert() {
        // System.debug('lstWorkExperience===>'+lstWorkExperience.size()+' records==>'+lstWorkExperience);
        // for(nm_WorkExperience__c objWE : lstWorkExperience) { 
        //     if(objWE.Id != null) {
        //         nm_WorkExperience__c objWork = [SELECT Id,nm_Student__c,nm_Lead__c,Name FROM nm_WorkExperience__c WHERE Id=:objWE.Id];
        //         System.debug('objWE.Name--'+objWork.Name);
        //          mapOfNameVsId.put(objWork.Name, objWE.Id);
        //         objWE.Id = null;
        //     }
        // }
        List<nm_WorkExperience__c> lstWorkExperienceRecord = [SELECT Id,nm_Student__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c,Experience_Level__c,Name,RecordId__c FROM nm_WorkExperience__c WHERE nm_Lead__c=:leadId ORDER BY nm_StartDate__c ASC];
             lstWorkExperience.clear();
        for(nm_WorkExperience__c objWE : lstWorkExperienceRecord) {
            mapOfNameVsId.put(objWE.Name, objWE.Id);
            objWE.Id = null;
            lstWorkExperience.add(objWE);
         }
         System.debug('lstWorkExperience==>'+lstWorkExperience.size()+' records'+lstWorkExperience);

    }

    /**
    * @description 
    * @author @BK | 19-07-2024 
    * @return String 
    **/
    public String leadQuery() {
        return 'SELECT id,nm_ChooseaProgram__c,nm_InformationCenter__r.Allow_Degree__c,nm_InformationCenter__r.Allow_Bachelor__c,nm_Program__r.Name,nm_InformationCenter__r.Address__c,'+
            'Status,LeadSource,InactiveLead__c,nm_IPForLead__c,nm_PaymentStatus__c,Partial_form_filled__c,Program_Type__c,nm_RegistrationNo__c,Email,MobilePhone,isConverted,'+
            'nm_InformationCenter__c,nm_StudentSelectedIC__c,Student_Number_Lateral__c,Year_Of_Passing_Lateral__c,Month_Of_Passing_Lateral__c,Course_Name_Lateral__c,nm_Program__r.Specialisation__c,'+
            'nm_HouseNumber_P__c,nm_LocalityName_P__c,nm_Street_P__c,nm_StateProvince_P__c,nm_Country_P__c,nm_City_P__c,nm_PostalCode_P__c,nm_Year__c,nm_Session__c,'+
            'House_No_Name_Shipping__c,Locality_Name_Shipping__c,nm_SelfLearningMaterial__c,Shipping_Street__c,State_Province_Shipping__c,Country_Shipping__c,nm_Program__r.Form_Specialisation__c,'+
            'Shipping_City__c,Zip_Postal_Code_Shipping__c,nm_HouseNumber__c,nm_LocalityName__c,Street,State,Country,City,PostalCode,nm_InformationCenter__r.recordtype__c,'+
            'Shipping_Address_Choice__c,Address,nm_EligiblityCriteria__c,Salutation,FirstName,nm_MiddleName__c,LastName,nm_DateOfBirth__c,Father_Salutation__c,Father_First_Name__c,'+
            'Father_Last_Name__c,Mother_Salutation__c,Mother_First_Name__c,Mother_Last_Name__c,nm_Gender__c,nm_MaritalStatus__c,nm_SpouseName__c,nm_BloodGroup__c,nm_Program__r.Bachelor_Specialization__c,'+
            'nm_Category__c,nm_OtherCategory__c,nm_Domicile__c,nm_Nationality__c,AadharCardNumber__c,Pancard_no__c,nm_Passport__c,nm_STDCode__c,Phone,nm_SecondryEmail__c,'+
            'IC_Name__c,Specialization_Type__c,Program_Preference1__c,nm_Program__c,nm_Program2__c,Allow_to_Opt_Lateral__c,nm_Interview_Slot_Preference__c,Are_you_from_Defence__c,nm_ServiceNumber__c,'+
            'Relationship__c,nm_DateofCommission__c,Armed_Service__c,Rank__c,nm_NameofBoard__c,nm_10thClassStateBoardName__c,nm_10thPercentage__c,nm_YearofCompletion__c,'+
            'nm_NameofSchool__c,nm_Class12OrDiploma__c,nm_NameofBoard12__c,nm_12thClassStateBoardName__c,nm_YearofCompletion12__c,nm_Stream__c,nm_Program__r.nm_ProgramName__c,'+
            'nm_NameofSchool12__c,nm_DiplomaSchoolCollegeUniversityname__c,Result_Diploma__c,nm_DiplomaYearOfCompletion__c,nm_DiplomaName__c,nm_StreamDiploma__c,nm_DurationOfDiploma__c,'+
            'nm_BachelorsDegreeName__c,nm_OtherBachelorsDegreeName__c,nm_Specialization__c,nm_University_Type__c,nm_BachelorsDegreePercentage__c,nm_NameofUniversity__c,'+
            'nm_Other_University_Name__c,nm_GraduationDegreeMode__c,nm_OtherGraduationDegreeMode__c,nm_YearofCollegeCompletion__c,nm_NameOfCollege__c,Name_of_Program1__c,'+
            'Name_of_Program2__c,Name_of_Program3__c,Name_of_College1__c,Name_of_College2__c,Name_of_College3__c,Name_of_University1__c,Name_of_University2__c,Name_of_University3__c,'+
            'Year_of_Passing1__c,Year_of_Passing2__c,Year_of_Passing3__c,Percentage1__c,Percentage2__c,Percentage3__c,Duration_of_Program1__c,Duration_of_Program2__c,'+
            'Duration_of_Program3__c,nm_Duration_of_Program_in_Year1__c,nm_Duration_of_Program_in_Year2__c,nm_Duration_of_Program_in_Year3__c,Graduation_Degree_Mode1__c,'+
            'Graduation_Degree_Mode2__c,Graduation_Degree_Mode3__c,Other_Graduation_Degree_Mode1__c,Other_Graduation_Degree_Mode2__c,Other_Graduation_Degree_Mode3__c,'+
            'Total_Work_Experience__c,Reason__c,LinkedIn_URL__c,SSC_Score__c,HSCOrDiploma_Score__c,Grad_Score__c,Father_Name__c,nm_ProgramName__c,nm_Eligibility_Criteria_Ref__c,'+
            'Mother_Name__c,nmm_BatchName__c,nm_InformationCenter__r.Nm_Active__c,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,'+
            'Father_s_Email_Id__c,Father_s_Mobile_number__c,Mother_s_Email_Id__c,Mother_s_Mobile_number__c,Is_Non_Lateral__c,Differently_abled__c,Your_disability__c,nm_SSC_Rating_Type__c,SSC_Marks_obtained__c,SSC_Marks_Out_Off__c,'+
            'SSC_Examination_State__c,HSC_status__c,HSC_Marks_obtained__c,HSC_Marks_Out_Off__c,HSC_Examination_State__c,nm_HSC_Rating_Type__c,nm_12thPercentage__c,ABCID__c,DEBID__c,'+
            'Diploma_Examination_State__c,Diploma_Marks_obtained__c,Diploma_Marks_Out_Off__c,Diploma_Percentage__c,Diploma_status__c ,Other_Name_of_Program1__c,Master_s_Degree_Name__c,'+
            'Profile_Name__c,nm_Mother_Tongue__c,nm_Other_Mother_Tongue__c,nm_WorkExperience__c,nm_Other_Reason__c,nm_StudentImageUrl__c,StudentLogin__c,nm_SelectedIC__c, Adhar_Card_Number__c,Is_Lateral__c,Lateral_Editable_set__c,OwnerId,Locality__c  FROM Lead';
    }

    /**
    * @description 
    * @author @BK | 23-07-2024 
    * @return String 
    **/
    public String accountQuery() { 
        return 'SELECT Id,nm_RegistrationNumber__c,nm_StudentStatus__c,nm_StudentImageUrl__c,Salutation,FirstName,LastName,nm_DateOfBirth__c,nm_Gender__c,nm_MaritialStatus__c,nm_Program__r.Bachelor_Specialization__c,'+
            'Father_Name__c,Father_Last_Name__c,Father_First_Name__c,Father_Salutation__c,Mother_Salutation__c,Mother_First_Name__c,Mother_Last_Name__c,Mother_Name__c,nm_SpouseName__c,nm_BloodGroup__c,nm_Category__c,nm_Nationality__c,nm_Domicile__c,Adhar_Card_Number__c,House_No_Name_Shipping_Account__c,nm_Program__r.Form_Specialisation__c,'+
            'Shipping_Street__c,Locality_Name_Shipping__c,Differently_abled__c,Your_disability__c,City_Shipping_Account__c,State_Province_Shipping__c,Country_Shipping__c,Zip_Postal_Code_Shipping__c,PersonMobilePhone,nm_Program__r.Specialisation__c,'+
            'PersonEmail,nm_Mother_Tongue__c,nm_Other_Mother_Tongue__c,nm_STDCode__c,Phone,nm_HouseNumber_P__c,nm_Street__c,nm_LocalityName_P__c,nm_City__c,nm_StateProvince__c,nm_Country__c,nm_PostalCode__c,nm_SecondryEmail__c,'+
            'nm_ChooseaProgram__c,Program_Type__c,Specialization_Type__c,nm_Program__c,nm_Program2__c,nm_DefencePersonnel__c,nm_ServiceNumber__c,nm_Relationship__c,nm_DateofCommission__c,nm_ArmedService__c,Rank__c,Eligibility_Criteria_Ref__c,nm_EligiblityCriteria__c,nm_10thPercentage__c,nm_NameofBoard__c,'+
            'nm_YearofCompletion__c,nm_Class12OrDiploma__c,nm_12thPercentage__c,nm_NameofBoard12__c,nm_YearofCompletion12__c,nm_NameofStateBoard10th__c,nm_NameofSchool12__c,nm_Stream__c,nm_NameofStateBoard12th__c,nm_ResultDiploma__c,'+
            'nm_DiplomaName__c,nm_DiplomaSchoolCollegeUniversityname__c,Other_Name_of_Program1__c,nm_StreamDiploma__c,nm_DurationOfDiploma__c,nm_DiplomaYearOfCompletion__c,nm_BachelorsDegreeName__c,'+
            'nm_NameOfCollege__c,nm_NameofUniversity__c,Other_University_Name__c,nm_YearofCollegeCompletion__c,Percentage_Bachlor__c,nm_GraduationDegreeMode__c,nm_Other_Reason__c,'+
            'Name_of_Program1__c,Master_s_Degree_Name__c,Name_of_College1__c,Name_of_University1__c,Year_of_Passing1__c,Duration_of_Program1__c,Percentage1__c,Graduation_Degree_Mode1__c,nm_Specialization__c,'+
            'Name_of_Program2__c,Name_of_College2__c,Name_of_University2__c,Year_of_Passing2__c,Duration_of_Program2__c,Percentage2__c,Graduation_Degree_Mode2__c,nm_NameofSchool__c,'+
            'Name_of_Program3__c,Name_of_College3__c,Name_of_University3__c,Year_of_Passing3__c,Duration_of_Program3__c,Percentage3__c,Graduation_Degree_Mode3__c,Reason__c,'+
            'LinkedIn_URL__c,Total_Work_Experience__c,nm_WorkExperience__c,ABCID__c,DEBID__c,AadharCardNumber__c,Student_ID__c,nm_Program__r.nm_ProgramName__c,OwnerId,Locality__c ,Pass_Out__c,Program_Name__c,Passing_Year__c,Passing_Month__c FROM Account';
    }

    public class DEBDetails {
        public DEBDetails() {
            this.isAPICalled = false;
            this.isDEBActive = false;
            this.isDebMatched = false;
            this.isABCMatched = false;
            this.isDOBMatched = false;
            this.dateOfBirthDEB = null;
            this.debUniqueId = '';
            this.abcUniqueId = '';
            this.isDebInvalid = false;
        }

        public Boolean isAPICalled {get;set;}
        public Boolean isDEBActive {get;set;}
        public Boolean isDOBMatched {get;set;}
        public Boolean isDebMatched {get;set;}  
        public Boolean isABCMatched {get;set;}
        public Date dateOfBirthDEB {get;set;}
        public String debUniqueId {get;set;}
        public String abcUniqueId {get;set;}
        public Boolean isDebInvalid {get;set;}
    }
   
}