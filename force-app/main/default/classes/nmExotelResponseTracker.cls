@isTest
private class nmExotelResponseTracker
{
    
    private static testmethod  void unitTest1()
    {
        Task T = new Task();
        T.Type = 'Email';
        T.Description = '';
        T.Exotel_Sid__c ='test';        
        insert T;
        apexPages.currentPage().getParameters().put('CallSid','test');        
        apexPages.currentPage().getParameters().put('RecordingUrl','test');
        apexPages.currentPage().getParameters().put('status','test');
        nmExotelResponse obj = new nmExotelResponse();
        obj.UpdateStatusCallback();
    
    }
  }