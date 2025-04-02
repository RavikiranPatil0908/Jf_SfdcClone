/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-02-2023
 * @last modified by  : @BK
**/
@RestResource(urlMapping='/Ozontel/getLCName')
global class OzontelAPI {
    @HttpPost
    global static void show() { 
        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        try {
            // Request Arguments.
            String jsonString = RestContext.request.requestbody.toString();
            // To set Header for response
            RestContext.response.addHeader('Content-Type', 'application/json');
            Map<String,Object> mapOfRequestParameters = (Map<String,Object>)Json.deserializeUntyped(jsonString.trim());

            if(!mapOfRequestParameters.containsKey('callerph') || (mapOfRequestParameters.get('callerph')==null || mapOfRequestParameters.get('callerph')=='')) {
                mapOfResponseParameters.put('errorCode','ERROR');
                mapOfResponseParameters.put('message','invalid request');
            } else { 
                String mobileNumber = (String)mapOfRequestParameters.get('callerph');
                mobileNumber = mobileNumber.right(10);
                System.debug(mobileNumber);
                List<Account> lstAccount = [SELECT id,LC_Name__c FROM Account WHERE RecordType.Name='Person Account' AND PersonMobilePhone=:mobileNumber LIMIT 1];
                System.debug('lstAccount -->'+lstAccount);
                if(lstAccount.size() > 0) {
                    String LCName = lstAccount[0].LC_Name__c;
                    System.debug('LC Name -->'+LCName);
                    mapOfResponseParameters = checkValue(LCName);
                } else {
                    List<Lead> lstLead = [SELECT id,LC_Name__c FROM Lead WHERE MobilePhone=:mobileNumber LIMIT 1];
                    System.debug('lstLead -->'+lstLead);
                    if(lstLead.size() > 0) { 
                        String LCName = lstLead[0].LC_Name__c;
                        System.debug('LC Name -->'+LCName);
                        mapOfResponseParameters = checkValue(LCName);
                    } else {
                        mapOfResponseParameters = checkValue(null);
                    }
                }
            }
        } catch (Exception error) {
            System.debug('Error ==>'+error.getMessage());
            mapOfResponseParameters.put('errorCode','ERROR');
            mapOfResponseParameters.put('message','Internal error occured.');
        }
        // List<Object> lstResponseParam = new List<Object>{mapOfResponseParameters};
        Blob result = Blob.valueOf(JSON.serialize(mapOfResponseParameters));
        RestContext.response.responseBody = result;
    }

    public static Map<String,Object> checkValue(String LCName) {
        Map<String,Object> mapOfResponseParameters = new Map<String,Object>();
        if(String.isNotBlank(LCName)) {
            mapOfResponseParameters.put('LCName',LCName);
            mapOfResponseParameters.put('errorCode','SUCCESS');
            mapOfResponseParameters.put('message','Record found.');
        } else {
            mapOfResponseParameters.put('errorCode','ERROR');
            mapOfResponseParameters.put('message','No record found.');
        }
        return mapOfResponseParameters;
    }
}