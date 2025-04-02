/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-06-2025
 * @last modified by  : @vickysahu
**/
public without sharing class AvanseWebService {
    public static final String APIKEY = System.Label.AvanseAPIKey;
    public static final String partnerCode = System.Label.AvansePartnerCode;

    //Create Lead for Avanse Loan
    public AvanseResponseWrapper createNewLead(String orderId,String emailAddress,String firstName,String mobileNumber,Decimal totalPrice ,String tenure,String recordId,String objType,String loanPlanCode,String ic_Name,String programCode) {
        Map<String,Object> mapOfRequestParms = new Map<String,Object>();
        Map<String,Object> mapOfRequestParms2 = new Map<String,Object>();
        // mapOfRequestParms2.put('partner_application_number', 'getPartnercode');
        mapOfRequestParms2.put('admission_number', orderId);
        mapOfRequestParms.put('other_fields', mapOfRequestParms2);
        
        mapOfRequestParms.put('email', emailAddress);
        mapOfRequestParms.put('mobile_number',Long.valueOf(mobileNumber));
        mapOfRequestParms.put('first_name', firstName);
        //mapOfRequestParms.put('last_name', lastName);
        mapOfRequestParms.put('course_code', programCode);
        mapOfRequestParms.put('expected_loan_amount', Integer.valueOf(totalPrice));
        mapOfRequestParms.put('loan_plan_code', loanPlanCode);
        mapOfRequestParms.put('partner_code', partnerCode);
        mapOfRequestParms.put('dsa_code', ic_Name);
        
        // mapOfRequestParms.put('discount', Decimal type);
        String jsonString = JSON.serialize(mapOfRequestParms);
        System.debug('jsonString---> ' + jsonString);

        Http http = new Http();
        HttpRequest objRequest = new HttpRequest();
        HttpResponse objResponse = new HttpResponse();
        objRequest.setMethod('POST');
        objRequest.setEndpoint(System.Label.Avanse_Url + 'api/v1/lead');
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('apikey',APIKEY);
        objRequest.setHeader('Accept', 'application/json');
        objRequest.setBody(jsonString);
        System.debug('Request--->' + objRequest);
        try {
            objResponse = http.send(objRequest);
            if (objResponse.getStatusCode() == 201) {
                String result = objResponse.getBody();
                AvanseResponseWrapper objWrapper = AvanseResponseWrapper.parse(result);
                APIRequestHandler.insertAPIRequest(jsonString,objResponse.getBody(),'AvanseLeadCreateAPI',true,recordId,objType,'AvanseLoan');
                return objWrapper;
            }
            else {
                APIRequestHandler.insertAPIRequest(jsonString,objResponse.getBody(),'AvanseLeadCreateAPI',false,recordId,objType,'AvanseLoan');            
            }
        } catch (Exception e) {
            System.debug('Error ---> ' + e);
            System.debug('Error msg ---> ' + e.getMessage());
            System.debug('Line No ---> ' + e.getLineNumber());
        }
        return null;
    }

    //Avanse to Inactive Lead or cancel loan
    public Boolean cancelAvanseLoan(String quoteId,String recordType,String recordId) {
        Boolean result = false;
        Http http = new Http();
        HttpRequest objRequest = new HttpRequest();
        HttpResponse objResponse = new HttpResponse();
        objRequest.setMethod('POST');
        objRequest.setEndpoint(System.Label.Avanse_Url + 'api/v1/status/' + quoteId);
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('apikey',APIKEY);
        objRequest.setHeader('Accept', 'application/json');
        String jsonString  = '{"status" : "INACTIVE"}';
        objRequest.setBody(jsonString);
        try {
            objResponse = http.send(objRequest);
            System.debug('objRequest---->' + objRequest);
            System.debug('objResponse---->' + objResponse);
            System.debug('objRequest.setBody---->' + objRequest.getBody());
            if (objResponse.getStatusCode() == 200) {
                String response = objResponse.getBody();
                Map<String,Object> mapOfResponseParameter = (Map<String,Object>) json.deserializeUntyped(response);
                result =  Boolean.valueOf(mapOfResponseParameter.get('status'));
                System.debug('result---->' + result);
                APIRequestHandler.insertAPIRequest(jsonString, objResponse.getBody(), 'AvanceLoanCancelAPI', result, recordId, recordType, 'AvanseLoan');
            }
            else {
                APIRequestHandler.insertAPIRequest(jsonString, objResponse.getBody(), 'AvanceLoanCancelAPI', result, recordId, recordType, 'AvanseLoan');
            }
        } catch (Exception e) {
            System.debug('Exception error---> ' + e);
            System.debug('Error Msg---> ' + e.getMessage());
            System.debug('Line Number ---> ' + e.getLineNumber());
        }
        return result;
    }

    //Avanse Loan API for Approval and waiting in Ready to Disbursment status
    public Boolean updateAvanseLoanStatus(String quoteId,String recordType,String recordId) {
        Boolean result = false;
        Http http = new Http();
        HttpRequest objRequest = new HttpRequest();
        HttpResponse objResponse = new HttpResponse();
        objRequest.setMethod('POST');
        objRequest.setEndpoint(System.Label.Avanse_Url + 'api/v1/disbursement/' + quoteId);
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('Accept', 'application/json');
        objRequest.setHeader('apikey',APIKEY);
        try {
            objResponse = http.send(objRequest);
            if (objResponse.getStatusCode() == 200) {
                String response = objResponse.getBody();
                Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(response);
                System.debug('mapOfResponseParameters -->'+mapOfResponseParameters);
                result = Boolean.valueOf(mapOfResponseParameters.get('status'));
                APIRequestHandler.insertAPIRequest('', objResponse.getBody(), 'AvanseLoanApprovalAPI', result, recordId, recordType, 'AvanseLoan');
            } else {
                APIRequestHandler.insertAPIRequest('', objResponse.getBody(), 'AvanseLoanApprovalAPI', false, recordId, recordType, 'AvanseLoan');
            }
        } catch (Exception e) {
            System.debug('Exception ---> ' + e);
            System.debug('Error Msg ---> ' + e.getMessage());
            System.debug('Line Number ---> ' + e.getLineNumber());
        }
        return result;
    }

    /*public Map<String,Object> getListOfProgramCode (String ic_Name,String recordType,String recordId) {
        Http http = new Http();
        HttpRequest objRequest = new HttpRequest();
        HttpResponse objResponse = new HttpResponse();
        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        Boolean result = false;
        objRequest.setMethod('GET');
        objRequest.setEndpoint('https://avanseuatpartnerapi.kelltontech.net/api/v1/courses');
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('Accept', 'application/json');
        objRequest.setHeader('apikey',APIKEY);
        String jsonBody = '{"partnerCode" : "' + ic_Name + '"}';
        objRequest.setBody(jsonBody);
        try {
            objResponse = http.send(objRequest);
            if (objResponse.getStatusCode() == 200) {
                String response = objResponse.getBody();
                mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(response);
                System.debug('mapOfResponseParameters -->'+mapOfResponseParameters);
                result = Boolean.valueOf(mapOfResponseParameters.get('status'));
                //APIRequestHandler.insertAPIRequest('', objResponse.getBody(), 'AvanseLoanApprovalAPI', result, recordId, recordType, 'AvanseLoan');
            } else {
                //APIRequestHandler.insertAPIRequest('', objResponse.getBody(), 'AvanseLoanApprovalAPI', false, recordId, recordType, 'AvanseLoan');
                System.debug('Failed to get Program Code');
            }
        } catch (Exception e) {
            System.debug('Exception ---> ' + e);
            System.debug('Error Msg ---> ' + e.getMessage());
            System.debug('Line Number ---> ' + e.getLineNumber());
        }
        return mapOfResponseParameters;
    }*/

    //Create dsa means Center code using partner code 
    public Map<String,Object> createAEPCode(String email, String mobile, String name) {
        Http http = new Http();
        HttpRequest objRequest = new HttpRequest();
        HttpResponse objResponse = new HttpResponse();
        objRequest.setEndpoint(System.Label.Avanse_Url + 'api/v1/dsa');
        objRequest.setHeader('Accept', 'application/json');
        objRequest.setHeader('Content-Type', 'application/json');
        objRequest.setHeader('apikey', APIKEY);
        Boolean result = false;
        Map<String,Object> mapOfResponseParameter = new Map<String,Object>();
        Map<String,Object> mapOfRequestParm = new Map<String,Object>{
            'name' => name,
            'email' => email,
            'mobile' => Long.valueOf(mobile),
            'partner_codes' => partnerCode
        };
        String jsonString = JSON.serialize(mapOfRequestParm);
        objRequest.setMethod('POST');
        objRequest.setBody(jsonString);
        try {
            objResponse = http.send(objRequest);
            if (objResponse.getStatusCode() == 201) {
                String response = objResponse.getBody();
                mapOfResponseParameter = (Map<String,Object>) json.deserializeUntyped(response);                
                System.debug('mapOfResponseParameters -->'+mapOfResponseParameter);
            }
            else {
                System.debug('Something went wrong during api call' + objResponse.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Exception ---> ' + e);
            System.debug('Error Msg ---> ' + e.getMessage());
            System.debug('Line Number ---> ' + e.getLineNumber());
        }
        return mapOfResponseParameter;
    }



    // public static void apiRequestsInsertion(HttpRequest objRequest,HttpResponse objResponse,String objType,String recordId){
    //     API_Request__c apiRequest = new API_Request__c();
    //     apiRequest.API_Name__c = 'AvanseLeadCreateAPI';
    //     apiRequest.Type_of_Request__c = 'Avanse';
    //     apiRequest.Request__c = objRequest.getBody();
    //     apiRequest.Response__c = objResponse.getBody();
    //     apiRequest.Lead__c = objType == 'Lead' ? recordId : null;
    //     apiRequest.Opportunity__c = objType != 'Lead' ? recordId : null; 
    //     insert apiRequest;
    // }
}