/**
 * @File Name          : ConnecToTriggerHandler.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 23-01-2024
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/30/2019, 11:53:37 AM   shubhranshu     Initial Version
**/
public class ConnecToTriggerHandler{

    ConnecToHelperClass connecToHelper = new ConnecToHelperClass();
    List<nm_Centers__c> lstActiveCenters = new List<nm_Centers__c>();
    Map<Id,nm_Centers__c> mapOfCenterIdVsCenter = new Map<Id,nm_Centers__c>();
    Map<String,nm_Centers__c> mapOfCenterNameVsCenter = new Map<String,nm_Centers__c>();

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
                        this.mapOfCenterNameVsCenter.put(assignIcTOLC.tolowercase().trim(),objCenter );
                       }

                   }
                    this.mapOfCenterNameVsCenter.put(objCenter.Name.tolowercase(),objCenter);
                }
            }
        }
        system.debug('this.mapOfCenterNameVsCenter --> ' + this.mapOfCenterNameVsCenter);
        return this.mapOfCenterNameVsCenter;
    }

    public string addInformationCenterBasedOnCurrentLocation(String City) {
    Map<String, nm_Centers__c> mapOfCenterNameVsCenter1 = getMapOfCenterNameVsCenter();
     if (
      City != null &&
      City != '' &&
      mapOfCenterNameVsCenter1.containsKey(City) &&
      mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c != null &&
      mapOfCenterNameVsCenter1.get(City).nm_ChooseaProgram__c != '' &&
      mapOfCenterNameVsCenter1.get(City).RegistrationClosed__c == false
    ) {
      nm_Centers__c objCenter1 = mapOfCenterNameVsCenter1.get(City);
      return String.valueof(objCenter1.Id);
    }
    return mapOfCenterNameVsCenter1.get('Counsellor').Id;
  }
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @return void
    */
    public void BeforeInsert(list<Connecto__c> triggerNew){
        ValidateConnectoRecord(triggerNew);
        FillInformationCenterBasedUponSelectedCity(triggerNew);
    }  

    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @param map<id, Connecto__c> triggerOldMap
    * @return void
    */
    public void AfterUpdate(list<Connecto__c> triggerNew,map<id,Connecto__c> triggerOldMap){
        UpdateTaskOwner(triggerNew,triggerOldMap);
    }  

    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @param map<id, Connecto__c> triggerOldMap
    * @return void
    */
    public void BeforeUpdate(list<Connecto__c> triggerNew , map<id,Connecto__c> triggerOldMap){
        CheckExistingLeadEmail(triggerNew);
        CheckExistingAccountEmail(triggerNew);
        UpdateConnectToOwner(triggerNew,triggerOldMap);
        InsertLeadWhenAllFieldValid(triggerNew,triggerOldMap);  
            
    }
    
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @return void
    */
    public void ValidateConnectoRecord(list<Connecto__c> triggerNew){

        boolean CheckExistingLeadMobile;
        boolean CheckExistingLeadEmail;
        boolean CheckExistingRecordConnecTo;    
        boolean CheckExistingAccountMobile = false;
        
        for(Connecto__c objConnecTo :triggerNew){

            CheckExistingLeadEmail = connecToHelper.CheckExistingLeadEmail(objConnecTo.Email_ID__c);      
            CheckExistingLeadMobile = connecToHelper.CheckExistingLeadBasedOnMobileNum(objConnecTo.Mobile_Number__c);
            System.debug('<----------CheckExistingLeadMobile------->'+CheckExistingLeadMobile);
            CheckExistingAccountMobile = connecToHelper.CheckExistingAccountBasedOnMobileNum(objConnecTo.Mobile_Number__c);
            System.debug('<----------CheckExistingAccountMobile------->'+CheckExistingAccountMobile);
            CheckExistingRecordConnecTo = connecToHelper.CheckConnectToRecordForDuplicateMobile(objConnecTo.Mobile_Number__c);
            System.debug('value of round robin id '+objConnecTo.Round_Robin_ID__c);
            if(CheckExistingLeadMobile == false){
                objConnecTo.nm_ExistingLead__c =true;
                objConnecTo.Status__c='Existing Lead';
                objConnecTo.Qualified__c=false;
               connecToHelper.updateExistingLeadTORebornFromMobileNo(objConnecTo.Mobile_Number__c);

            }
            
            if(CheckExistingAccountMobile){
                objConnecTo.Status__c='Existing Account';
                objConnecTo.Qualified__c=false;
                objConnecTo.nm_ExistingLead__c =false;
            }

            if(CheckExistingRecordConnecTo == false){
                objConnecTo.Duplicate_ConnecTo_Record__c = true; 
            }
            if(CheckExistingLeadEmail == false){
                objConnecTo.Status__c = 'Existing Lead';
                objConnecTo.nm_ExistingLead__c = true;
                 connecToHelper.updateExistingLeadTORebornFromEmail(objConnecTo.Email_ID__c);

            }
        }   
    }
        
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @return void
    */
    public void FillInformationCenterBasedUponSelectedCity(list<Connecto__c> triggerNew){

        for(Connecto__c objConnecTo :triggerNew){
            if(String.isNotBlank(objConnecTo.City__c) ) {
                 String inFormationCenterId = addInformationCenterBasedOnCurrentLocation(objConnecTo.City__c.tolowercase().trim());
                List<nm_UserMapping__c> userMapped = [select nm_User__c from nm_UserMapping__c where nm_Centers__c=:inFormationCenterId];
                if(userMapped.size() > 0) {
                    objConnecTo.ownerId = userMapped[0].nm_User__c;    
                    objConnecTo.Center__c = inFormationCenterId;
                }
            } else {
                List<nm_Centers__c> objCenter =[select id,OwnerId  from nm_Centers__c where name ='Counsellor'];
                system.debug('objCenter --> ' + objCenter);
                List<nm_UserMapping__c> userMapped = [select nm_User__c from nm_UserMapping__c where nm_Centers__c=:objCenter[0].id]; 
                System.debug('Enter In Loop');
                if(userMapped.size() > 0) {
                    objConnecTo.ownerId = userMapped[0].nm_User__c;
                    objConnecTo.Center__c = objCenter[0].id;
                }
            }
        }
    }     

    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @param map<id, Connecto__c> triggerOldMap
    * @return void
    */
    public void InsertLeadWhenAllFieldValid(list<Connecto__c> triggerNew,map<id,Connecto__c> triggerOldMap){        
        boolean checkIfCenterIsActive;
        for(Connecto__c connect:triggerNew){

            checkIfCenterIsActive = connecToHelper.CheckIfCenterIsActive(connect.Center__c);
            Connecto__c oldValOfConnect = triggerOldMap.get(connect.id);
            if(connect.Status__c=='Existing Account'){
                connect.Qualified__c =false;
                connect.nm_ExistingLead__c =false;
            }else{
                if(connect.nm_FirstName__c!=null&& 
                    connect.nm_LastName__c!=null && 
                    connect.nm_ChooseaProgram__c!=null &&
                    connect.Center__c!=null && 
                    connect.Email_ID__c!='' && 
                    connect.Status__c !='Existing Lead' &&
                    connect.Lead_Description__c!=null &&                             
                    connect.Status__c !='Incomplete Detail' &&
                    !connect.Qualified__c && connect.Status__c !='Lead Created')
                {
                    connect.Qualified__c=true;
                
                    lead objLead = new Lead();
                    objLead.FirstName=connect.nm_FirstName__c;
                    objLead.LastName=connect.nm_LastName__c;
                    objLead.Status =Connect.Status__c;
                    objLead.Email=Connect.Email_ID__c;
                    objLead.MobilePhone=oldValOfConnect.Mobile_Number__c;
                    objLead.nm_ChooseaProgram__c=connect.nm_ChooseaProgram__c;
                    // new changes added for selected program and from URL
                    objLead.nm_SelectedProgram__c = connect.Selected_Program__c;
                    // objLead.nm_Site__c = connect.From_URL__c; 
                    
                    objLead.nm_InformationCenter__c=Connect.Center__c;
                    objLead.LeadSource='Web';
                    if(connect.Agency_Name__c!=null && connect.Agency_Name__c!='' ){
                        objLead.Agency__c= connect.Agency_Name__c ;
                    }else{
                        objLead.Agency__c='Connecto';
                    }
                    objLead.Lead_Description__c=connect.Lead_Description__c;
                    objLead.Reason_for_Others__c= connect.Reason_for_Others__c;
                    objLead.Description=connect.Description__c;
                    objLead.Connecto__c=connect.id;
                                        
                                        
                    if(checkIfCenterIsActive == false){
                        connect.addError('The Center is not Active. Please change the information Center before inserting lead');
                        return;
                    }else{
                        try{
                            insert objLead;
                            System.debug('objLead '+objLead);
                        }catch(Exception e){
                            connect.addError('Duplicate Value Of Email/Mobile Found.Kindly Update The ConnecToStatus to Existing Lead');
                        }
                    }
                    Connect.Status__c='Lead Created';
                }
                else if(connect.nm_FirstName__c==null || 
                        connect.nm_LastName__c==null || 
                        connect.nm_ChooseaProgram__c==null ||
                        connect.Email_ID__c=='')
                    {
                        if(Connect.Status__c !='Invalid Number' && Connect.Status__c !='Not Contacted' && Connect.Status__c !='Not Interested' && Connect.Status__c !='No Response' && Connect.Status__c!='Existing Lead' && Connect.Status__c!='Reborn')
                        {
                            Connect.Status__c ='Incomplete Detail';
                        }
                    }
                    else
                    {
                        if(connect.Status__c == 'Incomplete Detail')
                        {
                        connect.addError('Please change the status of Lead'); 
                        }    
                    }
            } 
        }
    }
       
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @param map<id, Connecto__c> triggerOldMap
    * @return void
    */
    public void UpdateConnectToOwner(list<Connecto__c>triggerNew, map<id,Connecto__c> triggerOldMap){
        for(Connecto__c objConnecTo:triggerNew){
            if(triggerOldMap.get(objConnecTo.id).Center__c != objConnecTo.Center__c)
            {
                nm_UserMapping__c userMapped =new nm_UserMapping__c();
                nm_Centers__c centerval = [select id,OwnerId,nm_LearningCenter__c,nm_LearningCenter__r.name,name from nm_Centers__c where id=:objConnecTo.Center__c];
                System.debug('Learning center Id ---->'+centerval.nm_LearningCenter__c);                    
                if(centerval.nm_LearningCenter__c !=null){
                    userMapped = [select nm_User__c from nm_UserMapping__c where nm_Centers__c =:centerval.nm_LearningCenter__c and nm_Head__c =true limit 1];
                    objConnecTo.City__c =centerval.nm_LearningCenter__r.name;
                }else{
                    userMapped = [select nm_User__c from nm_UserMapping__c where nm_Centers__c=:centerval.id and nm_Head__c =true limit 1];
                    objConnecTo.City__c =centerval.name;
                }
                objConnecTo.Center__c = centerval.id;
                objConnecTo.ownerId = userMapped.nm_User__c; 
            }
        }              
    }
       
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @return Void
    */
    public Void CheckExistingLeadEmail(list<Connecto__c>triggerNew){
        boolean checkEmailForLead;
        for(Connecto__c connect:triggerNew){
            checkEmailForLead = connecToHelper.CheckExistingLeadEmail(connect.Email_ID__c);
            if(checkEmailForLead == false){
                    connect.nm_ExistingLead__c =true;
                    connect.Status__c='Existing Lead';
                    connect.Qualified__c=false;
            }
        }
    }
        
       
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @return Void
    */
    public Void CheckExistingAccountEmail(list<Connecto__c>triggerNew){
        boolean checkEmailForAccount;
        for(Connecto__c connect :triggerNew){
            checkEmailForAccount = connecToHelper.CheckExistingAccountEmail(connect.Email_ID__c);
            if(checkEmailForAccount){
                System.debug('Existing Account updated');
                connect.Status__c='Existing Account';
                connect.Qualified__c=false;
                connect.nm_ExistingLead__c =false;
            }   
        }
    }
       
    /**
    * @description
    * @author shubhranshu | 8/30/2019
    * @param list<Connecto__c> triggerNew
    * @param map<id, Connecto__c> triggerOldMap
    * @return void
    */
    public void UpdateTaskOwner(list<Connecto__c>triggerNew,map<id,Connecto__c>triggerOldMap){
        set<id>SetOwnerId=new set<id>();
        map<id,id>MapForUpdateTaskOwner=new map<id,id>();
        for(Connecto__c objConnecTo :TriggerNew){
            if(triggerOldMap !=null){
                System.debug('Enter In OldMap Loop Of Task Update');
                if(objConnecTo.OwnerId!=triggerOldMap.get(objConnecTo.id).OwnerId){
                    MapForUpdateTaskOwner.put(objConnecTo.id,objConnecTo.OwnerId);
                    SetOwnerId.add(objConnecTo.id);
                }
            }   
            if(SetOwnerId.size()>0){
                list<Task>lstTask=[Select Id, who.name, who.id, owner.id, owner.name,what.id From task where what.id in: MapForUpdateTaskOwner.keyset()]; 
                if(lstTask.size()>0){
                    list<Task>TaskToUpdate=new list<Task>();
                    for(Task objTask:lstTask){
                        objTask.ownerId=MapForUpdateTaskOwner.get(objConnecTo.id);
                        TaskToUpdate.add(objTask);
                    }
                    if(TaskToUpdate.size()>0){
                        try{
                        update TaskToUpdate;
                        }catch(DmlException e){
                            System.debug(e.getMessage());
                        }
                    }  
                }
            }
        }
    }           

     //<------------------------Phalguni commented as Connecto agency name wont able to capture------------------------------------------------------------------>//    
    /*   public void InsertLeadWhenAllFieldValid(list<Connecto__c>triggerNew,map<id,Connecto__c>triggerOldMap)
       {
                boolean checkIfCenterIsActive;
                for(Connecto__c connect:triggerNew)
                {
                        checkIfCenterIsActive = connecToHelper.CheckIfCenterIsActive(connect.Center__c);
                        Connecto__c oldValOfConnect = triggerOldMap.get(connect.id);
                       
                        if(connect.Status__c=='Existing Account')
                        {
                            connect.Qualified__c =false;
                            connect.nm_ExistingLead__c =false;
                        }
                        else 
                        {
                            if(connect.nm_FirstName__c!=null&& 
                               connect.nm_LastName__c!=null && 
                               connect.nm_ChooseaProgram__c!=null &&
                               connect.Center__c!=null && 
                               connect.Email_ID__c!='' && 
                               connect.Status__c !='Existing Lead' &&
                               connect.Lead_Description__c!=null &&                             
                               connect.Status__c !='Incomplete Detail' &&
                               !connect.Qualified__c && connect.Status__c !='Lead Created')
                            {
                            connect.Qualified__c=true;
                            
                            lead objLead = new Lead(FirstName=connect.nm_FirstName__c,
                                                    LastName=connect.nm_LastName__c,
                                                    Status =Connect.Status__c,
                                                    Email=Connect.Email_ID__c,
                                                    MobilePhone=oldValOfConnect.Mobile_Number__c,
                                                    nm_ChooseaProgram__c=connect.nm_ChooseaProgram__c,
                                                    nm_InformationCenter__c=Connect.Center__c,
                                                    LeadSource='Web',Agency__c= connect.Agency_Name__c ,
                                                    Lead_Description__c=connect.Lead_Description__c,
                                                   Reason_for_Others__c= connect.Reason_for_Others__c,
                                                    Description=connect.Description__c,
                                                    Connecto__c=connect.id);
                                        if(checkIfCenterIsActive == false)
                                        {
                                            connect.addError('The Center is not Active. Please change the information Center before inserting lead');
                                            return;
                                        }
                                        else{
                                         try{
                                       insert objLead;
                                       }     
                                       catch(Exception e){
                                       connect.addError('Duplicate Value Of Email/Mobile Found.Kindly Update The ConnecToStatus to Existing Lead');
                                       }
                                        }
                                      
                                       Connect.Status__c='Lead Created';
                            
                            }
                            else if(connect.nm_FirstName__c==null || 
                                   connect.nm_LastName__c==null || 
                                   connect.nm_ChooseaProgram__c==null ||
                                   connect.Email_ID__c=='')
                             {
                                    if(Connect.Status__c !='Invalid Number' && Connect.Status__c !='Not Contacted' && Connect.Status__c !='Not Interested' && Connect.Status__c !='No Response' && Connect.Status__c!='Existing Lead')
                                    {
                                       Connect.Status__c ='Incomplete Detail';
                                    }
                             }
                             else
                             {
                                  if(connect.Status__c == 'Incomplete Detail')
                                  {
                                    connect.addError('Please change the status of Lead'); 
                                  }    
                             }
                         } 
                    }

           }*/
}