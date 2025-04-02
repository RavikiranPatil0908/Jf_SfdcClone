public with sharing class MassAccountupdate {
    private final ApexPages.StandardSetController cntr;
    private final PageReference fromPage{get;set;}
    private transient ApexPages.Message currentMsg{get;set;}
    private string currentStep{get;set;}
    public List<Account> lstOfSelectedRecords{get;set;}
    public integer sizeOfRecordsToUpdate{get;set;}
    public String AccountFieldAction{get;set;}
    public List<String> lstOfUrls{get;set;}
    public List<Account> lstOfAccounttoUpdate{get;set;}
    public String returnUrl{get;set;}
    public String Status{get;set;}
    public String CPprofile {get;set;}
    public String Center{get;set;}
    Public String Profileid {get;set;}
    public string getStep(){
        return currentStep;
    }

    public MassAccountupdate (ApexPages.StandardSetController controller) {
        lstOfSelectedRecords=new  List<Account>();
        currentStep='1';
        returnUrl = null;
        Status=null;
        CPprofile =null;
        Center=null;
        lstOfUrls = new List<String>();
        lstOfAccounttoUpdate = new List<Account> ();
        controller.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)controller;

        list<string> lstAccountRecord = new  list<string>();
        List<SObject> lstSObject=cntr.getSelected();
        system.debug('lstSObject '+lstSObject.size());
        sizeOfRecordsToUpdate=lstSObject.size();
        string RecordId='';
        for(SObject s:lstSObject){
            RecordId=s.id;
            lstAccountRecord.add(RecordId);
            system.debug('lstAccountRecord'+lstAccountRecord);
            System.debug('Id Of Selected Record--->'+RecordId);
        }
        
        if(lstAccountRecord.size()>0){
            lstOfSelectedRecords=cntr.getSelected();
            System.debug('lstOfSelectedRecords----->'+lstOfSelectedRecords.size());
        }
        fromPage=cntr.cancel();
        if(sizeOfRecordsToUpdate<1){
            string msg='No record was selected on the list view.  Please click Previous button and select records for mass update.';
            currentMsg=new  ApexPages.Message(ApexPages.severity.ERROR,msg);
        }else{
            string msg='Number of records selected for update: '+sizeOfRecordsToUpdate;
            currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,msg);
        }
        ApexPages.addMessage(currentMsg);


    }
    public PageReference cancel(){
        return fromPage;
    }

    // First Page------------------------> 
    public PageReference step1(){
        currentStep='1';
        return ApexPages.currentPage();
    }

    //Second Page-----------------------------//
    public PageReference step2(){
        // system.debug('lstOfRecords in step2'+lstOfRecords);
        // if(lstOfRecords.size()<sizeOfRecordsToUpdate)return cancel();
        // currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,'Number of Per Document Page to be merged is :'+numberOfPage);
        // ApexPages.addMessage(currentMsg);
        currentStep='2';
        return ApexPages.currentPage();
    }
    public PageReference step3(){
        // data type validation
        if(currentMsg!=null){
            ApexPages.Message msg=new  ApexPages.Message(ApexPages.severity.INFO,'');
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        string msg='Please review your selections before proceeding: <br></br>';
        msg=msg+'<br><b>Records Selected:</b>    '+sizeOfRecordsToUpdate+'</br>';
        currentMsg=new  ApexPages.Message(ApexPages.severity.INFO,msg);
        ApexPages.addMessage(currentMsg);
        currentStep='3';
        return ApexPages.currentPage();
    }
    public PageReference step4(){
        if(lstOfSelectedRecords.size()>0)MassupdateAccountList(lstOfSelectedRecords);
        ApexPages.addMessage(currentMsg);
        currentStep='4';
        return ApexPages.currentPage();
    }

    public ApexPages.Message MassupdateAccountList(List<Account> lstOfSelectedRecords){
        string result;
        Set<Id> setOfSuccessfullAccountupdate = new Set<Id> ();
        nm_UserMapping__c objuser = new nm_UserMapping__c ();
        Counsellor_Profile__c  objcpuser = new Counsellor_Profile__c  ();
        System.Debug('lstOfSelectedRecords--->'+lstOfSelectedRecords);
        system.Debug('AccountFieldAction--->'+AccountFieldAction);
        if(Center!=null && Center!='')
        {
             objuser = [Select id ,nm_Centers__c, UserId__c from nm_UserMapping__c where nm_Centers__c!=null and nm_Centers__c =:Center and nm_Head__c= true limit 1];
        }
        if(CPprofile!=null && CPprofile!='')
        {
            objcpuser = [select id,ownerId,name from Counsellor_Profile__c  where id=:CPprofile limit 1];
        }

        for(Account objAccount:lstOfSelectedRecords){
            
            
            if(AccountFieldAction=='CPprofile' )
            {
                objAccount.Counselor_Profile__c= CPprofile;
                objAccount.OwnerId = objcpuser.ownerId;
                lstOfAccounttoUpdate.add(objAccount);
            }
           /*if(AccountFieldAction=='Center' && objAccount.nm_InformationCenter__c!= null)
            {
                objAccount.nm_InformationCenter__c = Center;
                
                if(objuser!=null)
                {
                  objAccount.OwnerId = objuser.UserId__c ;
                }
                lstOfAccounttoUpdate.add(objAccount);
            }*/



        }
        if(lstOfAccounttoUpdate.size()>0)
        {
            Database.SaveResult[] srList = Database.update(lstOfAccounttoUpdate,false);
            for (Database.SaveResult sr : srList) 
            {
                system.debug('sr.isSuccess()'+sr.isSuccess());
                if (sr.isSuccess()) 
                 {
                     setOfSuccessfullAccountupdate.add(sr.getId());
                    // Operation was successful, so get the ID of the record that was processed
                   currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Updated ' + sr.getId()+ ' Records');
                   ApexPages.addMessage(currentMsg );
                    System.debug('Successfully updated Account. Account ID: ' + sr.getId());
                  }
                  else                                   
                     {
                    // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) 
                        {                                           
                            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Failed to update record' +err.getMessage() + ' Records-->'+sr.getId());
                            ApexPages.addMessage(currentMsg );
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    } 
                      
            }                     
        }
       
        return currentMsg;
    }
  
         public List<SelectOption> getActionList()
       {
        /*Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);*/
        
           List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','Select field Name to Update'));
            options.add(new SelectOption('CPprofile','Counselor Profile'));

            return options;
                    
        }

    public List<SelectOption> getAllCPprofile() 
    {
        List<SelectOption> lstCPprofileOptions = new List<SelectOption>();
        lstCPprofileOptions.add(new SelectOption('', 'AEP Team Profile'));
        List<Counsellor_Profile__c> lstCPprofile =[select id ,Name from Counsellor_Profile__c where IsActive__c =false];
        
        if(lstCPprofile!=null && lstCPprofile.size()>0)
        {
            for(Counsellor_Profile__c objcp:lstCPprofile)
            {
                lstCPprofileOptions.add(new SelectOption (objcp.id,objcp.name));
            }
        }
        return lstCPprofileOptions;
    }
     
    public List<SelectOption> getAllCenter() 
    {
        List<SelectOption> lstCenterOptions = new List<SelectOption>();
       String userid= UserInfo.getUserId();
        lstCenterOptions.add(new SelectOption('', 'AEP'));
        List<nm_Centers__c> lstCenter =[select id, Name, nm_Active__c,  
        RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
        from nm_Centers__c where nm_Active__c =true  and OwnerId =: userid order by name asc];
        
        if(lstCenter!=null && lstCenter.size()>0)
        {
            for(nm_Centers__c objCenter:lstCenter)
            {
                lstCenterOptions.add(new SelectOption (objCenter.id,objCenter.name));
            }
        }
        return lstCenterOptions;
    }



}