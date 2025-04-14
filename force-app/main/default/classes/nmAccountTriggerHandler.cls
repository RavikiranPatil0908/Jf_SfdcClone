/**
 * @File Name          : nmAccountTriggerHandler.cls
 * @Description        : 
 * @Author             : phalguni
 * @Group              : 
 * @Last Modified By   : @Shailesh
 * @Last Modified On   : 04-04-2025
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    21/1/2020   phalguni     Initial Version
**/
// This Class is used as a trigger handler for trigger on Account
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        4-Mar-2014      Neeraj Chauhan           Initial Version
// ---------------------------------------------------------------------------------------------
public class nmAccountTriggerHandler
{
    public static boolean IsAfterInsertRunOnce = false;
    public static boolean IsAfterUpdateRunOnce = false;
    public static boolean IsBeforeInsertRunOnce = false;
    public static boolean IsBeforeUpdateRunOnce = false; 
    
    //DocumentHelperClass documentHelper = new DocumentHelperClass();
    nmLinksForDocumentStatusHandler nmDocHandler = new nmLinksForDocumentStatusHandler();
    
   
    ProductHelper  ProductHelper = new ProductHelper();
    cancelStudentHeplerClass cancelAdm = new cancelStudentHeplerClass();
    List<nm_UserMapping__c> lstUserCenterMapping = new List<nm_UserMapping__c> ();
    Map<Id,Id> MapOfCenterIdVsUserId = new Map<Id,Id>();
    Map<Id,Counsellor_Profile__c> mapOfCounseloridVsCounselorProfile = new Map<Id,Counsellor_Profile__c>();
    List<Counsellor_Profile__c> lstAllCP = new List<Counsellor_Profile__c> ();
     Map<Id,LateralProgramSkipSem__c> mapOfProgramIdVsProgram = new Map<Id,LateralProgramSkipSem__c>();
     Map<Id,List<LateralProgramSkipSem__c>> mapOfNewProgramVsList = new Map<Id,List<LateralProgramSkipSem__c>>();
     List<LateralProgramSkipSem__c> lstAllProgram = new List<LateralProgramSkipSem__c>();
     
    public void AfterInsert(List<Account> triggerNew, map<id, Account> mapAccountNewMap)
    {
        // Method to insert document records as well as for transfer uploaded document from Lead to account
        nmDocHandler.DocumentCreationOnAccount(triggerNew);
        //Method to transfer work experiance lead to account
        updateWorkExperiance (triggerNew);
        
        //Method to transfer Cases from lead to account
        updateCase(triggerNew);

        //Method to transfer Apirequest from lead to account
        updateTranferApirequestfromLeadtoAcc(triggerNew);

        //Method to transfer Student Rating lead to account
        updateStudentRating(triggerNew);

        //Method to transfer AEP Request lead to account
        updateAEPRequest(triggerNew);
        checkForLateralValidation(triggerNew, mapAccountNewMap,'Insert');
        
         ChkLateralFutureSemvs2(triggerNew, mapAccountNewMap,'Insert');

        updateDEBDetails(triggerNew);
        // To update Account and opportunity Owner
       // UpdateAccToOpp(triggerNew,mapAccountNewMap,'Insert');
       UpdateOppOwner(triggerNew,mapAccountNewMap,'Insert');
    }
    
    public void BeforeInsert(List<Account> triggerNew, map<id, Account> mapAccountOldMap)
    {
        //Method to Change the Account owner when one changes the IC/LC
        UpdateAccountOwnerId(triggerNew, mapAccountOldMap);
    } 
    
    public void BeforeUpdate(List<Account> triggerNew, map<id, Account> mapAccountOldMap)
    {
    
    
        // AvoidDuplicateMobileNumberandEmailwithAccount(triggerNew,mapAccountOldMap);
        //Method to Change the Account owner when one changes the IC/LC
        UpdateAccountOwnerId(triggerNew, mapAccountOldMap);
        //call method to update shipping address based upon shipping address choice
        copyAddress(triggerNew);
       // NotAllowtowaiveOffStudent(triggerNew, mapAccountOldMap);
        // call a Method To Update Number Of Times Document Stage Updated for Same Status(eg.Document Disapproved,Document Submitted,Document Approved)
   //     documentHelper.UpdateDocumentStatusCountOnAccount(triggerNew,mapAccountOldMap);
       // UpdateMobileAndEmailVerifyDateTime(triggerNew,mapAccountOldMap);
 
    } 
    
    public void AfterUpdate(List<Account> triggerNew, map<id, Account> mapAccountOldMap)
    {
        if(IsAfterUpdateRunOnce && triggerNew.size() < 25){
            return;
        }
        
        IsAfterUpdateRunOnce = true;
        // call method to Update Document on Account Confirmed and ProvisionalWithHold is true
        nmDocHandler.UpdateLinksForDocumentsProvisionalWithHoldAccount(triggerNew, mapAccountOldMap);

        UpdateDefenceProductPrice(triggerNew,mapAccountOldMap); 
        // call method to Update Document on Account after Change In Criteria 
        UpdateDocumentsForChangeInEligibilityCriteria(triggerNew,mapAccountOldMap, 'UPDATE'); 
        
        // call method to update Tsk Owner In case of Information center change or owner change
        UpdateTask(triggerNew,mapAccountOldMap);
       
        //Method to Change the Account owner when one changes the IC/LC
        documentApproval(triggerNew,mapAccountOldMap);  
       // NotAllowtowaiveOffStudent(triggerNew, mapAccountOldMap);
       
        //method to Send Mobile Number verification SMS and Verification Email  
        sendMobileAndEmailVerificationMsg(triggerNew,mapAccountOldMap);
        
        // method to AutoUpdate State and Country based upon PostalCode
        autoAupdateStateAndCountryBasedUponPostalCode(triggerNew,mapAccountOldMap);
        

        //method to create account as a lead in leadsquare.
       // createLeadInLeadSquare(triggerNew);
       
       //To capture Document Submitted on update.
        // updateDocumentSubmittedDate(triggerNew,mapAccountOldMap);
       // Update Documents on Account with respect to lateral and program changes.
        checkforLateralAndProgramChanges(triggerNew,mapAccountOldMap);

        //Update Document change on Differently Abled
        checkForDifferentlyAbledChanges(triggerNew,mapAccountOldMap);
        //Update Document change on cast certificate
        checkForCastDocumentChanges(triggerNew,mapAccountOldMap);
        
       // UpdateAccountOwnerId(triggerNew, mapAccountOldMap);
        // call CancelAdmissionHelper Class if any need of cancel studnet
        callCancelStudentHelperClass(triggerNew,mapAccountOldMap);

        checkForLateralValidation(triggerNew, mapAccountOldMap,'Update');

        // callFindabilityWebservice(triggerNew,mapAccountOldMap);

         // To update Account and opportunity Owner
        // UpdateAccToOpp(triggerNew,mapAccountOldMap,'Update');
        UpdateOppOwner(triggerNew,mapAccountOldMap,'Update');

        
    }

    // after registration Payment if Student Opt for Defence Discount then update Product Price and Fee type on opportunity as Annual or PG Option not available for Defence  
  /*  public void UpdateDefenceProductPrice(List<Account> lstAccount,map<id, Account> accountOldMap) 
    {
       set<string> Accid=new set<string>();  
       if(lstAccount.size()>0 && lstAccount!=null)
       {
           for(Account objacc:lstAccount)
           {
              if(objacc.nm_DefencePersonnel__c!=accountOldMap.get(objacc.id).nm_DefencePersonnel__c)
              {
                Accid.add(objacc.id);
                system.debug('Account id is'+Accid);
              }
           }
           if(Accid.size()>0)
           {
               list<Opportunity> lstOpp=[select id,nm_Semester__c,nm_Fee_Type__c,AccountId,Account.nm_DefencePersonnel__c,nm_Program__c  from Opportunity where Accountid In :Accid];
               system.debug('Opp is '+lstOpp.size());
               if(lstOpp.size()>0)
               {
                  for(Opportunity objOpps : lstOpp)
                  {
                      if(objOpps.Account.nm_DefencePersonnel__c =='Yes')
                      {
                          if(objOpps.nm_Fee_Type__c !='admission')
                          {
                               Opportunity objOppToUpdate = new Opportunity(id =objOpps.id);
                               objOppToUpdate.nm_Fee_Type__c ='admission';
                               update objOppToUpdate;
                          }else
                          {
                              // calling update Opportunity Line Item if Fee type Not Change and Defence flag Yes
                              productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps);
                          }
                       }else// if Defence flag change from Yes to No then Update Product price to Admission
                       {
                           productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps);
                       } 
                  }   
               }    
           }    
       }
    }*/
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
    public List<nm_UserMapping__c> getlstUserCenterMapping(){
        if(this.lstUserCenterMapping.isEmpty()){
           system.debug('UserMaping call out');
           String queryUserCenterMapping = getQueryAllFieldSql('nm_UserMapping__c',' nm_Centers__c !=null and nm_Head__c = true','nm_Centers__r.Name,nm_user__r.Email,nm_user__r.id,nm_user__r.Name');
            this.lstUserCenterMapping = DataBase.query(queryUserCenterMapping);
        }       
        return this.lstUserCenterMapping;
    }
     public Map<Id,Id> getMapOfCenterIdVsUserId(){      
        if(this.MapOfCenterIdVsUserId.isEmpty()){       
          List<nm_UserMapping__c> lstUserCenterMapping = getlstUserCenterMapping();
            if(this.lstUserCenterMapping.size() > 0){
                for(nm_UserMapping__c objCenteruserMapping : lstUserCenterMapping){
                    this.MapOfCenterIdVsUserId.put(objCenteruserMapping.nm_Centers__c,objCenteruserMapping.nm_User__c);
                }
            }
        }
        return this.MapOfCenterIdVsUserId;
    }
    public Map<id,Counsellor_Profile__c> getMapAllCounsellor (){
        if(this.mapOfCounseloridVsCounselorProfile.isEmpty()){
            String CounsellorProfile = getQueryAllFieldSql('Counsellor_Profile__c','Name!=null',null);
               this.mapOfCounseloridVsCounselorProfile = new Map<id,Counsellor_Profile__c>((List<Counsellor_Profile__c>)DataBase.query(CounsellorProfile));
               system.debug('mapOfCounseloridVsCounselorProfile -->'+mapOfCounseloridVsCounselorProfile );
            this.lstAllCP = mapOfCounseloridVsCounselorProfile.values() ;
        }       
        return this.mapOfCounseloridVsCounselorProfile;
    }
         public List<LateralProgramSkipSem__c> getlstAllProgram (){
        if(this.lstAllProgram.isEmpty()){
            String ProgramQuery = getQueryAllFieldSql('LateralProgramSkipSem__c','OldProgram__c!=null',null);
               this.mapOfProgramIdVsProgram = new Map<id,LateralProgramSkipSem__c>((List<LateralProgramSkipSem__c>)DataBase.query(ProgramQuery));
               system.debug('mapOfProgramIdVsProgram -->'+mapOfProgramIdVsProgram );
            this.lstAllProgram = mapOfProgramIdVsProgram.values() ;
        }       
        return this.lstAllProgram;
    }
    public Map<Id,List<LateralProgramSkipSem__c>> getMapOfProgramNameVsProgram(){
        if(this.mapOfNewProgramVsList.isEmpty() || this.mapOfProgramIdVsProgram.isEmpty()){
            
             List<LateralProgramSkipSem__c>  lstPrograms = getlstAllProgram(); 
            if(lstPrograms.size() > 0){
                for(LateralProgramSkipSem__c objProgram : lstPrograms){
                    
                if(!this.mapOfNewProgramVsList.containsKey((objProgram.New_Program_opt__c))){
                     this.mapOfNewProgramVsList.put(objProgram.New_Program_opt__c,new List<LateralProgramSkipSem__c>());
                 }
                this.mapOfNewProgramVsList.get(objProgram.New_Program_opt__c).add(objProgram);
                  
                }
            }
        }
        return this.mapOfNewProgramVsList;
    }
      // after registration Payment if Student Opt for Defence Discount then update Product Price and Fee type on opportunity as Annual or PG Option not available for Defence  
      // after registration Payment if Student Opt for Defence Discount then update Product Price and Fee type on opportunity as Annual or PG Option not available for Defence  
    public void UpdateDefenceProductPrice(List<Account> lstAccount,map<id, Account> accountOldMap) 
    {
       set<string> Accid=new set<string>();  
       set<string> setOfOppsId=new set<string>(); 
       if(lstAccount.size()>0 && lstAccount!=null)
       {    
            Id criteriaId;
            String AccountId;
           for(Account objacc:lstAccount)
           {    
              criteriaId = objAcc.nm_EligiblityCriteria__c;
              AccountId = objAcc.id;
              if((objacc.nm_DefencePersonnel__c!=accountOldMap.get(objacc.id).nm_DefencePersonnel__c) || (objacc.HSC_status__c!=accountOldMap.get(objacc.id).HSC_status__c))
              {
                Accid.add(objacc.id);
                system.debug('Account id is'+Accid);
                
                //calling UpdateDocumentSubmittedStatusOnAccount method for update student
                nmDocHandler.UpdateDocumentsOnAccountForChangeInEligibilityCriteria(lstAccount,criteriaId,AccountId);
              }
           }
           if(Accid.size()>0)
           {
               list<Opportunity> lstOpp=[select id,RegistrationFee__c ,Sem__c,BacklogList__c,IsTerm__c,PVM__c,Total_Sem__c,Choose_a_Program__c,LiveLecturesType__c,CourseList__c,ConsumerType__c,Program_Structure__c,ChooseProgram__c,Specialisation__c,Account.OldStudentForExecutive__c,nm_Semester__c,Account.Name,IC__c,Processed__c,nm_Fee_Type__c,StageName,AccountId,Account.nm_DefencePersonnel__c,nm_Program__c,Program_Name__c from Opportunity where Accountid In :Accid];
               system.debug('Opp is '+lstOpp.size());
               if(lstOpp.size()>0)
                {
                  for(Opportunity objOpps : lstOpp)
                    {
                    //20% discount if Defence or old student for Executive Program
                      if(objOpps.Account.nm_DefencePersonnel__c =='Yes'|| objOpps.Account.OldStudentForExecutive__c==true)
                       {                         
                                // calling update Opportunity Line Item if Fee type Not Change and Defence flag Yes
                             // productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps,objOpps.Program_Name__c);
                             Callproducthelper(objOpps);
                         
                       }else// if Defence flag change from Yes to No then Update Product price to Admission
                       {
                          // productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps,objOpps.Program_Name__c);
                          Callproducthelper(objOpps);
                       } 
                       //Check for Debit entry required based on Defence Personnel change
                       //Move to producthelper
                      /*  if(objOpps.StageName=='Closed Won' && objOpps.Processed__c == true &&  !objOpps.nm_Fee_Type__c.contains('-Considered')) 
                        {                                                                            
                             productHelper.CheckForAdjustmentDebit(setOfOppsId ,objOpps); 
                        } */
                    }   
                }    
           }    
       }
    }
    
