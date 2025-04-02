@RestResource(urlMapping='/createleadservice/*')
global without sharing class CreateLeadService
{    
    global class WapperId
         {
             public String LeadId {get;set;}
             public String result {get;set;}
             public String message {get;set;}
             public WapperId(String Id,String message,String result)
             {
                 this.LeadId=Id;
                 this.message=message ;
                 this.result =result;
             }
         }
     global class JSONCreater
     {
         public String CreateJson(WapperId obj)
         {
             JSONGenerator gen = JSON.createGenerator(true);
             gen.writeStartObject();
             if(obj.result =='Success' || obj.result =='Duplicate')
             {
                 gen.writeStringField('LeadId',obj.LeadId);
                 gen.writeStringField('result',obj.message);
             }
             else
             {
                 gen.writeStringField('result',obj.message);
                 gen.writeStringField('Error Message',obj.result);
             }    
             gen.writeEndObject();
             String formatstring = gen.getAsString();
             formatstring = formatstring .replaceAll('\n', '');
            return formatstring.replace('\"','');  
         }
     } 
     
      
    @HttpPost
    global static string connectToEnquiry(String Name,String EmailID,String ContactNo,String Agency,String HighestQualification,decimal AdmissionYear,String CurrentLocation,String CourseIntrestedIn )
     {
        String leadSource='Web';
        String Category='Distance Learning / Correspondence';
        string statusOfLead='Not Contacted';  
        string planToStart='0-1 Week';
        System.debug('CourseIntrested in--->'+CurrentLocation);
         RestRequest req = RestContext.request;
         String ipAddress = req.remoteAddress;
         
        list<Lead>lstLead=[Select id,Email,MobilePhone from Lead where (Email=:EmailID or MobilePhone=:ContactNo)and IsConverted=false ];
        IF(lstLead.size()>0)
        {
          WapperId obj =new WapperId(lstLead[0].id,'Duplicate','Duplicate');
          JSONCreater jsonMaker =new JSONCreater();
          return jsonMaker.CreateJson(obj);
        }
        else
        {
            Map<String,String> mapOfErrorMessages =ValidateNameandMaobile(Name,ContactNo);
            Lead objLead = new Lead(LastName=Name,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=CourseIntrestedIn,nm_PlantoStart__c=planToStart,nm_Year__c=AdmissionYear,nm_SelectedIC__c=CurrentLocation,Highest_Qualification__c=HighestQualification,Agency__c=Agency,nm_Lead_Category__c=Category,nm_IPForLead__c=ipAddress);
              try
              {
                    WapperId obj;
                    if(!mapOfErrorMessages.isEmpty())
                    {
                       obj =new WapperId(objLead.id,'Error',mapOfErrorMessages.get('Error'));
                    }
                    else
                    {
                        insert objLead;
                        obj =new WapperId(objLead.id,'Success','Success');
                    }    
                    JSONCreater jsonMaker =new JSONCreater();
                    return jsonMaker.CreateJson(obj);
               }
                catch(Exception e)
                {  
                     WapperId obj =new WapperId(objLead.id,'Error',String.valueOf(e));
                     JSONCreater jsonMaker =new JSONCreater();
                     return jsonMaker.CreateJson(obj);
                }    
         } 
    }
    
   public static map<string,string> ValidateNameandMaobile(string Name,string ContactNo)
    {
        map<string,string> mapOfError = new map<string,string>();
       if(!ContactNo.StartsWith('9') && !ContactNo.StartsWith('7') && !ContactNo.StartsWith('8'))
       {
           mapOfError.put('Error','Please Make Sure number should be start with 9 or 8 or 7 digits.');
       }
       else if(ContactNo.length() != 10 && ContactNo.length() != 12 )
       {
           mapOfError.put('Error','Mobile Number Should be 10 OR 12 digits.');
       }
       else
       {
            Pattern phonePattern = Pattern.compile('^[0-9]*$');  
            Matcher phoneMatcher = phonePattern.matcher(ContactNo);  
            if(!phoneMatcher.find())
            {
               mapOfError.put('Error','Mobile Number Should Not Contains Special Character.');
            }
       }
       
       if(Name != '')
       {
            String SPECIAL_CHAR_PATTERN = '[/[^a-zA-Z ]/,]';
            Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
            Matcher pm = p.matcher(Name);
            while (pm.find())
             {
                 mapOfError.put('Error','Please Enter Valid Name.Name should not be contain special character and Number');
             }
       }
       return mapOfError;
    }
}