/**
 * @description       : DEB Verification API for Mobile App
 * @author            : @Ravi
 * @last modified on  : 12--09--2025
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   26-08-2025   @Ravi    Initial Version
**/
@RestResource(urlMapping='/api/DEBVerification/*')
global without sharing class MobileAppDEBVerificationAPI {
   
    @HttpPost
    global static DEBResponseWrapper handleDEBVerification() {
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        DEBResponseWrapper response = new DEBResponseWrapper();

        try {
            String body = req.requestBody.toString();
            DEBRequestWrapper input =(DEBRequestWrapper) JSON.deserialize(body, DEBRequestWrapper.class);

            if (String.isBlank(input.recordId)) {
                response.status  = 'Error';
                response.message = 'Record ID is required';
                return response;
            }
            String objectType = input.recordId.startsWith('00Q') ? 'Lead' : 'Account';
            Date dob;
            String ownerId;

            if (objectType == 'Account') {
                Account acc = [SELECT Id, DEBID__c, OwnerId, nm_DateOfBirth__c FROM Account WHERE Id = :input.recordId LIMIT 1];
                dob     = acc.nm_DateOfBirth__c;
                ownerId = acc.OwnerId;
            } else {
                Lead leadRec = [SELECT Id, DEBID__c, OwnerId, nm_DateOfBirth__c  FROM Lead  WHERE Id = :input.recordId  LIMIT 1];
                dob     = leadRec.nm_DateOfBirth__c;
                ownerId = leadRec.OwnerId;
            }
            // Prepare handler request
            DEBVerificationHandler.Request objRequest = new DEBVerificationHandler.Request();
            objRequest.recordId = input.recordId;
            objRequest.objType  = objectType;
            objRequest.debId    = input.debId;
            objRequest.dob      = dob;
            objRequest.ownerId  = ownerId;

            // Call handler
            DEBVerificationHandler.Response objResponse = DEBVerificationHandler.verifyDEBID(objRequest);
            System.debug('isSuccess => ' + objResponse.isSuccess);
            DEBDetails details =  (DEBDetails)JSON.deserialize(JSON.serialize(objResponse), DEBDetails.class);
            response.debDetails = details;
            if (!objResponse.isSuccess) {
                response.status  = 'Error';
                response.message = 'Verification failed';
                return response;
            }
            // Validate matches
            if (!objResponse.isDebMatched) {
                response.status  = 'Error';
                response.message = 'Mismatch-DEB';
                return response;
            }
            if (!objResponse.isDOBMatched) {
                response.status  = 'Error';
                response.message = 'Mismatch-DOB';
                return response;
            }

            if (objectType == 'Account') {
                update new Account(Id = objRequest.recordId, DEBID__c = input.debId,is_Deb_verified__c = true );
            } else {
                update new Lead( Id = objRequest.recordId, DEBID__c = input.debId );
            }
            response.status  = 'Success';
            response.message = 'DEB Verified';
            return response;
        } catch (Exception e) {
            response.status  = 'Error';
            response.message = 'Exception: ' + e.getMessage() + ' (Line ' + e.getLineNumber() + ')';
            return response;
        }
    }

    // Response Wrapper
    global class DEBResponseWrapper {
        public String status;   // Success / Error
        public String message;
        public DEBDetails debDetails;
    }

    // Request Wrapper
    global class DEBRequestWrapper {
        public String recordId; // Account or Lead Id
        public String debId;  
    } 

    global class DEBDetails {
        public Boolean isDEBActive;
        public Boolean isDOBMatched;
        public Boolean isDebMatched;
        public Boolean isABCMatched;
        public Date dateOfBirthDEB;
        public String debUniqueId;
        public String abcUniqueId;
        public Boolean isDebInvalid;
    }
}