    //public void ChkLateralFutureSem(List<Account> lstAccount,Map<Id,Account> accountOldMap,String activity){
    /* public void ChkLateralFutureSem(List<Account> lstAccount){
    {
        system.debug('ChkLateralFutureSem called');
        List<Account> lstOldAccountOfLateral = new List<Account>();
        List<Account> lstAccountToUpdate = new List<Account>();
        List<nm_Program__c> prgList=new List<nm_Program__c>();
         set<String> SetOldAcc = new set<String>();
        
        prgList=[select id,Name from nm_Program__c where Name in ('PCDM','PDDM','C-SEM & SMM','C-SEM & DMA', 'C-SMM & DMA')];
         if(lstAccount.size()>0){
            for(Account objacc:lstAccount ){
            system.debug('lstAccount ==> ' + lstAccount);
                if(objacc.OldAccount__c!=null){
                    SetOldAcc.add(String.valueOf(objacc.OldAccount__c));
                       system.debug('SetOldAcc==> ' + SetOldAcc);
                }
            }
         }
         map<Id,String> mapOfoldAccount = new Map<Id,String>();
          map<ID,String> mapOfProg = new Map<Id,String>();
          if(SetOldAcc.size() > 0) {
                lstOldAccountOfLateral = [select id,nm_Program__c,nm_Program__r.Name,OldAccount__c,OldAccount__r.nm_Program__r.Name from Account where OldAccount__c IN:SetOldAcc];
            }
        if(prgList.size() > 0)
        {
            for(nm_Program__c ob:prgList)
            {
                mapOfProg.put(ob.Id,ob.Name);
            }
            
        }
            
              if(lstOldAccountOfLateral.size() > 0) {
                for (Account acc : lstOldAccountOfLateral) {
                    //mapOfoldAccount.put(acc.Id,String.valueOf(acc.nm_Program__r.Name));
                    mapOfoldAccount.put(acc.OldAccount__c,String.valueOf(acc.OldAccount__r.nm_Program__r.Name));
                    //mapOfAccountID.put(acc.Id,acc.OldAccount__c);
                }
                system.debug('mapOfoldAccount==>'+mapOfoldAccount);
            }
            for(Account objacc:lstAccount ){
                system.debug('String.valueOf(objacc.OldAccount__c)==>'+String.valueOf(objacc.OldAccount__c));
                system.debug('mapOfoldAccount.get(objacc.OldAccount__c)==>'+mapOfoldAccount.get(objacc.OldAccount__c));
                system.debug('objacc.nm_Program__c==>'+objacc.nm_Program__c);
                
            if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-SMM & DMA' && mapOfProg.get(objacc.nm_Program__c)=='PCDM' )
            {
                system.debug('Inside If 1');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-SMM & DMA' && mapOfProg.get(objacc.nm_Program__c)=='PDDM' )
            {
                system.debug('Inside If 2');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-SMM' && mapOfProg.get(objacc.nm_Program__c)=='C-SEM & SMM' )
            {
                system.debug('Inside If 3');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-SMM' && mapOfProg.get(objacc.nm_Program__c)=='PCDM' )
            {
                system.debug('Inside If 4');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-SMM' && mapOfProg.get(objacc.nm_Program__c)=='PDDM' )
            {
                system.debug('Inside If 5');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
           else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-DMA' && mapOfProg.get(objacc.nm_Program__c)=='C-SEM & DMA' )
            {
                system.debug('Inside If 6');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-DMA' && mapOfProg.get(objacc.nm_Program__c)=='C-SMM & DMA' )
            {
                system.debug('Inside If 7');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '2';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-DMA' && mapOfProg.get(objacc.nm_Program__c)=='PCDM' )
            {
                system.debug('Inside If 8');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '3';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            else if(mapOfoldAccount.containsKey(String.valueOf(objacc.OldAccount__c))&& mapOfoldAccount.get(objacc.OldAccount__c) =='C-DMA' && mapOfProg.get(objacc.nm_Program__c)=='PDDM' )
            {
                system.debug('Inside If 9');
                      Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objacc.Id;
                        UpdateoBjAcc.Future_Sem_To_Skip__c = '3';
                        lstAccountToUpdate.add(UpdateoBjAcc);
            }
            }
         if(lstAccountToUpdate.size() > 0) {
            update lstAccountToUpdate;
        }
    }
    }*/
    
     public void ChkLateralFutureSemvs2(List<Account> lstAccount,map<id, Account> accountOldMap,String activity){
      
      if(lstAccount.size()>0 )
      {
          List<Account> listaccountTOupdate = new List<Account>();
          List<LateralProgramSkipSem__c> ListLateralProgramss = new List<LateralProgramSkipSem__c>();
          Set <id> setidsLateral = new Set<Id> ();


          if(activity=='Insert')
          {
            // Map<Id,List<LateralProgramSkipSem__c>> mapOfNewProgramVsList = getMapOfProgramNameVsProgram();
             
             for(Account objAccount : lstAccount )
             {
                 if(objAccount.Is_Lateral__c && objAccount.OldAccount__c!=null && objAccount.nm_Program__c !=null)
                 {
                     setidsLateral.add(objAccount.Id);
                 }
             }

  
          }
          if(activity=='Update')
          {
          System.debug('Check lateral--->');
             for(Account objAccount : lstAccount )
             {
                // Account oldAccount = Trigger.oldMap.get(objAccount.ID);

             system.debug('objAccount.nm_Program__c--->'+objAccount.nm_Program__c);
            system.debug('accountOldMap--->'+accountOldMap.get(objAccount.id).nm_Program__c);

                 if(objAccount.Is_Lateral__c && objAccount.OldAccount__c!=null && accountOldMap!=null 
                 && objAccount.nm_Program__c !=null && objAccount.nm_Program__c!= accountOldMap.get(objAccount.id).nm_Program__c )
                 {
                     setidsLateral.add(objAccount.Id);
                     system.debug('setidsLateral--->'+setidsLateral);
                 }
             }
          }
           if(setidsLateral.size()>0)
             {
                 Map<Id,List<LateralProgramSkipSem__c>> mapOfNewProgramVsList = getMapOfProgramNameVsProgram();
                 List<Account> lstacc = [select id,Future_Sem_To_Skip__c,nm_Program__c,OldAccount__r.nm_Program__c,OldAccount__c  from Account where id=:setidsLateral];
                           System.debug('Check lateral set--->'+setidsLateral);

                 if(lstacc.size()>0)
                 {
                     for(Account objacc:lstacc)
                     {
                         if(mapOfNewProgramVsList.containskey(objacc.nm_Program__c) )
                            
                         {
                            // ListLateralProgramss = mapOfNewProgramVsList.get(objAccount.nm_Program__c);
                             
                             if(lstAllProgram.size()>0)
                             {
                                 for (LateralProgramSkipSem__c objLateralSem : lstAllProgram)
                                 {
                                     if(objLateralSem.New_Program_opt__c == objacc.nm_Program__c 
                                         && objLateralSem.OldProgram__c == objacc.OldAccount__r.nm_Program__c)
                                         {
                                             objacc.Future_Sem_To_Skip__c = String.valueof(objLateralSem.Future_Sem_Skip__c);
                                             listaccountTOupdate.add(objacc);
                                         }
                                 }
                             }
                         }else if (objacc.Future_Sem_To_Skip__c!='' && !mapOfNewProgramVsList.containskey(objacc.nm_Program__c))
                         {
                               objacc.Future_Sem_To_Skip__c = '';
                               listaccountTOupdate.add(objacc);
                         }
                     }
                 }
             }
          if(listaccountTOupdate.size()>0)
             {
                 update listaccountTOupdate;
             }
      }
      
    }

     public void checkForLateralValidation(List<Account> lstAccount,Map<Id,Account> accountOldMap,String activity){
        set<String> SetOFstudent = new set<String>();
        List<Account> lstOldAccountOfLateral = new List<Account>();
        List<Account> lstAccountToUpdate = new List<Account>();
        if(lstAccount.size()>0){
            for(Account objacc:lstAccount ){
            system.debug('lstAccount ==> ' + lstAccount);
            system.debug('activity ==> ' + activity);
                if(accountOldMap !=null && objacc.Is_Lateral__c && objacc.Is_Lateral__c != accountOldMap.get(objacc.Id).Is_Lateral__c && String.isNotBlank(String.valueOf(objacc.Student_Number_Lateral__c)) &&  activity=='Update'){
                    SetOFstudent.add(String.valueOf(objacc.Student_Number_Lateral__c));
                       system.debug('SetOFstudent==> ' + SetOFstudent);
                }else if(activity=='Insert' && objacc.Is_Lateral__c && String.isNotBlank(String.valueOf(objacc.Student_Number_Lateral__c)) )
                {
                      SetOFstudent.add(String.valueOf(objacc.Student_Number_Lateral__c));
                }
            }
            map<String,Account> mapOfoldAccount = new Map<String,Account>();
            system.debug('inside isEmpty lstOldAccountOfLateral ===>'+SetOFstudent);

            if(SetOFstudent.size() > 0) {
                lstOldAccountOfLateral = [select id,Name,FirstName, LastName,Student_ID__c,Ref__c,nm_DateOfBirth__c,Student_Number_Lateral__c,OldAccount__c from Account where Ref__c IN:SetOFstudent ];   //and Pass_Out__c =true
            }

                
            if(lstOldAccountOfLateral.size() > 0) {
                for (Account acc : lstOldAccountOfLateral) {
                    system.debug('inside notEmopty lstOldAccountOfLateral ===>' );
                    mapOfoldAccount.put( String.valueOf(acc.Ref__c), acc);
                }
            }
            for(Account objaccount:lstAccount ){
                 system.debug('objaccount ==> ' + objaccount);
                 system.debug('objaccount.Is_Lateral__c  ==> ' + objaccount.Is_Lateral__c ); 
                if((accountOldMap !=null && objaccount.Is_Lateral__c && objaccount.Is_Lateral__c != accountOldMap.get(objaccount.Id).Is_Lateral__c && String.isNotBlank(String.valueOf(objaccount.Student_Number_Lateral__c)) &&  activity=='Update') || (activity=='Insert' && objaccount.Is_Lateral__c && String.isNotBlank(String.valueOf(objaccount.Student_Number_Lateral__c)))){
                system.debug('Enter1');
                    if(!Test.isRunningTest() && !mapOfoldAccount.containsKey( String.valueOf(objaccount.Student_Number_Lateral__c))){
                        objaccount.addError('Student Number does not match');    
                    }
                    // else if(!Test.isRunningTest() && mapOfoldAccount.containsKey( String.valueOf(objaccount.Student_Number_Lateral__c)) && (objaccount.FirstName!=mapOfoldAccount.get( String.valueOf(objaccount.Student_Number_Lateral__c)).FirstName) && (objaccount.LastName!=mapOfoldAccount.get( String.valueOf(objaccount.Student_Number_Lateral__c)).LastName)){
                    //      system.debug('Student name | objaccount.Name ===> ' + objaccount.Name );
                    //      system.debug('Student name | mapOfoldAccount.get( String.valueOf(objaccount.Student_Number_Lateral__c)).Name ===> ' + mapOfoldAccount.get( String.valueOf(objaccount.Student_Number_Lateral__c)).Name );
                    //     objaccount.addError('Student Name does not match');    
                    // } else if(!Test.isRunningTest() && mapOfoldAccount.containsKey( String.valueOf(objaccount.Student_Number_Lateral__c)) && (objaccount.nm_DateOfBirth__c!=mapOfoldAccount.get( String.valueOf(objaccount.Student_Number_Lateral__c)).nm_DateOfBirth__c)){
                    //     system.debug('mapOfoldAccount.get ==> ' + mapOfoldAccount.get(String.valueOf(objaccount.Student_Number_Lateral__c)));
                    //     objaccount.addError('Date Of Birth Does not Match');
                        
                    // }
                    else if(mapOfoldAccount.containsKey( String.valueOf(objaccount.Student_Number_Lateral__c))){
                        Account UpdateoBjAcc = new Account ();
                        UpdateoBjAcc.Id = objaccount.Id;
                        UpdateoBjAcc.OldAccount__c = mapOfoldAccount.get(String.valueOf(objaccount.Student_Number_Lateral__c) ).Id;
                        lstAccountToUpdate.add(UpdateoBjAcc);
                    }
    
                }

            }
        }

        if(lstAccountToUpdate.size() > 0) {
            update lstAccountToUpdate;
        }
    }

    /**
    * @description  -- check laterl and Program change and update the documnets accordingly.
    * @author shubhranshu | 8/21/2019
    * @param List<Account> lstAccount
    * @param Map<Id, Account> accountOldMap
    * @return void
    */
    public void checkforLateralAndProgramChanges(List<Account> lstAccount,Map<Id,Account> accountOldMap){
        if(lstAccount.size()>0 && lstAccount!=null)
       {    
            Id criteriaId;
            String AccountId;
           for(Account objacc:lstAccount)
           {    
              criteriaId = objAcc.nm_EligiblityCriteria__c;
              AccountId = objAcc.id;
               // system.debug('objAcc.nm_Program__c--->'+objAcc.nm_Program__c);
              // system.debug('accountOldMap--->'+accountOldMap.get(objAcc.id).nm_Program__c);

              if((objacc.Is_Lateral__c!=accountOldMap.get(objacc.id).Is_Lateral__c)|| (objacc.nm_Program__c!=accountOldMap.get(objacc.id).nm_Program__c)
              && String.isNotBlank(objacc.nm_StudentStatus__c)
              && !objacc.nm_StudentStatus__c.contains('Cancel') && !objacc.nm_StudentStatus__c.contains('Closed') && !objacc.nm_StudentStatus__c.contains('Alumni')
              && !objacc.nm_StudentStatus__c.contains('Rejected') && !objacc.nm_StudentStatus__c.contains('De-Registered')
              && !(objacc.nm_StudentStatus__c.contains('Confirmed') && accountOldMap.get(objacc.id).nm_StudentStatus__c.contains('Alumni')))
            {
              //calling UpdateDocumentSubmittedStatusOnAccount method for update student
              nmDocHandler.UpdateDocumentsOnAccountForChangeInEligibilityCriteria(lstAccount,criteriaId,AccountId);
            }
           }    
       }
    }

