/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-09-2024
 * @last modified by  : @BK
**/
public class UpdateLeadOwnerLC implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    public Set<String> lstFailedRecords;
    public Set<String> lstSuccessRecords;
    public Integer successCount = 0;
    public Integer failedCount = 0;
    public Integer totalCount = 0;
    public Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = new Map<Id,nm_Centers__c>();
    public List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();


    public UpdateLeadOwnerLC() {
        
    }
    public void execute(SchedulableContext sc) {
        UpdateLeadOwnerLC b = new UpdateLeadOwnerLC();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
       
        System.debug('Update LC list Batch started');
         mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
        List<String> lstStatus = new List<String>{'Admission Fee Paid','Admission Cancelled','Qualified','Registration Fee Disapproved By Finance','Registration Fee Paid'};
        String query = 'SELECT id, nm_InformationCenter__c,	Counselor_Profile__c,OwnerId,CreatedDate,nm_InformationCenter__r.nm_LearningCenter__c,Transfer_Lead_To_LC__c , nm_InformationCenter__r.OwnerId FROM Lead WHERE IsConverted=false AND Is_Transferred_From_LC_To_AEP__c=false AND LeadSource!=\'Partner\' AND Transfer_Lead_To_LC__c !=\'\' AND Transfer_Lead_To_LC__c != null AND Status NOT IN :lstStatus  Order by CreatedDate DESC LIMIT 9999';
        if(Test.isRunningTest()) {
            query =  'SELECT id, nm_InformationCenter__c,Counselor_Profile__c,OwnerId FROM Lead limit 1';
        }
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<nm_UserMapping__c> lstALLUserMapping = new List<nm_UserMapping__c>();
        List <Lead> leadToUpdate = new List<Lead>();
        if(scope.size() > 0) { 
            for(SObject sc : scope){
                Lead objLead = (Lead)sc;
                if(objLead.nm_InformationCenter__c != null && mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)  ){
                     Lead upLead = new Lead();
                       upLead.Id = objLead.Id;
                    upLead.nm_InformationCenter__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                    upLead.OwnerId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).OwnerId;
                    leadToUpdate.add(upLead );
                     totalCount++; 

                    }            
         else {
            System.debug('No records found.');
        }
    }
        if(leadToUpdate.size() > 0) {
            try {
                lstFailedRecords = new Set<String>();
                lstSuccessRecords = new Set<String>();
                Database.SaveResult[] srList = Database.update(leadToUpdate, false);
                for (Integer i = 0; i < leadToUpdate.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Lead origRecord = leadToUpdate[i];
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        lstSuccessRecords.add(origRecord.Id);
                        System.debug('Successfully updated Lead ID: ' + sr.getId());
                         successCount++;
        
                    } else {
                        System.debug('sr.getId() -->'+origRecord.id);
                        lstFailedRecords.add(origRecord.id);
                        failedCount++;
                        // Operation failed, so get all errors.                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Lead fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
         catch (Exception e) {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
             }
        }
    }
    }
     public List<nm_Centers__c> getlstActiveCenters(){
        if(lstActiveCenters.isEmpty()){
            String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' id !=null and nm_LearningCenter__c !=null and RegistrationClosed__c =false',null);            
            // this.lstActiveCenters = DataBase.query(queryActiveCenters);
             mapOfCenterIdVsCenter = new Map<id,nm_Centers__c>((List<nm_Centers__c>)DataBase.query(queryActiveCenters));
            lstActiveCenters = mapOfCenterIdVsCenter.values() ;
            system.debug('lstActiveCenters---query'+lstActiveCenters );
        }       
        return lstActiveCenters;
    }
      public Map<Id,nm_Centers__c> getMapOfCenterIdVsCenter(){
        if(this.mapOfCenterIdVsCenter.isEmpty()){

              List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
            system.debug('lstActiveCenters--->'+lstActiveCenters );
            if(lstActiveCenters.size() > 0 && mapOfCenterIdVsCenter.isEmpty()){
                for(nm_Centers__c objCenter : lstActiveCenters){
                    mapOfCenterIdVsCenter.put(objCenter.id,objCenter);
                }
            }
        }
        return mapOfCenterIdVsCenter;
    }
       public String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }

    public void finish(Database.BatchableContext bc) {
        if(lstFailedRecords!=null && lstFailedRecords.size() > 0) {
            sendErrorMail();
        }
        system.debug('Finished ===> ');
    }


    public void sendErrorMail() {
        String recordList = '';
        if(lstFailedRecords!=null && lstFailedRecords.size()>0) {
            for(String s: lstFailedRecords) {
                recordList += (recordList==''?'':',\n')+s;
            }
        }
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
        string[] toAddress = System.Label.setBccAdderess.split(','); 
        mail.setToAddresses(toAddress);
        mail.setSubject('UpdateLeadOwnerLC Error Mail');
        String mailBody = 'Hi Team,\n\n'+
        'Please find below UpdateLeadOwnerLC Class Error:\n'+
        'Here are the lists of failed records List:\n'+
          recordList +'\n\n'+
        'Total Records Processed: ' +totalCount +'\n'+
        'Sucess Records: '+ successCount +'\n'+
        'Error Records: '+ failedCount +'\n\n'+
       
        'Thanks & Regards' +'\n'+
        'NMIMS CDOE';
        mail.setPlainTextBody(mailBody);
        mail.setOrgWideEmailAddressId(owe.id);   
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

     
    }
}