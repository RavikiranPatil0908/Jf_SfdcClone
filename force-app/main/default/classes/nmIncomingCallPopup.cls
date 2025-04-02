// This Class is used to populate incomming call popup
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        11-Feb-2014      Neeraj Chauhan            Initial Version
// ---------------------------------------------------------------------------------------------
public class nmIncomingCallPopup 
{
    public string incomingNumber{get;set;}
    public string recordId{get;set;}
    public String callerId { get; set; }
    public string strUrl {get;set;}
    
    public nmIncomingCallPopup ()
    {
        strUrl = url.getSalesforceBaseUrl().toExternalForm();
        //ShowIncommingCall();
    }
    
    public void ShowIncommingCall()
    {
        List<Task> lstTask = [select id, whoid, From_No__c, call_type__c, Is_Call_Received__c
                                     from Task 
                                     where id =: recordId];
                                     
        if(lstTask != null && lstTask.size() > 0)
        {
            if(lstTask[0].WhoId != null && lstTask[0].call_type__c == 'Incoming' && lstTask[0].Is_Call_Received__c == false)
            {
                incomingNumber = lstTask[0].From_No__c;        
            
                string strWhoid = lstTask[0].WhoId; 
                if(strWhoid.startsWith('003'))
                {
                    List<Contact> lstContact = [select id, Name from contact where id =: strWhoid];
                    
                    if(lstContact != null && lstContact.size() > 0)
                    {
                        incomingNumber = lstContact[0].Name +' ('+ lstTask[0].From_No__c +')'; 
                        callerId = lstContact[0].id;
                    }
                }
                else
                {
                    List<lead> lstLead = [select id, Name from lead where id =: strWhoid];
                    if(lstLead != null && lstLead.size() > 0)
                    {
                        incomingNumber = lstLead[0].Name +' ('+ lstTask[0].From_No__c +')'; 
                        callerId = lstLead[0].id;
                    }
                }
            }
            else
            {
                incomingNumber = '';
            }
        }
        else
        {
            incomingNumber = '';
        }
    }
    
    public void MarkChecked()
    {
        Task objTask = new Task(id=recordId, Is_Call_Received__c = true);
        update objTask;
    }
}