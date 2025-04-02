/**
 * @File Name          : GenerateRegistrationNoBatch.cls
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 02-21-2022
 * @last modified by  : @BK
**/
public class GenerateRegistrationNoBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    nmLeadTriggerHandler objTrigger = new nmLeadTriggerHandler();
    Map<String,String> mapOfChoosePrgTypevsSessionYear = new Map<String,String>();
    Map<String,String> mapOfProgramTypeVsStrPreRegistrationId = new Map<String,String>();
    List<Calender__c> lstCalender = new List<Calender__c>();
    Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();

    public void execute(SchedulableContext sc) {
        GenerateRegistrationNoBatch b = new GenerateRegistrationNoBatch();
        Database.executebatch(b, 50);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Update course list Batch started');
        String query = 'SELECT id,nm_RegistrationNo__c,CreatedDate,nm_ChooseaProgram__c,Program_Type__c,nm_RegistrationID__c,nm_SelectedIC__c,nm_InformationCenter__c,Email,MobilePhone FROM Lead WHERE nm_RegistrationNo__c=null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) { 
        List<Lead> lstNullLead = new List<Lead>();
        Map<String,Lead> mapOfLead = new Map<String,Lead>();
        List<String> registrationNou = new List<String>();
        Map<String,Lead> MapOfEmailVsLeadId = new Map<String,Lead>();
        Map<String,Lead> MapOfMobileNoVsLeadId = new Map<String,Lead>();
        mapOfCenterNameVsCenter = mapOfCenterNameVsCenter.size() == 0 ? objTrigger.getMapOfCenterNameVsCenter() : mapOfCenterNameVsCenter;
        try { 
            for(SObject sc : scope){ 
                Lead objLead = (Lead)sc;
                String selectedIC = objLead.nm_SelectedIC__c;
                objLead.nm_InformationCenter__c = (objLead.nm_InformationCenter__c==null && mapOfCenterNameVsCenter.size() > 0 && mapOfCenterNameVsCenter.containsKey(selectedIC)) ? mapOfCenterNameVsCenter.get(selectedIC).Id : objLead.nm_InformationCenter__c;
                MapOfEmailVsLeadId.put(objLead.Email,objLead);
                MapOfMobileNoVsLeadId.put(objLead.MobilePhone,objLead);
                mapOfLead.put(objLead.Id,objLead);
            }
            // mark Reborn on Duplicate Leads
            lstNullLead = updateReborn(MapOfEmailVsLeadId, MapOfMobileNoVsLeadId, mapOfLead);
            // to reset the map to use for to set registration n o generted leads.
            mapOfLead = new Map<String,Lead>();
            mapOfLead = GenerateRegistrationNoOnLead(lstNullLead);
            System.debug('Record getting updated ==>'+mapOfLead.size());
            
            List<Lead> deleteLead = new List<Lead>();
            List<Lead> lstLead = mapOfLead.values();
            Database.SaveResult[] srList = Database.update(lstLead, false);
            for (Integer i = 0; i < lstLead.size(); i++) {
                Database.SaveResult sr = srList[i];
                Lead origRecord = lstLead[i];
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated Account. Account ID: ' + sr.getId());
                } else {
                    System.debug('sr.getId() -->'+origRecord.id);
                    // Operation failed, so get all errors.                
                    for(Database.Error err : sr.getErrors()) {
                        String errorMsg = (String)err.getMessage();
                        if(errorMsg.contains('duplicate value found')) {
                            deleteLead.add(origRecord);
                        }
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }

            if(deleteLead.size() > 0) {
                delete deleteLead;
            }
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }

    /**
    * @description 
    * @author @BK | 02-12-2022 
    * @param lstLead 
    * @return Map<String, Lead> 
    **/
    public Map<String,Lead> GenerateRegistrationNoOnLead(List<Lead> lstLead){
        
        Map<String,Lead> mapOfRegistrationNoAndLead = new Map<String,Lead>();
        // list of active calendars
        List<Calender__c> lstCalender = getlstCalender();
        List<Lead> lstLeadDuplicatedRegNo = new List<Lead>();
        String calenderSession = '';
        String calenderYear = '';
        // Map<String,String> mapOfProgramTypeVsStrPreRegistrationId = new Map<String,String>();
        system.debug('lstCalender--->'+lstCalender);
        if(lstCalender.size() > 0 && !mapOfProgramTypeVsStrPreRegistrationId.isEmpty()) {
            string strPreRegistrationID = '';
            System.debug('mapOfProgramTypeVsStrPreRegistrationId---'+mapOfProgramTypeVsStrPreRegistrationId);
            System.debug('mapOfRegistrationNoAndLead---'+mapOfRegistrationNoAndLead);
            for( Lead objLead : lstLead){
                String mapKey = objLead.nm_ChooseaProgram__c;
                if(objLead.Program_Type__c != null && objLead.Program_Type__c != '') {
                    mapKey = objLead.nm_ChooseaProgram__c + '-' + objLead.Program_Type__c;
                }

                if(objLead.nm_ChooseaProgram__c!=null && mapOfProgramTypeVsStrPreRegistrationId.containskey(mapKey) ){                                            
                    strPreRegistrationID = mapOfProgramTypeVsStrPreRegistrationId.get(mapKey);
                    system.debug('strPreRegistrationID --->'+strPreRegistrationID );
                }
                else if(mapOfProgramTypeVsStrPreRegistrationId.containskey('All'))
                {
                    strPreRegistrationID = mapOfProgramTypeVsStrPreRegistrationId.get('All');
                    system.debug('strPreRegistrationID --->'+strPreRegistrationID );
                }
                if (String.isNotBlank(strPreRegistrationID)) {
                    Datetime x = Datetime.now();
                    // String RegistrationNo = strPreRegistrationID + (Integer)Math.floor(10000 + Math.random()*90000);
                    String RegistrationNo = strPreRegistrationID + Integer.valueof((Math.random() * 1000)) + x.millisecond();
                    // call method to get Unique Registration Number
                    String UniqueRegistratioNo = objTrigger.FindDuplicateRegistrationNo(RegistrationNo,strPreRegistrationID,mapOfRegistrationNoAndLead ); 
                    
                    objLead.nm_RegistrationNo__c = UniqueRegistratioNo ;
                    objLead.nm_RegistrationID__c = strPreRegistrationID ;
                    mapOfRegistrationNoAndLead.put(objLead.nm_RegistrationNo__c,objLead);
                }
            }
        }
        return removeDuplicateNo(mapOfRegistrationNoAndLead);
    }

    /**
    * @description 
    * @author @BK | 02-12-2022 
    * @param mapOfLead 
    * @return Map<String, Lead> 
    **/
    public Map<String,Lead> removeDuplicateNo(Map<String,Lead> mapOfLead) {
        List<Lead> LstOfDuplicateLead = [SELECT id,nm_RegistrationNo__c FROM Lead WHERE nm_RegistrationNo__c IN :mapOfLead.keySet()];
        if(LstOfDuplicateLead.size() > 0) {
            for(Lead objLead : LstOfDuplicateLead) {
                Lead removedKey = mapOfLead.containsKey(objLead.nm_RegistrationNo__c) ? mapOfLead.remove(objLead.nm_RegistrationNo__c) : null;
            }
        }
        return mapOfLead;
    }

    /**
    * @description 
    * @author @BK | 02-12-2022 
    * @return List<Calender__c> 
    **/
    public List<Calender__c> getlstCalender() {
        String mapKey;
        if(mapOfProgramTypeVsStrPreRegistrationId.isEmpty() || mapOfChoosePrgTypevsSessionYear.isEmpty()) {       
           lstCalender = getlstCalendervs2();
            if (lstCalender.size() > 0) {
                system.debug('enter into list');  
                String TodaysDate = String.valueOf(System.now().day());
                if(TodaysDate.length () < 2){
                    TodaysDate = '0'+TodaysDate;
                }
                TodaysDate =TodaysDate+String.valueOf(System.now().month());    
                if (mapOfProgramTypeVsStrPreRegistrationId.isEmpty() || mapOfChoosePrgTypevsSessionYear.isEmpty()) {
                    for (Calender__c objCal: lstCalender) {
                        String sessionMonth = objTrigger.findDriveMonthCount(objCal.Session__c);
                        if (String.isNotBlank(objCal.nm_Type__c)) {
                               mapKey = objCal.nm_Type__c;
                            if (objCal.Specialisation__c != null && objCal.Specialisation__c != '') {
                                mapKey = objCal.nm_Type__c + '-' + objCal.Specialisation__c;
                            }
                        }
   
                        if (String.IsBlank(objCal.nm_Type__c)) {
                            mapOfChoosePrgTypevsSessionYear.put('All', objCal.Session__c + '_' + String.valueof(objCal.Year__c));
                            mapOfProgramTypeVsStrPreRegistrationId.put('All',sessionMonth+String.valueOf(objCal.Year__c).substring(2,4)+TodaysDate);
                        } else {
                            mapOfChoosePrgTypevsSessionYear.put(mapKey, objCal.Session__c + '_' + String.valueof(objCal.Year__c));
                            mapOfProgramTypeVsStrPreRegistrationId.put(mapKey,sessionMonth+String.valueOf(objCal.Year__c).substring(2,4)+TodaysDate);
                        }
                        system.debug('mapOfChoosePrgTypevsSessionYear--->' + mapOfChoosePrgTypevsSessionYear);
                        system.debug('mapOfProgramTypeVsStrPreRegistrationId--->' + mapOfProgramTypeVsStrPreRegistrationId);
                    }
                }
            }
        }
        system.debug('lstCalender--->'+lstCalender);
        return lstCalender;
    }

    /**
    * @description 
    * @author @BK | 02-12-2022 
    * @return List<Calender__c> 
    **/
    public List<Calender__c> getlstCalendervs2(){
        if(lstCalender.isEmpty()){
            String calenderQuery = objTrigger.getQueryAllFieldSql('Calender__c', 'Session_End_Date__c >=Today and Session_Start_Date__c  <= Today and Category__c = \'Admission\' ', null);
            lstCalender = DataBase.query(calenderQuery);
            system.debug('lstCalender.size()--->'+lstCalender.size());           
        }       
        return lstCalender;
    }



    /**
    * @description 
    * @author @BK | 02-21-2022 
    * @param MapEmailId 
    * @param MapPhoneNo 
    * @param MapOfIdVsLead 
    * @return List<Lead> 
    **/
    public List<Lead> updateReborn(Map<String,Lead> MapEmailId, Map<String,Lead> MapPhoneNo, Map<String,Lead> MapOfIdVsLead) {
        List<Lead> lstLead = [SELECT id,Status,Email,MobilePhone FROM Lead WHERE (Email IN :MapEmailId.keySet() OR MobilePhone IN :MapPhoneNo.keySet()) AND nm_RegistrationNo__c!=null];
        Map<Id,Lead> MapOfDuplicateLeads = new Map<Id,Lead>();
        if(lstLead.size() > 0) {
            for (Lead objLead : lstLead) {
                objLead.status = 'Reborn';
                if(MapEmailId.containsKey(objLead.Email)) {
                    Lead objLeadNew = MapEmailId.get(objLead.Email);
                    MapOfDuplicateLeads.put(objLeadNew.id,objLeadNew);
                    if(MapOfIdVsLead.containsKey(objLeadNew.id)) {
                        MapOfIdVsLead.remove(objLeadNew.id);
                    }
                }
                if(MapPhoneNo.containsKey(objLead.MobilePhone)) {
                    Lead objLeadNew = MapPhoneNo.get(objLead.MobilePhone);
                    MapOfDuplicateLeads.put(objLeadNew.id,objLeadNew);
                    if(MapOfIdVsLead.containsKey(objLeadNew.id)) {
                        MapOfIdVsLead.remove(objLeadNew.id);
                    }
                }
            }
            Database.SaveResult[] srList = Database.update(lstLead, false);
            for (Integer i = 0; i < lstLead.size(); i++) {
                Database.SaveResult sr = srList[i];
                Lead origRecord = lstLead[i];
                if (!sr.isSuccess()) {
                    System.debug('sr.getId() -->'+origRecord.id);
                    // Operation failed, so get all errors.                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            // delete the duplicate leads 
            if(MapOfDuplicateLeads.size() > 0) {
                delete MapOfDuplicateLeads.values();
            }
        }
        return MapOfIdVsLead.values();
    }

    public void finish(Database.BatchableContext bc) { 
        System.debug('Finished');
    }
}