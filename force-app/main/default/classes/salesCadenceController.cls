/**
 * @File Name          : salesCadenceController.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 06-04-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    16/4/2020   shubhranshu     Initial Version
**/
public without sharing class salesCadenceController {
    
    @AuraEnabled(Cacheable = true)
    public static List<Lead> getLeads(){
        String userId = UserInfo.getUserId();
        List<Lead> Finallist = new List<Lead>();
        List <Lead> listlead1 = [select Id,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_STDCode__c,Phone,
                                nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,Comment__c,CreatedDate from Lead where (Status='Not Contacted' or Status='Reborn') and ownerID =:userId  Order By CreatedDate asc];
        Finallist.addAll(listlead1);

        if(listlead1.size()<10)
        { 
            List <Lead> listlead2 = [select Id,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_STDCode__c,Phone,
                                     nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,Comment__c,CreatedDate  from Lead where Next_Follow_up__c=Today and ownerID =:userId and IsConverted =false and  DescriptionLastUpdated__c!=today and Status_Tracking__c!=today Order By Next_Follow_up__c desc];
            Finallist.addAll(listlead2);

            if(listlead2.size()<10){
                List <Lead> listlead3 = [select Id,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_STDCode__c,Phone,
                                nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,Comment__c,CreatedDate,NumberofAttempts__c  from Lead where 
                LastModifiedDate!=today and DescriptionLastUpdated__c!=today and Status_Tracking__c!=today and IsConverted =false and ownerID =:userId Order By nm_LeadWeightage__c desc ,NumberofAttempts__c asc,DescriptionLastUpdated__c desc];
                Finallist.addAll(listlead3);
            } 
        }
        return Finallist;
    }
    
    @AuraEnabled
    public static List<Lead> getLeadsforRefresh(){
        String userId = UserInfo.getUserId();
        List<Lead> Finallist = new List<Lead>();
        List <Lead> listlead1 = [select Id,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_STDCode__c,Phone,
                                nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,Comment__c,CreatedDate from Lead where (Status='Not Contacted' or Status='Reborn') and ownerID =:userId  Order By CreatedDate asc];
        Finallist.addAll(listlead1);

        if(listlead1.size()<10)
        { 
            List <Lead> listlead2 = [select Id,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_STDCode__c,Phone,
                                     nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,Comment__c,CreatedDate  from Lead where Next_Follow_up__c=Today and ownerID =:userId and IsConverted =false and  DescriptionLastUpdated__c!=today and Status_Tracking__c!=today Order By Next_Follow_up__c desc];
            Finallist.addAll(listlead2);

            if(listlead2.size()<10){
                List <Lead> listlead3 = [select Id,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_STDCode__c,Phone,
                                nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,Comment__c,CreatedDate,NumberofAttempts__c  from Lead where 
                LastModifiedDate!=today and DescriptionLastUpdated__c!=today and Status_Tracking__c!=today and IsConverted =false and ownerID =:userId Order By nm_LeadWeightage__c desc ,NumberofAttempts__c asc,DescriptionLastUpdated__c desc];
                Finallist.addAll(listlead3);
            } 
        }
        return Finallist;
    }

    @AuraEnabled
    public static Lead updateLead(Lead ld,String ldId){
        System.debug('ld '+ld+' ldId '+ldId);
        try{ 
            ld.id = ldId;
            update ld;
            System.debug('Lead is updated...');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return ld;
    }

    @AuraEnabled
    public static String updateDescription(String leadId, String comment){
        System.debug('Id '+leadId+' Comment '+comment);
        try{ 
            Lead objLead = new Lead(); 
            objLead.Id = leadId;
            objLead.Comment__c = comment;
            update objLead;
            System.debug('Lead is updated...');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return 'success';
    }

    @AuraEnabled(cacheable=true)
    public static EmailMessage getEmailDetails(String taskId) {
        List<EmailMessage> msgs = [select Id,Subject,FromName,FromAddress,ToAddress,TextBody,HtmlBody,
                                        (select RelationId,Relation.Name,RelationObjectType,RelationType
                                        from EmailMessageRelations
                                        where RelationType in('FromAddress','ToAddress')
                                        order by RelationType asc)
                                    from EmailMessage
                                    where ActivityId=:taskId];
        if(!msgs.isEmpty()){
            return msgs[0];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<Task> getActivityHistory(String recordId, String dateFilter, Integer count){
        String dateFilterStr;
        if(dateFilter!=null){
            System.debug('Date filter= LAST_7_DAYS');
            switch on dateFilter{
                when 'last_7_days'{
                    System.debug('Date filter= LAST_7_DAYS');
                    dateFilterStr='LAST_N_DAYS:7';
                }
                when 'last_30_days'{
                    System.debug('Date filter= LAST_30_DAYS');
                    dateFilterStr='LAST_N_DAYS:30';
                }
                when 'next_7_days'{
                    System.debug('Date filter= NEXT_7_DAYS');
                    dateFilterStr='NEXT_N_DAYS:7';
                }
            }
        }
        String query = 'SELECT Subject,OwnerId,Owner.Name,WhoId,WhatId,Who.FirstName,Who.Name,Who.type,What.type,id,CreatedDate,CallType,Description,IsRecurrence,ActivityDate,Status,TaskSubtype FROM Task WHERE whoId=:recordId';
        if(String.isNotBlank(dateFilterStr)) {
            query += ' AND CreatedDate=' + dateFilterStr +' ORDER BY CreatedDate desc';
        } else {
            query += ' ORDER BY CreatedDate desc';
        }
        List<Task> lstTasks = DataBase.query(query);
        if(lstTasks.size() > 0) {
            return lstTasks;
        }

        return null;
    }

    // for cacheable methods
    @AuraEnabled(cacheable=true)
    public static Lead getLeadRecord(String recordId){
        List<Lead> lstLead = [SELECT Id,Name,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_Designation__c,Phone,
                                nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,nm_STDCode__c,
                                Age__c,nm_Qualification__c,Industry,Agency__c,nm_LeadWeightage__c,nm_Total_Months_of_WorkExperience__c,nm_WorkExperience__c,LeadSource,Comment__c
                                FROM Lead WHERE Id =:recordId];
        
        if(lstLead.size() > 0) {
            return lstLead[0];
        }
        return null;
    }

    // for non cachable methods
    @AuraEnabled
    public static Lead getRefershRecord(String recordId){
        List<Lead> lstLead = [SELECT Id,Name,FirstName,LastName,nm_InformationCenter__c,Status,nm_SelectedProgram__c,Next_Follow_up__c,Lead_Description__c,nm_Designation__c,Phone,
                                nm_ProgramName__c,Email,MobilePhone,nm_Session__c,nm_Year__c,nm_InformationCenter__r.Name,nm_ChooseaProgram__c,Description,nm_STDCode__c,
                                Age__c,nm_Qualification__c,Industry,Agency__c,nm_LeadWeightage__c,nm_Total_Months_of_WorkExperience__c,nm_WorkExperience__c,LeadSource,Comment__c
                                FROM Lead WHERE Id =:recordId];
        
        if(lstLead.size() > 0) {
            return lstLead[0];
        }
        return null;
    }

    @AuraEnabled
    public static Task saveTask(Task objTask){
        try {
            insert objTask;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
       return objTask;
    }

    @AuraEnabled(cacheable = true)
    public static OrgWideEmailAddress getOrgDetails(){
        try {
            OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            return owe;
        } catch (Exception e) {
            System.debug(e.getMessage());   
        }
        return null;
    }

    @AuraEnabled(cacheable = true)
    public static Organization getOrganization(){
        try {
            Organization objOrg = [SELECT id FROM Organization];
            return objOrg;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }


    @AuraEnabled(cacheable = true)
    public static List <FetchValueWrapper> fetchPickListValue(sObject objInfo, string picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
 
        // Get a map of fields for the SObject
        map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
 
        // Get the list of picklist values for this field.
        list <Schema.PicklistEntry> values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
 
        // Create a list of wrapper to store picklist value/lable
        list <FetchValueWrapper> objWrapper = new list < FetchValueWrapper > ();
 
        for (Schema.PicklistEntry a: values) {
            FetchValueWrapper oFetchValueWrapper = new FetchValueWrapper();
            oFetchValueWrapper.slabel = a.getLabel();
            oFetchValueWrapper.svalue = a.getValue();
            objWrapper.add(oFetchValueWrapper);
        }
        return objWrapper;
    }

    public with sharing class FetchValueWrapper {
        @auraEnabled public string slabel {get;set;}
        @auraEnabled public string svalue {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<Document> getAllDocuments(){
        List<Document> resultOfDocs = new List<Document>();
        List<Set<String>> lstWrapper = new List<Set<String>>();
        List<List<Document>> lstWrapperDocuments = new List<List<Document>>();
        List<Document> lstDocs = [SELECT Id,BodyLength,ContentType,Description,DeveloperName,FolderId,IsBodySearchable,IsDeleted,IsInternalUseOnly,
        IsPublic,Keywords,Name,NamespacePrefix,Type,Url,Folder.Name FROM Document WHERE Folder.Name!=null ORDER BY Name ASC NULLS FIRST];
        
        for(Integer i = 0 ; i < (lstDocs.size() / 200) + 1 ; i++){
            Set<String> setOfDocs = new Set<String>();
            List<Document> setOfDocumentsList = new List<Document>();
            for(Integer j=(i*200); (j<(i*200)+200) && j < lstDocs.size(); j++){
                setOfDocs.add(lstDocs.get(j).Id);
                setOfDocumentsList.add(lstDocs.get(j));
            }
            lstWrapper.add(setOfDocs);
            lstWrapperDocuments.add(setOfDocumentsList);
        }
        String userId = UserInfo.getUserID();

        Integer count = 0;
        for(Set<String> setOfDocs : lstWrapper) {
            List<Document> setOfDocumentsList = lstWrapperDocuments[count];
            List<UserRecordAccess> lst = [SELECT RecordId, HasAllAccess, HasDeleteAccess, HasEditAccess, HasReadAccess, HasTransferAccess 
                                            FROM UserRecordAccess where UserId =:userId and RecordId IN :setOfDocs];
            for(UserRecordAccess usr : lst){
                for(Document doc:setOfDocumentsList){
                    if(doc.Id == usr.RecordId && usr.HasReadAccess){
                       resultOfDocs.add(doc); 
                    }
                }
            }
            count++;
        }
        if(resultOfDocs.size() > 0){
            return resultOfDocs;
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getAllEmailTemplate(){
        List<EmailTemplate> resultOfTemplates = new List<EmailTemplate>();
        List<Set<String>> lstWrapper = new List<Set<String>>();
        List<List<EmailTemplate>> lstWrapperTemplates = new List<List<EmailTemplate>>();
        List<String> activeTemplate = new List<String>();
        List<EmailTemplate> lstTemplate = [SELECT Id FROM EmailTemplate WHERE IsActive=true AND (NOT Name LIKE 'Communities:%')];
        
        for(Integer i = 0 ; i < (lstTemplate.size() / 200) + 1 ; i++){
            Set<String> setOfTemplates = new Set<String>();
            List<EmailTemplate> setOfTemplatesList = new List<EmailTemplate>();
            for(Integer j=(i*200); (j<(i*200)+200) && j < lstTemplate.size(); j++){
                setOfTemplates.add(lstTemplate.get(j).Id);
                setOfTemplatesList.add(lstTemplate.get(j));
            }
            lstWrapper.add(setOfTemplates);
            lstWrapperTemplates.add(setOfTemplatesList);
        }
        String userId = UserInfo.getUserID();

        Integer count = 0;
        for(Set<String> setOfTemplates : lstWrapper) {
            List<EmailTemplate> setOfTemplatesList = lstWrapperTemplates[count];
            List<UserRecordAccess> lst = [SELECT RecordId, HasReadAccess FROM UserRecordAccess where UserId =:userId and RecordId IN :setOfTemplates];
            for(UserRecordAccess usr : lst){
                for(EmailTemplate doc:setOfTemplatesList){
                    if(doc.Id == usr.RecordId && usr.HasReadAccess){
                        activeTemplate.add(doc.Id);
                    }
                }
            }
            count++;
        }

        if(activeTemplate.size() > 0) {
            resultOfTemplates = [SELECT Id,Subject,Folder.Name,TemplateType,OwnerId,Description,Body,Name,
                HtmlValue,FolderId FROM EmailTemplate WHERE IsActive=true AND Id IN :activeTemplate];

            if(resultOfTemplates.size() > 0){
                return resultOfTemplates;
            }
        }
        return null;
    }

    @AuraEnabled
    public static string sendEmail(EmailValueWrapper objWrapper) {
        try {
            System.debug(objWrapper);
            OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {objWrapper.toAddress};
            mail.setToAddresses(toAddresses);
            if(String.isNotBlank(objWrapper.ccAddress)) {
                String[] toCC = objWrapper.ccAddress.split(',');
                mail.setCcAddresses(toCC);
            }

            if(String.isNotBlank(objWrapper.bccAddress)) {
                String[] toBCC = objWrapper.bccAddress.split(',');
                mail.setBccAddresses(toBCC);
            }
            mail.setTargetObjectId(objWrapper.leadId);
            mail.setSaveAsActivity(true);
            mail.setOrgWideEmailAddressId(owe.id);
            mail.setReplyTo(owe.Address);
            if(String.isNotBlank(objWrapper.templateId)) {
                System.debug(objWrapper.templateId);
                mail.setTemplateID(objWrapper.templateId);
            } else {
                mail.setSubject(objWrapper.subject);
                mail.setHtmlBody(objWrapper.body);
            } 

            if(objWrapper.hasAttachment)  {
                List<Document> attachments = [SELECT Id,body,ContentType,Name FROM Document WHERE Id IN :objWrapper.attachments];
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                for (Document a : attachments) {
                    // Adds attachment to emails
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.body);
                    efa.setContentType(a.ContentType);
                    fileAttachments.add(efa);               
                }
                mail.setFileAttachments(fileAttachments);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            return 'Success';
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)  
    public static List<Lead_Score_Calculator__c> getLSMappings(){
        List<Lead_Score_Calculator__c> lstLeadScore = new List<Lead_Score_Calculator__c>();
        try {
            lstLeadScore = [SELECT Id,Name, Category__c, Lead_Score__c, Parameters__c, Total_Score__c,Weightage_Percentage__c,Weightage_Score__c FROM Lead_Score_Calculator__c ] ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('lstLeadScore '+lstLeadScore);
        if(lstLeadScore.size() > 0){
            return lstLeadScore;
        }
        return null;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Counsellor_Profile__c> getCounselorDetails(String centerId){
        List<Counsellor_Profile__c> lstCounselors = [SELECT id,MobilePhone__c,AEP_Name__r.Name,First_Name__c,Last_Name__c,Agent_Number__c 
        FROM Counsellor_Profile__c WHERE Agent_Number__c!=null AND AEP_Name__r.Name=:centerId AND IsActive__c=false];
        return lstCounselors;
    }

    public with sharing class EmailValueWrapper {
        @auraEnabled public String leadId {get;set;}
        @auraEnabled public String fromAdress {get;set;}
        @auraEnabled public String toAddress {get;set;}
        @auraEnabled public String ccAddress {get;set;}
        @auraEnabled public String bccAddress {get;set;}
        @auraEnabled public String subject {get;set;}
        @auraEnabled public String body {get;set;}
        @auraEnabled public Boolean hasAttachment {get;set;}
        @auraEnabled public String emailType {get;set;}
        @auraEnabled public String templateId {get;set;}
        @auraEnabled public List<String> attachments {get;set;}
    }
}