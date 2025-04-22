/**
 * @File Name          : nmLeadTriggerHandler.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @Ravi
 * @Last Modified On   : 15--04--2025
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    11/5/2019, 10:18:02 AM   @BK     Initial Version
**/
public without sharing class nmLeadTriggerHandler {
    
    public static boolean IsAfterInsertRunOnce = false;
    public static boolean IsAfterUpdateRunOnce = false;
    public static boolean IsBeforeInsertRunOnce = false;
    public static boolean IsBeforeUpdateRunOnce = false; 
    
    public nmLeadTriggerHandler(){
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitQueryRows());
        System.debug('Total Number of records that can be queriedxc  in this Apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() );
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime());
        System.debug('Total Number of Future Call allowed in this Apex code context: ' +  Limits.getLimitFutureCalls());
    }
    
    // caching variable
    DocumentHelperClass documentHelper = new DocumentHelperClass();
    list<id> duplicateLeadIdsToBeDeleted = new list<id>();
    Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = new Map<String,List<nm_UserMapping__c>>();
    Map<Id,nm_UserMapping__c> mapOfCenterIdVsCenterUserMappinghead = new Map<Id,nm_UserMapping__c>();

    Map<String,String> mapOfUserIdVsCenterId = new Map<String,String>();
    Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = new Map<Id,nm_Centers__c>();
    Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();
  // Map<String,nm_StudentProgram__c> mapOfStudentNoVsProgramCompletedStudentPrg = new Map<String,nm_StudentProgram__c>();
    Map<String,Account> mapOfStudentNoVsProgramCompletedAccounts = new Map<String,Account>();
    
    //Map<String,User> mapOfUserIdVsUser = new Map<String,User>();
    Map<String,nm_Program__c> mapOfProgramNameVsProgram = new Map<String,nm_Program__c>();
    Map<Id,nm_Program__c> mapOfProgramIdVsProgram = new Map<Id,nm_Program__c>();
    Map<Id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = new Map<Id,Counsellor_Profile__c>();
    List<Counsellor_Profile__c> lstAllCP = new List<Counsellor_Profile__c> ();
    Map<String,String> mapOfChoosePrgTypevsSessionYear = new Map<String,String>();
    Map<String,String> mapOfProgramTypeVsStrPreRegistrationId = new Map<String,String>();
    // List<Calender__c> lstCalender = new List<Calender__c>();
   // List<Calender__c> lstActiveCalender = new List<Calender__c>();
    // List<nm_Program__c> lstAllProgram = new List<nm_Program__c>();
    List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
    List<nm_UserMapping__c> lstUserCenterMapping = new List<nm_UserMapping__c> ();
    List<User> lstActiveUsers = new List<User> ();
    //RecordType ob= [select Id from RecordType where sObjectType='Lead' and Name='AEP DND' limit 1];
    
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
    
    //  public List<nm_Program__c> getlstAllProgram (){
    //     if(this.lstAllProgram.isEmpty()){
    //         String ProgramQuery = getQueryAllFieldSql('nm_Program__c','nm_Type__c!=null',null);
    //            this.mapOfProgramIdVsProgram = new Map<id,nm_Program__c>((List<nm_Program__c>)DataBase.query(ProgramQuery));
    //            system.debug('mapOfProgramIdVsProgram -->'+mapOfProgramIdVsProgram );
    //         this.lstAllProgram = mapOfProgramIdVsProgram.values() ;
    //     }       
    //     return this.lstAllProgram;
    // }

    public List<nm_Centers__c> getlstActiveCenters(){
        if(this.lstActiveCenters.isEmpty()){
            String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' id !=null and RegistrationClosed__c =false',null);            
            // this.lstActiveCenters = DataBase.query(queryActiveCenters);
             this.mapOfCenterIdVsCenter = new Map<id,nm_Centers__c>((List<nm_Centers__c>)DataBase.query(queryActiveCenters));
            this.lstActiveCenters = mapOfCenterIdVsCenter.values() ;
            system.debug('lstActiveCenters---query'+lstActiveCenters );
        }       
        return this.lstActiveCenters;
    }
    
    public List<nm_UserMapping__c> getlstUserCenterMapping(){
        if(this.lstUserCenterMapping.isEmpty()){
           system.debug('UserMaping call out');
           String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null and nm_Centers__r.RegistrationClosed__c =false','nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name');
            this.lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
        }       
        return this.lstUserCenterMapping;
    }

    /**
    * @description 
    * @author @BK | 03-04-2024 
    * @return List<nm_Program__c> 
    **/
    public List<nm_Program__c> getlstAllProgram(){
        ProgramUtility utils = ProgramUtility.getInstance();
        List<nm_Program__c> lstAllProgram = utils.objWrapper.lstPrograms;
        this.mapOfProgramIdVsProgram = utils.objWrapper.mapOfIdVsProgram;
        this.mapOfProgramNameVsProgram = utils.objWrapper.mapOfNameVsProgram;
        System.debug('lstProgram ==>'+lstAllProgram.size());
        return lstAllProgram;
    }

    /**
    * @description 
    * @author @BK | 30-12-2023 
    * @return List<Calender__c> 
    **/
    public List<Calender__c> getlstCalender() {
        CalendarUtility utils = CalendarUtility.getInstance();
        System.debug('lstCalendar ==>'+utils.lstCalendar);
        List<Calender__c> lstCalender = utils.lstCalendar;
        if (this.mapOfProgramTypeVsStrPreRegistrationId.isEmpty() || this.mapOfChoosePrgTypevsSessionYear.isEmpty()) {       
            if (lstCalender.size() > 0) {
                System.debug('enter into list');  
                String todaysDate = String.valueOf(System.now().format('ddmm'));
                if (this.mapOfProgramTypeVsStrPreRegistrationId.isEmpty() || this.mapOfChoosePrgTypevsSessionYear.isEmpty()) {
                    for (Calender__c objCal: lstCalender) {
                        setSessionAndRegistrationId(objCal, todaysDate);
                    }
                }
            }
        }
        System.debug('lstCalender--->'+lstCalender);
        return lstCalender;
    }
      
    /**
    * @description 
    * @author @BK | 30-12-2023 
    * @param Calender__c objCal 
    **/
    public void setSessionAndRegistrationId(Calender__c objCal, String todaysDate) {
        String mapKey = null;
        String sessionMonth = findDriveMonthCount(objCal.Session__c);
        if(String.isNotBlank(objCal.nm_Type__c)) {
            mapKey = objCal.nm_Type__c;
            if (String.isNotBlank(objCal.Specialisation__c)) {
                mapKey = objCal.nm_Type__c + '-' + objCal.Specialisation__c;
            }
        }

        if (String.isBlank(mapKey)) {
            this.mapOfChoosePrgTypevsSessionYear.put('All', objCal.Session__c + '_' + String.valueof(objCal.Year__c));
            this.mapOfProgramTypeVsStrPreRegistrationId.put('All',sessionMonth+String.valueOf(objCal.Year__c).substring(2,4)+todaysDate);
        } else {
            this.mapOfChoosePrgTypevsSessionYear.put(mapKey, objCal.Session__c + '_' + String.valueof(objCal.Year__c));
            this.mapOfProgramTypeVsStrPreRegistrationId.put(mapKey,sessionMonth+String.valueOf(objCal.Year__c).substring(2,4)+todaysDate);
        }
        System.debug('mapOfChoosePrgTypevsSessionYear size--->' + this.mapOfChoosePrgTypevsSessionYear.size());
        System.debug('mapOfProgramTypeVsStrPreRegistrationId size--->' + this.mapOfProgramTypeVsStrPreRegistrationId.size());
    }
      
    /*public Map<String,nm_Program__c> getMapOfProgramNameVsProgram(){
        if(this.mapOfProgramNameVsProgram.isEmpty()){
            //String queryProgram = getQueryAllFieldSql('nm_Program__c',' nm_ProgramName__c !=null ',null);
            //List<nm_Program__c> lstPrograms = DataBase.query(queryProgram);
             List<nm_Program__c>  lstPrograms = getlstAllProgram(); 
            if(lstPrograms.size() > 0){
                for(nm_Program__c objProgram : lstPrograms){
                    this.mapOfProgramNameVsProgram.put(objProgram.nm_ProgramName__c,objProgram);
                }
            }
        }
        return this.mapOfProgramNameVsProgram;
    }*/

    public Map<String,nm_Program__c> getMapOfProgramNameVsProgram(){
        if(this.mapOfProgramNameVsProgram.isEmpty() || this.mapOfProgramIdVsProgram.isEmpty()){
            getlstAllProgram(); 
        }
        return this.mapOfProgramNameVsProgram;
    }
    
  /*  public Map<String,nm_StudentProgram__c> getMapOfStudentNoVsProgramCompletedStudentProgram(List<Lead> lstLead){
        Set<String> setOfLateralStudentNo = new Set<String>();
        for(Lead objLead : lstLead){
            if(objLead.Student_Number_Lateral__c !=null && objLead.Is_Lateral__c){ 
                setOfLateralStudentNo.add(objLead.Student_Number_Lateral__c);
            }
        }
        
        if(setOfLateralStudentNo.size() > 0){
            if(this.mapOfStudentNoVsProgramCompletedStudentPrg.isEmpty()){
                String queryClosedStudentProgramString = getQueryAllFieldSql('nm_StudentProgram__c',' nm_IsClosed__c = true and nm_Student__r.nm_StudentStatus__c = \'Confirmed\' and nm_Student__r.nm_StudentNo__c !=null and nm_Student__r.nm_StudentNo__c in :setOfLateralStudentNo',' nm_Program__r.nm_ProgramName__c ,nm_Program__r.nm_Type__c ,nm_Student__r.nm_StudentNo__c ');
                List<nm_StudentProgram__c> lstClosedStudentProgram = DataBase.query(queryClosedStudentProgramString);
                if(lstClosedStudentProgram.size() > 0){
                    for(nm_StudentProgram__c objStudentProgram : lstClosedStudentProgram){
                        this.mapOfStudentNoVsProgramCompletedStudentPrg.put(objStudentProgram.nm_Student__r.nm_StudentNo__c,objStudentProgram);
                    }
                }
            }
        }
        return this.mapOfStudentNoVsProgramCompletedStudentPrg;
    }*/
    // Comment by phalguni
    // public Map<String,Account> getMapOfStudentNoVsProgramCompletedAccounts(List<Lead> lstLead){
    //     Set<String> setOfLateralStudentNo = new Set<String>();
    //     for(Lead objLead : lstLead){
    //         if(objLead.Student_Number_Lateral__c !=null && objLead.Is_Lateral__c){ 
    //             setOfLateralStudentNo.add(objLead.Student_Number_Lateral__c);
    //         }
    //     }
        
    //     if(setOfLateralStudentNo.size() > 0){
    //         if(this.mapOfStudentNoVsProgramCompletedAccounts.isEmpty()){
    //             String queryClosedStudentProgramString = getQueryAllFieldSql('Account','Pass_Out__c = true and nm_StudentStatus__c = \'Confirmed\' and nm_StudentNo__c !=null and nm_StudentNo__c in :setOfLateralStudentNo',' nm_Program__r.nm_ProgramName__c ,nm_Program__r.nm_Type__c  ,nm_Program__r.Name');
    //             List<Account> lstClosedStudentProgram = DataBase.query(queryClosedStudentProgramString);
    //             if(lstClosedStudentProgram.size() > 0){
    //                 for(Account account : lstClosedStudentProgram){
    //                     this.mapOfStudentNoVsProgramCompletedAccounts.put(account.nm_StudentNo__c,account);
    //                 }
    //             }
    //         }
    //     }
    //     return this.mapOfStudentNoVsProgramCompletedAccounts;
    // }
    public Map<String,Account> getMapOfStudentNoVsProgramCompletedAccounts(List<Lead> lstLead){
        Set<String> setOfLateralStudentNo = new Set<String>();
        for(Lead objLead : lstLead){
            if(objLead.Student_Number_Lateral__c !=null && objLead.Is_Lateral__c){ 
                setOfLateralStudentNo.add(objLead.Student_Number_Lateral__c);
            }
        }
        
        if(setOfLateralStudentNo.size() > 0){
            if(this.mapOfStudentNoVsProgramCompletedAccounts.isEmpty()){
                String queryClosedStudentProgramString = getQueryAllFieldSql('Account','(Pass_Out__c = true or nm_StudentStatus__c = \'De-Registered\' or nm_Program__r.Anytime_Lateral__c =true) and nm_StudentNo__c !=null and Student_ID__c in :setOfLateralStudentNo','nm_Program__r.Specialisation__c,nm_Program__r.nm_ProgramName__c ,nm_Program__r.nm_Type__c  ,nm_Program__r.Name');
                   List<Account> lstClosedStudentProgram = DataBase.query(queryClosedStudentProgramString);
                if(lstClosedStudentProgram.size() > 0){
                    for(Account account : lstClosedStudentProgram){
                        this.mapOfStudentNoVsProgramCompletedAccounts.put(account.Student_ID__c,account);
                    }
                }
            }
        }
        return this.mapOfStudentNoVsProgramCompletedAccounts;
    }
    
    public Map<Id,nm_Centers__c> getMapOfCenterIdVsCenter(){
        if(this.mapOfCenterIdVsCenter.isEmpty()){
          //  String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' id !=null ',null);
          //  List<nm_Centers__c> lstActiveCenters = DataBase.query(queryActiveCenters);
            List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
            system.debug('lstActiveCenters--->'+lstActiveCenters );
            if(lstActiveCenters.size() > 0 && this.mapOfCenterIdVsCenter.isEmpty()){
                for(nm_Centers__c objCenter : lstActiveCenters){
                    this.mapOfCenterIdVsCenter.put(objCenter.id,objCenter);
                }
            }
        }
        return this.mapOfCenterIdVsCenter;
    }

    public Map<String,Id> getmapOfICNameVsLCId() {
        Map<String,Id> mapOfICNameVsLCId = new Map<String,Id>();
        List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
        system.debug('lstActiveCenters--->'+lstActiveCenters );
        if(lstActiveCenters.size() > 0){
            for(nm_Centers__c objCenter : lstActiveCenters){
                if(objCenter.recordtype__c == 'Information Center') {
                    mapOfICNameVsLCId.put(objCenter.Name,objCenter.nm_LearningCenter__c);
                }
            }
        }
        return mapOfICNameVsLCId;
    }
    
   /* public Map<String,User> getMapOfUserIdVsUser(){
        if(this.mapOfUserIdVsUser.isEmpty()){
            String queryActiveUsers = getQueryAllFieldSql('User',' name !=null ','Profile.Name');
             Map<id,User> mapOfUserIdVsUser = new Map<id,User>((List<User>)DataBase.query(queryActiveUsers));
            this.lstActiveUsers = mapOfUserIdVsUser.values() ;         
        }
        return this.mapOfUserIdVsUser;
    }*/
   /* public Map<String,User> getMapOfUserIdVsUser(){
        if(this.mapOfUserIdVsUser.isEmpty()){
            String queryActiveUsers = getQueryAllFieldSql('User',' name !=null ','Profile.Name');
            List<User> lstActiveUsers = DataBase.query(queryActiveUsers);
            if(lstActiveUsers.size() > 0){
                for(User objUser : lstActiveUsers){
                    this.mapOfUserIdVsUser.put(objUser.id,objUser);
                }
            }
        }
        return this.mapOfUserIdVsUser;
    }*/
    public Map<String,nm_Centers__c> getMapOfCenterNameVsCenter(){
        if(this.mapOfCenterNameVsCenter.isEmpty()){
          //  String queryActiveCenters = getQueryAllFieldSql('nm_Centers__c',' Name != null ',null);
         //   List<nm_Centers__c> lstActiveCenters = DataBase.query(queryActiveCenters);
            List<nm_Centers__c> lstActiveCenters  = getlstActiveCenters();
             system.debug('lstActiveCenters2--->'+lstActiveCenters );
            if(lstActiveCenters.size() > 0){
                for(nm_Centers__c objCenter : lstActiveCenters){
                   if(objCenter.Assign_IC_To_LC__c != null && objCenter.Assign_IC_To_LC__c != '') {
                       system.debug('@@@@@@@@@$$@$');
                       system.debug(objCenter.Assign_IC_To_LC__c);
                       List<String> lstAssignityToLc= new List<String>();
                       lstAssignityToLc =  objCenter.Assign_IC_To_LC__c.split(';');
                       for(string assignIcTOLC: lstAssignityToLc ) {
                            this.mapOfCenterNameVsCenter.put(assignIcTOLC.trim(),objCenter );
                       }

                   }
                    this.mapOfCenterNameVsCenter.put(objCenter.Name,objCenter);
                }
            }
        }
        return this.mapOfCenterNameVsCenter;
    }
    
    public Map<String,List<nm_UserMapping__c>> getMapOfCenterIdVsCenterUserMapping(){
        // String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null and nm_Centers__r.RegistrationClosed__c =false ','nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name');
         //System.debug('queryUserCenterMapping---'+queryUserCenterMapping);
         if(this.mapOfCenterIdVsCenterUserMapping.isEmpty()){
          //   List<nm_UserMapping__c> lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
          List<nm_UserMapping__c> lstUserCenterMapping = getlstUserCenterMapping();
             if(this.lstUserCenterMapping.size() > 0){
                 for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
                     if(!this.mapOfCenterIdVsCenterUserMapping.containsKey(objCenteruserMapping.nm_Centers__c)){
                         this.mapOfCenterIdVsCenterUserMapping.put(objCenteruserMapping.nm_Centers__c,new List<nm_UserMapping__c>());
                     }
                     if(objCenteruserMapping.nm_Head__c)
                     {
                       this.mapOfCenterIdVsCenterUserMappinghead.put(objCenteruserMapping.nm_Centers__c,objCenteruserMapping);
                     }
                     this.mapOfCenterIdVsCenterUserMapping.get(objCenteruserMapping.nm_Centers__c).add(objCenteruserMapping);
                 }
             }
         }
         return this.mapOfCenterIdVsCenterUserMapping;
     }
     
    public Map<String,String> getMapOfUserIdVsCenterId(){
       // String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null ',null);
        if(this.mapOfUserIdVsCenterId.isEmpty()){
          //  List<nm_UserMapping__c> lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
          List<nm_UserMapping__c> lstUserCenterMapping = getlstUserCenterMapping();
            if(this.lstUserCenterMapping.size() > 0){
                for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
                    this.mapOfUserIdVsCenterId.put(objCenteruserMapping.nm_User__c,objCenteruserMapping.nm_Centers__c);
                }
            }
        }
        return this.mapOfUserIdVsCenterId;
    }
    
    public Map<id,Counsellor_Profile__c> getMapAllCounsellor (){
        if(this.mapOfCounseloridVsCounselorProfile.isEmpty()){
            String CounsellorProfile = getQueryAllFieldSql('Counsellor_Profile__c','Name!=null and IsActive__c=false and UserIsActive__c =true',null);
               this.mapOfCounseloridVsCounselorProfile = new Map<id,Counsellor_Profile__c>((List<Counsellor_Profile__c>)DataBase.query(CounsellorProfile));
               system.debug('mapOfCounseloridVsCounselorProfile -->'+mapOfCounseloridVsCounselorProfile );
            this.lstAllCP = mapOfCounseloridVsCounselorProfile.values() ;
        }       
        return this.mapOfCounseloridVsCounselorProfile;
    }

    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }
    
    
    //Method to handle all before insert trigger events
    public void BeforeInsert(list<Lead> triggerNew, map<id,Lead> triggerOldMap){
        if(IsBeforeInsertRunOnce && triggerNew.size() < 25){// checking triggerNew size as data load from dataLoader it shoul be geater than 25 records at time to avoid unProcessing of records greater than 200 records 
            return;
        }
      
        IsBeforeInsertRunOnce = true;
        
        //Calling method to set escallation time
        escallationDate(triggerNew, triggerOldMap);
        
        //Calling Method In Order to Make Choose Program In Proper Case
        updateChooseProgramAndMobileNumberOnLead(triggerNew,true);
        
        //Calling method to update selected IC if leads need to be routed
        Lead_Routing(triggerNew);
        
        //Calling Method In Order to Make Choose Program In Proper Case
        //   updateChooseProgramAndMobileNumberOnLead(triggerNew,true);
        
        //Calling Method to fill IC automatically In case Lead CreateBy IC or LC
        ICAutoSelection (triggerNew);
        
        FillInformationCenterBasedUponSelectedIc(triggerNew);
        
        //update LC Email And Owner on Lead 
        UpdateLeadOwnerAndICEmailOnLead(triggerNew,triggerOldMap,'Insert');
        //  UpdateLeadOwnerAndICEmailOnLead(triggerNew,triggerOldMap);
        
        updateProgramDetailOnLead(triggerNew,triggerOldMap);
        
        // update Session and Year on Lead 
        Update_Session_Year(triggerNew);
        
        // split Lead Name for Get In Touch Lead or Lead Inserted from Website
        splitLeadName(triggerNew);
        
        // update Lead semester for Lateral Student Based upon Program Completed previously commented by Phalguni
        // UpdateLeadSemester(triggerNew,triggerOldMap);
        
        // generate Registration Number on Lead
        generateRegistrationNoOnLead(triggerNew);
        // internationalForm(triggerNew);

        // trim Email & Mobile Number on Lead
        trimEmailAndMobile(triggerNew);
        
        System.debug('-------------------------------Before Insert-------------------------------');
        System.debug('1. Number of Queries used in this Apex code so far : ' + Limits.getQueries());
        System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
        System.debug('3. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
        System.debug('4. Number of DML statements used so far: ' +  Limits.getDmlStatements());    
        System.debug('5. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
        System.debug('6. Number of Future Call used so far: ' + Limits.getFutureCalls());
    }
    
    public void AfterInsert(list<Lead> triggerNew, map<id,Lead> triggernewmap, map<id, Lead> triggerOldMap){
        if(IsAfterInsertRunOnce && triggerNew.size() < 25){
            return;
        }
        
        IsAfterInsertRunOnce = true;
        
        //Remove leads from trigger which are already deleted by above method.
        List<Lead> uniqueLeadsFromTriggerNew = new List<Lead>();
        for(Lead lead : triggerNew){
            if(!duplicateLeadIdsToBeDeleted.contains(lead.Id)){
                uniqueLeadsFromTriggerNew.add(lead);
            }
        }

        Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
        Set<String> setOfEligiblityCriteria = new Set<String>();
        Boolean isNeedToStartBatchClass = false;
        for(Lead lead : triggerNew){
            if ((UserInfo.getName() == 'marketing ngasce' || UserInfo.getName() == 'Suyog Deshmukh') && !isNeedToStartBatchClass && Boolean.valueOf(System.label.Lead_Allotment_For_Marketing) ) {
                isNeedToStartBatchClass= true;
            }
            System.debug('lead.nm_EligiblityCriteria__c '+lead.nm_EligiblityCriteria__c);
            if(String.isNotBlank(lead.nm_EligiblityCriteria__c) && lead.nm_EligiblityCriteria__c != triggerOldMap.get(lead.id).nm_EligiblityCriteria__c){
                setOfEligiblityCriteria.add(lead.nm_EligiblityCriteria__c);
            }
        }
    
        if(isNeedToStartBatchClass) {
            Database.executeBatch(new LeadAllotmentForAgencyBatchClass(), 20);
        } 
        
        //Calling method to get documents list against each criteria
        if(setOfEligiblityCriteria.size() > 0){
            mapCriteriaDocuments = documentHelper.GetProgrameWiseDocumentsList(setOfEligiblityCriteria);
        }
        //create Document Records on Insert Lead
        documentHelper.CreateDocumentRecordsOnLead(triggerNew,mapCriteriaDocuments);
         
        //Purpose of this method is not clear. MOved from updatetime trigger to here: Sanket : 17-Sep-2015
        updateCreateTimeStamp(uniqueLeadsFromTriggerNew,triggerOldMap);
         
        saveDuplicateLeadvs4(triggerNew); 
        
        // Flag the Partner lead as earlier it was Web Lead allocate to the same partner / partner group 
        getLeadTransferHistorytoUpdateLead(triggerNew);
        
        //Delete Duplicate records, calling one more time, in case record is not deleted. It was reported that in some cases record was not deleted.
        if(duplicateLeadIdsToBeDeleted.size() > 0){
            //delete [select id from Lead where id in :duplicateLeadIdsToBeDeleted];
            
            Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, false);
           /* for(Database.DeleteResult dr : deleteResults) {                   
                if (!dr.isSuccess()) {
                    for(Database.Error err : dr.getErrors()) {
                        System.debug(LoggingLevel.Error, 'The following error has occurred.'
                            + '\n' + err.getStatusCode() + ': ' + err.getMessage()
                            + '\n fields that affected this error: ' + err.getFields());
                        // Plus further error handling as required
                    }
                }
            }*/
            
            
            List<ID> listIds = new List<ID>(duplicateLeadIdsToBeDeleted);
            //Delete it permanantly, so that IC can not recover it from Recycle bin
            Database.emptyRecycleBin(listIds);
        }
        
        // call method to check and update Owner Id for Web-To-Lead cases
      /*  Set<String> setOfLeadId = new Set<String>();
        for(Lead lead : triggerNew){
            if(!String.IsBlank(lead.nm_SelectedIC__c)){
                setOfLeadId.add(lead.id);
            }
        }
        
        if(setOfLeadId.size() > 0){
            ChangeDefaultOwnerAssignment(setOfLeadId);
        }*/
        
        System.debug('-------------------------------After Insert-------------------------------');
        System.debug('1. Number of Queries used in this Apex code so far : ' + Limits.getQueries());
        System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
        System.debug('3. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
        System.debug('4. Number of DML statements used so far: ' +  Limits.getDmlStatements());    
        System.debug('5. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
        System.debug('6. Number of Future Call used so far: ' + Limits.getFutureCalls());
    }
    
    public void BeforeUpdate(list<Lead> triggerNew, map<id,Lead> triggerOldMap){
        if(IsBeforeUpdateRunOnce && triggerNew.size() < 25){
            return;
        }
        
        IsBeforeUpdateRunOnce = true;
        // checkDuplicateLeadWithEmailAndMobileWithLeadSource(triggerNew,triggerOldMap);
                    
        // checkDuplicateLeadWithEmailAndMobile(triggerNew,triggerOldMap);

        checkDuplicateLeadWithEmailAndMobileV2(triggerNew,triggerOldMap);
        
        //Calling method to set escallation time
        escallationDate(triggerNew, triggerOldMap);
        
        //Calling Method to Copy address
        copyAddressOnLead(triggerNew,triggerOldMap);
        
        //update LC Email And Owner on Lead 
       UpdateLeadOwnerAndICEmailOnLead(triggerNew,triggerOldMap,'Update');
      //UpdateLeadOwnerAndICEmailOnLead(triggerNew,triggerOldMap);
        
        //Calling Method In Order to Make Choose Program In Proper Case
        updateChooseProgramAndMobileNumberOnLead(triggerNew,false);
        
        updateProgramDetailOnLead(triggerNew,triggerOldMap);
          
          
        // update Session and Year on Lead 
        Update_Session_Year(triggerNew);
        
        // update Lead semester for Lateral Student Based upon Program Completed previously commented by Phalguni
        // UpdateLeadSemester(triggerNew,triggerOldMap);
        // trim Email & Mobile Number on Lead
        trimEmailAndMobile(triggerNew);
      
        // UpdateLeadStatus if Account with same Email or Mobile Exist in system
       // UpdateLeadStatusOfNewLeadForAlreadySameAccountPresentInSystem(triggerNew,triggerOldMap);
        
        System.debug('-------------------------------Before Update-------------------------------');
        System.debug('1. Number of Queries used in this Apex code so far : ' + Limits.getQueries());
        System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
        System.debug('3. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
        System.debug('4. Number of DML statements used so far: ' +  Limits.getDmlStatements());    
        System.debug('5. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
        System.debug('6. Number of Future Call used so far: ' + Limits.getFutureCalls());
    }
    
    //Method to handle all after update trigger events
    public void AfterUpdate(list<Lead> triggerNew, map<id,Lead> triggernewmap, map<id, Lead> triggerOldMap){
        if(IsAfterUpdateRunOnce && triggerNew.size() < 25){
            return;
        }
        
        IsAfterUpdateRunOnce = true;
        
        UpdateDocumentsForChangeInEligibilityCriteria(triggerNew,triggerOldMap);
       
        //Calling method to convert lead
        ConvertLead(triggerNew, triggerOldMap);
        
        // update Task owner Id 
        UpdateTaskOwnerId(triggerNew,triggerOldMap);
        
        //method to Send Mobile Number verification SMS and Email Verification Email
        sendMobileAndEmailVerificationMsg(triggerNew,triggerOldMap);
        
        // method to AutoUpdate State and Country based upon PostalCode
        autoAupdateStateAndCountryBasedUponPostalCode(triggerNew,triggerOldMap);

        //method to Send Mobile Number DND SMS
        sendMobileDNDSMS(triggerNew,triggerOldMap);
         
        // to call Liquiloans status update API in approved or rejected stage from our end
        callLoanStatusUpdate(triggernewmap,triggerOldMap);
        
        System.debug('-------------------------------After Update-------------------------------');
        System.debug('1. Number of Queries used in this Apex code so far : ' + Limits.getQueries());
        System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
        System.debug('3. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
        System.debug('4. Number of DML statements used so far: ' +  Limits.getDmlStatements());    
        System.debug('5. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
        System.debug('6. Number of Future Call used so far: ' + Limits.getFutureCalls());
    }
    
  /* Commented by phalguni
    public void Lead_Routing(list <Lead> lstLead) {
      Map <string,string> mapFromICNameAndToICName = new Map <string, string> ();
      Map <string, Lead_Routing__c> mapFromICNameAndLR = new Map <string, Lead_Routing__c> ();
      List <Lead_Routing__c> lstActiveLeadRouting = [select id, From_IC__c, To_IC__c, Agency__c,Choose_a_Program__c,CounselorProfile__c from Lead_Routing__c where Active__c = true];
      Set<String> agencyLrDefine =new Set<String>();
      Set<String> programLrDefine =new Set<String>();
      boolean CounselorDefine=false;
    if(lstActiveLeadRouting.size() > 0)
    {
        for(Lead_Routing__c lr: lstActiveLeadRouting)
        {
            mapFromICNameAndToICName.put(lr.From_IC__c, lr.To_IC__c);
            if(lr.Agency__c != null || lr.Choose_a_Program__c != null || lr.CounselorProfile__c!=null )
            {
                mapFromICNameAndLR.put(lr.From_IC__c, lr);
            }
        }
        for(Lead objLead: lstLead)
        {
            if(objLead.nm_SelectedIC__c != null && objLead.nm_SelectedIC__c != '' && objLead.LeadSource != 'Partner')
            {
                if(mapFromICNameAndToICName.containsKey(objLead.nm_SelectedIC__c))
                {
                    if(mapFromICNameAndLR.containsKey(objLead.nm_SelectedIC__c))
                    {
                        //agencyLrDefine = mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Agency__c!=null ? agencyLrDefine.addall(mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Agency__c.split(',')) : null;
                        //programLrDefine = mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Choose_a_Program__c!=null ? programLrDefine.addall(mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Choose_a_Program__c.split(';')):null;
                        
                        if( mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Agency__c!=null)
                        {
                            agencyLrDefine.addall(mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Agency__c.split(','));
                        }
                        if(mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Choose_a_Program__c!=null)
                        {
                            programLrDefine.addall(mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).Choose_a_Program__c.split(';'));
                            system.debug('programLrDefine-->'+programLrDefine);
                        }
                        if(mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).CounselorProfile__c!=null)
                        {
                            objLead.Counselor_Profile__c = mapFromICNameAndLR.get(objLead.nm_SelectedIC__c).CounselorProfile__c;
                            system.debug('CounselorProfile--->'+objLead.Counselor_Profile__c);
                            CounselorDefine = true;
                        }
                      if((agencyLrDefine !=null && agencyLrDefine.contains(objLead.Agency__c) )
                        || (programLrDefine!=null && programLrDefine.contains(objLead.nm_ChooseaProgram__c))
                        || CounselorDefine)
                        {
                            objLead.nm_StudentSelectedIC__c = objLead.nm_SelectedIC__c;
                            objLead.nm_SelectedIC__c = mapFromICNameAndToICName.get(objLead.nm_SelectedIC__c);
                        }
                    }
                    else
                    {
                        objLead.nm_StudentSelectedIC__c = objLead.nm_SelectedIC__c;
                        objLead.nm_SelectedIC__c = mapFromICNameAndToICName.get(objLead.nm_SelectedIC__c);
                    }
                }
            }
        }
    }
  }*/
/*
    Commented by @BK 18-12-2021
    public void Lead_Routing(list <Lead> lstLead) {
        Map<String,String> mapOfKeyVsCenterId = new Map<String,String>();
        List<String> lstProgramList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead_Routing__c.Choose_a_Program__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            lstProgramList.add(f.getValue());
        }
        System.debug(lstProgramList);    
        List <Lead_Routing__c> lstActiveLeadRouting = [SELECT id, From_IC__c, To_IC__c, Agency__c,Choose_a_Program__c,CounselorProfile__c FROM Lead_Routing__c WHERE Active__c = true];
        if(lstActiveLeadRouting.size() > 0) {
            for (Lead_Routing__c objLeadRouting : lstActiveLeadRouting) {
                List<String> lstProgram = new List<String>();
                List<String> lstAgency = new List<String>();
                if(objLeadRouting.Choose_a_Program__c!=null && objLeadRouting.Choose_a_Program__c!='') {
                    lstProgram = objLeadRouting.Choose_a_Program__c.split(';');
                }
                if(objLeadRouting.Agency__c!=null && objLeadRouting.Agency__c!='') {
                    lstAgency = objLeadRouting.Agency__c.split(',');
                }
                if(lstProgram.size() == 0 && lstAgency.size() == 0) {
                    for (String program : lstProgramList) {
                        String key = objLeadRouting.From_IC__c +'_'+program+'_null';
                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                    }
                } else if(lstProgram.size() > 0 && lstAgency.size() == 0) {
                    for (String program : lstProgram) {
                        String key = objLeadRouting.From_IC__c +'_'+program+'_null';
                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                    }
                } else if(lstProgram.size() == 0 && lstAgency.size() > 0) {
                    for (String program : lstProgramList) {
                        for (String agency : lstAgency) {
                            String key = objLeadRouting.From_IC__c +'_'+ program +'_' + agency.trim();
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        }
                    }
                } else {
                    for (String program : lstProgram) {
                        for (String agency : lstAgency) {
                            String key = objLeadRouting.From_IC__c +'_'+ program +'_' + agency.trim();
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        }
                    }
                }
            }
            System.debug(mapOfKeyVsCenterId.size());
            for(Lead objLead: lstLead) {
                if(objLead.LeadSource!='Partner' && objLead.nm_SelectedIC__c != null && objLead.nm_SelectedIC__c != '') {
                    String key = objLead.nm_SelectedIC__c +'_'+ objLead.nm_ChooseaProgram__c +'_'+ (objLead.Agency__c!=null && objLead.Agency__c!='' ? objLead.Agency__c.trim() : 'null');
                    String key2 = objLead.nm_SelectedIC__c +'_'+ objLead.nm_ChooseaProgram__c +'_null';
                    System.debug('Map Key for Lead Routing');
                    System.debug(key);
                    if(mapOfKeyVsCenterId.containsKey(key)) {
                        objLead.nm_StudentSelectedIC__c = objLead.nm_SelectedIC__c;
                        objLead.nm_SelectedIC__c = mapOfKeyVsCenterId.get(key);
                    } 
                    // for incase if the lead routing consists of any agencies.
                    else if(mapOfKeyVsCenterId.containsKey(key2)) {
                        objLead.nm_StudentSelectedIC__c = objLead.nm_SelectedIC__c;
                        objLead.nm_SelectedIC__c = mapOfKeyVsCenterId.get(key2);
                    }
                }
            }
        }
    }
*/

    /**
    * @description Lead Routing Logic
    * @author @BK | 12-18-2021 
    * @param lstLead 
    **/
    public void Lead_Routing(list <Lead> lstLead) {
        Map<String,String> mapOfKeyVsCenterId = new Map<String,String>();
        List<String> lstProgramTypeList = new List<String>();
        List<String> lstProgramList = new List<String>();
        Schema.DescribeFieldResult fieldResultForProgram = Lead_Routing__c.Choose_a_Program__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResultForProgram.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            lstProgramList.add(f.getValue());
        }

        Schema.DescribeFieldResult fieldResultForProgramType = Lead_Routing__c.Program_Type__c.getDescribe();
        ple = fieldResultForProgramType.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            lstProgramTypeList.add(f.getValue());
        }

        System.debug(lstProgramList);
        System.debug(lstProgramTypeList); 
        List <Lead_Routing__c> lstActiveLeadRouting = [SELECT id,From_IC__c,From_Center__r.Landing_Page_Cities__c,To_IC__c,Agency__c,Choose_a_Program__c,CounselorProfile__c,Program_Type__c FROM Lead_Routing__c WHERE Active__c=true];
        if(lstActiveLeadRouting.size() > 0) {
            Map<String,List<String>> mapOfChooseProgranVsProgramType = new Map<String,List<String>>();
            Map<String,String> mapOfCityVsLC = new Map<String,String>();
            List<String> lstMasterProgram = new List<String>{'MBA (WX)','MBA (X)','M.Sc.','M.Sc. (AI)','M.Sc. (AI & ML Ops)'};
            List<String> lstBachelorProgram = new List<String>{'BBA','BCom','BA'};
            List<String> lstProfessionalProgram = new List<String>{'Professional Diploma Term 4','Professional Diploma','PD Term 4'};
            List<String> lstCertificateProgram = new List<String>{'PC Term 2','Certificate Term 1','Certificate Term 2','Certificate Term 3'};
            List<String> lstMBAProgram = new List<String>{'MBA'};
            mapOfChooseProgranVsProgramType.put('Master Programs',lstMasterProgram);
            mapOfChooseProgranVsProgramType.put('Bachelor Programs',lstBachelorProgram);
            mapOfChooseProgranVsProgramType.put('Professional Programs',lstProfessionalProgram);
            mapOfChooseProgranVsProgramType.put('Certificate Programs',lstCertificateProgram);
            mapOfChooseProgranVsProgramType.put('MBA (Online) Programs',lstMBAProgram);

            for (Lead_Routing__c objLeadRouting : lstActiveLeadRouting) {
                String city = objLeadRouting.From_IC__c;
                String cities = objLeadRouting.From_Center__r.Landing_Page_Cities__c;
                if(String.isNotBlank(cities)) {
                    List<String> lstAssignityToLc = cities.split(';');
                    for(String lcity: lstAssignityToLc) {
                        mapOfCityVsLC.put(lcity,city);
                    }
                }

                List<String> lstProgram = new List<String>();
                List<String> lstProgramType = new List<String>();
                List<String> lstAgency = new List<String>();
                if(objLeadRouting.Choose_a_Program__c!=null && objLeadRouting.Choose_a_Program__c!='') {
                    lstProgram = objLeadRouting.Choose_a_Program__c.split(';');
                }
                if(objLeadRouting.Program_Type__c!=null && objLeadRouting.Program_Type__c!='') {
                    lstProgramType = objLeadRouting.Program_Type__c.split(';');
                }
                if(objLeadRouting.Agency__c!=null && objLeadRouting.Agency__c!='') {
                    lstAgency = objLeadRouting.Agency__c.split(',');
                }

                if(lstProgram.size() == 0 && lstAgency.size() == 0 && lstProgramType.size() == 0) {
                    for (String program : lstProgramList) {
                        // to insert Default Program Keys
                        String key = city +'_'+program+'_null_null';
                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        
                        // to insert All the specializationTypes Keys
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        for(String programType : lstprogramTypes) {
                            String key2 = city +'_'+program+'_'+programType+'_null';
                            mapOfKeyVsCenterId.put(key2,objLeadRouting.To_IC__c);
                        }
                    }
                } else if(lstProgram.size() > 0 && lstAgency.size() == 0 && lstProgramType.size() == 0) {
                    for (String program : lstProgram) {
                        // to insert Default Program Keys
                        String key = city +'_'+program+'_null_null';
                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        
                        // to insert All the specializationTypes Keys
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        for(String programType : lstprogramTypes) {
                            String key2 = city +'_'+program+'_'+programType+'_null';
                            mapOfKeyVsCenterId.put(key2,objLeadRouting.To_IC__c);
                        }
                    }
                } else if(lstProgram.size() == 0 && lstAgency.size() == 0 && lstProgramType.size() > 0) {
                    for (String programType : lstProgramType) {
                        for(String programKey : mapOfChooseProgranVsProgramType.keySet()){
                            List<String> lPType = mapOfChooseProgranVsProgramType.get(programKey);
                            if(lPType.contains(programType)) {
                                String key3 = city +'_'+programKey+'_'+programType+'_null';
                                mapOfKeyVsCenterId.put(key3,objLeadRouting.To_IC__c);
                                break;
                            }
                        }
                    }
                } else if(lstProgram.size() > 0 && lstAgency.size() == 0 && lstProgramType.size() > 0) {
                    for (String program : lstProgram) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            Boolean checkExists = false;
                            List<String> lstSpecilaization = new List<String>();
                            for(Integer i=0; i<lstprogramTypes.size(); i++) {
                                if(lstProgramType.contains(String.valueof(lstprogramTypes[i]))) {
                                    checkExists = true;
                                    lstSpecilaization.add(String.valueof(lstprogramTypes[i]));
                                }
                            } 
                            if(checkExists) {
                                for(String programType : lstSpecilaization) {
                                    String key2 = city +'_'+program+'_'+programType+'_null';
                                    mapOfKeyVsCenterId.put(key2,objLeadRouting.To_IC__c);
                                } 
                            } else {
                                for(String programType : lstprogramTypes) {
                                    String key2 = city +'_'+program+'_'+programType+'_null';
                                    mapOfKeyVsCenterId.put(key2,objLeadRouting.To_IC__c);
                                }
                            }
                        } else {
                            String key = city +'_'+program+'_null_null';
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        }
                    }
                } else if(lstProgram.size() == 0 && lstProgramType.size() == 0 && lstAgency.size() > 0) {
                    for (String program : lstProgramList) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            for(String programType : lstprogramTypes) {
                                for (String agency : lstAgency) {
                                    String key = city +'_'+ program +'_'+programType+'_' + agency.trim();
                                    mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                                }
                            }
                        }
            
                        for (String agency : lstAgency) {
                            String key = city +'_'+ program +'_null_' + agency.trim();
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        }
                    }
                } else if(lstProgram.size() > 0 && lstProgramType.size() == 0 && lstAgency.size() > 0) {
                    for (String program : lstProgram) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            for(String programType : lstprogramTypes) {
                                for (String agency : lstAgency) {
                                    String key = city +'_'+ program +'_'+programType+'_' + agency.trim();
                                    mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                                }
                            }
                        }
            
                        for (String agency : lstAgency) {
                            String key = city +'_'+ program +'_null_' + agency.trim();
                            mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                        }
                    }
                } else {
                    for (String program : lstProgram) {
                        List<String> lstprogramTypes = mapOfChooseProgranVsProgramType.containsKey(program) ? mapOfChooseProgranVsProgramType.get(program) : new List<String>();
                        if(lstprogramTypes.size() > 0) {
                            Boolean checkExists = false;
                            List<String> lstSpecilaization = new List<String>();
                            for(Integer i=0; i<lstprogramTypes.size(); i++) {
                                if(lstProgramType.contains(String.valueof(lstprogramTypes[i]))) {
                                    checkExists = true;
                                    lstSpecilaization.add(String.valueof(lstprogramTypes[i]));
                                }
                            } 
                            if(checkExists) {
                                for(String programType : lstSpecilaization) {
                                    for (String agency : lstAgency) {
                                        String key = city +'_'+ program +'_'+programType+'_' + agency.trim();
                                        mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                                    }
                                } 
                            } else {
                                Boolean checkLimit = false;
                                for(String programType : lstprogramTypes) {
                                    for (Integer i = 0; i < lstAgency.size(); i++) {
                                        String agency = lstAgency[i];
                                        System.debug('agency ==>'+agency);
                                        String key1 = city +'_'+ program +'_'+programType+'_' + agency.trim();
                                        mapOfKeyVsCenterId.put(key1,objLeadRouting.To_IC__c);
                                        
                                        // to insert default value as well
                                        if(!checkLimit) {
                                            String key2 = city +'_'+ program +'_null_' + agency.trim();
                                            mapOfKeyVsCenterId.put(key2,objLeadRouting.To_IC__c);
                                            if(i == (lstAgency.size()-1)) {
                                                checkLimit = true;
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            for (String agency : lstAgency) {
                                String key = city +'_'+ program +'_null_' + agency.trim();
                                mapOfKeyVsCenterId.put(key,objLeadRouting.To_IC__c);
                            }
                        }
                    }
                }
            }
            System.debug(mapOfKeyVsCenterId.size());
            List<String> lstLeadSourceToAvoid = new List<String>{'Partner','AEP-CC','CC-AEP'};
            for(Lead objLead: lstLead) {
                if(!lstLeadSourceToAvoid.contains(objLead.LeadSource) && String.isNotBlank(objLead.nm_SelectedIC__c)) {
                    String programType = String.isNotBlank(objLead.Program_Type__c) && mapOfChooseProgranVsProgramType.containsKey(objLead.nm_ChooseaProgram__c) 
                                        ? objLead.Program_Type__c 
                                        : 'null';
                    String city = mapOfCityVsLC.containsKey(objLead.nm_SelectedIC__c) ? mapOfCityVsLC.get(objLead.nm_SelectedIC__c) : objLead.nm_SelectedIC__c;
                    String agency = objLead.Agency__c!=null && objLead.Agency__c!='' ? objLead.Agency__c.trim() : 'null';
                    String key = city +'_'+ objLead.nm_ChooseaProgram__c +'_' + programType + '_'+ agency;
                    String key2 = city +'_'+ objLead.nm_ChooseaProgram__c +'_'+ programType +'_null';
                    
                    System.debug('Map Key for Lead Routing');
                    System.debug(key);
                    System.debug(key2);
                    System.debug('is Key Exists ==> '+mapOfKeyVsCenterId.containsKey(key));
                    System.debug('is key2 Exists ==> '+mapOfKeyVsCenterId.containsKey(key2));
                    if(mapOfKeyVsCenterId.containsKey(key)) {
                        objLead.nm_StudentSelectedIC__c = objLead.nm_SelectedIC__c;
                        objLead.nm_SelectedIC__c = mapOfKeyVsCenterId.get(key);
                    } 
                    // for incase if the lead routing consists of any agencies.
                    else if(mapOfKeyVsCenterId.containsKey(key2)) {
                        objLead.nm_StudentSelectedIC__c = objLead.nm_SelectedIC__c;
                        objLead.nm_SelectedIC__c = mapOfKeyVsCenterId.get(key2);
                    }
                }
            }
        }
    }
 
    public void updateChooseProgramAndMobileNumberOnLead(list<Lead> lstLead , boolean IsInsert){
        system.debug('updateChooseProgramAndMobileNumberOnLead called');
        if(lstLead.size()>0){
         //Lead ob= [SELECT Id, Name ,RecordTypeId FROM Lead WHERE RecordType.Name = 'AEP DND'];
            for(Lead objLead :lstLead){
                if(objLead.nm_ChooseaProgram__c !=null){// update choose program in proper format as in SFDC
                    if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('Post')){
                        objLead.nm_ChooseaProgram__c ='Post Graduate Diploma Programs';
                    }else if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('Diploma')){
                        objLead.nm_ChooseaProgram__c ='Diploma Programs';
                    }else if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('Certificate')){
                        objLead.nm_ChooseaProgram__c ='Certificate Programs';
                    }else if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('Bachelor')){
                        objLead.nm_ChooseaProgram__c ='Bachelor Programs';
                    }else if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('Master')){                           
                        objLead.nm_ChooseaProgram__c ='Master Programs';        
                    }else if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('Professional')){      
                        objLead.nm_ChooseaProgram__c ='Professional Programs';      
                    }else if(objLead.nm_ChooseaProgram__c.startsWithIgnoreCase('MBA')){      
                        objLead.nm_ChooseaProgram__c ='MBA (Online) Programs';      
                    }         
                    
                }
                //If(objLead.Mobile_Masked__c!=null)
               /* If(String.isBlank(objLead.Mobile_Masked__c))
                {
                    objLead.Mobile_Masked__c= objLead.MobilePhone;  
                }
                If(String.isNotBlank(objLead.Mobile_Masked__c) && String.isBlank(objLead.MobilePhone))
                {
                    objLead.MobilePhone= objLead.Mobile_Masked__c;
                }
                If(String.isBlank(objLead.Email_Masked__c))
                {
                    objLead.Email_Masked__c= objLead.Email;  
                }
                If(String.isNotBlank(objLead.Email_Masked__c) && String.isBlank(objLead.Email))
                {
                    objLead.Email=objLead.Email_Masked__c;
                }
                
                if(objLead.is_dnd_new__c=='Yes')
                {
                    objLead.RecordTypeId=ob.Id;
                }*/
                // remove bracket from Mobile Number 
                if(objLead.MobilePhone != null && IsNullOrEmpty(objLead.Country_Code__c) ){
                    string strMobileNo = objLead.MobilePhone;
                    strMobileNo = strMobileNo.replace('(','');
                    strMobileNo = strMobileNo.replace(')','');
                    strMobileNo = strMobileNo.replace(' ','');
                    strMobileNo = strMobileNo.replace('-','');
                    strMobileNo = strMobileNo.replace('+91','');
                    strMobileNo = strMobileNo.trim();
                    if(IsInsert){
                        strMobileNo = strMobileNo.right(10);
                    }
                    objLead.MobilePhone = strMobileNo;
                }
            }
        }
    }
    
    public void updateCreateTimeStamp(list<Lead> triggerNew,map<id, Lead> triggerOldMap){
        Integer y = System.now().year();
        Integer mo = System.now().month();
        Integer d = System.now().day();
        Integer h = System.now().hour();
        Integer mi = System.now().minute(); 
       // Map<String,User> mapOfUserIdVsUser = getMapOfUserIdVsUser();
       // String MyProflieName =  mapOfUserIdVsUser.get(UserInfo.getUserId()).Name;
        String MyProflieName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
        list <lead> lstleadToUpdate = new list<lead>();
        for(Lead objlead: triggerNew){
            Lead objNewLead = new Lead(id=objLead.id);
            objNewLead.nm_TimeStamp2__c = objLead.nm_CreatedDatetime__c.format('hh:mm a');
            objNewLead.nm_PaymentStatus__c = ''; // make  PaymentStatus blank in case of Lead created from Web to Lead form 
            if(objLead.Description != '' && objLead.Lead_Action__c != '' && objLead.Description != null && objLead.Lead_Action__c != null){
                objNewLead.Description = objLead.Description +'\n'+ objLead.Lead_Action__c+'\n'+' inserted by ' + MyProflieName + DateTime.valueOf(y + '-' + mo + '-' + d + ' ' + (h+5)+ ':' + (mi+30)+ ':00') ;
            }else if(objLead.Lead_Action__c != '' && objLead.Lead_Action__c != null){
                objNewLead.Description = objLead.Lead_Action__c+'\n'+' inserted by ' + MyProflieName + DateTime.valueOf(y + '-' + mo + '-' + d + ' ' + (h+5)+ ':' + (mi+30)+ ':00') ;
            }else if(objLead.Description != '' && objLead.Description != null){
                objNewLead.Description = objLead.Description +'\n'+' inserted by ' + MyProflieName + DateTime.valueOf(y + '-' + mo + '-' + d + ' ' + (h+5)+ ':' + (mi+30)+ ':00') ;
            }
            lstleadToUpdate.add(objNewLead);
        }
        
        if(lstleadToUpdate.size() > 0){
            update lstleadToUpdate;
        }
    }

    /**
    * @description : To trim the email and mobile values
    * @author @BK | 01-04-2023 
    * @param lstLead 
    **/
    public void trimEmailAndMobile(list<Lead> lstLead) {
        for(Lead objLead : lstLead) {
            String EmailID = objLead.Email;
            objLead.Email = String.isNotBlank(EmailID) ? EmailID.trim() : EmailID;
            String MobileNo = objLead.MobilePhone;
            objLead.MobilePhone = String.isNotBlank(MobileNo) ? MobileNo.trim() : MobileNo;
        }
    }

    /**
    * @description : Purpose of this method is to identify leads that have a previous transfer history Records and update them to reflect that they were previously allocated as web leads
    * @author @Ravi | 28--01--2025 
    * @param lstLead 
    **/
    public void getLeadTransferHistorytoUpdateLead(List<Lead> lstLead) {
        System.debug('in Lead Transfer History ' + lstLead);
        List<lead> lstToUpdate = new List<lead>();
    try {
        if (lstLead.size() > 0) {
            for (Lead lead : lstLead) {
                Lead objNewLead = new Lead(id=lead.id);
                String email = lead.Email;
                String mobile = lead.MobilePhone;
                String infoCenterId = lead.nm_InformationCenter__c;
                List<Lead_Transfer_History__c> lstTransferHistory = [SELECT Id, Lead__c,Prev_AEP_Name__c, Is_Assigment_History__c, New_AEP_Name__c FROM Lead_Transfer_History__c
                                                                     WHERE Prev_AEP_Name__c =:infoCenterId AND (Lead__r.Email =:email OR Lead__r.MobilePhone =:mobile) ];
                if (lstTransferHistory.size() > 0) {
                    objNewLead.Is_Previously_Allocated_As_Web_Lead__c =true;
                    lstToUpdate.add(objNewLead);
                }
            }
            System.debug('Leads to Update: ' + lstToUpdate);
            if (lstToUpdate.size() > 0) {
                update lstToUpdate;
            }
        }
    } catch (Exception error) {
        System.debug(' fail to Update Lead: ' + error.getMessage());
        System.debug('Line Number===>'+error.getLineNumber());
     } }
    
    //Method to fill IC and program lookup on leads from website basis of IC name selected by candidate
    public void FillInformationCenterBasedUponSelectedIc(list<Lead> lstLead){
        if(lstLead.size() > 0){  
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            Map<String,nm_Program__c> mapOfProgramNameVsProgram = getMapOfProgramNameVsProgram();
            Map<String,nm_Centers__c> mapOfCenterNameVsCenter = getMapOfCenterNameVsCenter();
            Map<String,Id> mapOfICNameVsLCId = getmapOfICNameVsLCId();
            List<Lead> lstLeadToUpdate = new List<Lead>();
           // Map<Integer,id> mapOfRoundRobinIds =new map<Integer,id>();
            List<nm_UserMapping__c> lstUserMapping = new List<nm_UserMapping__c>();
            system.debug('Method Entered');
            for(Lead objLead : lstLead)
            {
                if(objLead.nm_InformationCenter__c != null){
                    System.debug('Method Entered inside value');
                    lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                }
                else if(!String.isBlank(objLead.nm_SelectedIC__c)){
                    System.debug('Method Entered inside step 2');
                    if(UserInfo.getName() == 'marketing ngasce') {
                        System.debug('Method Entered inside step 3');
                        objLead.nm_InformationCenter__c = mapOfCenterNameVsCenter.get('Counsellor').id;
                        lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(mapOfCenterNameVsCenter.get('Counsellor').id);
                    } else if(mapOfICNameVsLCId.containsKey(objLead.nm_SelectedIC__c) && mapOfICNameVsLCId.get(objLead.nm_SelectedIC__c)!=null
                        && !objLead.LeadSource.contains('Partner')) {
                        System.debug('Method Entered inside step 4');
                        String inFormationCenterId = mapOfICNameVsLCId.get(objLead.nm_SelectedIC__c);
                        System.debug(inFormationCenterId);
                        objLead.nm_InformationCenter__c = inFormationCenterId;
                        lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(inFormationCenterId);
                    } else {
                        System.debug('Method Entered inside step 5');
                        String inFormationCenterId = addInformationCenterBasedOnCurrentLocation(objLead.nm_SelectedIC__c, objLead.nm_ChooseaProgram__c, objLead.nm_City_P__c);
                        System.debug(inFormationCenterId);
                        objLead.nm_InformationCenter__c = inFormationCenterId;
                        lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(inFormationCenterId);
                    }
                }
                else{
                    objLead.nm_InformationCenter__c = mapOfCenterNameVsCenter.get('Counsellor').id;
                    lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(mapOfCenterNameVsCenter.get('Counsellor').id);
                   // IsCounsellorLead = true;
                }
                system.debug('lstUserMapping-->'+lstUserMapping);
                
                if (lstUserMapping != null && lstUserMapping.size() > 1) 
                {   
                    objLead.OwnerId = AssignUser(lstUserMapping,objLead.nm_ChooseaProgram__c );
                }else if(lstUserMapping!=null && lstUserMapping.size()>0 ){
                    objLead.OwnerId = lstUserMapping[0].nm_user__c;
                }

                if(objLead.nm_SelectedProgram__c !=null){
                    if(mapOfProgramNameVsProgram.containsKey(objLead.nm_SelectedProgram__c)){
                        objLead.nm_Program__c = mapOfProgramNameVsProgram.get(objLead.nm_SelectedProgram__c).id;
                        objLead.Program_Type__c = mapOfProgramNameVsProgram.get(objLead.nm_SelectedProgram__c).Specialisation__c;
                    }
                }
                if(objLead.nm_Program__c !=null && IsNullOrEmpty(objLead.nm_SelectedProgram__c)){
                    if(!mapOfProgramIdVsProgram.isEmpty() && mapOfProgramIdVsProgram.containsKey(objLead.nm_Program__c)){
                        objLead.nm_SelectedProgram__c = mapOfProgramIdVsProgram.get(objLead.nm_Program__c).nm_ProgramName__c;
                        objLead.Program_Type__c = mapOfProgramIdVsProgram.get(objLead.nm_Program__c).Specialisation__c;
                    }
                }
            }
                        
            if(lstLeadToUpdate.size() > 0){
                update lstLeadToUpdate;
            }            
        }
    }



    // Method To Get Information Center From Selected Ic Or City

    public string addInformationCenterBasedOnCurrentLocation(String currentLocation, String programName, String city) {
        System.debug('Method Entered addInformationCenterBasedOnCurrentLocation');
        Map<String, nm_Centers__c> mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();
        System.debug(' Inside addInformationCenterBasedOnCurrentLocation Lead currentLocation + programName + city ----->' +currentLocation + '-' + programName + ' - ' + city );
        // System.debug(mapOfCenterNameVsCenter1.containsKey('Mumbai - Mira Road East'));
        if (mapOfCenterNameVsCenter1.containsKey(currentLocation) && String.isNotBlank(programName)) {
            System.debug('Method Entered addInformationCenterBasedOnCurrentLocation Step 1');
            nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(currentLocation);
            System.debug(objCenter1);
            if (String.isNotBlank(objCenter1.nm_ChooseaProgram__c) && objCenter1.nm_ChooseaProgram__c.contains(programName)) {
                return String.valueof(objCenter1.Id);
            } else if (
                mapOfCenterNameVsCenter1.containsKey(objCenter1.CenterName__c) &&
                String.isNotBlank(mapOfCenterNameVsCenter1.get(city).nm_ChooseaProgram__c) &&
                mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c).nm_ChooseaProgram__c.contains(programName)
            ) {
                nm_Centers__c objCenter2 = mapOfCenterNameVsCenter1.get(objCenter1.CenterName__c);
                System.debug('objCenter2 --------------->>>' + objCenter2);

                return objCenter2.Id;
            } else if (
                String.isNotBlank(city) &&
                mapOfCenterNameVsCenter1.containsKey(city) &&
                String.isNotBlank(mapOfCenterNameVsCenter1.get(city).nm_ChooseaProgram__c) &&
                mapOfCenterNameVsCenter1.get(city).nm_ChooseaProgram__c.contains(programName)
            ) {
                System.debug('@#$@##@#@#');
                nm_Centers__c objCenter3 = mapOfCenterNameVsCenter1.get(city);
                System.debug('objCenter3 --------------->>>' + objCenter3);

                return objCenter3.Id;
            }
        } else if (
            String.isNotBlank(city) &&
            String.isNotBlank(programName) &&
            mapOfCenterNameVsCenter1.containsKey(city) &&
            String.isNotBlank(mapOfCenterNameVsCenter1.get(city).nm_ChooseaProgram__c) &&
            mapOfCenterNameVsCenter1.get(city).nm_ChooseaProgram__c.contains(programName) &&
            mapOfCenterNameVsCenter1.get(city).RegistrationClosed__c == false
            ) {
            nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(city);
            return String.valueof(objCenter1.Id);
        }
        return mapOfCenterNameVsCenter1.containskey('Counsellor') ? mapOfCenterNameVsCenter1.get('Counsellor').Id:null;
    }

                    
    /**
    * @description 
    * @author @BK | 03-04-2024 
    * @param List<Lead> lstlead 
    * @param Map<id Lead> oldMap 
    **/
    public void updateProgramDetailOnLead(List <Lead> lstlead, Map <id,Lead> oldMap) {
        // updating Lead program 
        for (Lead objLead: lstLead) {
            if (oldMap != null) {
                System.debug('objLead.nm_Program__c--->'+objLead.nm_Program__c);
                if (objLead.nm_Program__c != oldMap.get(objLead.id).nm_Program__c) {
                    objLead = setProgram(objLead);
                }
            } else if (objLead.nm_Program__c != null) {
                objLead = setProgram(objLead);
            }
        }
    }


    /**
    * @description 
    * @author @BK | 03-04-2024 
    * @param Lead objLead 
    * @return Lead 
    **/
    public Lead setProgram(Lead objLead) {
        System.debug('objLead.nm_Program__c--->'+objLead.nm_Program__c);
        System.debug('specila--->'+ mapOfProgramIdVsProgram.keyset());
        List<nm_Program__c> lstAllProgram = getlstAllProgram();
        if (lstAllProgram.size() > 0 && mapOfProgramIdVsProgram.containsKey(objLead.nm_Program__c)) {
            objLead.Program_Type__c = mapOfProgramIdVsProgram.get(objLead.nm_Program__c).Specialisation__c;
            objLead.nm_ChooseaProgram__c = mapOfProgramIdVsProgram.get(objLead.nm_Program__c).nm_Type__c;
        }
        return objLead;
    }

  /*  public void Update_Session_Year(List<Lead> lstLead){
        // list of active calendars   
        List<Calender__c> lstActiveCalender = lstCalender(true);
        if(lstActiveCalender.size() > 0){
            for(Lead objLead : lstLead){
                if(!objLead.nm_IsRegistrationFeePaid__c) {
                    for(Calender__c objCal : lstActiveCalender){
                        if('Executive Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) && 'Executive Programs'.equalsIgnoreCase(objCal.nm_Type__c)){
                            objLead.nm_Session__c = objCal.Session__c;
                            objLead.nm_Year__c = objCal.Year__c;
                            break;
                        }
                        else if('Master Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) && 'Master Programs'.equalsIgnoreCase(objCal.nm_Type__c) &&  objLead.Program_Type__c!=null && objLead.Program_Type__c.equalsIgnoreCase(objCal.Specialisation__c)){
                            System.debug('objCal.Session__c in Master Programs'+objCal.Session__c +' '+'objCal.Year__c '+objCal.Year__c);
                            objLead.nm_Session__c = objCal.Session__c;
                            objLead.nm_Year__c = objCal.Year__c;
                            break;
                        }else if('Certificate Programs'.equalsIgnoreCase(objLead.nm_ChooseaProgram__c) && 'Certificate Programs'.equalsIgnoreCase(objCal.nm_Type__c)){
                            objLead.nm_Session__c = objCal.Session__c;
                            objLead.nm_Year__c = objCal.Year__c;
                            break;
                        }
                        else if(IsNullOrEmpty(objCal.nm_Type__c))
                        {   System.debug('objCal.Session__c else part '+objCal.Session__c +' '+'objCal.Year__c '+objCal.Year__c);
                            objLead.nm_Session__c = objCal.Session__c;
                            objLead.nm_Year__c = objCal.Year__c;
                        }
                    }
                }
            }
        }
    }*/
    
    public void Update_Session_Year(List<Lead> lstLead){
        // list of active calendars  
        List<Calender__c> lstCalender = getlstCalender();
        if(lstCalender.size() > 0){
            for(Lead objLead : lstLead){
                if(!objLead.nm_IsRegistrationFeePaid__c && !mapOfChoosePrgTypevsSessionYear.isEmpty() && !objLead.IsConverted) {
                    String mapKey = objLead.nm_ChooseaProgram__c;
                    if(objLead.Program_Type__c != null && objLead.Program_Type__c != '') {
                        mapKey = objLead.nm_ChooseaProgram__c + '-' + objLead.Program_Type__c;
                    }
                    if(objLead.nm_ChooseaProgram__c!=null && mapOfChoosePrgTypevsSessionYear.containskey(mapKey) ){
                        objLead.nm_Session__c = mapOfChoosePrgTypevsSessionYear.get(mapKey).substring(0, mapOfChoosePrgTypevsSessionYear.get(mapKey).indexOf('_'));
                        objLead.nm_Year__c =  Integer.valueOf(mapOfChoosePrgTypevsSessionYear.get(mapKey).right(4));
                        break;
                    }  
                    else if(mapOfChoosePrgTypevsSessionYear.containsKey('All'))
                    {  
                        objLead.nm_Session__c = mapOfChoosePrgTypevsSessionYear.get('All').substring(0, mapOfChoosePrgTypevsSessionYear.get('All').indexOf('_')); 
                        objLead.nm_Year__c = Integer.valueOf(mapOfChoosePrgTypevsSessionYear.get('All').right(4));
                    }
                }
            }
        }
    }
    
    /**
    * @description 
    * @author @BK | 03-04-2024 
    * @param list<Lead> lstlead 
    **/
    public void splitLeadName(list<Lead> lstlead){
        for(Lead objLead : lstLead){
            if(objLead.LeadSource=='Web'){
                if(IsNullOrEmpty(objLead.FirstName)){
                    objLead = splitFullName(objLead);
                }
            }
            
            if(IsNullOrEmpty(objLead.nm_PlantoStart__c)){
                objLead.nm_PlantoStart__c = '0-1 week';
            }
        }
    }

    /**
    * @description 
    * @author @BK | 03-04-2024 
    * @param Lead objLead 
    * @return Lead 
    **/
    public Lead splitFullName(Lead objLead) {
        List<String> lstLeadName = objLead.LastName.split(' ');
        if(lstLeadName.size() > 0){
            if(lstLeadName.size() < 2){
                objLead.FirstName = lstLeadName[0];
               // objLead.nm_MiddleName__c = ''; 
                objLead.LastName='.';
            } else if(lstLeadName.size() < 3){
                objLead.FirstName = lstLeadName[0];
              //  objLead.nm_MiddleName__c = ''; 
                objLead.LastName = lstLeadName[1];
            } else {
                objLead.FirstName = lstLeadName[0];
              //  objLead.nm_MiddleName__c = lstLeadName[1]; 
                objLead.LastName = lstLeadName[2];
            }
        }
        return objLead;
    }
    
    // if AEP Create Lead through his login then based upon AEP UserId update nm_InfromationCenter__c on Lead
    public void ICAutoSelection (list<Lead> lstlead){
        Map<String,String> mapOfUserIdVsCenterId = getMapOfUserIdVsCenterId();
        for(Lead objLead : lstLead){
             System.debug('ICAutoselect Lead--'+objLead.nm_InformationCenter__c +'----OwnerId---'+objLead.OwnerId);
            System.debug('mapOfUserIdVsCenterId---'+mapOfUserIdVsCenterId.containsKey(objLead.OwnerId));
            if(objLead.nm_InformationCenter__c == null && (objLead.nm_SelectedIC__c == null || objLead.nm_SelectedIC__c  =='')){// added check to avoid setting LeadOwner while inserting records from DataLoader
                if(mapOfUserIdVsCenterId.containsKey(objLead.OwnerId)){
                    objLead.nm_InformationCenter__c = mapOfUserIdVsCenterId.get(objLead.OwnerId);
                }
            }
        }
    }
  /*  public void UpdateLeadOwnerAndICEmailOnLead(List<Lead> lstlead, Map<id,Lead> oldMap,string activity){

         set<id> setofLeadid = new set<id> ();
          for(Lead objlead : lstlead){
                if(oldMap !=null && objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c && activity=='Update'){
                    setofLeadid.add(objlead.id);
                    system.debug('Ic change for update ');
                } else {
                    if(objLead.nm_InformationCenter__c != null && activity=='Insert' ){
                        setofLeadid.add(objlead.id);
                          system.debug('Ic change for insert');
                    }
                } 
          }
          if(setofLeadid.size()>0){
              
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            Map<String,String> mapOfUserIdVsCenterId = getMapOfUserIdVsCenterId();
            Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
          
        for(Lead objlead : lstlead){
            if(oldMap !=null){
                if(objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c){
                    
                   // lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                  //  if(lstUserMapping.size()>0)
                    // objLead.OwnerId = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__c;
                    objLead.OwnerId = mapOfCenterIdVsCenterUserMappinghead.containsKey(objLead.nm_InformationCenter__c) ? mapOfCenterIdVsCenterUserMappinghead.get(objLead.nm_InformationCenter__c).nm_user__c : mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__c;
                    objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                    system.debug('objLead.OwnerId--->'+objLead.OwnerId);
                    if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                        String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                        if(!IsNullOrEmpty(LearningCenterId)){
                            if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                                objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                            }
                        }else{
                            objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                        }
                    }
                }
            }else{
                if(objLead.nm_InformationCenter__c != null){
                    if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                    objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                        String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                        if(!IsNullOrEmpty(LearningCenterId)){
                            if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                                objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                            }
                        }else if(mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c) !=null){
                            objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                        }
                    }
                }
            }
        }
      }
    }*/
    public String AssignUser (List<nm_UserMapping__c>lstUserMapping ,String ChooseProgram ){
        List<nm_UserMapping__c> lstUserMapping2 = new List<nm_UserMapping__c>();
        List<nm_UserMapping__c> lstUserMappingNoProgramOffer = new List<nm_UserMapping__c>();
        Map<Integer,id> mapOfRoundRobinIds =new map<Integer,id>();
        Map<String,List<nm_UserMapping__c>> mapProgramAndUser = new Map<String,List<nm_UserMapping__c>>();
        Integer maxnumber;
        String centerOwnerId = null;
        String DefaultOwner;
        String centerHead = null;
        String Uid = UserInfo.getUserId();
        boolean internaluser = false;

    
        if (lstUserMapping != null && lstUserMapping.size() > 0) 
        {
            for (nm_UserMapping__c obj: lstUserMapping) 
            {
                System.debug('Uid--->'+Uid+'user-->'+obj.nm_user__c);

                if (Uid==obj.nm_user__c){
                     centerOwnerId = Uid;
                     internaluser= true;
                     System.debug('centerOwnerId--->'+centerOwnerId);
                     break;
                    // return centerOwnerId;
                }                         
               System.debug('centerOwnerId--->'+centerOwnerId);
               System.debug('Uid--->'+Uid);
                if(obj.nm_ChooseaProgram__c!=null && centerOwnerId==null)
                {
                    for(string program : obj.nm_ChooseaProgram__c.split(';'))
                    {
                        if(!mapProgramAndUser.containsKey(program))
                        {
                            mapProgramAndUser.put(program,new List<nm_UserMapping__c>());
                            mapProgramAndUser.get(program).add(obj);            
                        }else
                        {
                            mapProgramAndUser.get(program).add(obj);            
                        }                
                    }
                }else if(obj.nm_ChooseaProgram__c==null && centerOwnerId==null)
                {
                    lstUserMappingNoProgramOffer.add(obj);
                }
                if(obj.nm_Head__c)
                {
                    centerHead = obj.nm_user__c;
                }
                    DefaultOwner = obj.nm_user__c;    
            }
                system.debug('mapProgramAndUser-->'+mapProgramAndUser);
                if(!mapProgramAndUser.IsEmpty() && mapProgramAndUser.containsKey(ChooseProgram) && !internaluser)
                {
                    lstUserMapping2 = mapProgramAndUser.get(ChooseProgram);
                }else if(lstUserMappingNoProgramOffer.size()>1 && centerOwnerId==null && centerHead==null)
                {
                    lstUserMapping2 = lstUserMappingNoProgramOffer;
                }
                system.debug('lstUserMapping2-->'+lstUserMapping2);
                if (lstUserMapping2 != null && lstUserMapping2.size() > 1) {
                    Integer i = 0;
                    for(nm_UserMapping__c obj:lstUserMapping2 ){
                        MapOfRoundRobinIds.put(i,obj.nm_user__r.id);
                        System.debug(i+'------'+obj.nm_user__r.Name);   
                        i++;
                    }
                    maxnumber =  (Integer)Math.floor(100 + Math.random()*90);
                    System.debug('User Number Round Robin--'+math.mod(integer.valueOf(maxnumber),lstUserMapping2.size()));
                    Integer mod = (integer)(math.mod(integer.valueOf(maxnumber),lstUserMapping2.size()));
                    centerOwnerId = MapOfRoundRobinIds.get(mod);
                    System.debug('OwnerId--->'+centerOwnerId);           
                }else
                {
                    centerOwnerId = lstUserMapping2!=null && lstUserMapping2.size()>0?lstUserMapping2[0].nm_user__c:centerOwnerId;
                }
    
            
            centerHead = centerHead!=null?centerHead:DefaultOwner;
            centerOwnerId = centerOwnerId!=null?centerOwnerId:centerHead;
            System.debug('OwnerId--->'+centerOwnerId);           

         //  return centerOwnerId;
        }
        return centerOwnerId;
    }

    /*public void UpdateLeadOwnerAndICEmailOnLead(List<Lead> lstlead, Map<id,Lead> oldMap,string activity){

        set<id> setofLeadid = new set<id> ();
        set<id> setofCPLeadid = new set<id> ();

         for(Lead objlead : lstlead){
               if(oldMap !=null && objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c && activity=='Update'){
                   setofLeadid.add(objlead.id);
                   system.debug('Ic change for update ');
               } else if(activity=='Insert') {
                   if(objLead.nm_InformationCenter__c != null && activity=='Insert' ){
                       setofLeadid.add(objlead.id);
                         system.debug('Ic change for insert');
                   }
               }else if(oldMap !=null && objLead.Counselor_Profile__c != null && objLead.Counselor_Profile__c != oldMap.get(objLead.id).Counselor_Profile__c  ){                                            
                      setofLeadid.add(objlead.id);
                       system.debug('CP change for insert');

               }
         }
         if(setofLeadid.size()>0){
             
           Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
           Map<String,String> mapOfUserIdVsCenterId = getMapOfUserIdVsCenterId();
           Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
           Map<id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = getMapAllCounsellor();

         
       for(Lead objlead : lstlead){
           if(oldMap !=null){
               if(objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c){
                   
                   objLead.OwnerId = mapOfCenterIdVsCenterUserMappinghead.containsKey(objLead.nm_InformationCenter__c) ? mapOfCenterIdVsCenterUserMappinghead.get(objLead.nm_InformationCenter__c).nm_user__c : mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__c;
                   objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                   system.debug('objLead.OwnerId--->'+objLead.OwnerId);
                   if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                       String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                       if(!IsNullOrEmpty(LearningCenterId)){
                           if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                               objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                           }
                       }else{
                           objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                       }
                   }
               }else if(objLead.Counselor_Profile__c != null && objLead.Counselor_Profile__c != oldMap.get(objLead.id).Counselor_Profile__c && objLead.nm_InformationCenter__c== mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c){
                   objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;
                   
               }
           }else{
               if(objLead.nm_InformationCenter__c != null){
                   if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                      objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                       String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                       if(!IsNullOrEmpty(LearningCenterId)){
                           if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                               objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                           }
                       }else if(mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c) !=null){
                           objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                       }
                   }
               }
           }
       }
     }
   }*/
   
 /* Commented by Phalguni 03032023
   public void UpdateLeadOwnerAndICEmailOnLead(List<Lead> lstlead, Map<id,Lead> oldMap,string activity)
   {
       set<id> setofLeadid = new set<id> ();
       List<nm_UserMapping__c> lstALLUserMapping = new List<nm_UserMapping__c>();

       String centerHead ;
       
        for(Lead objlead : lstlead){
              if(oldMap !=null && objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c && activity=='Update'){
                  setofLeadid.add(objlead.id);
                  system.debug('Ic change for update ');
              } else if(activity =='Insert') {
                  if(objLead.nm_InformationCenter__c != null && activity=='Insert' ){
                      setofLeadid.add(objlead.id);
                        system.debug('Ic change for insert');
                  }
              }else if(oldMap !=null && objLead.Counselor_Profile__c != null && objLead.Counselor_Profile__c != oldMap.get(objLead.id).Counselor_Profile__c  ){                                            
                  //objlead.CP_Change_Date__c=System.now();//added by swati on 2/12/22   
                  setofLeadid.add(objlead.id);
                      system.debug('CP change for insert');

              }
        }
        if(setofLeadid.size()>0){
            
          Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
          Map<String,String> mapOfUserIdVsCenterId = getMapOfUserIdVsCenterId();
          Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
          Map<id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = getMapAllCounsellor();

        
      for(Lead objlead : lstlead){
          if(oldMap !=null){
              if(objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c){
                   objLead.CP_Change_Date__c=null;             
                  lstALLUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                  
                  if(objLead.Counselor_Profile__c != null
                  && mapOfCounseloridVsCounselorProfile.containsKey(objLead.Counselor_Profile__c)
                  && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c
                  && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).UserIsActive__c
                  && (mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).nm_ChooseaProgram__c!=null && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)))
                  {
                      System.debug('RE-assign counselor'+objLead.Counselor_Profile__c);
                        objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;                        
                  }                
                  else if(objLead.Counselor_Profile__c != null
                  && mapOfCounseloridVsCounselorProfile.containsKey(objLead.Counselor_Profile__c)
                  && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c
                  && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).UserIsActive__c)
                  
                  {
                      System.debug('RE-assign counselor'+objLead.Counselor_Profile__c);
                        objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;                        
                  }                
                  else if(lstALLUserMapping!=null && lstALLUserMapping.size()>1)
                  {
                       objLead.OwnerId = AssignUser(lstALLUserMapping,objLead.nm_ChooseaProgram__c );
                  }else
                  {
                      objLead.OwnerId = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__c;
                  }
                                     
                  objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                  system.debug('objLead.OwnerId--->'+objLead.OwnerId);
                 objLead.Prior_Information_Center__c = mapOfCenterIdVsCenter.containskey(oldMap.get(objLead.id).nm_InformationCenter__c)?mapOfCenterIdVsCenter.get(oldMap.get(objLead.id).nm_InformationCenter__c).Name:'';

                  
                  if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                      String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                      if(!IsNullOrEmpty(LearningCenterId)){
                          if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                              objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                          }
                      }else{
                          objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                      }
                  }
              }else if((objLead.Counselor_Profile__c != null && objLead.Counselor_Profile__c != oldMap.get(objLead.id).Counselor_Profile__c)
               &&   objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c){
                      objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;
                         if(objLead.nm_InformationCenter__c ==oldMap.get(objLead.id).nm_InformationCenter__c)
                   {
                      objLead.CP_Change_Date__c=System.now();//added by swati on 2/12/22
                   }
                   
                  
              }
               }else{
                  if(objLead.nm_InformationCenter__c != null){
                      if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                         objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                          String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                          if(!IsNullOrEmpty(LearningCenterId)){
                              if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                                  objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                              }
                          }else if(mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c) !=null){
                              objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                           }
                           if(objLead.Counselor_Profile__c != null && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c ){
                                objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;
       
                                system.debug('objLead.OwnerId--->'+objLead.OwnerId);
                            }
                       }
                   }
               }
           }
       }
    
   }*/
   public void UpdateLeadOwnerAndICEmailOnLead(List<Lead> lstlead, Map<id,Lead> oldMap,string activity)
   {
       set<id> setofLeadid = new set<id> ();
       set<id> setofLeadidStatus = new set<id> ();
       List<nm_UserMapping__c> lstALLUserMapping = new List<nm_UserMapping__c>();

       String centerHead ;
       
        for(Lead objlead : lstlead){
              if(oldMap !=null && objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c && activity=='Update'){
                  setofLeadid.add(objlead.id);
                  system.debug('Ic change for update ');
              } else if(activity =='Insert') {
                  if(objLead.nm_InformationCenter__c != null && activity=='Insert' ){
                      setofLeadid.add(objlead.id);
                        system.debug('Ic change for insert');
                  }
              }else if(oldMap !=null && objLead.Counselor_Profile__c != null && objLead.Counselor_Profile__c != oldMap.get(objLead.id).Counselor_Profile__c  ){                                            
                  //objlead.CP_Change_Date__c=System.now();//added by swati on 2/12/22   
                  setofLeadid.add(objlead.id);
                      system.debug('CP change for insert');

              }
               if ( oldMap !=null && activity=='Update'
              && !IsNullOrEmpty(objLead.Status) && objLead.Status != oldMap.get(objLead.id).Status            
               ) {
                setofLeadidStatus.add(objlead.id);
                 system.debug('Status change for update');
            }
        }
        if(setofLeadid.size()>0 || setofLeadidStatus.size()>0 ){
            
            
          Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
          Map<String,String> mapOfUserIdVsCenterId = getMapOfUserIdVsCenterId();
          Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
          Map<id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = getMapAllCounsellor();

      if(setofLeadid.size()>0) {
      for(Lead objlead : lstlead){
          if(oldMap !=null){
              if(objLead.nm_InformationCenter__c != null && objLead.nm_InformationCenter__c != oldMap.get(objLead.id).nm_InformationCenter__c){
                   objLead.CP_Change_Date__c=null;             
                  lstALLUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                  
                  if(objLead.Counselor_Profile__c != null
                  && mapOfCounseloridVsCounselorProfile.containsKey(objLead.Counselor_Profile__c)
                  && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c
                  && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).UserIsActive__c
                  && (mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).nm_ChooseaProgram__c!=null && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)))
                  {
                      System.debug('RE-assign counselor'+objLead.Counselor_Profile__c);
                        objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;                        
                  }                
                  else if(objLead.Counselor_Profile__c != null
                  && mapOfCounseloridVsCounselorProfile.containsKey(objLead.Counselor_Profile__c)
                  && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c
                  && mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).UserIsActive__c)
                  
                  {
                      System.debug('RE-assign counselor'+objLead.Counselor_Profile__c);
                        objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;                        
                  }                
                  else if(lstALLUserMapping!=null && lstALLUserMapping.size()>1)
                  {
                       objLead.OwnerId = AssignUser(lstALLUserMapping,objLead.nm_ChooseaProgram__c );
                  }else
                  {
                      objLead.OwnerId = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__c;
                  }
                                     
                  objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                  system.debug('objLead.OwnerId--->'+objLead.OwnerId);
                 objLead.Prior_Information_Center__c = mapOfCenterIdVsCenter.containskey(oldMap.get(objLead.id).nm_InformationCenter__c)?mapOfCenterIdVsCenter.get(oldMap.get(objLead.id).nm_InformationCenter__c).Name:'';

                  
                  if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                      String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                      if(!IsNullOrEmpty(LearningCenterId)){
                          if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                              objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                          }
                      }else{
                          objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                      }
                  }
              }else if((objLead.Counselor_Profile__c != null && objLead.Counselor_Profile__c != oldMap.get(objLead.id).Counselor_Profile__c)
               &&   objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c){
                      objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;
                         if(objLead.nm_InformationCenter__c ==oldMap.get(objLead.id).nm_InformationCenter__c)
                   {
                      objLead.CP_Change_Date__c=System.now();//added by swati on 2/12/22
                   }
                   
                  
              }
               }else{
                  if(objLead.nm_InformationCenter__c != null){
                      if(mapOfCenterIdVsCenter.containsKey(objLead.nm_InformationCenter__c)){
                         objLead.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).AEP_email_id__c; 
                          String LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                          if(!IsNullOrEmpty(LearningCenterId)){
                              if(mapOfCenterIdVsCenterUserMapping.containsKey(LearningCenterId)){
                                  objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(LearningCenterId)[0].nm_user__r.Email;
                              }
                          }else if(mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c) !=null){
                              objLead.nm_LCEmailID__c = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c)[0].nm_user__r.Email;
                           }
                           if(objLead.Counselor_Profile__c != null && objLead.nm_InformationCenter__c == mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).AEP_Name__c ){
                                objLead.OwnerId = mapOfCounseloridVsCounselorProfile.get(objLead.Counselor_Profile__c).OwnerId;
       
                                system.debug('objLead.OwnerId--->'+objLead.OwnerId);
                            }
                       }
                   }
               }
           }
        }
         if(setofLeadidStatus.size()>0)
       {
            
            set<String> leadStatusOfLabel = new Set<String>(new List<String>(System.Label.Transfer_Lead_To_LC.split(',')));       
            Set<String> profileName = new Set<String>{'Information Center Partner Community User', 'pp profile'};
            Set<String> setOfProfileIdAllowed = new Set<String>();
            for (Profile objProfile : [SELECT Id, Name FROM Profile WHERE Name IN :profileName ]) {
                setOfProfileIdAllowed.add(objProfile.Id);
                }
            for (Lead objlead : lstlead)
            {
              String  LearningCenterId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).nm_LearningCenter__c;
                LearningCenterId = IsNullOrEmpty(LearningCenterId)? objLead.nm_InformationCenter__c : LearningCenterId;

                if(leadStatusOfLabel.size()>0 && leadStatusOfLabel.contains(objLead.Status) && 
                !IsNullOrEmpty(LearningCenterId) && objlead.LeadSource=='Web'
                && setOfProfileIdAllowed.contains(UserInfo.getProfileId()))
                {
                  objLead.nm_InformationCenter__c = LearningCenterId;
                  objLead.OwnerId = mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).OwnerId;
                }
          }
       }
     }      
   }
          
    //update Lead semester for Lateral Student Based upon Program Completed previously
   /* public void UpdateLeadSemester(List<Lead> lstLead , Map<Id,Lead> oldMap){
        Map<String,nm_StudentProgram__c> mapOfStudentNoVsProgramCompletedStudentPrg = getMapOfStudentNoVsProgramCompletedStudentProgram(lstLead);
        for(Lead objLead : lstLead){
            if(objLead.Student_Number_Lateral__c !=null && objLead.Is_Lateral__c){ 
            
                if(mapOfStudentNoVsProgramCompletedStudentPrg.containsKey(objLead.Student_Number_Lateral__c)){
                    nm_StudentProgram__c objStudentProgram = mapOfStudentNoVsProgramCompletedStudentPrg.get(objLead.Student_Number_Lateral__c);
                    system.debug('objStudentProgram.nm_Program__r.nm_Type__c--->'+objStudentProgram.nm_Program__r.nm_Type__c);
                        system.debug('objStudentProgram.nm_Program__r.nm_ProgramName__c--->'+objStudentProgram.nm_Program__r.nm_ProgramName__c);
                    if(objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c){
                    System.debug('oldMap --->'+oldMap );
                        if(objLead.nm_ChooseaProgram__c.startsWith('Certificate') && objStudentProgram.nm_Program__r.nm_Type__c == 'Certificate Programs' ){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c && objStudentProgram.nm_Program__r.nm_Type__c == 'Diploma Programs' && objStudentProgram.nm_Program__r.nm_ProgramName__c != 'Diploma in General Management'){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c && (objStudentProgram.nm_Program__r.nm_Type__c == 'Post Graduate Diploma Programs' || objStudentProgram.nm_Program__r.nm_ProgramName__c == 'Diploma in General Management')){
                            objLead.nm_Semester__c = '3';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }
                    }else{
                    system.debug('objStudentProgram.nm_Program__r.nm_Type__c--->'+objStudentProgram.nm_Program__r.nm_Type__c);
                        system.debug('objStudentProgram.nm_Program__r.nm_ProgramName__c--->'+objStudentProgram.nm_Program__r.nm_ProgramName__c);
                        if(objLead.nm_ChooseaProgram__c.startsWith('Certificate') && objStudentProgram.nm_Program__r.nm_Type__c == 'Certificate Programs' ){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && objStudentProgram.nm_Program__r.nm_Type__c == 'Diploma Programs' && objStudentProgram.nm_Program__r.nm_ProgramName__c != 'Diploma in General Management'){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && (objStudentProgram.nm_Program__r.nm_Type__c == 'Post Graduate Diploma Programs' || objStudentProgram.nm_Program__r.nm_ProgramName__c == 'Diploma in General Management')){
                            objLead.nm_Semester__c = '3';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }
                    }
                }
            }
        }
    }*/
    //update Lead semester for Lateral Student Based upon Program Completed previously
  /*  public void UpdateLeadSemester(List<Lead> lstLead , Map<Id,Lead> oldMap){
        Map<String,nm_StudentProgram__c> mapOfStudentNoVsProgramCompletedStudentPrg = getMapOfStudentNoVsProgramCompletedStudentProgram(lstLead);
        for(Lead objLead : lstLead){
            if(objLead.Student_Number_Lateral__c !=null && objLead.Is_Lateral__c){ 
            
                if(mapOfStudentNoVsProgramCompletedStudentPrg.containsKey(objLead.Student_Number_Lateral__c)){
                    nm_StudentProgram__c objStudentProgram = mapOfStudentNoVsProgramCompletedStudentPrg.get(objLead.Student_Number_Lateral__c);
                    system.debug('objStudentProgram.nm_Program__r.nm_Type__c--->'+objStudentProgram.nm_Program__r.nm_Type__c);
                        system.debug('objStudentProgram.nm_Program__r.nm_ProgramName__c--->'+objStudentProgram.nm_Program__r.nm_ProgramName__c);
                    if(objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c){
                    System.debug('oldMap --->'+oldMap );
                        if(objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objStudentProgram.nm_Program__r.nm_Type__c == 'Diploma Programs' ){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c && objStudentProgram.nm_Program__r.nm_Type__c == 'Diploma Programs' && objStudentProgram.nm_Program__r.nm_ProgramName__c != 'Diploma in General Management'){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c && (objStudentProgram.nm_Program__r.nm_Type__c == 'Post Graduate Diploma Programs' || objStudentProgram.nm_Program__r.nm_ProgramName__c == 'Diploma in General Management')){
                            objLead.nm_Semester__c = '3';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }
                    }else{
                    system.debug('objStudentProgram.nm_Program__r.nm_Type__c--->'+objStudentProgram.nm_Program__r.nm_Type__c);
                        system.debug('objStudentProgram.nm_Program__r.nm_ProgramName__c--->'+objStudentProgram.nm_Program__r.nm_ProgramName__c);
                        if(objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objStudentProgram.nm_Program__r.nm_Type__c == 'Diploma Programs' ){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && objStudentProgram.nm_Program__r.nm_Type__c == 'Diploma Programs' && objStudentProgram.nm_Program__r.nm_ProgramName__c != 'Diploma in General Management'){
                            objLead.nm_Semester__c = '2';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }else if(objLead.nm_ChooseaProgram__c.startsWith('Post') && (objStudentProgram.nm_Program__r.nm_Type__c == 'Post Graduate Diploma Programs' || objStudentProgram.nm_Program__r.nm_ProgramName__c == 'Diploma in General Management')){
                            objLead.nm_Semester__c = '3';
                            objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
                        }
                    }
                }
            }
        }
    }*/
    
       //update Lead semester for Lateral Student Based upon Program Completed previously
    // public void UpdateLeadSemester(List<Lead> lstLead , Map<Id,Lead> oldMap){
    //     Map<String,Account> mapOfStudentNoVsProgramCompletedAccounts =  getMapOfStudentNoVsProgramCompletedAccounts(lstLead);
    //    /* Map<String, String> mapOfCenterNameVsId = new Map<String, String>();
    //     Set<String> setOfProfileIdAllowed = new set<String>();
    //     for (nm_Centers__c objCen : [SELECT Id, Name FROM nm_Centers__c WHERE RecordType.Name = 'Learning Center']) {
    //         mapOfCenterNameVsId.put(objCen.Name, objCen.Id);
    //     }
    //     Set<String> profileName = new Set<String>{'Information Center Partner Community User', 'pp profile'};
    //     for (Profile objProfile : [SELECT Id, Name FROM Profile WHERE Name IN :profileName ]) {
    //         setOfProfileIdAllowed.add(objProfile.Id);
    //     }
    //     List<Lead> lstLeadToTranserToLC = new List<Lead>();
    //     Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();*/
    //     for(Lead objLead : lstLead){
    //         if(objLead.Student_Number_Lateral__c !=null  && objLead.Is_Lateral__c 
    //         ){ 
            
    //             if(mapOfStudentNoVsProgramCompletedAccounts.containsKey(objLead.Student_Number_Lateral__c)){
    //                 Account objStudentProgram = mapOfStudentNoVsProgramCompletedAccounts.get(objLead.Student_Number_Lateral__c);
    //                     system.debug('objStudentProgram.Current_semester__c--->'+objStudentProgram.Current_semester__c);
    //                     system.debug('objStudentProgram.nm_Program__r.Name--->'+objStudentProgram.nm_Program__r.Name);
    //                     system.debug('objLead.nm_Program__c--->'+objLead.nm_ProgramName__c);

    //                 if(oldMap != null && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c ){
    //                 System.debug('oldMap --->'+oldMap );
    //                     if(objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objStudentProgram.nm_ChooseaProgram__c == 'Diploma Programs'){
    //                         objLead.nm_Semester__c = '2';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if((objLead.nm_ChooseaProgram__c.startsWith('Diploma') || objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') || (objLead.nm_ChooseaProgram__c.contains('Master Programs') && objLead.Program_Type__c == 'MBA')) 
    //                     && objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'CBM' && objStudentProgram.BatchStartD__c > date.newinstance(2019,01,01)){
    //                         objLead.nm_Semester__c = '2';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     else if((objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') || (objLead.nm_ChooseaProgram__c.contains('Master Programs') && objLead.Program_Type__c == 'MBA')) 
    //                     && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c && objStudentProgram.nm_ChooseaProgram__c == 'Diploma Programs'){
    //                         if(objStudentProgram.nm_Program__r.Name == 'DBM' && objStudentProgram.BatchStartD__c > date.newinstance(2019,01,01)) {
    //                             system.debug('objStudentProgram.BatchStartD__c-->'+objStudentProgram.BatchStartD__c);
    //                             objLead.nm_Semester__c = '3';
    //                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                         }else{
    //                             objLead.nm_Semester__c = '2';
    //                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                         }
    //                     }
    //                     /*else if(objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') && objLead.nm_ChooseaProgram__c != oldMap.get(objLead.id).nm_ChooseaProgram__c && (objStudentProgram.nm_ChooseaProgram__c == 'Post Graduate Diploma Programs' || objStudentProgram.nm_Program__r.Name == 'DGM')){
    //                         objLead.nm_Semester__c = '3';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 2') || objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4'))&& (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 1')){
    //                         objLead.nm_Semester__c = '2';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4'))&& (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 2')){
    //                         objLead.nm_Semester__c = '3';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if(objLead.nm_ChooseaProgram__c.startsWith('Professional Programs') &&  objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 3')){
    //                         objLead.nm_Semester__c = '4';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }*/
    //                     //PCDM to PDDM lateral Admission
    //                     else if(objLead.nm_ChooseaProgram__c.startsWith('Professional Programs') && objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 3')){
    //                         objLead.nm_Semester__c = String.valueof(Integer.valueof(objStudentProgram.Current_semester__c) + 1) ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-SEM & SMM to PDDM,PCDM lateral Admission
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4')) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SEM & SMM')){
    //                         objLead.nm_Semester__c = String.valueof(objStudentProgram.Current_semester__c+ 1) ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-SEM & DMA to PDDM,PCDM lateral Admission, it will be default 2
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4')) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SEM & DMA')){
    //                         objLead.nm_Semester__c = '2' ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-SMM & DMA to PDDM,PCDM lateral Admission, it will be default 1
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4')) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SMM & DMA')){
    //                         objLead.nm_Semester__c = '1' ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-SEM to PDDM,PCDM, C-SEM lateral Admission, it will be default 2
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c.contains('Certificate in Search Engine Marketing') ) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SEM')){
    //                         objLead.nm_Semester__c = '2' ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-DMA to PDDM,PCDM, C-DMA lateral Admission, it will be default 1
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c.contains('Certificate in Digital Marketing Analytics') ) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-DMA')){
    //                         objLead.nm_Semester__c = '1' ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-SMM to PDDM,PCDM, C-SEM & SMM lateral Admission, it will be default 1
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c=='Certificate in Search Engine Marketing & Certificate in Social Media and Content Marketing') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SMM')){
    //                         objLead.nm_Semester__c = '1' ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     //C-SMM to PDDM,PCDM, C-SMM & DMA lateral Admission, it will be default 2
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c=='Certificate in Social Media and Content Marketing & Certificate in Digital Marketing Analytics') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SMM')){
    //                         objLead.nm_Semester__c = '2' ;
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     else {
    //                         objLead.nm_Semester__c = '1';
    //                         objLead.Lead_Lateral_Catogery__c = 'Admission';
    //                     }
    //                 }else{
    //                     system.debug('objStudentProgram.nm_FeesPaidofSemester__c--->'+objStudentProgram.nm_ChooseaProgram__c);
    //                     system.debug('objStudentProgram.nm_Program__r.Name--->'+objStudentProgram.nm_Program__r.Name);
    //                     if(objLead.nm_ChooseaProgram__c.startsWith('Diploma') && objStudentProgram.nm_ChooseaProgram__c == 'Diploma Programs' ){
    //                         objLead.nm_Semester__c = '2';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if((objLead.nm_ChooseaProgram__c.startsWith('Diploma') || objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') || (objLead.nm_ChooseaProgram__c.contains('Master Programs') && objLead.Program_Type__c == 'MBA')) 
    //                     && objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'CBM' && objStudentProgram.BatchStartD__c > date.newinstance(2019,01,01)){
    //                         objLead.nm_Semester__c = '2';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }
    //                     else if((objLead.nm_ChooseaProgram__c.contains('MBA (Distance) Programs') || (objLead.nm_ChooseaProgram__c.contains('Master Programs') 
    //                     && objLead.Program_Type__c == 'MBA')) && objStudentProgram.nm_ChooseaProgram__c == 'Diploma Programs' ){
    //                         if(objStudentProgram.nm_Program__r.Name == 'DBM' && objStudentProgram.BatchStartD__c>date.newinstance(2019,01,01)) {
    //                             system.debug('objStudentProgram.BatchStartD__c-->'+objStudentProgram.BatchStartD__c);
    //                             objLead.nm_Semester__c = '3';
    //                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                         }else{
    //                             objLead.nm_Semester__c = '2';
    //                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                         }
    //                     }
    //                     /*else if(objLead.nm_ChooseaProgram__c.startsWith('MBA (Distance) Programs') && (objStudentProgram.nm_ChooseaProgram__c == 'Post Graduate Diploma Programs' || objStudentProgram.nm_Program__r.Name == 'DGM')){
    //                         objLead.nm_Semester__c = '3';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs') )&& (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 2') || objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4'))&& (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 1')){
    //                         objLead.nm_Semester__c = '2';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4'))&& (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 2')){
    //                         objLead.nm_Semester__c = '3';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }else if(objLead.nm_ChooseaProgram__c.startsWith('Professional Programs') &&  objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 3')){
    //                         objLead.nm_Semester__c = '4';
    //                         objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                     }*/
    //                         //PCDM to PDDM lateral Admission
    //                     else if(objLead.nm_ChooseaProgram__c.startsWith('Professional Programs') && objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Specialisation__c == 'Certificate Term 3')){
    //                                              objLead.nm_Semester__c = String.valueof(Integer.valueof(objStudentProgram.Current_semester__c) + 1) ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                    //C-SEM & SMM to PDDM,PCDM lateral Admission
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4')) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SEM & SMM')){
    //                                             objLead.nm_Semester__c = String.valueof(Integer.valueof(objStudentProgram.Current_semester__c) + 1);
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                    //C-SEM & DMA to PDDM,PCDM lateral Admission, it will be default 2
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4')) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SEM & DMA')){
    //                                             objLead.nm_Semester__c = '2' ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                    //C-SMM & DMA to PDDM,PCDM lateral Admission, it will be default 1
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4')) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SMM & DMA')){
    //                                             objLead.nm_Semester__c = '1' ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                     //C-SEM to PDDM,PCDM, C-SEM lateral Admission, it will be default 2
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c.contains('Certificate in Search Engine Marketing') ) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SEM')){
    //                                             objLead.nm_Semester__c = '2' ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                     //C-DMA to PDDM,PCDM, C-DMA lateral Admission, it will be default 1
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c.contains('Certificate in Digital Marketing Analytics') ) && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-DMA')){
    //                                             objLead.nm_Semester__c = '1' ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                     //C-SMM to PDDM,PCDM, C-SEM & SMM lateral Admission, it will be default 1
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c=='Certificate in Search Engine Marketing & Certificate in Social Media and Content Marketing') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SMM')){
                                
    //                                              objLead.nm_Semester__c = '1' ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
    //                     //C-SMM to PDDM,PCDM, C-SMM & DMA lateral Admission, it will be default 2
    //                     else if((objLead.nm_ChooseaProgram__c.startsWith('Certificate Programs') || objLead.nm_ChooseaProgram__c.startsWith('Professional Programs')) && (objLead.Program_Type__c.equalsIgnoreCase('Certificate Term 3') || objLead.Program_Type__c.equalsIgnoreCase('Professional Diploma Term 4') || objLead.nm_ProgramName__c=='Certificate in Social Media and Content Marketing & Certificate in Digital Marketing Analytics') && (objStudentProgram.nm_ChooseaProgram__c == 'Certificate Programs' && objStudentProgram.nm_Program__r.Name == 'C-SMM')){
                                
    //                                              objLead.nm_Semester__c = '2' ;
    //                                             objLead.Lead_Lateral_Catogery__c = 'Lateral Admission';
    //                                         }
                        
    //                     else{
    //                         objLead.nm_Semester__c = '1';
    //                         objLead.Lead_Lateral_Catogery__c = 'Admission';
    //                     }
    //                 }
    //             }
    //             else{
    //                     objLead.nm_Semester__c = '1';
    //                     objLead.Lead_Lateral_Catogery__c = 'Admission';
    //                 }
    //         }
    // }
    // }

    /**
    * @description 
        Create Unique Registration Number
        Registration No :- DriverMonth + DriveYear + TodayDate + RandomNumber 
        eg. Registration No : - 07 + 17 + 10 + 28728043
    * @author @BK | 21-12-2022 
    * @param lstLead 
    **/
    public void generateRegistrationNoOnLead(List<Lead> lstLead){
        // list of active calendars
        List<Calender__c> lstCalender = getlstCalender();
        Map<String,String> MapOFDupGeneratedRegNo = new Map<String,String>();
        System.debug('lstCalender--->'+lstCalender);
        if(lstCalender.size() > 0){
            String strPreRegistrationID = '';
            Map<String,Lead> mapOfRegistrationNoAndLead = new Map<String,Lead>();
            for( Lead objLead : lstLead ){
                String mapKey = objLead.nm_ChooseaProgram__c;
                if(objLead.Program_Type__c != null && objLead.Program_Type__c != '') {
                    mapKey = objLead.nm_ChooseaProgram__c + '-' + objLead.Program_Type__c;
                }
    
                if(objLead.nm_ChooseaProgram__c!=null && mapOfProgramTypeVsStrPreRegistrationId.containskey(mapKey) ){
                    strPreRegistrationID = mapOfProgramTypeVsStrPreRegistrationId.get(mapKey);
                    system.debug('strPreRegistrationID --->'+strPreRegistrationID );
                } else {
                    strPreRegistrationID = mapOfProgramTypeVsStrPreRegistrationId.get('All');
                    system.debug('strPreRegistrationID --->'+strPreRegistrationID );
                }
                String RegistrationNo = strPreRegistrationID + String.valueOf(System.now().millisecond()) + String.valueOf((Integer)Math.floor(100 + Math.random()*900));
                // call method to get Unique Registration Number
                String UniqueRegistratioNo = FindDuplicateRegistrationNo(RegistrationNo,strPreRegistrationID,mapOfRegistrationNoAndLead); 
                objLead.nm_RegistrationNo__c = UniqueRegistratioNo;
                objLead.nm_RegistrationID__c = strPreRegistrationID;
                mapOfRegistrationNoAndLead.put(objLead.nm_RegistrationNo__c,objLead);
            }
    
            if(!mapOfRegistrationNoAndLead.IsEmpty()) {
                // Check if Registration no already exists in the system.
                List<Lead> lstLeadDuplicatedRegNo = [SELECT id,nm_RegistrationNo__c,nm_RegistrationID__c FROM Lead WHERE nm_RegistrationNo__c IN :mapOfRegistrationNoAndLead.keySet()];
                if(lstLeadDuplicatedRegNo.size() > 0) {
                    for (Lead objDupLead : lstLeadDuplicatedRegNo) {
                        if(mapOfRegistrationNoAndLead.containsKey(objDupLead.nm_RegistrationNo__c)) {
                            Lead objld = mapOfRegistrationNoAndLead.get(objDupLead.nm_RegistrationNo__c);
                            String UniqueRegistratioNo = FindDuplicateRegistrationNo(objld.nm_RegistrationNo__c,objld.nm_RegistrationID__c,mapOfRegistrationNoAndLead); 
                            objld.nm_RegistrationNo__c = UniqueRegistratioNo;
                            mapOfRegistrationNoAndLead.put(objld.nm_RegistrationNo__c,objld);
                            MapOFDupGeneratedRegNo.put(objDupLead.nm_RegistrationNo__c,UniqueRegistratioNo);
                        }
                    }
    
                    for( Lead objLead : lstLead ){ 
                        if(MapOFDupGeneratedRegNo.containsKey(objLead.nm_RegistrationNo__c)) {
                            objLead.nm_RegistrationNo__c = MapOFDupGeneratedRegNo.get(objLead.nm_RegistrationNo__c);
                        }
                    }
                }
            }
        }
    }
    
    public String FindDuplicateRegistrationNo(String RegistrationNo,String strPreRegistrationID ,Map<String,Lead> mapOfRegistrationNoAndLead){//RegistrationNo is equal to strPreRegistrationID+randomNumber; 
        if(mapOfRegistrationNoAndLead.containsKey(RegistrationNo)){
            // if Duplicate RegistrationNo found then call same method by applying random function
            RegistrationNo = strPreRegistrationID + String.valueOf(System.now().millisecond()) + String.valueOf((Integer)Math.floor(10000 + Math.random()*90000));
            System.debug('Enter in method of Find Duplicate-->');
            return FindDuplicateRegistrationNo(RegistrationNo,strPreRegistrationID,mapOfRegistrationNoAndLead);
        }else{
            // if RegistrationNo  is Unique 
            System.debug('Return RegistrationNo--->'+RegistrationNo);
            return RegistrationNo;
        }
    } 

    public String findDriveMonthCount(String driveSession) {
        Map<String, String> monthsMap = new Map<String, String>{
            'January'  => '01',
            'February' => '02',
            'March' => '03',
            'April' => '04',
            'May' => '05',
            'June' => '06',
            'July' => '07',
            'August' => '08',
            'September' => '09',
            'October' => '10',
            'November' => '11',
            'December' => '12'
        };

        if(String.isNotBlank(driveSession) && monthsMap.containsKey(driveSession)) {
            return monthsMap.get(driveSession);
        }
        return '07';
    }
    
    public void copyAddressOnLead(List<Lead> lstLead , Map<Id,Lead> oldMap){

        for(Lead objLead : lstLead){
            // system.debug(oldMap.get(objLead.id).nm_CopyAddress__c);
            system.debug(oldMap.get(objLead.id).nm_CopyAddress__c);
            system.debug(objLead.nm_CopyAddress__c);
            
            if(objLead.nm_CopyAddress__c =='Yes' && oldMap.get(objLead.id).nm_CopyAddress__c != objLead.nm_CopyAddress__c ){
                objLead.nm_HouseNumber_P__c = objLead.nm_HouseNumber__c;
                objLead.nm_Street_P__c = objLead.Street;
                objLead.nm_City_P__c = objLead.City;
                objlead.nm_StateProvince_P__c = objLead.State;
                objLead.nm_PostalCode_P__c = objLead.PostalCode;
                objLead.nm_Country_P__c = objLead.Country;
                objLead.nm_LocalityName_P__c = objLead.nm_LocalityName__c;
                objLead.nm_NearestLandmark_P__c = objLead.nm_NearestLandmark__c;
                objLead.nm_Other_P_Country__c = objLead.Other_Country__c;
                objLead.nm_Other_P_State__c = objLead.Other_State__c;
            }else if(objLead.Shipping_Address_Choice__c == 'Shipping Address as Permanent Address' && oldMap.get(objLead.id).Shipping_Address_Choice__c != objLead.Shipping_Address_Choice__c){
                objLead.House_No_Name_Shipping__c =objLead.nm_HouseNumber_P__c;
                objLead.Shipping_Street__c =objLead.nm_Street_P__c;
                objLead.Shipping_City__c =objLead.nm_City_P__c;
                objlead.State_Province_Shipping__c =objLead.nm_StateProvince_P__c;
                objLead.Zip_Postal_Code_Shipping__c=objLead.nm_PostalCode_P__c;
                objLead.Country_Shipping__c =objLead.nm_Country_P__c;
                objLead.Locality_Name_Shipping__c = objLead.nm_LocalityName_P__c;
                objLead.Nearest_LandMark_Shipping__c = objLead.nm_NearestLandmark_P__c;
                objLead.Other_Country_Shipping__c = objLead.nm_Other_P_Country__c;
                objLead.Other_State_Shipping__c= objLead.nm_Other_P_State__c;
            }else if(objLead.Shipping_Address_Choice__c == 'Shipping Address as Billing Address' && oldMap.get(objLead.id).Shipping_Address_Choice__c != objLead.Shipping_Address_Choice__c){
                objLead.House_No_Name_Shipping__c =objLead.nm_HouseNumber__c;
                objLead.Shipping_Street__c =objLead.Street;
                objLead.Shipping_City__c =objLead.City;
                objlead.State_Province_Shipping__c =objLead.State;
                objLead.Zip_Postal_Code_Shipping__c=objLead.PostalCode;
                objLead.Country_Shipping__c =objLead.Country;
                objLead.Locality_Name_Shipping__c = objLead.nm_LocalityName__c;
                objLead.Nearest_LandMark_Shipping__c = objLead.nm_NearestLandmark__c;
                objLead.Other_Country_Shipping__c = objLead.Other_Country__c;
                objLead.Other_State_Shipping__c= objLead.Other_State__c;
            }
        }
    }
    
    // Update Lead Status if Account with same Email or Mobile Exist in system
    /*public void UpdateLeadStatusOfNewLeadForAlreadySameAccountPresentInSystem(List<Lead> lstLead,map<id,Lead>triggerOldMap){
        for(Lead objLead :lstLead){
            if(objLead.nm_Program__c != null && triggerOldMap.get(objLead.Id).nm_Program__c == null){
                List<Account> lstAccount = [select Id,nm_RegistrationNumber__c from Account where (PersonEmail =:objLead.email OR PersonMobilePhone =:objLead.MobilePhone ) AND nm_StudentStatus__c != 'Admission Cancel' limit 1];
                if(lstAccount != Null && lstAccount.size() > 0){
                    List<nm_StudentProgram__c> lstSP = [select Id, nm_Program__c from nm_StudentProgram__c where nm_Student__c =:lstAccount[0].Id];
                    if(lstSP != Null && lstSP.size() > 0){
                        for(nm_StudentProgram__c obj : lstSP){
                            if(obj.nm_Program__c ==objLead.nm_Program__c){
                                objLead.Status = 'Invalid Lead';
                                objLead.nm_Reason_for_Dead_Invalid_Leads__c = 'Lead alreadyregistered for same program with Registration Number - ' +lstAccount[0].nm_RegistrationNumber__c;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    // avoid Creation of Duplicate Lead in System     
    //Commented by phalguni on 08.06.2022 for new logic
    
  /*  public void checkDuplicateLeadWithEmailAndMobile(List<Lead> lstLead,map<id,Lead>triggerOldMap){
        list<Id> duplicateLeadIdsToBeDeleted = new list<Id>();
        Set<String> setOfLeadId = new Set<String>();
        Set<String> setOfEmailIds = new Set<String>();
        Set<String> setOfMobileNumbers = new Set<String>();
        boolean combination;
        for(Lead objLead : lstLead){
            if (triggerOldMap.get(objLead.id).Email !=objLead.Email || triggerOldMap.get(objLead.id).mobilephone!=objLead.mobilephone)
            {
                setOfLeadId.add(objLead.id);
                setOfMobileNumbers.add(objLead.MobilePhone);
                setOfEmailIds.add(objLead.Email);
            }  
        }
        
        if(setOfLeadId.size()>0)
        {
            
   
        String queryExistingLead = getQueryAllFieldSql('Lead',' (Email In:setOfEmailIds or MobilePhone In :setOfMobileNumbers) and IsConverted = false and IsDeleted = false and Id NOT IN:setOfLeadId limit 1 ',null);
        List<Lead> lstExistingLead = DataBase.query(queryExistingLead);
        if(lstExistingLead.size() > 0){
            List<Lead> lstldtoUpdate = new List<Lead>();
            for(Lead objLead : lstLead){
                for(Lead existingLead : lstExistingLead){
                  
                        if(((existingLead.Email == objLead.email && triggerOldMap.get(objLead.id).Email !=objLead.Email) || (existingLead.mobilephone == objLead.mobilephone  && triggerOldMap.get(objLead.id).mobilephone !=objLead.mobilephone )) && !existingLead.IsConverted){  
                            system.debug('reborn email value --->'+(triggerOldMap.get(objLead.id).Email).left(6));
                            system.debug('reborn mobile value --->'+(triggerOldMap.get(objLead.id).MobilePhone).right(4));
                            if((existingLead.LeadSource.contains('Partner') 
                            && objLead.LeadSource.contains('Web') && existingLead.Status !='Registration Fee Paid' && existingLead.Status !='Admission Fee Paid' && existingLead.Status !='Payment Made' 
                            && ((objLead.MobilePhone !=triggerOldMap.get(objLead.id).mobilephone+'0000') || (objLead.Email!='reborn_'+triggerOldMap.get(objLead.id).Email))
                            && ((triggerOldMap.get(objLead.id).Email).left(6)=='reborn' && (triggerOldMap.get(objLead.id).MobilePhone).right(4)=='0000')
                            )){
                              duplicateLeadIdsToBeDeleted.add(existingLead.Id);
                                objLead.nmOldLeadDetail__c = objLead.nmOldLeadDetail__c+
                                '\n'+'Registration No:- '+existingLead.nm_RegistrationNo__c+
                                '\n'+'Lead Status:- '+existingLead.Status+
                                '\n'+'Lead Source :- '+existingLead.LeadSource+
                                '\n'+'Information Center Name :- '+existingLead.IC_Name__c+
                                '\n'+'Email Address :- '+existingLead.Email+
                                '\n'+'Mobile Phone :- '+existingLead.MobilePhone+
                                '\n'+'Description:- '+existingLead.Description;
                            }else{
                                lstldtoUpdate.add(existingLead);
                                objLead.adderror('Duplicate Lead Found <a href=\''+ System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+existingLead.id + '\'>' + existingLead.Name + '</a>',false);
                            }
                        }
                    
                }
        
                if(lstldtoUpdate.size()>0){
                    Update_Session_Year(lstldtoUpdate);
                }
            }
        }
    }    
        if(duplicateLeadIdsToBeDeleted.size() > 0){
           // delete [select id from Lead where id in :duplicateLeadIdsToBeDeleted];
           Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);
          
                    }
    }*/
       // avoid Creation of Duplicate Lead in System     
    //    public void checkDuplicateLeadWithEmailAndMobile(List<Lead> lstLead,map<id,Lead>triggerOldMap){
    //     list<Id> duplicateLeadIdsToBeDeleted = new list<Id>();
    //     Set<String> setOfLeadId = new Set<String>();
    //     Set<String> setOfEmailIds = new Set<String>();
    //     Set<String> setOfMobileNumbers = new Set<String>();
    //     boolean combination;
    //     for(Lead objLead : lstLead){
    //         if (triggerOldMap.get(objLead.id).Email !=objLead.Email || triggerOldMap.get(objLead.id).mobilephone!=objLead.mobilephone)
    //         {
    //             setOfLeadId.add(objLead.id);
    //             setOfMobileNumbers.add(objLead.MobilePhone);
    //             setOfEmailIds.add(objLead.Email);
    //         }  
    //     }
        
     
        
    //     if(setOfLeadId.size()>0)
    //     {
                 
    //     String queryExistingLead = getQueryAllFieldSql('Lead',' (Email In:setOfEmailIds or MobilePhone In :setOfMobileNumbers) and IsConverted = false and IsDeleted = false and Id NOT IN:setOfLeadId limit 1 ',null);
    //     List<Lead> lstExistingLead = DataBase.query(queryExistingLead);
    //     if(lstExistingLead.size() > 0){
    //         List<Lead> lstldtoUpdate = new List<Lead>();
    //         for(Lead objLead : lstLead){
    //             for(Lead existingLead : lstExistingLead){
                  
    //                     if(((existingLead.Email == objLead.email && triggerOldMap.get(objLead.id).Email !=objLead.Email 
    //                        && existingLead.IC_Name__c==objLead.IC_Name__c && !existingLead.LeadSource.contains('Partner') && !objLead.LeadSource.contains('Partner')    ) 
    //                         || (existingLead.mobilephone == objLead.mobilephone  && triggerOldMap.get(objLead.id).mobilephone !=objLead.mobilephone && existingLead.IC_Name__c==objLead.IC_Name__c && !existingLead.LeadSource.contains('Partner') && !objLead.LeadSource.contains('Partner'))) 
    //                     && !existingLead.IsConverted){  
    //                         system.debug('reborn email value --->'+(triggerOldMap.get(objLead.id).Email).left(6));
    //                         system.debug('reborn mobile value --->'+(triggerOldMap.get(objLead.id).MobilePhone).right(4));
    //                         if((existingLead.LeadSource.contains('Partner') 
    //                         && objLead.LeadSource.contains('Web') && existingLead.Status !='Registration Fee Paid' && existingLead.Status !='Admission Fee Paid' && existingLead.Status !='Payment Made' 
    //                         && ((objLead.MobilePhone !=triggerOldMap.get(objLead.id).mobilephone+'0000') || (objLead.Email!='reborn_'+triggerOldMap.get(objLead.id).Email))
    //                         && ((triggerOldMap.get(objLead.id).Email).left(6)=='reborn' && (triggerOldMap.get(objLead.id).MobilePhone).right(4)=='0000')
    //                         )){
    //                           duplicateLeadIdsToBeDeleted.add(existingLead.Id);
    //                             objLead.nmOldLeadDetail__c = objLead.nmOldLeadDetail__c+
    //                             '\n'+'Registration No:- '+existingLead.nm_RegistrationNo__c+
    //                             '\n'+'Lead Status:- '+existingLead.Status+
    //                             '\n'+'Lead Source :- '+existingLead.LeadSource+
    //                             '\n'+'Information Center Name :- '+existingLead.IC_Name__c+
    //                             '\n'+'Email Address :- '+existingLead.Email+
    //                             '\n'+'Mobile Phone :- '+existingLead.MobilePhone+
    //                             '\n'+'Description:- '+existingLead.Description;
    //                         }else{
    //                             lstldtoUpdate.add(existingLead);
    //                             objLead.adderror('Duplicate Lead Found <a href=\''+ System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+existingLead.id + '\'>' + existingLead.Name + '</a>',false);
    //                         }
    //                     }
                    
    //             }
        
    //             if(lstldtoUpdate.size()>0){
    //                 Update_Session_Year(lstldtoUpdate);
    //             }
    //         }
    //     }
    // }      
    //     if(duplicateLeadIdsToBeDeleted.size() > 0){
          
    //        Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);
            
    //   }
    // }

    /**
    * @description : To Avoid Email and Mobile Update On Partner and Web Leads, if Duplicate Exits.
    * @author @BK | 12-15-2022 
    * @param lstLead 
    * @param triggerOldMap 
    **/
    public void checkDuplicateLeadWithEmailAndMobileV2(List<Lead> lstLead, map<id,Lead> triggerOldMap){
        Set<String> setOfLeadId = new Set<String>();
        Map<String,String> mapOfLeadIdVsEmail = new Map<String,String>();
        Map<String,String> mapOfLeadIdVsMobile = new Map<String,String>();
        Map<String,Lead> mapOfEmailVsLead = new Map<String,Lead>();
        Map<String,Lead> mapOfMobileVsLead = new Map<String,Lead>();
        Map<String,Lead> mapOfEmailVsLeadNonPartner = new Map<String,Lead>();
        Map<String,Lead> mapOfMobileVsLeadNonPartner = new Map<String,Lead>();
    
        for(Lead objLead : lstLead){
            if (triggerOldMap.get(objLead.id).Email!=objLead.Email || triggerOldMap.get(objLead.id).mobilephone!=objLead.mobilephone) {
                mapOfLeadIdVsEmail.put(objLead.id,objLead.Email);
                mapOfLeadIdVsMobile.put(objLead.id,objLead.MobilePhone);
                setOfLeadId.add(objLead.id);
                System.debug('value changed V1');
            }  
        }
    
        if(setOfLeadId.size() > 0) { 
            List<Lead> lstldtoUpdate = new List<Lead>();
            List<Lead> lstExistingLead = [SELECT id,Name,Email,MobilePhone,IC_Name__c,LeadSource,Status,nm_RegistrationNo__c,Description,
                IsConverted,nm_IsRegistrationFeePaid__c,nm_ChooseaProgram__c,Program_Type__c,nm_Session__c,nm_Year__c FROM Lead 
                WHERE (Email IN : mapOfLeadIdVsEmail.values() OR MobilePhone IN : mapOfLeadIdVsMobile.values()) AND IsConverted=FALSE 
                AND IsDeleted=FALSE AND Id NOT IN:setOfLeadId];
            if(lstExistingLead.size() > 0){
                System.debug('Duplicate Record Found V1');
                for(Lead existingLead : lstExistingLead){
                    mapOfEmailVsLead.put(existingLead.Email,existingLead);
                    mapOfMobileVsLead.put(existingLead.MobilePhone,existingLead);
                    if(existingLead.LeadSource!='Partner') {
                        mapOfEmailVsLeadNonPartner.put(existingLead.Email,existingLead);
                        mapOfMobileVsLeadNonPartner.put(existingLead.MobilePhone,existingLead);
                        mapOfEmailVsLeadNonPartner.put(existingLead.IC_Name__c,existingLead);
                    }
                  }
    
                for(Lead objLead : lstLead){ 
    
                    if((mapOfEmailVsLead.containsKey(objLead.Email) && triggerOldMap.get(objLead.id).Email !=objLead.Email && mapOfEmailVsLead.get(objLead.Email).IC_Name__c==objLead.IC_Name__c 
                    && !mapOfEmailVsLead.get(objLead.Email).LeadSource.contains('Partner') && !objLead.LeadSource.contains('Partner') && !mapOfEmailVsLead.get(objLead.Email).IsConverted) 
                    || (mapOfMobileVsLead.containsKey(objLead.mobilephone) && triggerOldMap.get(objLead.id).mobilephone !=objLead.mobilephone && mapOfMobileVsLead.get(objLead.mobilephone).IC_Name__c==objLead.IC_Name__c 
                    && !mapOfMobileVsLead.get(objLead.mobilephone).LeadSource.contains('Partner') && !objLead.LeadSource.contains('Partner') && !mapOfMobileVsLead.get(objLead.mobilephone).IsConverted)) {
                        
                        Lead existingLead = mapOfEmailVsLead.containsKey(objLead.Email) ? mapOfEmailVsLead.get(objLead.Email) : mapOfMobileVsLead.get(objLead.mobilephone);
                        System.debug('reborn email value --->'+(triggerOldMap.get(objLead.id).Email).left(6));
                        System.debug('reborn mobile value --->'+(triggerOldMap.get(objLead.id).MobilePhone).right(4));
                        
                        if((existingLead.LeadSource.contains('Partner') 
                        && objLead.LeadSource.contains('Web') && existingLead.Status!='Registration Fee Paid' && existingLead.Status!='Admission Fee Paid' && existingLead.Status!='Payment Made' 
                        && ((objLead.MobilePhone!=triggerOldMap.get(objLead.id).mobilephone+'0000') || (objLead.Email!='reborn_'+triggerOldMap.get(objLead.id).Email))
                        && ((triggerOldMap.get(objLead.id).Email).left(6)=='reborn' && (triggerOldMap.get(objLead.id).MobilePhone).right(4)=='0000')
                        )){
                            duplicateLeadIdsToBeDeleted.add(existingLead.id);
                            objLead.nmOldLeadDetail__c = objLead.nmOldLeadDetail__c+
                            '\n'+'Registration No:- '+existingLead.nm_RegistrationNo__c+
                            '\n'+'Lead Status:- '+existingLead.Status+
                            '\n'+'Lead Source :- '+existingLead.LeadSource+
                            '\n'+'Information Center Name :- '+existingLead.IC_Name__c+
                            '\n'+'Email Address :- '+existingLead.Email+
                            '\n'+'Mobile Phone :- '+existingLead.MobilePhone+
                            '\n'+'Description:- '+existingLead.Description;
                        }else{
                            lstldtoUpdate.add(existingLead);
                            objLead.adderror('Duplicate Lead Found <a href=\''+ System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+existingLead.id + '\'>' + existingLead.Name + '</a>',false);
                        }
                    }  // Added By @BK on 15-12-2022
                    else if(objLead.LeadSource=='Partner' && Label.RunDuplicatCheck=='Yes' && (mapOfEmailVsLeadNonPartner.containsKey(objLead.Email) || mapOfMobileVsLeadNonPartner.containsKey(objLead.MobilePhone)) && mapOfEmailVsLeadNonPartner.containsKey(objLead.IC_Name__c) ) {
                        System.debug('Error Added V1');
                        objLead.addError('Duplicate Lead Found, Kindly contact Learning Center.',false);
                    }
                    
                    }
    
                if(lstldtoUpdate.size()>0){
                    Update_Session_Year(lstldtoUpdate);
                }
            }
        }
        
        if(duplicateLeadIdsToBeDeleted.size() > 0){
           Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);
        }
    }

    /**
    * @description : To Avoid Email and Mobile Update On Partner and Web Leads, if Duplicate Exits.
    * @author @BK | 07-12-2022 
    * @param lstLead 
    * @param triggerOldMap 
    **/
    // public void checkDuplicateLeadWithEmailAndMobileWithLeadSource(List<Lead> lstLead, map<id,Lead> triggerOldMap) {
    //     if(Label.RunDuplicatCheck == 'Yes') {
    //         System.debug('Method Called V1');
    //         Set<String> setOfLeadId = new Set<String>();
    //         Map<String,String> mapOfLeadIdVsEmail = new Map<String,String>();
    //         Map<String,String> mapOfLeadIdVsMobile = new Map<String,String>();
    //         Map<String,String> mapOfEmailVsLeadId = new Map<String,String>();
    //         Map<String,String> mapOfMobileVsLeadId = new Map<String,String>();

    //         for(Lead objLead : lstLead){
    //             if ((triggerOldMap.get(objLead.id).Email!=objLead.Email || triggerOldMap.get(objLead.id).mobilephone!=objLead.mobilephone) && objLead.LeadSource=='Partner') {
    //                 mapOfLeadIdVsEmail.put(objLead.id,objLead.Email);
    //                 mapOfLeadIdVsMobile.put(objLead.id,objLead.MobilePhone);
    //                 setOfLeadId.add(objLead.id);
    //                 System.debug('value changed V1');
    //             }  
    //         }

    //         if(mapOfLeadIdVsEmail.size() > 0 || mapOfLeadIdVsMobile.size() > 0) {
    //             List<Lead> lstExistingLead = [SELECT id,Email,MobilePhone FROM Lead WHERE (Email IN : mapOfLeadIdVsEmail.values() OR MobilePhone IN : mapOfLeadIdVsMobile.values()) AND IsConverted=FALSE AND IsDeleted=FALSE AND Id NOT IN:setOfLeadId AND LeadSource!='Partner'];
    //             if(lstExistingLead.size() > 0){
    //                 System.debug('Duplicate Record Found V1');
    //                 for(Lead existingLead : lstExistingLead){
    //                     mapOfEmailVsLeadId.put(existingLead.Email,existingLead.id);
    //                     mapOfMobileVsLeadId.put(existingLead.MobilePhone,existingLead.id);
    //                 }

    //                 for(Lead objLead : lstLead){ 
    //                     if(mapOfEmailVsLeadId.containsKey(objLead.Email) || mapOfEmailVsLeadId.containsKey(objLead.MobilePhone)) {
    //                         System.debug('Error Added V1');
    //                         objLead.addError('Duplicate Lead Found, Kindly contact Learning Center.',false);
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }
  
    /*logic updated 
    public void ConvertLead(List<Lead> lstLead, Map<id, Lead> oldMap){
        Set<String> strDuplicate = new Set<String>();
        map<string, Account> mapDupAccounts = new map<string, Account>();
        //Adding Email MobilePhone in set in string format 
        for(Lead objLead : lstLead){
            strDuplicate.add(((String)objLead.Email + (String) objLead.MobilePhone ).toLowerCase());
        }
        //getting accounts already in Account
       // String queryDuplicatAccount = getQueryAllFieldSql('Account',' nm_CheckDuplicate__c in : strDuplicate and nm_StudentStatus__c !=\'Confirmed\' ','(select id from Contacts limit 1)');
       // List<Account> lstDuplicateAccount = DataBase.query(queryDuplicatAccount);
        List<Account> lstDuplicateAccount = [select id,nm_ChooseaProgram__c,nm_CheckDuplicate__c,nm_StudentStatus__c,(select id from Contacts limit 1) from Account where nm_CheckDuplicate__c in : strDuplicate and nm_StudentStatus__c !='Confirmed' ];
        if(lstDuplicateAccount.size() > 0){
            for(Account objAccount : lstDuplicateAccount){
                for(Lead objLead : lstLead){
                    if(objAccount.nm_ChooseaProgram__c == objLead.nm_ChooseaProgram__c ){
                        mapDupAccounts.put(objAccount.nm_CheckDuplicate__c, objAccount);
                    }
                }
            }
        }
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(Lead objLead : lstLead){
            if(objLead.nm_Program__c != null && objLead.nm_EligiblityCriteria__c != null && objLead.IsConverted ==false && objLead.nm_PaymentCompleted__c == true && oldMap.get(objLead.id).nm_PaymentCompleted__c == false){
                string strLead = ((String)objLead.Email + (String) objLead.MobilePhone ).toLowerCase();
                if(mapDupAccounts.get(strLead) != null && mapDupAccounts !=null){
                    Database.LeadConvert lc = new Database.LeadConvert(); 
                    lc.setLeadId(objLead.id);
                    lc.setAccountId(mapDupAccounts.get(strLead).id);
                    lc.setContactId(mapDupAccounts.get(strLead).Contacts[0].id);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    try{
                        Database.LeadConvertResult lcr = Database.convertLead(lc);
                    }catch(exception ex){
                        objLead.addError(ex.getMessage()); 
                    }
                }else{
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(objLead.id);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    try{
                        Database.LeadConvertResult lcr = Database.convertLead(lc);
                    }catch(exception ex){
                        objLead.addError(ex.getMessage());
                    }
                }
            }
        }
    }*/
    public void ConvertLead(List<Lead> lstLead, Map<id, Lead> oldMap){
        Set<String> strDuplicate = new Set<String>();
        map<string, Account> mapDupAccounts = new map<string, Account>();
        Set<String> setMobile = new Set<String>();
        Set<String> setEmail = new Set<String>();
        Id accId;
        Id oppId;
        Set<String> duplicateLeadWithSourceWeb = new Set<String>();
        //Adding Email MobilePhone in set in string format 
        for(Lead objLead : lstLead){
            
            if(objLead.nm_PaymentCompleted__c == true && oldMap.get(objLead.id).nm_PaymentCompleted__c == false)
            {
                strDuplicate.add(((String)objLead.Email + (String) objLead.MobilePhone ).toLowerCase());
                setMobile.add(objLead.MobilePhone);
                setEmail.add(objLead.Email);
            }           
        }
        //getting accounts already in Account
       /* String queryDuplicatAccount = getQueryAllFieldSql('Account',' nm_CheckDuplicate__c in : strDuplicate and nm_StudentStatus__c !=\'Confirmed\' ','(select id from Contacts limit 1)');
        List<Account> lstDuplicateAccount = DataBase.query(queryDuplicatAccount);*/
        system.debug('strDuplicate--->'+strDuplicate);
        if(strDuplicate.size()>0)
        {
            List<Account> lstDuplicateAccount = [select id,nm_ChooseaProgram__c,nm_CheckDuplicate__c,nm_StudentStatus__c,(select id from Contacts limit 1) from Account where nm_CheckDuplicate__c in : strDuplicate and nm_StudentStatus__c !='Confirmed' ];
            if(lstDuplicateAccount.size() > 0){
                for(Account objAccount : lstDuplicateAccount){
                    for(Lead objLead : lstLead){
                        if(objAccount.nm_ChooseaProgram__c == objLead.nm_ChooseaProgram__c ){
                            mapDupAccounts.put(objAccount.nm_CheckDuplicate__c, objAccount);
                        }
                    }
                }
            }
            List<Lead> lstead = [SELECT Id, LeadSource FROM Lead WHERE LeadSource = 'Web' AND (MobilePhone IN : setMobile OR Email IN :setEmail)];
            if(lstLead.size() > 0) {
                for(Lead obLd : lstLead) {
                    duplicateLeadWithSourceWeb.add(obLd.Id);
                }
            }
            
             LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
             for(Lead objLead : lstLead){
                if(objLead.nm_Program__c != null && objLead.nm_EligiblityCriteria__c != null && objLead.IsConverted ==false && objLead.nm_PaymentCompleted__c == true && oldMap.get(objLead.id).nm_PaymentCompleted__c == false){
                    string strLead = ((String)objLead.Email + (String) objLead.MobilePhone ).toLowerCase();
                    if(mapDupAccounts.get(strLead) != null && mapDupAccounts !=null){
                        Database.LeadConvert lc = new Database.LeadConvert(); 
                        lc.setLeadId(objLead.id);
                        lc.setAccountId(mapDupAccounts.get(strLead).id);
                        lc.setContactId(mapDupAccounts.get(strLead).Contacts[0].id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        try{
                            Database.LeadConvertResult lcr = Database.convertLead(lc);
                            accId = lcr.getAccountId();
                            oppId = lcr.getOpportunityId();
                            Account objaccount = new Account (id= accId);
                            if(objLead.LeadSource == 'Partner' &&  duplicateLeadWithSourceWeb.contains(objLead.Id)) {
                                objaccount.PersonLeadSource  = 'Web & Partner';
                            }
                            objaccount.AadharCardNumber__c = objLead.AadharCardNumber__c;
                            update objaccount;
                        }catch(exception ex){
                            objLead.addError(ex.getMessage()); 
                        }
                    
                    }else{
                        Database.LeadConvert lc = new Database.LeadConvert();
                        lc.setLeadId(objLead.id);
                        lc.setConvertedStatus(convertStatus.MasterLabel);
                        try{
                            Database.LeadConvertResult lcr = Database.convertLead(lc);
                            accId = lcr.getAccountId();
                            Account objaccount = new Account (id= accId);
                            objaccount.AadharCardNumber__c = objLead.AadharCardNumber__c;
                            if(objLead.LeadSource == 'Partner' &&  duplicateLeadWithSourceWeb.contains(objLead.Id)) {
                                objaccount.PersonLeadSource  = 'Web & Partner';
                            }
                           update objaccount;
                        }catch(exception ex){
                            objLead.addError(ex.getMessage());
                        }
                    }
                }
            }    
        }
        
           
    }
    public void UpdateTaskOwnerId(List<Lead> lstLead,Map<id,Lead> oldMap){
        Map<String,String> mapLeadIdOwnerID = new map<String,String>();
        List<Task> lstTaskToUpdate = new List<Task>();
        Set<String> setOfLeadId = new Set<String>();
        for(Lead objLead : lstLead ){
            if(oldMap.get(objLead.id).OwnerId != objLead.OwnerId){
                mapLeadIdOwnerID.put(objLead.id,objLead.OwnerId);
            }
        }
        setOfLeadId = new set<String>(mapLeadIdOwnerID.keyset());
        
        if(!mapLeadIdOwnerID.isEmpty()){
            String queryLeadRelatedTask = getQueryAllFieldSql('Task',' who.id in : setOfLeadId ',null);
            List<Task> lstTask = DataBase.query(queryLeadRelatedTask);
            if(lstTask.size() > 0){
                for(Task objTask : lstTask){
                    objTask.OwnerId = mapLeadIdOwnerID.get(objTask.whoid);
                    lstTaskToUpdate.add(objTask);
                }
            }
        }
        if(lstTaskToUpdate.size() > 0){
            update lstTaskToUpdate;
        }
    }
    
    // Send Mobile Verification Msg and Email verification mail to Registration Form Filled,Admission Fee Paid,Registration Fee Paid  Student till not Verified Mobile Number and also when Mobile No change prior Confirmation 
    public void sendMobileAndEmailVerificationMsg(List<Lead> lstLead, Map<id,Lead> oldMap){
        List<Lead> lstLeadToUpdate = new List<Lead>();
        boolean updateflag = false;
         if(lstLead.size() >0 ){
            for(Lead objLead : lstLead){

                Lead objLeadToUpdate = new Lead(id=objLead.id);
                
                if((objLead.Status != oldMap.get(objLead.id).Status && !objLead.Is_Mobile_Verified__c && (objLead.Status =='Registration Form Filled' || objLead.Status =='Admission Fee Paid' || objLead.Status =='Registration Fee Paid') && !objLead.IsConverted )
                    ||
                    (objLead.MobilePhone != oldMap.get(objLead.id).MobilePhone && !objLead.IsConverted && !objLead.Is_Mobile_Verified__c))
                {
                   if(System.IsBatch() == false && System.isFuture() == false){
                         sendMobileNumberVerificationSMS(objLead.id);
                    }
                }else if(objLead.MobilePhone != oldMap.get(objLead.id).MobilePhone && !objLead.IsConverted && objLead.Is_Mobile_Verified__c){
                    // send MSg to student even if mobile verified and mobile change
                if(System.IsBatch() == false && System.isFuture() == false){
                        updateflag = true;  
                        sendMobileNumberVerificationSMS(objLead.id);
                        objLeadToUpdate.Is_Mobile_Verified__c = false;
                    }
                }

                if((objLead.Status != oldMap.get(objLead.id).Status && !objLead.nm_IsEmailVerified__c && (objLead.Status =='Registration Form Filled' || objLead.Status =='Admission Fee Paid' || objLead.Status =='Registration Fee Paid') && !objLead.IsConverted )
                ||
                    (objLead.Email != oldMap.get(objLead.id).Email && !objLead.IsConverted && !objLead.nm_IsEmailVerified__c))
                {
                    if(System.IsBatch() == false && System.isFuture() == false){
                        sendEmailVerificationMail(objLead.id);
                    }
                }else if(objLead.Email != oldMap.get(objLead.id).Email && !objLead.IsConverted && objLead.nm_IsEmailVerified__c){
                    // send Email to student even if email verified and email change
                if(System.IsBatch() == false && System.isFuture() == false){
                        updateflag = true;
                        sendEmailVerificationMail(objLead.id);
                        objLeadToUpdate.nm_IsEmailVerified__c = false;
                    }
                }
                if(objLead.Status != oldMap.get(objLead.id).Status && objLead.Status =='Phone Switched Off/Ringing/No Response' && objLead.NoResponse__c==false)
                {
                    updateflag = true;
                    objLeadToUpdate.NoResponse__c = true;
                    sendNoResponseSMS(objLead.MobilePhone);
                }

                if(updateflag && (!objLeadToUpdate.Is_Mobile_Verified__c || !objLeadToUpdate.nm_IsEmailVerified__c )){
                    lstLeadToUpdate.add(objLeadToUpdate);
                }
            }

            if(lstLeadToUpdate.size()>0){
                update lstLeadToUpdate;
            }
        }
    }
    public void autoAupdateStateAndCountryBasedUponPostalCode(List<Lead> lstLead,Map<id,Lead> oldMap){
        for(Lead objLead : lstLead){
            if((( objLead.PostalCode !=null && objLead.PostalCode !=oldMap.get(objLead.id).PostalCode) 
                || 
               (objLead.nm_PostalCode_P__c !=null && objLead.nm_PostalCode_P__c !=oldMap.get(objLead.id).nm_PostalCode_P__c)
                ||
                ( objLead.Zip_Postal_Code_Shipping__c !=null && objLead.Zip_Postal_Code_Shipping__c !=oldMap.get(objLead.id).Zip_Postal_Code_Shipping__c ))
                
               && !objLead.IsConverted)
            {   
                autoUpdateStateAndCountryWebService(objLead.id);
            }
        }
    }


    
    /**
    * @description 
    * new method to check eligiblity change and flag change document insertion and deletion
    * @author shubhranshu | 1/7/2020 
    * @param listOfLead 
    * @param oldMapOfLead 
    * @return void 
    **/
    public void UpdateDocumentsForChangeInEligibilityCriteria(List<Lead> listOfLead , Map<id,Lead> oldMapOfLead){  
        // map for eligiblity criteria change check
        Map<String,List<nm_LinksForDocumentsLead__c>> mapofDocuments = new Map<String,List<nm_LinksForDocumentsLead__c>>();
        // map of flag check for e.g. lateral , defence etc...
        Map<String,List<nm_LinksForDocumentsLead__c>> mapOfDocsForFlagCheck = new Map<String,List<nm_LinksForDocumentsLead__c>>();
        // to get the map of eligiblity criteria documents
        Map<string, set<string>> mapCriteriaDocuments = new Map<string, set<string>>();
        Set<String> setOfEligiblityCriteria = new Set<String>();
        Map<Id,Lead> mapOfLeadIdvsLead = new Map<Id,Lead>();
        // insertion list
        List<nm_LinksForDocumentsLead__c> lstDocumentsInsert = new List<nm_LinksForDocumentsLead__c>();
        // deletion list
        List<nm_LinksForDocumentsLead__c> lstDocumentsDelete = new List<nm_LinksForDocumentsLead__c>();
        
        for(Lead lead : listOfLead){
            System.debug('lead.nm_EligiblityCriteria__c in after update'+lead.nm_EligiblityCriteria__c + ' ==> '+ oldMapOfLead.get(lead.id).nm_EligiblityCriteria__c);
            if(String.isNotBlank(lead.nm_EligiblityCriteria__c) && lead.nm_EligiblityCriteria__c != oldMapOfLead.get(lead.id).nm_EligiblityCriteria__c){
                setOfEligiblityCriteria.add(lead.nm_EligiblityCriteria__c);
                mapOfLeadIdvsLead.put(lead.Id,lead);
            }
        }
        
        //Calling method to get documents list against each criteria
        System.debug(setOfEligiblityCriteria.size());
        if(setOfEligiblityCriteria.size() > 0){
            mapCriteriaDocuments = documentHelper.GetProgrameWiseDocumentsList(setOfEligiblityCriteria);
            mapofDocuments = documentHelper.UpdateDocumentsOnLeadForChangeInEligibilityCriteria(mapCriteriaDocuments,mapOfLeadIdvsLead);
            if(!mapofDocuments.isEmpty()){
                if(mapofDocuments.containsKey('INSERT')){
                    lstDocumentsInsert.addAll(mapofDocuments.get('INSERT'));
                }
                if(mapofDocuments.containsKey('DELETE')){
                    lstDocumentsDelete.addAll(mapofDocuments.get('DELETE'));
                }
            }
        }
        Set<Id> lstOfLeadId = oldMapOfLead.keySet();
        mapOfDocsForFlagCheck= documentHelper.UpdateDocumentsOnLeadForFlagChanges(listOfLead,lstOfLeadId);
        if(!mapOfDocsForFlagCheck.isEmpty()){
            if(mapOfDocsForFlagCheck.containsKey('INSERT')){
                lstDocumentsInsert.addAll(mapOfDocsForFlagCheck.get('INSERT'));
            }
            if(mapOfDocsForFlagCheck.containsKey('DELETE')){
                lstDocumentsDelete.addAll(mapOfDocsForFlagCheck.get('DELETE'));
            }
        }
        
        // delete the documents if not need
        System.debug('lstDocumentsDelete '+lstDocumentsDelete);
        if(lstDocumentsDelete.size() > 0){
            documentHelper.documentNeedToDelete(lstDocumentsDelete);
        }

        // update documents on the basis of eligiblity criteria
        System.debug('lstDocumentsInsert --->'+lstDocumentsInsert);
        if(lstDocumentsInsert.size() > 0){
            documentHelper.insertDocumentsAfterUpdate(lstDocumentsInsert);
        }

       
    }
    
   /* public void saveDuplicateLead(List<Lead> lstLead){
        set<String> setRebornEmail = new set<String>();
        set<String> setRebornMobile = new set<String>();
        List<Lead> lstToUpdateOldReg = new List<Lead>();
        set<string> setEmailId = new set<string>();
        set<string> setMobileNo = new set<string>();
        set<String> setIds = new set<String>();
        set<string> setSecondaryEmailId = new set<string>();
        set<string> setSecondaryMobileNo = new set<string>();
        List<string> lstofSecondaryEmailId = new List<string>();
        List<string> lstofSecondaryMobileNo = new List<string>();
       
        
        for(Lead objLead : lstLead){
            setEmailId.add(objLead.Email);
            setMobileNo.add(objLead.mobilephone);
            setRebornEmail.add('reborn_'+objLead.Email);
            setRebornMobile.add(objLead.mobilephone+'0000');
            setIds.add(objLead.Id);
        }
        
        // Loop to deleted already Reborn Lead and do not allowed to Insert double Reborn Lead to avoid Error of Duplicate Lead found 
        String rebornLeadQuery = getQueryAllFieldSql('Lead',' (email in :setRebornEmail or  mobilephone in :setRebornMobile) and IsDeleted = false and IsConverted=false ',null);
        List<Lead> lstExistingDuplicateRebornLeadsTemp = DataBase.query(rebornLeadQuery);
        List<Lead> lstExistingDuplicateRebornLeads = new List<Lead>();
        if(lstExistingDuplicateRebornLeadsTemp.size() > 0){
            for(Lead l : lstExistingDuplicateRebornLeadsTemp){
                Id duplicateLeadId = l.id;
                if(!setIds.contains(duplicateLeadId)){
                    //Duplicate lead is different than that created through trigger
                    lstExistingDuplicateRebornLeads.add(l);
                }
            }
        }
        
     
           if(lstExistingDuplicateRebornLeads.size()>0){
            for(Lead objLead : lstLead){
                for(Lead existingLead :lstExistingDuplicateRebornLeads){
                    if((objLead.nm_ChooseaProgram__c !='Bachelor Programs' && objLead.nm_ChooseaProgram__c != existingLead.nm_ChooseaProgram__c && existingLead.nm_ChooseaProgram__c !='Bachelor Programs') || (objLead.nm_ChooseaProgram__c == existingLead.nm_ChooseaProgram__c)){
                        if((!existingLead.IsConverted) && (existingLead.Email == 'reborn_'+objLead.email || existingLead.mobilephone == objLead.mobilephone+'0000')){
                            duplicateLeadIdsToBeDeleted.add(objLead.Id);
                        }
                    }
                }
            }
        }
        System.debug('saveDuplicate Lead--'+duplicateLeadIdsToBeDeleted);
        //Loop of Delete Reborn Lead ends 
        String duplicateLeadQuery = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c, nm_Program__r.nm_Type__c , nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c');
        List<Lead> lstExistingDuplicateLeadsTemp = DataBase.query(duplicateLeadQuery);
        List<Lead> lstExistingDuplicateLeads = new List<Lead>();
        if(lstExistingDuplicateLeadsTemp.size() > 0){
            for(Lead l : lstExistingDuplicateLeadsTemp){
                Id duplicateLeadId = l.id;
                if(!setIds.contains(duplicateLeadId)){
                    //Duplicate lead is different than that created through trigger
                    lstExistingDuplicateLeads.add(l);
                }
            }
        }
        
        if(lstExistingDuplicateLeads.size()>0 && duplicateLeadIdsToBeDeleted.isEmpty()){
           // Map<String,User> mapOfUserIdVsUser = getMapOfUserIdVsUser();
            Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            
            for(Lead objLead : lstLead){
                for(Lead existingLead :lstExistingDuplicateLeads){
                   System.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
                    if((objLead.nm_ChooseaProgram__c != existingLead.nm_ChooseaProgram__c && existingLead.nm_ChooseaProgram__c !='Bachelor Programs' && objLead.nm_ChooseaProgram__c !='Bachelor Programs') || (objLead.nm_ChooseaProgram__c == existingLead.nm_ChooseaProgram__c)){
                      //  if((!existingLead.IsConverted) && (existingLead.Email == objLead.email || existingLead.mobilephone == objLead.mobilephone)  ){
                      system.debug('enter'+objLead.nm_SelectedIC__c);
                      if((!existingLead.IsConverted) && (existingLead.Email == objLead.email || existingLead.mobilephone == objLead.mobilephone) && objLead.nm_SelectedIC__c!='upGrad'){
                            // Insert New Lead with Reborn Status 1) if existing Lead is partner and new Web. 2)if Jaro's Lead and Web Lead 
                            // in Such cases do not Update Duplicate Counter as this is not duplicate 
                            //for Such Lead append reborn_ in Email and 0000 in MobilePhone
                            system.debug('entry---->');
                              System.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
                            if(existingLead.SecondaryEmailAddress__c!=null && existingLead.SecondaryEmailAddress__c!='')
                            {
                                 lstofSecondaryEmailId =  existingLead.SecondaryEmailAddress__c.split(',');
                                 system.debug('lstofSecondaryEmailId'+lstofSecondaryEmailId);
                                 setSecondaryEmailId.addAll(lstofSecondaryEmailId);
                                 system.debug('setSecondaryEmailId'+setSecondaryEmailId);

                            }
                            if(existingLead.SecondaryMobileNumber__c!=null && existingLead.SecondaryMobileNumber__c!='')
                            {
                                lstofSecondaryMobileNo = existingLead.SecondaryMobileNumber__c.split(',');
                                system.debug('lstofSecondaryMobileNo'+lstofSecondaryMobileNo);
                                setSecondaryMobileNo.addAll(lstofSecondaryMobileNo);
                                system.debug('setSecondaryMobileNo'+setSecondaryMobileNo);
                            }
                            
                         system.debug('existingLead.IC_Name__c'+existingLead.IC_Name__c);
                            
                            if(!setNewLeadStatusAsReborn(objLead,existingLead) && existingLead.IC_Name__c!='upGrad'){
                                if(existingLead.Status !='Registration Fee Paid' && existingLead.Status !='Admission Fee Paid' && existingLead.Status !='Payment Made' && existingLead.Status !='Registration form filled' ){
                                    existingLead.Status= 'Reborn';
                                    system.debug('setSecondaryEmailId--->boolean'+setSecondaryEmailId.contains(objLead.email));
                                    system.debug('setSecondaryMobileNo--->boolean'+setSecondaryMobileNo.contains(objLead.mobilephone));
                                    
                                    if(existingLead.Email != objLead.email && !setSecondaryEmailId.contains(objLead.email))
                                    {                                      
                                        existingLead.SecondaryEmailAddress__c = existingLead.SecondaryEmailAddress__c!='' &&  existingLead.SecondaryEmailAddress__c!= null ? existingLead.SecondaryEmailAddress__c +'\n'+objLead.email+',' :objLead.email+',';
                                            
                                    }
                                    if(existingLead.mobilephone != objLead.mobilephone && !setSecondaryMobileNo.contains(objLead.mobilephone) )
                                    {
                                        existingLead.SecondaryMobileNumber__c = existingLead.SecondaryMobileNumber__c!='' && existingLead.SecondaryMobileNumber__c!=null ?existingLead.SecondaryMobileNumber__c+'\n'+objLead.mobilephone+',' :objLead.mobilephone+',';
                                    }
                                    if(objLead.Agency__c!='' && objLead.Agency__c!=null )
                                    {
                                        existingLead.AgencyAppended__c =existingLead.AgencyAppended__c!=''? existingLead.AgencyAppended__c+'\n'+objLead.Agency__c:objLead.Agency__c;
                                    }                                   
                                                                        
                                    duplicateLeadIdsToBeDeleted.add(objLead.Id);
                                    
                                    // transfer Reborn Lead from Information Center to Learning Center 
                                    if(existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null && existingLead.LeadSource !='Partner'){
                                       
                                        if(existingLead.nm_ChooseaProgram__c=='Bachelor Programs'){
                                            existingLead.nm_InformationCenter__c = mapOfCenterNameVsCenter.get(existingLead.nm_ChooseaProgram__c).id;
                                        }else{
                                            existingLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__r.nm_LearningCenter__c;

                                        }
                                    }
                                     if(objLead.nm_ChooseaProgram__c != existingLead.nm_ChooseaProgram__c && existingLead.LeadSource !='Partner')   
                                   {
                                        existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
                                        
                                        if(existingLead.nm_EligiblityCriteria__c!=null && existingLead.nm_EligiblityCriteria__r.nm_Program__c!=objLead.nm_ChooseaProgram__c)
                                        {
                                            existingLead.nm_EligiblityCriteria__c=null;
                                        }
                                        if(existingLead.nm_Program__c!=null && existingLead.nm_Program__r.nm_Type__c!=objLead.nm_ChooseaProgram__c)
                                        {
                                            existingLead.nm_Program__c= objLead.nm_Program__c!=null? objLead.nm_Program__c : null;
                                            
                                            if(objLead.nm_Program__c==null)
                                             {
                                                  existingLead.Program_Type__c ='';
                                             }
                                        }
                                   }           
                                    //change Lead Owner 
                                    if(mapOfCenterIdVsCenterUserMapping.containsKey(existingLead.nm_InformationCenter__c)){
                                        List<nm_UserMapping__c> lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(existingLead.nm_InformationCenter__c);
                                        if(lstUserMapping !=null && lstUserMapping.size() > 0){
                                            existingLead.OwnerId = lstUserMapping[0].nm_User__c;
                                        }
                                    }
                                    
                                    // Increment Duplicate Counter in Existing Lead for Reference 
                                    if(existingLead.Counter__c == null  ){
                                        existingLead.Counter__c = 1;
                                    }else{
                                        existingLead.Counter__c = Integer.valueOf(existingLead.Counter__c) + 1;
                                    }
                                    
                                    // Increment Reborn Counter 
                                    if(existingLead.RebornCounter__c == null ){
                                        existingLead.RebornCounter__c = 1;
                                    }else{
                                        existingLead.RebornCounter__c = Integer.valueOf(existingLead.RebornCounter__c) + 1;
                                    }
                                    
                                    String InformationCenter = objLead.nm_InformationCenter__c !=null ? mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).Name:objLead.nm_SelectedIC__c;
                                    String MyProflieName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
                                    DateTime DateTimeValue = DateTime.valueOf(system.now().year() + '-' + system.now().month() + '-' + system.now().day() + ' ' + (System.now().hour()+5)+ ':' + (System.now().minute()+30)+ ':00');
                                    String existingLeadId = existingLead.id;
                                    
                                    if(existingLead.Counter__c == 1){
                                       Duplicate_Lead__c duplead = createDuplicateLead(objLead, existingLead,MyProflieName,DateTimeValue,InformationCenter);
                                       insert duplead;
                                    }else{
                                        String duplicateLead = getQueryAllFieldSql('Duplicate_Lead__c',' Original_Existing_Lead__c =:existingLeadId ',null);
                                        List<Duplicate_Lead__c> lstDuplicate = DataBase.query(duplicateLead);
                                        if(lstDuplicate.size() > 0){
                                            for(Duplicate_Lead__c ob :lstDuplicate){
                                                ob.Description__c='\n'+ob.Description__c+InformationCenter+'\n'+'attempt to created Lead '+' '+MyProflieName+DateTimeValue ;
                                                if(objLead.Agency__c !=null){
                                                  ob.Agency__c = ob.Agency__c +','+objLead.Agency__c;
                                                }  
                                                update ob;
                                            }
                                        }
                                    }
                                    
                                    if( objLead.Meeting_Location__c!=null || objLead.Meeting_Date_Time__c!=null){
                                        existingLead.Meeting_Location__c  = objLead.Meeting_Location__c;
                                        existingLead.Meeting_Date_Time__c = objLead.Meeting_Date_Time__c;
                                    }
                                    
                                    // update Existing Lead with Reborn Status and update Duplicate Lead counter
                                    update existingLead;
                                    
                                    System.debug('Delete saveDuplicate Lead--'+duplicateLeadIdsToBeDeleted);
                                    //Delete Duplicate records
                                    if(duplicateLeadIdsToBeDeleted.size() > 0){
                                       // delete [select id from Lead where id in :duplicateLeadIdsToBeDeleted];
                                       
                                       Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);
                                    }
                                }
                            }
                        }
                    }else if(objLead.nm_ChooseaProgram__c =='Bachelor Programs'){
                        Lead objLeadToUpdate = new Lead();
                        objLeadToUpdate.id = objLead.id;
                        objLeadToUpdate.Old_Registration_Number__c = existingLead.nm_RegistrationNo__c;
                        lstToUpdateOldReg.add(objLeadToUpdate);
                    }
                }
            }
        }
    }*/
    //Commented by Phalguni
    /*
    public void saveDuplicateLead(List<Lead> lstLead){
        set<String> setRebornEmail = new set<String>();
        set<String> setRebornMobile = new set<String>();
        List<Lead> lstToUpdateOldReg = new List<Lead>();
        set<string> setEmailId = new set<string>();
        set<string> setMobileNo = new set<string>();
        set<String> setIds = new set<String>();
        set<string> setSecondaryEmailId = new set<string>();
        set<string> setSecondaryMobileNo = new set<string>();
        boolean bachelor = false;
        List<string> lstofSecondaryEmailId = new List<string>();
        List<string> lstofSecondaryMobileNo = new List<string>();
        String duplicateLeadQuery;
       
        
        for(Lead objLead : lstLead){
            setEmailId.add(objLead.Email);
            setMobileNo.add(objLead.mobilephone);
            setRebornEmail.add('reborn_'+objLead.Email);
            setRebornMobile.add(objLead.mobilephone+'0000');
            setIds.add(objLead.Id);
            if(objLead.nm_ChooseaProgram__c.contains('Bachelor'))
              {
                  bachelor =true;
              }
        }
        
        //Loop to deleted already Reborn Lead and do not allowed to Insert double Reborn Lead to avoid Error of Duplicate Lead found 
        String rebornLeadQuery = getQueryAllFieldSql('Lead',' (email in :setRebornEmail or  mobilephone in :setRebornMobile) and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.Allow_Bachelor__c');
        List<Lead> lstExistingDuplicateRebornLeads = DataBase.query(rebornLeadQuery);
       // List<Lead> lstExistingDuplicateRebornLeads = new List<Lead>();        
    
           if(lstExistingDuplicateRebornLeads.size()>0){
            for(Lead objLead : lstLead){
                for(Lead existingLead :lstExistingDuplicateRebornLeads){                  
                        if((!existingLead.IsConverted) && (existingLead.Email == 'reborn_'+objLead.email || existingLead.mobilephone == objLead.mobilephone+'0000')){
                        if(objLead.nm_ChooseaProgram__c =='Bachelor Programs' && existingLead.nm_InformationCenter__r.Allow_Bachelor__c )
                        {
                               duplicateLeadIdsToBeDeleted.add(objLead.Id);
                        }else if (objLead.nm_ChooseaProgram__c !='Bachelor Programs' && existingLead.nm_ChooseaProgram__c !='Bachelor Programs'){
                               duplicateLeadIdsToBeDeleted.add(objLead.Id);
                        }
                                                
                    }
                    
                }
            }
        }
        System.debug('saveDuplicate Lead--'+duplicateLeadIdsToBeDeleted);
        //Loop of Delete Reborn Lead ends 
        if(bachelor)
        {
          duplicateLeadQuery = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and (nm_ChooseaProgram__c  like \'Bachelor%\') and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.recordtype__c, nm_Program__r.nm_Type__c ,nm_InformationCenter__r.Allow_Bachelor__c ,nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c');
         system.debug('duplicateLeadQuery--');
        }else{
             duplicateLeadQuery = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and (NOT nm_ChooseaProgram__c  like \'Bachelor%\') and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c,nm_InformationCenter__r.recordtype__c, nm_Program__r.nm_Type__c ,nm_InformationCenter__r.Allow_Bachelor__c ,nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c');
             system.debug('duplicateLeadQuery2--');

            }
        String duplicateLeadQuery3 = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c, nm_Program__r.nm_Type__c ,nm_InformationCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.recordtype__c ,nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c');

        List<Lead> lstExistingDuplicateLeads = DataBase.query(duplicateLeadQuery);
      //  List<Lead> lstExistingDuplicateLeads = new List<Lead>();
        system.debug('lstExistingDuplicateLeads'+lstExistingDuplicateLeads);
         if(lstExistingDuplicateLeads.isEmpty())
         {
            system.debug('duplicateLeadQuery--3');

            lstExistingDuplicateLeads= DataBase.query(duplicateLeadQuery3);
         }

        system.debug('lstExistingDuplicateLeads--->'+lstExistingDuplicateLeads.size());
        system.debug('duplicateLeadIdsToBeDeleted--->'+duplicateLeadIdsToBeDeleted);

        if(lstExistingDuplicateLeads.size()>0 && duplicateLeadIdsToBeDeleted.isEmpty()){
           // Map<String,User> mapOfUserIdVsUser = getMapOfUserIdVsUser();
            Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            
            for(Lead objLead : lstLead){
                for(Lead existingLead :lstExistingDuplicateLeads){
                   System.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
                   if((existingLead.nm_InformationCenter__r.recordtype__c!='Learning Center' && objLead.nm_ChooseaProgram__c =='Bachelor Programs' &&       existingLead.nm_InformationCenter__r.Allow_Bachelor__c) 
                   || ( existingLead.nm_ChooseaProgram__c!= objLead.nm_ChooseaProgram__c && existingLead.nm_ChooseaProgram__c.contains('Bachelor') && existingLead.nm_InformationCenter__r.recordtype__c!='Learning Center')
         || (!existingLead.nm_ChooseaProgram__c.contains('Bachelor') && !objLead.nm_ChooseaProgram__c.contains('Bachelor'))){

                   system.debug('enter'+objLead.nm_SelectedIC__c);
                      if((!existingLead.IsConverted) && (existingLead.Email == objLead.email || existingLead.mobilephone == objLead.mobilephone) && objLead.nm_SelectedIC__c!='upGrad'){
                            // Insert New Lead with Reborn Status 1) if existing Lead is partner and new Web. 2)if Jaro's Lead and Web Lead 
                            // in Such cases do not Update Duplicate Counter as this is not duplicate 
                            //for Such Lead append reborn_ in Email and 0000 in MobilePhone
                            system.debug('entry---->');
                              System.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
                            if(existingLead.SecondaryEmailAddress__c!=null && existingLead.SecondaryEmailAddress__c!='')
                            {
                                 lstofSecondaryEmailId =  existingLead.SecondaryEmailAddress__c.split(',');
                                 system.debug('lstofSecondaryEmailId'+lstofSecondaryEmailId);
                                 setSecondaryEmailId.addAll(lstofSecondaryEmailId);
                                 system.debug('setSecondaryEmailId'+setSecondaryEmailId);

                            }
                            if(existingLead.SecondaryMobileNumber__c!=null && existingLead.SecondaryMobileNumber__c!='')
                            {
                                lstofSecondaryMobileNo = existingLead.SecondaryMobileNumber__c.split(',');
                                system.debug('lstofSecondaryMobileNo'+lstofSecondaryMobileNo);
                                setSecondaryMobileNo.addAll(lstofSecondaryMobileNo);
                                system.debug('setSecondaryMobileNo'+setSecondaryMobileNo);
                            }
                            
                         system.debug('existingLead.IC_Name__c'+existingLead.IC_Name__c);
                            
                        //   if(!setNewLeadStatusAsReborn(objLead,existingLead) && existingLead.IC_Name__c!='upGrad'                             
                          //  && ((existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null 
                          //  && existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c))
                           // || IsNullOrEmpty(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c))
                            
                           // ){
                            if(!setNewLeadStatusAsReborn(objLead,existingLead) && existingLead.IC_Name__c!='upGrad'){

                                if(existingLead.Status !='Registration Fee Paid' && existingLead.Status !='Admission Fee Paid' && existingLead.Status !='Payment Made' && existingLead.Status !='Registration form filled' )
                                {
                                if((objLead.nm_ChooseaProgram__c =='Bachelor Programs' && existingLead.nm_InformationCenter__r.Allow_Bachelor__c) || !objLead.nm_ChooseaProgram__c.contains('Bachelor')){
                                    existingLead.Status= 'Reborn';
                                    system.debug('setSecondaryEmailId--->boolean'+setSecondaryEmailId.contains(objLead.email));
                                    system.debug('setSecondaryMobileNo--->boolean'+setSecondaryMobileNo.contains(objLead.mobilephone));
                                    
                                    if(existingLead.Email != objLead.email && !setSecondaryEmailId.contains(objLead.email))
                                    {                                      
                                        existingLead.SecondaryEmailAddress__c = existingLead.SecondaryEmailAddress__c!='' &&  existingLead.SecondaryEmailAddress__c!= null ? existingLead.SecondaryEmailAddress__c +'\n'+objLead.email+',' :objLead.email+',';
                                            
                                    }
                                    if(existingLead.mobilephone != objLead.mobilephone && !setSecondaryMobileNo.contains(objLead.mobilephone) )
                                    {
                                        existingLead.SecondaryMobileNumber__c = existingLead.SecondaryMobileNumber__c!='' && existingLead.SecondaryMobileNumber__c!=null ?existingLead.SecondaryMobileNumber__c+'\n'+objLead.mobilephone+',' :objLead.mobilephone+',';
                                    }
                                    if(objLead.Agency__c!='' && objLead.Agency__c!=null )
                                    {
                                        existingLead.AgencyAppended__c =existingLead.AgencyAppended__c!=''? existingLead.AgencyAppended__c+'\n'+objLead.Agency__c:objLead.Agency__c;
                                    }                                   
                                                                        
                                    duplicateLeadIdsToBeDeleted.add(objLead.Id);
                                    
                                    // transfer Reborn Lead from Information Center to Learning Center 
                                    if(existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null && existingLead.LeadSource !='Partner'){
                                       
                                        if(objLead.nm_ChooseaProgram__c!=null && objLead.nm_ChooseaProgram__c=='Bachelor Programs'){
                                            existingLead.nm_InformationCenter__c = System.Label.LC_bachelorID;
                                        }else{
                                            existingLead.nm_InformationCenter__c = existingLead.nm_InformationCenter__r.nm_LearningCenter__c;

                                        }
                                    }
                                     if(objLead.nm_ChooseaProgram__c != existingLead.nm_ChooseaProgram__c && existingLead.LeadSource !='Partner')   
                                   {
                                        existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
                                        
                                        if(existingLead.nm_EligiblityCriteria__c!=null && existingLead.nm_EligiblityCriteria__r.nm_Program__c!=objLead.nm_ChooseaProgram__c)
                                        {
                                            existingLead.nm_EligiblityCriteria__c=null;
                                        }
                                        if(existingLead.nm_Program__c!=null && existingLead.nm_Program__r.nm_Type__c!=objLead.nm_ChooseaProgram__c)
                                        {
                                            existingLead.nm_Program__c= objLead.nm_Program__c!=null? objLead.nm_Program__c : null;
                                            
                                            if(objLead.nm_Program__c==null)
                                             {
                                                  existingLead.Program_Type__c ='';
                                             }
                                        }

                                   }           
                                    //change Lead Owner 
                                    if(mapOfCenterIdVsCenterUserMapping.containsKey(existingLead.nm_InformationCenter__c)){
                                        List<nm_UserMapping__c> lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(existingLead.nm_InformationCenter__c);
                                        if(lstUserMapping !=null && lstUserMapping.size() > 0){
                                            existingLead.OwnerId = lstUserMapping[0].nm_User__c;
                                        }
                                    }
                                    
                                    // Increment Duplicate Counter in Existing Lead for Reference 
                                    if(existingLead.Counter__c == null  ){
                                        existingLead.Counter__c = 1;
                                    }else{
                                        existingLead.Counter__c = Integer.valueOf(existingLead.Counter__c) + 1;
                                    }
                                    
                                    // Increment Reborn Counter 
                                    if(existingLead.RebornCounter__c == null ){
                                        existingLead.RebornCounter__c = 1;
                                    }else{
                                        existingLead.RebornCounter__c = Integer.valueOf(existingLead.RebornCounter__c) + 1;
                                    }
                                    
                                    String InformationCenter = objLead.nm_InformationCenter__c !=null ? mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).Name:objLead.nm_SelectedIC__c;
                                    String MyProflieName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
                                    DateTime DateTimeValue = DateTime.valueOf(system.now().year() + '-' + system.now().month() + '-' + system.now().day() + ' ' + (System.now().hour()+5)+ ':' + (System.now().minute()+30)+ ':00');
                                    String existingLeadId = existingLead.id;
                                    
                                    if(existingLead.Counter__c == 1){
                                       Duplicate_Lead__c duplead = createDuplicateLead(objLead, existingLead,MyProflieName,DateTimeValue,InformationCenter);
                                       insert duplead;
                                    }else{
                                        String duplicateLead = getQueryAllFieldSql('Duplicate_Lead__c',' Original_Existing_Lead__c =:existingLeadId ',null);
                                        List<Duplicate_Lead__c> lstDuplicate = DataBase.query(duplicateLead);
                                        if(lstDuplicate.size() > 0){
                                            for(Duplicate_Lead__c ob :lstDuplicate){
                                                ob.Description__c='\n'+ob.Description__c+InformationCenter+'\n'+'attempt to created Lead '+' '+MyProflieName+DateTimeValue ;
                                                if(objLead.Agency__c !=null){
                                                  ob.Agency__c = ob.Agency__c +','+objLead.Agency__c;
                                                }  
                                                update ob;
                                            }
                                        }
                                    }
                                    //Update via API after creating lead
                                    if( objLead.Meeting_Location__c!=null || objLead.Meeting_Date_Time__c!=null){
                                        existingLead.Meeting_Location__c  = objLead.Meeting_Location__c;
                                        existingLead.Meeting_Date_Time__c = objLead.Meeting_Date_Time__c;
                                    }
                                    
                                    // update Existing Lead with Reborn Status and update Duplicate Lead counter
                                    update existingLead;
                                   
                                    System.debug('Delete saveDuplicate Lead--'+duplicateLeadIdsToBeDeleted);
                                    //Delete Duplicate records
                                    if(duplicateLeadIdsToBeDeleted.size() > 0){
                                       // delete [select id from Lead where id in :duplicateLeadIdsToBeDeleted];                                      
                                       Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);                                                                           }
                                }
                            }
                          }
                        }
                    }else if(objLead.nm_ChooseaProgram__c =='Bachelor Programs'){
                        Lead objLeadToUpdate = new Lead();
                        objLeadToUpdate.id = objLead.id;
                        objLeadToUpdate.Old_Registration_Number__c = existingLead.nm_RegistrationNo__c;
                        lstToUpdateOldReg.add(objLeadToUpdate);
                    }
                }
            }
        }
    }*/
//         public void saveDuplicateLeadvs2(List<Lead> lstLead){
//         set<String> setRebornEmail = new set<String>();
//         set<String> setRebornMobile = new set<String>();
//         set<string> setEmailId = new set<string>();
//         set<string> setMobileNo = new set<string>();
//         set<String> setIds = new set<String>();
//         List<Lead> ListexistingLead = new List<Lead>();
//         boolean RebornLead =false;
//         String duplicateLeadQuery;
//         Integer attempts = Integer.valueof(System.Label.LeadAttempt);
       
//         for(Lead objLead : lstLead){
//             setEmailId.add(objLead.Email);
//             setMobileNo.add(objLead.mobilephone);
//             setRebornEmail.add('reborn_'+objLead.Email);
//             setRebornMobile.add(objLead.mobilephone+'0000');
//              setIds.add(objLead.Id);
           
//         }
        
//         String rebornLeadQuery = getQueryAllFieldSql('Lead',' (email in :setRebornEmail or  mobilephone in :setRebornMobile) and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.nm_ChooseaProgram__c');
//          List<Lead> lstExistingDuplicateRebornLeads = DataBase.query(rebornLeadQuery);
         
//            if(lstExistingDuplicateRebornLeads.size()>0){
               
//             Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
//             Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();

//             for(Lead objLead : lstLead){
//                 for(Lead existingLead :lstExistingDuplicateRebornLeads){                  
//                         if((!existingLead.IsConverted) 
//                         && (existingLead.Email == 'reborn_'+objLead.email 
//                         || existingLead.mobilephone == objLead.mobilephone+'0000')
//                         && existingLead.Status !='Registration Fee Paid' 
//                         && existingLead.Status !='Admission Fee Paid'
//                         && existingLead.Status !='Registration form filled'
//                         && objLead.nm_SelectedIC__c!='upGrad'){                       
//                                duplicateLeadIdsToBeDeleted.add(objLead.Id);
//                                System.debug('System Delete1-->');
//                                //update existing lead detail and transfer to LC forcefully
//                                Lead objexistingLead = new Lead();

//                                objexistingLead =  TransferLeadToManger(existingLead,objLead);  
//                             RebornLead =true;  
//                           //  ListexistingLead.add(existingLead);                          
//                     }                   
//                 }
//             }
//         }

//         String  duplicateLeadQuery1 = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c, nm_Program__r.nm_Type__c ,nm_InformationCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.recordtype__c ,nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_ChooseaProgram__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c');
        

//         List<Lead> lstExistingDuplicateLeads = DataBase.query(duplicateLeadQuery1);
        
//         system.debug('lstExistingDuplicateLeads--->'+lstExistingDuplicateLeads.size());
//         system.debug('duplicateLeadIdsToBeDeleted--->'+duplicateLeadIdsToBeDeleted);
//         if(lstExistingDuplicateLeads.size()>0){
            
//             Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
//             Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            
//                 for(Lead objLead : lstLead){
//                     for(Lead existingLead :lstExistingDuplicateLeads){
//                   System.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
//                  system.debug('existingLead.IC_Name__c-->'+existingLead.IC_Name__c);
//                  system.debug('existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c-->'+existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c);
//                  system.debug('RebornLead--->'+RebornLead);
//                //  rebornStatus = setRebornList.contains(objLead.Agency__c);
//                  System.debug('Agency --->'+objLead.Agency__c);
               
//                   // non co-oprate lead
//                   if((!existingLead.IsConverted) 
//                   && (existingLead.Email == objLead.email || existingLead.mobilephone == objLead.mobilephone)
//                    )
//                   {
//                       if(existingLead.IC_Name__c=='upGrad' && objLead.nm_SelectedIC__c=='upGrad' )
//                       {
//                           //Delete the lead 
//                           duplicateLeadIdsToBeDeleted.add(objLead.Id);
//                           System.debug('System Delete2-->');

//                       }
//                       /*else if (existingLead.nm_ChooseaProgram__c =='Bachelor Programs' 
//                       && objLead.nm_ChooseaProgram__c =='Bachelor Programs')
//                       {
//                           //Delete the lead 
//                           if(existingLead.LeadSource =='Partner' && objLead.LeadSource =='Web' && !RebornLead)
//                           {
//                             CreatLeadwithStatusAsReborn(existingLead,objLead);

//                           }else {
//                             duplicateLeadIdsToBeDeleted.add(objLead.Id);
//                             System.debug('System Delete3-->');  
//                             existingLead = UpdateExistingLeadTransfertoLC(existingLead,objLead);
//                             ListexistingLead.add(existingLead);                               
//                           }

 
//                       }*/else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null 
//                           && existingLead.LeadSource !='Partner'
//                       && objLead.nm_SelectedIC__c!='upGrad' && existingLead.IC_Name__c!='upGrad'
//                       && existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c))
//                       {
//                          //Delete the lead 
//                           duplicateLeadIdsToBeDeleted.add(objLead.Id);
//                           System.debug('System Delete4-->');
//                           // Call method to update existing lead Detail and reborn to LC
//                           if(existingLead.NumberofAttempts__c!=null && attempts > existingLead.NumberofAttempts__c)
//                             {
//                                 existingLead = UpdateExistingLeadTransfertoLC(existingLead,objLead);
//                                 ListexistingLead.add(existingLead); 
//                             }else
//                             {
//                                 existingLead.Status ='Reborn';
//                                 existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
//                                 existingLead.nm_Session__c = objLead.nm_Session__c;
//                                 existingLead.nm_Year__c = objLead.nm_Year__c;
//                                 ListexistingLead.add(existingLead);
//                             }                                                     

//                          //update existingLead;                     

//                       }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null 
//                       && existingLead.LeadSource !='Partner'
//                       && objLead.nm_SelectedIC__c!='upGrad' && existingLead.IC_Name__c!='upGrad'
//                      &&! existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c))
//                   {
//                       if(existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null)
//                       {
//                         String LearningCenterId = mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).nm_LearningCenter__c;
//                       if(mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)){
//                         //Delete the lead 
//                         duplicateLeadIdsToBeDeleted.add(objLead.Id);
//                         System.debug('System Delete4-->');
//                         // Call method to update existing lead Detail and reborn to LC

//                          existingLead = UpdateExistingLeadTransfertoLC(existingLead,objLead);
//                        /* existingLead.Status ='Reborn';
//                         existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
//                         existingLead.nm_Session__c = objLead.nm_Session__c;
//                         existingLead.nm_Year__c = objLead.nm_Year__c;*/
//                         ListexistingLead.add(existingLead);
//                         system.debug('existingLead.nm_InformationCenter__c--->'+existingLead.nm_InformationCenter__c);

//                          // update existingLead;                          
//                          }
//                       }

//                   }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c) && existingLead.LeadSource =='Partner' && objLead.LeadSource =='Web' && !RebornLead){
//                             // Don't Delete the lead and Create Reborn_ and 0000 Lead to that Partner LC and update leadsource

//                             CreatLeadwithStatusAsReborn(existingLead,objLead);
//                             System.debug('No  Delete-->');

                          
//                       }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && !existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c) && existingLead.LeadSource =='Partner' && objLead.nm_SelectedIC__c!='upGrad' &&  existingLead.IC_Name__c!='upGrad'&& !RebornLead) {
//                           // Allow to create Lead against  LC and if existing partner lc offer then create Reborn_
//                           // Else allow to create new lead with another LC AEP who offer Program
//                                 String LearningCenterId = mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).nm_LearningCenter__c;
//                                 LearningCenterId= IsNullOrEmpty(LearningCenterId)? existingLead.nm_InformationCenter__c : LearningCenterId;
//                                 System.debug('System Delete5-->');

//                           if(mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c!= null 
//                          && mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c))
//                          {
//                             CreatLeadwithStatusAsReborn(existingLead,objLead);

//                          }
//                       }
//                     //call for reborn check 
//                  // write method to delete the lead
//                  else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c) && existingLead.LeadSource =='Partner' 
//                       && objLead.LeadSource !='Web' && !RebornLead) {
//                         System.debug('System Delete6-->');

//                           //Delete the lead 
//                           duplicateLeadIdsToBeDeleted.add(objLead.Id);
//                         //  existingLead = updatePartnerLead(existingLead,objLead.nm_ChooseaProgram__c,existingLead.Program_Type__c);
//                         existingLead.Status ='Reborn';
//                         existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
//                         existingLead.nm_Session__c = objLead.nm_Session__c;
//                         existingLead.nm_Year__c = objLead.nm_Year__c;
//                           ListexistingLead.add(existingLead);
//                       }                     
//                   }
              

//                 }
//             }
//         }
//         system.debug('duplicateLeadIdsToBeDeleted.size()--->'+duplicateLeadIdsToBeDeleted.size());
//             if(duplicateLeadIdsToBeDeleted.size() > 0){
//             // delete [select id from Lead where id in :duplicateLeadIdsToBeDeleted];                                      
//             Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);                                            
//             }
//             system.debug('ListexistingLead--->'+ListexistingLead);
//             if(ListexistingLead.size()>0)
//             {
//              /*   try{
//                     update  ListexistingLead;                          
//                 }catch(exception ex){
//                     ex.getMessage(); 
//                 }*/
//             //    update  ListexistingLead;  
//                 Database.SaveResult[] srList = Database.update(ListexistingLead, false);

// // Iterate through each returned result
//        /* for (Database.SaveResult sr : srList) {
//             if (sr.isSuccess()) {
//                 // Operation was successful, so get the ID of the record that was processed
//                 System.debug('Successfully update Lead. Lead ID: ' + sr.getId());
//             }
//             else {
//                 // Operation failed, so get all errors                
//                 for(Database.Error err : sr.getErrors()) {
//                     System.debug('The following error has occurred.');                    
//                     System.debug(err.getStatusCode() + ': ' + err.getMessage());
//                     System.debug('Lead fields that affected this error: ' + err.getFields());
//                 }
//             }
//         }*/




//             }                        

//     }
 /*   public void saveDuplicateLeadvs3(List<Lead> lstLead){
        set<String> setRebornEmail = new set<String>();
        set<String> setRebornMobile = new set<String>();
        set<string> setEmailId = new set<string>();
        set<string> setMobileNo = new set<string>();
        set<String> setIds = new set<String>();
        List<Lead> ListexistingLead = new List<Lead>();
        List<Lead> ListUpdateNewLead = new List<Lead>();
        boolean RebornLead =false;
        String duplicateLeadQuery;
        Integer attempts = Integer.valueof(System.Label.LeadAttempt);
       
        for(Lead objLead : lstLead){
            setEmailId.add(objLead.Email);
            setMobileNo.add(objLead.mobilephone);
            setRebornEmail.add('reborn_'+objLead.Email);
            setRebornMobile.add(objLead.mobilephone+'0000');
            setIds.add(objLead.Id);
           
        }
        
        String  duplicateLeadQuery1 = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c, nm_Program__r.nm_Type__c ,nm_InformationCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.recordtype__c ,nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_ChooseaProgram__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.Name');
        

        List<Lead> lstExistingDuplicateLeads = DataBase.query(duplicateLeadQuery1);
        
        system.debug('lstExistingDuplicateLeads--->'+lstExistingDuplicateLeads.size());
        system.debug('duplicateLeadIdsToBeDeleted--->'+duplicateLeadIdsToBeDeleted);
        if(lstExistingDuplicateLeads.size()>0){
            
            Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            
                for(Lead objLead : lstLead){
                    for(Lead existingLead :lstExistingDuplicateLeads){
                    system.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
                    system.debug('existingLead.IC_Name__c-->'+existingLead.IC_Name__c);
                    system.debug('existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c-->'+existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c);
                    system.debug('RebornLead--->'+RebornLead);
                    system.debug('existingLead.nm_InformationCenter__r.Name --->'+existingLead.nm_InformationCenter__r.Name );
                    system.debug('objLead.nm_InformationCenter__c--->'+objLead.nm_InformationCenter__c);
                    //  rebornStatus = setRebornList.contains(objLead.Agency__c);
                    System.debug('Agency --->'+objLead.Agency__c);
               
                  // non co-oprate lead
                  if((!existingLead.IsConverted) 
                  && (existingLead.Email == objLead.email || existingLead.mobilephone == objLead.mobilephone)
                   )
                  {
                      if(existingLead.IC_Name__c=='upGrad' && objLead.nm_SelectedIC__c=='upGrad' )
                      {
                          //Delete the lead if same lead came for upgrad
                          duplicateLeadIdsToBeDeleted.add(objLead.Id);
                          System.debug('System Delete2-->');

                      }
                      else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null 
                              && existingLead.LeadSource =='Partner'
                              && objLead.LeadSource =='Partner'
                              && objLead.nm_SelectedIC__c!='upGrad' && existingLead.IC_Name__c!='upGrad'
                              && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c
                              )
                      {
                        //Delete the lead on condition of same AEP for leadsource partner
                        duplicateLeadIdsToBeDeleted.add(objLead.Id);
                        System.debug('System Delete3-->');
                        if(String.isNotBlank(objLead.Agency__c) && !objLead.Agency__c.startsWith('L1') && !objLead.Agency__c.startsWith('L2') && !objLead.Agency__c.startsWith('L3') && !existingLead.Status.contains('Fee Paid') && existingLead.Status != 'Not Contacted')
                                {
                                    existingLead.Status ='Reborn';
                                    existingLead.nm_ChooseaProgram__c = existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)?objLead.nm_ChooseaProgram__c:existingLead.nm_ChooseaProgram__c;
                                    existingLead.nm_Session__c = objLead.nm_Session__c;
                                    existingLead.nm_Year__c = objLead.nm_Year__c;
                                    ListexistingLead.add(existingLead);   
                                }                                                

                      }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null 
                      && existingLead.LeadSource !='Partner' &&  objLead.LeadSource !='Partner'
                      && objLead.nm_SelectedIC__c!='upGrad' && existingLead.IC_Name__c!='upGrad'
                     && !existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c))
                      {//Transfer Lead to LC as AEP don't offer the program
                      if(existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null)
                      {
                        String LearningCenterId = mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).nm_LearningCenter__c;
                      if(mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)){
                            //Delete the lead 
                            duplicateLeadIdsToBeDeleted.add(objLead.Id);
                            System.debug('System Delete4-->');
                            // Call method to update existing lead Detail and reborn to LC

                            existingLead = UpdateExistingLeadTransfertoLC(existingLead,objLead);                    
                            ListexistingLead.add(existingLead);
                            system.debug('existingLead.nm_InformationCenter__c--->'+existingLead.nm_InformationCenter__c);
                                         
                         }
                      }

                  }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c) && existingLead.LeadSource!='Partner' 
                  && objLead.LeadSource !='Partner' && !RebornLead && objLead.nm_SelectedIC__c!='upGrad' &&  existingLead.IC_Name__c!='upGrad'){
                        //Reborn Web lead if again visited without touching partner
                        System.debug('System Delete5-->');
                        duplicateLeadIdsToBeDeleted.add(objLead.Id);
                        if(String.isNotBlank(objLead.Agency__c) && !objLead.Agency__c.startsWith('L1') && !objLead.Agency__c.startsWith('L2') && !objLead.Agency__c.startsWith('L3') && !existingLead.Status.contains('Fee Paid') && existingLead.Status != 'Not Contacted')
                        {
                            existingLead.Status ='Reborn';
                            existingLead.nm_ChooseaProgram__c = existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)?objLead.nm_ChooseaProgram__c:existingLead.nm_ChooseaProgram__c;
                            existingLead.nm_Session__c = objLead.nm_Session__c;
                            existingLead.nm_Year__c = objLead.nm_Year__c;
                            ListexistingLead.add(existingLead);   
                        }                               
                    }
            else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource !='Partner' 
            && objLead.LeadSource =='Partner'  && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c && !RebornLead ) {
                duplicateLeadIdsToBeDeleted.add(objLead.Id);  
                //If existing web lead and partner lead is incoming update lead source of existing web lead only if it came for same aep.
                System.debug('System Delete7-->');
                        
                      }
                         else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource !='Partner' 
            && objLead.LeadSource =='Partner'   && !RebornLead ) {
                duplicateLeadIdsToBeDeleted.add(objLead.Id);  
                //If existing web lead and partner lead is incoming for same AEP DELETE the lead.
                System.debug('System Delete9-->');
                                                                                                    
                      }
                        else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource =='Partner' 
            && objLead.LeadSource !='Partner'  && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c && !RebornLead) {
                duplicateLeadIdsToBeDeleted.add(objLead.Id);
                System.debug('System Delete8-->');
                                //If existing partner lead and web lead is incoming update lead source of existing Partner lead only if it came for same aep.

                            if(objLead.LeadSource =='Web' )   
                            {
                                existingLead.LeadSource ='Web & Partner';                                  
                                ListexistingLead.add(existingLead); 
                                
                            }               
                      }
                    
                 // partner and partner lead with Same AEP name delete the lead
                 else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource =='Partner' 
                      && objLead.LeadSource =='Partner' && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c) {
                        System.debug('System Delete6-->');

                          //Delete the lead 
                            duplicateLeadIdsToBeDeleted.add(objLead.Id);                      
                                if(String.isNotBlank(objLead.Agency__c) && !objLead.Agency__c.startsWith('L1') && !objLead.Agency__c.startsWith('L2') && !objLead.Agency__c.startsWith('L3') && !existingLead.Status.contains('Fee Paid') && existingLead.Status != 'Not Contacted')
                                {
                                    existingLead.Status ='Reborn';
                                    existingLead.nm_ChooseaProgram__c = existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)?objLead.nm_ChooseaProgram__c:existingLead.nm_ChooseaProgram__c;
                                    existingLead.nm_Session__c = objLead.nm_Session__c;
                                    existingLead.nm_Year__c = objLead.nm_Year__c;
                                    ListexistingLead.add(existingLead);   
                                }       
                      }                     
                  }
              
                }
            }
        }
        system.debug('duplicateLeadIdsToBeDeleted.size()--->'+duplicateLeadIdsToBeDeleted.size());
            if(duplicateLeadIdsToBeDeleted.size() > 0){
            // delete [select id from Lead where id in :duplicateLeadIdsToBeDeleted];                                      
            Database.DeleteResult[] deleteResults = Database.delete(duplicateLeadIdsToBeDeleted, true);                                            
            }
            system.debug('ListexistingLead--->'+ListexistingLead);
            if(ListexistingLead.size()>0)
            {          
                Database.SaveResult[] srList = Database.update(ListexistingLead, false);
            }
            system.debug('ListUpdateNewLead--->'+ListUpdateNewLead);
           if(ListUpdateNewLead.size()>0)
            {          
                Database.SaveResult[] srupdateList = Database.update(ListUpdateNewLead, false);

            }                           

    }*/

    public void saveDuplicateLeadvs4(List<Lead> lstLead){
        set<string> setEmailId = new set<string>();
        set<string> setMobileNo = new set<string>();
        set<String> setIds = new set<String>();
        List<Lead> listExistingLead = new List<Lead>();
        // List<Lead> ListUpdateNewLead = new List<Lead>();
        // boolean RebornLead =false;
        String duplicateLeadQuery;
        Integer attempts = Integer.valueof(System.Label.LeadAttempt);
        
        for(Lead objLead : lstLead){
            setEmailId.add(objLead.Email);
            setMobileNo.add(objLead.mobilephone);
            setIds.add(objLead.Id);
        }
            
        String duplicateLeadQuery1 = getQueryAllFieldSql('Lead',' (email in :setEmailId or  mobilephone in :setMobileNo) and Id!=:setIds and IsDeleted = false and IsConverted=false ','nm_InformationCenter__r.nm_LearningCenter__c, nm_Program__r.nm_Type__c ,nm_InformationCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.recordtype__c ,nm_EligiblityCriteria__r.nm_Program__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Degree__c,nm_InformationCenter__r.nm_ChooseaProgram__c,nm_InformationCenter__r.nm_LearningCenter__r.Allow_Bachelor__c,nm_InformationCenter__r.Name');
        List<Lead> lstExistingDuplicateLeads = DataBase.query(duplicateLeadQuery1);
        System.debug('lstExistingDuplicateLeads--->'+lstExistingDuplicateLeads.size());
        // System.debug('duplicateLeadIdsToBeDeleted--->'+duplicateLeadIdsToBeDeleted);
        if(lstExistingDuplicateLeads.size()>0){
            ProfileUtility utils = ProfileUtility.getInstance();
            Id profileId = UserInfo.getProfileId();
            List<String> skipProfiles = new List<String>{'Counsellor'};
            Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
            for(Lead objLead : lstLead){
                for(Lead existingLead :lstExistingDuplicateLeads){
                    System.debug('New Program--'+objLead.nm_ChooseaProgram__c+'-----Existing Program--'+existingLead.nm_ChooseaProgram__c);
                    System.debug('existingLead.IC_Name__c-->'+existingLead.IC_Name__c);
                    System.debug('existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c-->'+existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c);
                    System.debug('existingLead.nm_InformationCenter__r.Name --->'+existingLead.nm_InformationCenter__r.Name );
                    System.debug('objLead.nm_InformationCenter__c--->'+objLead.nm_InformationCenter__c);
                    System.debug('Agency --->'+objLead.Agency__c);
                
                    // non co-oprate lead
                    if((!existingLead.IsConverted) && (existingLead.Email == objLead.email || existingLead.mobilephone == objLead.mobilephone)) {
                        if(existingLead.IC_Name__c=='upGrad' && objLead.nm_SelectedIC__c=='upGrad' ) {
                            //Delete the lead if same lead came for upgrad
                            if(utils.profileMap.containsKey(profileId) && skipProfiles.contains(utils.profileMap.get(profileId).Name)) {
                                objLead.addError('Duplicate Lead, Record already exists with same Email or Mobile No');
                            } else {
                                duplicateLeadIdsToBeDeleted.add(objLead.Id);
                            }
                            System.debug('System Delete2-->');
                            
                        } else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource =='Partner'
                        && objLead.LeadSource =='Partner' && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c) {
                            System.debug('System Delete3-->');
                            if(String.isNotBlank(objLead.Agency__c) && !objLead.Agency__c.startsWith('L1') && !objLead.Agency__c.startsWith('L2') && !objLead.Agency__c.startsWith('L3') && !existingLead.Status.contains('Fee Paid') && existingLead.Status != 'Not Contacted')
                            {
                                existingLead.Status ='Reborn';
                                existingLead.nm_ChooseaProgram__c = existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)?objLead.nm_ChooseaProgram__c:existingLead.nm_ChooseaProgram__c;
                                existingLead.nm_Session__c = objLead.nm_Session__c;
                                existingLead.nm_Year__c = objLead.nm_Year__c;
                                listExistingLead.add(existingLead);   
                            }   
                            //Delete the lead on condition of same AEP for leadsource partner
                            if(utils.profileMap.containsKey(profileId) && skipProfiles.contains(utils.profileMap.get(profileId).Name)) {
                                objLead.addError('Duplicate Lead, Record already exists with same Email or Mobile No');
                            } else {
                                duplicateLeadIdsToBeDeleted.add(objLead.Id);
                            } 

                        }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource !='Partner' &&  objLead.LeadSource !='Partner'
                        && !existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)) {
                            //Transfer Lead to LC as AEP don't offer the program
                            if(existingLead.nm_InformationCenter__r.nm_LearningCenter__c!=null) {
                                String LearningCenterId = mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).nm_LearningCenter__c;
                                if(mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)){
                                    System.debug('System Delete4-->');
                                    // Call method to update existing lead Detail and reborn to LC
                                    existingLead = UpdateExistingLeadTransfertoLC(existingLead,objLead);                    
                                    listExistingLead.add(existingLead);
                                    System.debug('existingLead.nm_InformationCenter__c--->'+existingLead.nm_InformationCenter__c);
                                    //Delete the lead 
                                    if(utils.profileMap.containsKey(profileId) && skipProfiles.contains(utils.profileMap.get(profileId).Name)) {
                                        objLead.addError('Duplicate Lead, Record already exists with same Email or Mobile No');
                                    } else {
                                        duplicateLeadIdsToBeDeleted.add(objLead.Id);
                                    }
                                }
                            }
    
                        }else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)
                        && existingLead.LeadSource!='Partner' && objLead.LeadSource !='Partner' ) {
                            //Reborn Web lead if again visited without touching partner
                            System.debug('System Delete5-->');
                            System.debug('existingLead.LeadSource-->'+existingLead.LeadSource);
                            System.debug('objLead.LeadSource-->'+objLead.LeadSource);
                            if((String.isNotBlank(objLead.Agency__c) && !objLead.Agency__c.startsWith('L1') && !objLead.Agency__c.startsWith('L2') && !objLead.Agency__c.startsWith('L3') && !existingLead.Status.contains('Fee Paid') && existingLead.Status != 'Not Contacted'))
                            {
                                existingLead.Status ='Reborn';
                                existingLead.nm_ChooseaProgram__c = existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c.contains(objLead.nm_ChooseaProgram__c)?objLead.nm_ChooseaProgram__c:existingLead.nm_ChooseaProgram__c;
                                existingLead.nm_Session__c = objLead.nm_Session__c;
                                existingLead.nm_Year__c = objLead.nm_Year__c;
                                existingLead.LeadSource = (existingLead.LeadSource == 'Web' && objLead.LeadSource =='CC-AEP') ? 'Web & CC-AEP':existingLead.LeadSource;
    
                                listExistingLead.add(existingLead);   
                            }else if(existingLead.LeadSource == 'Web' && objLead.LeadSource =='CC-AEP'){
                                System.debug('CC-AEP update -->');
                                existingLead.LeadSource = 'Web & CC-AEP';
                                existingLead.Status ='Reborn';
                                existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
                                existingLead.nm_Session__c = objLead.nm_Session__c;
                                existingLead.nm_Year__c = objLead.nm_Year__c;
                                listExistingLead.add(existingLead);   
                            }

                            if(utils.profileMap.containsKey(profileId) && skipProfiles.contains(utils.profileMap.get(profileId).Name)) {
                                objLead.addError('Duplicate Lead, Record already exists with same Email or Mobile No');
                            } else {
                                duplicateLeadIdsToBeDeleted.add(objLead.Id);
                            }
    
                        } else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource !='Partner' 
                        && objLead.LeadSource =='Partner' && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c  ) {
                            if(utils.profileMap.containsKey(profileId) && skipProfiles.contains(utils.profileMap.get(profileId).Name)) {
                                objLead.addError('Duplicate Lead, Record already exists with same Email or Mobile No');
                            } else {
                                duplicateLeadIdsToBeDeleted.add(objLead.Id);
                            }
                            //If existing web lead and partner lead is incoming for the same AEP DELETE the incoming lead
                            System.debug('System Delete7-->');
    
                        }
                        else if(existingLead.nm_InformationCenter__r.nm_ChooseaProgram__c!=null && existingLead.LeadSource =='Partner' && objLead.LeadSource !='Partner'  
                        && existingLead.nm_InformationCenter__c == objLead.nm_InformationCenter__c && objLead.Status != 'Admission Cancelled' 
                        && objLead.Status != 'Registration Cancelled' ) {
                            System.debug('System Delete8-->');
                            //If existing partner lead and web lead is incoming update lead source of existing Partner lead only if it came for same aep.
                            if(objLead.LeadSource =='Web'){
                                existingLead.LeadSource ='Web & Partner';                                  
                                listExistingLead.add(existingLead); 
                            }
                            if(utils.profileMap.containsKey(profileId) && skipProfiles.contains(utils.profileMap.get(profileId).Name)) {
                                objLead.addError('Duplicate Lead, Record already exists with same Email or Mobile No');
                            } else {
                                duplicateLeadIdsToBeDeleted.add(objLead.Id);
                            }

                        }            
                    }
                }
            }
        }
        System.debug('listExistingLead--->'+listExistingLead);
        if(listExistingLead.size()>0) {          
            Database.SaveResult[] srList = Database.update(listExistingLead, false);
        }
    }

    public Lead UpdateExistingLeadTransfertoLC(Lead existingLead,Lead objLead )
{
    String LearningCenterId;
    String interestedLeadStatus = System.Label.Interested_LeadStatus;
    List<String> setIntrestedList = interestedLeadStatus.split(',');
    String RebornHighPriority = System.Label.RebornHighPriority;
   
    if(existingLead.Status !='Registration Fee Paid' && existingLead.Status !='Admission Fee Paid'
    && existingLead.Status !='Registration form filled')
        {
           // Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
           system.debug('mapOfCenterIdVsCenter--->'+mapOfCenterIdVsCenter);
           System.debug('Inside of If Function' + '----------------------->');
                LearningCenterId = mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).nm_LearningCenter__c;
                LearningCenterId = IsNullOrEmpty(LearningCenterId)? existingLead.nm_InformationCenter__c : LearningCenterId;
                
                system.debug('LearningCenterId--->'+LearningCenterId);
                if(LearningCenterId!=null && existingLead.LeadSource !='Partner'){
                    system.debug('existingLead.LeadSource--->'+existingLead.LeadSource);                   
                  /*  if(objLead.nm_ChooseaProgram__c!=null && objLead.nm_ChooseaProgram__c=='Bachelor Programs'){
                        system.debug('objLead.nm_ChooseaProgram__c--->'+objLead.nm_ChooseaProgram__c);
                        existingLead.nm_InformationCenter__c = System.Label.LC_bachelorID;
                        existingLead = SetOwner(existingLead);
                        existingLead.Status='Reborn';

                    }else{*/
                        // existingLead.nm_InformationCenter__c = LearningCenterId;
                        // system.debug('existingLead.nm_InformationCenter__c--->'+existingLead.nm_InformationCenter__c);
                        // existingLead = SetOwner(existingLead);
                      
                        if(!setIntrestedList.contains(existingLead.Status)) {
                            System.debug('inside contain if' + '--------------------->');
                            existingLead.nm_InformationCenter__c = LearningCenterId; 
                            existingLead.Status='Reborn';            
                            existingLead = SetOwner(existingLead);                  
                        }                      
                        existingLead.Status= !IsNullOrEmpty(objLead.Agency__c) && RebornHighPriority.contains(objLead.Agency__c)?'Reborn - High Priority':'Reborn';                                             
                        existingLead.nm_Session__c = objLead.nm_Session__c;
                        existingLead.nm_Year__c = objLead.nm_Year__c;
                        existingLead.LeadSource = (existingLead.LeadSource == 'Web' && objLead.LeadSource =='CC-AEP') ? 'Web & CC-AEP':existingLead.LeadSource;
                        
                        
                }
                 if(objLead.nm_ChooseaProgram__c != existingLead.nm_ChooseaProgram__c && existingLead.LeadSource !='Partner')   
                {
                  //existingLead = ToUpdatePRogramDetailOnLead(existingLead,objLead );
                  existingLead.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;


                  if(existingLead.nm_EligiblityCriteria__c!=null && existingLead.nm_EligiblityCriteria__r.nm_Program__c!=objLead.nm_ChooseaProgram__c)
                  {
                      existingLead.nm_EligiblityCriteria__c=null;
                  }
                  if(existingLead.nm_Program__c!=null && existingLead.nm_Program__r.nm_Type__c!=objLead.nm_ChooseaProgram__c)
                  {
                      existingLead.nm_Program__c= objLead.nm_Program__c!=null? objLead.nm_Program__c : null;
                      
                      if(objLead.nm_Program__c==null)
                       {
                          existingLead.Program_Type__c ='';
                       }
                  }
              
               }   
               if(existingLead!=null)
               {
                   existingLead = UpdateExistingLeadEmailMobile(existingLead,objLead);
                   existingLead = UpdateExistingLeadCounter(existingLead,objLead);
               }
               
        }
      return existingLead;
    }
    public Lead UpdateExistingLeadCounter(Lead existingLead,Lead objLead )
    {
                                            
// Increment Duplicate Counter in Existing Lead for Reference 
        if(existingLead.Counter__c == null  ){
            existingLead.Counter__c = 1;
        }else{
            existingLead.Counter__c = Integer.valueOf(existingLead.Counter__c) + 1;
        }
        
        // Increment Reborn Counter 
        if(existingLead.RebornCounter__c == null ){
            existingLead.RebornCounter__c = 1;
        }else{
            existingLead.RebornCounter__c = Integer.valueOf(existingLead.RebornCounter__c) + 1;
        }
        
        String InformationCenter = objLead.nm_InformationCenter__c !=null ? mapOfCenterIdVsCenter.get(objLead.nm_InformationCenter__c).Name:objLead.nm_SelectedIC__c;
        String MyProflieName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
        DateTime DateTimeValue = DateTime.valueOf(system.now().year() + '-' + system.now().month() + '-' + system.now().day() + ' ' + (System.now().hour()+5)+ ':' + (System.now().minute()+30)+ ':00');
        String existingLeadId = existingLead.id;
        
        if(existingLead.Counter__c == 1){
           Duplicate_Lead__c duplead = createDuplicateLead(objLead, existingLead,MyProflieName,DateTimeValue,InformationCenter);
           insert duplead;
        }else{
            String duplicateLead = getQueryAllFieldSql('Duplicate_Lead__c',' Original_Existing_Lead__c =:existingLeadId ',null);
            List<Duplicate_Lead__c> lstDuplicate = DataBase.query(duplicateLead);
            if(lstDuplicate.size() > 0){
                for(Duplicate_Lead__c ob :lstDuplicate){
                    ob.Description__c='\n'+ob.Description__c+InformationCenter+'\n'+'attempt to created Lead '+' '+MyProflieName+DateTimeValue ;
                    if(objLead.Agency__c !=null){
                      ob.Agency__c = ob.Agency__c +','+objLead.Agency__c;
                    }  
                    update ob;
                }
            }
        }

      return existingLead;

    }

    public Lead UpdateExistingLeadEmailMobile(Lead existingLead,Lead objLead )
    {
        set<string> setSecondaryEmailId = new set<string>();
        set<string> setSecondaryMobileNo = new set<string>();
        List<string> lstofSecondaryEmailId = new List<string>();
        List<string> lstofSecondaryMobileNo = new List<string>();
        if(existingLead.SecondaryEmailAddress__c!=null && existingLead.SecondaryEmailAddress__c!='')
        {
            lstofSecondaryEmailId =  existingLead.SecondaryEmailAddress__c.split(',');
            system.debug('lstofSecondaryEmailId'+lstofSecondaryEmailId);
            setSecondaryEmailId.addAll(lstofSecondaryEmailId);
            system.debug('setSecondaryEmailId'+setSecondaryEmailId);
        }
        if(existingLead.SecondaryMobileNumber__c!=null && existingLead.SecondaryMobileNumber__c!='')
        {
            lstofSecondaryMobileNo = existingLead.SecondaryMobileNumber__c.split(',');
            system.debug('lstofSecondaryMobileNo'+lstofSecondaryMobileNo);
            setSecondaryMobileNo.addAll(lstofSecondaryMobileNo);
            system.debug('setSecondaryMobileNo'+setSecondaryMobileNo);
        }
        if(existingLead.Email != objLead.email && !setSecondaryEmailId.contains(objLead.email))
        {                                      
            existingLead.SecondaryEmailAddress__c = existingLead.SecondaryEmailAddress__c!='' &&  existingLead.SecondaryEmailAddress__c!= null ? existingLead.SecondaryEmailAddress__c +'\n'+objLead.email+',' :objLead.email+',';              
        }
        if(existingLead.mobilephone != objLead.mobilephone && !setSecondaryMobileNo.contains(objLead.mobilephone) )
        {
            existingLead.SecondaryMobileNumber__c = existingLead.SecondaryMobileNumber__c!='' && existingLead.SecondaryMobileNumber__c!=null ?existingLead.SecondaryMobileNumber__c+'\n'+objLead.mobilephone+',' :objLead.mobilephone+',';
        }
        if(objLead.Agency__c!='' && objLead.Agency__c!=null )
        {
            existingLead.AgencyAppended__c =existingLead.AgencyAppended__c!=''? existingLead.AgencyAppended__c+'\n'+objLead.Agency__c:objLead.Agency__c;
        }                                   

      return existingLead;

    }

    public Lead SetOwner(Lead objLead)
    {
        Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
        
        if(mapOfCenterIdVsCenterUserMapping.containsKey(objLead.nm_InformationCenter__c)){
        List<nm_UserMapping__c> lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
        if(lstUserMapping !=null && lstUserMapping.size() > 0){
            objLead.OwnerId = lstUserMapping[0].nm_User__c;
        }
    }
        return objLead;
    }


    public Duplicate_Lead__c createDuplicateLead(Lead newLead, Lead existingLead,String UserName, DateTime DateTimeValue,String InformationCenter ){
        Duplicate_Lead__c  objDupLead = new Duplicate_Lead__c ();
        objDupLead.Email__c= newLead.Email;
        objDupLead.nm_FirstName__c= newLead.FirstName;
        objDupLead.nm_LastName__c= newLead.LastName;
        objDupLead.Mobile_No__c= newLead.MobilePhone;
        objDupLead.Agency__c= newLead.Agency__c;
        objDupLead.Lead_Source__c= newLead.LeadSource;
        objDupLead.IP_For_Lead__c= newLead.nm_IPForLead__c;
        objDupLead.Original_Existing_Lead__c = existingLead.Id;
        objDupLead.Selected_IC__c = newLead.nm_SelectedIC__c;
        objDupLead.nm_InformationCenter__c = newLead.nm_InformationCenter__c;
        objDupLead.Description__c=InformationCenter+'Inserted By '+UserName+''+DateTimeValue ;
        return objDupLead;
    }
    
    /*public boolean setNewLeadStatusAsReborn(Lead newLead,Lead existingLead){
        Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
        Map<String,nm_Centers__c> mapOfCenterNameVsCenter = getMapOfCenterNameVsCenter();
        Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
        nm_Centers__c LCBachelorName = new nm_Centers__c();
        System.debug('newLead --'+newLead );
        System.debug('mapOfCenterIdVsCenter ---'+mapOfCenterIdVsCenter.keySet());
        if(newLead !=null){
              String InformationCenter = existingLead.nm_InformationCenter__c !=null && !mapOfCenterIdVsCenter.IsEmpty() && mapOfCenterIdVsCenter!=null? mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).Name : existingLead.nm_SelectedIC__c;
            if(existingLead.LeadSource == 'Partner' && newLead.LeadSource == 'Web') {
                Lead objLeadToUpdate = new Lead(id=newLead.id);
                System.debug('Enter in loop of Non Deleted---->');
                objLeadToUpdate.MobilePhone = newLead.MobilePhone+'0000';
                objLeadToUpdate.Email = 'Reborn_'+newLead.Email;
                objLeadToUpdate.Status = 'Reborn';
                objLeadToUpdate.LeadSource='Web & Partner';
                objLeadToUpdate.Old_Registration_Number__c = existingLead.nm_RegistrationNo__c;
                
                 existingLead.LeadSource='Web & Partner';
                 existingLead.InactiveLead__c = true;
                
                //transfer New Reborn Lead from Information Center to Learning Center 
                if(mapOfCenterNameVsCenter.containsKey(InformationCenter)){
                    if(mapOfCenterNameVsCenter.get(InformationCenter) !=null){
                        if(mapOfCenterNameVsCenter.get(InformationCenter).nm_LearningCenter__c !=null){
                             LCBachelorName = mapOfCenterNameVsCenter.get(existingLead.nm_ChooseaProgram__c)!=null?mapOfCenterNameVsCenter.get(existingLead.nm_ChooseaProgram__c):mapOfCenterNameVsCenter.get(newLead.nm_ChooseaProgram__c);
                             System.debug('LCBachelorName-->'+LCBachelorName);
                             System.debug('chooseprogram-->'+existingLead.nm_ChooseaProgram__c);

                            objLeadToUpdate.nm_InformationCenter__c = LCBachelorName!=null ?LCBachelorName.id : mapOfCenterNameVsCenter.get(InformationCenter).nm_LearningCenter__c;
                            objLeadToUpdate.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLeadToUpdate.nm_InformationCenter__c).AEP_email_id__c; 

                            if(mapOfCenterIdVsCenterUserMapping.containskey(objLeadToUpdate.nm_InformationCenter__c)){
                                List<nm_UserMapping__c> lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLeadToUpdate.nm_InformationCenter__c);
                                if(lstUserMapping !=null && lstUserMapping.size() > 0){
                                    objLeadToUpdate.OwnerId =  lstUserMapping[0].nm_user__c;
                                }
                            }
                        }
                    }    
                }
                update existingLead;
                update objLeadToUpdate;
                return true;
            }
        }
        return false;
    }*/

