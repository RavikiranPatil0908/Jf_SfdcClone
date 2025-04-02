public class NextFollowUp 
{    
    public Lead objLead{get;set;}
    public string strLeadID{get;set;}
    public string param{get;set;}
    public string testparam{get;set;}
    //public string param2{get;set;}
    public string strNextDatetime{get;set;}
    public String displayMessage {get;set;}
    public NextFollowUp()
    {
        objLead = new Lead();
        testparam ='';
        strLeadID = ApexPages.currentPage().getParameters().get('id');
        testparam = ApexPages.currentPage().getParameters().get('param');
        system.debug('Test ---->'+testparam);
        //param1 = ApexPages.currentPage().getParameters().get('reason');
        //param2 = ApexPages.currentPage().getParameters().get('reasonForOther');
        displayMessage = '';
        if(strLeadID !=null && strLeadID !='' && testparam =='LeadCaptureDetail'){
           String query = getQueryAllFieldSql('Lead',' id=:strLeadID');
           List<Lead> lstLead = DataBase.query(query);
           if(lstLead.size() > 0){
               objLead = lstLead[0];
               objLead.id = null;
           }
        }
        
       
    }
   public PageReference saveFllowUpdate()
    {
        system.debug('List of Lead--->-' + objLead);
        if(objLead != null)
        {
            Lead objNewLead = objLead.clone();
            objNewLead.id = strLeadID;
            Update objNewLead;
            displayMessage ='Thank you for sharing the requisite information';
        }
        return null;
    }
    public List<SelectOption> getReasonForNotJoining()
    {
        Schema.sObjectType sobject_type = Lead.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<string, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Reason_for_not_joining__c').getDescribe().getPickListValues();
        List<selectOption> options = new  List<selectOption>();
        for(Schema.PicklistEntry a: pick_list_values)
        {
            options.add(new  selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    public List<SelectOption> getStudentPlantoStart()
    {
        Schema.sObjectType sobject_type = Lead.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<string, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Student_Plan_to_Start__c').getDescribe().getPickListValues();
        List<selectOption> options = new  List<selectOption>();
        for(Schema.PicklistEntry a: pick_list_values)
        {
            options.add(new  selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    /* public void saveFllowUpdate()
    {
     if( strLeadID != null && strLeadID != '')
        {
             List<Lead> lstOfLead = [Select id,Next_Follow_up__c,Student_Define_Date_Time__c,Email from Lead where id=:strLeadID];
              if(lstOfLead.size()>0)
        {
        objLead = lstOfLead[0].clone();
         system.debug('objLead.Student_Define_Date_Time__c--->-'+objLead.Student_Define_Date_Time__c);
             update objLead; 
        }
        
        
        }
        }
    */
    
     public String getQueryAllFieldSql(String SObjectAPIName,String conditionString)
    {
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
    
}