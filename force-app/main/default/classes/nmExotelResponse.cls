// This Class is used to update call final status on task.
// And page url associated with this class used as status call bak url for exotel API 
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        6-Feb-2014      Neeraj Chauhan            Initial Version
// ---------------------------------------------------------------------------------------------
public class nmExotelResponse
{
    //Constructure
    public nmExotelResponse()
    {    
    }
    
    //Method to update call status and audio recording url on task.
    public void UpdateStatusCallback()
    {
        string strCallSid = apexPages.currentPage().getParameters().get('CallSid');
        string strStatus = apexPages.currentPage().getParameters().get('Status');
        string strRecordingUrl = apexPages.currentPage().getParameters().get('RecordingUrl');
        
        if(strCallSid != null && strCallSid != '')
        {
            List<Task> lstTask = [select id, status, Audio_Recording_Url__c from Task where Exotel_Sid__c =: strCallSid];
            
            if(lstTask != null && lstTask.size() > 0)
            {
                lstTask[0].Exotel_Call_Status__c = strStatus;
                lstTask[0].Audio_Recording_Url__c = strRecordingUrl;
                
                update lstTask;
            }
        }
        
        system.debug('Call Sid:'+strCallSid+' ; Status:'+strStatus);
    }
}