/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 07-29-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-09-2021   shubhranshu   Initial Version
**/
global without sharing class GetLoanDetailsService {

    webservice static String getLoanDetails(String chooseProgram){
        List<Tenure__c> lst = [SELECT Id,Choose_Program__c,Fee_Type__c,Interest_Rate__c,Loan_Type__c,Program_Type__c,Subvention_Value__c,Tenure__c,Key__c FROM Tenure__c WHERE Choose_Program__c=:chooseProgram AND IsActive__c=TRUE];
        Map<String,Map<String,Tenure__c>> mapofValues = new Map<String,Map<String,Tenure__c>>();
        String jsonMap = '';
        System.debug('lst ===>'+lst);
        if(lst.size() > 0) {
            for(Tenure__c objTenures :lst) { 
                Map<String,Tenure__c> mapSS = mapofValues.size() > 0 && mapofValues.containsKey(objTenures.Key__c) ? mapofValues.get(objTenures.Key__c) : new Map<String,Tenure__c>();
                mapSS.put(objTenures.Tenure__c,objTenures);
                mapofValues.put(objTenures.Key__c,mapSS);
            }
            System.debug('mapofValues ===>'+mapofValues.size());
            System.debug('JSON ===>');
            jsonMap = JSON.serialize(mapofValues);
            System.debug(jsonMap);
        }
        return jsonMap;
    }

    webservice static String generateChecksumForSession(String studentNo){
        String salt = 'SessionChecksum|'+studentNo;
        System.debug('salt value '+salt);
        String key = System.Label.NgasceSessionKey;
        Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
        System.debug('checksum ==>'+ EncodingUtil.convertToHex(data));
        return  EncodingUtil.convertToHex(data);
    }

}