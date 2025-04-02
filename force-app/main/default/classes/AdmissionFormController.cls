/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 20-08-2024
 * @last modified by  : @BK
**/
public without sharing class AdmissionFormController {
    public lead objLead { get; set; }
    public String jsonMapOfEligibilityVsWorkExp {get;set;}
    public String jsonMapOfEligibilityVsRequiredAcademic {get;set;}
    public String jsonMapOfEligibilityVsRequiredAcademicPercentage {get;set;}
    public String jsonMapOfSpecialisationVsId {get;set;}
    public String jsonMapOfEligibilityVsMaster {get;set;}
    public Map<String,String> mapOfFieldAPIVsFieldLabel {get;set;} 
    public Map<String,Boolean> mapOfEligibilityVsRequiredAcademic{get;set;}
    public Map<String,nm_Program__c> MapOfIdVsProgram {get;set;}
    public string strSecToShow { get; set; }
    public string message { get;set; }
    public  boolean IsReLogin{get;set;}
    public string ipAddress{get;set;} 
    public String LeadId {get;set;}
    public boolean disabledIC {get;set;}
    public String IC {get;set;}
    public String billingToShippingCopyAddress {get;set;}
    public String CopyPermanantAddressFromTo {get;set;}
    public String Postalcode {get;set;}
    public String icValue {get;set;}
    public String sectionName {get;set;}
    public boolean IsEditFormConfirmation {get;set;}
    public list<nm_WorkExperience__c> lstWorkExperience {get;set;}
    public Map<String,Id> mapOfNameVsId {get;set;}
    public Set<Id> RemovedWorkExperience {get;set;}
    public String PostalCodeMessage {get;set;}
    public String AlumniMessage {get;set;}
    public String selectedICName {get;set;}
    public String corporateBatchName {get;set;}
    public Boolean checkExpireDateforBatch {get;set;}
    public String isDupChecked {get;set;}

    // temp to delete later
    public String imageURL {get;set;}
    public String registrationNo {get;set;}

    public String programNameForSpecialization {get; set;}
    
    //---- Select Options ---------------//
    public List<SelectOption> globalStateValue {get;set;}
    public List<SelectOption> globalCountryValue {get;set;}
    public List<SelectOption> getWorkExpTimeList{get;set;}
    public list<SelectOption> getElegibilityCriteriaList{get;set;}
    public List<SelectOption> getLateralOptions {get;set;}
    public List<SelectOption> getDomicile {get;set;}
    public List<SelectOption> getProgramsList {get;set;}
    public List<SelectOption> getSpecializationList {get; set;}
    public Map<String, String> BachelorProgramSpecialization {get; set;}
    public String jsonMapOfBachelorProgramSpecialization {get;set;} 

    //For OTP Verification Login
    public String registrationButton {get;set;}
    public OTPFields objOTP {get;set;}
    public list<string> lstMsg  { get; set; }
    public Boolean IsLeadJustInserted { get; set; }
    
    public AdmissionFormController(){
        objLead = new Lead();
        objLead.id = null;
        sectionName = '';
        icValue = 'false';
        jsonMapOfEligibilityVsWorkExp = null;
        jsonMapOfEligibilityVsRequiredAcademic = null;
        jsonMapOfEligibilityVsRequiredAcademicPercentage = null;
        jsonMapOfSpecialisationVsId = null;
        mapOfFieldAPIVsFieldLabel = new Map<String,String>();
        jsonMapOfEligibilityVsMaster = null;
        MapOfIdVsProgram = new Map<String,nm_Program__c>();
        BachelorProgramSpecialization = new Map<String, String>();
        strSecToShow = '';
        disabledIC = false;
        message = null;
        IsReLogin = false;
        Postalcode  = '';
        ipAddress = null;
        LeadId = null;
        IC = null;
        isDupChecked ='';
        billingToShippingCopyAddress = '';
        CopyPermanantAddressFromTo = '';
        IsEditFormConfirmation = false;
        lstWorkExperience = new list<nm_WorkExperience__c>();
        mapOfNameVsId = new Map<String,Id>();
        RemovedWorkExperience = new Set<Id>();
        PostalCodeMessage = '';
        AlumniMessage = '';
        selectedICName = '';
        LeadId = ApexPages.currentPage().getParameters().get('id');
        sectionName = ApexPages.currentPage().getParameters().get('sectionName');
        registrationNo = null;
        imageURL = null;

        objOTP = new OTPFields();
        registrationButton = 'registrationButton';
        lstMsg = new List<String>();
        IsLeadJustInserted = false;
        
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');

        icValue = ApexPages.currentPage().getParameters().get('IC');
        
        if(ApexPages.currentPage().getParameters().get('ReLogin') !=null && ApexPages.currentPage().getParameters().get('ReLogin') !=''){
            IsReLogin = Boolean.valueOf(ApexPages.currentPage().getParameters().get('ReLogin'));
        }
        
        if(ApexPages.currentPage().getParameters().get('IsEditFormConfirmation') !=null && ApexPages.currentPage().getParameters().get('IsEditFormConfirmation') !=''){
            IsEditFormConfirmation = Boolean.valueOf(ApexPages.currentPage().getParameters().get('IsEditFormConfirmation'));
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('fname'))) {
            objLead.FirstName = ApexPages.currentPage().getParameters().get('fname');
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('lname'))) {
            objLead.LastName = ApexPages.currentPage().getParameters().get('lname');
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('email'))) {
            objLead.Email = ApexPages.currentPage().getParameters().get('email');
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('mobile'))) {
            objLead.MobilePhone = ApexPages.currentPage().getParameters().get('mobile');
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('IcRec'))){
            IC = ApexPages.currentPage().getParameters().get('IcRec');
        }

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('batch'))) {
            corporateBatchName = ApexPages.currentPage().getParameters().get('batch');
            checkExpireDateforBatch = calenderCheckForCorporate(corporateBatchName);
            System.debug('checkExpireDateforBatch '+checkExpireDateforBatch);
        }

        if (ApexPages.currentPage().getParameters().get('skipOTP') != null && ApexPages.currentPage().getParameters().get('skipOTP') != '') {
            objOTP.skipOTP = Boolean.valueOf(ApexPages.currentPage().getParameters().get('skipOTP'));
        }

        getGlobalStateAndCountryValues();

        if(String.isBlank(LeadId)) {
            LeadId = getCookie();
        }

        if(String.isNotBlank(LeadId)){
            registrationButton = '';
            QueryLeadData();
        } else {
            getProgramsList();
        }
    }
    
    public void ErrorMessage(String msg,String secToShow){
        message = msg;
        strSecToShow = secToShow; 
    }
    
    public Map<String,String> getMapOfEditableVsDataTypeOfFieldForSObject(String SObjectAPIName) {
        Map<String,String> mapOfEditableFieldAPIVsDataType = new Map<String,String>();
        Map<String,Boolean> mapOfFieldVsPermission = getMapOfFieldVsPermission(SObjectAPIName);
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        
        for(String fieldName : fieldMap.keySet()) {
            if(mapOfFieldVsPermission.containsKey(fieldName)){ 
               mapOfEditableFieldAPIVsDataType.put(fieldName.toLowerCase() ,String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
            }
        }
        
        return mapOfEditableFieldAPIVsDataType;
    }

    public Map<String,Boolean> getMapOfFieldVsPermission(String ObjectAPIName) {
        String ProfileId = userinfo.getProfileId();
        Map<String,Boolean> mapOfFieldVsPermission = new Map<String,Boolean>();
        List<FieldPermissions> lstFieldPermissions = [SELECT Field FROM FieldPermissions WHERE SobjectType =:ObjectAPIName AND Parent.ProfileId=:ProfileId AND PermissionsEdit=true]; 
        if(lstFieldPermissions.size() > 0) {
            for(FieldPermissions objFieldPermissions : lstFieldPermissions) {
                String fieldName = objFieldPermissions.Field;
                fieldName = fieldName.substringAfterLast('.');
                System.debug('fieldName -->'+fieldName);
                mapOfFieldVsPermission.put(fieldName.toLowerCase(),true);
            }
        }
        return mapOfFieldVsPermission;
    }
    
    public void QueryLeadData(){
        String LeadQuery = LeadQuery();
        LeadQuery = LeadQuery+' WHERE id=:LeadId';
        List<Lead> lstLead = DataBase.query(LeadQuery);

        if(lstLead.size() > 0){
            objLead = lstLead[0];
            objLead.id = null;
            IsReLogin = true;
            registrationNo = objLead.nm_RegistrationNo__c;
            imageURL = objLead.nm_StudentImageUrl__c;
            programNameForSpecialization = objLead.Program_Type__c;
            //to get the List of work experience from leadid.
            List<nm_WorkExperience__c> lstWorkExperienceRecord = [SELECT id,nm_Student__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c,Experience_Level__c,Name,RecordId__c FROM nm_WorkExperience__c WHERE nm_Lead__c=:LeadId];
            System.debug('---------------------lstWorkExperience---------------');
            System.debug(lstWorkExperienceRecord);
            for (nm_WorkExperience__c objWp : lstWorkExperienceRecord) {
                nm_WorkExperience__c objWpClone = objWp;
                objWpClone.id = null;
                lstWorkExperience.add(objWpClone);
                mapOfNameVsId.put(objWp.Name,objWp.RecordId__c);
                System.debug('mapOfNameVsId==>');
                System.debug(mapOfNameVsId);
            }
            // //to get the list of work experience from leadid.
            // lstWorkExperience = [SELECT id,nm_Student__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c,Experience_Level__c, FROM nm_WorkExperience__c WHERE nm_Lead__c=:LeadId];
            // System.debug('---------------------lstWorkExperience---------------');
            // System.debug(lstWorkExperience);
            if(lstWorkExperience.size() == 0 || lstWorkExperience == null){
                AddExperience();
            }
            checkShippingSamePermanent();
            getProgramsList();

            // to create the cookie
            if(String.isBlank(getCookie())) {
                setCookie(LeadId);
            }

            String modalJSON = getCookieForObjOTP();
            System.debug('Modal cookie --> ' + modalJSON);
            if (String.isNotBlank(modalJSON)) {
                IsLeadJustInserted = true;
                objOTP = (OTPFields)JSON.deserialize(modalJSON, OTPFields.class);
                System.debug('objOTP cookie --> ' + objOTP);
            }
        } else {
            getProgramsList();
        }
    }
    
    
    /**
    * @description
    * @method call from Confirmation Page
    * @return PageReference
    */
    public PageReference GoToEditTab(){
        String page = 'AdmissionForm?';  
        if(objLead.LeadSource!='' && objLead.LeadSource!=null && objLead.LeadSource == 'Corporate') {
            page = 'CorporateMBACompleteForm?batch=' + System.Label.Conneqt_Batch + '&';
        }
        
        PageReference pg = new PageReference('/apex/'+page+'id='+LeadId+'&sectionName='+sectionName+'&IsEditFormConfirmation=true');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference nextPage(){
        System.debug('objLead---'+objLead);
        checkExistingLead();
        clearCookieForObjOTP();
        if(validateFormOnServerSide()) {
            return null;
        }
        if(LeadId =='' || LeadId == null){
            objLead.Status = 'Not Contacted';
            objLead.LeadSource = 'Web';
            if(String.isNotBlank(corporateBatchName)) {
                objLead.LeadSource = 'Corporate';
            }
            objLead.nm_IPForLead__c = ipAddress;
            objLead.nm_PaymentStatus__c ='';
            objLead.Partial_form_filled__c = true;
            objLead.StudentLogin__c=false;
            // Lead Routing 
            LeadRouting();
            try{
                insert objLead;
                LeadId = objLead.id;
                objLead.id = null;
                if(objOTP.optStatus != 'OTP Verified' && System.label.Allow_OTP_For_Registration == 'TRUE' && !objOTP.skipOTP ) {
                    registrationButton = '';
                    IsLeadJustInserted = true;
                    validateOTPStatus();
                }
                QueryLeadData();
            }catch(Exception e){
                System.debug('Error-->' + String.valueof(e));
                ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
                if(string.valueof(e).contains('duplicate value found') && string.valueof(e).contains('nm_CheckforDuplicacy__c')){
                    ErrorMessage('Mobile no already exist. Please enter valid mobile no.','PopUpError');
                }
            }
        }else{
            try{
                CopyAddress();
                isDupChecked = isDuplicateAccountExist();
                if(isDupChecked=='Duplicate') {
                    System.debug('isDuplicateAccountExist--->');
                    LeadId = null;
                    ErrorMessage('Duplicate record found. Kindly contact ngasce@nmims.edu','PopUpError');
                    return null;
                } 
                // else if(registrationButton != 'registrationButton' && validateImageUrl()) {
                //     System.debug('Student Image is Missing--->');
                //     ErrorMessage('Please Upload Photo.','PopUpError');
                //     return null;
                // }
                if(objOTP.optStatus != 'OTP Verified' && System.label.Allow_OTP_For_Registration == 'TRUE' && !objOTP.skipOTP && registrationButton == 'registrationButton') {
                    IsLeadJustInserted = true;
                    registrationButton = '';
                    validateOTPStatus();
                }
                objLead.id = LeadId;
                objLead.Partial_form_filled__c = true;
                objLead.StudentLogin__c=false;
                update objLead;
                objLead.id = null;
                if(lstWorkExperience.size() == 0) {
                    QueryLeadData();
                }
            }catch(Exception e){
                System.debug('Error-->' + String.valueof(e));
                ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
                if(string.valueof(e).contains('duplicate value found') && string.valueof(e).contains('nm_CheckforDuplicacy__c')){
                    ErrorMessage('Mobile no already exist. Please enter valid mobile no.','PopUpError');
                }
            }
        }
        
        return null;
    }
    
    public PageReference GoToConfirmationForm(){
        try{
            isDupChecked = isDuplicateAccountExist();
            System.debug('isDupChecked--->'+isDupChecked);
            if(isDupChecked=='Duplicate') {
                System.debug('isDuplicateAccountExist--->');
                ErrorMessage('Duplicate record found. Kindly contact ngasce@nmims.edu','PopUpError');
                return null;
            } 
            // else if(validateImageUrl()) {
            //     System.debug('Student Image is Missing--->');
            //     ErrorMessage('Please Upload Photo.','PopUpError');
            //     return null;
            // }
            String page = 'ConfirmationForm';
            //to save work expereience
            Boolean SaveWorkExp = SaveWorkExp();
            Boolean calculateAcademicScore = calculateAcademicScore();
            objLead.Partial_form_filled__c = false;
            System.debug('objLead in GoToConfirmationForm '+objLead);
            Lead objNewLead = objLead.clone();
            objNewLead.id=LeadId;
            objNewLead.nm_PaymentStatus__c ='';
            if(objNewLead.Status!='Registration Fee Paid' && objNewLead.Status!='Admission Fee Paid'){
                objNewLead.Status ='Registration Form Filled';
            } 
            if(objNewLead.nm_ChooseaProgram__c == 'Master Programs' && programNameForSpecialization!='MBA' && SaveWorkExp && calculateAcademicScore){
                return null;
            }else{
                update objNewLead;
                page = 'AdmissionConfirmationForm';
                PageReference pg = new PageReference('/apex/'+page+'?id='+LeadId);
                pg.setRedirect(true);
                return pg;
            }
            
        }catch(Exception e){
            ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
            return null;
        }
    }
    
   
    public void checkExistingLead(){
        String registrationNo = objLead.nm_RegistrationNo__c;
        String LeadEmail = objLead.Email;
        String LeadMobilePhone = objLead.MobilePhone;
        String RebornEmail = 'reborn_'+objLead.Email;
        String RebornPhone = objLead.MobilePhone+'0000';
        String ChooseProgram = objLead.nm_ChooseaProgram__c;
        Boolean allowBachelor = objLead.nm_InformationCenter__r.Allow_Bachelor__c;
        String ProgramType = objLead.Program_Type__c;
        String queryDuplicateLead;
        String queryRebornLead;
        System.debug('Mobile -->'+objLead.MobilePhone +'  Email -->'+objLead.Email);
        String LeadQuery = LeadQuery();
        String queryReLoginLead = LeadQuery + ' WHERE nm_RegistrationNo__c=:registrationNo AND isConverted=false LIMIT 1';
        queryRebornLead = LeadQuery + ' WHERE (email=:RebornEmail OR MobilePhone=:RebornPhone) AND isConverted = false LIMIT 1';
        queryDuplicateLead = LeadQuery + ' WHERE (email=:LeadEmail OR MobilePhone=:LeadMobilePhone) AND LeadSource!=\'Partner\' AND isConverted=false LIMIT 1';
        List<Lead> lstExistingLead  = new List<Lead>();
        if(IsReLogin){
            lstExistingLead = DataBase.query(queryReLoginLead);
        } else {
            List<Lead> lstRebornLead = DataBase.query(queryRebornLead);
            if(lstRebornLead != null && lstRebornLead.size() > 0) {
                if(ChooseProgram.contains('Bachelor') && lstRebornLead[0].nm_InformationCenter__r.Allow_Bachelor__c) 
                {
                    lstExistingLead = lstRebornLead;
                    objLead.Email = lstExistingLead[0].Email;
                    objLead.MobilePhone = lstExistingLead[0].MobilePhone;
                }else if(!ChooseProgram.contains('Bachelor')){
                        lstExistingLead = lstRebornLead;
                        objLead.Email = lstExistingLead[0].Email;
                        objLead.MobilePhone = lstExistingLead[0].MobilePhone;
                }
            }else{
                lstExistingLead = DataBase.query(queryDuplicateLead);
                if(lstExistingLead.size() > 0 ){
                    if(ChooseProgram.contains('Bachelor') && lstExistingLead[0].nm_InformationCenter__r.Allow_Bachelor__c) 
                    {
                        objLead.Email = lstExistingLead[0].Email;
                        objLead.MobilePhone = lstExistingLead[0].MobilePhone;
                    }else if(!ChooseProgram.contains('Bachelor')){
                        objLead.Email = lstExistingLead[0].Email;
                        objLead.MobilePhone = lstExistingLead[0].MobilePhone;

                    }
                }
            }
        }
        
        if(lstExistingLead !=null && lstExistingLead.size() > 0 ){
            String newLeadJsonString = JSON.serialize(objLead);
            System.debug('newLeadJsonString ---'+newLeadJsonString);
            Map<String,Object> mapOfNewLeadParameters = (Map<String,Object>)Json.deserializeUntyped(newLeadJsonString);
            
            for(Lead existingLead : lstExistingLead) {
                String oldLeadJsonString = JSON.serialize(existingLead);
                System.debug('oldLeadJsonString--'+oldLeadJsonString);
                Map<String,Object> mapOfOldLeadParameters = (Map<String,Object>)Json.deserializeUntyped(oldLeadJsonString);
                
                // allowed same student to registered for Executive Program and any other program at same time
                if(existingLead.nm_ChooseaProgram__c !=null && existingLead.nm_ChooseaProgram__c != objLead.nm_ChooseaProgram__c  && 'Executive Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c)){
                    System.debug('choose program returned');
                    return;
                }
                

                // allowed same student to registered for Master Program for upgrad and any other program at same time
                // if('Master Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) && String.isNotBlank(objLead.Program_Type__c) && existingLead.Program_Type__c!=objLead.Program_Type__c 
                //     && ('MBA (X)'.equalsIgnoreCase(objLead.Program_Type__c) || existingLead.Program_Type__c == 'MBA (X)') && existingLead.nm_InformationCenter__c!=objLead.nm_InformationCenter__c){
                //     System.debug('choose program returned for upgrad');
                //     return;
                // }
                if(existingLead.nm_InformationCenter__c !=null && existingLead.nm_InformationCenter__r.Nm_Active__c && !existingLead.nm_InformationCenter__r.Allow_Bachelor__c && 'Bachelor Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) ) {
                    System.debug('same ic selected');
                    return;
                    
                }

                if(existingLead.nm_EligiblityCriteria__c!=null && existingLead.nm_ChooseaProgram__c != objLead.nm_ChooseaProgram__c) {
                    objLead.nm_EligiblityCriteria__c = null;
                }

                if(existingLead.nm_InformationCenter__c !=null && existingLead.nm_InformationCenter__r.Nm_Active__c && existingLead.nm_InformationCenter__r.Allow_Degree__c && 'Master Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) ) {
                    System.debug('same ic selected');
                    objLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__c;
                    
                }else if(existingLead.nm_InformationCenter__c !=null && existingLead.nm_InformationCenter__r.Nm_Active__c && existingLead.nm_InformationCenter__r.Allow_Bachelor__c && 'Bachelor Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) ) {
                    System.debug('same ic selected');
                    objLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__c;
                    
                }
                else if(!existingLead.nm_InformationCenter__r.Nm_Active__c  && existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null )
                {
                    if('Bachelor Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c))
                    {
                        objLead.nm_InformationCenter__c = System.Label.LC_bachelorID;

                    }else{
                        objLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__r.nm_LearningCenter__c;                        
                    }
                     
                }
                else if(existingLead.nm_InformationCenter__c !=null && !existingLead.nm_InformationCenter__r.Allow_Degree__c && existingLead.LeadSource != 'Partner' && 'Master Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c)) {
                                        
                   if(existingLead.nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c && existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null){
                        System.debug('lc selected');
                        objLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__r.nm_LearningCenter__c;
                    }else{
                        System.debug('counselor selected');
                        Map<String,nm_Centers__c> mapOfCenterNameVsCenter = getMapOfCenterNameVsCenter();
                        if(mapOfCenterNameVsCenter.containsKey('Counsellor')) {
                            objLead.nm_InformationCenter__c = mapOfCenterNameVsCenter.get('Counsellor').id;
                        }
                    }
                } else if(existingLead.LeadSource == 'Partner') {
                    System.debug('partner selected');
                    return;
                }

                LeadId = existingLead.id;
            
                IsReLogin = true;
                Map<String,String> mapOfEditableFieldAPIVSDataType = getMapOfEditableVsDataTypeOfFieldForSObject('Lead');
                List<String> skipField = new List<String>{'Address','nm_EligiblityCriteria__c'};
                if(!mapOfNewLeadParameters.isEmpty() && !mapOfOldLeadParameters.isEmpty()){
                    for(String oldValueKey : mapOfOldLeadParameters.keySet()){
                        if(!mapOfNewLeadParameters.containsKey(oldValueKey)){
                            if(mapOfOldLeadParameters.get(oldValueKey) !=null && mapOfEditableFieldAPIVSDataType.containsKey(oldValueKey.toLowerCase()) && !skipField.contains(oldValueKey)){
                                System.debug('oldValueKey--'+oldValueKey+'----value---'+mapOfEditableFieldAPIVSDataType.get(oldValueKey.toLowerCase()));
                                if('DATETIME'.equalsIgnoreCase(mapOfEditableFieldAPIVSDataType.get(oldValueKey.toLowerCase()))){
                                    objLead.put(oldValueKey,setStringToDateFormat(String.valueOf(mapOfOldLeadParameters.get(oldValueKey))));
                                }else if('DATE'.equalsIgnoreCase(mapOfEditableFieldAPIVSDataType.get(oldValueKey.toLowerCase()))) {
                                    objLead.put(oldValueKey,Date.valueOf(String.valueOf(mapOfOldLeadParameters.get(oldValueKey))));
                                }else {
                                    objLead.put(oldValueKey,mapOfOldLeadParameters.get(oldValueKey));
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
    
    public Boolean validateFormOnServerSide(){
        ErrorMessage('','');
        List<String> errorMessage = new List<String>();
        Integer days = objLead.nm_DateOfBirth__c!=null ? objLead.nm_DateOfBirth__c.daysBetween(Date.Today()) : 1;
        Integer age = Integer.valueOf(days/365);
        if(!(age >= 17 || (age >= 16 && objLead.nm_ChooseaProgram__c == 'Bachelor Programs'))) {
            errorMessage.add('Date of Birth cannot be less than Eligible age years.');
        }
        System.debug('errorMessage---'+errorMessage);
        if(errorMessage.size() > 0){
            ErrorMessage(String.join(errorMessage,'<br/>'),'PopUpError');
            return true;
        }
        return false;
    }

    public void validateOTPStatus() {
        system.debug('objOTP. --> ' + JSON.serialize(objOTP));
        objOTP.lstMsg.clear();
            if(String.isBlank(objOTP.optStatus)) {
                sendOTP();
            } else if(objOTP.optStatus == '903') {
                objOTP.lstMsg.add('Incorrect OTP Entered, kindly try again.');
                sendOTP();
            } else if(objOTP.optStatus == '907') {
                objOTP.lstMsg.add('OTP has been expired, kindly try again.');
                sendOTP();
            } else {
                objOTP.lstMsg.add('OTP Verification has been failed, kindly try again');
                sendOTP();
            }
            system.debug('optStatus --> '  + objOTP.optStatus);
        }

        public void sendOTP() {
            String recordId = String.isBlank(objLead.id) ? LeadId : objLead.id;
            List<Lead> mbLead = [SELECT Id,Is_Mobile_Verified__c,nm_IsEmailVerified__c FROM Lead WHERE Id = :recordId LIMIT 1];
            if (!mbLead[0].nm_IsEmailVerified__c || objOTP.OtpMode == 'E') {
                objOTP.modalToShow = 'otpVerify';
                String smsMessage = generateOTPMSG();
                sendEmailOTP();
                objOTP.OtpMode = 'E';
                objOTP.optStatus = 'OTP Sent';
                objOTP.lstMsg.add(objOTP.alertMsg);
                String objOTPJSON = JSON.serialize(objOTP);
                System.debug('objOTPJSON-->'+objOTPJSON);
                setCookieForObjOTP(objOTPJSON);
                
            } else if(!mbLead[0].Is_Mobile_Verified__c || objOTP.OtpMode == 'M') {
                if(System.Label.Enable_SMS_Service=='Yes'){
                    objOTP.modalToShow = 'otpVerify';
                    String smsMessage = generateOTPMSG();
                    sendmGageSMSFuture(objLead.MobilePhone.left(10),smsMessage);
                    objOTP.OtpMode = 'M';
                    objOTP.alertMsg = 'OTP has been sent to your mobile no ******'+objLead.MobilePhone.right(4);
                    objOTP.optStatus = 'OTP Sent';
                    objOTP.lstMsg.add(objOTP.alertMsg);
                    String objOTPJSON = JSON.serialize(objOTP);
                    setCookieForObjOTP(objOTPJSON);
                    System.debug('optStatus-->'+objOTP.optStatus);
                }
            } else if (mbLead[0].nm_IsEmailVerified__c && mbLead[0].Is_Mobile_Verified__c && String.isBlank(objOTP.OtpMode)) {
                objOTP.OtpMode = 'D';
                String objOTPJSON = JSON.serialize(objOTP);
                setCookieForObjOTP(objOTPJSON);
                system.debug('objOTP.OtpMode --> ' + objOTP.OtpMode);
            }
            
        } 
        
        public void sendEmailOTP() {
            String recordId = String.isBlank(objLead.id) ? LeadId : objLead.id;
            try {
                Lead objupdateLead = new Lead();
                objupdateLead.Email_Verification_Token__c = objOTP.OtpCode;
                objupdateLead.id = recordId;
                update objupdateLead;
                
                // // To Query Organisation Details. moved to flow
                // OrgWideEmailAddress owe = [SELECT id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
                // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                // mail.setOrgWideEmailAddressId(owe.id);
                // mail.setReplyTo(owe.Address);
                //     // To Query the Email Template.
                // EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Lead' LIMIT 1];
                // mail.setTargetObjectId(recordId);
                // mail.setTemplateId(emailTemplate.Id);
                
                // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);

                EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE name = 'OTP Email Template for Lead' LIMIT 1];
                SendEmailForOTP.callEmailAlertFlow(recordId, emailTemplate.Id);
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

        @future(callout=true)
        public static void sendmGageSMSFuture(String mobileNumber, String msg){        
            SMSSenderWebService.sendmGageSMS(mobileNumber, msg) ;
        }

        public void VerifyOTP() {
            clearCookieForObjOTP();
            system.debug('VerifyOTP --> called');
            if(String.isNotBlank(objOTP.Otp)) {
                Long otpEnteredTime = DateTime.now().getTime();
                Long milliseconds = otpEnteredTime - objOTP.otpSentTime;
                Long seconds = milliseconds / 1000;
                if(objOTP.OtpCode == objOTP.Otp && seconds <= 180){
                    objOTP.optStatus = 'OTP Verified';
                    objOTP.modalToShow = 'OTP Verified';
                    
                    IsLeadJustInserted = false;
                    objOTP.lstMsg.clear();
                    String recordId = String.isBlank(objLead.id) ? LeadId : objLead.id;
                    if(String.isNotBlank(recordId)) {
                        List<Lead> mbLead = [SELECT Id,Is_Mobile_Verified__c,nm_IsEmailVerified__c FROM Lead WHERE Id = :recordId LIMIT 1];
                        if (mbLead.size() > 0 &&  !mbLead[0].Is_Mobile_Verified__c && objOTP.OtpMode == 'M') {
                            Lead upLead = new Lead(Id = recordId, Is_Mobile_Verified__c = true, Mobile_Verification_Token__c = objOTP.OtpCode);
                            update upLead;
                            objOTP.optStatus = '';
                            objOTP.OtpMode = 'A';
                            validateOTPStatus();
                        } else if(mbLead.size() > 0 &&  !mbLead[0].nm_IsEmailVerified__c && objOTP.OtpMode == 'E') {
                            Lead upLead = new Lead(Id = recordId, nm_IsEmailVerified__c = true);
                            objOTP.optStatus = '';
                            objOTP.OtpMode = 'A';
                            update upLead;
                            validateOTPStatus();
                        }
                    }
                }else if(objOTP.OtpCode != objOTP.Otp) {
                    objOTP.optStatus = '903';
                    objOTP.lstMsg.clear();
                    objOTP.lstMsg.add('Incorrect OTP Entered, kindly try again.');
                }else if(seconds > 180){
                    objOTP.optStatus = '907';
                    objOTP.lstMsg.clear();
                    objOTP.lstMsg.add('OTP has been expired, kindly try again.');
                }else{
                    objOTP.optStatus = '906';
                    objOTP.lstMsg.clear();
                    objOTP.lstMsg.add('OTP Verification has been failed, kindly try again.');
                }
                String objOTPJSON = JSON.serialize(objOTP);
                setCookieForObjOTP(objOTPJSON);
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
            String smsMessage = objOTP.OtpCode +' is your verification code for NMIMS CDOE.';
            objOTP.otpSentTime = DateTime.now().getTime();
            return smsMessage;
            // return '';
        }
    
    public void LeadRouting(){
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
    }

    /**
    * @description
    * @author Balakrishnan | 18/3/2019
    * @return void
    * To get Lateral Student Details.
    */
    public void getLateralStudentDetailsAPI() {
        try {
            AlumniMessage = '';
            System.debug('Student Lateral Number -->' + objLead.Student_Number_Lateral__c);
            String lateralNo = objLead.Student_Number_Lateral__c;
            List<Account> lstClosedStudentProgram = [SELECT Id, nm_Program__r.nm_ProgramName__c, nm_Program__r.nm_Type__c, nm_Program__r.Name, nm_Program__r.nm_TotalSemesters__c, Name, nm_DateOfBirth__c, Pass_Out__c, Program_Name__c, Passing_Year__c, Passing_Month__c, nm_ChooseaProgram__c, BatchStartD__c FROM Account WHERE Student_ID__c != null AND Student_ID__c LIKE :lateralNo LIMIT 1];
            Account objAcc = lstClosedStudentProgram.size() > 0 ? lstClosedStudentProgram[0] : null;
            String name = objLead.FirstName.trim() + ' ' + objLead.LastName.trim();
            System.debug('Lateral Account -->' + JSON.serialize(objAcc));
            if(objAcc != null) {
                if(objAcc.Name != name || objAcc.nm_DateOfBirth__c != objLead.nm_DateOfBirth__c) {
                    AlumniMessage = 'Student Name and Date of Birth does not Match.'; 
                    return;
                }
            }
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

            if(passout) {
                if((objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objAcc.nm_ChooseaProgram__c == 'Diploma Programs') ||
                ((objLead.nm_ChooseaProgram__c.startsWith('Diploma') || (objLead.nm_ChooseaProgram__c.contains('Master Programs') && programNameForSpecialization=='MBA')) &&
                objAcc.nm_ChooseaProgram__c == 'Certificate Programs' && objAcc.nm_Program__r.Name == 'CBM' && objAcc.BatchStartD__c > date.newinstance(2019, 1, 1)) ||
                ((objLead.nm_ChooseaProgram__c.contains('Master Programs') && programNameForSpecialization=='MBA') && objAcc.nm_ChooseaProgram__c == 'Diploma Programs'))  {
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
                    AlumniMessage = 'Student has not cleared the program.';
                } else if (Status == 'Invalid') {
                    AlumniMessage = 'Invalid Student Number.';
                } else {
                    AlumniMessage = 'Internal error occured. Kindly contact your Authorized Enrolment Partner.';
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            AlumniMessage = 'Internal error occured. Kindly contact your Authorized Enrolment Partner.';
            // ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.', 'PopUpError');
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

    // to check if any duplicate Account Exist
    public String isDuplicateAccountExist(){
        system.debug('isDupChecked-->'+isDupChecked);
        if(isDupChecked==null || isDupChecked=='' || isDupChecked=='Duplicate' ) {
            String chooseProgram = objLead.nm_ChooseaProgram__c;
            List<Account> lstAccount = new List<Account>();
            if('Certificate Programs'.equalsIgnoreCase(chooseProgram))
            {
                lstAccount = [SELECT id FROM Account WHERE (PersonEmail=:objLead.Email OR PersonMobilePhone=:objLead.MobilePhone)
                AND nm_ChooseaProgram__c=:chooseProgram and  (Pass_Out__c = false and Active_account__c = true) LIMIT 1];
            }else
            {
                lstAccount = [SELECT id FROM Account WHERE (PersonEmail=:objLead.Email OR PersonMobilePhone=:objLead.MobilePhone)
                AND nm_ChooseaProgram__c!='Certificate Programs' and  (Pass_Out__c = false and Active_account__c = true) LIMIT 1];
            }            
           
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
    * @author @BK | 08-18-2024 
    * @param serviceType 
    **/
    public void updateAddressDetails() {
        if(String.isNotBlank(Postalcode)) {
            // Create an instance of GeocodeController
            GeocodeController geocodeController = new GeocodeController();
                    
            // Call the processGeocode method
            GeocodeResult result = geocodeController.processGeocode(Postalcode, System.Label.GeoCodeServiceType);

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
        PostalCodeMessage = result.postalCodeMessage;
    }
     
    /**
    * @description
    * @author Balakrishnan | 18/3/2019
    * @return void CopyAddress From shipping to permanent and billing
    */
    public void CopyAddress(){
        if(CopyPermanantAddressFromTo == 'SameAsShipping'){
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
        }else if(CopyPermanantAddressFromTo == 'NewAddress') {
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
    
    public List<SelectOption> getElegibilityCriteriaList(){
        List<SelectOption> lstECOptions = new List<SelectOption>();
        Map<String,String> mapOfEligibilityVsWorkExp = new Map<String,String>();
        Map<String,Decimal> mapOfEligibilityVsRequiredAcademicPercentage = new Map<String,Decimal>();
        mapOfEligibilityVsRequiredAcademic = new Map<String,Boolean>();
        Map<String,Boolean> mapOfEligibilityVsMaster = new Map<String,Boolean>();
        
        String chooseProgram = objLead.nm_ChooseaProgram__c;
        String programType;
        if(String.isNotBlank(chooseProgram) && chooseProgram.equals('Master Programs')) {
            programType = programNameForSpecialization;
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
    
    public List<SelectOption> getProgramsList(){
        List<SelectOption> lstProgramsOptions = new List<SelectOption>();
        Map<String,Id> MapOfSpecialisationVsId = new Map<String,Id>();
        String chooseProgram = objLead.nm_ChooseaProgram__c;
        String specalization = objLead.Program_Type__c;
        
        List<nm_Program__c> lstActiveProgram = new List<nm_Program__c>();
        system.debug('programNameForSpecialization ---> ' + programNameForSpecialization);
        if(chooseProgram == 'Master Programs' || chooseProgram == 'Bachelor Programs') {
            lstActiveProgram = [SELECT id,nm_ProgramName__c, Form_Specialisation__c,Specialisation__c FROM nm_Program__c WHERE nm_Type__c=:chooseProgram AND Specialisation__c=:programNameForSpecialization AND nmIsActive__c=true ORDER BY Name ASC];
            lstProgramsOptions.add(new SelectOption('', 'Choose Specialization'));
        } 
        else {
            chooseProgram = String.isBlank(chooseProgram) ? 'Certifcate Programs' : chooseProgram;
            lstActiveProgram = [SELECT id,nm_ProgramName__c,Specialisation__c,Form_Specialisation__c FROM nm_Program__c WHERE nm_Type__c=:chooseProgram AND nmIsActive__c=true ORDER BY Name ASC];
            lstProgramsOptions.add(new SelectOption('', 'Choose Program'));
        }
        System.debug('lstActiveProgram--'+lstActiveProgram);
        if(lstActiveProgram.size() > 0){
            for(nm_Program__c objProgram : lstActiveProgram){
                if((chooseProgram == 'Master Programs' || chooseProgram == 'Bachelor Programs') && objProgram.Form_Specialisation__c!=null) {
                    String prgName = objProgram.Form_Specialisation__c!=null ? objProgram.Form_Specialisation__c : objProgram.nm_ProgramName__c;
                    lstProgramsOptions.add(new SelectOption(objProgram.id, prgName));
                } else {
                    lstProgramsOptions.add(new SelectOption(objProgram.id, objProgram.nm_ProgramName__c));
                }
                MapOfIdVsProgram.put(objProgram.id,objProgram);
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

    public List<SelectOption> getSpecializationList(){
        Map<String,String> mapOfSpecialisationForMaster = new Map<String,String>{
            'MBA (WX)' => 'Master of Business Administration (Working Executive)',
            'MBA' => 'Master of Business Administration'
        };
        Map<String,String> mapOfSpecialisationForBachelor = new Map<String,String>{
            'BCom' => 'Bachelor of Commerce',
            'BBA' => 'Bachelor of Business Administration'
        };

        List<SelectOption> lstProgramsOptions = new List<SelectOption>();
        lstProgramsOptions.add(new SelectOption('', 'Choose Program'));
        if(objLead.nm_ChooseaProgram__c == 'Master Programs') {
            for (String spec : mapOfSpecialisationForMaster.keySet()) {
                lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForMaster.get(spec)));
            }
        } else if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs') {
            for (String spec : mapOfSpecialisationForBachelor.keySet()) {
                lstProgramsOptions.add(new SelectOption(spec, mapOfSpecialisationForBachelor.get(spec)));
            }
        }
        return lstProgramsOptions;
    }

    /**
    * @description To calculate Academic Scores
    * @author Balakrishnan | 18/3/2019
    * @return Boolean 
    */
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
            return result;
        } catch (Exception e) {
            System.debug(e);
            ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
            return true;
        }
    }

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
    
    public List<SelectOption> getAllLeadsource(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Lead.Howdidyougettoknowabouttheprogram__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','Lead Source'));
        for( Schema.PicklistEntry f : ple) {
            if(f.getLabel() !='Partner' && f.getValue() !='Partner'){
              options.add(new SelectOption(f.getLabel(), f.getValue()));
            }  
        }       
        return options;
    }
   
    public List<SelectOption> getAllPublication(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult1 = Lead.nm_Publications__c.getDescribe();
        List<Schema.PicklistEntry> plu = fieldResult1.getPicklistValues();
        
        for( Schema.PicklistEntry p : plu) {
            options.add(new SelectOption(p.getLabel(), p.getValue())); 
        }       
        return options;
    }
    
    public list<SelectOption> getGraduationDegreeMode(){
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('','---None--'));
        options.add(new SelectOption('Full Time','Full Time'));
        options.add(new SelectOption('Part Time','Part Time'));
        options.add(new SelectOption('Distance Learning','Distance Learning'));
        options.add(new SelectOption('Correspondence','Correspondence'));
        return options;
    }
    
    public List<SelectOption> getLateralOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Do you want to opt for Lateral Admission?'));
        options.add(new SelectOption('true','Yes'));
        options.add(new SelectOption('false','No'));
        return options; 
    } 

    //for MBA Executive Programs
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
    
    public List<SelectOption> getAllInformationCenters() {
        List<SelectOption> lstICOptions = new List<SelectOption>();
        List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
        lstICOptions.add(new SelectOption('','---None--'));
        system.debug('objLead.nm_Program__c --> ' + objLead.nm_Program__c);
        system.debug('objLead.Program_Type__c --> ' + objLead.Program_Type__c);
        system.debug('programNameForSpecialization --> ' + programNameForSpecialization);
        String queryCity = 'SELECT id,Name,nm_Active__c,RegistrationClosed__c,Allow_Degree__c,Allow_Bachelor__c, Registration_City__c FROM nm_Centers__c WHERE nm_Active__c=true AND RegistrationClosed__c=false';
        if(objLead.nm_ChooseaProgram__c == 'Master Programs') {
            // queryCity = queryCity + ' AND (Allow_Degree__c=true AND Allow_MBA_WX__c=true)';
            queryCity = queryCity + ' AND (Allow_Degree__c=true)';
        } else if(objLead.nm_ChooseaProgram__c == 'Bachelor Programs') {
            queryCity = queryCity + ' AND Allow_Bachelor__c = true';
        }
        lstActiveCenters = Database.query(queryCity);
        if(lstActiveCenters.size() > 0 && String.isNotBlank(objLead.nm_ChooseaProgram__c)){
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
        return lstICOptions;
    } 

   
    /**
    * @description
    * @author Balakrishnan | 18/3/2019
    * @return void, Method to add Experience 
    */
    public void AddExperience() { 
        nm_WorkExperience__c objWE = new nm_WorkExperience__c();
        objWE.id = null;
        lstWorkExperience.add(objWE);
    }

    /**
    * @description
    * @author Balakrishnan | 18/3/2019
    * @return void Method to remove Experience 
    */
    public void RemoveExperience() {
        Integer strRowNo = lstWorkExperience.size();
        if(strRowNo != null && strRowNo > 1){
            Integer IndexVal = integer.valueOf(strRowNo) - 1;
            String WEXPName = lstWorkExperience[IndexVal].Name;
            System.debug('WEXPName ==>'+WEXPName);
            // String RemoveExperienceId = lstWorkExperience[IndexVal].Id;
            String RemoveExperienceId = String.isNotBlank(WEXPName) && mapOfNameVsId.containsKey(WEXPName) ? mapOfNameVsId.get(WEXPName) : null;
            if(RemoveExperienceId != '' && RemoveExperienceId != null){
                RemovedWorkExperience.add(RemoveExperienceId);
            }
            lstWorkExperience.remove(IndexVal);

        }  
    }
    
    /*------- Method to Redirect to payment -----*/
    public pageReference MakePayment() {
        if( LeadId != null && LeadId != '') {    
            String sitebaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String fullURL = sitebaseURL + System.Label.GoToAdmissionPayment_Url + 'id=' + LeadId;
            if(icValue == 'true') {
                fullURL = fullURL + '&IC=true';
            }
            System.debug('siteURL ==>'+fullURL);
            PageReference pgURL = new PageReference(fullURL);//payOpt=3
            pgURL.setRedirect(true);
            return pgURL;
            
        }
        return null;
    }
    /*---- End Method to Redirect to payment ---*/

    //to save workexpereince
    public boolean SaveWorkExp(){
        
        try{

            Integer monthDiff = 0;

            List<nm_WorkExperience__c> lstWEToUpsert = new List<nm_WorkExperience__c>();
            if( lstWorkExperience != null && lstWorkExperience.size() > 0  && String.isBlank(objLead.Reason__c))
            {
                System.debug('lstWorkExperience--'+lstWorkExperience);
                for(nm_WorkExperience__c objWE : lstWorkExperience) {
                    objWE.nm_Lead__c = LeadId;
                    objWE.Id = objWE.Name!=null && mapOfNameVsId.containsKey(objWE.Name) ? mapOfNameVsId.get(objWE.Name) : null;
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

                //update workexpereince. 
                if( lstWEToUpsert.size() > 0 ){

                    //to delete removed workexpereince.
                    if(RemovedWorkExperience.size() > 0){
                        delete [select Id from nm_WorkExperience__c where Id in :RemovedWorkExperience];
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
                }
            }else{

                for(nm_WorkExperience__c objWE : lstWorkExperience) {
                    // String RemoveExperienceId = objWE.Id;
                    String RemoveExperienceId = objWE.Name!=null && mapOfNameVsId.containsKey(objWE.Name) ? mapOfNameVsId.get(objWE.Name) : null;
                    if(RemoveExperienceId != '' && RemoveExperienceId != null){
                        RemovedWorkExperience.add(RemoveExperienceId);
                    }
                }
                if(RemovedWorkExperience.size() > 0){
                    delete [select Id from nm_WorkExperience__c where Id in :RemovedWorkExperience];
                }
            }
            return false;
        }
        catch( Exception e){
            ErrorMessage('Internal error occured. Kindly contact your Authorized Enrolment Partner.','PopUpError');
            return true;
        }
    }

    /**
    * @description
    * @author Balakrishnan | 18/3/2019
    * @return void
    * check if shipping address is same as permanent address
    */
    public void checkShippingSamePermanent() {   
        String HouseNo = objLead.nm_HouseNumber_P__c;
        String PostalCode = objLead.nm_PostalCode_P__c;
        if( ( houseNo != null && PostalCode != null ) && houseNo.equalsIgnoreCase(objLead.House_No_Name_Shipping__c) && PostalCode.equalsIgnoreCase(objLead.Zip_Postal_Code_Shipping__c) ){
            CopyPermanantAddressFromTo = 'SameAsShipping';
        }else{
            CopyPermanantAddressFromTo = 'NewAddress';
        }
    }
 
    //For domicile dropdown list
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
    * @author Balakrishnan | 18/3/2019
    * @return String of Lead Query
    */
    public String LeadQuery() {
        String LeadQueryField = 'SELECT id,nm_ChooseaProgram__c,nm_Program__r.Name,nm_InformationCenter__r.Allow_Degree__c,nm_InformationCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.Address__c,'+
            'Status,LeadSource,InactiveLead__c,nm_IPForLead__c,nm_PaymentStatus__c,Partial_form_filled__c,Program_Type__c,nm_RegistrationNo__c,Email,MobilePhone,isConverted,'+
            'nm_InformationCenter__c,nm_StudentSelectedIC__c,Student_Number_Lateral__c,Year_Of_Passing_Lateral__c,Month_Of_Passing_Lateral__c,Course_Name_Lateral__c,'+
            'nm_HouseNumber_P__c,nm_LocalityName_P__c,nm_Street_P__c,nm_StateProvince_P__c,nm_Country_P__c,nm_City_P__c,nm_PostalCode_P__c,nm_Year__c,nm_Session__c,'+
            'House_No_Name_Shipping__c,Locality_Name_Shipping__c,nm_SelfLearningMaterial__c,Shipping_Street__c,State_Province_Shipping__c,Country_Shipping__c,'+
            'Shipping_City__c,Zip_Postal_Code_Shipping__c,nm_HouseNumber__c,nm_LocalityName__c,Street,State,Country,City,PostalCode,'+
            'Shipping_Address_Choice__c,Address,nm_EligiblityCriteria__c,Salutation,FirstName,nm_MiddleName__c,LastName,nm_DateOfBirth__c,Father_Salutation__c,Father_First_Name__c,'+
            'Father_Last_Name__c,Mother_Salutation__c,Mother_First_Name__c,Mother_Last_Name__c,nm_Gender__c,nm_MaritalStatus__c,nm_SpouseName__c,nm_BloodGroup__c,'+
            'nm_Category__c,nm_OtherCategory__c,nm_Domicile__c,nm_Nationality__c,AadharCardNumber__c,Pancard_no__c,nm_Passport__c,nm_STDCode__c,Phone,nm_SecondryEmail__c,'+
            'IC_Name__c,Specialization_Type__c,Program_Preference1__c,nm_Program__c,nm_Program2__c,nm_Interview_Slot_Preference__c,Are_you_from_Defence__c,nm_ServiceNumber__c,'+
            'Relationship__c,nm_DateofCommission__c,Armed_Service__c,Rank__c,nm_NameofBoard__c,nm_10thClassStateBoardName__c,nm_10thPercentage__c,nm_YearofCompletion__c,'+
            'nm_NameofSchool__c,nm_Class12OrDiploma__c,nm_NameofBoard12__c,nm_12thClassStateBoardName__c,nm_YearofCompletion12__c,nm_Stream__c,'+
            'nm_NameofSchool12__c,nm_DiplomaSchoolCollegeUniversityname__c,Result_Diploma__c,nm_DiplomaYearOfCompletion__c,nm_DiplomaName__c,nm_StreamDiploma__c,nm_DurationOfDiploma__c,'+
            'nm_BachelorsDegreeName__c,nm_OtherBachelorsDegreeName__c,nm_Specialization__c,nm_University_Type__c,nm_BachelorsDegreePercentage__c,nm_NameofUniversity__c,'+
            'nm_Other_University_Name__c,nm_GraduationDegreeMode__c,nm_OtherGraduationDegreeMode__c,nm_YearofCollegeCompletion__c,nm_NameOfCollege__c,Name_of_Program1__c,'+
            'Name_of_Program2__c,Name_of_Program3__c,Name_of_College1__c,Name_of_College2__c,Name_of_College3__c,Name_of_University1__c,Name_of_University2__c,Name_of_University3__c,'+
            'Year_of_Passing1__c,Year_of_Passing2__c,Year_of_Passing3__c,Percentage1__c,Percentage2__c,Percentage3__c,Duration_of_Program1__c,Duration_of_Program2__c,'+
            'Duration_of_Program3__c,nm_Duration_of_Program_in_Year1__c,nm_Duration_of_Program_in_Year2__c,nm_Duration_of_Program_in_Year3__c,Graduation_Degree_Mode1__c,'+
            'Graduation_Degree_Mode2__c,Graduation_Degree_Mode3__c,Other_Graduation_Degree_Mode1__c,Other_Graduation_Degree_Mode2__c,Other_Graduation_Degree_Mode3__c,'+
            'Total_Work_Experience__c,Reason__c,LinkedIn_URL__c,SSC_Score__c,HSCOrDiploma_Score__c,Grad_Score__c,Father_Name__c,nm_ProgramName__c,nm_Eligibility_Criteria_Ref__c,'+
            'Mother_Name__c,nmm_BatchName__c,nm_InformationCenter__r.Nm_Active__c,nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,'+
            'Father_s_Email_Id__c,Father_s_Mobile_number__c,Mother_s_Email_Id__c,Mother_s_Mobile_number__c,Differently_abled__c,Your_disability__c,nm_SSC_Rating_Type__c,SSC_Marks_obtained__c,SSC_Marks_Out_Off__c,'+
            'SSC_Examination_State__c,HSC_status__c,HSC_Marks_obtained__c,HSC_Marks_Out_Off__c,HSC_Examination_State__c,nm_HSC_Rating_Type__c,nm_12thPercentage__c,'+
            'Diploma_Examination_State__c,Diploma_Marks_obtained__c,Diploma_Marks_Out_Off__c,Diploma_Percentage__c,Diploma_status__c ,Other_Name_of_Program1__c,Master_s_Degree_Name__c,'+
            'Profile_Name__c,nm_Mother_Tongue__c,nm_Other_Mother_Tongue__c,nm_WorkExperience__c,nm_Other_Reason__c,nm_StudentImageUrl__c,StudentLogin__c,nm_SelectedIC__c, Adhar_Card_Number__c,Is_Lateral__c  FROM Lead';

        return LeadQueryField;
    }

    public Map<String,nm_Centers__c> getMapOfCenterNameVsCenter(){
        Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();
        if(mapOfCenterNameVsCenter.isEmpty()){
            List<nm_Centers__c> lstActiveCenters = [SELECT id,Name FROM nm_Centers__c WHERE Name != null];
            if(lstActiveCenters.size() > 0){
                for(nm_Centers__c objCenter : lstActiveCenters){
                    mapOfCenterNameVsCenter.put(objCenter.Name,objCenter);
                }
            }
        }
        System.debug('mapOfCenterNameVsCenter -->'+mapOfCenterNameVsCenter);
        return mapOfCenterNameVsCenter;
    }

    public Boolean calenderCheckForCorporate(String BatchNamePara){
        
        Date ExpireDate = Date.valueOf(System.Label.Conneqt_Expired_date);
        String BatchName = System.Label.Conneqt_Batch;

        if(ExpireDate != null && BatchName != null){
            if(ExpireDate >= Date.today() && BatchNamePara.equalsIgnoreCase(BatchName)){
                return true;
            }
        }
        return false;
    }

    /**
    * @description For the MBA-X Program Center assign.
    * @author @BK | 14/9/2019 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getAllInformationCentersOnMBAX() {
        List<SelectOption> lstICOptions = new List<SelectOption>();
        String recordCenterId = objLead.nm_InformationCenter__c;
        Map<Id,nm_Centers__c> mapOfIdVsActiveCenters = new Map<Id,nm_Centers__c>([SELECT id,Name,Allow_MBA_X__c FROM nm_Centers__c WHERE recordtype.Name='Information Center' AND Allow_MBA_X__c=true ORDER BY name ASC]);
        if(mapOfIdVsActiveCenters.size() > 0){
            Boolean checkIcContains = String.isNotBlank(IC) ? mapOfIdVsActiveCenters.containsKey(IC) : false;
            for(String nmCenterId : mapOfIdVsActiveCenters.KeySet()){
                nm_Centers__c objCenter = mapOfIdVsActiveCenters.get(nmCenterId);
                if(checkIcContains && IC.equals(nmCenterId) && (String.isBlank(recordCenterId) || recordCenterId.equals(nmCenterId))){
                    lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
                    selectedICName = objCenter.Name;
                    System.debug('objCenter.Name ==>'+objCenter.Name);
                } 
                else if(!checkIcContains && String.isNotBlank(recordCenterId) && recordCenterId.equals(nmCenterId)) {
                    lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
                    System.debug('objCenter.Name ==>'+objCenter.Name);
                    selectedICName = objCenter.Name;
                }
                // else if(!checkIcContains && String.isBlank(recordCenterId) && objCenter.Name=='upGrad') {
                //     lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
                //     selectedICName = objCenter.Name;
                //     System.debug('objCenter.Name ==>'+objCenter.Name);
                // }
            }

            // if(lstICOptions.isEmpty()) {
            //     for(nm_Centers__c objCenter : mapOfIdVsActiveCenters.values()){
            //         if(objCenter.Name=='upGrad') {
            //             lstICOptions.add(new SelectOption(objCenter.id, objCenter.Name));
            //             selectedICName = objCenter.Name;
            //             System.debug('objCenter.Name ==> 2'+objCenter.Name);
            //         }
            //     }
            // }
        }
        return lstICOptions;
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

    public String getCookieForObjOTP() {
        String objOtpJson = null;
        Cookie modalObject = ApexPages.currentPage().getCookies().get('MODALOBJECT');
        String modalToken = modalObject!=null ? modalObject.getValue() : null;
        if(String.isNotBlank(modalToken)) {
            Blob key = Blob.valueOf(System.Label.NgasceSessionKey);
            Blob decrypted = Crypto.decryptWithManagedIV('AES256', key, EncodingUtil.base64Decode(modalToken));
            objOtpJson = decrypted.toString();
        }
        return objOtpJson;
    }

    public void setCookieForObjOTP(String objOtpJson) {
        Blob key = Blob.valueOf(System.Label.NgasceSessionKey);
        Blob data = Blob.valueOf(objOtpJson);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);

        String modalToken = EncodingUtil.base64Encode(encrypted);
        Cookie modalObject = ApexPages.currentPage().getCookies().get('MODALOBJECT');
        modalObject = new Cookie('MODALOBJECT',modalToken,null,3600,true);
        ApexPages.currentPage().setCookies(new Cookie[]{modalObject});
    }

    public void clearCookieForObjOTP() {
        Cookie modalObject = new Cookie('MODALOBJECT','',null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{modalObject});
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
        public String regNo {get;set;}
        public List<String> lstMsg {get;set;}

        public OTPFields() {
            this.optStatus = '';
            this.Otp = '';
            this.resendOtp = 'false';
            this.OtpCode = '';
            this.otpSentTime = 0;
            this.skipOTP = false;
            this.OtpMode = '';
            this.alertMsg = '';
            this.modalToShow = '';
            this.regNo = '';
            this.lstMsg = new List<String>();
        }
    }

    /**
    * @description 
    * @author @BK | 11-04-2022 
    **/
    public void ValidateStudentImage() {
        List<Lead> lstLead = [SELECT id,nm_StudentImageUrl__c FROM Lead WHERE id=:LeadId LIMIT 1];
        imageURL = lstLead[0].nm_StudentImageUrl__c;
    }
    
    /**
    * @description 
    * @author @BK | 11-04-2022 
    * @return Boolean 
    **/
    public Boolean validateImageUrl() {
        ValidateStudentImage();
        return String.isBlank(imageURL) ? true : false;
        // return false;
    }

    @RemoteAction
    public static List<University_List__c> getUniversityList() {
        List<University_List__c> universityList = [SELECT Id, Is_Active__c, University_Name__c, University_Type__c FROM University_List__c WHERE Is_Active__c = true];
        System.debug('University List --> ' + JSON.serialize(universityList));
        return universityList;
    }

}