/**
 * @File Name          : KnowlarityAPI.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-03-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    9/8/2019, 11:52:58 AM   @BK     Initial Version
**/
@RestResource(urlMapping='/Knowlarity/getSalesforceLeads')
global without sharing class KnowlarityAPI {
    
    public Map<String,User> mapOfUserIdVsUser;

    /**
    * @description
    * @author @BK | 27/8/2019
    * @return void
    */
    @HttpPost
    global static void show() {
        // Request Arguments.
        String jsonString = RestContext.request.requestbody.toString();

        // To set Header for response
        RestContext.response.addHeader('Content-Type', 'application/json');

        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());

        if(invalidRequest(mapOfRequestParameters,'callerph')) {
            mapOfResponseParameters.put('message','invalid request');
        } 
        else {
            if(Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.User.isAccessible()) {
                String mobileNumber = (String)mapOfRequestParameters.get('callerph');
                mobileNumber = mobileNumber.right(10);
                System.debug(mobileNumber);
                List<Lead> lstLead = [SELECT id,LeadSource,MobilePhone,OwnerId,Owner.Phone FROM Lead WHERE MobilePhone=:mobileNumber LIMIT 1];
                System.debug('lstLead -->'+lstLead);
                if(lstLead.size() > 0) {
                    String ownerId = lstLead[0].OwnerId;
                    List<User> lstUser = [SELECT id,MobilePhone,Phone,Profile.Name,Username,Name FROM User WHERE Id =:ownerId LIMIT 1];
                    System.debug(lstUser[0].MobilePhone);
                    String leadSource = lstLead[0].LeadSource;
                    String ownerMobileNumber = lstUser[0].MobilePhone;
                    if(String.isNotBlank(ownerMobileNumber)) {
                        ownerMobileNumber = ownerMobileNumber.replaceAll( '\\s+', '');
                    }
                    System.debug('OwnerMobileNumber -->'+ownerMobileNumber);
                    mapOfResponseParameters.put('Leadsource',leadSource);
                    mapOfResponseParameters.put('ownerMobileNumber', OwnerMobileNumber);
                } 
                else {
                    mapOfResponseParameters.put('message','default lead source');
                }
            }
            else{
                mapOfResponseParameters.put('message','invalid access');
            }
        }
        List<Object> lstResponseParam = new List<Object>{mapOfResponseParameters};
		Blob result = Blob.valueOf(JSON.serialize(lstResponseParam));
        RestContext.response.responseBody = result;
    }

    /**
    * @description
    * @author @BK | 27/8/2019
    * @param Map<String, Object> mapOfRequestParameters
    * @param String requiredParams
    * @return Boolean
    */
    public static Boolean invalidRequest(Map<String,Object> mapOfRequestParameters, String requiredParams) {
        Boolean invalidRequest = false;
        Map<String,String> mapOfRequiredValue = new Map<String,String>();
        List<String> setRequiredParam = requiredParams.split(',');
        Set<String> setPresentParam = mapOfRequestParameters.keySet();
        
        if(setPresentParam.containsAll(setRequiredParam)) {
            for (String fieldName : setRequiredParam) {
                if(mapOfRequestParameters.get(fieldName) == null || mapOfRequestParameters.get(fieldName) == '') {
                    invalidRequest = true;
                }
                else if(mapOfRequiredValue.containsKey(fieldName)) {
                    if(mapOfRequiredValue.get(fieldName) != String.valueOf(mapOfRequestParameters.get(fieldName)) ) {
                        invalidRequest = true;
                    }
                }
            }
        }
        else{
            invalidRequest = true;
        }
        return invalidRequest;
    }
    
}