    public void checkForDifferentlyAbledChanges(List<Account> lstAccount,Map<Id,Account> accountOldMap){
        if(lstAccount.size()>0 && lstAccount!=null)
       {    
            Id criteriaId;
            String AccountId;
           for(Account objacc:lstAccount)
           {    
              criteriaId = objAcc.nm_EligiblityCriteria__c;
              AccountId = objAcc.id;
              if(objacc.Differently_abled__c!=accountOldMap.get(objacc.id).Differently_abled__c)
              {
                //calling UpdateDocumentSubmittedStatusOnAccount method for update student
                nmDocHandler.UpdateDocumentsOnAccountForChangeInEligibilityCriteria(lstAccount,criteriaId,AccountId);
              }
           }
       }
    }
    
    public void checkForCastDocumentChanges(List<Account> lstAccount,Map<Id,Account> accountOldMap){
        if(lstAccount.size()>0 && lstAccount!=null)
       {    
            Id criteriaId;
            String AccountId;
           for(Account objacc:lstAccount)
           {    
              criteriaId = objAcc.nm_EligiblityCriteria__c;
              AccountId = objAcc.id;
              if(objacc.nm_Category__c !=accountOldMap.get(objacc.id).nm_Category__c)
              {
                //calling UpdateDocumentSubmittedStatusOnAccount method for update student
                nmDocHandler.UpdateDocumentsOnAccountForChangeInEligibilityCriteria(lstAccount,criteriaId,AccountId);
              }
           }
       }
    }

     public void Callproducthelper(Opportunity objOpps)
    {
       //  list<nm_Program__c> Lstofprogram = [select id,name,nm_Type__c,Specialisation__c,nm_ProgramName__c from nm_Program__c where id=:objOpps.nm_Program__c limit 1];
          nm_Program__c objprogram =   GetProgram(objOpps) ;
         if(objprogram!=null )
         {
             productHelper.UpdateOpportunityLineItemAfterFeetypeChange(objOpps,objprogram, null, null);
         }
         
    }
    
    public nm_Program__c GetProgram (Opportunity objOpps)
    {
        nm_Program__c objprogram = new nm_Program__c (id = objOpps.nm_Program__c);
        objprogram.Name = objOpps.Program_Name__c;
        objprogram.nm_Type__c = objOpps.ChooseProgram__c;
        objprogram.Specialisation__c = objOpps.Specialisation__c;      
        objprogram.PVM__c= objOpps.PVM__c;
        objprogram.nm_TotalSemesters__c= objOpps.Total_Sem__c;
        objprogram.IsTerm__c= objOpps.IsTerm__c;
        return objprogram;
        
    }
    
    public void UpdateDocumentsForChangeInEligibilityCriteria(List<Account> lstAccount, map<id, Account> accountOldMap, String triggerType)
    {
        system.debug('Inside UpdateDocumentsForChangeInEligibilityCriteria 1');
        if(lstAccount != null && lstAccount.size() > 0)
        {
            system.debug('Inside UpdateDocumentsForChangeInEligibilityCriteria 2');
            Id criteriaId;
            String AccountId;
            List<Account> acUpdate=new List<Account>();
            for(Account objAcc : lstAccount)
            {
                criteriaId = objAcc.nm_EligiblityCriteria__c;
                AccountId = objAcc.id;
                // if(triggerType.equalsIgnoreCase('INSERT'))
                // {
                    //     flag  = true;
                    // }
                    // else
                    // {
                        //     //Check if Eligibility criteria has changed as compared to old value
                        //     flag = objAcc.nm_EligiblityCriteria__c != accountOldMap.get(objAcc.id).nm_EligiblityCriteria__c;
                        //     system.debug('--------flag---update scenario----- '+flag);
                        // }
                       
                        
                if(objAcc.nm_EligiblityCriteria__c != accountOldMap.get(objAcc.id).nm_EligiblityCriteria__c ){
                    nmDocHandler.UpdateDocumentsOnAccountForChangeInEligibilityCriteria(lstAccount,criteriaId,AccountId);
                }
            }               
        }
    } 
    



 public void UpdateOppOwner (list<Account> lstAccount, map<id,Account> oldmapAccount,String activity){
        
    map<Id,String> mapofAccIdvsAcc = new map<Id,String>();
    set<Id> CpIds = new set<Id>();
    List<Opportunity> lstOppToUpdate = new List<Opportunity>();
    List<Opportunity> lstopportunity = new List<Opportunity>();
    List<Account> AccountToUpdate = new List<Account>();
   
    if(lstAccount.size()>0){
        for(Account ObjAcc : lstAccount){
        // system.debug('lstAccount ==> ' + lstAccount);

            if(oldmapAccount !=null && String.isNotBlank(ObjAcc.OwnerId) && ObjAcc.OwnerId!=oldmapAccount.get(ObjAcc.Id).OwnerId
            && activity=='Update') 
            {
                mapofAccIdvsAcc.put(ObjAcc.Id, ObjAcc.OwnerId);
            }
            else if(activity=='Insert' && String.isNotBlank(ObjAcc.OwnerId) ){
                mapofAccIdvsAcc.put(ObjAcc.Id, ObjAcc.OwnerId);
            }
        }
    
     
            if(mapofAccIdvsAcc!=null)
            {
             lstopportunity = [SELECT Id, OwnerId,AccountID,Account.OwnerId FROM Opportunity where AccountID =:mapofAccIdvsAcc.keyset() ];
            system.debug('lstopportunity to update owner--->'+lstopportunity);
            
                if(lstopportunity.size()>0)
                {
                    for(Opportunity objopps: lstopportunity)
                    {
                        if(objopps.OwnerId!= objopps.Account.OwnerId)
                        {
                            objopps.OwnerId = objopps.Account.OwnerId;
                            lstOppToUpdate.add(objopps);
                            system.debug('lstOppToUpdate to update owner--->'+lstOppToUpdate);
                        }
                        
                    }
                } 
            }
            
              if(lstOppToUpdate.size() > 0 ){
                update lstOppToUpdate;
         }
    }
}

 /*   public void UpdateAccToOpp(list<Account> lstAccount, map<id,Account> oldmapAccount,String activity){
        set<Id> AccountIds = new set<Id>();
        map<Id,String> newOwenrIds = new map<Id,String>();
        set<Id> CpIds = new set<Id>();
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        List<Account> AccountToUpdate = new List<Account>();
       
        if(lstAccount.size()>0){
            for(Account ObjAcc : lstAccount){
               // system.debug('lstAccount ==> ' + lstAccount);

                if((ObjAcc.OwnerId!=oldmapAccount.get(ObjAcc.Id).OwnerId && String.isNotBlank(ObjAcc.OwnerId) && activity=='Update') || (activity=='Insert' && String.isNotBlank(ObjAcc.OwnerId))) {
                    newOwenrIds.put(ObjAcc.Id, ObjAcc.OwnerId);
                    accountIds.add(ObjAcc.Id);
                }
                    else if(activity=='Update' && String.isNotBlank(ObjAcc.Counselor_Profile__c) && ObjAcc.Counselor_Profile__c!=oldmapAccount.get(ObjAcc.Id).Counselor_Profile__c){
                        CpIds.add(ObjAcc.Counselor_Profile__c);
                        accountIds.add(ObjAcc.Id);
                    }
                   //system.debug('AccountIds==> ' + AccountIds);
                
            }
            if (!accountIds.isEmpty()){
                Map<Id, Counsellor_Profile__c> mapOfIdVsCounselorProfile = new Map<Id,Counsellor_Profile__c>([SELECT id,Program_Offered__c, OwnerId FROM Counsellor_Profile__c WHERE Id IN :CpIds]);
                for (Account acc : [SELECT Id, OwnerId, Counselor_Profile__r.OwnerId,Counselor_Profile__c, (SELECT Id, OwnerId FROM Opportunities) FROM Account WHERE Id in :accountIds AND Active_account__c=true]){
                    String newOwnerId = newOwenrIds.get(acc.Id);
                  

                   Boolean CheckOwnerCounselor = false;
                    if(mapOfIdVsCounselorProfile.containsKey(acc.Counselor_Profile__c)){
                       
                        CheckOwnerCounselor = true;
                     Account UpdateAccount = new Account(OwnerId = mapOfIdVsCounselorProfile.get(acc.Counselor_Profile__c).OwnerId,Id = acc.Id);
                     AccountToUpdate.add(UpdateAccount);
                    }

                    for(Opportunity opp : acc.Opportunities){
                        if(opp.OwnerId != newOwnerId){
                            Opportunity UpdatedOpportunity = new Opportunity(OwnerId = CheckOwnerCounselor ? mapOfIdVsCounselorProfile.get(acc.Counselor_Profile__c).OwnerId : newOwnerId, Id = opp.Id);
                            lstOppToUpdate.add(UpdatedOpportunity);
                           // system.debug('UpdatedOpportunity==> ' + UpdatedOpportunity);
                        }

                    }
                }
            }
        }
        if(lstOppToUpdate.size() > 0 ){
            update lstOppToUpdate;

        }
        if( AccountToUpdate.size() > 0){
            update AccountToUpdate;

        }
    }*/

