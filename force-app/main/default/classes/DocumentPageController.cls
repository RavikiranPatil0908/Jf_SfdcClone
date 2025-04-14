/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 14--04--2025
 * @last modified by  : @Ravi
**/
public without sharing class DocumentPageController {

    public Id objectId;
    public String objectType;

    public List<DocumentWrapper> lstDocuments {get;set;}
    public Boolean isRecordExists {get;set;}
    public Boolean isProvisinalWithHold {get;set;}
    public StudentDetails objStudentDetails {get;set;} 
    public FormDetails objDocumentDetails {get;set;}
    public RecordInformations objInformation {get;set;}
    public List<SelectOption> getPickListValuesOfUploadMode {get;set;}
    public DigilockerListDocumentWrapper objListDocuments {get;set;}
    public Boolean isDocumentFetched {get;set;}
    public String clientId {get;set;}
    public String getJsonMapOfFetchedFiles {get;set;}
    public String selectedFile {get;set;}
    public String jsonDocumentList {get;set;}
    public String jsonDocumentModeList {get;set;}
    public MsgHandler msgHandler {get;set;}
    public FormSubmitResponse formSubmitResponse {get;set;}
    public Boolean showOldDocument {get;set;} 
    public Integer countOfUploadedDocuments {get;set;}
    public Boolean hideSubmitButton {get;set;}
    // public Boolean isDigiLockerSelected {get;set;}

    public DocumentPageController() {
        showOldDocument = false; 
        isRecordExists = false;
        objStudentDetails = new StudentDetails();
        objDocumentDetails = new FormDetails();
        objListDocuments = new DigilockerListDocumentWrapper();
        isDocumentFetched = false;
        clientId = '';
        selectedFile = '';
        jsonDocumentList = '';
        jsonDocumentModeList = '';
        msgHandler = new MsgHandler();
        formSubmitResponse = new FormSubmitResponse();
        countOfUploadedDocuments=0;
        hideSubmitButton=false;
        // isDigiLockerSelected = false;
        reIniatlize();
        fetchDocumentsFromDigiLocker();
    }

    public void reIniatlize() {
        lstDocuments = new List<DocumentWrapper>();
        objInformation = new RecordInformations();
    }

    public Id getObjectId() {
		return this.objectId;
	}

    public void setObjectId(Id objectId) {
        this.objectId = objectId;
        if(String.isNotBlank(this.objectId)) {
            queryRecordData(this.objectId);
        }
	}

    public String getObjectType() {
		return this.objectType;
	}

    public void setObjectType(String objectType) {
        this.objectType = objectType;
	}

    public void queryRecordData(Id recordId) {
        reIniatlize();
        List<String> lstStatus = new List<String>{'Created', 'Disapproved', 'Rejected'};
        Set<String> mandatoryDocuments = new Set<String>();
        
        if (this.objectType == 'Account') {
            mandatoryDocuments = setAccountDetails();
            countOfUploadedDocuments= 0;
            processAccountDocuments(recordId, lstStatus, mandatoryDocuments);
        } else {
            mandatoryDocuments = setLeadData();
            countOfUploadedDocuments= 0;
            processLeadDocuments(recordId, lstStatus, mandatoryDocuments);
        }
        
        // Set the flag if documents are present
        isRecordExists = !lstDocuments.isEmpty();
    }
    
    /**
     * Processes documents related to an Account and populates the lstDocuments list.
     * 
     * @param recordId The ID of the Account record.
     * @param lstStatus List of status values to determine if upload should be shown.
     * @param mandatoryDocuments Set of mandatory document names.
     */
    private void processAccountDocuments(Id recordId, List<String> lstStatus, Set<String> mandatoryDocuments) {
        List<nm_LinksForDocuments__c> docs = [SELECT id, nm_DocumentName__c, nm_URLforDocuments__c, nm_Status__c, Document_Upload_Mode__c, nm_ReasonforDisapprove__c, Document_Query__c , nm_Old_URL_for_Documents__c FROM nm_LinksForDocuments__c WHERE nm_Account__c = :recordId];
        
        for (nm_LinksForDocuments__c objDoc : docs) {
            DocumentWrapper doc = createDocumentWrapper(objDoc, lstStatus, mandatoryDocuments);
            if(objDoc.nm_URLforDocuments__c != null ){
                countOfUploadedDocuments=countOfUploadedDocuments+1;
                System.Debug('countOfUploadedDocuments'+countOfUploadedDocuments);
            } 
            lstDocuments.add(doc);
        }
        // Hide submit button if all documents are uploaded
         if(countOfUploadedDocuments == docs.size()){
            hideSubmitButton = true;
            System.Debug('hideSubmitButton'+hideSubmitButton);
         }
    }
    
    /**
     * Processes documents related to a Lead and populates the lstDocuments list.
     * 
     * @param recordId The ID of the Lead record.
     * @param lstStatus List of status values to determine if upload should be shown.
     * @param mandatoryDocuments Set of mandatory document names.
     */
    private void processLeadDocuments(Id recordId, List<String> lstStatus, Set<String> mandatoryDocuments) {
        List<nm_LinksForDocumentsLead__c> docs = [SELECT id, nm_DocumentName__c, nm_URLforDocuments__c, nm_Status__c, Document_Upload_Mode__c FROM nm_LinksForDocumentsLead__c WHERE Lead__c = :recordId];
        
        for (nm_LinksForDocumentsLead__c objDoc : docs) {
            DocumentWrapper doc = createDocumentWrapper(objDoc, lstStatus, mandatoryDocuments);
            if(objDoc.nm_URLforDocuments__c != null ){
                countOfUploadedDocuments=countOfUploadedDocuments+1;
                System.Debug('countOfUploadedDocuments'+countOfUploadedDocuments);
            }
            lstDocuments.add(doc);
        }
        if(countOfUploadedDocuments == docs.size()){
            hideSubmitButton = true;
            System.Debug('hideSubmitButton'+hideSubmitButton);
         }
    }
    
    /**
     * Creates a DocumentWrapper instance based on the provided document details.
     * 
     * @param objDoc The document record.
     * @param lstStatus List of status values to determine if upload should be shown.
     * @param mandatoryDocuments Set of mandatory document names.
     * @return DocumentWrapper The populated DocumentWrapper instance.
     */
    private DocumentWrapper createDocumentWrapper(nm_LinksForDocuments__c objDoc, List<String> lstStatus, Set<String> mandatoryDocuments) {
        DocumentWrapper doc = new DocumentWrapper();
        if(objDoc.nm_Old_URL_for_Documents__c != null){
            showOldDocument =  true ;
        }
        doc.name = objDoc.nm_DocumentName__c;
        doc.oldLink = objDoc.nm_Old_URL_for_Documents__c;     
        doc.showoldDocLink=objDoc.nm_Old_URL_for_Documents__c != null ? true : false; 
        doc.link = objDoc.nm_URLforDocuments__c;                  
        doc.status = objDoc.nm_Status__c;
        doc.showUpload = shouldShowUpload(doc.link, doc.status, lstStatus);
        doc.statusColorCode = getColorCode(doc.status);
        doc.isMandatory = mandatoryDocuments.contains(doc.name);
        doc.objType = 'Account';
        doc.recordId = objDoc.Id;
        doc.resonForIncorrect = objDoc.nm_Status__c == 'Disapproved' 
                                ? objDoc.nm_ReasonforDisapprove__c 
                                : (objDoc.nm_Status__c == 'Documents Incorrect' ? objDoc.Document_Query__c : '');
        doc.documentMode = objDoc.Document_Upload_Mode__c;
        doc.modeOfUpload = !doc.showUpload ? doc.documentMode : '';
        doc.selectedMode = getDocumentMode(doc.recordId);
        return doc;
    }
    
    /**
     * Creates a DocumentWrapper instance based on the provided document details for Leads.
     * 
     * @param objDoc The document record for Lead.
     * @param lstStatus List of status values to determine if upload should be shown.
     * @param mandatoryDocuments Set of mandatory document names.
     * @return DocumentWrapper The populated DocumentWrapper instance.
     */
    private DocumentWrapper createDocumentWrapper(nm_LinksForDocumentsLead__c objDoc, List<String> lstStatus, Set<String> mandatoryDocuments) {
        DocumentWrapper doc = new DocumentWrapper();
        doc.name = objDoc.nm_DocumentName__c;
        doc.link = objDoc.nm_URLforDocuments__c;
        doc.status = objDoc.nm_Status__c;
        doc.showUpload = shouldShowUpload(doc.link, doc.status, lstStatus);
        doc.statusColorCode = getColorCode(doc.status);
        doc.isMandatory = mandatoryDocuments.contains(doc.name);
        doc.objType = 'Lead';
        doc.recordId = objDoc.Id;
        doc.documentMode = objDoc.Document_Upload_Mode__c;
        doc.modeOfUpload = !doc.showUpload ? doc.documentMode : '';
        doc.selectedMode = getDocumentMode(doc.recordId);
        return doc;
    }

    /**
    * @description 
    * @author @BK | 11-09-2024 
    * @param String recordId 
    * @return String 
    **/
    private String getDocumentMode(String recordId) {
        if(!isDocumentFetched) {
            return '';
        }

        List<SelectedDocumentData> selectedDocuments = (List<SelectedDocumentData>)JSON.deserialize(jsonDocumentModeList, List<SelectedDocumentData>.class);
        for (SelectedDocumentData objdoc : selectedDocuments) {
            if(recordId == objdoc.recordId) {
                return objdoc.modeOfUpload;
            }
        }
        return '';
    }
    
    /**
     * Determines if the upload option should be shown based on document details.
     * 
     * @param link The URL of the document.
     * @param status The status of the document.
     * @param lstStatus List of status values to check.
     * @return Boolean True if upload should be shown, otherwise false.
     */
    private Boolean shouldShowUpload(String link, String status, List<String> lstStatus) {
        return String.isBlank(link) || String.isBlank(status) || lstStatus.contains(status) || (status == 'Not Applicable' && String.isBlank(link))  ;
    }
    
    // Method to get mandatory documents for Lead
    private Set<String> setLeadData() {
        List<Lead> lstLead = fetchLeadData(objectId);
        if (lstLead.isEmpty()) {
            return new Set<String>();
        }
        Lead objLead = lstLead[0];
        updateStudentDetailsFromLead(objLead);
        return getMandatoryDocumentsForLead(objLead);
    }

    // Method to get mandatory documents for Account
    private Set<String> setAccountDetails() {
        List<Account> lstAccount = fetchAccountData(objectId);
        if (lstAccount.isEmpty()) {
            return new Set<String>();
        }
        Account objAccount = lstAccount[0];
        if(objAccount.Provisional_With_Hold__c == true && objAccount.nm_StudentStatus__c == 'Confirmed') {    //-----------CHANGED
            isProvisinalWithHold = true;
        }
        
        updateStudentDetailsFromAccount(objAccount);
        return getMandatoryDocumentsForAccount(objAccount);
    }

    // Fetch Lead data based on objectId
    private List<Lead> fetchLeadData(Id leadId) {
        return [SELECT id, nm_RegistrationNo__c, FirstName, LastName, Email, MobilePhone, nm_Eligibility_Criteria_Ref__c, HSC_status__c, 
                nm_Program__r.Form_Specialisation__c, Are_you_from_Defence__c, Relationship__c, nm_ProgramName__c,
                Diploma_status__c, Is_Lateral__c, nm_Program__r.Bachelor_Specialization__c, nm_ChooseaProgram__c, nm_Nationality__c 
                ,nm_Category__c FROM Lead WHERE id = :leadId];
    }

    // Fetch Account data based on objectId
    private List<Account> fetchAccountData(Id accountId) {
        return [SELECT Id, nm_RegistrationNumber__c,Provisional_With_Hold__c , nm_StudentStatus__c, FirstName, LastName, PersonEmail, PersonMobilePhone, Eligibility_Criteria_Ref__c, 
                Program_Type__c, nm_DefencePersonnel__c, nm_Relationship__c, nmStudent_Program__c, HSC_status__c, Diploma_status__c, 
                Is_Lateral__c, nm_Program__r.Bachelor_Specialization__c, nm_Program__r.Form_Specialisation__c, nm_Nationality__c 
                ,nm_Category__c FROM Account WHERE id = :accountId];
    }

    // Update student details from Lead
    private void updateStudentDetailsFromLead(Lead objLead) {
        objStudentDetails.studentNo = objLead.nm_RegistrationNo__c;
        objStudentDetails.studentName = objLead.FirstName + ' ' + objLead.LastName;
        objStudentDetails.firstName = objLead.FirstName;
        objStudentDetails.lastName = objLead.LastName;
        objStudentDetails.studentEmail = objLead.Email;
        objStudentDetails.studentMobileNo = objLead.MobilePhone;
        objStudentDetails.eligibility = objLead.nm_Eligibility_Criteria_Ref__c;
        objStudentDetails.programCategory = objLead.nm_ChooseaProgram__c;
        objStudentDetails.program = objLead.nm_Program__r.Bachelor_Specialization__c;
        objStudentDetails.programSpecialisaton = objLead.nm_Program__r.Form_Specialisation__c;
    }

    // Update student details from Account
    private void updateStudentDetailsFromAccount(Account objAccount) {
        objStudentDetails.studentNo = objAccount.nm_RegistrationNumber__c;
        objStudentDetails.studentName = objAccount.FirstName + ' ' + objAccount.LastName;
        objStudentDetails.firstName = objAccount.FirstName;
        objStudentDetails.lastName = objAccount.LastName;
        objStudentDetails.studentEmail = objAccount.PersonEmail;
        objStudentDetails.studentMobileNo = objAccount.PersonMobilePhone;
        objStudentDetails.eligibility = objAccount.Eligibility_Criteria_Ref__c;
        objStudentDetails.programCategory = objAccount.Program_Type__c;
        objStudentDetails.program = objAccount.nm_Program__r.Bachelor_Specialization__c;
        objStudentDetails.programSpecialisaton = objAccount.nm_Program__r.Form_Specialisation__c;
    }

    // Get mandatory documents for Lead
    private Set<String> getMandatoryDocumentsForLead(Lead objLead) {
        if(String.isBlank(objLead.nm_Eligibility_Criteria_Ref__c)) {
            return new Set<String>();
        }
        GetMandatoryDocuments documentHandler = new GetMandatoryDocuments();
        GetMandatoryDocuments.StudentStatus objStatus = new GetMandatoryDocuments.StudentStatus();
        populateStudentStatus(objStatus, objLead, 'Lead');
        return documentHandler.getMandatoryDocumentsName(objStatus);
    }

    // Get mandatory documents for Account
    private Set<String> getMandatoryDocumentsForAccount(Account objAccount) {
        GetMandatoryDocuments documentHandler = new GetMandatoryDocuments();
        GetMandatoryDocuments.StudentStatus objStatus = new GetMandatoryDocuments.StudentStatus();
        populateStudentStatus(objStatus, objAccount, 'Account');
        return documentHandler.getMandatoryDocumentsName(objStatus);
    }

    // Populate StudentStatus object with details from Lead or Account
    private void populateStudentStatus(GetMandatoryDocuments.StudentStatus objStatus, Lead objLead, String objectType) {
        objStatus.chooseProgram = objLead.nm_ChooseaProgram__c;
        objStatus.eligibilityCriteria = objLead.nm_Eligibility_Criteria_Ref__c;
        objStatus.isDefencePersonnel = objLead.Are_you_from_Defence__c;
        objStatus.relationship = objLead.Relationship__c;
        objStatus.studentProgram = objLead.nm_ProgramName__c;
        objStatus.hscStatus = objLead.HSC_status__c;
        objStatus.diplomaStatus = objLead.Diploma_status__c;
        objStatus.isLateral = objLead.Is_Lateral__c;
        objStatus.recordId = objLead.Id;
        objStatus.isIndian = objLead.nm_Nationality__c == 'Indian';
        objStatus.objectType = objectType;
        objStatus.castCertificateDocument = objLead.nm_Category__c;
    }

    // Overloaded method for Account
    private void populateStudentStatus(GetMandatoryDocuments.StudentStatus objStatus, Account objAccount, String objectType) {
        objStatus.chooseProgram = objAccount.Program_Type__c;
        objStatus.eligibilityCriteria = objAccount.Eligibility_Criteria_Ref__c;
        objStatus.isDefencePersonnel = objAccount.nm_DefencePersonnel__c;
        objStatus.relationship = objAccount.nm_Relationship__c;
        objStatus.studentProgram = objAccount.nmStudent_Program__c;
        objStatus.hscStatus = objAccount.HSC_status__c;
        objStatus.diplomaStatus = objAccount.Diploma_status__c;
        objStatus.isLateral = objAccount.Is_Lateral__c;
        objStatus.recordId = objAccount.Id;
        objStatus.isIndian = objAccount.nm_Nationality__c == 'Indian';
        objStatus.objectType = objectType;
        objStatus.castCertificateDocument = objAccount.nm_Category__c;
    }

    /**
    * @description 
    * @author @BK | 09-02-2024 
    * @param status 
    * @return String 
    **/
    public String getColorCode(String status) {
        if(status == 'Disapproved' || status == 'Rejected' || status == 'Documents incorrect') {
            return '#FF0000';
        } else if(status == 'Submitted' || status == 'Re-Submited') {
            return '#FFBF00';
        } else if(status == 'Approved' || status == 'Provisional' || status == 'Admission Form & Documents Provisional') {
            return '#50C878';
        } else {
            return '#555';
        }
    }

    /**
    * @description 
    * @author @BK | 09-02-2024 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getPickListValuesOfUploadMode(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Select Mode of Upload'));
        Schema.DescribeFieldResult fieldResult = nm_LinksForDocumentsLead__c.Document_Upload_Mode__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            String option = pickListVal.getLabel();
            options.add(new SelectOption(option,option));
        }     
        return options;
    } 

    /**
    * @description 
    * @author @BK | 09-02-2024 
    * @return String 
    **/
    public String getJsonMapOfFetchedFiles(){
        Map<String,String> options = new Map<String,String>();
        if(isDocumentFetched) {
            for( DigilockerListDocumentWrapper.Documents document : objListDocuments.data.documents){
                if(document.file_id.startsWith('digilocker_file')){
                 options.put(document.file_id,document.name);
                }
            }
        }
        return !options.isEmpty() ? JSON.serialize(options) : '';
    } 

    /**
    * @description 
    * @author @BK | 09-02-2024 
    * @return PageReference 
    **/
    public PageReference submitUploadMode() {
        System.debug('method called');
        formSubmitResponse = new FormSubmitResponse();
        if(String.isBlank(jsonDocumentModeList) && validateForm()) {
            return null;
        }

        try {
            Boolean isOtherModeSelected = false;
            Boolean isDigiLockerSelected = false;
            List<SelectedDocumentData> selectedDocuments = getSelectedDocuments();
            for (SelectedDocumentData objdoc : selectedDocuments) {
                if(String.isNotBlank(objdoc.modeOfUpload)) {
                    isDigiLockerSelected = objdoc.modeOfUpload == 'Upload via DigiLocker' || isDigiLockerSelected ? true : false;
                    isOtherModeSelected = objdoc.modeOfUpload != 'Upload via DigiLocker' || isOtherModeSelected ? true : false;
                }
            }

            if(!isDigiLockerSelected) {
                updateRecord();
                formSubmitResponse.isFormSubmitted = true;
                showMsg('Document Upload Mode has been updated, Kindly Proceed with the Document Upload!', 'success', false);
                return null;
            } else {
                
                DigilockerInitializeWrapper objInitalizer = DigilockerWebService.initializeDigilocker(
                    objDocumentDetails.studentName, 
                    objDocumentDetails.studentMobile, 
                    objDocumentDetails.studentEmail, 
                    getObjectId());
                if(objInitalizer==null || !objInitalizer.success) {
                    String message = objInitalizer!=null ? objInitalizer.message : 'Internal error occured. Kindly contact our Support Team.';
                    showMsg(message, 'error', false);
                    return null;
                }

                if(isOtherModeSelected) {
                    updateRecord();
                }

                SessionManager obj = new SessionManager();
                Map<String,String> mapOfParameters = obj.getSessionData();
                mapOfParameters.put('client_id',objInitalizer.data.client_id);
                mapOfParameters.put('isOtherModeSelected',String.valueOf(isOtherModeSelected));
                mapOfParameters.put('jsonDocumentModeList',jsonDocumentModeList);
                obj.updateSessionData(mapOfParameters);
                PageReference pgURL = new PageReference(objInitalizer.data.url);
                pgURL.setRedirect(true);
                return pgURL;
            }
            
        } catch (Exception error) {
            System.debug('error =>'+error.getMessage());
            System.debug('error =>'+error.getLineNumber());
        }
        showMsg('Internal error occured. Kindly contact our Support Team.', 'error', false);
        return null;
    }

    /**
    * @description 
    * @author @BK | 09-02-2024 
    * @return Boolean 
    **/
    private Boolean validateForm() {
        Boolean isModeSelected = false;
        Boolean isDigiLockerSelected = false;
        List<SelectedDocumentData> selectedDocuments = getSelectedDocuments();
        if(selectedDocuments==null || selectedDocuments.isEmpty()) {
            showMsg('Please select one of the options', 'error', false);
            return true;
        }
        for (SelectedDocumentData objdoc : selectedDocuments) {
            if(String.isNotBlank(objdoc.modeOfUpload)) {
                isModeSelected = true;
                isDigiLockerSelected = objdoc.modeOfUpload == 'Upload via DigiLocker' || isDigiLockerSelected ? true : false;
            }
        }
        if(!isModeSelected) {
            System.debug('returned true');
            showMsg('Please select one of the options', 'error', false);
            return true;
        }

        if((isDigiLockerSelected)
        && (String.isBlank(objDocumentDetails.studentName) 
        || String.isBlank(objDocumentDetails.studentEmail)
        || String.isBlank(objDocumentDetails.studentMobile))) {
            System.debug('returned true');
            showMsg('Please Fill the Form field to opt for Digilocker Option', 'error', false);
            return true;
        }
        System.debug('returned false');
        return false;
    }

    /**
    * @description 
    * @author @BK | 09-02-2024 
    **/
    private void updateRecord() {
        Boolean isProvisional = false;
        List<nm_LinksForDocumentsLead__c> lstLeadDocs = new List<nm_LinksForDocumentsLead__c>();
        List<nm_LinksForDocuments__c> lstAccountDocs = new List<nm_LinksForDocuments__c>();
        List<SelectedDocumentData> selectedDocuments = getSelectedDocuments();
        for (SelectedDocumentData objdoc : selectedDocuments) {
            if(String.isNotBlank(objdoc.modeOfUpload)) {

                isProvisional =isProvisional || (objdoc.modeOfUpload == 'Upload Self-Attested Now' && objdoc.isMandatory) ? true : false;
                if(objdoc.objType == 'Lead') {
                    nm_LinksForDocumentsLead__c objDocument = new nm_LinksForDocumentsLead__c(
                        Id=objdoc.recordId,
                        Document_Upload_Mode__c = objdoc.modeOfUpload
                    );
                    lstLeadDocs.add(objDocument);
                }

                if(objdoc.objType == 'Account') {
                    nm_LinksForDocuments__c objDocument = new nm_LinksForDocuments__c(
                        Id=objdoc.recordId,
                        Document_Upload_Mode__c = objdoc.modeOfUpload
                    );
                    lstAccountDocs.add(objDocument);
                }
            }
        }

        if(lstLeadDocs.size() > 0) {
            update lstLeadDocs;
        }

        if(lstAccountDocs.size() > 0) {
            update lstAccountDocs;
        }
        System.debug('isProvisional==> '+ isProvisional);
        updateParentObject(isProvisional);
    }

    /**
    * @description 
    * @author @BK | 09-11-2024 
    * @return List<SelectedDocumentData> 
    **/
    private List<SelectedDocumentData> getSelectedDocuments() {
        if(String.isBlank(jsonDocumentModeList)) {
            System.debug('jsonDocumentModeList:' + jsonDocumentModeList);
            return null;
        }
        try {
            List<SelectedDocumentData> selectedDocuments = (List<SelectedDocumentData>)JSON.deserialize(jsonDocumentModeList, List<SelectedDocumentData>.class);
            System.debug('SelectedDocuments:' + selectedDocuments);
            return selectedDocuments;
        } catch (Exception error) {
            System.debug('Error Message ==>'+error.getMessage());
            System.debug('Error Line Number ==>'+error.getLineNumber());
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 11-09-2024 
    * @param Boolean isProvisional 
    **/
    private void updateParentObject(Boolean isProvisional) {
        if(!isProvisional) {
            return;
        }
        try {
            if(this.objectType == 'Lead') {
                Lead objLead = new Lead(id = getObjectId(), Provisional_With_Hold__c = true);
                update objLead;
            }
    
            if(this.objectType == 'Account') {
                Account objAccount = new Account(id = getObjectId(), Provisional_With_Hold__c = true);
                update objAccount;
            }
        } catch (Exception error) {
            System.debug('error on ParnetObject Function');
            System.debug('error =>'+error.getMessage());
            System.debug('error =>'+error.getLineNumber());
        }
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @return PageReference 
    **/
    public PageReference saveFileLinks() {
        try {
            
            if(String.isBlank(jsonDocumentList)) {
                showMsg('Kindly select the documents to link', 'error', false);
                return null;
            }
            List<SelectedDocumentData> selectedDocuments = (List<SelectedDocumentData>)JSON.deserialize(jsonDocumentList, List<SelectedDocumentData>.class);
            if(selectedDocuments.isEmpty()) {
                showMsg('Internal error occured. Kindly contact our Support Team.', 'error', false);
                return null;
            }

            for (SelectedDocumentData document : selectedDocuments) {
                document.link = fetchDocumentLinkFromDigiLocker(document.fileId);
            }

            if(generateAndUpdateLinks(selectedDocuments)) {

                SessionManager obj = new SessionManager();
                Map<String,String> mapOfParameters = obj.getSessionData();
                formSubmitResponse.isFormSubmitted = mapOfParameters.containsKey('isOtherModeSelected') 
                                                    ? Boolean.valueOf(mapOfParameters.get('isOtherModeSelected')) 
                                                    : false;
                String successMessage = formSubmitResponse.isFormSubmitted ? 'Files Uploaded Successfully, Kindly upload the pending documents!' : 'Files Uploaded Successfully!';
                clearDigiLockerSession();
                showMsg(successMessage, 'success', true);
            }
            
            return null;
        } catch (Exception error) {
            System.debug('Error ==>' + error.getMessage());
            System.debug('Error ==>' + error.getLineNumber());
        }
        showMsg('Internal error occured. Kindly contact our Support Team.', 'error', false);
        return null;
    }

    /**
    * @description 
    * @author @BK | 09-02-2024 
    **/
    public void fetchDocumentsFromDigiLocker() {
        SessionManager obj = new SessionManager();
        Map<String,String> mapOfParameters = obj.getSessionData();
        if(!mapOfParameters.isEmpty() && mapOfParameters.containsKey('client_id')
        && DigilockerWebService.getDigilockerOauthStatus(mapOfParameters.get('client_id'), getObjectId())) {
            
            clientId = mapOfParameters.get('client_id');
            jsonDocumentModeList = mapOfParameters.get('jsonDocumentModeList');
            objListDocuments = DigilockerWebService.getListOfDocument(clientId, getObjectId());

            if(objListDocuments!=null && objListDocuments.success) {
                isDocumentFetched = true;
            } else {
                clearDigiLockerSession();
            }
        }
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param String fileId 
    * @return String 
    **/
    private String fetchDocumentLinkFromDigiLocker(String fileId) {
        if(String.isBlank(clientId) || String.isBlank(fileId)) {
            return null;
        }

        DigilockerDocumentDownloadWrapper response = DigilockerWebService.getDigilockerDownloadedDocument(clientId, fileId, getObjectId());
        if(!response.success) {
            return null;
        }
        return response.data.download_url;
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param List<SelectedDocumentData> selectedDocuments 
    **/
    private Boolean generateAndUpdateLinks(List<SelectedDocumentData> selectedDocuments) {
        List<String> lstUrls = new List<String>();
        for (SelectedDocumentData document : selectedDocuments) {
            if(String.isNotBlank(document.link)) {
                lstUrls.add(document.link);
            }
        }
        if(lstUrls.isEmpty()) {
            return false;
        }
        CloudfrontUrlOnFileUpload response = GenerateCloudfrontLinks.generateLinks(lstUrls, getObjectId());
        if(response.error) {
            return null;
        }

        for (SelectedDocumentData document : selectedDocuments) {
            for (CloudfrontUrlOnFileUpload.Link url : response.links) {
                if(document.link == url.fileUrl) {
                    document.awsUrl = url.awsUrl;
                }
            }
        }

        return updateDocumentLink(selectedDocuments);
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param List<SelectedDocumentData> selectedDocuments 
    * @return Boolean 
    **/
    private Boolean updateDocumentLink(List<SelectedDocumentData> selectedDocuments) {
       try {
            Map<Id, SelectedDocumentData> leadDocMap = new Map<Id, SelectedDocumentData>();
            Map<Id, SelectedDocumentData> accountDocMap = new Map<Id, SelectedDocumentData>();

            for (SelectedDocumentData doc : selectedDocuments) {
                if (doc.objType == 'Lead') {
                    leadDocMap.put(doc.recordId, doc);
                } else {
                    accountDocMap.put(doc.recordId, doc);
                }
            }
            // Query existing Lead documents
            Map<Id, nm_LinksForDocumentsLead__c> existingLeadDocs = new Map<Id, nm_LinksForDocumentsLead__c>(
                [SELECT Id, nm_Status__c FROM nm_LinksForDocumentsLead__c WHERE Id IN :leadDocMap.keySet()]
            );

            // Query existing Account documents
            Map<Id, nm_LinksForDocuments__c> existingAccountDocs = new Map<Id, nm_LinksForDocuments__c>(
                [SELECT Id, nm_Status__c FROM nm_LinksForDocuments__c WHERE Id IN :accountDocMap.keySet()]
            );

            List<nm_LinksForDocumentsLead__c> lstLeadDocumentsToUpdate = new List<nm_LinksForDocumentsLead__c>();
            List<nm_LinksForDocuments__c> lstAccountDocumentsToUpdate = new List<nm_LinksForDocuments__c>();

            for (SelectedDocumentData doc : selectedDocuments) {
                String newStatus = 'Submitted';

                if (doc.objType == 'Lead') {
                    String prevStatus = existingLeadDocs.containsKey(doc.recordId) ? existingLeadDocs.get(doc.recordId).nm_Status__c : null ;
                    if (prevStatus == 'Documents incorrect') {
                        newStatus = 'Re-Submited';
                    }

                    lstLeadDocumentsToUpdate.add(new nm_LinksForDocumentsLead__c(
                        Id = doc.recordId,
                        nm_URLforDocuments__c = doc.awsUrl,
                        nm_Status__c = newStatus,
                        Document_Upload_Mode__c = 'Upload via DigiLocker'
                    ));
                } else {
                    String prevStatus = existingAccountDocs.containsKey(doc.recordId) ? existingAccountDocs.get(doc.recordId).nm_Status__c : null;
                    if (prevStatus == 'Documents incorrect') {
                        newStatus = 'Re-Submited';
                    }
                    
                    lstAccountDocumentsToUpdate.add(new nm_LinksForDocuments__c(
                        Id = doc.recordId,
                        nm_URLforDocuments__c = doc.awsUrl,
                        nm_Status__c = newStatus,
                        Document_Upload_Mode__c = 'Upload via DigiLocker'
                    ));
                }
            }

            if (!lstAccountDocumentsToUpdate.isEmpty()) {
                update lstAccountDocumentsToUpdate;
            }
            if (!lstLeadDocumentsToUpdate.isEmpty()) {
                update lstLeadDocumentsToUpdate;
            }

            return true;
        } catch (Exception error) {
            System.debug('Error =>' + error.getMessage());
            System.debug('Line =>' + error.getLineNumber());
            return false;
        }
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @return void 
    **/
    private void clearDigiLockerSession() {
        SessionManager obj = new SessionManager();
        Map<String,String> mapOfParameters = obj.getSessionData();
        if(!mapOfParameters.isEmpty()) {
            String[] lstKeys = new List<String>{'client_id','isOtherModeSelected', 'jsonDocumentModeList'};
            for (String key : lstKeys) {
                if(mapOfParameters.containsKey(key)) {
                    mapOfParameters.remove(key);
                }
            }
            obj.updateSessionData(mapOfParameters);
            
            jsonDocumentModeList = '';
            isDocumentFetched = false;
        }
    }

    /**
    * @description 
    * @author @BK | 03-09-2024 
    * @param String status 
    * @param String message 
    **/
    private void showMsg(String message, String status, Boolean refreshPage) {
        msgHandler.message = message;
        msgHandler.status = status;
        msgHandler.refreshPage = refreshPage;
    }

    public class DocumentWrapper {
        public DocumentWrapper() {
            this.showoldDocLink=false;
            this.recordId = null;
            this.showUpload = false;
            this.name = '';
            this.status = 'Not Uploaded';
            this.link = '';
            this.oldLink ='';   
            this.statusColorCode = '#555';
            this.isMandatory = false;
            this.resonForIncorrect = '';
            this.objType = '';
            this.modeOfUpload = '';
            this.selectedMode = '';
            this.documentMode = '';
        }
        public Boolean showoldDocLink {get;set;}
        public Id recordId {get;set;}
        public String name {get;set;}
        public String oldLink {get;set;}   
        public String link {get;set;}
        public String status {get;set;}
        public String statusColorCode {get;set;}
        public Boolean showUpload {get;set;}
       
        public Boolean isMandatory {get;set;}
        public String resonForIncorrect {get;set;}
        public String objType {get;set;}
        public String modeOfUpload {get;set;}
        public String selectedMode {get;set;}
        public String documentMode {get;set;}
    }

    public class FormDetails {
        public FormDetails() {
            this.modeOfUpload = '';
            this.studentName = '';
            this.studentEmail = '';
            this.studentMobile = '';
            this.selectedDocuments = '';
        }
        public String modeOfUpload {get;set;}
        public String studentName {get;set;}
        public String studentEmail {get;set;}
        public String studentMobile {get;set;}
        public String selectedDocuments {get;set;}
    }

    public class RecordInformations {
        public RecordInformations() {
            this.alreadySelectedMode = '';
        }
        public String alreadySelectedMode {get;set;}
    }

    public class SelectedDocumentData {
        public SelectedDocumentData() {
            this.recordId = null;
            this.name = '';
            this.objType = '';
            this.fileId = '';
            this.link = '';
            this.awsUrl = '';
            this.isMandatory = false;
            this.modeOfUpload = '';
        }
        public String recordId {get;set;}
        public String name {get;set;}
        public String objType {get;set;}
        public String fileId {get;set;}
        public String link {get;set;}
        public String awsUrl {get;set;}
        public Boolean isMandatory {get;set;}
        public String modeOfUpload {get;set;}
    }

    public class MsgHandler {
        public MsgHandler() {
            this.status = '';
            this.message = '';
            this.refreshPage = false;
        }
        public String status {get;set;}
        public String message {get;set;}
        public Boolean refreshPage {get;set;}
    }

    public class FormSubmitResponse {
        public FormSubmitResponse() {
            this.parameters = '';
            this.isFormSubmitted = false;
        }
        public String parameters {get;set;}
        public Boolean isFormSubmitted {get;set;}
    }
}