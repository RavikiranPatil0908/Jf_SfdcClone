@IsTest
public class LeadAdditioanlInfoRestServiceTracker{
    
    public static testmethod void UnitTest(){
        String jsonString = '{\"LeadId\":\"00QO0000009fDV5\",\"Industry\":\"Infotech\",\"totalWorkExp\":\"0-1\",\"designation\":\"Assistant\",\"higestQualification\":\"B.E\",\"gender\":\"Male\",\"city\":\"Mumbai\",\"fraud\":\"frausyes\",\"riskcourse\":\"0\",\"company\":\"Jforce\",\"income\":\"56773\"}';
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(jsonString );
        RestContext.request= req;
        LeadAdditioanlInfoRestService.doPost();
        Test.stopTest();
    }
    
    public static testmethod void UnitTest1(){
        String jsonString = '{\"LeadId\" : \"\",\"Industry\":\"IT\",\"workExp\" : \"10\" ,\"designation\" : \"Developer\" ,\"city\" : \"Mumbai\" ,\"higestQualification\" : \"12th\" ,\"gender\" : \"Male\"}';
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(jsonString );
        RestContext.request= req;
        LeadAdditioanlInfoRestService.doPost();
        Test.stopTest();
    }
}