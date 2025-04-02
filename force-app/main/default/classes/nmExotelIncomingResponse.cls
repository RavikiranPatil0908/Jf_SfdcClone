// This Class is used to update call final status on task.
// And page url associated with this class used as status call bak url for exotel API 
// --------------------------------------------------------------------------------------------- 
// Version#     Date             Author                  Description
// ---------------------------------------------------------------------------------------------
// 1.0        6-Feb-2014      Neeraj Chauhan            Initial Version
// ---------------------------------------------------------------------------------------------
public class nmExotelIncomingResponse 
{
    //Constructure
    public nmExotelIncomingResponse ()
    {    
        system.debug('call by cuatomer');
    }
    
    //Method to update call status and audio recording url on task.
    public pagereference UpdateStatusCallback()
    {
        string strCallSid = apexPages.currentPage().getParameters().get('CallSid');
        string strFrom = apexPages.currentPage().getParameters().get('From');
        string strRecordingUrl = apexPages.currentPage().getParameters().get('RecordingUrl');
        string strTo = apexPages.currentPage().getParameters().get('To');
        string strCallType = apexPages.currentPage().getParameters().get('CallType');
        
        List<Task> lstCallCallSummary = [select id from Task where Exotel_Sid__c =: strCallSid];
        if(lstCallCallSummary != null && lstCallCallSummary.size() > 0)
        {
            Task callSummary = new Task(id=lstCallCallSummary[0].id);
            if(strTo != null)
                callSummary.To_Number__c = strTo;
            if(strRecordingUrl != null)
                callSummary.Audio_Recording_Url__c = strRecordingUrl;
            if(strCallType != null)
            {            
                callSummary.Exotel_Call_Status__c = strCallType;  
                //if(strCallType != 'call-attempt')
                    //callSummary.Is_Call_Received__c = true;
            }
            
            update callSummary;
        }
        else
        {
            if(strFrom != null && strFrom != '')
            {               
                Task callSummary = new Task();
            
                List<Contact> lstContact = [select id, Name from contact where MobilePhone =: strFrom];
                if(lstContact != null && lstContact.size() > 0)
                    callSummary.WhoId = lstContact[0].id;                   
                else
                {
                    List<Lead> lstLead = [select id from lead where MobilePhone =: strFrom];
                    if(lstLead != null && lstLead.size() > 0)
                        callSummary.WhoId = lstLead[0].id;
                    else
                    {
                        if(!test.isrunningtest()){
                        //Creating new lead if incoming phone number does not match any lead or contact.
                        Lead objLead = new Lead(lastname='New Lead');
                        objLead.firstName = 'New Lead';
                        objLead.MobilePhone = strFrom;
                        objLead.Company = 'New Lead';
                        objLead.Email = 'new@test.com';
                        
                        insert objLead;
                        
                        callSummary.WhoId = objLead.id;
                        }
                    } 
                }
                
                callSummary.ActivityDate = Date.today();
                callSummary.Subject='Call';
                callSummary.OwnerId = UserInfo.getUserId();
                callSummary.Status='Completed';
                callSummary.Exotel_Call_Status__c = 'call-attempt';
                callSummary.call_type__c = 'Incoming';
                //Exotel responces
                callSummary.Exotel_Sid__c = strCallSid;
                callSummary.From_No__c = strFrom;
                
                insert callSummary;
            }
        }
        
        system.debug('Call Sid:'+strCallSid+' ; strFrom :'+strFrom+' ; strCallType :'+strCallType +' ; strRecordingUrl:'+strRecordingUrl );
        
        return null;
    }
}