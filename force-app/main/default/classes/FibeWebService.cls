/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 27--02--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   27--02--2026   @Ravi   Initial Version
**/
public without sharing class FibeWebService {

    public FibeResponseWrapper profileIngestion(){
        try {
             // Get fibeLaon from Custom Metadata
              API_Key__mdt fibeLaon = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c,Password__c,Username__c FROM API_Key__mdt WHERE MasterLabel = 'Fibe Loan' LIMIT 1];
             System.debug('fibeLaon=='+fibeLaon);

            // Generate Token
            String token = generateToken(fibeLaon);
              System.debug('token=='+token);
            Map<String, Object> payloadMap = new Map<String, Object>{
                'personalInfo' => new Map<String, Object>{
                    'mobileNumber' => '9892433636',
                    'firstName' => 'shailesh',
                    'lastName' => 'test',
                    'dob' => '1958-08-15',
                    'email' => 'shaileshpandt80@gmail.com'
                },

                'orderInfo' => new Map<String, Object>{
                    'channelName' => 11176,
                    'orderId' => '69537b48a832c239c98c4a12',
                    'orderAmount' => '210000',
                    'selectedEmiTenure' => '12'
                },

                'redirectionInfo' => new Map<String, Object>{
                    'redirectionUrl' => 'https://transaction.xyz.com/Pages/thankyouES.aspx',
                    'redirectionParam' => new Map<String, Object>{
                        'key1' => 'sdsds',
                        'key2' => 'ddfd'
                    }
                },

                'universityDetails' => new Map<String, Object>{
                    'universityFeePaymentType' => 'FullFeeLaon',
                    'universityCourseId' => '1234_01'
                }
            };

            String JsonBody = JSON.serialize(payloadMap);
            System.debug('JsonBody==>'+JsonBody);
            Long randomLong = Long.valueOf(fibeLaon.Secret_Key__c);
            String encryptedPayload =AESUtil.encryptAES(JsonBody, randomLong) ;

            Map<String, Object> finalBody = new Map<String, Object>{ 'data' => encryptedPayload };

            HttpRequest req = new HttpRequest();
            req.setEndpoint(fibeLaon.Base_Url__c+'/profileIngestion');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization',token);
            req.setBody(JSON.serialize(finalBody));

            Http http = new Http();
            HttpResponse res = http.send(req);
            Map<String, Object> responseMap =(Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            if(res.getStatusCode() == 200) {
                String response = (String)responseMap.get('response');
                System.debug('responseWrapper==>'+response);
                String decryptedJson = AESUtil.decryptAES(response, randomLong);
                FibeResponseWrapper responseWrapper = FibeResponseWrapper.parse(decryptedJson);
                // APIRequestHandler.insertAPIRequest(JsonBody,decryptedJson,'FibeLeadCreateAPI',true,recordId,objType,'FibeLoan');
                System.debug('responseWrapper==>'+responseWrapper);
                return responseWrapper;
            } else {
                 // APIRequestHandler.insertAPIRequest(JsonBody,decryptedJson,'FibeLeadCreateAPI',true,recordId,objType,'FibeLoan');
            }
        } catch (Exception e) {
            System.debug('Exception :'+e.getMessage());
        }
        return null;
    } 

    
    /**
    * @description 
    * @author @Ravi | 27--02--2026 
    * @param API_Key__mdt fibeLaon 
    * @return String 
    **/
    public static String generateToken(API_Key__mdt fibeLaon){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(fibeLaon.Base_Url__c+'/generateToken');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> authBody = new Map<String, Object>{
            'username' => fibeLaon.Username__c,
            'password' => fibeLaon.Password__c
        };

        req.setBody(JSON.serialize(authBody));
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('res.getBody() :'+res.getBody());
        Map<String, Object> responseMap =(Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(res.getStatusCode() == 200 && responseMap.get('statusCode')== 200) {
            
            return (String) responseMap.get('token');
        }
        return (String)responseMap.get('statusMessage');
    }
}