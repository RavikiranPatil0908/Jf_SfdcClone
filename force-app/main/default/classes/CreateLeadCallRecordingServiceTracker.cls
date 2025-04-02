@isTest(SeeAllData=False)
Public class CreateLeadCallRecordingServiceTracker
    {
        public static Lead objLead;
        
       static testMethod void UnitTest()
        {
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/createleadcallreocrdingservice';
            RestContext.request.addHeader('httpMethod','POST');
            CreateLeadCallRecordingRestService.CallRecordingWrapper obj = new CreateLeadCallRecordingRestService.CallRecordingWrapper('www.google.com');
            List<CreateLeadCallRecordingRestService.CallRecordingWrapper> lst = new List<CreateLeadCallRecordingRestService.CallRecordingWrapper>();
            lst.add(obj);
            String results = CreateLeadCallRecordingRestService.connectToEnquiry('Sagar',lst);
        
        }
    }