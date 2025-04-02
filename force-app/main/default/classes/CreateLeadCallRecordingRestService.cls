@RestResource(urlMapping='/createleadcallreocrdingservice/*')
global without sharing class CreateLeadCallRecordingRestService
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
     global static string connectToEnquiry(String LeadId,List<CallRecordingWrapper> CallRecordingUrlList)
     {
        if(LeadId !=null)
        {
          for(CallRecordingWrapper objlstUrl :CallRecordingUrlList)
             {
                try
                {
                    Call_Recording__c objCallRecording =new Call_Recording__c (Lead__c=LeadId,URL__c=objlstUrl.Url);
                    insert objCallRecording;
                }
                catch(Exception e)
                {
                    return 'Incorrect Lead Id'+e;
                }    
             } 
          return 'Successfully Inserted';  
        }
        else
        {
            return 'Please Provide Unique Lead Id';
        }     
     }
}