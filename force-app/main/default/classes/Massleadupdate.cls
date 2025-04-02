/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 10-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-26-2021   shubhranshu   Initial Version
**/
public with sharing class Massleadupdate {
    private final ApexPages.StandardSetController cntr;
    private final PageReference fromPage{get;set;}
    private transient ApexPages.Message currentMsg{get;set;}
    private string currentStep{get;set;}
    public List<Lead> lstOfSelectedRecords{get;set;}
    public integer sizeOfRecordsToUpdate{get;set;}
    public String LeadFieldAction{get;set;}
    public List<String> lstOfUrls{get;set;}
    public List<Lead> lstOfLeadtoUpdate{get;set;}
    public String returnUrl{get;set;}
    public String Status{get;set;}
    public String CPprofile {get;set;}
    public String Center{get;set;}
    Public String Profileid {get;set;}
    // Public String emailId {get;set;}
    Public String profileName {get;set;}
    public string getStep(){
        return currentStep;
    }

    public Massleadupdate(ApexPages.StandardSetController controller) {
        lstOfSelectedRecords = new  List<Lead>();
        currentStep='1';
        returnUrl = null;
        Status=null;
        CPprofile =null;
        Center=null;
        lstOfUrls = new List<String>();
        lstOfLeadtoUpdate = new List<Lead> ();
        String userid= UserInfo.getUserId();
       User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userid];
       profileName = userDetails.Profile.Name;
        controller.setPageSize(1000);
        cntr=(ApexPages.StandardSetController)controller;
       //Set<String> setofChooseprogram = new set<String>();
        list<string> lstLeadRecord = new  list<string>();
        List<SObject> lstSObject=cntr.getSelected();
        system.debug('lstSObject '+lstSObject.size());
        sizeOfRecordsToUpdate=lstSObject.size();
        //string RecordId='';
        for(SObject s:lstSObject){
           // RecordId=s.id;
           // setofChooseprogram.add(s.nm_ChooseaProgram__c);
            lstLeadRecord.add(s.id);
            system.debug('lstLeadRecord'+lstLeadRecord);
            System.debug('Id Of Selected Record--->'+s.id);
        }
        
        if(lstLeadRecord.size()>0){
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
        if(lstOfSelectedRecords.size()>0)MassupdateLeadList(lstOfSelectedRecords);
        ApexPages.addMessage(currentMsg);
        currentStep='4';
        return ApexPages.currentPage();
    }

    public ApexPages.Message MassupdateLeadList(List<Lead> lstOfSelectedRecords){
        string result;
        Set<Id> setOfLeadIds = new Set<Id>();
        String userid= UserInfo.getUserId();
       User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userid];
       String emailAddress = userDetails.Email;
       String message = 'Mail will be send when massLeadUpdate activity is done, this process may take upTo 10 - 15 minutes';
        if(lstOfSelectedRecords.size() > 0) {
            for (Lead objLead : lstOfSelectedRecords) {
                setOfLeadIds.add(objLead.Id);
            }
            System.debug('setOfLeadIds --> ' + setOfLeadIds);
            System.debug('LeadFieldAction --> ' + LeadFieldAction);
            System.debug('Status --> ' + Status);
            System.debug('Center --> ' + Center);
            System.debug('CPprofile --> ' + CPprofile);
            if(lstOfSelectedRecords.size() < 50 ) {
                updateLeadSync(setOfLeadIds, LeadFieldAction, Status, Center, CPprofile, emailAddress);
                message = 'Updated Successfully, ' + message;
            } else {
                updateLeadAsync(setOfLeadIds, LeadFieldAction, Status, Center, CPprofile, emailAddress);
            }
        }
         currentMsg = new ApexPages.Message(ApexPages.severity.INFO, message);
                   ApexPages.addMessage(currentMsg );
       
        return currentMsg;
    }

    public void updateLeadSync(Set<Id> setOfLeadIds, String LeadFieldAction,String Status, String Center, String CPprofile, String emailAddress) {
        updateLeadFuture(setOfLeadIds, LeadFieldAction, Status, Center, CPprofile, emailAddress);
    }
    
    @future
    public static void updateLeadAsync(Set<Id> setOfLeadIds,String LeadFieldAction,String Status, String Center, String CPprofile, String emailAddress) {
        updateLeadFuture(setOfLeadIds, LeadFieldAction, Status, Center, CPprofile, emailAddress);
    }
    public static  void updateLeadFuture(Set<Id> setOfLeadIds,String LeadFieldAction,String Status, String Center, String CPprofile, String emailAddress ) {
        Set<Id> setOfSuccessfullLeadupdate = new Set<Id> ();
        String emailId= '';
        nm_UserMapping__c objuser = new nm_UserMapping__c ();
        Map<String,nm_UserMapping__c> mapofProgramVsUser = new Map<String,nm_UserMapping__c>();
        List<nm_UserMapping__c> lstobjuser = new List<nm_UserMapping__c>();
        Database.DMLOptions dlo = new Database.DMLOptions();
        List<Lead> lstOfLeadtoUpdate = new List<Lead>();
        Counsellor_Profile__c  objcpuser = new Counsellor_Profile__c  ();
        List<Lead> lstOfSelectedRecords = [SELECT Id, Status, nm_ChooseaProgram__c,nm_InformationCenter__c, Counselor_Profile__c,OwnerId FROM Lead WHERE Id IN :setOfLeadIds ];
        System.Debug('lstOfSelectedRecords--->'+lstOfSelectedRecords);
        system.Debug('LeadFieldAction--->'+LeadFieldAction);
        system.Debug('Center -----> ' + Center );
        String email;
        if(Center!=null && Center!='')
        {
            String query = 'Select id ,nm_Centers__c, UserId__c,Email__c ,nm_ChooseaProgram__c from nm_UserMapping__c where nm_Centers__c = \'' +Center + '\' and nm_Head__c = true';
            system.debug('query --> ' + query);
             lstobjuser = Database.query(query);
             system.debug('lstobjuser ----> ' + lstobjuser);
             if(lstobjuser.size()>0) {
                if(lstobjuser.size()>1) {
                     for (nm_UserMapping__c objuserprg : lstobjuser)
                     {
                        if(objuserprg.nm_ChooseaProgram__c!=null)
                        {
                            for(string strprogram : objuserprg.nm_ChooseaProgram__c.split(';'))
                            {
                                mapofProgramVsUser.put(strprogram,objuserprg);
                            }
                        }                           
                     }
                }else{
                    objuser = lstobjuser[0];
                }
             }
             emailId = objuser!=null && objuser.id!=null ?objuser.Email__c:null;
        }
        if(CPprofile!=null && CPprofile!='')
        {
            objcpuser = [select id,ownerId,name,OwnerEmail__c from Counsellor_Profile__c  where id=:CPprofile limit 1];
             emailId = objcpuser.OwnerEmail__c;
        }

        for(Lead objLead:lstOfSelectedRecords){
            system.debug('objLead.nm_ChooseaProgram__c--->'+objLead.nm_ChooseaProgram__c);
            if(LeadFieldAction=='Status' && objLead.Status != '')
            {
                objLead.Status = Status;
                lstOfLeadtoUpdate.add(objLead);
            }
            if(LeadFieldAction=='CPprofile' )
            {
                if(String.isNotBlank(CPprofile)) {
                    objLead.Counselor_Profile__c= CPprofile;
                }
                   objLead.OwnerId = objcpuser.ownerId;
                    dlo.EmailHeader.triggerAutoResponseEmail = true;
                    dlo.assignmentRuleHeader.useDefaultRule= true;
                    dlo.EmailHeader.triggerUserEmail = true;
                    objLead.SetOptions(dlo); 

                lstOfLeadtoUpdate.add(objLead);
            }
            if(LeadFieldAction=='Center' && objLead.nm_InformationCenter__c!= null)
            {
                objLead.nm_InformationCenter__c = Center;
                if(String.isNotBlank(CPprofile)) {
                    objLead.Counselor_Profile__c= CPprofile;
                    objLead.OwnerId = objcpuser.ownerId ;
                    dlo.EmailHeader.triggerAutoResponseEmail = true;
                    dlo.EmailHeader.triggerUserEmail = true;
                    dlo.assignmentRuleHeader.useDefaultRule= true;
                    objLead.SetOptions(dlo);

                } else if(objuser!=null && objuser.id!=null) {
                    system.debug('objuser -->'+objuser );
                    objLead.OwnerId = objuser.UserId__c ;
                    dlo.EmailHeader.triggerAutoResponseEmail = true;
                    dlo.EmailHeader.triggerUserEmail = true;
                    dlo.assignmentRuleHeader.useDefaultRule= true;
                    objLead.SetOptions(dlo); 
                }else
                { 
                   if(mapofProgramVsUser.containsKey(objLead.nm_ChooseaProgram__c))
                    {
                         objuser = mapofProgramVsUser.get(objLead.nm_ChooseaProgram__c);
                         objLead.OwnerId = objuser.UserId__c;
                         emailId = objuser.Email__c;
                         system.debug('objuser -->'+objuser );
                    }
                  
                }

                lstOfLeadtoUpdate.add(objLead);
            }



        }
        if(lstOfLeadtoUpdate.size()>0)
        {

            Database.SaveResult[] srList = database.update(lstOfLeadtoUpdate,dlo);
            String url;
            Set<String> urlSuccessSet = new Set<String>();
            Set<String> urlFailedSet = new Set<String>();
//Database.update(lstOfLeadtoUpdate,false);
            for (Database.SaveResult sr : srList) 
            {
                system.debug('sr.isSuccess()'+sr.isSuccess());
                if (sr.isSuccess()) 
                 {
                     setOfSuccessfullLeadupdate.add(sr.getId());
                    // Operation was successful, so get the ID of the record that was processed
                //    currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Updated ' + sr.getId()+ ' Records');
                //    ApexPages.addMessage(currentMsg );
                    System.debug('Successfully updated Lead. Lead ID: ' + sr.getId());
                    url = 'https://nga-sce.force.com/'+sr.getId();
                    urlSuccessSet.add(url);
                  }
                  else                                   
                     {
                    // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) 
                        {                                           
                            // currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Failed to update record' +err.getMessage() + ' Records-->'+sr.getId());
                            // ApexPages.addMessage(currentMsg );
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Lead fields that affected this error: ' + err.getFields());
                            urlFailedSet.add(sr.getId());
                        }
                    } 
                      
            }  
            if(String.isNotBlank(emailAddress))
            // if(emailId!=null && emailId!='')
            {
             String mySuccessLong  = '';
             String myFailLong  = '';
            if (urlSuccessSet.size() > 0) {
                for(String url2:urlSuccessSet){
                    mySuccessLong += '<a href="' + url2 +'" >'+ url2 +' </a>'+'<br/>';
                 }
            }
            if (urlFailedSet.size() > 0) {
                for(String url2:urlFailedSet){
                    myFailLong += url2 ;
                 }
            }

             
             String subject = 'Lead Mass Transfer';
             
             String emailBody = 'Dear Team , <br/><br/>'
                               +' Records have been assigned to you today by '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+' , below are the details:'+'<br/><br/>'
                               + 'Success Record - ' + urlSuccessSet.size() + '<br/>'
                               +  mySuccessLong + '<br />'
                               + 'Failed Record - ' + urlFailedSet.size() + '<br/>'
                               +  myFailLong + '<br />'
                               +'<br/><br/>'
                               +'Team NMIMS CDOE';  
             
            OrgWideEmailAddress owe = [select id,Address,DisplayName from OrgWideEmailAddress WHERE DisplayName='NMIMS CDOE' LIMIT 1];
            Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
            List<String> toAddresses = new List<String>();
           // List<String> tocc = new List<String>();
            Emailwithattch.setSubject(subject);
            Emailwithattch.setOrgWideEmailAddressId(owe.id);
            toAddresses.add(emailAddress);
            if (String.isNotBlank(emailId)) {
                toAddresses.add(emailId);
            }
            System.debug('toAddresses.toString() ----> ' + toAddresses.toString());
            Emailwithattch.setToaddresses(toAddresses);
            //tocc.add('phalguni.bhadarka@gmail.com');
           // Emailwithattch.setCcAddresses(tocc);
            Emailwithattch.setReplyTo(owe.Address);
            Emailwithattch.setHtmlBody(emailBody);
    
          //  Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{});
          if (Boolean.valueOf(System.label.Mass_Lead_Email_Allowed)) {
              try {
                system.debug('inside try-- >');
                    Messaging.SendEmailResult [] r =
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
                    
                } catch (Exception e) {
                    System.debug('An exception occurred: ' + e.getMessage() + ' --- ' +e.getLineNumber());
                }
            
          }  
    
            }
            
        }
    }



  
    public List<SelectOption> getAllLeadStatus() 
    {
          List<SelectOption> options = new List<SelectOption>();
        
          Schema.DescribeFieldResult fieldResult1 = Lead.Status.getDescribe();
          List<Schema.PicklistEntry> plu = fieldResult1.getPicklistValues();
        
          for( Schema.PicklistEntry p : plu) {
             options.add(new SelectOption(p.getLabel(), p.getValue())); 
          }       
          return options;
    }
         public List<SelectOption> getActionList()
       {
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        
           List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','Select field Name to Update'));
            if(profileName!='Information Center Partner Community User')
            {
                options.add(new SelectOption('Status','Lead Status'));
                options.add(new SelectOption('Center','Information Center'));

            }
            options.add(new SelectOption('CPprofile','Counselor Profile'));

            return options;
                    
            }

    public List<SelectOption> getAllCPprofile()     
    {   
        List<SelectOption> lstCPprofileOptions = new List<SelectOption>();  
        lstCPprofileOptions.add(new SelectOption('', 'AEP Team Profile'));  
        List<Counsellor_Profile__c> lstCPprofile =[select id , Name, Full_Name__c from Counsellor_Profile__c where IsActive__c =false Order by Name asc];   
            
        if(lstCPprofile!=null && lstCPprofile.size()>0) 
        {   
            for(Counsellor_Profile__c objcp:lstCPprofile)   
            {   
                String name = objcp.name + '  ' + objcp.Full_Name__c;   
                lstCPprofileOptions.add(new SelectOption (objcp.id, name)); 
            }   
        }   
        return lstCPprofileOptions; 
    }

    public List<SelectOption> getAllCPprofileForCenter() 
    {
        List<SelectOption> lstCPprofileOptions = new List<SelectOption>();
        lstCPprofileOptions.add(new SelectOption('', 'AEP Team Profile'));
        system.debug('Center --> ' + Center);
        if(String.isNotBlank(Center)) {
            List<Counsellor_Profile__c> lstCPprofile =[select id ,Name, Full_Name__c from Counsellor_Profile__c where AEP_Name__c   =:Center AND IsActive__c =false];
            
            if(lstCPprofile!=null && lstCPprofile.size()>0)
            {
                for(Counsellor_Profile__c objcp:lstCPprofile)
                {
                    String name = objcp.name + '  ' + objcp.Full_Name__c;
                    lstCPprofileOptions.add(new SelectOption (objcp.id, name));
                }
            }
        }
        return lstCPprofileOptions;
    }
     
    public List<SelectOption> getAllCenter() 
    {
        List<SelectOption> lstCenterOptions = new List<SelectOption>();
       String userid= UserInfo.getUserId();
       User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userid];
       system.debug('Role Name:' + userDetails.UserRole.Name);
       List<nm_Centers__c> lstCenter = new List<nm_Centers__c> ();
        lstCenterOptions.add(new SelectOption('', 'AEP'));
        
        if(userDetails.UserRole.Name=='Super Admin' ){
        
                lstCenter =[select id, Name, nm_Active__c,  
                            RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                            from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and recordtype__c ='Learning Center' order by name asc];       
        } else if(userDetails.Profile.Name=='Information Center Executive Community User' && userDetails.UserRole.Name == 'Hike Education Partner Executive' ) {
            lstCenter =[select id, Name, nm_Active__c,  
                RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and GroupName__c = 'Group 1'  order by name asc];
        } else if(userDetails.Profile.Name=='Information Center Executive Community User' && userDetails.UserRole.Name == 'Kennis Learning Routes Partner Executive' ) {
            lstCenter =[select id, Name, nm_Active__c,  
                RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and GroupName__c = 'Group 3'  order by name asc];
        }else if(userDetails.Profile.Name=='Information Center Executive Community User' && userDetails.UserRole.Name == 'Edukyu Partner Executive' ) {
            lstCenter =[select id, Name, nm_Active__c,  
                RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and GroupName__c = 'Group 4'  order by name asc];
        }else if(userDetails.UserRole.Name=='West LC And South') {
            lstCenter =[select id, Name, nm_Active__c,  
                RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and recordtype__c ='Learning Center' and (name ='Mumbai' or name='Pune' or name='Indore'or name='Ahmedabad' Or name ='Bangalore' or name='Hyderabad') order by name asc];
        }else if(userDetails.UserRole.Name=='South LC') {
            lstCenter =[select id, Name, nm_Active__c,  
                RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and recordtype__c ='Learning Center' and (name ='Bangalore' or name='Hyderabad') order by name asc];
        }else if(userDetails.UserRole.Name=='North LC') {
            lstCenter =[select id, Name, nm_Active__c,  
                RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
                from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and recordtype__c ='Learning Center' and (name ='Delhi' or name='Lucknow' or name ='Kolkata' or name='Chandigarh') order by name asc];
      
        }
        else{
              if(userid=='00590000002cMwh')
                    {
                  lstCenter =[select id, Name, nm_Active__c,  
    RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
    from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and OwnerId in('00590000002cMwh','0052j0000013124') order by name asc];
                     }
                     else{
     lstCenter =[select id, Name, nm_Active__c,  
    RecordType.Name,nm_LearningCenter__r.Contact_No_1__c 
    from nm_Centers__c where nm_Active__c =true and RegistrationClosed__c=false and OwnerId =: userid order by name asc];
                         }

        }
        
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