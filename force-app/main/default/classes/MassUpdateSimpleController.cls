public  class MassUpdateSimpleController {
    
   private final ApexPages.StandardSetController cntr;
   private final PageReference fromPage {get;set;}
   Public final List<Lead> lstOfSelectedLeadRecords {get;set;}
   private transient ApexPages.Message currentMsg {get;set;}
   private String currentStep{get;set;}
   public List<NMAT_Lead__c> lstOfSelectedNMATRecords {get;set;}
   public String fieldName {get;set;}
   public NMAT_Lead__c objNMATLead {get;set;}
   public String valueToUpdate {get;set;}
   public integer sizeOfRecordsToUpdate {get;set;}
   public String Roles {get;set;}
   public list<nm_UserMapping__c> lstUserMapping {get;set;}
   
   public String getStep() {
    return currentStep;
  }
   public MassUpdateSimpleController(ApexPages.StandardSetController controller) {
       lstOfSelectedNMATRecords =new List<NMAT_Lead__c>(); 
       lstOfSelectedLeadRecords  = new List<Lead>(); 
       lstUserMapping  =new List<nm_UserMapping__c>();
       currentStep = '1';
       fieldName ='';
       Roles ='';
       objNMATLead =new NMAT_Lead__c();
       controller.setPageSize(1000);
       cntr = (ApexPages.StandardSetController)controller;
        lstUserMapping=[select id,nm_Centers__c,nm_User__r.UserRole.Name,nm_User__r.Profile.Name from nm_UserMapping__c where nm_User__c=:UserInfo.getUserId()];
        if(lstUserMapping.size()>0)
        {
            if(lstUserMapping.size()>0  && lstUserMapping[0].nm_User__r.UserRole.Name !=null)
            {
                Roles = lstUserMapping[0].nm_User__r.UserRole.Name; // checking role for hiding update Information Center option for IC User 
            }
            else
            {
                Roles = 'System Administrator';
            }
        } 
        else
            {
                Roles = 'System Administrator';
            }   
        
       // checking records for Mass Update eg.NMAT or Lead
        List<SObject> lstSObject =cntr.getSelected(); 
        sizeOfRecordsToUpdate =lstSObject.size();
        String RecordId ='';
        for(SObject s : lstSObject)
        {
            RecordId=s.id;
            break;
        }
        System.debug('Id Of Selected Record--->'+RecordId);
        List<NMAT_Lead__c> lstOfRecords =[select id from NMAT_Lead__c where id=:RecordId];
        List<Lead> lstOfLeadRecords =[select id from Lead where id=:RecordId];
        if(lstOfRecords.size()>0)
        {
            lstOfSelectedNMATRecords =cntr.getSelected();
        }
        else if(lstOfLeadRecords.size()>0)
        {
            lstOfSelectedLeadRecords = cntr.getSelected();
        }
       fromPage = cntr.cancel();

       if (sizeOfRecordsToUpdate<1) {
            String msg = 'No record was selected on the list view.  Please click Previous button and select records for mass update.'; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
       } else {
            String msg = 'Number of records selected for update: ' + sizeOfRecordsToUpdate; 
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
       }
       ApexPages.addMessage(currentMsg);
   }
   
   public PageReference cancel() {
        return fromPage;
    }

    public PageReference step1() { 
      currentStep='1';          
        return ApexPages.currentPage();
    }
    
    public PageReference step2() {
     if(sizeOfRecordsToUpdate<1) return fromPage;      
      currentStep='2';          
       return ApexPages.currentPage();
    }
    
    public PageReference step3() {
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Field type of selected field:'+fieldName);
        ApexPages.addMessage(currentMsg);
        
        currentStep='3';          
        return ApexPages.currentPage();
    } 
    
    public PageReference step4() {
        // data type validation
            if (currentMsg!=null) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, '');
                ApexPages.addMessage(msg);
                ApexPages.addMessage(currentMsg);
                return ApexPages.currentPage();
            }
            
            String msg = 'Please review your selections before confirm: <br></br>'; 
            msg = msg + '<br><b>Records Selected:</b>    ' + sizeOfRecordsToUpdate +'</br>';
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
            ApexPages.addMessage(currentMsg);
            currentStep='4';  
            return ApexPages.currentPage();        
    }
    
    public PageReference step5() {
        if(lstOfSelectedNMATRecords.size()>0)
        {
           currentMsg = UpdateNMATRecords(valueToUpdate,objNMATLead,lstOfSelectedNMATRecords);
        }
        else
        {
            currentMsg = UpdateLeadRecords(valueToUpdate,objNMATLead,lstOfSelectedLeadRecords);
        }
        ApexPages.addMessage(currentMsg);
        currentStep='5';          
        return ApexPages.currentPage();
    }
    
    public ApexPages.Message UpdateNMATRecords(String CenterId,NMAT_Lead__c objNMATLead,List<NMAT_Lead__c> lstOfSelectedNMATRecords)
    {
    List<NMAT_Lead__c> lstToUpdate =new List<NMAT_Lead__c>();
    for(NMAT_Lead__c objNMAT :lstOfSelectedNMATRecords)
    {
       if(CenterId !=null && CenterId!= '')
       {
         objNMAT.Information_Center__c =CenterId;
       } 
       if(objNMATLead.LeadSource__c !=null && objNMATLead.LeadSource__c !='')
       {
           objNMAT.LeadSource__c =objNMATLead.LeadSource__c;
       } 
       objNMAT.Convert_Lead__c =objNMATLead.Convert_Lead__c;
       lstToUpdate.add(objNMAT);
    }
        
    if(lstToUpdate.size()>0)
    {
        try{
           update lstToUpdate;
           currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Updated ' + lstToUpdate.size() + ' Records');
           }
           catch(System.DmlException e)
           {
           currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0) + '  No record updated');
           }
       }
        return currentMsg;
    }
    
    
    public ApexPages.Message UpdateLeadRecords(String CenterId,NMAT_Lead__c objNMATLead,List<Lead> lstOfSelectedLeadRecords)
    {
    List<Lead> lstToUpdate =new List<Lead>();
    for(Lead objNMAT :lstOfSelectedLeadRecords)
    {
       if(CenterId !=null && CenterId!= '')
       {
         objNMAT.nm_InformationCenter__c =CenterId;
       } 
       if(objNMATLead.LeadSource__c !=null && objNMATLead.LeadSource__c !='')
       {
           objNMAT.LeadSource =objNMATLead.LeadSource__c;
       } 
       
       lstToUpdate.add(objNMAT);
    }
        
    if(lstToUpdate.size()>0)
    {
        try{
           update lstToUpdate;
           currentMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Updated ' + lstToUpdate.size() + ' Records');
           }
           catch(System.DmlException e)
           {
           currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getDmlMessage(0) + '  No record updated');
           }
       }
        return currentMsg;
    }
    
     public List<SelectOption> getFieldTypeOptions() {
        if (lstOfSelectedNMATRecords.size()<1) return null;
         List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('','-None-'));
        String SobjectApiName = 'NMAT_Lead__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
            String commaSepratedFields = '';
            System.debug('Key Set-->'+fieldMap.keyset());
            for(String fieldName : fieldMap.keyset())
            {
               String label = fieldMap.get(fieldName).getDescribe().getLabel();
               String key =fieldName;
               if(Roles =='System Administrator' || Roles.startsWith('Learning'))
               {
                    if(label.startsWith('Information Center')|| label.startsWith('Convert') || label.startsWith('Lead Source'))
                    {
                        options.add(new SelectOption(key, label));
                    }
               }
               else
               {
                   if(label.startsWith('Convert') || label.startsWith('Lead Source'))
                    {
                        options.add(new SelectOption(key, label));
                    }
               }
            }
        return options;
     }
     
     
     public List<SelectOption> getFieldTypeOptionsForLead() {
        if (lstOfSelectedNMATRecords.size()<1) return null;
         List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('','-None-'));
        String SobjectApiName = 'Lead';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
 
            String commaSepratedFields = '';
            System.debug('Key Set-->'+fieldMap.keyset());
            for(String fieldName : fieldMap.keyset())
            {
               String label = fieldMap.get(fieldName).getDescribe().getLabel();
               String key =fieldName;
               if(Roles =='System Administrator' || Roles.startsWith('Learning'))
               {
                    if(label.startsWith('Information Center')|| label.startsWith('Lead Source'))
                    {
                        options.add(new SelectOption(key, label));
                    }
               }
               else
               {
                   if(label.startsWith('Lead Source'))
                    {
                        options.add(new SelectOption(key, label));
                    }
               }
            }
        return options;
    }
    
   public List<SelectOption> getInfoCenterRelatedToLC() 
   {
      List<nm_Centers__c>  lstLcRelatedInformationCenter =new List<nm_Centers__c>();
    if(lstUserMapping.size()>0)
    { 
         if(lstUserMapping.size()>0  && lstUserMapping[0].nm_User__r.UserRole.Name !=null)
         {
            if(lstUserMapping[0].nm_User__r.UserRole.Name.startsWith('Learning'))
            {
               lstLcRelatedInformationCenter=[select name,id from nm_Centers__c where  nm_LearningCenter__c=:lstUserMapping[0].nm_Centers__c ];
            }
         }
         else if(lstUserMapping[0].nm_User__r.Profile.Name.startsWith('System Administrator'))
         {
             lstLcRelatedInformationCenter=[select name,id from nm_Centers__c];
         }
     }
     else
     {
         lstLcRelatedInformationCenter=[select name,id from nm_Centers__c];
     }    
     List<SelectOption> options = new List<SelectOption>();      
     options.add(new SelectOption('','-None-'));
     for(nm_Centers__c objCenter :lstLcRelatedInformationCenter) 
     {
         options.add(new SelectOption(objCenter.id,objCenter.Name));
     }
     return options;    
   }
   
 }