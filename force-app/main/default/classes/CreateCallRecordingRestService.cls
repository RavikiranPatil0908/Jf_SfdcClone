@RestResource(urlMapping='/callrecordingrestservice/*')
global without sharing class CreateCallRecordingRestService
{
     global class CallRecordingWrapper
     {
         public String Url{get;set;}
         
         public CallRecordingWrapper(String Url)
         {
             this.Url=Url;
         }
     }
     
     @HttpPost
     global static string connectToEnquiry(String Name,String EmailID,String ContactNo,String City,String Centre,String Program,String Industry,String Designation,String WorkExperience,List<CallRecordingWrapper> CallRecordingUrlList)
     {
         String leadSource='Web';
         String Agency ='DGM';
         String HighestQualification ='12th';
         String Category='Distance Learning / Correspondence';
         string statusOfLead='Not Contacted';  
         string planToStart='0-1 Week';
         Call_Recording__c objCallRecording;    
         List<Lead> lstLeadToUpsert =[select id,name from Lead where (MobilePhone =:ContactNo or Email =:EmailID) and IsConverted=false];
         if(lstLeadToUpsert.size()>0)
         { 
             for(CallRecordingWrapper objlstUrl :CallRecordingUrlList)
             {
                 
                 objCallRecording =new Call_Recording__c (Lead__c=lstLeadToUpsert[0].id,URL__c=objlstUrl.Url);
                 insert objCallRecording;
            }  
             return 'Successfully '+' '+objCallRecording.id;
         }
         else
         {
             Lead objLead = new Lead(LastName=Name,Email=EmailID,Status=statusOfLead,MobilePhone=ContactNo,LeadSource=leadSource,nm_ChooseaProgram__c=Program,nm_PlantoStart__c=planToStart,nm_SelectedIC__c=Centre,Highest_Qualification__c=HighestQualification,Agency__c=Agency,nm_Lead_Category__c=Category,nm_City_P__c=City,nm_WorkExperience__c=WorkExperience,Industry=Industry,nm_Designation__c=Designation);
             try
             {
                  insert objLead; 
                  for(CallRecordingWrapper objlstUrl :CallRecordingUrlList)
                     {
                         
                         objCallRecording =new Call_Recording__c (Lead__c=objLead.id,URL__c=objlstUrl.Url);
                         insert objCallRecording;
                    }  
                 return 'Lead Inserted Successfully'+' '+objCallRecording.id;
             }
             catch(Exception e)
             {
                 return 'Unsuccessfull Lead Insert'+e;
             
             }
         }
     }
}