//Simple Method to transfer Reborn Lead to Manager without validating 
// public Lead TransferLeadToManger(Lead newLead,Lead existingLead){
//     Lead objled = new Lead (id=existingLead.id);
//     String RebornHighPriority = System.Label.RebornHighPriority;
    
//     if(existingLead.nm_InformationCenter__c!=null)
//     {
//         String LearningCenterId = mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).nm_LearningCenter__c;
//         LearningCenterId = IsNullOrEmpty(LearningCenterId)? existingLead.nm_InformationCenter__c : LearningCenterId;
//         system.debug('LearningCenterId--->'+LearningCenterId);
//       //  Lead objled = new Lead (id=existingLead.id);
//         if(!IsNullOrEmpty(LearningCenterId)){
//             if(mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c!= null 
//             && mapOfCenterIdVsCenter.get(LearningCenterId).nm_ChooseaProgram__c.contains(newLead.nm_ChooseaProgram__c) )
//             {
//                 System.debug('TransferLeadToManger1--->');
//             objled.nm_InformationCenter__c = LearningCenterId;               
//           //  objled.Status= setRebornList.contains(newLead.Agency__c)?'Reborn - High Priority':'Reborn';
//           objled.Status = !IsNullOrEmpty(newLead.Agency__c) && RebornHighPriority.contains(newLead.Agency__c)?'Reborn - High Priority':'Reborn';
//           objled = ToUpdatePRogramDetailOnLead(existingLead,newLead);
                
