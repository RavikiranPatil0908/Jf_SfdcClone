@isTest
private class nmIncomingCallDetailTracker
{
    
    private static testmethod  void unitTest1()
    {
        Task T = new Task();
        T.Type = 'Email';
        T.Description = '';
        T.Exotel_Sid__c ='test';        
        insert T;
        apexPages.currentPage().getParameters().put('id',t.id);
        apexPages.currentPage().getParameters().put('isFollowUp','true');
       
        nmIncomingCallDetail obj = new nmIncomingCallDetail();
        obj.SaveDetails();
        obj.BackToLead();
        apexPages.currentPage().getParameters().put('isFollowUp','false');
        nmIncomingCallDetail obj1= new nmIncomingCallDetail();
        obj1.SaveDetails();
        apexPages.currentPage().getParameters().put('id',null);
        nmIncomingCallDetail obj2= new nmIncomingCallDetail();
        obj2.SaveDetails();
    
    }
    
 
 }