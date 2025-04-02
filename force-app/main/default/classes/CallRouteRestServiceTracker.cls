@isTest(SeeAllData=true)
Public class CallRouteRestServiceTracker
{
    static testMethod void Unittest()
    {
        System.RestContext.request = new RestRequest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request.params.put('callerNumber','97166016011');
        req.requestURI = 'https://services/apexrest/callrouterestservice/';  
        req.httpMethod = 'GET';
       // RestContext.request.addHeader('httpMethod','GET');
        Test.StartTest();
        String result =CallRouteRestService.doGet();
        Test.StopTest();

    } 
    
    
    static testMethod void Unittest1()
    {
        System.RestContext.request = new RestRequest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request.params.put('callerNumber','9716601601');
        req.requestURI = 'https://services/apexrest/callrouterestservice/';  
        req.httpMethod = 'GET';
       // RestContext.request.addHeader('httpMethod','GET');
        Test.StartTest();
        String result =CallRouteRestService.doGet();
        Test.StopTest();

    }
    
    
    static testMethod void Unittest2()
    {
        System.RestContext.request = new RestRequest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request.params.put('callerNumber','8652603545');
        req.requestURI = 'https://services/apexrest/callrouterestservice/';  
        req.httpMethod = 'GET';
       // RestContext.request.addHeader('httpMethod','GET');
        Test.StartTest();
        String result =CallRouteRestService.doGet();
        Test.StopTest();

    }  
}