/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 11--02--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   29--09--2025   @Ravi   Initial Version
**/
global without sharing class MobileAppFormPageAPIHandler {
    
    public Boolean isAlreadyQualified = false;
    public ProgramPicklist programResponse = new ProgramPicklist();
    public Map<String,String> mapOfInterviewDateTimeVsSlotId ;
    public Boolean inActive = false;  
    public String recid ='';
    public String reqURL ='';

    /**
    * @description 
    * @author @Ravi | 22--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getDashboardDetails(String url ,String jsonString) {
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
         try {
            if (!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            String objectType = getObjName(recid);
            if (objectType == null) {
                return buildResponse('Error', 'Invalid RecordId Found', null);
            }
            DashboardPageController controller = new DashboardPageController();
            controller.setObjectType(objectType);
            controller.setObjectId(recid);
            return buildResponse('Success', 'Student details fetched successfully.',controller.objRecord);
         } catch (Exception e) {
             insertAPIRequest2(reqURL,'Error while fetching data: ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error', 'Internal error occured. Kindly contact our Support Team.', null);
         }
      
    }
    /**
    * @description 
    * @author @Ravi | 22--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob fetchDetails(String url, String jsonString) {
        try {
            System.debug('jsonString--'+jsonString);
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
            Set<String> setRequiredParam = new Set<String>{'recordId','registrationNumber'};
            recid = String.valueOf(mapOfRequestParameters.get('recordId'));
            Blob result;
            if (!validateRequest(setRequiredParam, mapOfRequestParameters)) { 
                return  buildResponse('Error','Internal error occured. Missing required data', null); 
            } else {
                String registrationNumber =String.valueOf(mapOfRequestParameters.get('registrationNumber'));
                System.debug('registrationNumber=='+registrationNumber);
               result = fetchLeadAccountDetails(registrationNumber);
            }
         return result;
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error while fetching data: ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
           return buildResponse('Error', 'Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /*
    * @description 
    * @author @Ravi | 22--09--2025 
    * @param String registrationNumber 
    * @return Blob 
    **/
    public Blob fetchLeadAccountDetails(String registrationNumber) {
             Map<String, String> recordInfo = getRecordDetails(registrationNumber);
            if (recordInfo.isEmpty()) {
                return buildResponse('Error', 'No match found for entered Registration no.', null);
            }
            if (inActive) {
                return buildResponse('Error', 'Provided Registration Number had been expired.', null);
            }
            if (isAlreadyQualified) {
                return buildResponse('Error', 'Lead already qualified with another partner.', null);
            }
            FormPageController controller = new FormPageController();
            if (recordInfo.get('objectType') == 'Lead') {
                controller.setLeadId(recordInfo.get('recordId')); 
            } else {
               controller.setAccountId(recordInfo.get('recordId'));
            }
            LeadData responseData = new LeadData();
            responseData.leadId = controller.getLeadId();
            responseData.accountId = controller.getAccountId();
            responseData.objLead = controller.objLead;
            responseData.objAccount = controller.objAccount;
            responseData.lstWorkExperience = controller.lstWorkExperience;
            // responseData.isLateral = controller.isLateral;
            responseData.copyPermanantAddressFromTo = controller.copyPermanantAddressFromTo;
            responseData.isRecordQueried = controller.isRecordQueried;
            responseData.lateraleditablefields = controller.lateraleditablefields;
            responseData.mapOfIdVsProgram =controller.mapOfIdVsProgram;
            if(recordInfo.get('objectType') == 'Lead'){
                responseData.jsonMapOfEligibilityVsMaster = (Map<String, Boolean>) JSON.deserialize(controller.jsonMapOfEligibilityVsMaster, Map<String, Boolean>.class);
                responseData.jsonMapOfEligibilityVsWorkExp = (Map<String, String>) JSON.deserialize(controller.jsonMapOfEligibilityVsWorkExp, Map<String, String>.class);
                responseData.jsonMapOfEligibilityVsRequiredAcademic = (Map<String, Boolean>) JSON.deserialize(controller.jsonMapOfEligibilityVsRequiredAcademic, Map<String, Boolean>.class);
                responseData.jsonMapOfEligibilityVsRequiredAcademicPercentage = (Map<String, Decimal>) JSON.deserialize(controller.jsonMapOfEligibilityVsRequiredAcademicPercentage, Map<String, Decimal>.class);
                
            }
            if (controller.debDetailObject != null) {
                responseData.debDetailObject = (FormPageController.DEBDetails)JSON.deserialize(JSON.serialize(controller.debDetailObject), FormPageController.DEBDetails.class);
            }
            return buildResponse('Success', 'Student details fetched successfully.', responseData);
    }

    /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob handleDEBVerification(String url, String jsonString){
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> requiredParams = new Set<String>{'recordId','debId','isTermAgreed'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));

        if (!validateRequest(requiredParams, mapOfRequestParameters)) {
            return  buildResponse('Error','Internal error occured. Missing required data', null);
        }
        try {
            String DebId = String.valueOf(mapOfRequestParameters.get('debId'));
            Boolean isTermAgreed = Boolean.valueOf(mapOfRequestParameters.get('isTermAgreed'));
            String debTerms = String.valueOf(mapOfRequestParameters.get('debTerms'));
            Date dob;
            String ownerId;
            String objectType = getObjName(recid);

            if(System.Label.Enable_DEB_Verification =='Yes' || Test.isRunningTest())  {
                if (objectType == 'Account') {
                    Account acc = [SELECT Id, DEBID__c, OwnerId, nm_DateOfBirth__c FROM Account WHERE Id = :recid LIMIT 1];
                    dob     = acc.nm_DateOfBirth__c;
                    ownerId = acc.OwnerId;
                } else if(objectType == 'Lead') {
                    Lead leadRec = [SELECT Id, DEBID__c, OwnerId, nm_DateOfBirth__c  FROM Lead  WHERE Id = :recid  LIMIT 1];
                    dob     = leadRec.nm_DateOfBirth__c;
                    ownerId = leadRec.OwnerId;
                }
                    //handler request
                    DEBVerificationHandler.Request objRequest = new DEBVerificationHandler.Request();
                    objRequest.recordId = recid;
                    objRequest.objType  = objectType;
                    objRequest.debId    = DebId;
                    objRequest.dob      = dob;
                    objRequest.ownerId  = ownerId;
    
                    // Call handler
                    DEBVerificationHandler.Response objResponse = DEBVerificationHandler.verifyDEBID(objRequest);
                    FormPageController.DEBDetails details =  (FormPageController.DEBDetails)JSON.deserialize(JSON.serialize(objResponse), FormPageController.DEBDetails.class);
                
                if (!objResponse.isSuccess) {
                    return buildResponse('Error', 'Verification failed', details);
                }
                if (!objResponse.isDebMatched) {
                    return buildResponse('Error', 'Mismatch-DEB', details);
                }
                if (!objResponse.isDOBMatched) {
                    return buildResponse('Error', 'Mismatch-DOB', details);
                }
    
                if (objectType == 'Account') {
                    update new Account(Id = objRequest.recordId, DEBID__c = DebId,is_Deb_verified__c = true );
                }
                //  else {
                //     update new Lead( Id = objRequest.recordId, DEBID__c = DebId );
                // }
                return buildResponse('Success', 'DEB Verified', details);
            } else {
                Account objAccount = new Account(id=recid,DEBID__c=DebId,Agree_DEB_Terms__c=isTermAgreed);
                if (System.Label.Enable_DEB_Verification =='No' && isTermAgreed ) {
                    objAccount.DEB_Terms_And_Condition__c = debTerms;
                }
                 update objAccount;
                return buildResponse('Success', 'DEB Saved', null);
            }
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error', 'Internal Error Occured, Please try again.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 22--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob updateLead(String url, String jsonString) {
        System.debug('jsonString--' + jsonString);
    
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> requiredParams = new Set<String>{'recordId','copyPermanantAddressFromTo','objLead'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
        // Validate required params
        if (!validateRequest(requiredParams, mapOfRequestParameters)) {
            return  buildResponse('Error','Internal error occured. Missing required data', null);
        }
        try {
            String copyPermanantAddressFromTo = String.valueOf(mapOfRequestParameters.get('copyPermanantAddressFromTo'));
            Lead objLead = (Lead) JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('objLead')), Lead.class);
    
            // Controller logic
            FormPageController controller = new FormPageController();
            controller.setLeadId(recid);
            controller.copyPermanantAddressFromTo = copyPermanantAddressFromTo;
            controller.objLead = objLead;
            controller.nextPage();
            
            // Build response
            String status = String.isBlank(controller.errorMsg) ? 'Success' : 'Error';
            String msg = String.isBlank(controller.errorMsg) ? (String.isBlank(controller.lateralMessage) ? 'Lead Updated successfully' : controller.lateralMessage): controller.errorMsg;
            if(status=='Error'){
                insertAPIRequest2(reqURL, 'Error: '+controller.exceptionError, url, false, recid);
            }
            return buildResponse(status, msg, null);
        } catch (Exception e) {
             insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error', 'Internal error occured. Kindly contact our Support Team.', null);
        }
    }
    
     /**
     * @description 
     * @author @Ravi | 22--09--2025 
     * @param String jsonString 
     * @return Blob 
     **/
     public Blob goToConfirmationForm(String url,String jsonString){
        System.debug('jsonString--'+jsonString);
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId','objLead'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
        if(!validateRequest(setRequiredParam, mapOfRequestParameters)){
            return  buildResponse('Error','Internal error occured. Missing required data', null);
        }
         try {
            String recordId = String.valueOf(mapOfRequestParameters.get('recordId'));
            Lead objLead = (Lead) JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('objLead')), Lead.class);
            Object workExpObj = mapOfRequestParameters.containsKey('lstWorkExperience') ? mapOfRequestParameters.get('lstWorkExperience'): null;
            // List<nm_WorkExperience__c> weList = (List<nm_WorkExperience__c>) JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('lstWorkExperience')), List<nm_WorkExperience__c>.class);
            List<nm_WorkExperience__c> weList = (workExpObj == null) ? new List<nm_WorkExperience__c>(): (List<nm_WorkExperience__c>) JSON.deserialize( JSON.serialize(workExpObj),  List<nm_WorkExperience__c>.class);
            FormPageController controller = new FormPageController();
                 // Set record ID
                 if(!String.isBlank(String.valueOf(mapOfRequestParameters.get('removedWorkExperience')))){
                    List<Id> workExpIds = (List<Id>) JSON.deserialize(JSON.serialize(mapOfRequestParameters.get('removedWorkExperience')), List<Id>.class);
                        controller.removedWorkExperience = new Set<Id>(workExpIds);
                }
                 controller.setLeadId(recordId);
                 controller.objLead = objLead;
                 controller.lstWorkExperience =weList;
                 controller.goToConfirmationForm();
                 String status=String.isBlank(controller.errorMsg) ? 'Success' : 'Error';
                 String msg = String.isBlank(controller.errorMsg) ? (String.isBlank(controller.lateralMessage)  ? 'Lead Updated successfully' : controller.lateralMessage) : controller.errorMsg;
                 if(status=='Error'){
                    insertAPIRequest2(reqURL,'Error :'+ controller.exceptionError, url, false, recid);
                 }
                 return buildResponse(status, msg, null);
         } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error', 'Internal error occured. Kindly contact our Support Team.', null);

         }
     }

         
    /**
    * @description 
    * @author @Ravi | 25--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getProgramPicklistValues(String url,String jsonString ) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId','chooseProgram','IsLateral'};  //,'lateralCourseName','programType'
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                // insertAPIRequest2(reqURL,'Error :Internal error occured. Kindly contact our Support Team. ,Required:' + setRequiredParam +'mapOfRequestParameters ==>'+ mapOfRequestParameters, url, false, recid);
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            String chooseProgram = String.valueOf(mapOfRequestParameters.get('chooseProgram'));
            Boolean isLateral    = Boolean.valueOf(mapOfRequestParameters.get('IsLateral'));
            String lateralCourseName = String.valueOf(mapOfRequestParameters.get('lateralCourseName'));
            String programType  = String.valueOf(mapOfRequestParameters.get('programType'));

            programResponse.getProgramsList = getProgramsList(chooseProgram, programType);
            programResponse.getEligibilityCriteriaList = getEligibilityCriteriaList(chooseProgram, programType);
            programResponse.getSpecializationList =getSpecializationList(chooseProgram, isLateral, lateralCourseName);
            return buildResponse('Success', 'Picklist values fetched successfully', programResponse);
  
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 25--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob checkLateralValidations(String url,String jsonString) {
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId','SAPId','chooseProgram'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                // insertAPIRequest2(reqURL,'Error :Internal error occured. Kindly contact our Support Team. ,Required:' + setRequiredParam +'mapOfRequestParameters ==>'+ mapOfRequestParameters, url, false, recid);
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            String studentNumber = String.valueOf(mapOfRequestParameters.get('SAPId'));
            String selectedProgram = String.valueOf(mapOfRequestParameters.get('chooseProgram'));
            map<String,Object> studentDetails = LateralDataAssigmentWrapper.validateLateralStudentDetails(studentNumber,selectedProgram);
            String status =String.valueOf(studentDetails.get('status')) ;
            String messsage = String.valueOf(studentDetails.get('message'));
           return buildResponse(status,messsage, studentDetails.get('data'));
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error : ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 25--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob updateLateralDetails(String url,String jsonString ){
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId','accId','enrolledSem','oldprogram'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                // insertAPIRequest2(reqURL,'Error : Internal error occured. Kindly contact our Support Team.' +'Required :'+setRequiredParam +'mapOfRequestParameters:'+mapOfRequestParameters, url, false, recid);
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            LateralvalidateResponse data =(LateralvalidateResponse) JSON.deserialize(jsonString,LateralvalidateResponse.class);
            if(queryLateralAccountRecord(data)){
                return buildResponse('Success','Lateral Details Updated.', null);
            } else {
                // insertAPIRequest2(reqURL,'No match found for entered SAP ID.s', url, false, recid);
                return buildResponse('Error','No match found for entered SAP ID.', null);
            }
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 25--09--2025 
    * @param LateralvalidateResponse data 
    * @return Boolean 
    **/
    public Boolean queryLateralAccountRecord(LateralvalidateResponse data) {
        String accountQuery = accountQuery();
        String accid=data.accId;
        accountQuery = accountQuery+' WHERE id=:accid LIMIT 1';
        List<Account> lstAccount = DataBase.query(accountQuery);
        LateralDataAssigmentWrapper assigmentWrapper =new LateralDataAssigmentWrapper();
        Lead objLead = new Lead();
        System.debug(lstAccount[0]);
            if(lstAccount.size() > 0 ) {
                    Account accountRecord = lstAccount[0]; 
                    objLead.Id = data.recordId;
                    objLead.Student_Number_Lateral__c = accountRecord.Student_ID__c;
                    objLead.Year_Of_Passing_Lateral__c = data.yearOfPassing;
                    objLead.Month_Of_Passing_Lateral__c = data.monthOfPassing;
                    objLead.Course_Name_Lateral__c = data.oldprogram;
                    objLead.Is_Lateral__c =true;
                    objLead.Sem__c = data.enrolledSem ;
                    objLead.nm_Semester__c = data.enrolledSem;
                    objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                    assigmentWrapper.leadIdRecordId= data.recordId;
                    assigmentWrapper.updateLeadData(accountRecord,data.recordId,objLead);
                    assigmentWrapper.addLateralStudentWkExperience(accountRecord.Id);   
                    assigmentWrapper.populateApporovedDefaultDocs(accountRecord.Id);
                    return true; 
            } 
            return false;
    }

     /**
     * @description 
     * @author @Ravi | 29--09--2025 
     * @param String url 
     * @param String jsonString 
     * @return Blob 
     **/
     public Blob updateAsNonLateral(String url , String jsonString){
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId','IsLateral'};
        recid =String.valueOf(mapOfRequestParameters.get('recordId'));
        Boolean islateral =Boolean.valueOf(mapOfRequestParameters.get('IsLateral'));
        Lead objLead = new Lead();
        try { 
            if (!islateral) {
                objLead.Id =recid;
                objLead.Sem__c='';
                objLead.Student_Number_Lateral__c = '';
                objLead.Year_Of_Passing_Lateral__c = '';
                objLead.Month_Of_Passing_Lateral__c = '';
                objLead.Course_Name_Lateral__c = '';
                objLead.Is_Lateral__c = false;
                objLead.Is_Non_Lateral__c ='Yes';
                update objLead;
                return buildResponse('Success', 'Kindly continue with the new admission form.', null);   
            }
             return buildResponse('Error', 'Internal error occured. Kindly contact our Support Team.', null);  
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recid);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }
 
    /**
    * @description 
    * @author @Ravi | 23--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getDocuments(String url,String jsonString) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
           if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
             return  buildResponse('Error','Internal error occured. Missing required data', null);
           } 
          
           String objectType = getObjName(recordId);
            if (objectType == null) {
                return buildResponse('Error', 'Invalid RecordId Found', null);
            }  
            // Initialize Controller
             DocumentPageController controller = new DocumentPageController();
             controller.setObjectType(objectType);
             controller.setObjectId(recordId);
 
             // Response Wrapper
             DocumentResponseWrapper response = new DocumentResponseWrapper();
             response.recordId                  = recordId;
             response.lstDocuments              = controller.lstDocuments;
             response.isRecordExists             = controller.isRecordExists;
             response.isProvisinalWithHold       = controller.isProvisinalWithHold;
             response.showOldDocument            = controller.showOldDocument;
             response.countOfUploadedDocuments   = controller.countOfUploadedDocuments;
             response.hideSubmitButton           = controller.hideSubmitButton;
             return buildResponse('Success', 'Documents fetched successfully.', response);
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return  buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 11--02--2026 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob uploadDocuments(String url,String jsonString) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId','documentId','uploadMode','documentURL'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        String documentId = String.valueOf(mapOfRequestParameters.get('documentId'));
        String documentStatus =String.valueOf(mapOfRequestParameters.get('documentStatus'));
        String uploadMode =String.valueOf(mapOfRequestParameters.get('uploadMode'));
        String documentURL =String.valueOf(mapOfRequestParameters.get('documentURL'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
           }
        // DocumentUploadWrapper input = (DocumentUploadWrapper)JSON.deserialize( jsonString, DocumentUploadWrapper.class);
           String objectType = getObjName(recordId);
           system.debug('Test log==>'+objectType);
           if (objectType == null) {
               return buildResponse('Error', 'Invalid RecordId Found', null);
           }
            if(objectType =='Lead') {
                nm_LinksForDocumentsLead__c docList = new nm_LinksForDocumentsLead__c();
                docList.Id =documentId;
                docList.nm_Status__c = String.isBlank(documentStatus)? 'Submitted': documentStatus;
                docList.Document_Upload_Mode__c = uploadMode;
                docList.nm_URLforDocuments__c =documentURL;
                update docList;
            } else if(objectType =='Account') {
                nm_LinksForDocuments__c  docList = new nm_LinksForDocuments__c();
                docList.Id =documentId;
                docList.nm_Status__c = documentStatus == 'Documents incorrect' ? 'Re-Submited': 'Submitted';
                docList.Document_Upload_Mode__c = uploadMode;
                docList.nm_URLforDocuments__c =documentURL;
                update docList;
            }
           return buildResponse('Success','Document uploaded.', null); 
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error :' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return  buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);  
        }
    }

    /**
    * @description 
    * @author @Ravi | 31--10--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getWelcomeLetter(String url,String jsonString) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            List<EmailTemplate> emailTemplate = [SELECT Id FROM EmailTemplate WHERE name='Admission Confirmation' LIMIT 1];
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, null, recordId);
            String emailHtmlBody = email.getHtmlBody();
            System.debug('body-->'+ emailHtmlBody);
            return buildResponse('Success', 'data fetched successfully.', new Map<String,String >{'template' => emailHtmlBody});
        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error : ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 23--09--2025 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getPicklistValues(String url,String jsonString) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        Set<String> setRequiredParam = new Set<String>{'recordId'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            String objectType = getObjName(recordId);
            PicklistResponse responseData = new PicklistResponse();
                FormPageController controller = new FormPageController();
                if (objectType == 'Lead') controller.setLeadId(recordId);
                else controller.setAccountId(recordId);
            
                responseData.getDomicile                   = convertSelectOptions(controller.getDomicile());
                responseData.getProgramsList               = convertSelectOptions(controller.getProgramsList());
                responseData.getWorkExpTimeList            = convertSelectOptions(controller.getWorkExpTimeList());
                responseData.getProgramTypePicklistValues  = convertSelectOptions(controller.getProgramTypePicklistValues());
                responseData.getUniversityOption           = convertUniversityList(GetUniversityList.getUniversityDetails());
                responseData.getGlobalLocalityOptionValues = getPicklistOptions(Lead.Locality__c);
                responseData.publicStateValue              = getPicklistOptions(Lead.State__c);
                responseData.publicCountryValue            = getPicklistOptions(Lead.Country__c);
                responseData.getBachelorsDegree            = getPicklistOptions(Lead.nm_BachelorsDegreeName__c);
                responseData.getMastersDegree              = getPicklistOptions(Lead.Master_s_Degree_Name__c);
                responseData.getIndustryOptions            = getPicklistOptions(nm_WorkExperience__c.Industry__c);
                responseData.getAnnualIncomeOptions        = getPicklistOptions(nm_WorkExperience__c.Annual_Income__c);
                responseData.getDepartmentOptions          = getPicklistOptions(nm_WorkExperience__c.nm_Department__c);
                responseData.getDesignationOptions         = getPicklistOptions(nm_WorkExperience__c.nm_Designation__c);
                responseData.getExperienceLevelOptions     = getPicklistOptions(nm_WorkExperience__c.Experience_Level__c);
                return buildResponse('Success', 'Picklist values fetched successfully.', responseData);
        } catch (Exception e){
            insertAPIRequest2(reqURL,'Error : ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 18--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getInterviewDetails(String url,String jsonString) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        InterviewDetailsResponse interviewData = new InterviewDetailsResponse();
        Set<String> setRequiredParam = new Set<String>{'recordId'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
           InterviewFormPageController controller = new InterviewFormPageController();
           controller.setObjectId(recordId);
           interviewData.recordId =recordId;
           interviewData.statusCode =controller.statusCode;
           interviewData.message =controller.message;
           interviewData.isSlotBooked =controller.isSlotBooked;
           interviewData.isSlotAvailable =controller.isSlotAvailable;
           interviewData.bookedInterviewDate = controller.bookedInterviewDate;
           interviewData.bookedTimeRange =controller.bookedTimeRange;
           interviewData.joinLink =controller.joinLink;
           interviewData.bookedTime =controller.bookedTime;
           interviewData.objInterviewDetails =controller.objInterviewDetails;
           interviewData.mapOfSlotVsAccountlistSize =controller.mapOfSlotVsAccountlistSize;
           interviewData.lstInterviewDate =convertSelectOptions(controller.getInterviewDate());
           interviewData.lstInterviewTime = convertSelectOptions(controller.getInterviewTime());

            return buildResponse('Success', 'fetched Interview details.', interviewData);
         } catch(Exception e){
            insertAPIRequest2(reqURL,'Error: ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 19--11--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob getInterviewSlot(String url,String jsonString) {
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        InterviewDetailsResponse interviewData = new InterviewDetailsResponse();
        Set<String> setRequiredParam = new Set<String>{'recordId','selectedDate'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)) {
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            
           InterviewFormPageController controller = new InterviewFormPageController();
           controller.setObjectId(recordId);
           controller.objInterviewDetails.interviewDate = Date.valueOf(String.valueOf(mapOfRequestParameters.get('selectedDate')));
           interviewData.lstInterviewTime = convertSelectOptions(controller.getInterviewTime());
           return buildResponse('Success', 'fetched time slot details.',new Map<String,list<SelectOption>>{'timeSlotList' => interviewData.lstInterviewTime});

         } catch(Exception e){
            insertAPIRequest2(reqURL,'Error: ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }

    /**
    * @description 
    * @author @Ravi | 02--12--2025 
    * @param String url 
    * @param String jsonString 
    * @return Blob 
    **/
    public Blob saveInterviewCallDetails(String url,String jsonString) { 
        Map<String ,Object> mapOfRequestParameters = (Map<String ,Object>)JSON.deserializeUntyped(jsonString);
        InterviewDetailsResponse interviewData = new InterviewDetailsResponse();
        Account objAccount =new Account();
        Set<String> setRequiredParam = new Set<String>{'recordId','selectedDate','selectedTime'};
        String recordId   = String.valueOf(mapOfRequestParameters.get('recordId'));
        String slotId;
        try {
            if(!validateRequest(setRequiredParam, mapOfRequestParameters)){
                return  buildResponse('Error','Internal error occured. Missing required data', null);
            }
            InterviewFormPageController controller = new InterviewFormPageController();
            controller.setObjectId(recordId);
            objAccount.Id =recordId;

            controller.objInterviewDetails.interviewDate =Date.valueOf(String.valueOf(mapOfRequestParameters.get('selectedDate')));
            controller.objInterviewDetails.timeRange =String.valueOf(mapOfRequestParameters.get('selectedTime'));
            controller.getInterviewTime();

            mapOfInterviewDateTimeVsSlotId =controller.mapOfInterviewDateTimeVsSlotId;
            String mapKey = controller.objInterviewDetails.timeRange + '-' + String.valueOf(mapOfRequestParameters.get('selectedDate'));
            System.debug('mapKey -->'+mapKey);
            System.debug('mapOfInterviewDateTimeVsSlotId -->'+mapOfInterviewDateTimeVsSlotId.keySet());

            if(mapOfInterviewDateTimeVsSlotId.containsKey(mapKey)) {
                slotId = mapOfInterviewDateTimeVsSlotId.get(mapKey);
                objAccount.Interview_Slot__c = slotId;
            } else {
                System.debug('Interview Slot id is missing');
                return buildResponse('Error','Internal Error Occured, Kindly try again later.',null);
            }

            if(controller.checkForSlotAvalialbility(objAccount.Interview_Slot__c)) {
                objAccount.Time_Range__c = controller.objInterviewDetails.timeRange;
                objAccount.Interview_Date__c = controller.objInterviewDetails.interviewDate;
                update objAccount;
                 return buildResponse('Success','Interview Slot Booked Successfully.',null);
            } else {
                 return buildResponse('Success','The selected Interview slot is not available',null);
            }

        } catch (Exception e) {
            insertAPIRequest2(reqURL,'Error: ' + e.getMessage()+'Line ==>'+e.getLineNumber(), url, false, recordId);
            return buildResponse('Error','Internal error occured. Kindly contact our Support Team.', null);
        }
    }


    /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param String chooseProgram 
    * @param Boolean isLateral 
    * @param String lateralCourseName 
    * @return List<SelectOption> 
    **/
    public List<SelectOption> getSpecializationList(String chooseProgram, Boolean isLateral, String lateralCourseName) {
        Map<String,String> master   = new Map<String,String>{ 'MBA (WX)' => 'Master of Business Administration (Working Executive)'};
        Map<String,String> bachelor = new Map<String,String>{ 'BCom' => 'Bachelor of Commerce', 'BBA' => 'Bachelor of Business Administration' };
        Map<String,String> mbaOnline= new Map<String,String>{ 'MBA'  => 'Master of Business Administration' };

        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', 'Choose Program') };
        String selectedProgram = String.isBlank(chooseProgram) ? '' : chooseProgram.trim();

        if (selectedProgram == 'Master Programs') {
            options.addAll(getOptionsFromMap(master));
        } else if (selectedProgram == 'MBA (Online) Programs') {
            options.addAll(getOptionsFromMap(mbaOnline));
        } else if (selectedProgram == 'Bachelor Programs') {
            for (String key : bachelor.keySet()) {
                if (IsLateral) {
                    if ((lateralCourseName == 'Certificate in Business Administration' && key == 'BBA') ||
                        (lateralCourseName == 'Certificate in General Management' && key == 'BCom')) {
                        options.add(new SelectOption(key, bachelor.get(key)));
                    }
                } else {
                    options.add(new SelectOption(key, bachelor.get(key)));
                }
            }
        }
        return options;
    }

     /**
     * @description 
     * @author @Ravi | 29--09--2025 
     * @param String chooseProgram 
     * @param String programType 
     * @return List<SelectOption> 
     **/
     public static List<SelectOption> getProgramsList(String chooseProgram, String programType) {
        List<SelectOption> options = new List<SelectOption>();
        List<nm_Program__c> programs;

        if (new List<String>{'Master Programs', 'Bachelor Programs', 'MBA (Online) Programs'}.contains(chooseProgram)) {
            programs = [SELECT Id, nm_ProgramName__c, Form_Specialisation__c, Specialisation__c  FROM nm_Program__c  WHERE nm_Type__c = :chooseProgram AND Specialisation__c = :programType 
                          AND nmIsActive__c = true ORDER BY Name ASC];
            options.add(new SelectOption('', 'Choose Specialization'));
        } else {
            chooseProgram = String.isBlank(chooseProgram) ? 'Certificate Programs' : chooseProgram;
            programs = [SELECT Id, nm_ProgramName__c, Specialisation__c, Form_Specialisation__c FROM nm_Program__c WHERE nm_Type__c = :chooseProgram 
                          AND nmIsActive__c = true ORDER BY Name ASC];
            options.add(new SelectOption('', 'Choose Program'));
        }

        for (nm_Program__c prog : programs) {
            String prgName = (prog.Form_Specialisation__c != null) ? prog.Form_Specialisation__c : prog.nm_ProgramName__c;
            options.add(new SelectOption(prog.Id, prgName));
        }
        return options;
    }

     /**
     * @description 
     * @author @Ravi | 29--09--2025 
     * @param String chooseProgram 
     * @param String type 
     * @return List<SelectOptionForCriteria> 
     **/
     public List<SelectOptionForCriteria> getEligibilityCriteriaList(String chooseProgram, String type ){  
        List<SelectOptionForCriteria> lstECOptions = new List<SelectOptionForCriteria>{ new SelectOptionForCriteria('', '---None--',0) };

        String programType = (chooseProgram == 'Master Programs') ? type : null;
        List<nm_EligiblityCriteria__c> lstEligibility = [
            SELECT Id,nm_EligiblityCriteria__c,Experience_Required_In_Year__c,HSC_Re__c,Diploma_Required__c, Graduation_Required__c,Post_Graduation_Required__c,Post_Graduation_Percentage__c,Graduation_Percentage__c,nm_Program__c,Is_Active__c,Program_Type__c,HSC_Percentage__c,
                   Diploma_Percentage__c,Enable_Master__c FROM nm_EligiblityCriteria__c WHERE Program_Type__c = :programType  AND nm_Program__c = :chooseProgram AND Is_Active__c = true];

        if (!lstEligibility.isEmpty()) {
            Map<String,String>  mapWorkExp = new Map<String,String>();
            Map<String,Decimal> mapAcademicPerc = new Map<String,Decimal>();
            Map<String,Boolean> mapAcademicReq = new Map<String,Boolean>();
            Map<String,Boolean> mapMaster = new Map<String,Boolean>();

            for (nm_EligiblityCriteria__c obj : lstEligibility) {
                Decimal we = (obj.Experience_Required_In_Year__c == null) ? 0 : obj.Experience_Required_In_Year__c;
                lstECOptions.add(new SelectOptionForCriteria(obj.Id, obj.nm_EligiblityCriteria__c, we));

                mapWorkExp.put(obj.Id, String.valueOf(obj.Experience_Required_In_Year__c));
                mapAcademicReq.put(obj.Id+'-HSC', obj.HSC_Re__c);
                mapAcademicReq.put(obj.Id+'-Diploma', obj.Diploma_Required__c);
                mapAcademicReq.put(obj.Id+'-Graduation', obj.Graduation_Required__c);
                mapAcademicReq.put(obj.Id+'-Professional', obj.Post_Graduation_Required__c);

                mapAcademicPerc.put(obj.Id+'-HSC', obj.HSC_Percentage__c);
                mapAcademicPerc.put(obj.Id+'-Diploma', obj.Diploma_Percentage__c);
                mapAcademicPerc.put(obj.Id+'-Graduation', obj.Graduation_Percentage__c);
                mapAcademicPerc.put(obj.Id+'-Professional', obj.Post_Graduation_Percentage__c);

                mapMaster.put(obj.Id, obj.Enable_Master__c);
            }
            programResponse = (programResponse == null) ? new ProgramPicklist() : programResponse;
            programResponse.jsonMapOfEligibilityVsWorkExp                  = mapWorkExp;
            programResponse.jsonMapOfEligibilityVsRequiredAcademic         = mapAcademicReq;
            programResponse.jsonMapOfEligibilityVsRequiredAcademicPercentage = mapAcademicPerc;
            programResponse.jsonMapOfEligibilityVsMaster                   = mapMaster;
        }
        return lstECOptions;
    }

    /**
    * @description: find student Details.
    * @author @Ravi | 13--08--2025 
    * @param String registrationNumber 
    * @return Map<String, String> 
    **/
    public Map<String, String> getRecordDetails(String registrationNumber) {  
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

            if(!objWrapper.isValid) {   // Perform update activity, so that the current session and year are updated on the Lead if a Lead exists with the old session and year.
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

    /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param detailsWrapper objWrapper 
    * @return Boolean 
    **/
    public static Boolean setValid(detailsWrapper objWrapper) {
        List<Calender__c> lstCalender = getActiveCalender(objWrapper.chooseProgram,objWrapper.programType);
        if (lstCalender.size() > 0) { 
            return String.isNotBlank(objWrapper.session) && objWrapper.year!=null && objWrapper.session == lstCalender[0].Session__c && objWrapper.year == lstCalender[0].Year__c ? true : false;
        }
        return false;
    }

    /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param String program 
    * @param String specialization 
    * @return List<Calender__c> 
    **/
    public static List<Calender__c> getActiveCalender(String program,String specialization) {
        List<Calender__c> lstCalender = [SELECT Id, Year__c, Specialisation__c, Session_End_Date__c, Session__c, Category__c, Session_Start_Date__c FROM Calender__c WHERE Category__c='Admission' AND nm_Type__c=:program AND Specialisation__c=:specialization AND Session_Start_Date__c <= Today AND Session_End_Date__c >= Today LIMIT 1];
        return lstCalender;
    }


    /**
    * @description 
    * @author @Ravi | 29--09--2025 
    * @param Map<String String> input 
    * @return List<SelectOption> 
    **/
    private static List<SelectOption> getOptionsFromMap(Map<String,String> input) {
        List<SelectOption> options = new List<SelectOption>();
        for (String key : input.keySet()){
         options.add(new SelectOption(key, input.get(key)));
        }
          return options;
     }

    /**
    * @description 
    * @author @Ravi | 23--09--2025 
    * @param Schema.SObjectField field 
    * @return List<SelectOption> 
    **/
    private static List<SelectOption> getPicklistOptions(Schema.SObjectField field) {
        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '---None---') };
        for (Schema.PicklistEntry pe : field.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(pe.getValue(), pe.getValue()));
        }
        return options;
    }

    /**
    * @description 
    * @author @Ravi | 23--09--2025 
    * @param List<University_List__c> uniList 
    * @return List<UniversityOption> 
    **/
    private static List<UniversityOption> convertUniversityList(List<University_List__c> uniList) {
        List<UniversityOption> options = new List<UniversityOption>{ new UniversityOption('', '-- Select --','') };
        for (University_List__c uni : uniList) {
            options.add(new UniversityOption(uni.University_Name__c, uni.University_Name__c, uni.University_Type__c));
        }
        return options;
    }

    /**
    * @description 
    * @author @Ravi | 23--09--2025 
    * @param List<System.SelectOption> options 
    * @return List<SelectOption> 
    **/
    private static List<SelectOption> convertSelectOptions(List<System.SelectOption> options) {
        if (options == null) return null;
        List<SelectOption> result = new List<SelectOption>();
        for (System.SelectOption opt : options)
        {
            result.add(new SelectOption(opt.getValue(), opt.getLabel()));
        } 
        return result;
    }

    /**
    * @description 
    * @author @Ravi | 11--02--2026 
    * @param String status 
    * @param String message 
    * @param Object data 
    * @return Blob 
    **/
    private static Blob buildResponse(String status, String message, Object data) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('status', status);
        response.put('message', message);
        if (data != null) {
            response.put('data', data);
        }
        return Blob.valueOf(JSON.serialize(response));
    }

    /**
    * @description 
    * @author @Ravi | 11--02--2026 
    * @param String req 
    * @param String res 
    * @param String apiName 
    * @param Boolean isSuccess 
    * @param Id recordId 
    **/
    private static void insertAPIRequest2(String req, String res, String apiName, Boolean isSuccess, Id recordId) {
        if(!Test.isRunningTest()) {
            String objectName=getObjName(recordId);
            APIRequestHandler.insertAPIRequest(req, res, apiName, isSuccess, recordId, objectName, 'MobileApp');
        } 
    }

    /**
    * @description 
    * @author @Ravi | 11--02--2026 
    * @param Set<String> requiredParams 
    * @param Map<String Object> requestParams 
    * @return Boolean 
    **/
    private static Boolean validateRequest(Set<String> requiredParams, Map<String,Object> requestParams) {
        for (String param : requiredParams) {
            if (!requestParams.containsKey(param) ||  requestParams.get(param) == null || String.valueOf(requestParams.get(param)).trim().length() == 0) {
                return false;
            }
        }
        return true;
    }

    private static String getObjName(Id recordId) {
        return recordId!=null ? recordId.getSObjectType().getDescribe().getName() : null;
    }

    public class SelectOption {
        public String value;
        public String label;
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    public class UniversityOption {
        public String value;
        public String label;
        public String Type;
        public UniversityOption(String value, String label, String Type) {
            this.value = value;
            this.label = label;
            this.Type  = Type;
        }
    }

    public class SelectOptionForCriteria {
        public String value;
        public String label;
        public Decimal WExpRequired;
        public SelectOptionForCriteria(String value, String label, Decimal WeRequired) {
            this.value = value;
            this.label = label;
            this.WExpRequired = WeRequired;
        }
    }
    // ----------------------------
    // Response Wrapper Classes
    // ----------------------------
    // public class DEBDetails {
    //     public Boolean isAPICalled {get;set;}
    //     public Boolean isDEBActive {get;set;}
    //     public Boolean isDOBMatched {get;set;}
    //     public Boolean isDebMatched {get;set;}  
    //     public Boolean isABCMatched {get;set;}
    //     public Date dateOfBirthDEB {get;set;}
    //     public String debUniqueId {get;set;}
    //     public String abcUniqueId {get;set;}
    //     public Boolean isDebInvalid {get;set;}
    //     public String debTerms {get;set;}

    // }
    // Lead Data Wrapper
    public class LeadData {
        public String leadId;
        public String accountId;
        public Boolean isRecordQueried;
        public Boolean isLateral;
        public String copyPermanantAddressFromTo;
        public Boolean isDEBVerificationEnable = String.valueOf(System.label.Enable_DEB_Verification) =='Yes' ? true : false;
        public Boolean byPassDEBVerification = String.valueOf(System.Label.ByPass_DEB_Verification) == 'Yes' ? true: false;
        public String lateralAdmAllowedProgram =String.valueOf(System.Label.Not_allow_for_lateral_Admission);

        public Lead objLead;
        public Account objAccount;
        public FormPageController.DEBDetails debDetailObject;

        public List<nm_WorkExperience__c> lstWorkExperience;
        public List<String> lateraleditablefields;

        public Map<String,Boolean> jsonMapOfEligibilityVsMaster;
        public Map<String,Decimal> jsonMapOfEligibilityVsRequiredAcademicPercentage;
        public Map<String,Boolean> jsonMapOfEligibilityVsRequiredAcademic;
        public Map<String,String> jsonMapOfEligibilityVsWorkExp;
        public Map<String,nm_Program__c> mapOfIdVsProgram;
    }

    public class detailsWrapper {
        public String chooseProgram;
        public String programType;
        public String session;
        public Integer year; 
        public Boolean isValid; 
    }

     // Document Response Wrapper
    public class DocumentResponseWrapper {
         public String recordId;
         public List<DocumentPageController.DocumentWrapper> lstDocuments;
         public Boolean isRecordExists;
         public Boolean isProvisinalWithHold;
         public Boolean showOldDocument;
         public Integer countOfUploadedDocuments;
         public Boolean hideSubmitButton;
     }

    //  public class DocumentUploadWrapper {
    //      public String documentId;
    //      public String uploadMode;
    //      public String documentStatus;
    //      public String documentURL;
    //  }

     // PickList Response Wrapper
    public class PicklistResponse {
        public List<SelectOption> getDomicile;
        public List<SelectOption> getProgramsList;
        public List<SelectOption> publicStateValue;
        public List<SelectOption> publicCountryValue;
        public List<SelectOption> getWorkExpTimeList;
        public List<SelectOption> getProgramTypePicklistValues;
        public List<UniversityOption> getUniversityOption;
        public List<SelectOption> getBachelorsDegree;
        public List<SelectOption> getMastersDegree;
        public List<SelectOption> getGlobalLocalityOptionValues;
        public List<selectOption> getIndustryOptions;
        // public List<SelectOption> getCompanyNames;
        public List<SelectOption> getDepartmentOptions;
        public List<SelectOption> getDesignationOptions;
        public List<SelectOption> getExperienceLevelOptions;
        public List<SelectOption> getAnnualIncomeOptions;

    }
    // Program Response Wrapper
    public class ProgramPicklist {
        public List<SelectOption> getSpecializationList;
        public List<SelectOption> getProgramsList;
        public List<SelectOptionForCriteria> getEligibilityCriteriaList;
        public Map<String,Boolean> jsonMapOfEligibilityVsMaster;
        public Map<String,Decimal> jsonMapOfEligibilityVsRequiredAcademicPercentage;
        public Map<String,Boolean> jsonMapOfEligibilityVsRequiredAcademic;
        public Map<String,String> jsonMapOfEligibilityVsWorkExp;
    }

      // Lateral Response Wrapper
    public class LateralvalidateResponse {
        public String recordId;
        public String accId;
        public String monthOfPassing;
        public String yearOfPassing;
        public String oldprogram;
        public String enrolledSem;
    }

     //Interview Response Wrapper
     public class InterviewDetailsResponse {
        public Id recordId;
        public String statusCode ;
        public String message ;  
        public Boolean isSlotBooked ;
        public Boolean isSlotAvailable ;
        public Date bookedInterviewDate ;
        public String bookedTimeRange ;
        public String joinLink ;
        public DateTime bookedTime ;
        public InterviewFormPageController.InterviewDetails objInterviewDetails ;
        public Map<String,Integer> mapOfSlotVsAccountlistSize ;
    
        // Picklist Options
        public list<SelectOption> lstInterviewTime ;
        public List<SelectOption> lstInterviewDate ;
     }

    public static String accountQuery() { 
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
}