//             }/*else if(newLead.nm_ChooseaProgram__c.contains('Bachelor') ){
//                 System.debug('TransferLeadToManger2--->');

//                 objled.nm_InformationCenter__c = System.Label.LC_bachelorID;
//                 objled.status ='Reborn';
//                 objled = ToUpdatePRogramDetailOnLead(existingLead,newLead);
                
//             }   */        
//         }
//     }
//     return objled;
// }
// Method to update Choose Peogram and validate eligibility criteria plus Program and Program type
// public Lead ToUpdatePRogramDetailOnLead(Lead existingLead,Lead objLead)
// {          Lead objled = new Lead (id=existingLead.id);

//     objled.nm_ChooseaProgram__c = objLead.nm_ChooseaProgram__c;
    
//     if(existingLead.nm_EligiblityCriteria__c!=null && existingLead.nm_EligiblityCriteria__r.nm_Program__c!=objLead.nm_ChooseaProgram__c)
//     {
//         objled.nm_EligiblityCriteria__c=null;
//     }
//     if(existingLead.nm_Program__c!=null && existingLead.nm_Program__r.nm_Type__c!=objLead.nm_ChooseaProgram__c)
//     {
//         objled.nm_Program__c= objLead.nm_Program__c!=null? objLead.nm_Program__c : null;
        
