/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 06--02--2026
 * @last modified by  : @Ravi
**/
public without sharing class LateralDataAssigmentWrapper {

    public List<String> lateraleditablefields {get; set;}
    public Id leadIdRecordId {get; set;} 

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    **/
    public LateralDataAssigmentWrapper() {
        lateraleditablefields = new List<String>();
    }
    
      /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param String studentNumber 
    * @param String program 
    * @return Blob 
    **/
    public static Map<String, Object> validateLateralStudentDetails(String studentNumber ,String program) {
        List<Student_Lateral_Sem_Mapping__c> objLateralSemMapping = new List<Student_Lateral_Sem_Mapping__c>();
        // Student_Lateral_Sem_Mapping__c objSemMapping = new Student_Lateral_Sem_Mapping__c();
        LateralvalidateResponse data = new LateralvalidateResponse();
        String lateralNo = studentNumber.trim();
        System.debug('Student Lateral Number ---->' + lateralNo);
        try {
            // Query lateral student account
            List<Account> lstAccount = [SELECT Id, FirstName, LastName, nm_Program__r.nm_TotalSemesters__c,Student_ID__c,nm_Drive_Name__c, Program_Name__c, nm_DateOfBirth__c, PersonMobilePhone, PersonEmail, PersonContactId, Is_Mobile_Verified__c, nm_IsEmailVerified__c, Passing_Year__c, Passing_Month__c, Pass_Out__c, nm_ChooseaProgram__c 
                                        FROM Account  WHERE Student_ID__c != null AND Student_ID__c LIKE :lateralNo LIMIT 1];
             Account objAcc = lstAccount.size() > 0 ? lstAccount[0] : null;
             data.objAcc = objAcc;
            if (objAcc != null) {

                    if (!String.isBlank(objAcc.nm_Drive_Name__c)) {
                        Date studentDriveDate = convertDriveToDate(objAcc.nm_Drive_Name__c);
                        Date allowUpToDate = Date.newInstance(2024, 7, 1);
                            if (studentDriveDate == null || studentDriveDate < allowUpToDate) {
                                return buildMapResponse('Error', 'You are not eligible for lateral admission.', null);
                            }
                    }
                    // Get student program details
                    List<nm_StudentProgram__c> objStudentProg = [SELECT id, nm_Student__c, Certificate_Issue__c, Certificate_Issue__r.nm_ProgramName__c, Certificate_Issue__r.nm_Type__c, ProgramType__c, nm_Program__c, nm_Program__r.nm_ProgramName__c, nm_Program__r.prgst__c, Certificate_Issue__r.prgst__c
                                                                FROM nm_StudentProgram__c WHERE nm_Student__r.Student_ID__c = :lateralNo];
                    nm_StudentProgram__c objstuProg = objStudentProg.size() > 0 ? objStudentProg[0] : null;
                    System.debug('objStudentProg -->' + objstuProg);

                    // Fetch lateral mapping based on program
                    String oldProgram = objstuProg.Certificate_Issue__c != null ? objstuProg.Certificate_Issue__r.nm_ProgramName__c : objstuProg.nm_Program__r.nm_ProgramName__c;
                    // objLateralSemMapping = [SELECT Id, Lateral_Admission_to_the_Program__c, Old_Program__c, Future_Lateral_Sem__c  FROM Student_Lateral_Sem_Mapping__c WHERE Lateral_Admission_to_the_Program__c = :program AND Old_Program__c = :mappedProg];
                    // objSemMapping = objLateralSemMapping.size() > 0 ? objLateralSemMapping[0] : null;

                    // Get program structure years
                    String progStructure = objstuProg != null ? objstuProg.nm_Program__r.prgst__c : null;
                    String certifiStructure = (objstuProg != null && objstuProg.Certificate_Issue__c != null) ? objstuProg.Certificate_Issue__r.prgst__c : null;
                    Integer yearInt = progStructure != null ? Integer.valueOf(progStructure.right(4)) : null;
                    Integer certYearInt = certifiStructure != null ? Integer.valueOf(certifiStructure.right(4)) : null;

                    // Check if student is eligible for lateral (based on batch and certificate)
                    if (objstuProg.Certificate_Issue__c == null && yearInt != null && yearInt < 2024) {
                        return buildMapResponse('Error', 'You are not eligible for lateral admission.', null);
                    } else if (objstuProg.Certificate_Issue__c != null && certYearInt != null && certYearInt < 2024) {
                        return buildMapResponse('Error', 'You are not eligible for lateral admission.', null);
                    }

                    if (objAcc.Pass_Out__c) {
                    //  System.debug('Stage 3');
                        data.passout = objAcc.Pass_Out__c;
                        data.yearOfPassing = objAcc.Passing_Year__c;
                        data.monthOfPassing = objAcc.Passing_Month__c;
                        data.oldProgram = objstuProg.Certificate_Issue__c == null ? objstuProg.nm_Program__r.nm_ProgramName__c : objstuProg.Certificate_Issue__r.nm_ProgramName__c;

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
                        
                        System.debug('Response Body====>' + response.getBody());
                        String result = response.getBody();
                        Map<String, Object> mapOfAPIResponse = (Map<String, Object>) JSON.deserializeUntyped(result);

                        String status = mapOfAPIResponse.containsKey('status') ? (String) mapOfAPIResponse.get('status') : '';
                        if (status == 'Success') {
                            data.passout = true;
                            data.yearOfPassing = (String) mapOfAPIResponse.get('yearOfPassing');
                            data.monthOfPassing = (String) mapOfAPIResponse.get('monthOfPassing');
                            data.oldprogram = (String) mapOfAPIResponse.get('program');
                        } else {
                            data.passout = false;
                        }
                    }

                    if (data.passout) {
                        System.debug('Stage 4');
                        if(!objAcc.Pass_Out__c){
                            LateralDataAssigmentWrapper.markPassout(lateralNo,objAcc);
                        }
                        if ((program =='MBA (Online) Programs' &&  oldProgram == 'Diploma in Business Management')) {
                            data.enrolledSem = '3';

                        // Other Diploma programs --> Lateral Sem 2
                        } else if((program =='MBA (Online) Programs' &&  oldProgram.startsWith('Diploma'))){
                            data.enrolledSem = '2';

                        // CBM --> Lateral Sem 2
                        } else if ((program =='MBA (Online) Programs' || program == 'Diploma Programs') && oldProgram == 'Certificate in Business Management') {
                            data.enrolledSem = '2';

                        // If nothing matches, student is not eligible
                        } else {
                            return buildMapResponse('Error', 'You are not eligible for lateral admission.', null);
                        }
                        // Set final details if eligible
                        // objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        data.accId=objAcc.Id;
                        data.oldprogram = objstuProg.Certificate_Issue__c == null ? objstuProg.nm_Program__r.nm_ProgramName__c : objstuProg.Certificate_Issue__r.nm_ProgramName__c;
                        data.yearOfPassing = String.isBlank(data.yearOfPassing) ? objAcc.Passing_Year__c : data.yearOfPassing;
                        data.monthOfPassing = String.isBlank(data.monthOfPassing) ? objAcc.Passing_Month__c :data.monthOfPassing;
                        return buildMapResponse('Success', 'Eligible for lateral admission.',data);
                        } else {
                        // Student not marked as pass-out --> not eligible for lateral
                        return buildMapResponse('Error', 'You are not eligible for lateral admission.', null);
                    }
            } else {
                System.debug('Stage 7');
                return buildMapResponse('Error', 'No match found for entered SAP ID.', null);
            } 
        } catch (Exception e) {
            return buildMapResponse('Error', 'Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    * @param AccId 
    **/
    public void addLateralStudentWkExperience(Id AccId) {
        List<nm_WorkExperience__c> lstWE =new List<nm_WorkExperience__c>();
            List<nm_WorkExperience__c> lstWorkExperienceRecord = [SELECT Id,nm_Student__c,nm_Lead__c,Currently_Working_Here__c,nm_StartDate__c,nm_EndDate__c,Total_Work_Experience__c,Industry__c,OtherIndustry__c,nm_CompanyName__c,nm_Other_Company_Name__c ,nm_Department__c,Department__c,nm_Designation__c,nm_OtherDesignation__c,Annual_Income__c,Experience_Level__c,Name FROM nm_WorkExperience__c WHERE nm_Student__c=:AccId ORDER BY nm_StartDate__c ASC];
            System.debug('WE Data ==>'+lstWorkExperienceRecord+' =='+leadIdRecordId); 
            if(lstWorkExperienceRecord.size() > 0){
               for(nm_WorkExperience__c objWE : lstWorkExperienceRecord) {
                   if((objWE.nm_StartDate__c != null && objWE.nm_EndDate__c != null) || ( objWE.nm_StartDate__c != null && objWE.Currently_Working_Here__c == true)){
                    nm_WorkExperience__c newWE = objWE.clone(false); // false = Do not include Id
                    newWE.nm_Lead__c = leadIdRecordId;   
                    newWE.nm_Student__c = null;    
                    lstWE.add(newWE);
                   }
                }
           insert lstWE;
        }
    }

    /**
    * @description 
    * @author @Ravi | 15--01--2025 
    * @param AccId 
    **/
    public void populateApporovedDefaultDocs(Id AccId) {
        List<String> documentList = new List<String>{'Photo ID proof','Aadhaar Card','10th Mark Sheet','12th Marksheet' };
        List<nm_LinksForDocuments__c> docs = [SELECT Id, nm_DocumentName__c, nm_URLforDocuments__c, nm_Status__c, Document_Upload_Mode__c, nm_ReasonforDisapprove__c, Document_Query__c , nm_Old_URL_for_Documents__c FROM nm_LinksForDocuments__c WHERE nm_Account__c = :AccId AND nm_URLforDocuments__c !=null AND nm_Status__c = 'Approved'];
       if(docs.size() > 0){
        System.debug('Document Data ==>'+documentList); 
        for(nm_LinksForDocuments__c doc : docs){
            nm_LinksForDocumentsLead__c newDoc = new nm_LinksForDocumentsLead__c();
            if(documentList.contains(doc.nm_DocumentName__c)){
                newDoc.Name = doc.nm_DocumentName__c;
                newDoc.Lead__c = leadIdRecordId;
                newDoc.nm_DocumentName__c = doc.nm_DocumentName__c;
                newDoc.nm_URLforDocuments__c = doc.nm_URLforDocuments__c;
                newDoc.Document_Upload_Mode__c = doc.Document_Upload_Mode__c;
                newDoc.nm_Status__c = 'Submitted';
            }
            insert newDoc;
          }
        }  
    }

        /**
    * @description 
    * @author @Ravi | 15--01--2025 
    * @param AccRecord 
    * @param leadId 
    * @param lead 
    **/
    public void updateLeadData(Account AccRecord , Id leadId, Lead lead) {
        System.debug('updateLeadData  Call==> ' + AccRecord + ' ========>' + leadId);
        leadIdRecordId=leadId;
        Lead objLead = lead;
        objLead.Id =leadId;
        objLead.Is_Non_Lateral__c = 'No';

        // Create a map of field names to their values
        Map<String, Object> mapOfAccountapiVsValues = new Map<String, Object>{
            'Salutation' => AccRecord.Salutation,
            'FirstName' => AccRecord.FirstName,
            'LastName' => AccRecord.LastName,
            // 'PersonEmail' => AccRecord.PersonEmail,
            // 'PersonMobilePhone' => AccRecord.PersonMobilePhone,
            'Father_First_Name__c' => AccRecord.Father_First_Name__c,
            'Father_Salutation__c' => AccRecord.Father_Salutation__c,
            'Father_Last_Name__c' => AccRecord.Father_Last_Name__c,
            'Mother_Salutation__c' => AccRecord.Mother_Salutation__c,
            'Mother_First_Name__c' => AccRecord.Mother_First_Name__c,
            'Mother_Last_Name__c' => AccRecord.Mother_Last_Name__c,
            'nm_Gender__c' => AccRecord.nm_Gender__c,
            'nm_DateOfBirth__c' => AccRecord.nm_DateOfBirth__c,
            'nm_MaritialStatus__c' => AccRecord.nm_MaritialStatus__c,
            'nm_SpouseName__c' => AccRecord.nm_SpouseName__c,
            'nm_BloodGroup__c' => AccRecord.nm_BloodGroup__c,
            'nm_Category__c' => AccRecord.nm_Category__c,
            'nm_Domicile__c' => AccRecord.nm_Domicile__c,
            'nm_Nationality__c' => AccRecord.nm_Nationality__c,
            'nm_Mother_Tongue__c' => AccRecord.nm_Mother_Tongue__c,
            'nm_Other_Mother_Tongue__c' => AccRecord.nm_Other_Mother_Tongue__c,
            'Adhar_Card_Number__c' => AccRecord.Adhar_Card_Number__c,
            'AadharCardNumber__c' => AccRecord.AadharCardNumber__c,
            'Differently_abled__c' => AccRecord.Differently_abled__c,
            'Your_disability__c' => AccRecord.Your_disability__c,
           // Address Information 
            'Zip_Postal_Code_Shipping__c' => AccRecord.Zip_Postal_Code_Shipping__c,
            'City_Shipping_Account__c' => AccRecord.City_Shipping_Account__c,
            'State_Province_Shipping__c' => AccRecord.State_Province_Shipping__c,
            'House_No_Name_Shipping_Account__c'=>AccRecord.House_No_Name_Shipping_Account__c,
            'Country_Shipping__c' => AccRecord.Country_Shipping__c,
            'Shipping_Street__c' => AccRecord.Shipping_Street__c,
            'Locality_Name_Shipping__c' => AccRecord.Locality_Name_Shipping__c,
            'nm_STDCode__c' => AccRecord.nm_STDCode__c,
            // Permanent Address Information
            'Phone' => AccRecord.Phone,
            'nm_SecondryEmail__c' => AccRecord.nm_SecondryEmail__c,
            'Locality__c' => AccRecord.Locality__c,
            'nm_PostalCode__c' => AccRecord.nm_PostalCode__c,
            'nm_City__c' => AccRecord.nm_City__c,
            'nm_StateProvince__c' => AccRecord.nm_StateProvince__c,
            'nm_HouseNumber_P__c' => AccRecord.nm_HouseNumber_P__c,
            'nm_Street__c' => AccRecord.nm_Street__c,
            'nm_LocalityName_P__c' => AccRecord.nm_LocalityName_P__c,
            'nm_Country__c' => AccRecord.nm_Country__c,
            
            // Program Section
            // 'nm_ChooseaProgram__c' => AccRecord.nm_ChooseaProgram__c,
            // 'Program_Type__c' => AccRecord.Program_Type__c,
            // 'nm_Program__c' => AccRecord.nm_Program__c,
            // 'nm_Program2__c' => AccRecord.nm_Program2__c,
            // 'Specialization_Type__c' => AccRecord.Specialization_Type__c,
            // 'nm_EligiblityCriteria__c' => AccRecord.nm_EligiblityCriteria__c,
            'nm_DefencePersonnel__c' => AccRecord.nm_DefencePersonnel__c,
            'nm_ServiceNumber__c' => AccRecord.nm_ServiceNumber__c,
            'nm_Relationship__c' => AccRecord.nm_Relationship__c,
            'nm_DateofCommission__c' => AccRecord.nm_DateofCommission__c,
            'nm_ArmedService__c' => AccRecord.nm_ArmedService__c,
            'Rank__c' => AccRecord.Rank__c,

             // Educational Details
            'nm_NameofBoard__c' => AccRecord.nm_NameofBoard__c,
            'nm_NameofStateBoard10th__c' => AccRecord.nm_NameofStateBoard10th__c,
            'nm_10thPercentage__c' => AccRecord.nm_10thPercentage__c,
            'nm_YearofCompletion__c' => AccRecord.nm_YearofCompletion__c,
            'nm_NameofSchool__c' => AccRecord.nm_NameofSchool__c,
            'nm_Class12OrDiploma__c' => AccRecord.nm_Class12OrDiploma__c,
            'nm_NameofBoard12__c' => AccRecord.nm_NameofBoard12__c,
            'nm_NameofStateBoard12th__c' => AccRecord.nm_NameofStateBoard12th__c,
            'nm_12thPercentage__c' => AccRecord.nm_12thPercentage__c,
            'nm_YearofCompletion12__c' => AccRecord.nm_YearofCompletion12__c,
            'nm_Stream__c' => AccRecord.nm_Stream__c,
            'nm_NameofSchool12__c' => AccRecord.nm_NameofSchool12__c,
            'nm_DiplomaSchoolCollegeUniversityname__c' => AccRecord.nm_DiplomaSchoolCollegeUniversityname__c,
            'nm_ResultDiploma__c' => AccRecord.nm_ResultDiploma__c,
            'nm_DiplomaYearOfCompletion__c' => AccRecord.nm_DiplomaYearOfCompletion__c,
            'nm_DiplomaName__c' => AccRecord.nm_DiplomaName__c,
            'nm_StreamDiploma__c' => AccRecord.nm_StreamDiploma__c,
            'nm_DurationOfDiploma__c' => AccRecord.nm_DurationOfDiploma__c,
            'nm_BachelorsDegreeName__c' => AccRecord.nm_BachelorsDegreeName__c,
            'nm_Specialization__c' => AccRecord.nm_Specialization__c,
            'Percentage_Bachlor__c' => AccRecord.Percentage_Bachlor__c,
            'nm_NameofUniversity__c' => AccRecord.nm_NameofUniversity__c,
            'nm_GraduationDegreeMode__c' => AccRecord.nm_GraduationDegreeMode__c,
            'nm_YearofCollegeCompletion__c' => AccRecord.nm_YearofCollegeCompletion__c,
            'nm_NameOfCollege__c' => AccRecord.nm_NameOfCollege__c,
            'Name_of_Program1__c' => AccRecord.Name_of_Program1__c,
            'Master_s_Degree_Name__c' => AccRecord.Master_s_Degree_Name__c,
            'Other_Name_of_Program1__c' => AccRecord.Other_Name_of_Program1__c,
            'Name_of_College1__c' => AccRecord.Name_of_College1__c,
            'Name_of_University1__c' => AccRecord.Name_of_University1__c,
            'Year_of_Passing1__c' => AccRecord.Year_of_Passing1__c,
            'Percentage1__c' => AccRecord.Percentage1__c,
            'Duration_of_Program1__c' => AccRecord.Duration_of_Program1__c,
            'Graduation_Degree_Mode1__c' => AccRecord.Graduation_Degree_Mode1__c,
            'Name_of_Program2__c' => AccRecord.Name_of_Program2__c,
            'Name_of_College2__c' => AccRecord.Name_of_College2__c,
            'Name_of_University2__c' => AccRecord.Name_of_University2__c,
            'Year_of_Passing2__c' => AccRecord.Year_of_Passing2__c,
            'Percentage2__c' => AccRecord.Percentage2__c,
            'Duration_of_Program2__c' => AccRecord.Duration_of_Program2__c,
            'Graduation_Degree_Mode2__c' => AccRecord.Graduation_Degree_Mode2__c,
            'Name_of_Program3__c' => AccRecord.Name_of_Program3__c,
            'Name_of_College3__c' => AccRecord.Name_of_College3__c,
            'Name_of_University3__c' => AccRecord.Name_of_University3__c,
            'Year_of_Passing3__c' => AccRecord.Year_of_Passing3__c,
            'Percentage3__c' => AccRecord.Percentage3__c,
            'Duration_of_Program3__c' => AccRecord.Duration_of_Program3__c,
            'Graduation_Degree_Mode3__c' => AccRecord.Graduation_Degree_Mode3__c,
            // 'nm_StudentImageUrl__c' => AccRecord.nm_StudentImageUrl__c,
            'nm_WorkExperience__c' => AccRecord.nm_WorkExperience__c,
            // 'Total_Work_Experience__c' => AccRecord.Total_Work_Experience__c,
            'LinkedIn_URL__c' => AccRecord.LinkedIn_URL__c 
        };

        Map<String, String> AccounttoLeadMapping = new Map<String, String> {
            'Salutation' => 'Salutation',
            'FirstName' => 'FirstName',
            'LastName' => 'LastName',
            // 'PersonEmail' => 'Email',
            // 'PersonMobilePhone' => 'MobilePhone',
            'Father_First_Name__c' => 'Father_First_Name__c',
            'Father_Salutation__c' => 'Father_Salutation__c',
            'Father_Last_Name__c' => 'Father_Last_Name__c',
            'Mother_Salutation__c' => 'Mother_Salutation__c',
            'Mother_First_Name__c' => 'Mother_First_Name__c',
            'Mother_Last_Name__c' => 'Mother_Last_Name__c',
            'nm_Gender__c' => 'nm_Gender__c',
            'nm_DateOfBirth__c' => 'nm_DateOfBirth__c',
            'nm_MaritialStatus__c' => 'nm_MaritalStatus__c',
            'nm_SpouseName__c' => 'nm_SpouseName__c',
            'nm_BloodGroup__c' => 'nm_BloodGroup__c',
            'nm_Category__c' => 'nm_Category__c',
            'nm_Domicile__c' => 'nm_Domicile__c',
            'nm_Nationality__c' => 'nm_Nationality__c',
            'nm_Mother_Tongue__c' => 'nm_Mother_Tongue__c',
            'nm_Other_Mother_Tongue__c' => 'nm_Other_Mother_Tongue__c',
            'AadharCardNumber__c' => 'AadharCardNumber__c',
            'Adhar_Card_Number__c' => 'Adhar_Card_Number__c',
            'Differently_abled__c' => 'Differently_abled__c',
            'Your_disability__c' => 'Your_disability__c',
            
            // Address Information
            'Zip_Postal_Code_Shipping__c' => 'Zip_Postal_Code_Shipping__c',
            'City_Shipping_Account__c' => 'Shipping_City__c',
            'State_Province_Shipping__c' => 'State_Province_Shipping__c',
            'House_No_Name_Shipping_Account__c' =>'House_No_Name_Shipping__c',
            'Country_Shipping__c' => 'Country_Shipping__c',
            'Shipping_Street__c' => 'Shipping_Street__c',
            'Locality_Name_Shipping__c' => 'Locality_Name_Shipping__c',
            'Phone' => 'Phone',
            'nm_SecondryEmail__c' => 'nm_SecondryEmail__c',
            'Locality__c' => 'Locality__c',
            'nm_STDCode__c' => 'nm_STDCode__c',
            
            // Permanent Address Information
            'nm_PostalCode__c' => 'nm_PostalCode_P__c',
            'nm_City__c' => 'nm_City_P__c',
            'nm_StateProvince__c' => 'nm_StateProvince_P__c',
            'nm_HouseNumber_P__c' => 'nm_HouseNumber_P__c',
            'nm_Street__c' => 'nm_Street_P__c',
            'nm_LocalityName_P__c' => 'nm_LocalityName_P__c',
            'nm_Country__c' => 'nm_Country_P__c',
            
            // // Program Section
            // 'nm_ChooseaProgram__c' => 'nm_ChooseaProgram__c',
            // 'Program_Type__c' => 'Program_Type__c',
            // 'nm_Program__c' => 'nm_Program__c',
            // 'Specialization_Type__c' => 'Specialization_Type__c',
            // 'nm_Program2__c' => 'nm_Program2__c',
            // 'nm_EligiblityCriteria__c' => 'nm_EligiblityCriteria__c',
            'nm_DefencePersonnel__c' => 'Are_you_from_Defence__c',
            'nm_ServiceNumber__c' => 'nm_ServiceNumber__c',
            'nm_Relationship__c' => 'Relationship__c',
            'nm_DateofCommission__c' => 'nm_DateofCommission__c',
            'nm_ArmedService__c' => 'Armed_Service__c',
            'Rank__c' => 'Rank__c',
            
            // Educational Details
            'nm_NameofBoard__c' => 'nm_NameofBoard__c',
            'nm_NameofStateBoard10th__c' => 'nm_10thClassStateBoardName__c',
            'nm_10thPercentage__c' => 'nm_10thPercentage__c',
            'nm_YearofCompletion__c' => 'nm_YearofCompletion__c',
            'nm_NameofSchool__c' => 'nm_NameofSchool__c',
            'nm_Class12OrDiploma__c' => 'nm_Class12OrDiploma__c',
            'nm_NameofBoard12__c' => 'nm_NameofBoard12__c',
            'nm_NameofStateBoard12th__c' => 'nm_12thClassStateBoardName__c',
            'nm_12thPercentage__c' => 'nm_12thPercentage__c',
            'nm_YearofCompletion12__c' => 'nm_YearofCompletion12__c',
            'nm_Stream__c' => 'nm_Stream__c',
            'nm_NameofSchool12__c' => 'nm_NameofSchool12__c',
            'nm_DiplomaSchoolCollegeUniversityname__c' => 'nm_DiplomaSchoolCollegeUniversityname__c',
            'nm_ResultDiploma__c' => 'Result_Diploma__c',
            'nm_DiplomaYearOfCompletion__c' => 'nm_DiplomaYearOfCompletion__c',
            'nm_DiplomaName__c' => 'nm_DiplomaName__c',
            'nm_StreamDiploma__c' => 'nm_StreamDiploma__c',
            'nm_DurationOfDiploma__c' => 'nm_DurationOfDiploma__c',
            'nm_BachelorsDegreeName__c' => 'nm_BachelorsDegreeName__c',
            'nm_Specialization__c' => 'nm_Specialization__c',
            'Percentage_Bachlor__c' => 'nm_BachelorsDegreePercentage__c',
            'nm_NameofUniversity__c' => 'nm_NameofUniversity__c',
            'nm_GraduationDegreeMode__c' => 'nm_GraduationDegreeMode__c',
            'nm_YearofCollegeCompletion__c' => 'nm_YearofCollegeCompletion__c',
            'nm_NameOfCollege__c' => 'nm_NameOfCollege__c',
            'Name_of_Program1__c' => 'Name_of_Program1__c',
            'Master_s_Degree_Name__c' => 'Master_s_Degree_Name__c',
            'Other_Name_of_Program1__c' => 'Other_Name_of_Program1__c',
            'Name_of_College1__c' => 'Name_of_College1__c',
            'Name_of_University1__c' => 'Name_of_University1__c',
            'Year_of_Passing1__c' => 'Year_of_Passing1__c',
            'Percentage1__c' => 'Percentage1__c',
            'Duration_of_Program1__c' => 'Duration_of_Program1__c',
            'Graduation_Degree_Mode1__c' => 'Graduation_Degree_Mode1__c',
            'Name_of_Program2__c' => 'Name_of_Program2__c',
            'Name_of_College2__c' => 'Name_of_College2__c',
            'Name_of_University2__c' => 'Name_of_University2__c',
            'Year_of_Passing2__c' => 'Year_of_Passing2__c',
            'Percentage2__c' => 'Percentage2__c',
            'Duration_of_Program2__c' => 'Duration_of_Program2__c',
            'Graduation_Degree_Mode2__c' => 'Graduation_Degree_Mode2__c',
            'Name_of_Program3__c' => 'Name_of_Program3__c',
            'Name_of_College3__c' => 'Name_of_College3__c',
            'Name_of_University3__c' => 'Name_of_University3__c',
            'Year_of_Passing3__c' => 'Year_of_Passing3__c',
            'Percentage3__c' => 'Percentage3__c',
            'Duration_of_Program3__c' => 'Duration_of_Program3__c',
            'Graduation_Degree_Mode3__c' => 'Graduation_Degree_Mode3__c',
            // 'nm_StudentImageUrl__c' => 'nm_StudentImageUrl__c',
            
            // Work Experience
           'nm_WorkExperience__c' => 'nm_WorkExperience__c',
            // 'Total_Work_Experience__c' => 'Total_Work_Experience__c',
            'LinkedIn_URL__c' => 'LinkedIn_URL__c'
        };
        

        for (String accountFieldName : mapOfAccountapiVsValues.keySet()) {
            Object fieldValue = mapOfAccountapiVsValues.get(accountFieldName);
            System.debug('fieldValue --> ' + fieldValue);
              
            // Check if the field has a value or is blank
            if (fieldValue == null ||(fieldValue instanceof Date ? false : (fieldValue instanceof Decimal ? false : String.isBlank((String)fieldValue)))) {
                System.debug('lead Api Name in IF--'+AccounttoLeadMapping.get(accountFieldName)+''+'value--'+fieldValue);
                objLead.put(AccounttoLeadMapping.get(accountFieldName), fieldValue);
                lateraleditablefields.add(accountFieldName);
            } else {
                System.debug('lead Api Name in else--'+AccounttoLeadMapping.get(accountFieldName)+''+'value--'+fieldValue);
                objLead.put(AccounttoLeadMapping.get(accountFieldName), fieldValue);
            }
        }
        objLead.Lateral_Editable_set__c = String.join(lateraleditablefields, ', '); 
        update objLead;
    }

    /**
    * @description // Converts "January2024" → Date(2024, 1, 1)
    * @author @Ravi | 10--12--2025 
    * @param String driveName 
    * @return Date 
    **/
    public Date convertDriveToDate(String driveName) {
        if (String.isBlank(driveName)) {
            return null;
        } 
            // Extract month string (alphabets only)
            String monthStr = driveName.replaceAll('[0-9]', '');
            // Extract year (digits only)
            String yearStr = driveName.replaceAll('[^0-9]', '');
        if (String.isBlank(monthStr) || String.isBlank(yearStr)){
            return null;
        }
            Integer year = Integer.valueOf(yearStr);
            Integer month = 0;
            Map<String, Integer> monthMap = new Map<String, Integer>{'January' => 1, 'February' => 2, 'March' => 3, 'April' => 4, 'May' => 5, 'June' => 6, 'July' => 7, 'August' => 8, 'September' => 9, 'October' => 10, 'November' => 11, 'December' => 12 };
            month = monthMap.get(monthStr);
        
        return Date.newInstance(year, month, 1);
    }

     /**
     * @description 
     * @author @Ravi | 29--09--2025 
     * @param String studentNumber 
     * @param Account objAccount 
     **/
    public static void markPassout(String studentNumber, Account objAccount) {
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
    * @author @Ravi | 30--12--2025 
    * @param String status 
    * @param String message 
    * @param LateralvalidateResponse data 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> buildMapResponse(String status,String message, Object data) {
        Map<String, Object> res = new Map<String, Object>();
        res.put('status', status);
        res.put('message', message);
        res.put('data', data);
        return res;
    }

          // Lateral Response Wrapper
    public class LateralvalidateResponse {
        public String recordId;
        public String accId;
        public String monthOfPassing;
        public String yearOfPassing;
        public String oldprogram;
        public String enrolledSem;
        public Boolean passout;
        public Account objAcc;
    }
}