/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : @BK
**/
public class MassBankVerificationBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Map<String,nmRefund_Payment__c> mapOfRefundToUpdate = new Map<String,nmRefund_Payment__c>();
    public Map<String,nmRefund_Payment__c> mapOfRefundToPush = new Map<String,nmRefund_Payment__c>();
    public String bulkValidationId = 'NM_' + String.valueOf(DateTime.now().getTime());
    public List<Map<String,String>> lstOfEntries = new List<Map<String,String>>();
    public Boolean callStatusAPI = System.now().minute() >= 30 ? true : false;
    public Map<String,Map<String,nmRefund_Payment__c>> mapOfValidationIdVsRefund = new Map<String,Map<String,nmRefund_Payment__c>>();
    public String bearerAuthToken = null;
    public DateTime tokenExpiryTime = null;

    public void execute(SchedulableContext sc) {
        MassBankVerificationBatchClass b = new MassBankVerificationBatchClass();
        Database.executebatch(b, 200);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('MassBankVerificationBatchClass Batch Class Started');
        
        String filterQuery = 'Status__c=\'Refund Submitted to Finance\' AND Refund_transfer_Mode__c=\'NEFT\' AND Bank_Verification_API_Called__c=FALSE AND Avoid_Batch__c=FALSE AND Bank_Validation_Id__c=null AND Account_Number__c!=null LIMIT 200';
        if(callStatusAPI) {
            filterQuery = 'Bank_Verification_API_Called__c=TRUE AND Bank_Validation_Id__c!=null AND Bank_Validation_Id__c!=\'\' AND (Bank_Verified__c=null OR Bank_Verified__c=\'\') ORDER BY Bank_Validation_Id__c ASC LIMIT 200';
        }
        String query = getQueryAllFieldSql('nmRefund_Payment__c', filterQuery, 'Account__r.PersonMobilePhone,Account__r.Name,Account__r.Father_Name__c,Account__r.Mother_Name__c,Account__r.nm_SpouseName__c');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<nmRefund_Payment__c> lstRP) { 
        if(callStatusAPI) {
            for (nmRefund_Payment__c objRP : lstRP) {
                Map<String,nmRefund_Payment__c> mapOfKeyVsRP = mapOfValidationIdVsRefund.containsKey(objRP.Bank_Validation_Id__c) ? mapOfValidationIdVsRefund.get(objRP.Bank_Validation_Id__c) : new Map<String,nmRefund_Payment__c>();
                String mapKey = objRP.Account_Number__c + '_' + objRP.IFSC_Code__c;
                mapOfKeyVsRP.put(mapKey,objRP);
                mapOfValidationIdVsRefund.put(objRP.Bank_Validation_Id__c,mapOfKeyVsRP);
            }
        } else {
            for (nmRefund_Payment__c objRP : lstRP) {
                if(validateRefundRecord(objRP)) {
                    lstOfEntries.add(setBankData(objRP));
                    mapOfRefundToPush.put(objRP.id,objRP);
                } else {
                    objRP.Avoid_Batch__c = true;
                    mapOfRefundToUpdate.put(objRP.id,objRP);
                }
            }
        }

        if(mapOfValidationIdVsRefund.size() > 0) {
            for (String mapKey : mapOfValidationIdVsRefund.keySet()) {
                checkBankStatus(mapKey,mapOfValidationIdVsRefund.get(mapKey));
            }    
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('MassBankVerificationBatchClass Finished ---> ');

        if(!callStatusAPI) {
            // To set and call bank verification API
            getBankVerificationDetails();
        }

        if(mapOfRefundToUpdate.size() > 0) {
            updateRP(mapOfRefundToUpdate.values());
        }
    }

    /*  ---------------------------------------- Verification status check API Details Begins -------------------------------------------- */

    /**
    * @description 
    * @author @BK | 07-11-2023 
    * @param bankValidationId 
    * @param mapOfKeyVsRP 
    **/
    public void checkBankStatus(String bankValidationId, Map<String,nmRefund_Payment__c> mapOfKeyVsRP) {
        try {
            String authToken = getToken();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            req.setEndpoint('https://payout-api.cashfree.com/payout/v1/getBulkValidationStatus?bulkValidationId='+bankValidationId);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer '+ authToken);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('accept', 'application/json');
            resp = http.send(req);
            Integer statusCode = resp.getStatusCode();
            String resBody = resp.getBody();
            System.debug('statusCode = '+statusCode);
            if(statusCode == 200) {
                handleResponse(resBody,mapOfKeyVsRP,bankValidationId);
            }
        } catch (Exception e) {
            System.debug(e.getLineNumber() + ' --- '+e.getMessage());
        }
    }

    /**
    * @description 
    * @author @BK | 07-11-2023 
    * @param resBody 
    * @param mapOfKeyVsRP 
    **/
    public void handleResponse(String resBody, Map<String,nmRefund_Payment__c> mapOfKeyVsRP, String bankValidationId) {
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
        String status = (String)responseBody.get('status');
        if(status == 'SUCCESS') {
            Map<String,Object> mapOfData = (Map<String,Object>)responseBody.get('data');
            System.debug(resBody);
            System.debug('Transaction Id ==>'+mapOfData.get('bulkValidationId'));
            String validationId = (String) mapOfData.get('bulkValidationId');
            if(validationId == bankValidationId) {
                Map<String,Object> mapOfEntries = (Map<String,Object>)mapOfData.get('entries');
                for(String mapKey : mapOfKeyVsRP.keySet()) {
                    nmRefund_Payment__c objRP = mapOfKeyVsRP.get(mapKey);
                    if(mapOfEntries.containsKey(mapKey)) {
                        Map<String,Object> mapOfResponse = (Map<String,Object>)mapOfEntries.get(mapKey);
                        setBankResponse(mapOfResponse,objRP);
                    }
                }
            }
        }
    }

    /**
    * @description 
    * @author @BK | 07-11-2023 
    * @param mapOfEntries 
    * @param objRP 
    **/
    public void setBankResponse(Map<String,Object> mapOfResponse, nmRefund_Payment__c objRP) {
        String status = (String)mapOfResponse.get('accountExists');
        if(String.isNotBlank(status)) {
            if((String)mapOfResponse.get('accountExists') == 'YES') {
                objRP.Bank_Verified__c = 'Yes';
                objRP.Bank_Checked_Account_Holder_Name__c = (String)mapOfResponse.get('nameAtBank');
                objRP.Bank_Checked_Account_Number__c = (String)mapOfResponse.get('bankAccount');
                objRP.Bank_Checked_IFSC__c = (String)mapOfResponse.get('ifsc');
                objRP.Bank_Checked_refId__c = (String)mapOfResponse.get('refId');
                objRP.Bank_Checked_UTR__c = (String)mapOfResponse.get('utr');
            } else {
                objRP.Bank_Verified__c = 'No';
            }
            mapOfRefundToUpdate.put(objRP.id,objRP);
        }
    }

    /*  ---------------------------------------- Verification status check API Details Ends ------------------------------------------------- */

    /*  ---------------------------------------- Verification API Details Begins ------------------------------------------------------------ */

    /**
    * @description 
    * @author @BK | 07-11-2023 
    **/
    public void getBankVerificationDetails() {
        if(lstOfEntries.size() > 0) {
            Map<String,Object> mapOfRequestParam = new Map<String,Object>();
            mapOfRequestParam.put('entries',lstOfEntries);
            mapOfRequestParam.put('bulkValidationId',bulkValidationId);
            String jsonRequest = JSON.serialize(mapOfRequestParam);
            String validationId = getBankDetails(jsonRequest);
            if(String.isNotBlank(validationId)) {
                for (String mapKey : mapOfRefundToPush.keySet()) {
                    nmRefund_Payment__c objRP = mapOfRefundToPush.get(mapKey);
                    objRP.Bank_Verification_API_Called__c = true;
                    objRP.Bank_Validation_Id__c = validationId;
                    mapOfRefundToUpdate.put(mapKey,objRP);
                }
            }
        }
    }

    /**
    * @description 
    * @author @BK | 06-22-2023 
    * @param lstOfRP 
    **/
    public static void updateRP(List<nmRefund_Payment__c> lstOfRP) {
        Database.SaveResult[] srList = Database.update(lstOfRP, false);
        for (Integer i = 0; i < lstOfRP.size(); i++) {
            Database.SaveResult sr = srList[i];
            nmRefund_Payment__c origRecord = lstOfRP[i];
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated RP Owner ID: ' + sr.getId());
            } else {
                System.debug('sr.getId() -->'+origRecord.id);
                // Operation failed, so get all errors.                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('RP fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    /**
    * @description 
    * @author @BK | 06-22-2023 
    * @param objRP 
    * @return Map<String, String> 
    **/
    public Map<String,String> setBankData(nmRefund_Payment__c objRP) {
        Map<String,String> mapOfBankDetails = new Map<String,String>();
        mapOfBankDetails.put('name',objRP.Account_Holder_name__c);
        mapOfBankDetails.put('bankAccount',objRP.Account_Number__c);
        mapOfBankDetails.put('ifsc',objRP.IFSC_Code__c);
        mapOfBankDetails.put('phone',objRP.Account__r.PersonMobilePhone);

        if(String.isNotBlank(mapOfBankDetails.get('phone'))) {
            String mapValue = mapOfBankDetails.get('phone').right(10);
            mapOfBankDetails.put('phone',mapValue);
        } else {
            mapOfBankDetails.remove('phone');
        }
        return mapOfBankDetails;
    }

    /**
    * @description 
    * @author @BK | 06-21-2023 
    * @param objRP 
    * @return Boolean 
    **/
    public Boolean validateRefundRecord(nmRefund_Payment__c objRP) {
        System.debug('NameOfAccountHolder --> ' + objRP.Account_Holder_name__c);
        System.debug('TypeOfRelationship --> ' + objRP.Relationship__c);
        System.debug('CancelChequeDocument --> ' + objRP.Cancel_Cheque_Document_Upload__c);
        System.debug('TypeOfAccount --> ' + objRP.Type_Of_Account__c);
        System.debug('IFSCCode --> ' + objRP.IFSC_Code__c);
        System.debug('AccountNumber --> ' + objRP.Account_Number__c);
        System.debug('NameOfTheBank --> ' + objRP.nm_Name_of_the_Bank__c);

        String studentName = String.isNotBlank(objRP.Account__r.Name) ? objRP.Account__r.Name : '';
        String fatherName = String.isNotBlank(objRP.Account__r.Father_Name__c) ? objRP.Account__r.Father_Name__c : '';
        String motherName = String.isNotBlank(objRP.Account__r.Mother_Name__c) ? objRP.Account__r.Mother_Name__c : '';
        String spouseName = String.isNotBlank(objRP.Account__r.nm_SpouseName__c) ? objRP.Account__r.nm_SpouseName__c : '';

        if(String.isBlank(objRP.Relationship__c) || String.isBlank(objRP.Account_Holder_name__c)) {
            return false;
        }

        if(objRP.Relationship__c == 'Self' && (studentName.containsIgnoreCase(objRP.Account_Holder_name__c) || objRP.Account_Holder_name__c.containsIgnoreCase(studentName))) {
            return true;
        }
        
        if(objRP.Relationship__c == 'Parent (Father/Mother)' && (fatherName.containsIgnoreCase(objRP.Account_Holder_name__c) || objRP.Account_Holder_name__c.containsIgnoreCase(fatherName) || motherName.containsIgnoreCase(objRP.Account_Holder_name__c) || objRP.Account_Holder_name__c.containsIgnoreCase(motherName))) {
            return true;
        }

        if(objRP.Relationship__c == 'Spouse' && (spouseName.containsIgnoreCase(objRP.Account_Holder_name__c) || objRP.Account_Holder_name__c.containsIgnoreCase(spouseName))) {
            return true;
        }
        return false;
    }

    /**
    * @description 
    * @author @BK | 06-22-2023 
    * @param reqBoby 
    * @return String 
    **/
    public String getBankDetails(String reqBoby) {
        String resBody = '';
        String bulkValidationId = '';
        Boolean isSuccess = false;
        try {
            String authToken = getToken();
            HttpRequest req = new HttpRequest();
            HttpResponse resp = new HttpResponse();
            Http http = new Http();
            req.setEndpoint('https://payout-api.cashfree.com/payout/v1/bulkValidation/bankDetails');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer '+ authToken);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('accept', 'application/json');
            req.setBody(reqBoby);
            resp = http.send(req);
            // Integer statusCode = 200;
            Integer statusCode = resp.getStatusCode();
            resBody = resp.getBody();
            System.debug('statusCode = '+statusCode);
            if(statusCode == 200) {
                // resBody = '{"status":"SUCCESSS","subCode":200,"message":"Bulk Validation requested successfully.","data":{"bulkValidationId":"testid1"}}';
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(resBody);
                String status = (String)responseBody.get('status');
                if(status == 'SUCCESS') {
                    Map<String,Object> mapOfData = (Map<String,Object>)responseBody.get('data');
                    System.debug(resBody);
                    System.debug('Transaction Id ==>'+mapOfData.get('bulkValidationId'));
                    bulkValidationId = (String) mapOfData.get('bulkValidationId');
                    isSuccess = true;
                }
            }
            insertAPIRequest(reqBoby, resBody, isSuccess);
        }catch (Exception e) {
            System.debug(e.getLineNumber() + ' --- '+e.getMessage());
            insertAPIRequest(reqBoby, resBody + ' -- ' + e.getLineNumber() + ' --- '+e.getMessage(),false);
        }
        return bulkValidationId;
    }

    /**
    * @description 
    * @author @BK | 06-22-2023 
    * @param req 
    * @param res 
    * @param isSuccess 
    **/
    public void insertAPIRequest(String req, String res, Boolean isSuccess) {
        API_Request__c apiReq = new API_Request__c();
        apiReq.API_Name__c = 'BulkBankVerification';
        apiReq.Request__c = req.left(131072);
        apiReq.Type_of_Request__c = 'CashFree';
        apiReq.Response__c = res;
        apiReq.Success__c = isSuccess;
        insert apiReq;
    }

    /*  ---------------------------------------- Verification API Details Ends ------------------------------------------------------------ */

    public String getQueryAllFieldSql(String sObjectAPIName, String conditionString, String relatedFields) {
        Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
        Map<String, schema.SObjectField> fieldMap = scemapMap.get(sObjectAPIName).getDescribe().fields.getMap();
        List<String> fieldNames = new  List<String>(fieldMap.keySet());
        if(String.isNotBlank(relatedFields)) {
            fieldNames.add(relatedFields);
        }
        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + sObjectAPIName + ' WHERE ' + conditionString;
        return query;
    }

    /**
    * @description 
    * @author @BK | 07-11-2023 
    * @return String 
    **/
    public String getToken() {
        if(String.isBlank(bearerAuthToken) || tokenExpiryTime==null || tokenExpiryTime<=System.now()) {
            Map<String, Object> mapOfResponse = AuthorizationToken.getCashFreeAuthorizationToken('Bank');
            if(mapOfResponse.size() > 0 && mapOfResponse.containsKey('token')) {
                tokenExpiryTime = System.now().addMinutes(9);
                bearerAuthToken = (String)mapOfResponse.get('token');
            }
        }
        return bearerAuthToken;
    }

}