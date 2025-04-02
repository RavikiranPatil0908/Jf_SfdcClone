@isTest(SeeAllData=true)
public class CreateCallRecordingRestServiceTracker
{
    static testMethod void UnitTest()
    {   
         System.RestContext.request = new RestRequest();
         RestResponse res = new RestResponse();
         RestRequest req = new RestRequest();
         System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/callrecordingrestservice';
        RestContext.request.addHeader('httpMethod','POST');
        CreateCallRecordingRestService.CallRecordingWrapper obj=new CreateCallRecordingRestService.CallRecordingWrapper('www.ggole.com');
        List<CreateCallRecordingRestService.CallRecordingWrapper> Controllerlist =new List<CreateCallRecordingRestService.CallRecordingWrapper>();
         Controllerlist.add(obj);
        String results = CreateCallRecordingRestService.connectToEnquiry('Vikas','sac23@gm2323ail.com','9971529909091699','Mumbai','Mumbai','Diploma Programs','Jforce','Executive','1-2 Year',Controllerlist);
    
    }
    
    static testMethod void UnitTest1()
    {
         System.RestContext.request = new RestRequest();
         RestResponse res = new RestResponse();
         RestRequest req = new RestRequest();
         System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'https://services/apexrest/callrecordingrestservice';
        RestContext.request.addHeader('httpMethod','POST');
        CreateCallRecordingRestService.CallRecordingWrapper obj=new CreateCallRecordingRestService.CallRecordingWrapper('www.ggole.com');
        List<CreateCallRecordingRestService.CallRecordingWrapper> Controllerlist =new List<CreateCallRecordingRestService.CallRecordingWrapper>();
         Controllerlist.add(obj);
        String results = CreateCallRecordingRestService.connectToEnquiry('Vikas','sac@gmail.com','9971521699','Mumbai','Mumbai','Diploma Programs','Jforce','Executive','1-2 Year',Controllerlist);
    
    }
}