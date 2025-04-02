/**
 * @File Name          : BatchClassPushLeadToNetCore.cls
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 13-01-2025
 * @last modified by  : @BK
**/
public class BatchClassPushLeadToNetCore implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    
    public Map<String,String> mapOfFieldVsAPI = new Map<String,String>();
    public Map<String,String> mapOfFieldVsFieldFormat = new Map<String,String>();

    /**
    * @description 
    * @author @BK | 11-18-2022 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) {
        BatchClassPushLeadToNetCore b = new BatchClassPushLeadToNetCore();
        Database.executebatch(b, 750);
    }

    /**
    * @description 
    * @author @BK | 11-18-2022 
    * @param BC 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = System.Now().addHours(-1);
        String query = 'SELECT nm_LeadId__c,Email,MobilePhone,OwnerId,Created_Month__c,nm_RegistrationNo__c,DescriptionLastUpdated__c,Owner.Email,nm_PlantoStart__c,Is_Mobile_Verified__c,nm_IsEmailVerified__c,'+
        'is_dnd_new__c,Owner.Name,nm_LCEmailID__c,Lead_Stage_7__c,Lead_Stage_6__c,Lead_Stage_5__c,Lead_Stage_4__c,Lead_Stage_3__c,Lead_Stage_2__c,Lead_Stage_1__c,nm_Eligibility_Criteria_Ref__c,'+
        'nm_Designation__c,Industry,Total_Work_Experience__c,Highest_Qualification__c,nm_Qualification__c,Country,State,City,Networks__c,GACID__c,GCLID__c,nm_Keyword__c,'+
        'nm_AdvertisementCampaign__c,nmm_BatchName__c,nm_Reason_for_Dead_Invalid_Leads__c,Status_after_180_days__c,Status_after_90_days__c,Status_after_60_days__c,Status_after_30_days__c,'+
        'Status_after_15_days__c,Status_after_7_days__c,nm_Gender__c,LastName,FirstName,AEP_email_id__c,LC_Name__c,nm_ProgramName__c,Student_Number_Lateral__c,Agency__c,Name,nm_Session__c,'+
        'RebornCounter__c,EduVanz_last_update_status_date__c,Lead_created_date__c,nm_DateOfBirth__c,CreatedDate,NumberofAttempts__c,PostalCode,nm_Year__c,LeadSource,nm_InformationCenter__r.Name,'+
        'Program_Type__c,nm_ChooseaProgram__c,Lead_Description__c,Status FROM Lead WHERE LeadSource!=\'Partner\' AND LastModifiedDate>=:dt ORDER BY LastModifiedDate ASC';
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @author @BK | 11-18-2022 
    * @param BC 
    * @param scope 
    **/
    public void execute(Database.BatchableContext BC, List<Lead> scope) { 
        initalizeMap();
        List<Map<String,Object>> lstData = new List<Map<String,Object>>();
        List<Map<String,Object>> lstDataForActivity = new List<Map<String,Object>>();
        Integer counter = 0;
        while(counter < 750 && counter < scope.size()) {
            if(scope[counter].Lead_created_date__c >= System.now().addHours(-1)) {
                Map<String,Object> mapOfFieldVsLead = mapLeadFieldsForActivity(scope[counter]);
                lstDataForActivity.add(mapOfFieldVsLead);
            }

            Map<String,Object> mapOfFieldVsLead = mapLeadFields(scope[counter]);
            lstData.add(mapOfFieldVsLead);

            counter++;
        }

        if(!lstData.isEmpty()) {
            callQueryAPI(lstData);
        }

        if(!lstDataForActivity.isEmpty()) {
            LeadActivityHelper.callQueryAPI(lstDataForActivity);
        }
    }

    /**
    * @description 
    * @author @BK | 11-16-2022 
    * @param objLead 
    **/
    public Map<String,Object> mapLeadFields(Lead objLead) {
        Map<String,Object> mapOfFieldVsLead = new Map<String,Object>();
        for (String mapKey : mapOfFieldVsAPI.keySet()) {
          
            if(mapKey == 'INFORMATION_CENTER') {
                if(objLead.nm_InformationCenter__r.Name!=null)
                mapOfFieldVsLead.put(mapKey, objLead.nm_InformationCenter__r.Name);
                system.debug('mapOfFieldVsAPI.get(mapKey)==>'+objLead.nm_InformationCenter__r.Name);
            } else if(mapKey == 'OWNER_NAME') {
                if(objLead.Owner.Name!=null)
                mapOfFieldVsLead.put(mapKey, objLead.Owner.Name);
               system.debug('mapOfFieldVsAPI.get(mapKey)==>'+objLead.Owner.Name);
            } else if(mapKey == 'OWNER_EMAIL') {
                 system.debug('objLead.Owner.Email==>'+objLead.Owner.Email);
                if(objLead.Owner.Email!=null)
                mapOfFieldVsLead.put(mapKey, objLead.Owner.Email);
                
            } else {
                String apiKey = mapOfFieldVsAPI.get(mapKey);
                if(objLead.get(apiKey)!=null) {
                    mapOfFieldVsLead.put(mapKey, validateFieldType(mapKey,objLead.get(apiKey)));
                    system.debug('objLead.get(apiKey)==>'+objLead.get(apiKey));
                }
            }
        }
        
        return mapOfFieldVsLead;

    }

    /**
    * @description 
    * @author @BK | 27-12-2024 
    * @param Lead objLead 
    * @return Map<String, Object> 
    **/
    public Map<String,Object> mapLeadFieldsForActivity(Lead objLead) { 
        LeadActivityHelper.LeadData leadData = new LeadActivityHelper.LeadData();
        leadData.leadId = objLead.Id;
        leadData.status = objLead.Status;
        leadData.leadDescription = objLead.Lead_Description__c;
        leadData.chooseProgram = objLead.nm_ChooseaProgram__c;
        leadData.programName = objLead.nm_ProgramName__c;
        leadData.programType = objLead.Program_Type__c;
        leadData.leadCreatedDate = objLead.Lead_created_date__c;
        leadData.batchName = objLead.nmm_BatchName__c;
        leadData.lastUpdateStatusDate = null;
        leadData.descriptionLastUpdatedDate = null;
        if(objLead.EduVanz_last_update_status_date__c!=null) {
            DateTime dt = (DateTime)objLead.EduVanz_last_update_status_date__c;
            leadData.lastUpdateStatusDate = (Date)dt.date();
        }
        
        if(objLead.DescriptionLastUpdated__c!=null) {
            DateTime dt2 = (DateTime)objLead.DescriptionLastUpdated__c;
            leadData.descriptionLastUpdatedDate = (Date)dt2.date();
        }
        return LeadActivityHelper.mapLeadFields(leadData, 'Lead Created');
    }


    /**
    * @description 
    * @author @BK | 11-18-2022 
    * @param mapKey 
    * @param val 
    * @return Object 
    **/
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

    /**
    * @description 
    * @author @BK | 17-11-2022 
    * @return String 
    **/
    public String createAPIRequest(List<Map<String,Object>> lstData) {
        System.debug('lstData ==>'+lstData.size());
        Map<String,Object> mapOfRequest = new Map<String,Object>();
        mapOfRequest.put('listid',Integer.valueOf(Label.NetCore_Smartech_listId));
        mapOfRequest.put('notifyemail','balakrishnan.ramalingam.ext@nmims.edu');
        mapOfRequest.put('callbackurl','https://ngasce.secure.force.com/nmlogin_new?type=registration');
        mapOfRequest.put('primarykey','LEADID');
        mapOfRequest.put('data', lstData);
        return JSON.serialize(mapOfRequest);
    }

    /**
    * @description 
    * @author @BK | 11-18-2022 
    * @param lstData 
    **/
    public void callQueryAPI(List<Map<String,Object>> lstData) {
        String postData = createAPIRequest(lstData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.NetCore_Smartech_Url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('api-key', '8c6a823f040cd09421f2a785db8445a6');
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

    /**
    * @description 
    * @author @BK | 11-16-2022 
    **/
    public void initalizeMap() {
        if(mapOfFieldVsAPI.size() == 0) {
            mapOfFieldVsAPI = new Map<String,String>{
                'EMAIL'=>'Email','MOBILE'=>'MobilePhone','LEADID'=>'nm_LeadId__c',
                // 'OWNER_ID'=>'OwnerId',
                // 'LEAD_CREATE_MONTH_YEAR'=>'Created_Month__c',
                // 'REG_NO'=>'nm_RegistrationNo__c',
                'DESCRIPTION_LAST_UPDATED'=>'DescriptionLastUpdated__c', // needs date format
                // 'OWNER_EMAIL'=>'Owner.Email',
                // 'PLAN_TO_START'=>'nm_PlantoStart__c',
                // 'IS_MOBILE_VERIFIED'=>'Is_Mobile_Verified__c', // needs text format
                // 'IS_EMAIL_VERIFIED'=>'nm_IsEmailVerified__c', // needs text format
                // 'IS_DND'=>'is_dnd_new__c',
                // 'OWNER_NAME'=>'Owner.Name',
                // 'LC_EMAIL_ID'=>'nm_LCEmailID__c',
                // 'LEAD_STAGE_7'=>'Lead_Stage_7__c',
                // 'LEAD_STAGE_6'=>'Lead_Stage_6__c',
                // 'LEAD_STAGE_5'=>'Lead_Stage_5__c',
                // 'LEAD_STAGE_4'=>'Lead_Stage_4__c',
                // 'LEAD_STAGE_3'=>'Lead_Stage_3__c',
                // 'LEAD_STAGE_2'=>'Lead_Stage_2__c',
                // 'LEAD_STAGE_1'=>'Lead_Stage_1__c',
                // 'ELIGIBILITY_CRITERIA'=>'nm_Eligibility_Criteria_Ref__c',
                // 'DESIGNATION'=>'nm_Designation__c',
                // 'INDUSTRY'=>'Industry',
                // 'TOTAL_WORK_EXPERIENCE'=>'Total_Work_Experience__c',
                // 'HIGHEST_QUALIFICATION'=>'Highest_Qualification__c',
                // 'QUALIFICATION'=>'nm_Qualification__c',
                'COUNTRY'=>'Country',
                // 'STATE'=>'State',
                'CITY'=>'City',
                // 'NETWORKS'=>'Networks__c',
                // 'GACID'=>'GACID__c',
                // 'GCLID'=>'GCLID__c',
                // 'KEYWORD'=>'nm_Keyword__c',
                'ADVERTISEMENT_CAMPAIGN'=>'nm_AdvertisementCampaign__c',
                'BATCH_NAME'=>'nmm_BatchName__c',
                // 'REASON_FOR_DEAD_INVALID_LEADS'=>'nm_Reason_for_Dead_Invalid_Leads__c',
                // 'STATUS_AFTER_180_DAYS'=>'Status_after_180_days__c',
                // 'STATUS_AFTER_90_DAYS'=>'Status_after_90_days__c',
                // 'STATUS_AFTER_60_DAYS'=>'Status_after_60_days__c',
                // 'STATUS_AFTER_30_DAYS'=>'Status_after_30_days__c',
                // 'STATUS_AFTER_15_DAYS'=>'Status_after_15_days__c',
                // 'STATUS_AFTER_7_DAYS'=>'Status_after_7_days__c',
                // 'GENDER'=>'nm_Gender__c',
                'LAST_NAME'=>'LastName',
                'FIRST_NAME'=>'FirstName',
                // 'AEP_EMAIL_ID'=>'AEP_email_id__c',
                'LC_NAME'=>'LC_Name__c',
                'PROGRAM_NAME'=>'nm_ProgramName__c',
                // 'STUDENTNO'=>'Student_Number_Lateral__c',
                'AGENCY'=>'Agency__c',
                // 'FULLNAME'=>'Name',
                // 'SESSION'=>'nm_Session__c',
                // 'REBORN_COUNTER'=>'RebornCounter__c', // needs integer
                'LAST_UPDATE_STATUS_DATE'=>'EduVanz_last_update_status_date__c', // needs date format
                'LEAD_CREATED_DATE'=>'Lead_created_date__c', // needs date format (to check format)
                // 'DATE_OF_BIRTH'=>'nm_DateOfBirth__c', // needs date format (to check format)
                // 'CREATED_DATE'=>'CreatedDate', // needs date format
                // 'NUMBER_OF_ATTEMPTS'=>'NumberofAttempts__c', // needs integer
                // 'POSTAL_CODE'=>'PostalCode', // needs integer
                // 'YEAR'=>'nm_Year__c', // needs integer
                'LEAD_SOURCE'=>'LeadSource', 
                // 'INFORMATION_CENTER'=>'nm_InformationCenter__r.Name',
                // 'PROGRAM'=>'nm_ProgramName__c',
                'PROGRAM_TYPE'=>'Program_Type__c',
                'CHOOSE_A_PROGRAM'=>'nm_ChooseaProgram__c',
                'LEAD_DESCRIPTION'=>'Lead_Description__c',
                'LEAD_STATUS'=>'Status'
            };

            mapOfFieldVsFieldFormat = new Map<String,String> {
                'DESCRIPTION_LAST_UPDATED'=>'date',
                'IS_MOBILE_VERIFIED'=>'text',
                'IS_EMAIL_VERIFIED'=>'text',
                'REBORN_COUNTER'=>'int',
                'LAST_UPDATE_STATUS_DATE'=>'date',
                'CREATED_DATE'=>'date',
                'NUMBER_OF_ATTEMPTS'=>'int',
                'POSTAL_CODE'=>'int',
                'YEAR'=>'int'
            };
        }
    }

    /**
    * @description 
    * @author @BK | 11-18-2022 
    * @param BC 
    **/
    public void finish(Database.BatchableContext BC) { 
        System.debug('Finished');
    }
}