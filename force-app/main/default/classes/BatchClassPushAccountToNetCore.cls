/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 26-12-2022
 * @last modified by  : @BK
**/
public class BatchClassPushAccountToNetCore implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    public Map<String,String> mapOfFieldVsAPI = new Map<String,String>();
    public Map<String,String> mapOfFieldVsFieldFormat = new Map<String,String>();

    public void execute(SchedulableContext sc) {
        BatchClassPushAccountToNetCore b = new BatchClassPushAccountToNetCore();
        Database.executebatch(b, 200);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = System.Now().addHours(-1);
        String query = 'SELECT Id,nm_StudentNo__c,PersonEmail,PersonMobilePhone,nm_DateOfBirth__c,nm_ProgramType__c,Program_Type__c,PersonLeadSource,Agency__c,Name,'+
        'nm_StateProvince__c,State_Province_Shipping__c,Program_Name__c,Batch__c,nm_StudentStatus__c,LC_Name__c,nm_IsProvisonal__c,Salutation,FirstName,LastName'+
        ' FROM Account WHERE nm_StudentStatus__c=\'Confirmed\' AND nm_StudentNo__c!=null AND LastModifiedDate>=:dt ORDER BY LastModifiedDate ASC';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) { 
        initalizeMap();
        List<Map<String,Object>> lstData = new List<Map<String,Object>>();
        Integer counter = 0;
        while(counter<750 && counter<scope.size()) {
            Map<String,Object> mapOfFieldVsAccount = mapAccountFields(scope[counter++]);
                lstData.add(mapOfFieldVsAccount);
            }

        if(lstData.size() > 0) {
            callQueryAPI(lstData);
        }
    }

    public Map<String,Object> mapAccountFields(Account objAccount) {
        Map<String,Object> mapOfFieldVsAccount = new Map<String,Object>();
        for (String mapKey : mapOfFieldVsAPI.keySet()) {
            String apiKey = mapOfFieldVsAPI.get(mapKey);
            if(objAccount.get(apiKey)!=null) {
                mapOfFieldVsAccount.put(mapKey, validateFieldType(mapKey,objAccount.get(apiKey)));
                system.debug('objAccount.get(apiKey)==>'+objAccount.get(apiKey));
            }
        }
        
        return mapOfFieldVsAccount;

    }

    public Object validateFieldType(String mapKey, Object val) {
        if(mapOfFieldVsFieldFormat.containsKey(mapKey)) {
            String typeOfVal = mapOfFieldVsFieldFormat.get(mapKey);
            if(typeOfVal=='text' && val!=null) {
                val = (Object)String.valueOf(val);
            } else if(typeOfVal=='int' && val!=null) {
                val = (Object)Integer.valueOf(val);
            } else if(typeOfVal=='date' && val!=null) {
                DateTime dt = (DateTime)val;
                val = (Object)dt.date();
            }
        } 
        return val;
    }

    public String createAPIRequest(List<Map<String,Object>> lstData) {
        System.debug('lstData ==>'+lstData.size());
        Map<String,Object> mapOfRequest = new Map<String,Object>();
        mapOfRequest.put('listid',Integer.valueOf(Label.NetCore_Smartech_listId));
        mapOfRequest.put('notifyemail','balakrishnan.ramalingam.ext@nmims.edu');
        mapOfRequest.put('callbackurl','https://ngasce.secure.force.com/nmlogin_new?type=registration');
        mapOfRequest.put('primarykey','SAPID');
        mapOfRequest.put('data', lstData);
        return JSON.serialize(mapOfRequest);
    }

    public void callQueryAPI(List<Map<String,Object>> lstData) {
        String postData = createAPIRequest(lstData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.NetCore_Smartech_Url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('api-key', '354e91a790e45faeb7d7c11dac753e07');
        req.setBody(postData);
        System.debug('request body-->'+req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode = res.getStatusCode();
        System.debug('callQueryAPI:statusCode =' + statusCode);
        String result = res.getBody();
        System.debug('result ==>'+result);
        Map<String,Object> mapOfResponse = (Map<String, Object>)JSON.deserializeUntyped(result);
        System.debug(mapOfResponse);
    }

    public void initalizeMap() {
        if(mapOfFieldVsAPI.size() == 0) {
            mapOfFieldVsAPI = new Map<String,String>{
                'EMAIL'=>'PersonEmail','MOBILE'=>'PersonMobilePhone','SAPID'=>'nm_StudentNo__c',
                'DATE_OF_BIRTH'=>'nm_DateOfBirth__c', // needs date format
                'PROGRAM_TYPE'=>'Program_Type__c',
                'FULLNAME'=>'Name',
                'CHOOSE_A_PROGRAM'=>'nm_ProgramType__c',
                'LEAD_SOURCE'=>'PersonLeadSource',
                'AGENCY'=>'Agency__c',
                'STATE_PERMANENT'=>'nm_StateProvince__c',
                'PROGRAM_NAME'=>'Program_Name__c',
                'REVISED_BATCH_NAME'=>'Batch__c',
                'STUDENT_STATUS'=>'nm_StudentStatus__c',
                'LC_NAME'=>'LC_Name__c',
                'PROVISIONAL_ADMISSION'=>'nm_IsProvisonal__c',
                'SALUTATION'=>'Salutation',
                'FIRST_NAME'=>'FirstName',
                'LAST_NAME'=>'LastName'
            };

            mapOfFieldVsFieldFormat = new Map<String,String> {
                'BIRTH_DATE'=>'date',
                'PROVISIONAL_ADMISSION'=>'text'
            };
        }
    }

    public void finish(Database.BatchableContext BC) { 
        System.debug('Finished');
    }
}