@IsTest
public class FindabilityWebServiceTracker {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": 200,"regNo": "1213","message": "SUCCESS","accuracyWithMessage": "Face matched with accuracy 95.42%"}');
            response.setStatusCode(200);
            return response; 
        }

    }
    private class RestMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"message": "Invalid API key.","status": 400}');
            response.setStatus('Bad request');
            response.setStatusCode(400);
            return response; 
        }

    }
    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_StudentImageUrl__c = 'www.google.com';
        objAccount.Student_Image_Url2__c = 'www.google.com';
        update objAccount;
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Photo ID proof');
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Aadhaar Card');
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Additional Image Document');
        nmGenericTracker.CreateDocumentforAccount(objAccount,'Additional PhotoID');
    }

    @IsTest
    static void methodName3(){
        Test.startTest();
        Account objAccount = [Select Id From Account LIMIT 1];
        RestMock rest = new RestMock();
        Test.setMock(HttpCalloutMock.class, rest);
        FindabilityWebService.URLMatchvs2(objAccount.Id, 'Photo ID proof');
        FindabilityWebService.URLMatchvs2(objAccount.Id, 'Student Image 2');
        Test.stopTest();
    }

    @IsTest
    static void methodName4(){
        Test.startTest();
        Account objAccount = [Select Id From Account LIMIT 1];
        RestMock rest = new RestMock();
        Test.setMock(HttpCalloutMock.class, rest);
       // FindabilityWebService.ImageVsPhotoID(objAccount.Id);
       FindabilityWebService.ImageVsPhotoID(objAccount.Id, 'Additional PhotoID');
        Test.stopTest();
    }
  
  
  
  
  
  
  
  
  
  // @IsTest
    // static void methodName(){
        
    //     Test.startTest();
    //     Account objAccount = [Select Id From Account LIMIT 1];
    //     RestMock rest = new RestMock();
    //     Test.setMock(HttpCalloutMock.class, rest);
    //     FindabilityWebService.FSPhotoIDMatchAPI(objAccount.Id);
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void methodName1(){
        
    //     Test.startTest();
    //     Account objAccount = [Select Id From Account LIMIT 1];
    //     RestMock1 rest = new RestMock1();
    //     Test.setMock(HttpCalloutMock.class, rest);
    //     FindabilityWebService.FSPhotoIDMatchAPI(objAccount.Id);
    //     Test.stopTest();
        
    // }
    // @IsTest
    // static void methodName2(){
        
    //     Test.startTest();
    //     Account objAccount = [Select Id From Account LIMIT 1];
    //     RestMock1 rest = new RestMock1();
    //     Test.setMock(HttpCalloutMock.class, rest);
    //     FindabilityWebService.FSPhotoIDMatchAPIForSingle(objAccount.Id);
    //     Test.stopTest();
        
    // }
    
   
}