    //Method to handle IC/LC change
     public void UpdateAccountOwnerId(list<Account> lstAccount, map<id,Account> oldmapAccount)
    {
        
        if(lstAccount != null)
        {
            //set to store all the center id
            set<id> setCenterId = new set<id>();
            set<id> setCPId = new set<id>();
            map<id,Account> mapAccountIdvsAccount = new map<id,Account>();
            map<id,id> MapOfCenterIdVsUserId = new  map<id,id> ();
            map<Id, Counsellor_Profile__c> mapOfIdVsCounselorProfile = new Map<Id,Counsellor_Profile__c> ();
            //Loop to get center id's and store it in set
            Boolean checkValidUser = checkValidUser();
            for(Account objAccont : lstAccount)
            {
                if(objAccont.nm_StudentStatus__c == null)
                {
                  objAccont.nm_StudentStatus__c = 'Registered';
                }
                if(oldmapAccount != null)
                {
                    if(objAccont.nm_Centers__c != null &&  objAccont.nm_Centers__c != oldmapAccount.get(objAccont.id).nm_Centers__c)
                    {   
                        setCenterId.add(objAccont.nm_Centers__c);                                       
                        mapAccountIdvsAccount.put(objAccont.id,objAccont);
                        if(objAccont.Counselor_Profile__c != null )
                        {
                              setCPId.add(objAccont.Counselor_Profile__c);
                        }                       
                    }
                     if(objAccont.Counselor_Profile__c != null 
                     &&  objAccont.Counselor_Profile__c != oldmapAccount.get(objAccont.id).Counselor_Profile__c)
                    {    
                        setCPId.add(objAccont.Counselor_Profile__c);                  
                        mapAccountIdvsAccount.put(objAccont.id,objAccont);

                    }                   
                    List<String> lstAccountStatus = new List<String>{'Rusticated','Admission Cancelled'};

                      if((objAccont.nm_StudentStatus__c == 'Confirmed' 
                      || oldmapAccount.get(objAccont.id).nm_StudentStatus__c == 'Confirmed' 
                      || (objAccont.nm_StudentNo__c!=null && objAccont.nm_StudentNo__c!='' )) && !lstAccountStatus.contains(objAccont.nm_StudentStatus__c))
                {
                  
                    // update Student Profile on Student Zone if Email or Mobile or Mother Name or Father Name change on SFDC 
                    if((objAccont.Mother_First_Name__c != null &&  objAccont.Mother_First_Name__c != oldmapAccount.get(objAccont.id).Mother_First_Name__c)
                        || (objAccont.nm_StudentStatus__c != null &&  objAccont.nm_StudentStatus__c != oldmapAccount.get(objAccont.id).nm_StudentStatus__c )
                        || (objAccont.FirstName!= null &&  objAccont.FirstName!= oldmapAccount.get(objAccont.id).FirstName)
                        || (objAccont.LastName!= null &&  objAccont.LastName!= oldmapAccount.get(objAccont.id).LastName)
                        || (objAccont.nm_SpouseName__c!= null &&  objAccont.nm_SpouseName__c!= oldmapAccount.get(objAccont.id).nm_SpouseName__c)
                        || (objAccont.ValidUptoR__c != null &&  objAccont.ValidUptoR__c != oldmapAccount.get(objAccont.id).ValidUptoR__c )
                        || (objAccont.Father_First_Name__c != null &&  objAccont.Father_First_Name__c != oldmapAccount.get(objAccont.id).Father_First_Name__c)
                        || (objAccont.PersonEmail != null &&  objAccont.PersonEmail != oldmapAccount.get(objAccont.id).PersonEmail)
                        || (objAccont.PersonMobilePhone != null &&  objAccont.PersonMobilePhone != oldmapAccount.get(objAccont.id).PersonMobilePhone)
                        || (objAccont.nm_StudentImageUrl__c !=null && objAccont.nm_StudentImageUrl__c != oldmapAccount.get(objAccont.id).nm_StudentImageUrl__c)
                        || (objAccont.Extend_Validity_upto_Month__c !=null && objAccont.Extend_Validity_upto_Month__c != oldmapAccount.get(objAccont.id).Extend_Validity_upto_Month__c)
                        || (objAccont.Extend_Validity_Upto_Year__c !=null && objAccont.Extend_Validity_Upto_Year__c != oldmapAccount.get(objAccont.id).Extend_Validity_Upto_Year__c)
                        || (objAccont.nm_Centers__c !=null && objAccont.nm_Centers__c != oldmapAccount.get(objAccont.id).nm_Centers__c)                      
                        || (objAccont.House_No_Name_Shipping_Account__c !=null && objAccont.House_No_Name_Shipping_Account__c != oldmapAccount.get(objAccont.id).House_No_Name_Shipping_Account__c && checkValidUser)
                        || (objAccont.Locality_Name_Shipping__c !=null && objAccont.Locality_Name_Shipping__c != oldmapAccount.get(objAccont.id).Locality_Name_Shipping__c && checkValidUser)
                        || (objAccont.Nearest_LandMark_Shipping__c !=null && objAccont.Nearest_LandMark_Shipping__c != oldmapAccount.get(objAccont.id).Nearest_LandMark_Shipping__c && checkValidUser)
                        || (objAccont.City_Shipping_Account__c !=null && objAccont.City_Shipping_Account__c != oldmapAccount.get(objAccont.id).City_Shipping_Account__c && checkValidUser)
                        || (objAccont.Shipping_Street__c !=null && objAccont.Shipping_Street__c != oldmapAccount.get(objAccont.id).Shipping_Street__c && checkValidUser)
                        || (objAccont.Country_Shipping__c !=null && objAccont.Country_Shipping__c != oldmapAccount.get(objAccont.id).Country_Shipping__c && checkValidUser)
                        || (objAccont.State_Province_Shipping__c !=null && objAccont.State_Province_Shipping__c != oldmapAccount.get(objAccont.id).State_Province_Shipping__c && checkValidUser)
                        || (objAccont.Zip_Postal_Code_Shipping__c !=null && objAccont.Zip_Postal_Code_Shipping__c != oldmapAccount.get(objAccont.id).Zip_Postal_Code_Shipping__c && checkValidUser)
                        || (objAccont.nm_DateOfBirth__c !=null && objAccont.nm_DateOfBirth__c != oldmapAccount.get(objAccont.id).nm_DateOfBirth__c && checkValidUser)
                        || (objAccont.Phone !=null && objAccont.Phone != oldmapAccount.get(objAccont.id).Phone && checkValidUser)
                        || (objAccont.nm_Program__c !=null && objAccont.nm_Program__c != oldmapAccount.get(objAccont.id).nm_Program__c)
                        || (objAccont.Trigger_Sync_API__c && objAccont.Trigger_Sync_API__c != oldmapAccount.get(objAccont.id).Trigger_Sync_API__c)
                        || (objAccont.prgst__c !=null && objAccont.prgst__c != oldmapAccount.get(objAccont.id).prgst__c)
                        || (objAccont.Highest_Qualification__c !=null && objAccont.Highest_Qualification__c != oldmapAccount.get(objAccont.id).Highest_Qualification__c)
                        || (objAccont.Provisional_With_Hold__c != oldmapAccount.get(objAccont.id).Provisional_With_Hold__c)
                      )
                    {
                      system.debug('Call portal');
                       updateProfileonStudentZone(objAccont.id); 
                    }
                    
                  }
                    if(objAccont.nm_StudentImageUrl__c != null &&  objAccont.nm_StudentImageUrl__c != oldmapAccount.get(objAccont.id).nm_StudentImageUrl__c)
                    {
                        changeStudentImageLkD(objAccont.id,objAccont.nm_StudentImageUrl__c);
                    }

                    if(objAccont.nm_Program2__c != oldmapAccount.get(objAccont.id).nm_Program2__c){

                        updateAllOpportuinty(objAccont.id,objAccont.nm_Program2__c);
                    }
                }
            }
            if(setCPId.size()>0)
            {
                 mapOfIdVsCounselorProfile = getMapAllCounsellor();
                 MapOfCenterIdVsUserId = getMapOfCenterIdVsUserId();
                  
            }
            if(setCenterId.size()>0)
            {
                MapOfCenterIdVsUserId = getMapOfCenterIdVsUserId();
            }
            if(setCPId.size()>0 || mapAccountIdvsAccount!=null)
            {   
                
                //Loop to set the owner of lead by getting the user id in respect of center id
                List<Account> lstacc =  mapAccountIdvsAccount.values();   
                for(Account objAccount : lstacc )
                {
                    if(oldmapAccount != null && objAccount.IsPersonAccount && mapAccountIdvsAccount.containskey(objAccount.id) 
                     && objAccount.Counselor_Profile__c!= null && mapOfIdVsCounselorProfile.containskey(objAccount.Counselor_Profile__c) 
                     && objAccount.nm_Centers__c == mapOfIdVsCounselorProfile.get(objAccount.Counselor_Profile__c).AEP_Name__c
                     && mapOfIdVsCounselorProfile.get(objAccount.Counselor_Profile__c).UserIsActive__c)
                    {
                        system.debug('Enter CP change');
                        objAccount.OwnerId = mapOfIdVsCounselorProfile.get(objAccount.Counselor_Profile__c).OwnerId;
                        system.debug('objAccount.OwnerId --->'+objAccount.OwnerId );
                        
                    }else if(oldmapAccount != null && objAccount.IsPersonAccount && objAccount.nm_Centers__c != null 
                    && objAccount.nm_Centers__c != oldmapAccount.get(objAccount.id).nm_Centers__c 
                    &&  MapOfCenterIdVsUserId.containskey(objAccount.nm_Centers__c))
                    {
                        objAccount.OwnerId = MapOfCenterIdVsUserId.get(objAccount.nm_Centers__c);
                        system.debug('objAccount.OwnerId --->'+objAccount.OwnerId );
                    }
                    else if(objAccount.IsPersonAccount && objAccount.nm_Centers__c != null 
                    &&MapOfCenterIdVsUserId!=null &&  MapOfCenterIdVsUserId.containskey(objAccount.nm_Centers__c))
                    {
                       objAccount.OwnerId = MapOfCenterIdVsUserId.get(objAccount.nm_Centers__c);
                       system.debug('objAccount.OwnerId --->'+objAccount.OwnerId );
                    }
                  
                }
            }
        }
    }  
    
    //To check if the user is Admin User.
  /*  public boolean checkValidUser() {
        Id UserId=userinfo.getUserId();
        String AliasName = [Select Id,Alias from User where Id=:UserId].Alias;
        if(AliasName == 'AUser') {
            return false;
        }else{
            return true;
        }
    }*/
     //To check if the user is Admin User.
    public boolean checkValidUser() {
       String UserName = userinfo.getUserName();
        //String AliasName = [Select Id,Alias from User where Id=:UserId].Alias;
        if('rajiv.shah@nmims.edu'.equalsIgnoreCase(UserName)) {
            return false;
        }else{
            return true;
        }
    }

