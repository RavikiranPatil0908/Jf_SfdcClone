public class nmIncomingCallDetail 
{
    public String callSummary { get; set; }
    public string strTaskId{get;set;}
    public string strCallerId{get;set;}
    
    public nmIncomingCallDetail()
    {
        callSummary = '';
        
        strTaskId = apexpages.currentpage().getparameters().get('id');
        strCallerId = apexpages.currentpage().getparameters().get('lcid');
    }

    public PageReference SaveDetails() 
    {        
        if(strTaskId != null && strTaskId != '')
        {
            Task objTask = new Task(id=strTaskId);            
            objTask.description = callSummary;
            
            update objTask;
            
            string strIsFollowUp = ApexPages.currentPage().getParameters().get('isFollowUp');
            
            if(strIsFollowUp != null && strIsFollowUp == 'True')
            {
                return new pagereference('/'+objTask.Id+'/e?followup=1&retURL=%2F'+objTask.Id);
            }
            else
                return new Pagereference('/'+strCallerId);
        }
        return null;
    }
    
    //Method to return on detail page
    public pagereference BackToLead()
    {
        return new pagereference('/'+strCallerId);
    }
}