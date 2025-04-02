@IsTest
public class NMIMSSeminarRestServiceTracker{
    
    public static testmethod void UnitTestNMIMSSeminarRest(){

String jsonString  ='{\"SeminarID\":\"a1aO0000002KhE0\",\"Campaign\":\"4april19\",\"Medium\":\"email\",\"City\":\"Mumbai\",\"Source\":\"regmailer\",\"Name\":\"Test Reg\",\"Email\":\"test@thdgfb@gmail.com\",\"MobilePhone\":\"6789876567\",\"Company\":\"infotech\",\"Designation\":\"Assitant\"}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(jsonString );
        RestContext.request= req;
        NMIMSSeminarRestService.doPost();
        Test.stopTest();
    }
    
    public static testmethod void UnitTestNMIMSSeminarRest2(){

String jsonString  ='{\"SeminarID\":\"a1aO0000002KhE0\",\"Campaign\":\"4april19\",\"Medium\":\"email\",\"City\":\"Mumbai\",\"Source\":\"regmailer\",\"Name\":\"Test Reg\",\"Email\":\"test@thdgfb@gmail.com\",\"MobilePhone\":\"6789876567\",\"Company\":\"infotech\",\"Designation\":\"Assitant\"}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(jsonString );
        RestContext.request= req;
        NMIMSSeminarRestService.doPost();
        Test.stopTest();
    }
    public static testmethod void UnitTestNMIMSSeminarRest3(){

String jsonString  ='{\"SeminarID\":\"a1aO0000002KhE0\",\"Campaign\":\"pardot\",\"Medium\":\"Email\",\"City\":\"Mumbai\",\"Source\":\"Web\",\"Name\":\"First Name\",\"Email\":\"\",\"MobilePhone\":\"9817862453\",\"Company\":\"infotech\",\"Designation\":\"Vice pr\"}';

        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof(jsonString );
        RestContext.request= req;
        NMIMSSeminarRestService.doPost();
        Test.stopTest();
    }
}