/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : @vickysahu
**/
public without sharing class DEBVerificationHandler {

    public static Response verifyDEBID(Request objRequest) {
        // debDetailObject.isAPICalled = true;
        Response objResponse = new Response();
        System.debug('method--->');
        if(String.isBlank(objRequest.debId)) {
            return objResponse;
        }

        try {
            DEBStudentDetailsWrapper response = DEBUGCWebService.getStudentDetails(objRequest.debId, objRequest.recordId);
            System.debug('response1--->' + response);
            if(response==null) {
                objResponse.isDEBActive = false;
                objResponse.isDOBMatched = false;
                objResponse.isDebMatched = false;
                objResponse.isDebInvalid = true;
                return objResponse;
            }
            objResponse.isDebInvalid = false;
            
            if(!updateExistingDEB(objRequest)) {
                return objResponse;
            }

            objResponse = insertDEB(response.Resource[0], objRequest, objResponse);
            if(!objResponse.isSuccess) {
                return objResponse;
            }

            System.debug('isDebMatched =>'+objResponse.isDebMatched);
            System.debug('isDEBActive =>'+objResponse.isDEBActive);
            System.debug('isDOBMatched =>'+objResponse.isDOBMatched);

        } catch (Exception error) {
            System.debug('Error on => verifyDEBID');
            System.debug('Error Messgae =>'+error.getMessage());
            System.debug('Error Line Number =>'+error.getLineNumber());
            return objResponse;
        }

        return objResponse;
    }

    /**
    * @description 
    * @author @BK | 10-09-2024 
    * @param DEBStudentDetailsWrapper.Resource resource 
    * @return Response 
    **/
    private static Response insertDEB(DEBStudentDetailsWrapper.Resource resource, Request objRequest, Response objResponse) {
        try {
            DEB_Detail__c objDEBDetails = new DEB_Detail__c(
                Student_ID__c = resource.StudentID,
                Program__c = resource.Program,
                Email__c = resource.email,
                Student_Name__c = resource.stdname,
                Father_Name__c = resource.fathername,
                Mobile__c = resource.mobile,
                DEB_Created_Date__c = resource.cdate,
                Institute_Name__c = resource.institutename,
                Institute_Id__c = resource.InstituteID,
                IpAddress__c = resource.ipaddress,
                Program_Code__c = resource.programcode,
                Mode__c = resource.mode,
                Admission_Date__c = DebVerificationHandler.parseDates(resource.AdmissionDate),
                Admission_Details__c = resource.AdmissionDetails,
                University_Name__c = resource.UniversityName,
                Course_Name__c = resource.CourseName,
                ABCID__c = resource.ABCID,
                DEB_Unique_ID__c = resource.DEBUniqueID,
                Gender__c = resource.Gender,
                Date_of_Birth__c = DebVerificationHandler.parseDates(resource.DOB),
                Is_Active__c = true
            );

            objResponse.dateOfBirthDEB = objDEBDetails.Date_of_Birth__c;
            objResponse.debUniqueId = objDEBDetails.DEB_Unique_ID__c;
            objResponse.abcUniqueId = objDEBDetails.ABCID__c;
            objResponse.isDOBMatched = objResponse.dateOfBirthDEB == objRequest.dob ? true : false;
            objResponse.isDebMatched = objResponse.debUniqueId ==  objRequest.debId ? true : false;
            objResponse.isSuccess = true;
            Lead objLead = new Lead();
            if(objResponse.isDOBMatched && objResponse.isDebMatched) {
                objResponse.isDEBActive = true;
                System.debug('objRequest.objType-->' + objRequest.objType);
                if(objRequest.objType == 'Lead' ) {
                    objDEBDetails.Lead__c = objRequest.recordId;
                    objDEBDetails.OwnerId = objRequest.ownerId;
                    System.debug('recordId--->' + objRequest.recordId);
                    objLead.Id = objRequest.recordId;
                    objLead.DEBID__c = objResponse.debUniqueId;
                    objLead.nm_DateOfBirth__c = objRequest.dob;
                    objLead.is_Deb_verified__c = true;
                } else if(objRequest.objType == 'Account') {
                    objDEBDetails.Account__c = objRequest.recordId;
                    objDEBDetails.OwnerId = objRequest.ownerId;
                }
                insert objDEBDetails;
                if (objLead != null && objRequest.objType == 'Lead') {
                    update objLead;
                }
            }
            else {
                if (objRequest.objType == 'Lead') {
                    System.debug('recordId--->' + objRequest.recordId);
                    objLead.Id = objRequest.recordId;
                    objLead.nm_DateOfBirth__c = objRequest.dob;
                    objLead.DEBID__c = '';
                    objLead.is_Deb_verified__c = false;
                    update objLead;
                } 
            }
        } catch (Exception error) {
            System.debug('Error on => insertDEB');
            System.debug('Error Messgae =>'+error.getMessage());
            System.debug('Error Line Number =>'+error.getLineNumber());
            objResponse.isSuccess = false;
        }
        //objResponse.isSuccess = true;
        return objResponse;
    }

    private static Date parseDates(String strDate) {
        try {
 
            if(String.isBlank(strDate)) {
                return null;
            }

            if (strDate.contains('T')) {
                List<String> lstStr = strDate.split('T');
                strDate = lstStr[0];
            }
 
            if(strDate.contains('-')) {
                String[] dateParts = strDate.split('-');
 
                // Check if the dateParts array has the expected number of elements
                if (dateParts.size() == 3) {
                    // Reformat to yyyy-MM-dd
                    String formattedDateString = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                   
                    // Output the parsed date
                    System.debug('Parsed Date: ' + Date.valueOf(formattedDateString));
 
                    // Parse the date
                    return Date.valueOf(formattedDateString);
                }
            } else {
                return Date.parse(strDate);
            }
        } catch (Exception error) {
            System.debug('Error ==>'+error.getMessage());
            System.debug('strDate ==>'+strDate) ;
        }
        return null;
    }


    /**
    * @description 
    * @author @BK | 10-09-2024 
    * @return Boolean 
    **/
    private static Boolean updateExistingDEB(Request objRequest) {
        try {
            Id recordID =  objRequest.recordId;
            String subQuery = objRequest.objType == 'Lead' ? 'Lead__c=:recordID' : 'Account__c=:recordID';
            String debQuery = DynamicQueryBuilder.getQueryAllFieldSql('DEB_Detail__c', 'Is_Active__c=true AND '+subQuery+' ORDER BY CreatedDate DESC', '');
            List<DEB_Detail__c> lstDebUpdate = DataBase.query(debQuery);
            if (!lstDebUpdate.isEmpty()) {
                for (DEB_Detail__c objDeb : lstDebUpdate) {
                    objDeb.Is_Active__c = false;
                }
                update lstDebUpdate;
            }
        } catch (Exception error) {
            System.debug('Error on => updateExistingDEB');
            System.debug('Error Messgae =>'+error.getMessage());
            System.debug('Error Line Number =>'+error.getLineNumber());
            return false;
        }
        return true;

    }

    /**
    * @description 
    * @author @BK | 09-16-2024 
    * @param strDate 
    * @return Date 
    **/
    // private static Date parseDate(String strDate) {
    //     try {
    //         return String.isNotBlank(strDate) ? Date.parse(strDate) : null;
    //     } catch (Exception error) {
    //         System.debug('Error ==>'+error.getMessage());
    //         System.debug('strDate ==>'+strDate) ;
    //     }
    //     return null;
    // }

    public class Request {
        public Request() {
            this.debId = '';
            this.objType = '';
            this.recordId = null;
            this.dob = null;
            this.ownerId = '';
        }
        public String objType {get;set;}
        public Id recordId {get;set;}
        public String debId {get;set;}
        public date dob {get;set;}
        public String ownerId {get;set;}
    }

    public class Response {
        public Response() {
            this.dateOfBirthDEB = null;
            this.debUniqueId = '';
            this.abcUniqueId = '';
            this.isDebMatched = false;
            this.isDOBMatched = false;
            this.isDEBActive = false;
            this.isSuccess = false;
            this.isDebInvalid = false;
        }
        public Date dateOfBirthDEB {get;set;}
        public String debUniqueId {get;set;}
        public String abcUniqueId {get;set;}
        public Boolean isDebMatched {get;set;}
        public Boolean isDOBMatched {get;set;}
        public Boolean isDEBActive {get;set;}
        public Boolean isSuccess {get;set;}
        public Boolean isDebInvalid {get;set;}
    }
}