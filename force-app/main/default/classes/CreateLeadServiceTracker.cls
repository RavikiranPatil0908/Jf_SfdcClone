@isTest(SeeAllData=False)
Public class CreateLeadServiceTracker
    {
        public static Lead objLead;
        
       static testMethod void UnitTest()
        {
            System.RestContext.request = new RestRequest();
            RestContext.request.requestURI = 'https://services/apexrest/createleadservice';
            RestContext.request.addHeader('httpMethod','POST');
            String results = CreateLeadService.connectToEnquiry('Sagar','sagar@gmail.com','9987226106','DGM','Degree',2014.00,'Mumbai','Diploma Programs');
        
        }
    }