    //Method to transfer work experiance lead to account
    public void updateWorkExperiance (list<Account> lstAccount)
    {
        //map to store account id against lead id
        map<string,id> mapLeadAccountId = new map<string,id>();
        for (Account objAccount : lstAccount)
        {
            if(objAccount.nm_LeadId__c != null && objAccount.nm_LeadId__c != '')     //mayur 11/7/2015
            {
               // Id LeadId = objAccount.nm_LeadId__c;
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }
  
        //Query to get data of recently converted lead
        list<nm_WorkExperience__c> lstWorkExperiance = ([select id, nm_LeadId__c, nm_Student__c from nm_WorkExperience__c 
                                                        where nm_Lead__c in: mapLeadAccountId.keyset()]); 
        if(lstWorkExperiance != null && lstWorkExperiance.size()>0)
        {
            //List of work experiance data to be updated
            list<nm_WorkExperience__c> lstWorkExperianceToUpdate = new list<nm_WorkExperience__c>();
            
            for(nm_WorkExperience__c objWorkExperiance : lstWorkExperiance)
            {
                //updating id of account
                Id LeadId = objWorkExperiance.nm_LeadId__c; 
                objWorkExperiance.nm_Student__c = mapLeadAccountId.get(string.valueof(LeadId));
                system.debug('<----studentforWorkExperince----->'+objWorkExperiance.nm_Student__c);
                objWorkExperiance.nm_Lead__c = null;
                system.debug('<--- objWorkExperiance.nm_Lead__c--->'+ objWorkExperiance.nm_Lead__c);
                
                //Adding updated data in list           
                lstWorkExperianceToUpdate.add(objWorkExperiance);
            }
            //Updating List of work Experiance
            if(lstWorkExperianceToUpdate != null && lstWorkExperiance.size()>0)
            {
              update lstWorkExperianceToUpdate;
            }
        }
        
    }  
    
    /**
    * @description 
    * @author @BK | 24-10-2024 
    * @param List<Account> lstAccount 
    **/
    public void updateCase(List<Account> lstAccount) {
        Map<String,Id> mapLeadAccountId = new Map<String,Id>();
        List<Case> lstCaseToUpdate = new List<Case>();
        for (Account objAccount : lstAccount) {
            if(String.isNotBlank(objAccount.nm_LeadId__c))  {
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }

        for(Case objCase : [SELECT id,AccountId,Lead__c FROM Case WHERE Lead__c IN : mapLeadAccountId.keyset() AND RecordType.Name IN ('Student Feedbacks','Ticketing Tool')]) {
            //updating id of account
            Id leadId = objCase.Lead__c; 
            objCase.AccountId = mapLeadAccountId.get(String.valueOf(leadId));
            System.debug('<---- student for Case ----->'+objCase.AccountId);
            objCase.Lead__c = null;
            System.debug('<--- objCase.Lead__c--->'+ objCase.Lead__c);
            //Adding updated data in list           
            lstCaseToUpdate.add(objCase);
        }
        //Updating List of work Experiance
        if(!lstCaseToUpdate.isEmpty()) {
            update lstCaseToUpdate;
        }
    }

    /**
    * @description 
    * @author @Shailesh | 04-04-2025 
    * @param List<Account> lstAccount 
    **/
    public void updateTranferApirequestfromLeadtoAcc(List<Account> lstAccount) { 
        System.enqueueJob(new AsyncTransferApiRequest(lstAccount));
    }

    /**
    * @description : Method to transfer studentRating lead to account
    * @author @BK | 8/8/2019
    * @param list<Account> lstAccount
    * @return void
    */
    public void updateStudentRating(List<Account> lstAccount) {
        //map to store account id against lead id
        Map<String,Id> mapLeadAccountId = new Map<String,Id>();
        for (Account objAccount : lstAccount) {
            if(objAccount.nm_LeadId__c != null && objAccount.nm_LeadId__c != '') {
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }
  
        //Query to get data of recently converted lead
        List<Student_Rating__c> lstStudentRating = ([SELECT Question_2_Student_Rating__c,Student__c,Question_1_Student_Rating__c,Interview_Date__c,
            Interviewer_Name__c,Question_4_Student_Rating__c,Logical_Reasoning_Data_Interpretation__c,Number_of_retakes__c,Question_3_Student_Rating__c,
            Quantitative_Aptitude__c,Q5_text__c,Report_URL__c,Status__c,Question_5_Student_Rating__c,Submitted_At__c,Test_Score__c,Time_Taken__c,
            Verbal_Reasoning__c,nm_Lead__c FROM Student_Rating__c WHERE nm_Lead__c IN :mapLeadAccountId.keySet()]);

        if(lstStudentRating != null && lstStudentRating.size() > 0){
            //List of work experiance data to be updated
            List<Student_Rating__c> lstStudentRatingToUpdate = new List<Student_Rating__c>();
            
            for(Student_Rating__c objStudentRating : lstStudentRating) {
                //updating id of account
                Id leadId = objStudentRating.nm_Lead__c; 
                objStudentRating.Student__c = mapLeadAccountId.get(String.valueOf(leadId));
                System.debug('<----studentforStudentRating----->'+objStudentRating.Student__c);
                objStudentRating.nm_Lead__c = null;
                System.debug('<--- objStudentRating.nm_Lead__c--->'+ objStudentRating.nm_Lead__c);
                
                //Adding updated data in list           
                lstStudentRatingToUpdate.add(objStudentRating);
            }
            //Updating List of work Experiance
            if(lstStudentRatingToUpdate != null && lstStudentRatingToUpdate.size() > 0){
              update lstStudentRatingToUpdate;
            }
        }
    }
    
    /**
    * @description
    * @author shubhranshu | 8/29/2019
    * @param List<Account> lstAccount
    * @return void
    */
    public void updateAEPRequest(List<Account> lstAccount) {
        //map to store account id against lead id
        Map<String,Id> mapLeadAccountId = new Map<String,Id>();
        for (Account objAccount : lstAccount) {
            if(objAccount.nm_LeadId__c != null && objAccount.nm_LeadId__c != '') {
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }
  
        //Query to get data of recently converted lead
        List<AEP_Request__c> lstAEPRequest = ([SELECT Id,Lead__c,Student__c FROM AEP_Request__c WHERE Lead__c IN :mapLeadAccountId.keySet()]);
        //List of work experiance data to be updated
        List<AEP_Request__c> lstAEPRequestToUpdate = new List<AEP_Request__c>();

        if(lstAEPRequest != null && lstAEPRequest.size() > 0){
           
            for(AEP_Request__c objAEPReq : lstAEPRequest) {
                //updating id of account
                Id leadId = objAEPReq.Lead__c; 
                objAEPReq.Student__c = mapLeadAccountId.get(String.valueOf(leadId));
                System.debug('<----studentforAEP Request----->'+objAEPReq.Student__c);
                objAEPReq.Lead__c = null;
                System.debug('<--- objAEPReq.Lead__c--->'+ objAEPReq.Lead__c);
                
                //Adding updated data in list           
                lstAEPRequestToUpdate.add(objAEPReq);
            }
            //Updating List of work Experiance
            if(lstAEPRequestToUpdate != null && lstAEPRequestToUpdate.size() > 0){
              update lstAEPRequestToUpdate;
            }
        }
    }

    /**
    * @description 
    * @author @BK | 10-09-2024 
    * @param List<Account> lstAccount 
    **/
    public void updateDEBDetails(List<Account> lstAccount) {
        //map to store account id against lead id
        Map<String,Id> mapLeadAccountId = new Map<String,Id>();
        for (Account objAccount : lstAccount) {
            if(String.isNotBlank(objAccount.nm_LeadId__c)) {
                mapLeadAccountId.put(objAccount.nm_LeadId__c, objAccount.id);
            }
        }

        //Query to get data of recently converted lead
        List<DEB_Detail__c> lstDEBDetails = ([SELECT Id,Lead__c,Account__c FROM DEB_Detail__c WHERE Lead__c IN :mapLeadAccountId.keySet() AND Is_Active__c=true]);

        if(!lstDEBDetails.isEmpty()){
            //List of DEB Details data to be updated
            List<DEB_Detail__c> lstDEBDetailsToUpdate = new List<DEB_Detail__c>();

            for(DEB_Detail__c objDEBDetail : lstDEBDetails) {
                //updating id of account
                Id leadId = objDEBDetail.Lead__c; 
                objDEBDetail.Account__c = mapLeadAccountId.get(String.valueOf(leadId));
                System.debug('<----Account for DEB Detail----->'+objDEBDetail.Account__c);
                objDEBDetail.Lead__c = null;
                System.debug('<--- objDEBDetail.Lead__c--->'+ objDEBDetail.Lead__c);
                
                //Adding updated data in list           
                lstDEBDetailsToUpdate.add(objDEBDetail);
            }

            //Updating List of DEB Details
            if(!lstDEBDetailsToUpdate.isEmpty()){
                update lstDEBDetailsToUpdate;
            }
        }
    }

    public void documentApproval(list<Account> lstAccount,Map<id,Account> oldMap) {
        
        set<id> setAccId = new set<id>();
        List<Account> lstDocSubmittedAccount = new List<Account>();
        List<Account> lstDocToAddCoordinate = new List<Account>();
        List<Account> lstAccountToUpdateDateOfApprove = new List<Account>();
        decimal pendingAmount = 0.0;
        Map<String,String> mapOfEventName = new Map<String,String>();
        System.debug('documentApproval --> ' );
        System.debug('documentApproval --> ' );
        for(Account objAccount : lstAccount)
        {
            System.debug('objAccount.nm_StudentStatus__c--> ' + objAccount.nm_StudentStatus__c );
            System.debug('objAccount.nm_StudentStatus__c--> ' + oldMap.get(objAccount.id).Admission_Co_ordinator__c );
          // allow to Insert Late Fee Product if Document Submitted or Disapproved in Late Feee Slab
           if((objAccount.nm_StudentStatus__c=='Admission form & documents submitted' || objAccount.nm_StudentStatus__c=='Documents Disapproved') && objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c)
            {
                if(objAccount.nm_StudentStatus__c=='Admission form & documents submitted') {
                    lstDocSubmittedAccount.add(objAccount);
                }

                setAccId.add(objAccount.id);
                mapOfEventName.put('eventName','Document Submitted');

            }
            // else if((objAccount.nm_StudentStatus__c=='Documents Re-submitted')  && (oldMap.get(objAccount.id).Admission_Co_ordinator__c == null || !oldMap.get(objAccount.id).HOTeamIsActive__c) && objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c)
            else if((objAccount.nm_StudentStatus__c=='Documents Re-submitted')  && (objAccount.Admission_Co_ordinator__c == null || ( objAccount.Admission_Co_ordinator__c != null && !objAccount.HOTeamIsActive__c)) && objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c)
            { 
                system.debug('objAccount.nm_StudentStatus__c --> ' + objAccount.nm_StudentStatus__c);
                lstDocToAddCoordinate.add(objAccount);

        }

            else if((objAccount.nm_StudentStatus__c=='Admission form & documents Approved' || objAccount.nm_StudentStatus__c=='Admission Form & Documents Provisional') && objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c)
            {
                setAccId.add(objAccount.id);
                mapOfEventName.put('eventName','Document Approved');
                
               /* if(objAccount.nm_ChooseaProgram__c =='Degree Programs' && objAccount.Program_Type__c=='MBA (WX)' && objAccount.Interview_Date__c==null)
                    {
                        InterviewSchedules(objAccount.id);
                    }*/
            }else if(objAccount.nm_IsEmailVerified__c && objAccount.nm_IsEmailVerified__c !=oldMap.get(objAccount.id).nm_IsEmailVerified__c )
            {
                mapOfEventName.put('eventName','Email Verified');
                setAccId.add(objAccount.id);
            }else if(objAccount.Is_Mobile_Verified__c && objAccount.Is_Mobile_Verified__c !=oldMap.get(objAccount.id).Is_Mobile_Verified__c)
            {
                mapOfEventName.put('eventName','Mobile Verified');
                setAccId.add(objAccount.id);
            }else if(objAccount.is_Video_Call_Verified__c && objAccount.is_Video_Call_Verified__c !=oldMap.get(objAccount.id).is_Video_Call_Verified__c)
            {
                mapOfEventName.put('eventName','Video Call Verified');
                setAccId.add(objAccount.id);
            }else if(objAccount.AI_Component__c!=null && objAccount.AI_Component__c !=oldMap.get(objAccount.id).AI_Component__c)
            {
                mapOfEventName.put('eventName','Component Added');
                setAccId.add(objAccount.id);
            } else if(String.isNotBlank(objAccount.DEBID__c) && objAccount.is_Deb_verified__c && objAccount.is_Deb_verified__c !=oldMap.get(objAccount.id).is_Deb_verified__c){
                mapOfEventName.put('eventName','DEB ID Verified');
                setAccId.add(objAccount.id);
            }/*else if(objAccount.Adhar_Card_Number__c!=null && objAccount.Adhar_Card_Number__c!=oldMap.get(objAccount.id).Adhar_Card_Number__c)
            {
                mapOfEventName.put('eventName','CheckAdharCard');
                setAccId.add(objAccount.id);
            }else{
                setAccId.add(objAccount.id);
                mapOfEventName.put('eventName','Document Approved');
            }*/

            // Set Document Approved Date on student status to Admission form & documents Approved OR Admission Form & Documents Provisional
            if((objAccount.nm_StudentStatus__c=='Admission form & documents Approved' || objAccount.nm_StudentStatus__c=='Admission Form & Documents Provisional' || objAccount.nm_StudentStatus__c =='Document/s marked incorrect') 
                && objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c 
                && oldMap.get(objAccount.id).nm_StudentStatus__c == 'Admission form & documents submitted') {
                Account objAcc = new Account();
                objAcc.Id = objAccount.Id;
                objAcc.Document_Approved_Date__c = Datetime.now();
                system.debug('objAcc.Document_Approved_Date__c ---> ' + objAcc.Document_Approved_Date__c);
                system.debug('objAcc.nm_DocumentSubmittedDate__c ---> ' + objAcc.nm_DocumentSubmittedDate__c);
                system.debug('objAcc.nm_DocumentSubmittedDate__c ---> ' + objAcc.nm_DocumentSubmittedDate__c);
                if(String.isNotBlank(String.valueOf(objAcc.Document_Approved_Date__c)) && String.isNotBlank(String.valueOf(oldMap.get(objAccount.id).nm_DocumentSubmittedDate__c))) {
                    system.debug('inside getNumberOfDays');
                    objAcc.Verification_TAT__c = getNumberOfDays(oldMap.get(objAccount.id).nm_DocumentSubmittedDate__c,objAcc.Document_Approved_Date__c);
                }
                lstAccountToUpdateDateOfApprove.add(objAcc);
            }
            if((objAccount.nm_StudentStatus__c=='Admission form & documents Approved' || objAccount.nm_StudentStatus__c=='Admission Form & Documents Provisional' || objAccount.nm_StudentStatus__c =='Document/s marked incorrect') && oldMap.get(objAccount.id).nm_StudentStatus__c=='Documents Re-submitted' && objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c) {
                Account objAcc = new Account();
                objAcc.Id = objAccount.Id;
                objAcc.Document_Approved_Date__c = Datetime.now();
                
               if(String.isNotBlank(String.valueOf(oldMap.get(objAccount.id).nm_DocumentSubmittedDate__c))) {
                Integer tatOfDays = getNumberOfDays(oldMap.get(objAccount.id).nm_DocumentSubmittedDate__c, Datetime.now());
                    objAcc.Verification_TAT__c = tatOfDays;
                    objAcc.Re_Verification_TAT__c = tatOfDays;
                }
                
                lstAccountToUpdateDateOfApprove.add(objAcc);
            }
        }

        if(lstAccountToUpdateDateOfApprove.size() > 0) {
            update lstAccountToUpdateDateOfApprove;
        }
        if(lstDocToAddCoordinate.size() > 0) {
                addAdmissionCordinator(lstDocToAddCoordinate);
        }

        System.debug('mapOfEventName--'+mapOfEventName);
        if(setAccId.Size() > 0) {
            System.debug('setAccId.Size() ==>' + setAccId.size());
            list<Opportunity> lstOpportunity=[select id,LiveLecturesType__c,CourseList__c,StageName,Accountid,Is_Re_Registration_Payment__c,nm_Category__c from Opportunity where Accountid in :setAccId and (StageName = 'Payment Made' Or StageName = 'Closed' or StageName = 'Pending Payment')];
            if(lstOpportunity.size() > 0){
                // Create Late Fee Product during Late Fee Salb 
                for(Opportunity objOpps : lstOpportunity)
                {
                    productHelper.UpdateOpportunityStageToPendingOrPaymentMadeOrClosedOrClosedWon(objOpps.id,mapOfEventName.get('eventName'), null, null);
                }
            }

            if(lstDocSubmittedAccount.size() > 0) {
                addAdmissionCordinator(lstDocSubmittedAccount);
            }
        } else {
            return;
        }
        
    }


    public Integer getNumberOfDays(Datetime DateTimeOfStartDate, Datetime DateTimeOfEndDate) {
        system.debug('DateTimeOfStartDate --> ' + DateTimeOfStartDate);
        system.debug('DateTimeOfEndDate --> ' + DateTimeOfEndDate);
        if(String.isNotBlank(String.valueOf(DateTimeOfStartDate)) && String.isNotBlank(String.valueOf(DateTimeOfEndDate))) {
            Set<Date> uniqueDate = new Set<Date>();
            Date StartDate = date.newinstance(DateTimeOfStartDate.year(), DateTimeOfStartDate.month(), DateTimeOfStartDate.day());
            Date EndDate = date.newinstance(DateTimeOfEndDate.year(), DateTimeOfEndDate.month(), DateTimeOfEndDate.day());
    
            DateHelper DateHelper = new DateHelper();
            List<Date> lstDates =DateHelper.getAllDatesBetweenTwoDates(StartDate, EndDate);
            List<Date> ActualDate = lstDates.size()>0?DateHelper.getDateIgnoringSunday(lstDates) : new List<Date>();
            List<Date> ActualDateAfterHoliday = ActualDate.size()>0?DateHelper.getDateIgnoringHolidayList(ActualDate) : new List<Date>();            
            uniqueDate.addAll(ActualDateAfterHoliday);            
            return uniqueDate.size() > 0 ? uniqueDate.size() : 0;
        } else {
            return 0;
        }
    }

    /**
    * @description Method to add the Admission Co-ordinator according to the Program.
    * @author @BK | 02-15-2021 
    * @param lstAccounts 
    **/
    public void addAdmissionCordinator(List<Account> lstAccounts) { 
        System.debug('Entered in addAdmissionCordinator Method');
        Map<String,List<String>> mapOfProgramVsProfiles = new Map<String,List<String>>();
        List<Account> lstOfAccountUpdate = new List<Account>();
        Map<String,Integer> mapOfProfileVsCount = new Map<String,Integer>();
        List<Account> lstAssignedAccount = [SELECT id,Admission_Co_ordinator__c,nm_ProgramType__c,Program_Type__c FROM Account WHERE nm_StudentStatus__c!='Documents Re-submitted' AND Admission_Co_ordinator__c!=null AND nm_DocumentSubmittedDate__c=TODAY];
        List<Counsellor_Profile__c> lstProfile = [SELECT id,Program_Offered__c FROM Counsellor_Profile__c WHERE IsActive__c=false AND BusinessAccount__r.Name='Head Office'];
        if(lstProfile.size() > 0) {
            for (Counsellor_Profile__c objProfile : lstProfile) {
                String programOffered = objProfile.Program_Offered__c;
                List<String> lstProgramOffered = String.isNotBlank(programOffered) ? programOffered.split(';') : new List<String>();
                for(String program : lstProgramOffered) {
                    List<String> lstProfileId = mapOfProgramVsProfiles.containsKey(program) ? mapOfProgramVsProfiles.get(program) : new List<String>();
                    lstProfileId.add(objProfile.id);
                    mapOfProgramVsProfiles.put(program,lstProfileId);
                }
            }
            System.debug('mapOfProgramVsProfiles.size() ==>'+mapOfProgramVsProfiles.size());
        }

        if(lstAssignedAccount.size() > 0) {
            for(Account objAcc : lstAssignedAccount) {
                mapOfProfileVsCount = updateMapProfileVsCount(mapOfProfileVsCount,objAcc.Admission_Co_ordinator__c);
            }
        }
        
        for(Account objAcc : lstAccounts) {
            String programName = objAcc.nm_ChooseaProgram__c;
            List<String> lstSpecializedProgramCategory = new List<String>{'Certificate Programs','Professional Programs'};
            List<String> progrType = new List<String>{'PC Term 2','PD Term 4'};
            if(programName == 'Master Programs' || (lstSpecializedProgramCategory.contains(programName) && progrType.contains(objAcc.Program_Type__c))) {
                programName = objAcc.Program_Type__c;
            }
            // String programName = objAcc.nm_ChooseaProgram__c == 'Master Programs' ? objAcc.Program_Type__c : objAcc.nm_ChooseaProgram__c;
            System.debug('programName ==>'+programName);
            if(mapOfProgramVsProfiles.containsKey(programName)) {
                Account objAccountUpdate = new Account();
                objAccountUpdate.id = objAcc.id;
                List<String> lstProfileId = mapOfProgramVsProfiles.get(programName);
                System.debug('lstProfileId size ==>'+lstProfileId.size());
                System.debug('lstProfileId ==>'+lstProfileId);
                if(lstProfileId.size() > 1 && mapOfProfileVsCount.size() > 0) {
                    System.debug('Entered if condition');
                    String lowKey = mapOfProfileVsCount.isEmpty() ? null : new List<String>(mapOfProfileVsCount.keySet())[0];
                    String noKey = null;
                    for (String profileId : lstProfileId) {
                        if(mapOfProfileVsCount.containsKey(profileId)) {
                            lowKey = mapOfProfileVsCount.containsKey(profileId) && mapOfProfileVsCount.get(profileId) < mapOfProfileVsCount.get(lowKey) ? profileId : lowKey;
                        } else {
                            noKey = profileId;
                            break;
                        }
                    }
                    objAccountUpdate.Admission_Co_ordinator__c = String.isNotBlank(noKey) ? noKey : lowKey;
                } else {
                    System.debug('Entered else condition');
                    objAccountUpdate.Admission_Co_ordinator__c = lstProfileId[0];
                    System.debug('Random element: '+lstProfileId[0]);
                }
                lstOfAccountUpdate.add(objAccountUpdate);
                mapOfProfileVsCount = updateMapProfileVsCount(mapOfProfileVsCount,objAccountUpdate.Admission_Co_ordinator__c);
            }
        }

        if(lstOfAccountUpdate.size() > 0) {
            update lstOfAccountUpdate;
        }

    }

    /**
    * @description 
    * @author @BK | 02-15-2021 
    * @param mapOfProfileVsCount 
    * @param recId 
    * @return Map<String, Integer> 
    **/
    public Map<String,Integer> updateMapProfileVsCount(Map<String,Integer> mapOfProfileVsCount, String recId) {
        Integer count = mapOfProfileVsCount.containsKey(recId) ? mapOfProfileVsCount.get(recId) : 0;
        count++;
        mapOfProfileVsCount.put(recId,count);
        return mapOfProfileVsCount;
    }
    
    public void UpdateMobileAndEmailVerifyDateTime(list<Account> lstAcc,Map<id,Account> oldMap)
    {
        for(Account objAcc : lstAcc)
        {
            if(objAcc.nm_IsEmailVerified__c && objAcc.nm_IsEmailVerified__c !=oldMap.get(objAcc.id).nm_IsEmailVerified__c)
            {
                objAcc.Email_Verified_DateTime__c = System.now();
            }else if(objAcc.Is_Mobile_Verified__c && objAcc.Is_Mobile_Verified__c !=oldMap.get(objAcc.id).Is_Mobile_Verified__c)
            {
                objAcc.Mobile_Verified_dateTime__c = System.now();
            }
        }
    }
    
    public void copyAddress(list<Account> lstAccount)
    {
        if(lstAccount != null && lstAccount.size() > 0)
        {
            for(Account objAccount:lstAccount) 
            {
              if(objAccount.Shipping_Address_Choice__c== 'Shipping Address as Permanent Address')
                {
                    objAccount.House_No_Name_Shipping_Account__c =objAccount.nm_HouseNumber_P__c;
                    objAccount.Shipping_Street__c=objAccount.nm_Street__c;
                    objAccount.City_Shipping_Account__c=objAccount.nm_City__c;
                    objAccount.State_Province_Shipping__c=objAccount.nm_StateProvince__c;
                    objAccount.Zip_Postal_Code_Shipping__c=objAccount.nm_PostalCode__c;
                    objAccount.Country_Shipping__c=objAccount.nm_Country__c;
                    objAccount.Locality_Name_Shipping__c = objAccount.nm_LocalityName_P__c;
                    objAccount.Nearest_LandMark_shipping__c= objAccount.nm_NearestLandmark_P__c;   
                }
                else if(objAccount.Shipping_Address_Choice__c=='Shipping Address as Billing Address')
                {
                    objAccount.House_No_Name_Shipping_Account__c =objAccount.nm_HouseNumber__c;
                    objAccount.Shipping_Street__c=objAccount.BillingStreet;
                    objAccount.City_Shipping_Account__c=objAccount.BillingCity;
                    objAccount.State_Province_Shipping__c=objAccount.BillingState;
                    objAccount.Zip_Postal_Code_Shipping__c=objAccount.BillingPostalCode;
                    objAccount.Country_Shipping__c=objAccount.BillingCountry;
                    objAccount.Locality_Name_Shipping__c = objAccount.nm_LocalityName__c;
                    objAccount.Nearest_LandMark_shipping__c = objAccount.nm_NearestLandmark__c;  
                }
            }      
        }         
    }

      
  /*  public void AvoidDuplicateMobileNumberandEmailwithAccount(list<Account> lst,map<id,Account> oldmap)
    {
        set<string> SetOfMobile=new set<string>();
        set<string> SetOfEmail=new set<string>();
        System.debug('Account size--->'+lst.size());
        list<nm_UserMapping__c> lstUserMapping=new list<nm_UserMapping__c>();
        lstUserMapping=[select id,nm_Centers__c,nm_User__r.UserRole.Name,nm_User__r.Name,nm_User__r.Profile.Name from nm_UserMapping__c where nm_User__c=:UserInfo.getUserId()];
        system.debug('UserInfo.getUserId()'+UserInfo.getUserId()); 
      
        if(lstUserMapping.size()>0)
        {
            if(lstUserMapping[0].nm_User__r.Profile.Name!='System Administrator'||lstUserMapping[0].nm_User__r.Profile.Name!='Head Office')
            {
                for(Account objAcc:lst)
                {
                        if(oldmap.get(objAcc.id).PersonEmail != objAcc.PersonEmail)
                        {
                            SetOfEmail.add(objAcc.PersonEmail);
                            system.debug('SetOfEmail'+SetOfEmail);    
                        }
                        System.debug('Mobile Change-->'+(oldmap.get(objAcc.id).PersonMobilePhone!= objAcc.PersonMobilePhone));
                        if(oldmap.get(objAcc.id).PersonMobilePhone!= objAcc.PersonMobilePhone)
                        {
                            SetOfMobile.add(objAcc.PersonMobilePhone);
                            system.debug('SetOfMobile'+SetOfMobile);    
                        }
                }
            }                   
                            
        }                           
        if(SetOfMobile.size()>0 || SetOfEmail.size()>0)
        {
            // Checking Account's Mobile number and Email with Lead.
            list<Lead> lstLead=[select id,Email,MobilePhone from Lead where (Email In:SetOfEmail or MobilePhone In:SetOfMobile) and IsConverted=false];
            list<Account> lstExistingAccount=[select id,PersonMobilePhone,PersonEmail from Account where (PersonEmail In:SetOfEmail or PersonMobilePhone In: SetOfMobile)];                                                                                                                                  
            system.debug('lstExistingAccount'+lstExistingAccount.size());                                

            if(lstLead.size()>0)
            {
            for(Account objAccount:lst)
            {
                for(Lead objLead:lstLead)
                {    
                    if(objLead.Email==objAccount.PersonEmail && oldmap.get(objAccount.id).PersonEmail!=objAccount.PersonEmail)
                    {
                        objAccount.addError('Already lead available with this Email');
                    }
                    if(objLead.MobilePhone==objAccount.PersonMobilePhone && oldmap.get(objAccount.id).PersonMobilePhone!=objAccount.PersonMobilePhone)
                    {
                        objAccount.addError('Already lead available with this MobilePhone ');
                    }
                }
            }
            }
            if(lstExistingAccount.size()>0)
            {
                for(Account objNewAccount:lst )
                {
                    for(Account objExistingAccount:lstExistingAccount)
                    {
                        if(objExistingAccount.PersonMobilePhone==objNewAccount.PersonMobilePhone && !objNewAccount.Is_Lateral__c)
                        {
                            objNewAccount.addError('Already Account available with this MobilePhone');
                        }
                        if(objExistingAccount.PersonEmail==objNewAccount.PersonEmail && !objNewAccount.Is_Lateral__c)
                        {
                            objNewAccount.addError('Already Account available with this Email');
                        }
                    }
                }
            
            }
        }
          
    }*/
    /*commented give acces to eidt email and mobile update
     public void AvoidDuplicateMobileNumberandEmailwithAccount(list < Account > lst, map < id, Account > oldmap) {
     set < string > SetOfMobile = new set < string > ();
     set < string > SetOfEmail = new set < string > ();
     System.debug('Account size--->' + lst.size());
     list < nm_UserMapping__c > lstUserMapping = new list < nm_UserMapping__c > ();
     lstUserMapping = [select id, nm_Centers__c, nm_User__r.UserRole.Name, nm_User__r.Name, nm_User__r.Profile.Name from nm_UserMapping__c where nm_User__c = : UserInfo.getUserId()];
     system.debug('UserInfo.getUserId()' + UserInfo.getUserId());

     if (lstUserMapping.size() > 0) {
         if (lstUserMapping[0].nm_User__r.Profile.Name != 'System Administrator' || lstUserMapping[0].nm_User__r.Profile.Name != 'Head Office') {
             for (Account objAcc: lst) {
                 if (oldmap.get(objAcc.id).PersonEmail != objAcc.PersonEmail) {
                     SetOfEmail.add(objAcc.PersonEmail);
                     system.debug('SetOfEmail' + SetOfEmail);
                 }
                 System.debug('Mobile Change-->' + (oldmap.get(objAcc.id).PersonMobilePhone != objAcc.PersonMobilePhone));
                 if (oldmap.get(objAcc.id).PersonMobilePhone != objAcc.PersonMobilePhone) {
                     SetOfMobile.add(objAcc.PersonMobilePhone);
                     system.debug('SetOfMobile' + SetOfMobile);
                 }
             }
         }

     }
     if (SetOfMobile.size() > 0 || SetOfEmail.size() > 0) {
         // Checking Account's Mobile number and Email with Lead.
         list < Lead > lstLead = [select id, Email, MobilePhone, IC_company__c, LC_Name__c, LeadSource from Lead where(Email In: SetOfEmail or MobilePhone In: SetOfMobile) and IsConverted = false];
         list < Account > lstExistingAccount = [select id, PersonMobilePhone, PersonEmail, IC_company__c, LC_Name__c, PersonLeadSource from Account where(PersonEmail In: SetOfEmail or PersonMobilePhone In: SetOfMobile)];
         system.debug('lstExistingAccount' + lstExistingAccount.size());
         boolean checksameLCorCmp = false;
         string sourceupdate;
         if (lstLead.size() > 0) {
             for (Account objAccount: lst) {
                 for (Lead objLead: lstLead) {
                      if(objLead.Email==objAccount.PersonEmail && oldmap.get(objAccount.id).PersonEmail!=objAccount.PersonEmail)
                        {
                            objAccount.addError('Already lead available with this Email');
                        }
                        if(objLead.MobilePhone==objAccount.PersonMobilePhone && oldmap.get(objAccount.id).PersonMobilePhone!=objAccount.PersonMobilePhone)
                        {
                            objAccount.addError('Already lead available with this MobilePhone ');
                        }
                     if (!IsNullOrEmpty(objAccount.LC_Name__c) && !IsNullOrEmpty(objLead.LC_Name__c) && (objAccount.LC_Name__c).equalsIgnoreCase(objLead.LC_Name__c)) {
                         checksameLCorCmp = true;
                     } else if (!IsNullOrEmpty(objAccount.IC_company__c) && !IsNullOrEmpty(objLead.IC_company__c) && (objAccount.IC_company__c).equalsIgnoreCase(objLead.IC_company__c)) {
                         checksameLCorCmp = true;
                     } else {
                         checksameLCorCmp = false;
                     }

                     if (objLead.LeadSource == 'Web' && objAccount.PersonLeadSource == 'Partner' && checksameLCorCmp == true) {
                         sourceupdate = 'Web';
                     } else if (objLead.LeadSource == 'Web' && objAccount.PersonLeadSource == 'Partner' && checksameLCorCmp == false) {
                         sourceupdate = 'Web & Partner';
                     } else if (objLead.LeadSource == 'Partner' && objAccount.PersonLeadSource == 'Web' && checksameLCorCmp == false) {
                         sourceupdate = 'Web & Partner';
                     }
                     if (sourceupdate != null && sourceupdate != '') {
                        // System.enqueueJob(new QueueClass1(objAccount, sourceupdate));
                     }

                 }
             }
         }
         if (lstExistingAccount.size() > 0) {
             for (Account objNewAccount: lst) {
                 for (Account objExistingAccount: lstExistingAccount) {
                      if(objExistingAccount.PersonMobilePhone==objNewAccount.PersonMobilePhone && !objNewAccount.Is_Lateral__c)
                      {
                          objNewAccount.addError('Already Account available with this MobilePhone');
                      }
                      if(objExistingAccount.PersonEmail==objNewAccount.PersonEmail && !objNewAccount.Is_Lateral__c)
                      {
                          objNewAccount.addError('Already Account available with this Email');
                      }
                     if (!IsNullOrEmpty(objNewAccount.LC_Name__c) && !IsNullOrEmpty(objExistingAccount.LC_Name__c) && (objNewAccount.LC_Name__c).equalsIgnoreCase(objExistingAccount.LC_Name__c)) {
                         checksameLCorCmp = true;
                     } else if (!IsNullOrEmpty(objNewAccount.IC_company__c) && !IsNullOrEmpty(objExistingAccount.IC_company__c) && (objNewAccount.IC_company__c).equalsIgnoreCase(objExistingAccount.IC_company__c)) {
                         checksameLCorCmp = true;
                     } else {
                         checksameLCorCmp = false;
                     }
                     if (objExistingAccount.PersonLeadSource == 'Web' && objNewAccount.PersonLeadSource == 'Partner' && checksameLCorCmp == true) {
                         sourceupdate = 'Web';
                     } else if (objExistingAccount.PersonLeadSource == 'Web' && objNewAccount.PersonLeadSource == 'Partner' && checksameLCorCmp == false) {
                         sourceupdate = 'Web & Partner';
                     } else if (objExistingAccount.PersonLeadSource == 'Partner' && objNewAccount.PersonLeadSource == 'Web' && checksameLCorCmp == false) {
                         sourceupdate = 'Web & Partner';
                     }

                     if (sourceupdate != null) {
                       //  System.enqueueJob(new QueueClass1(objNewAccount, sourceupdate));
                     }

                 }
             }

         }
     }

 }*/
     
    public void UpdateTask(list<Account> lstAccount,Map<id,Account> oldMap)
    {
      if(lstAccount!=null)
       {
            map<id,id>mapAccoutOwnerId=new map<id,id>();
            list<Task>lstTask=new list<Task>();
            set<id> setOfAccId =new set<id>();
            for(Account objAccount:lstAccount)
            {
               if(oldMap !=null)
               {
                   if(objAccount.OwnerId != oldMap.get(objAccount.id).OwnerId)
                   {
                     mapAccoutOwnerId.put(objAccount.id,objAccount.OwnerId);
                     setOfAccId.add(objAccount.id);
                   }
               }               
            }
            System.debug('Account Owner Id Map----->'+mapAccoutOwnerId);
            if(setOfAccId.size()>0)
            {
                System.debug('Enter In Update task Owner loop-------->');
                lstTask=[select id,Who.id,Who.Name,Owner.id,Owner.Name,AccountId from Task where AccountId IN:mapAccoutOwnerId.KeySet()];
                IF(lstTask.Size()>0)
                {
                   list<Task>TaskToUpdate=new list<Task>();
                   for(Task objTask:lstTask)
                    {
                        objTask.Ownerid=mapAccoutOwnerId.get(objTask.AccountId);
                        TaskToUpdate.Add(objTask);
                        system.debug('<---->'+lstTask.size());
                    }
                    if(TaskToUpdate.size()>0)
                    {
                       update TaskToUpdate;
                    }
                }
            }   
       }
    }  
  
    // Send Mobile and Email Verification Msg to Fresh Student till not Verified Mobile Number and als when Mobile No change prior Confirmation 
     public void sendMobileAndEmailVerificationMsg(list<Account> lstAccount,Map<id,Account> oldMap)
      {
          List<Account> lstAccountToUpdate = new List<Account>();
           boolean updateflag = false;
          if(lstAccount.size()>0)
          {
              for(Account objAccount : lstAccount)
              {
                   Account objAccountToUpdate = new Account(id=objAccount.id);
                  if((objAccount.nmCaptureOpportuntiyStage__c != oldMap.get(objAccount.id).nmCaptureOpportuntiyStage__c && !objAccount.Is_Mobile_Verified__c && objAccount.nm_StudentStatus__c !='Confirmed')
                    ||
                    (objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c && !objAccount.Is_Mobile_Verified__c && objAccount.nm_StudentStatus__c !='Confirmed')
                    ||
                    (objAccount.nm_StudentStatus__c !='Confirmed' && objAccount.PersonMobilePhone != oldMap.get(objAccount.id).PersonMobilePhone && !objAccount.Is_Mobile_Verified__c))
                  {
                   if(System.IsBatch() == false && System.isFuture() == false){
                      sendMobileNumberVerificationSMS(objAccount.id);
                      }
                  }else if(objAccount.nm_StudentStatus__c !='Confirmed' && objAccount.PersonMobilePhone != oldMap.get(objAccount.id).PersonMobilePhone && objAccount.Is_Mobile_Verified__c)
                  {
                      //Account objAccountToUpdate = new Account(id=objAccount.id);
                     if(System.IsBatch() == false && System.isFuture() == false){
                          sendMobileNumberVerificationSMS(objAccount.id);
                          updateflag = true;
                          objAccountToUpdate.Is_Mobile_Verified__c = false;
                      }
                     // lstAccountToUpdate.add(objAccountToUpdate);
                  }
                  
                  if((objAccount.nmCaptureOpportuntiyStage__c != oldMap.get(objAccount.id).nmCaptureOpportuntiyStage__c && !objAccount.nm_IsEmailVerified__c && objAccount.nm_StudentStatus__c !='Confirmed')
                    ||
                    (objAccount.nm_StudentStatus__c != oldMap.get(objAccount.id).nm_StudentStatus__c && !objAccount.nm_IsEmailVerified__c && objAccount.nm_StudentStatus__c !='Confirmed')
                    ||
                    (objAccount.nm_StudentStatus__c !='Confirmed' && objAccount.PersonEmail != oldMap.get(objAccount.id).PersonEmail && !objAccount.nm_IsEmailVerified__c))
                  {
                       if(System.IsBatch() == false && System.isFuture() == false){
                          sendEmailVerificationMail(objAccount.id);
                      }
                  }else if(objAccount.nm_StudentStatus__c !='Confirmed' && objAccount.PersonEmail != oldMap.get(objAccount.id).PersonEmail && objAccount.nm_IsEmailVerified__c)
                  {
                    
                    if(System.IsBatch() == false && System.isFuture() == false){
                        updateflag = true;
                        objAccountToUpdate.nm_IsEmailVerified__c = false;
                        sendEmailVerificationMail(objAccount.id);
                    }
                  }
                  system.debug('objAccountToUpdate--->'+objAccountToUpdate);
                  if(updateflag && ( !objAccountToUpdate.Is_Mobile_Verified__c || !objAccountToUpdate.nm_IsEmailVerified__c))
                  {
                      lstAccountToUpdate.add(objAccountToUpdate);
                  }
              }
              
              if(lstAccountToUpdate.size()>0)
              {
                  update lstAccountToUpdate;
              }
          }
      }
         public void autoAupdateStateAndCountryBasedUponPostalCode(List<Account> lstAccount,map<id, Account> mapAccountOldMap)
  {
      for(Account objAccount : lstAccount)
      {
          if(((objAccount.BillingPostalCode !=null && objAccount.BillingPostalCode!= mapAccountOldMap.get(objAccount.id).BillingPostalCode)
              || 
              (objAccount.nm_PostalCode__c !=null && objAccount.nm_PostalCode__c!= mapAccountOldMap.get(objAccount.id).nm_PostalCode__c)
              ||
              (objAccount.Zip_Postal_Code_Shipping__c !=null
              && objAccount.Zip_Postal_Code_Shipping__c!= mapAccountOldMap.get(objAccount.id).Zip_Postal_Code_Shipping__c ))
              && objAccount.nm_StudentNo__c ==null)
          {   
            if(System.IsBatch() == false && System.isFuture() == false){
              autoUpdateStateAndCountryWebService(objAccount.id);
            }
          }
      }
  }
  

  
    /*public void createLeadInLeadSquare(List<Account> listOfAccount )
    {
        for(Account objAccount :listOfAccount)
        {
            if(objAccount.nm_StudentStatus__c == 'Confirmed' && objAccount.nm_StudentNo__c!= null && (objAccount.LeadSquared_Id__c=='' || objAccount.LeadSquared_Id__c==null)){
            autoCreateLeadInLeadSquare(objAccount.id); 
            }
        }
        
    }*/
    public boolean IsNullOrEmpty(String fieldValue){
        if(fieldValue == null || fieldValue == ''){
            return true;
        }
        return false;
    }
    
    /**
    * @description 
      callCancelStudentHelperClass for admission cancel or registration cancel or reject student (master program)
    * @author shubhranshu | 11/1/2019 
    * @param triggerNew 
    * @param OldMap 
    * @return void 
    **/
    public void callCancelStudentHelperClass(list<Account> triggerNew,map<id,Account> OldMap)
    {
        Set<String> formConfigurationKey = new Set<String>();
        List<Account> lstAccountForInitialDate = new List<Account>();
        List<Account> lstAccount = new List<Account>();
        for(Account obj:triggerNew) {
            if(obj.Interview_Status__c=='Rejected' && OldMap.get(obj.id).Interview_Status__c != obj.Interview_Status__c && obj.nm_ChooseaProgram__c == 'Master Programs' && obj.nm_StudentStatus__c!='Confirmed' 
                || ((obj.nm_StudentStatus__c=='Admission Cancelled' || obj.nm_StudentStatus__c=='Registration Cancelled' || obj.nm_StudentStatus__c=='Rusticated') && (obj.nm_StudentStatus__c != OldMap.get(obj.id).nm_StudentStatus__c )))
            {
                lstAccount.add(obj);
            }

            if(obj.Interview_Status__c=='Selected' && OldMap.get(obj.id).Interview_Status__c != obj.Interview_Status__c) {
                lstAccountForInitialDate.add(obj);
                String key = obj.Program_Type__c;
                if(String.isNotBlank(key))
                    formConfigurationKey.add(key);
                    System.debug(formConfigurationKey);
            }
        }

        if(lstAccount.size() > 0) {
            cancelAdm.intializaCancelAdmissionProcess(lstAccount,OldMap);
        }

        if(lstAccountForInitialDate.size() > 0 && formConfigurationKey.size() > 0) {
            updateInterviewSelectionDates(lstAccountForInitialDate,formConfigurationKey);
        }
    }

    public void updateInterviewSelectionDates(list<Account> triggerNew, Set<String> formConfigurationKey) {
        List<NM_Payment_Form_Configuration__c> lstConfig = [SELECT id,Payment_Window_EndDate__c,Session__c,Program_Type__c,Current_Admission_Year__c FROM NM_Payment_Form_Configuration__c WHERE Payment_Type__c='Admission' AND Program_Type__c IN :formConfigurationKey];
        List<Account> lstAccount = new List<Account>();
        System.debug('lstConfig.size() ==>'+lstConfig.size());
        if(lstConfig.size() > 0) {
            for(Account obj:triggerNew) {
                Account objAccount = new Account(id=obj.id);
                String sessionYear = obj.nm_Drive_Name__c;
                String session = String.isNotBlank(sessionYear) ? sessionYear.substringBefore('2') : null;
                String year = String.isNotBlank(sessionYear) ? sessionYear.right(4) : null;
                NM_Payment_Form_Configuration__c objFormConfigure = null;
                if(lstConfig.size() > 1) {
                    for(NM_Payment_Form_Configuration__c objConfig:lstConfig) {
                        if(objConfig.Program_Type__c == obj.Program_Type__c && objConfig.Session__c == session && objConfig.Current_Admission_Year__c == year) {
                            objFormConfigure = objConfig;
                        }
                    }
                } else {
                    objFormConfigure = lstConfig[0];
                }

                if(objFormConfigure!=null) {
                    DateTime ld = objFormConfigure.Payment_Window_EndDate__c;
                    Date endDate = ld.date();
                    Date updateAdmissionEndDate = endDate.addDays(-30);
                    Date updateSelectionEndDate = endDate.addDays(-7);

                    // to check if the intial date is greater than the window end date
                    if(System.today().addDays(7) > endDate) {
                        objAccount.Selection_InitialDate__c = updateSelectionEndDate;
                    } else {
                        objAccount.Selection_InitialDate__c = System.today();
                    }
                    // to check if the admission date is greater than the window end date
                    if(System.today().addDays(30) > endDate) {
                        objAccount.Selection_AdmissionDate__c = updateAdmissionEndDate;
                    } else {
                        objAccount.Selection_AdmissionDate__c = System.today();
                    }

                    objAccount.Interview_status_update_date__c = System.today();
                    lstAccount.add(objAccount);
                    System.debug('lstAccount.size() ==>'+lstAccount.size());
                }
            }

            if(lstAccount.size() > 0) {
                update lstAccount;
            }
        }
        
    }


    // public void callFindabilityWebservice(list<Account> triggerNew,map<id,Account> OldMap) {
    //     Set<String> lstAccountToUpdateId = new Set<String>();
    //     for(Account obj:triggerNew) {
    //        if( (IsNullOrEmpty(obj.Findability_Message__c) && !IsNullOrEmpty(obj.nm_StudentImageUrl__c) && IsNullOrEmpty(obj.nm_StudentNo__c ))
    //         || (!IsNullOrEmpty(obj.nm_StudentImageUrl__c) && obj.nm_StudentImageUrl__c != OldMap.get(obj.id).nm_StudentImageUrl__c) )
    //         {
    //             lstAccountToUpdateId.add(obj.Id);
    //         }
    //         if(lstAccountToUpdateId.size() > 0) {
    //             CallWebServiceFindability(lstAccountToUpdateId);
    //         }
    //     }
    // }

    // @future(callout=true)
    // public static void CallWebServiceFindability(Set<String> accId) {
    //     if(accId.size() > 0) {
    //         FindabilityWebService.FSPhotoIDMatchAPI(accId.toString());
    //     }
    // }

    
// public void callFindabilityWebservicevs2(list<Account> triggerNew,map<id,Account> OldMap) {
//     Set<String> lstAccountToUpdateId = new Set<String>();
//     for(Account obj:triggerNew) {
//         if( (IsNullOrEmpty(obj.Findability_Message__c) && !IsNullOrEmpty(obj.nm_StudentImageUrl__c) && IsNullOrEmpty(obj.nm_StudentNo__c ))
//             || ( !IsNullOrEmpty(obj.nm_StudentImageUrl__c) && obj.nm_StudentImageUrl__c != OldMap.get(obj.id).nm_StudentImageUrl__c) )
//         {
//             lstAccountToUpdateId.add(obj.Id);
//         }
//         if(lstAccountToUpdateId.size() > 0) {
//             FindabilityWebService.FSPhotoIDMatchAPI(lstAccountToUpdateId.toString());
//         }

//     }
// }


    /**
    * @description 
    * @author @BK | 18/1/2020 
    * @param triggerNew 
    * @param oldMap 
    * @return void 
    **/
    // public void updateDocumentSubmittedDate(list<Account> triggerNew,map<id,Account> oldMap) {
    //     List<Account> lstAccountToUpdate = new List<Account>();
    //     for (Account objAccount : triggerNew) { 
    //         System.debug('nm_StudentStatus__c -->'+objAccount.nm_StudentStatus__c);
    //         System.debug('oldMap '+oldMap.get(objAccount.id).nm_StudentStatus__c);

    //         if( oldMap.get(objAccount.id).nm_StudentStatus__c != objAccount.nm_StudentStatus__c && 
    //             (objAccount.nm_StudentStatus__c == 'Admission form & documents submitted' || objAccount.nm_StudentStatus__c == 'Documents Re-submitted') ) {
    //             Account objAccountToUpdate = new Account(id=objAccount.id);
    //             System.debug('objAccount before update Datetime-->'+objAccount.Documnet_submitted_date_on_Lead__c);
    //             if(objAccount.Documnet_submitted_date_on_Lead__c != null) {
    //                 objAccountToUpdate.nm_DocumentSubmittedDate__c = objAccount.Documnet_submitted_date_on_Lead__c;
    //                 objAccountToUpdate.Documnet_submitted_date_on_Lead__c = null;
    //             }
    //             else {
    //                 objAccountToUpdate.nm_DocumentSubmittedDate__c = Datetime.now();
    //             }
    //             System.debug(' ----------------------- Account Record ------------------------');
    //             System.debug(objAccountToUpdate);
    //             lstAccountToUpdate.add(objAccountToUpdate);
    //         }
    //     }

    //     if(lstAccountToUpdate.size() > 0) {
    //         System.debug('lstAccountToUpdate -->'+lstAccountToUpdate.size());
    //         try {
    //             update lstAccountToUpdate;
    //         } catch (Exception ex) {
    //             System.debug('error msg-->'+ex.getMessage());
    //         }
    //     }
    // }

  /*  public Void NotAllowtowaiveOffStudent(list<Account> lstAccount,map<id,Account> OldMap)
    {
            set<string> SetofAccId = new set<string>();
            list<Account> lstAccountUpdate = new list<Account>();
            boolean IsDocumentApproved =false;
        list<nm_UserMapping__c> lstUserMapping=[select id,nm_Centers__c,nm_User__r.UserRole.Name,nm_User__r.Name,nm_User__r.Profile.Name from nm_UserMapping__c where nm_User__c=:UserInfo.getUserId()];
        if(lstUserMapping.size()>0)
        {
            if(lstUserMapping[0].nm_User__r.Profile.Name!='System Administrator')
            {
                for(Account objAccount: lstAccount)
                {
                if(objAccount.Aadhaar_Card_Waive_Off__c!=OldMap.get(objAccount.id).Aadhaar_Card_Waive_Off__c && !OldMap.get(objAccount.id).Aadhaar_Card_Waive_Off__c && objAccount.Aadhaar_Card_Waive_Off__c )
                    {
                    SetofAccId.add(objAccount.id);   
                    }
                }
            }   
        } 
        if(SetofAccId.size()>0)
        {
            list<nm_LinksForDocuments__c> lstDocument = [select id,nm_Status__c,nm_Account__c,Name from nm_LinksForDocuments__c where  nm_Account__c In :SetofAccId];
            for(Account objAccount : lstAccount)
            {
                for(nm_LinksForDocuments__c objLinkDocument :lstDocument)
                {
                if(objLinkDocument.nm_Status__c=='Approved' && objLinkDocument.Name=='Aadhaar Card')
                {
                    objAccount.AddError('You can not Waive Off AadhaarCard,Because already AadhaarCard approved');
                }
                if(objLinkDocument.nm_Status__c!='Approved' && objLinkDocument.Name=='Aadhaar Card')
                {
                        
                        IsDocumentApproved=true;
                    
                }
                
                }
                if(IsDocumentApproved)
                {
                        Account ObjAcc = new Account(id=objAccount.id);
                       // ObjAcc .Adhar_Card_Number__c='';
                        lstAccountUpdate.add(ObjAcc); 
                }
            }
            if(lstAccountUpdate.size()>0)
            {
                update lstAccountUpdate ;
            }
        
        }
    }*/
  
    @future (callout=true)
    public static void updateProfileonStudentZone(String AccountId)
    {
        if (System.Label.Environment != 'Production' && !Test.isRunningTest()) {
            return;
        }
        
        API_Request__c apiReq = new API_Request__c();
        System.debug('update Student Profile Called--->');
        Account objAccount =[SELECT id,nm_SpouseName__c,FirstName,LastName,House_No_Name_Shipping_Account__c,Phone,Locality_Name_Shipping__c,Nearest_LandMark_Shipping__c,City_Shipping_Account__c,Shipping_Street__c,State_Province_Shipping__c,Country_Shipping__c,
                Zip_Postal_Code_Shipping__c,nm_DateOfBirth__c,PersonEmail,nm_StudentNo__c,PersonMobilePhone,nm_StudentImageUrl__c,Father_First_Name__c,Mother_First_Name__c,Validity_Month__c,Extend_Validity_upto_Month__c,Extend_Validity_Upto_Year__c,Validity_Year__c,
                nm_Centers__c,nm_Centers__r.Name,nm_Program__r.Name,nm_Program__r.StudentZoneProgramCode__c,nm_Program__r.prgst__c,Highest_Qualification__c,prgst__c,Provisional_With_Hold__c FROM Account WHERE id=:AccountId];
        String validitymonth = (objAccount.Extend_Validity_upto_Month__c!='' && objAccount.Extend_Validity_upto_Month__c!=null) ? objAccount.Extend_Validity_upto_Month__c.left(3) : objAccount.Validity_Month__c.left(3);
        String validityyear = (String.valueOf(objAccount.Extend_Validity_Upto_Year__c)!='' && String.valueOf(objAccount.Extend_Validity_Upto_Year__c)!=null) ? String.valueOf(objAccount.Extend_Validity_Upto_Year__c).replace(',','') : String.valueof(objAccount.Validity_Year__c);
        String CenterID = objAccount.nm_Centers__c;
        System.debug('validitymonth---->'+validitymonth );
        System.debug('validityyear ---->'+validityyear );
        System.debug('objAccount.id ---->'+objAccount.id );
        List<nm_StudentProgram__c> lstStudentProgram = [SELECT id,Previous_program_name__c FROM nm_StudentProgram__c WHERE nm_Student__c=:AccountId AND nm_PreviousProgram__c!=null];
        Opportunity objOpportunity = [SELECT id,Drive_Month__c,Enrollment_Year__c FROM Opportunity WHERE AccountId=:objAccount.id ORDER BY Sem__c,CreatedDate ASC LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
         req.setEndpoint(System.Label.Student_Portal+'m/updateProfileFromSFDC');
        //req.setEndpoint('https://uat-studentzone-ngasce.nmims.edu/studentportal/m/updateProfileFromSFDC');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        String previousProgram = lstStudentProgram.size() > 0 ? lstStudentProgram[0].Previous_program_name__c : null;
        String programStructure = String.isNotBlank(objAccount.prgst__c) ? objAccount.prgst__c : objAccount.nm_Program__r.prgst__c;
        String sapId = objAccount.nm_StudentNo__c;
        String provisionalAdmission = objAccount.Provisional_With_Hold__c ? 'true ' : 'false';
        Map<String,String> mapOfRequest = new Map<String,String>();
        mapOfRequest.put('sapid',sapId);
        mapOfRequest.put('firstName',objAccount.FirstName);
        mapOfRequest.put('lastName',objAccount.LastName);
        mapOfRequest.put('spouseName',objAccount.nm_SpouseName__c);
        mapOfRequest.put('emailId',objAccount.PersonEmail);
        mapOfRequest.put('mobileNo',objAccount.PersonMobilePhone);
        mapOfRequest.put('fatherName',objAccount.Father_First_Name__c);
        mapOfRequest.put('motherName',objAccount.Mother_First_Name__c);
        mapOfRequest.put('studentImage',objAccount.nm_StudentImageUrl__c);
        mapOfRequest.put('validityEndMonth',validitymonth);
        mapOfRequest.put('validityEndYear',validityyear);
        mapOfRequest.put('centerId',CenterID.left(15));
        mapOfRequest.put('centerName',objAccount.nm_Centers__r.Name);
        mapOfRequest.put('program',objAccount.nm_Program__r.StudentZoneProgramCode__c);
        mapOfRequest.put('addressLine1',objAccount.House_No_Name_Shipping_Account__c); // house No Name (Shipping)
        mapOfRequest.put('addressLine2',objAccount.Shipping_Street__c); // street (Shipping)
        mapOfRequest.put('addressLine3',objAccount.Locality_Name_Shipping__c); // locality (Shipping)
        mapOfRequest.put('landMark',objAccount.Nearest_LandMark_Shipping__c);
        mapOfRequest.put('city',objAccount.City_Shipping_Account__c);
        mapOfRequest.put('state',objAccount.State_Province_Shipping__c);
        mapOfRequest.put('country',objAccount.Country_Shipping__c);
        mapOfRequest.put('pin',objAccount.Zip_Postal_Code_Shipping__c);
        mapOfRequest.put('dob',String.valueOf(objAccount.nm_DateOfBirth__c));
        mapOfRequest.put('altPhone',objAccount.Phone);
        mapOfRequest.put('programStructure',programStructure);
        mapOfRequest.put('previousProgram',previousProgram);
        mapOfRequest.put('highestQualification',objAccount.Highest_Qualification__c);
        mapOfRequest.put('enrollmentMonth',objOpportunity.Drive_Month__c);
        mapOfRequest.put('enrollmentYear',objOpportunity.Enrollment_Year__c);
        mapOfRequest.put('provisionalAdmission',provisionalAdmission);
        if(String.isNotBlank(sapId) && sapId.startsWithIgnoreCase('De-Registered_')) {
            List<String> lstDeRgisteredMarkedField = new List<String> {'sapid','emailId','mobileNo','altPhone'};
            for(String key : mapOfRequest.keySet()) {
                if(lstDeRgisteredMarkedField.contains(key)) {
                    String mapValue = mapOfRequest.get(key)!=null ? mapOfRequest.get(key).removeStartIgnoreCase('De-Registered_') : mapOfRequest.get(key);
                    mapOfRequest.put(key, mapValue);
                }
            }
        }
        String jsonString = JSON.serialize(mapOfRequest);
        req.setBody(jsonString);
        System.debug(jsonString);

        apiReq.Request__c = jsonString;
        apiReq.Account__c = objAccount.id;
        apiReq.Type_of_Request__c= 'PortalAPI';
        apiReq.API_Name__c='updateProfileFromSFDC';
        try {
            res = http.send(req);
            apiReq.Response__c = res.getBody();
            if(res.getStatusCode() == 200){
                apiReq.Success__c = true;
            }

        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            apiReq.Response__c = res.getBody();
        }
        apiRequestsInsertion(apiReq);
    }

    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }
   /*@future (callout=true)
    
    public static void autoCreateLeadInLeadSquare(String AccountObj)
    {
     
     system.debug('AccountObj--->'+AccountObj);
        AccounttoleadSquaredConfigWebservice.createListofAccount(AccountObj);
    }*/
    /*Queue class remove 
            public class QueueClass1 implements Queueable {
        
            public Account objaccount;
            String source = '';
            public QueueClass1(Account objaccount, string source) {
        
                this.objaccount = objaccount;
                this.source = source;
            }
        
            public void execute(QueueableContext queCont) {
                List < Account > lstacc = new list < Account > ();
                if (source != null && source != '') {
                    objaccount.PersonLeadSource = source;
                    lstacc.add(objaccount);
                }
                if (lstacc.size() > 0) {
                    update lstacc;
                }
            }
        
        }*/
     @future 
    public static void changeStudentImageLkD(String AccountId, String url)
    {
        nm_LinksForDocuments__c objdoc =[select id,name,nm_DocumentName__c,nm_Account__c,nm_URLforDocuments__c from nm_LinksForDocuments__c where nm_DocumentName__c ='Student Photograph'  and nm_Account__c =:AccountId ];
        list<nm_LinksForDocuments__c> lsttoupdate = new List<nm_LinksForDocuments__c> ();
        if(objdoc!=null)
        {
            objdoc.nm_URLforDocuments__c = url;
            lsttoupdate.add(objdoc);
        }
        if(lsttoupdate.size()>0)
        {
            update lsttoupdate;
        }
    }       
    @future (callout=true)
    public static void sendMobileNumberVerificationSMS(String AccountId)
    {
        
        Account objAccount =[select id,PersonEmail,nmStudent_Program__c,nm_RegistrationNumber__c,nm_StudentNo__c,PersonMobilePhone,IC_Name_1__c,
                            ( select id, nm_FeesPaidofSemester__c,  nm_Program__r.Name
                                from Student_Program__r
                                where nm_IsClosed__c = false limit 1)
                            from Account where id=:AccountId ];
        if( objAccount.Student_Program__r != null && objAccount.Student_Program__r.size() > 0 )
        { 
            String studentNo = objAccount.nm_StudentNo__c !=null ? objAccount.nm_StudentNo__c : objAccount.nm_RegistrationNumber__c;
            String displayName = objAccount.nm_StudentNo__c !=null ? 'Student No.' : 'Registration No.';
            if (objAccount.IC_Name_1__c == 'RateGain Travel Technologies Ltd.') {
                nmSendNotification.sendVerificationSMSToStudentForCorporateFrom(objAccount.PersonMobilePhone,objAccount.Student_Program__r[0].nm_Program__r.Name,studentNo ,displayName ,'Account',objAccount.id);  
            } else {
                nmSendNotification.sendVerificationSMSToStudent(objAccount.PersonMobilePhone,objAccount.Student_Program__r[0].nm_Program__r.Name,studentNo ,displayName ,'Account',objAccount.id);  
            }
        }     
    }
    
    @future (callout=true)
    public static void sendEmailVerificationMail(String AccountId)
    {
        Account objAccount =[select id,PersonEmail,FirstName,LastName,PersonMobilePhone,LC_Email__c from Account where id=:AccountId];
        nmSendNotification.sendVerificationEmailToStudent(objAccount.PersonEmail,objAccount.LC_Email__c,objAccount.FirstName+''+objAccount.LastName,'Account',objAccount.id);
    }

    @future (callout=true)
    public static void autoUpdateStateAndCountryWebService(String AccountId)
    {   
        AutoUpdateStateAndCountryWebService.updateStateandCountyOnAccount(AccountId);  
    }
    

    @future
    public static void updateAllOpportuinty(Id accId,Id ProgramChange){
        List<Opportunity> lstOpp= [select Id,nm_Program2__c from Opportunity where AccountId =:accId];
        List<Opportunity> updateLstOpp = new List<Opportunity>();

        for(Opportunity opp:lstOpp){
            opp.nm_Program2__c = ProgramChange;
            updateLstOpp.add(opp);
        }

        if(updateLstOpp.size()>0){
            update updateLstOpp;
        }
    }
   /* @future 
    public static void InterviewSchedules(String AccountId)
    {
          Account objAccount =[select id,PersonEmail,nmStudent_Program__c,Interview_Date__c,nm_StudentNo__c,PersonMobilePhone,
                            ( select id, nm_FeesPaidofSemester__c,  nm_Program__r.Name
                                from Student_Program__r
                                where nm_IsClosed__c = false limit 1)
                            from Account where id=:AccountId ];
                List<Account> lstToupdate = new List<Account>();                
                            
                        Interview_Slot__c objslot = [select id ,Interview_Date__c 
                                                                    from Interview_Slot__c 
                                                                    where Interview_Date__c >=:Date.today().addDays(5)
                                                                    order by CreatedDate desc
                                                                    limit 1
                                                                    ];
                                       system.debug(objslot);
                                       
                                       if(objslot.Interview_Date__c!=null)
                                       {
                                           objAccount.Interview_Date__c= objslot.Interview_Date__c;
                                           lstToupdate.add(objAccount);
                                       }
                                       else
                                       {
                                           //default set next saturday by default as interview date
                                            Date myDate = Date.today().addDays(7);
                                            Date weekStart = myDate.toStartofWeek().addDays(6);
                                            system.debug('value--->'+weekStart);
                                            objAccount.Interview_Date__c = weekStart;
                                       }
                                       
                                       if(lstToupdate.size()>0)
                                       {
                                           update lstToupdate;
                                       }
    }*/
}