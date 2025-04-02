global class leadSquaredConfigWebservice{

   //webservice String accessKey=System.Label.LeadSquaredAccessKey;
  
//    webService static string createLead(String FirstName, String LastName, String EmailAddress ,String Phone, String City, String ProspectID){
   
//    HttpRequest req=new HttpRequest();
//    HttpResponse res=new HttpResponse();
   
//    Http http=new Http();
   
//    req.setEndpoint('https://api-in21.leadsquared.com/v2/LeadManagement.svc/Lead.Create?accessKey='+System.Label.LeadSquaredAccessKey+'&secretKey='+System.Label.LeadSquaredSecretKey);
//    req.setMethod('POST');
//    req.setHeader('Content-Type', 'application/json');
   
//    JSONHelper j=new JSONHelper();
//    j.addLeadAttribute('FirstName',FirstName);
//    j.addLeadAttribute('LastName',LastName);
//    j.addLeadAttribute('EmailAddress',EmailAddress);
//    j.addLeadAttribute('Phone',Phone);
//    j.addLeadAttribute('mx_City',City);
//    j.addLeadAttribute('ProspectID',ProspectID);
   
//    String postString = JSON.serialize(j);
//    Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(postString);
//    String cObjJson = JSON.serialize(mapOfResponseParameters.get('lstAttr'));
   
//    System.debug('cObjJson-->'+cObjJson);
//    req.setBody(cObjJson);
//    System.debug(req);
   
//    String status='';
//    String result='';
//    try{
   
//        if(!System.Test.isRunningTest()){
       
//          res=http.send(req);
//          result =res.getBody();
         
//        }else{
          
//           result='{"Status":"success"}';
//        }
   
//    }catch(System.CalloutException e){
   
//      System.debug('Callout error: '+e);
//      System.debug(res.toString());
//    }
    
//     return result;
//   }
  webService static string createListofLead(String jsonResults)
    {
        String result;
       
    List<Lead> lstLead = (List<Lead>)JSON.deserialize(jsonResults, List<Lead>.class);
    
        for(Lead objLead :lstLead)
        {
           result = postparameter(objLead,'Create',null); 
           system.debug('objLead Id-->'+objLead.id);
        }
          
            return result;
        
    }
webService static string updateLeadInLeadsquare(String LeadId)
    {
        String result;
        String ProspectId;
        String leadQueryString = getQueryAllFieldSql('Lead',' id=:LeadId',null);
        List<Lead> lstLead = DataBase.query(leadQueryString);
        system.debug('lstLead--->'+lstLead.size());
        system.debug('lstLead[0].FirstName--->'+lstLead[0].FirstName);
        if(lstLead.size() > 0 )
        {
            Lead objLead = lstLead[0];
            system.debug('objLead.FirstName--->'+objLead.FirstName);
            if(objLead.LeadSource=='Partner')
            {
                 if(objLead.LeadSquared_Id__c!='' && objLead.LeadSquared_Id__c!=null)
                    {
                       result = postparameter( lstLead[0],'Update',objLead.LeadSquared_Id__c); 
                    }else{
                        ProspectId = GetLeadId(objlead,objLead.Email);
                      //  update objLead;
                      if(ProspectId!=null && ProspectId!='')
                      {
                        result = postparameter( lstLead[0],'Update',ProspectId);
                      }
                  }
            }
           
        }
        return result;
    }    
    public static string postparameter(Lead objlead,String Action,String LeadID)
    {
        HttpRequest req=new HttpRequest();
        HttpResponse res=new HttpResponse();
        Http http=new Http();
        
       if(Action=='Create')
       {
       System.debug('action to create');
           req.setEndpoint('https://api-in21.leadsquared.com/v2/LeadManagement.svc/Lead.Create?accessKey='+System.Label.LeadSquaredAccessKey+'&secretKey='+System.Label.LeadSquaredSecretKey);
       }
       else if(Action=='Update')
       {
       System.debug('action to update');
           req.setEndpoint('https://api-in21.leadsquared.com/v2/LeadManagement.svc/Lead.Update?accessKey='+System.Label.LeadSquaredAccessKey+'&secretKey='+System.Label.LeadSquaredSecretKey+'&leadId='+LeadID);   
       }
   
   req.setMethod('POST');
   req.setHeader('Content-Type', 'application/json');
   
   JSONHelper j=new JSONHelper();
   j.addLeadAttribute('FirstName',objlead.FirstName);
   j.addLeadAttribute('mx_Registration_Number',objlead.nm_RegistrationNo__c);
   j.addLeadAttribute('EmailAddress',objlead.Email);
   j.addLeadAttribute('mx_Lead_Description',objlead.Lead_Description__c);
   j.addLeadAttribute('mx_Shipping_City',objlead.City);
   j.addLeadAttribute('mx_Lead_Status',objlead.Status);
   j.addLeadAttribute('Phone',objlead.MobilePhone);
   
   String postString = JSON.serialize(j);
   Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(postString);
   String cObjJson = JSON.serialize(mapOfResponseParameters.get('lstAttr'));
   
   System.debug('cObjJson-->'+cObjJson);
   req.setBody(cObjJson);
   System.debug(req);
   
   String status='';
   String result='';
   try{
   
       if(!System.Test.isRunningTest()){
       
         res=http.send(req);
         result =res.getBody();
         if(result !=null && result !='' && Action=='Update')
         {
             //UpdateleadsquaredId(result ,objlead); 
             objLead.LeadSquared_Id__c = LeadID;
              update objLead;
         } else if(result !=null && result !='' && Action=='Create')
         {
            UpdateleadsquaredId(result ,objlead);
         }
        
         system.debug('result--->'+result );
         
       }else{
          
          result='{"Status":"success"}';
       }
   
   }catch(System.CalloutException e){
   
     System.debug('Callout error: '+e);
     System.debug(res.toString());
   }
   return result;
   
    }
     public static String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
public static void UpdateleadsquaredId(String result,Lead objLead)
    {
        Map<String,Object> mapOfResponseParameters = (Map<String,Object>)Json.deserializeuntyped(result);
        System.debug('mapOfResponseParameters--->'+mapOfResponseParameters);

        if(!mapOfResponseParameters.isEmpty()){
               String currentStatus = String.valueOf(mapOfResponseParameters.get('Status'));
                 system.debug('currentStatus--->'+currentStatus);
           
            if(currentStatus =='Success')
            {
                Map<String, Object> mapID = (Map<String, Object>) mapOfResponseParameters.get('Message');
                String leadsquareId  = String.valueOf(mapID.get('Id'));
                system.debug('leadsquareId--->'+mapID.get('Id') );   
                if (leadsquareId!='' && leadsquareId!=null)
                {
                    objLead.LeadSquared_Id__c = leadsquareId;
                    update objlead;
                }
            }
       
        }
    }
    webService static string GetLeadId(Lead objlead,String EmailAddress){
   String LeadId;  
   HttpRequest req=new HttpRequest();
   HttpResponse res=new HttpResponse();
   
   Http http=new Http();
   
   req.setEndpoint('https://api-in21.leadsquared.com/v2/LeadManagement.svc/Leads.GetByEmailaddress?accessKey='+System.Label.LeadSquaredAccessKey+'&secretKey='+System.Label.LeadSquaredSecretKey+'&emailaddress='+EmailAddress);
   req.setMethod('GET');
   req.setHeader('Content-Type', 'application/json');
      
   
   String status='';
   String result='';
   try{
   
       if(!System.Test.isRunningTest()){
       
            res=http.send(req);
            result =res.getBody();
            system.debug('result--->'+result);
            if(result!='[]'){
                List<Object> results = (List<Object>) JSON.deserializeUntyped(result);
                for (Object itemObj : results) {
                    Map<String, Object> mapOfResponseParameters = (Map<String, Object>) itemObj;
                    system.debug('item-->'+mapOfResponseParameters);
                
                
                LeadId = String.valueOf(mapOfResponseParameters.get('ProspectID'));
                    system.debug('LeadId--->'+LeadId);
                }
            }else
            {
                result = postparameter(objlead,'Create',null);
            }
             
       }
   
   }catch(System.CalloutException e){
   
     System.debug('Callout error: '+e);
     System.debug(res.toString());
   }
    
    return LeadId;
  }
}