/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-23-2020
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   09-30-2020   @BK   Initial Version
**/
@RestResource(urlMapping='/Knowlarity/getRegionalNo')
global without sharing class KnowlarityRoutingAPI {

    /**
    * @description 
    * @author @BK | 09-30-2020 
    **/
    @HttpPost
    global static void show() {
        Map<String,String> mapOfRegionVsRegionalNumber = new Map<String,String>{
            'Mumbai' => '7400288823,7045488107',
            'Chandigarh' => '7017363461',
            'Delhi' => '9810017499,8587092391',
            'Kolkata' => '9875346031',
            'Hyderabad' => '9247023503',
            'Pune' => '9922022300',
            'Bangalore' => '9686663032',
            'Indore' => '7974090118',
            'Ahmedabad' => '9558551828'
        };
        // Request Arguments.
        String jsonString = RestContext.request.requestbody.toString();

        // To set Header for response
        RestContext.response.addHeader('Content-Type', 'application/json');

        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());

        if(invalidRequest(mapOfRequestParameters,'customerph')) {
            mapOfResponseParameters.put('message','invalid request');
        } 
        else {
            if(Schema.sObjectType.Lead.isAccessible()) {
                String mobileNumber = (String)mapOfRequestParameters.get('customerph');
                mobileNumber = mobileNumber.right(10);
                System.debug(mobileNumber);

                List<Lead> lstLead = [SELECT id,MobilePhone,nm_InformationCenter__r.CenterName__c FROM Lead WHERE MobilePhone=:mobileNumber LIMIT 1];
                System.debug('lstLead -->'+lstLead);
                if(lstLead.size() > 0) {
                    System.debug(lstLead[0].nm_InformationCenter__r.CenterName__c);
                    String region = lstLead[0].nm_InformationCenter__r.CenterName__c;
                    String regionalNumbers = String.isNotBlank(region) && mapOfRegionVsRegionalNumber.containsKey(region) 
                        ? mapOfRegionVsRegionalNumber.get(region) : null;
                    if(String.isNotBlank(regionalNumbers)) {
                        // List<String> lstRegionalNo = regionalNumbers.split(',');
                        mapOfResponseParameters.put('regionalph',regionalNumbers);
                    } else {
                        mapOfResponseParameters.put('message', 'regional number does not exists');
                    }
                } 
                else {
                    mapOfResponseParameters.put('message', 'record does not exists');
                }
            }
            else{
                mapOfResponseParameters.put('message','invalid access');
            }
        }
		Blob result = Blob.valueOf(JSON.serialize(mapOfResponseParameters));
        RestContext.response.responseBody = result;
    }

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