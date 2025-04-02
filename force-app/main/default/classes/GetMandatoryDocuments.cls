/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 28-09-2024
 * @last modified by  : @BK
**/
public without sharing class GetMandatoryDocuments {

    /**
    * @description 
    * @author @BK | 08-08-2024 
    * @param StudentStatus objStatus 
    * @return Set<String> 
    **/
    public Set<String> getMandatoryDocumentsName(StudentStatus objStatus) {
        // Retrieve work experience records based on object type or from wrapper
        List<nm_WorkExperience__c> lstWk = new List<nm_WorkExperience__c>();
        if(objStatus.lstWk.size() > 0) {
            lstWk = objStatus.lstWk;
        } else if(objStatus.recordId != null) {
            lstWk = getWorkExperienceRecords(objStatus.recordId, objStatus.objectType);
        }
        
    
        // Initialize the set of mandatory documents
        Set<String> mandatoryDocuments = new Set<String>{'Photo ID proof', 'Student Photograph'};
    
        // Add documents based on eligibility criteria
        addDegreeMarkSheetIfApplicable(objStatus, mandatoryDocuments);
        add12thMarkSheetIfApplicable(objStatus, mandatoryDocuments);
        addHSCMarksheetIfApplicable(objStatus, mandatoryDocuments);
        add10thMarkSheetIfApplicable(objStatus, mandatoryDocuments);
        addDiplomaDocumentsIfApplicable(objStatus, mandatoryDocuments);
        addWorkExperienceDocumentsIfApplicable(objStatus, lstWk, mandatoryDocuments);
        addProfessionalDocumentsIfApplicable(objStatus, mandatoryDocuments);
        addDefenceDocumentsIfApplicable(objStatus, mandatoryDocuments);
        addDifferentlyAbledDocumentsIfApplicable(objStatus, mandatoryDocuments);
        // addCastCertificateDocumentsIfApplicable(objStatus, mandatoryDocuments);
        addLateralDocumentsIfApplicable(objStatus, mandatoryDocuments);
        addMasterDegreeMarkSheetIfApplicable(objStatus, mandatoryDocuments);
        addAadharCardDocumentsIfApplicable(objStatus, mandatoryDocuments);
        
        return mandatoryDocuments;
    }
    
    // Helper method to get work experience records
    private List<nm_WorkExperience__c> getWorkExperienceRecords(Id recordId, String objectType) {
        String query = (objectType == 'Account') ? 
            'SELECT Id, Name, nm_CompanyName__c FROM nm_WorkExperience__c WHERE nm_Student__c = :recordId' :
            'SELECT Id, Name, nm_CompanyName__c FROM nm_WorkExperience__c WHERE nm_Lead__c = :recordId';
        return Database.query(query);
    }
    
    // Helper method to add Degree Mark Sheet if applicable
    private void addDegreeMarkSheetIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('Bachelor') || objStatus.eligibilityCriteria.contains('Graduation')) {
            documents.add('Degree Mark Sheet');
        }
    }
    
    // Helper method to add 12th Mark Sheet if applicable
    private void add12thMarkSheetIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('HSC')) {
            if (objStatus.chooseProgram != 'Bachelor Programs') {
                documents.add('12th Mark Sheet');
            } else if (objStatus.hscStatus == 'Passed') {
                documents.add('12th Mark Sheet');
            }
        }
    }
    
    // Helper method to add 11th and 12th Marksheet if applicable
    private void addHSCMarksheetIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('HSC') && objStatus.chooseProgram == 'Bachelor Programs') {
            if (objStatus.hscStatus == 'Appeared' || objStatus.hscStatus == 'Pending') {
                documents.add('11th Marksheet');
            }
            documents.add('12th Mark Sheet');
        }
    }
    
    // Helper method to add 10th Mark Sheet if applicable
    private void add10thMarkSheetIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('SSC')) {
            documents.add('10th Mark Sheet');
        }
    }
    
    // Helper method to add Diploma documents if applicable
    private void addDiplomaDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('Diploma')) {
            if (objStatus.chooseProgram != 'Bachelor Programs') {
                documents.add('Diploma Mark Sheet');
            } else if (objStatus.diplomaStatus == 'Appeared') {
                documents.add('Diploma 1st year Marksheet');
                documents.add('Diploma 2nd year Marksheet');
            } else if (objStatus.diplomaStatus == 'Passed') {
                documents.add('Diploma Mark Sheet');
            }
        }
    }
    
    // // Helper method to add Work Experience documents if applicable
    // private void addWorkExperienceDocumentsIfApplicable(StudentStatus objStatus, List<nm_WorkExperience__c> lstWk, Set<String> documents) {

    //     if(!objStatus.eligibilityCriteria.containsIgnoreCase('Work') || objStatus.eligibilityCriteria.contains('preferably')) {
    //         return;
    //     }

    //     // Map eligibility criteria to work experience document names
    //     Map<String, String> workExperienceMap = new Map<String, String>{
    //         '1' => 'Work Experience Certificate – 1 year',
    //         '2' => 'Work Experience Certificate – 2 years',
    //         '3' => 'Work Experience Certificate – 3 years'
    //     };
    
    //     // Find the appropriate work experience document name
    //     String wkName = '';
    //     for (String key : workExperienceMap.keySet()) {
    //         if (objStatus.eligibilityCriteria.containsIgnoreCase(key)) {
    //             wkName = workExperienceMap.get(key);
    //             break;
    //         }
    //     }
    
    //     // If a work experience document name is found, add it to the set
    //     if (String.isNotBlank(wkName)) {
    //         if (lstWk.isEmpty()) {
    //             documents.add(wkName);
    //         } else {
    //             for (nm_WorkExperience__c objWk : lstWk) {
    //                 String companyName = String.isNotBlank(objWk.nm_CompanyName__c) ? objWk.nm_CompanyName__c.left(125) : '';
    //                 documents.add(String.format('{0}/{1}/{2}', new String[]{wkName, objWk.Name, companyName}));
    //             }
    //         }
    //     }
    // }

    /**
     * Adds work experience documents to the provided set if applicable based on the student status.
     *
     * @param objStatus The student status containing eligibility criteria.
     * @param lstWk The list of work experience records.
     * @param documents The set of documents to which work experience documents might be added.
     */
    private void addWorkExperienceDocumentsIfApplicable(StudentStatus objStatus, List<nm_WorkExperience__c> lstWk, Set<String> documents) {
        // Check if work experience documents should be added based on eligibility criteria
        if (!shouldAddWorkExperienceDocuments(objStatus)) {
            return; // Exit if conditions are not met
        }
        
        // Get the appropriate work experience document name based on eligibility criteria
        String wkName = getWorkExperienceDocumentName(objStatus);
        
        // If a valid document name is found, add it to the set of documents
        if (String.isNotBlank(wkName)) {
            addDocumentsToSet(wkName, lstWk, documents);
        }
    }

    /**
     * Determines whether work experience documents should be added based on the eligibility criteria.
     *
     * @param objStatus The student status containing eligibility criteria.
     * @return True if work experience documents should be added, otherwise false.
     */
    private Boolean shouldAddWorkExperienceDocuments(StudentStatus objStatus) {
        // Check if the eligibility criteria include 'Work' and do not include 'preferably'
        return objStatus.eligibilityCriteria.containsIgnoreCase('Work') && 
            !objStatus.eligibilityCriteria.contains('preferably');
    }

    /**
     * Retrieves the work experience document name based on the eligibility criteria.
     *
     * @param objStatus The student status containing eligibility criteria.
     * @return The work experience document name corresponding to the eligibility criteria.
     */
    private String getWorkExperienceDocumentName(StudentStatus objStatus) {
        // Map of eligibility criteria to document names
        Map<String, String> workExperienceMap = new Map<String, String>{
            '1' => 'Work Experience Certificate – 1 year',
            '2' => 'Work Experience Certificate – 2 years',
            '3' => 'Work Experience Certificate – 3 years'
        };

        // Find and return the document name based on the criteria
        for (String key : workExperienceMap.keySet()) {
            if (objStatus.eligibilityCriteria.containsIgnoreCase(key)) {
                return workExperienceMap.get(key);
            }
        }
        
        // Return an empty string if no matching criteria is found
        return '';
    }

    /**
     * Adds the work experience document names to the set of documents.
     *
     * @param wkName The work experience document name.
     * @param lstWk The list of work experience records.
     * @param documents The set of documents to which work experience documents will be added.
     */
    private void addDocumentsToSet(String wkName, List<nm_WorkExperience__c> lstWk, Set<String> documents) {
        if (lstWk.isEmpty()) {
            // If no work experience records are present, just add the document name
            documents.add(wkName);
        } else {
            // Add formatted document names based on work experience records
            for (nm_WorkExperience__c objWk : lstWk) {
                String companyName = String.isNotBlank(objWk.nm_CompanyName__c) ? objWk.nm_CompanyName__c.left(125) : '';
                documents.add(String.format('{0}/{1}/{2}', new String[]{wkName, objWk.Name, companyName}));
            }
        }
    }
    
    // Helper method to add Professional documents if applicable
    private void addProfessionalDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('Professional')) {
            documents.add('Additional Qualification Certificates');
        }
    }
    
    // Helper method to add Defence documents if applicable
    private void addDefenceDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.isDefencePersonnel == 'Yes') {
            documents.add('Defence Document');
            if (objStatus.relationship != 'Self') {
                documents.add('Relationship Document');
            }
        }
    }
    
    // Helper method to add Differently Abled documents if applicable
    private void addDifferentlyAbledDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.isDifferentlyAbled == 'Yes') {
            documents.add('Differently Abled Document');
        }
    }
    
    // // Helper method to add CastCertificate documents if applicable
    // private void addCastCertificateDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
    //     if (String.isNotBlank(objStatus.castCertificateDocument) && objStatus.castCertificateDocument != 'General' && PickListHelper.getPickListValuesForLeadCategory().contains(objStatus.castCertificateDocument) ) {
    //         documents.add('Caste Certificate Document');
    //     }
    // }
    
    // Helper method to add Lateral documents if applicable
    private void addLateralDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.isLateral) {
            if (objStatus.studentProgram.startswith('Advance')) {
                documents.add('NMIMS Certificate Program Marksheet');
            } else {
                documents.add('NMIMS Diploma Marksheet');
            }
        }
    }
    
    // Helper method to add Master Degree Mark Sheet if applicable
    private void addMasterDegreeMarkSheetIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if (objStatus.eligibilityCriteria.contains('Master')) {
            documents.add('Master Degree Mark sheet');
        }
    }

    // Helper method to add Aadhar Card documents if applicable
    private void addAadharCardDocumentsIfApplicable(StudentStatus objStatus, Set<String> documents) {
        if(objStatus.isIndian) {
            documents.add('Aadhaar Card');
        }
    }

    public class StudentStatus {
        public StudentStatus() {
            this.eligibilityCriteria = '';
            this.chooseProgram = '';
            this.hscStatus = '';
            this.diplomaStatus = '';
            this.isDefencePersonnel = '';
            this.relationship = '';
            this.isDifferentlyAbled = '';
            this.studentProgram = '';
            this.castCertificateDocument = '';
            this.isLateral = false;
            this.isIndian = true;
            this.recordId = null;
            this.objectType = 'Account';
            this.lstWk = new List<nm_WorkExperience__c>();
        }
        public String eligibilityCriteria {get;set;}
        public String chooseProgram {get;set;}
        public String hscStatus {get;set;}
        public String diplomaStatus {get;set;}
        public String isDefencePersonnel {get;set;}
        public String relationship {get;set;}
        public String isDifferentlyAbled {get;set;}
        public String castCertificateDocument {get;set;}
        public Boolean isLateral {get;set;}
        public Boolean isIndian {get;set;}
        public String studentProgram {get;set;}
        public Id recordId {get;set;}
        public String objectType {get;set;}
        public List<nm_WorkExperience__c> lstWk {get;set;}
    }
}