//         if(objLead.nm_Program__c==null)
//          {
//             objled.Program_Type__c ='';
//          }
//     }
//     return objled;
// }  
// public void CreatLeadwithStatusAsReborn(Lead existingLead,Lead newLead){
        
//     Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = getMapOfCenterIdVsCenter();
//     Map<String,nm_Centers__c> mapOfCenterNameVsCenter = getMapOfCenterNameVsCenter();
//     Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = getMapOfCenterIdVsCenterUserMapping();
//     //  nm_Centers__c LCBachelorName = new nm_Centers__c();
//     String RebornHighPriority = System.Label.RebornHighPriority;
    
   
//     if(newLead !=null){
//         String InformationCenter = existingLead.nm_InformationCenter__c !=null && !mapOfCenterIdVsCenter.IsEmpty() && mapOfCenterIdVsCenter!=null? mapOfCenterIdVsCenter.get(existingLead.nm_InformationCenter__c).Name : existingLead.nm_SelectedIC__c;
//         System.debug('existingLead.LeadSource--->'+existingLead.LeadSource);
//         System.debug('newLead.LeadSource--->'+newLead.Agency__c);

//         if(existingLead.LeadSource == 'Partner' && newLead.LeadSource == 'Web') {
//             Lead objLeadToUpdate = new Lead(id=newLead.id);
//             System.debug('Enter in loop of Non Deleted---->');
//             //objLeadToUpdate.MobilePhone = newLead.MobilePhone+'0000';
//           //  objLeadToUpdate.Email = 'Reborn_'+newLead.Email;
//             objLeadToUpdate.MobilePhone = newLead.MobilePhone;
//             objLeadToUpdate.Email = newLead.Email;
//             //if(newLead.Mobile_Masked__c!=null)
//             /*If(String.isBlank(newLead.Mobile_Masked__c))
//             {
//              objLeadToUpdate.Mobile_Masked__c= newLead.MobilePhone;  
//             }
//             If(String.isNotBlank(newLead.Mobile_Masked__c) && String.isBlank(newLead.MobilePhone))
//             {
//             objLeadToUpdate.MobilePhone=newLead.Mobile_Masked__c;
//             }
//             If(String.isBlank(newLead.Email_Masked__c))
//             {
//              objLeadToUpdate.Email_Masked__c= newLead.Email;  
//             }
//             If(String.isNotBlank(newLead.Email_Masked__c) && String.isBlank(newLead.Email))
//             {
//             objLeadToUpdate.Email=newLead.Email_Masked__c;
//              }
//             if(newLead.is_dnd_new__c=='Yes')
//                 {
//             objLeadToUpdate.RecordTypeId=ob.Id;
//                 }*/
//            objLeadToUpdate.Status = !IsNullOrEmpty(newLead.Agency__c) && RebornHighPriority.contains(newLead.Agency__c)?'Reborn - High Priority':'Reborn';                 
//            objLeadToUpdate.LeadSource='Web & Partner';
//             objLeadToUpdate.Old_Registration_Number__c = existingLead.nm_RegistrationNo__c;
//             objLeadToUpdate.Prior_Information_Center__c = existingLead.IC_Name__c; 
//            //  existingLead.LeadSource='Web & Partner';
//             // existingLead.InactiveLead__c = true;
            
