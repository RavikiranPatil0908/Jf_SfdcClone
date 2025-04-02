/**
 * @File Name          : CareerServiceAPITracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 22/1/2020, 12:26:14 pm
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    11/5/2019, 7:01:53 PM   @BK     Initial Version
**/
@isTest(SeeAllData = false)
public class CareerServiceAPITracker2
{
    public static Account objAccount;
    public static Opportunity objOpp;
    public static Career_Service_Package__c CarrierPackage ;

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
     @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        nmGenericTracker.InsertSerialNo();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccount.nm_StudentNo__c = '77214000953';
        update objAccount;
        objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        
        Career_Service_Package__c CP = new Career_Service_Package__c();
        CP.Package_Name__c = 'Career Assistance';
        CP.Group_Name__c = 'Fast';
        insert CP;

        CarrierPackage = CP;
        RestResource_API_Access__c objRRAPIAccess = new RestResource_API_Access__c();
        objRRAPIAccess.isActive__c = true;
        objRRAPIAccess.API_EncryptionKey__c = 'P0KNL27jBEM0QFywZF2PJ/hIFGPUMTn2v2Q4+rHbcsk=';
        objRRAPIAccess.Password__c = 'test@123';
        objRRAPIAccess.Email__c = 'test@gmail.com';
        objRRAPIAccess.source__c = 'Career Services';
        objRRAPIAccess.Name = 'Career Services';
        insert objRRAPIAccess;
    }

    /*
    ** For Access Token Request
    ** For Success.
    */
    static testMethod void unitTest1(){
        Test.startTest();
        String myJSON = '{"email" : "test@gmail.com","password" : "test@123","request" : "auth_token","source": "Career Services"}';
        String URI = 'getAccessToken';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For Access Token Request Error Response
    ** For Invalid Request 422
    */
    static testMethod void unitTest2(){
        Test.startTest();
        String myJSON = '{"UserName" : "test@gmail.com","password" : "test@123","request" : "auth_token","source": "Career Services"}';
        String URI = 'getAccessToken';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For Access Token Request Error Response
    ** For Invalid login credentials 406
    */
    static testMethod void unitTest3(){
        Test.startTest();
        String myJSON = '{"email" : "test@gmail.com","password" : "test@1234","request" : "auth_token","source": "Career Services"}';
        String URI = 'getAccessToken';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For getPackages Request 
    ** For Success
    */
    static testMethod void unitTest4(){
        Test.startTest();
        String myJSON = '{"authToken":"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==","request":"packages"}';
        String URI = 'getPackages';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For getPackages Request Error Response
    ** For Invalid Token 405
    */
    static testMethod void unitTest5(){
        Test.startTest();
        String myJSON = '{"authToken":"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1og","request":"packages"}';
        String URI = 'getPackages';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For getPackages Request Error Response
    ** For Invalid Request 422
    */
    static testMethod void unitTest6(){
        Test.startTest();
        String myJSON = '{"authToken":"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==","request":""}';
        String URI = 'getPackages';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For submitRegistration 
    ** For Success
    */
    static testMethod void unitTest7(){
      //  loadData();
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Career_Service_Package__c CarrierPackage = [select id from Career_Service_Package__c limit 1];
        Test.startTest();
        String sapId = objAccount.nm_StudentNo__c;
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '\"sapId\":\"'+sapId+'\",'+
        '\"request\":{'+
        '    \"packageId\":\"'+CarrierPackage.id+'\",'+
        '    \"failureURL\":\"www.google.com\",'+
        '    \"successURL\":\"www.google.com\",'+
        '    \"paymentInitializationId\": \"test\"'+
        '}'+
        '}';
        
        String URI = 'submitRegistration';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For submitRegistration 
    ** For Invalid Request
    */
    static testMethod void unitTest8(){
       // loadData();
         Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
         Career_Service_Package__c CarrierPackage = [select id from Career_Service_Package__c limit 1];
        Test.startTest();
        String sapId = objAccount.nm_StudentNo__c;
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '\"sapId\":\"'+sapId+'\",'+
        '\"request\":{'+
        '    \"failureURL\":\"www.google.com\",'+
        '    \"successURL\":\"www.google.com\",'+
        '    \"paymentInitializationId\": \"test\"'+
        '}'+
        '}';
        
        String URI = 'submitRegistration';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For submitRegistration 
    ** For Invalid Request
    */
    static testMethod void unitTest9(){
       // loadData();
         Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
         Career_Service_Package__c CarrierPackage = [select id from Career_Service_Package__c limit 1];
        Test.startTest();
        String sapId = objAccount.nm_StudentNo__c;
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\"}';
        String URI = 'submitRegistration';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For submitRegistration 
    ** For Invalid Token
    */
    static testMethod void unitTest10(){
     //   loadData();
       Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
       Career_Service_Package__c CarrierPackage = [select id from Career_Service_Package__c  limit 1];
        Test.startTest();
        String sapId = objAccount.nm_StudentNo__c;
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdq\",'+
        '\"sapId\":\"'+sapId+'\",'+
        '\"request\":{'+
        '    \"packageId\":\"'+CarrierPackage.id+'\",'+
        '    \"work_Experience\":{'+
        '        \"reasonForNotWorking\":\"Fresher\"'+
        '    }'+
        '}'+
        '}';
        
        String URI = 'submitRegistration';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For submitRegistration 
    ** For Invalid Student Number
    */
    static testMethod void unitTest11(){
      //  loadData();
        Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
        Career_Service_Package__c CarrierPackage = [select id from Career_Service_Package__c limit 1];
        Test.startTest();
        String sapId = objAccount.nm_StudentNo__c;
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '\"sapId\":\"789456\",'+
        '\"request\":{'+
        '    \"packageId\":\"'+CarrierPackage.id+'\",'+
        '    \"work_Experience\":{'+
        '        \"reasonForNotWorking\":\"Fresher\"'+
        '    }'+
        '}'+
        '}';
        
        String URI = 'submitRegistration';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For submitRegistration 
    ** For upsert on package already selected
    */
    static testMethod void unitTest12(){
       // loadData();
         Account objAccount = [select id,nm_LeadId__c,nm_StudentNo__c from Account  limit 1];
         Career_Service_Package__c CarrierPackage = [select id from Career_Service_Package__c  limit 1];
        Test.startTest();
        Career_Service_Program__c CSProgram = new Career_Service_Program__c();
        CSProgram.Account__c = objAccount.id;
        CSProgram.CareerServiceProgram__c = CarrierPackage.id;
        insert CSProgram;

        String sapId = objAccount.nm_StudentNo__c;
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '\"sapId\":\"'+sapId+'\",'+
        '\"request\":{'+
        '    \"packageId\":\"'+CarrierPackage.id+'\",'+
        '    \"failureURL\":\"www.google.com\",'+
        '    \"successURL\":\"www.google.com\",'+
        '    \"paymentInitializationId\": \"test\"'+
        '}'+
        '}';
        
        String URI = 'submitRegistration';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /*
    ** For Invalid URL
    */
    static testMethod void unitTest13(){
        Test.startTest();
        String myJSON = '{"authToken":"","request":""}';
        String URI = 'getPackages12';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /**
    * @description For create Packages
    * @author @BK | 13/5/2019
    * @return testMethod
    */
    static testMethod void unitTest14(){
        Test.startTest();
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '   \"request\":{'+
        '       \"packageName\":\"Career Development and Assistant 3\",'+
        '       \"type\": \"Group 3\"'+
        '   }'+
        '}';
        String URI = 'createPackage';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    /**
    * @description For create Packages
    * @author @BK | 13/5/2019
    * @return testMethod Invalid Request
    */
    static testMethod void unitTest15(){
        Test.startTest();
        String myJSON = '{'+
        '   \"request\":{'+
        '       \"packageName\":\"Career Development and Assistant 3\",'+
        '       \"type\": \"Group 3\"'+
        '   }'+
        '}';
        String URI = 'createPackage';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

     /**
    * @description For create Packages
    * @author @BK | 13/5/2019
    * @return testMethod Invalid Token
    */
    static testMethod void unitTest16(){
        Test.startTest();
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHb67567567F0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '   \"request\":{'+
        '       \"packageName\":\"Career Development and Assistant 3\",'+
        '       \"type\": \"Group 3\"'+
        '   }'+
        '}';
        String URI = 'createPackage';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

     /**
    * @description For create Packages
    * @author @BK | 13/5/2019
    * @return testMethod Invalid Request
    */
    static testMethod void unitTest17(){
        Test.startTest();
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHbF0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '   \"request\":{'+
        '       \"packageName\":\"Career Development and Assistant 3\"'+
        '   }'+
        '}';
        String URI = 'createPackage';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

     /**
    * @description For create Packages
    * @author @BK | 13/5/2019
    * @return testMethod Invalid Token
    */
    static testMethod void unitTest18(){
        Test.startTest();
        String myJSON = '{\"authToken\":\"iDxjTSuS3D9Jz15ZsoI2r64mCx968x+2dWoZP5X4Wh7+m2H2mlHb67567567F0iTj3sJH+pYSbezkv0NuLZ1ogdqrgFOJw==\",'+
        '   \"request\":{'+
        '       \"packageName\":\"Career Assistance\",'+
        '       \"type\": \"Group 3\"'+
        '   }'+
        '}';
        String URI = 'createPackage';
        RequestData(myJSON,URI);
        CareerServiceAPI.show();
        Test.stopTest();
    }

    public static void RequestData(String myJson,String URI) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://services/apexrest/CS/v2/'+URI;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }

  /*  public static void loadData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
        objAccount.nm_StudentNo__c = '77214000953';
        update objAccount;
        objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        Career_Service_Package__c CP = new Career_Service_Package__c();
        CP.Package_Name__c = 'Career Assistance';
        insert CP;
        CarrierPackage = CP;
    }*/
}