//             //transfer New Reborn Lead from Information Center to Learning Center 
//             if(mapOfCenterNameVsCenter.containsKey(InformationCenter)){
//                 if(mapOfCenterNameVsCenter.get(InformationCenter) !=null){
//                     if(mapOfCenterNameVsCenter.get(InformationCenter).nm_LearningCenter__c !=null){
//                       //   LCBachelorName = mapOfCenterNameVsCenter.get(existingLead.nm_ChooseaProgram__c)!=null?mapOfCenterNameVsCenter.get(existingLead.nm_ChooseaProgram__c):mapOfCenterNameVsCenter.get(newLead.nm_ChooseaProgram__c);
//                       //   System.debug('LCBachelorName-->'+LCBachelorName);
//                          System.debug('chooseprogram-->'+existingLead.nm_ChooseaProgram__c);

//                         objLeadToUpdate.nm_InformationCenter__c =mapOfCenterNameVsCenter.get(InformationCenter).nm_LearningCenter__c;
//                         objLeadToUpdate.AEP_email_id__c = mapOfCenterIdVsCenter.get(objLeadToUpdate.nm_InformationCenter__c).AEP_email_id__c; 

//                         if(mapOfCenterIdVsCenterUserMapping.containskey(objLeadToUpdate.nm_InformationCenter__c)){
//                             List<nm_UserMapping__c> lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLeadToUpdate.nm_InformationCenter__c);
//                             if(lstUserMapping !=null && lstUserMapping.size() > 0){
//                                 objLeadToUpdate.OwnerId =  lstUserMapping[0].nm_user__c;
//                             }
//                         }
//                     }
//                 }    
//             }
//             update existingLead;
//             update objLeadToUpdate;
//         }
//     }
// }


    /**
    * @description To handle escalation dates and reminders for a list of leads
    * @author @BK | 08-27-2024 
    * @param lstLead 
    * @param oldMapLead 
    **/
    public void escallationDate(list<lead> lstLead, map<id,Lead> oldMapLead) {
        EscalationHandler.handleEscalationDate(lstLead, oldMapLead);
    }

    /**
    * @description
    * @author @BK | 22/8/2019
    * @param list<lead> lstLead
    * @param map<id, Lead> OldMapLead
    * @return void
    */
    public void sendMobileDNDSMS(list<lead> lstLead, map<id,Lead> oldMapLead) {
        List<String> lstOfMobileNumber = new List<String>();
        for(Lead objLead : lstLead ) {
            String isDND = objLead.is_dnd_new__c;
            if(String.isNotBlank(isDND) && isDND.equalsIgnoreCase('Yes') && oldMapLead.get(objLead.Id).is_dnd_new__c != objLead.is_dnd_new__c) {
                sendSMSToDNDActiveStudent(objLead.MobilePhone, objLead.FirstName+''+objLead.LastName);
            }
        }
    }
    
    public void callLoanStatusUpdate(map<id,Lead> newMap ,map<id,Lead> OldMap){
        for(String ldId : newMap.keySet()){
            Lead objLead = newMap.get(ldId);
            System.debug('callLoanStatusUpdate --'+objLead);
            if(objLead.Loan_Type__c =='LiquiLoans') {
                if(objLead.Loan_Approved__c && OldMap.get(objLead.id).Loan_Approved__c != objLead.Loan_Approved__c)
                {
                    liquiLoansStatusUpdate(objLead.EduVanz_lead_id__c,'Y',objLead.Id);  // used eduvanz field to avoid extra field creation for same functionality & Y is used for approved stage
                }else if(objLead.Loan_Application_Cancelled__c && OldMap.get(objLead.id).Loan_Order_Status__c != 'Rejected' && objLead.Loan_Order_Status__c != 'Rejected'){
                    liquiLoansStatusUpdate(objLead.EduVanz_lead_id__c,'N',objLead.Id);  // used eduvanz field to avoid extra field creation for same functionality & N is used for recjected stage
                }
            } else if(objLead.Loan_Type__c == 'Propelld' && objLead.Loan_Approved__c && OldMap.get(objLead.id).Loan_Approved__c != objLead.Loan_Approved__c) {
                propelldStatusUpdate(objLead.EduVanz_lead_id__c,true,objLead.Id);  // used eduvanz field to avoid extra field creation for same functionality & Y is used for approved stage
            }  else if(objLead.Loan_Type__c == 'Avanse'){
                if (objLead.Loan_Approved__c && OldMap.get(objLead.id).Loan_Approved__c != objLead.Loan_Approved__c) { 
                    System.debug('call Loan disbursment API as loan is approved');
                    avanseStatusUpdate(objLead.EduVanz_lead_id__c,objLead.Id,'approved');
                }
                // else if (objLead.Loan_Application_Cancelled__c && OldMap.get(objLead.Id).Loan_Order_Status__c != 'Rejected' && objLead.Loan_Order_Status__c != 'Rejected') {
                //     avanseStatusUpdate(objLead.EduVanz_lead_id__c,objLead.Id,'cancel');
                // }
            }
            /*else if(objLead.Loan_Type__c == 'GrayQuest' && objLead.Loan_Approved__c && OldMap.get(objLead.id).Loan_Approved__c != objLead.Loan_Approved__c) {
                GrayQuestStatusUpdate(objLead.EduVanz_lead_id__c,objLead.Id); 
            }*/
            /*else if (objLead.Loan_Type__c =='EzCred' ){
                if(objLead.Loan_Approved__c && OldMap.get(objLead.id).Loan_Approved__c != objLead.Loan_Approved__c)
                {
                    EzcredLoanStatusUpdate(objLead.Loan_Account_number__c,'APPROVED',objLead.Id);  
                }else if(objLead.Loan_Application_Cancelled__c && OldMap.get(objLead.id).Loan_Application_Cancelled__c != objLead.Loan_Application_Cancelled__c 
                            &&  OldMap.get(objLead.id).Loan_Order_Status__c != 'REJECTED'){
                    EzcredLoanStatusUpdate(objLead.Loan_Account_number__c,'REJECTED',objLead.Id);
                }
            } */
            
        } 
    }

    
    @future (callout=true)
    public static void liquiLoansStatusUpdate(String LoanId,String LoanStatus,String LeadId){
        liquiLoansStatusUpdateAPI.statusUpdateForLoan(LoanId,LoanStatus,LeadId,'Lead'); 
    }

    @future(callout=true)
    public static void propelldStatusUpdate(String quoteId, Boolean loanStatus, String leadId){
        PropelldWebService objPropelldWebService = new PropelldWebService();
        objPropelldWebService.updateStatusByQuoteId(quoteId,loanStatus,leadId,'Lead'); 
    }

    @future(callout=true)
    public static void avanseStatusUpdate(String quoteId, String leadId, String status){
        AvanseWebService objAvanseWebService = new AvanseWebService();
        // if (status == 'cancel') {
        //     objAvanseWebService.cancelAvanseLoan(quoteId, 'Lead', leadId);
        // }
        if (status == 'approved') {
            objAvanseWebService.updateAvanseLoanStatus(quoteId, 'Lead',leadId);
        }
    }
    
   /* @future (callout=true)
    public static void GrayQuestStatusUpdate(String LoanId,String LeadId){
        
       GrayQuestWebService.approvedLoan(LoanId,LeadId,'Lead'); 
    }*/

   /* @future (callout=true)
    public static void EzcredLoanStatusUpdate(String LoanAccountId,String Type,String leadId){
        if(Type == 'REJECTED'){
            EzcredWebService.cancelLoan(LoanAccountId,leadId,'Lead'); 
        }else if(Type == 'APPROVED'){
            EzcredWebService.approvedLoan(LoanAccountId,leadId,'Lead'); 
        }
        
    }*/

    @future (callout=true)
    public static void sendSMSToDNDActiveStudent(String MobileNumber,String Name){
        nmSendNotification.sendSMSToDNDActiveStudent(mobileNumber,Name);
    }
    
    @future (callout=true)
    public static void sendMobileNumberVerificationSMS(String LeadId){
       Lead objLead =[select id,MobilePhone,nm_Program__r.Name,nm_RegistrationNo__c, IC_Name__c from Lead where id=:LeadId];
       if (objLead.IC_Name__c == 'RateGain Travel Technologies Ltd.') {
           nmSendNotification.sendVerificationSMSToStudentForCorporateFrom(objLead.MobilePhone,objLead.nm_Program__r.Name,objLead.nm_RegistrationNo__c,'Registration No.','Lead',objLead.id);  
       } else {
           nmSendNotification.sendVerificationSMSToStudent(objLead.MobilePhone,objLead.nm_Program__r.Name,objLead.nm_RegistrationNo__c,'Registration No.','Lead',objLead.id);
       }
    }
   
    @future (callout=true)
    public static void sendEmailVerificationMail(String LeadId){
       Lead objLead =[select id,MobilePhone,nm_Program__r.Name,nm_RegistrationNo__c,Email,FirstName,LastName,LC_Email__c from Lead where id=:LeadId];
       nmSendNotification.sendVerificationEmailToStudent(objLead.Email,objLead.LC_Email__c,objLead.FirstName+''+objLead.LastName,'Lead',objLead.id);  
    }
    @future (callout=true)
    public static void sendNoResponseSMS(String MobileNumber){
        nmSendNotification.sendSMSToNoResponseStudent(mobileNumber);
    }
    @future (callout=true)
    public static void autoUpdateStateAndCountryWebService(String LeadId){
       AutoUpdateStateAndCountryWebService.updateStateandCountyOnLead(LeadId);  
    }
    
  /*  @future
    public static void ChangeDefaultOwnerAssignment(Set<String> setOfLeadId){
        List<Lead> lstLead = [select id,OwnerId,nm_InformationCenter__c , nm_ChooseaProgram__c from Lead where id in :setOfLeadId and isdeleted =                   false and isconverted = false];
        if(lstLead !=null && lstLead.size() > 0){
            
            Map<String,List<nm_UserMapping__c>> mapOfCenterIdVsCenterUserMapping = new Map<String,List<nm_UserMapping__c>>();
            List<Lead> lstLeadToUpdate = new List<Lead>();
            Map<String,List<nm_UserMapping__c>> mapProgramAndUser = new Map<String,List<nm_UserMapping__c>>();
            Map<Integer,id> mapOfRoundRobinIds =new map<Integer,id>();
            Set<Id> SetCentuserId = new Set<Id> ();
            List<nm_UserMapping__c> lstUserMapping2 = new List<nm_UserMapping__c>();
            Integer maxnumber; 

            
                String queryUserCenterMapping = 'select id,nm_Head__c,nm_ChooseaProgram__c  ,nm_user__c,nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name from nm_UserMapping__c where nm_Centers__c !=null and nm_Centers__r.RegistrationClosed__c =false';
                System.debug('queryUserCenterMapping---'+queryUserCenterMapping);
            
            List<nm_UserMapping__c> lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
            
            if(lstUserCenterMapping.size() > 0){
                for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
                    if(!mapOfCenterIdVsCenterUserMapping.containsKey(objCenteruserMapping.nm_Centers__c)){
                        mapOfCenterIdVsCenterUserMapping.put(objCenteruserMapping.nm_Centers__c,new List<nm_UserMapping__c>());
                    }
                    mapOfCenterIdVsCenterUserMapping.get(objCenteruserMapping.nm_Centers__c).add(objCenteruserMapping);
                }
            }
            
                for(Lead objLead : lstLead){
                
                 if(mapOfCenterIdVsCenterUserMapping.containsKey(objLead.nm_InformationCenter__c)){
                     
                    List<nm_UserMapping__c> lstUserMapping = mapOfCenterIdVsCenterUserMapping.get(objLead.nm_InformationCenter__c);
                    Id centerOwnerId = null;
                    Id centerHeadId = null;
                    
                    if(lstUserMapping !=null && lstUserMapping.size() > 0)
                    {   for(nm_UserMapping__c objuser :lstUserMapping )
                        {
                            if(objuser.nm_ChooseaProgram__c!=null)
                            {
                                for(string program : objuser.nm_ChooseaProgram__c.split(';'))
                                {
                                  if(!mapProgramAndUser.containsKey(program))
                                  {
                                                    mapProgramAndUser.put(program,new List<nm_UserMapping__c>());
                                                    mapProgramAndUser.get(program).add(objuser);            
                                  }else
                                  {
                                    mapProgramAndUser.get(program).add(objuser);            
                                  }                
                                }
                            }

                           if(objuser.nm_Head__c)
                            {
                               centerHeadId = objuser.nm_user__c;
                            } 
                            
                            SetCentuserId.add(objuser.id);            
                        }
                        Integer i = 0;
                        if(!mapProgramAndUser.Isempty())
                        {
                            lstUserMapping2 = mapProgramAndUser.get(objLead.nm_ChooseaProgram__c);
                        }
                        if (lstUserMapping2 != null && lstUserMapping2.size() > 0) 
                        {
                             for(nm_UserMapping__c obj :lstUserMapping2){
                                    MapOfRoundRobinIds.put(i,obj.nm_user__r.id);
                                    System.debug(i+'------'+obj.nm_user__r.Name);
                                    i++;
                                }
                                maxnumber =  (Integer)Math.floor(100 + Math.random()*90);
                                System.debug('User Number Round Robin--'+math.mod(integer.valueOf(maxnumber),lstUserMapping2.size()));
                                centerOwnerId = MapOfRoundRobinIds.get((integer)(math.mod(integer.valueOf(maxnumber),lstUserMapping2.size())));
                                System.debug('OwnerId--->'+objLead.OwnerId);
                       
                        }
                        centerOwnerId = centerOwnerId!=null?centerOwnerId:centerHeadId ;
                        System.debug('centerOwnerId---'+centerOwnerId+'---LeadOwnerId---'+objLead.OwnerId);
                        if(centerOwnerId!=null && !SetCentuserId.contains(objLead.OwnerId)){
                            objLead.OwnerId = centerOwnerId;
                            lstLeadToUpdate.add(objLead);
                        }
                    }
                }
            }
            
            if(lstLeadToUpdate.size() > 0){
                update lstLeadToUpdate;
            }
        }
    }*/
}