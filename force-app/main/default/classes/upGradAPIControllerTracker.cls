/**
 * @File Name          : upGradAPIControllerTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 3/10/2019, 4:51:31 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/10/2019   @BK     Initial Version
**/
@isTest(SeeAllData=false)
private class upGradAPIControllerTracker {

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

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        nmGenericTracker.InsertSerialNo();
        createRestResource();
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Registration Done');
        nm_Centers__c objCen = createCenterForUpgrad('Mumbai',true);
        objAccount.nm_Centers__c = objCen.id;
        update objAccount;
        
    }

    /**
    * @description 
    * @author @BK | 3/10/2019 
    * @return void 
    **/
    public static void createRestResource() {
        RestResource_API_Access__c objRRA = new RestResource_API_Access__c();
        objRRA.Name = 'UpGrad';
        objRRA.Password__c = 'Newuser@123';
        objRRA.Email__c = ' upgrads@login.in';
        objRRA.source__c = 'UpGrad';
        objRRA.isActive__c = true;
        objRRA.API_EncryptionKey__c = 'HzMa/Qz788pifMbAybR76PQY2PsVXV+gHMqfYErEa9M=';
        insert objRRA;
    }

    /**
    * @description 
    * @author @BK | 3/10/2019 
    * @param centerName 
    * @param AllowDegree 
    * @return nm_Centers__c 
    **/
    public static nm_Centers__c createCenterForUpgrad(String centerName,boolean AllowDegree) {
        Recordtype RT=[SELECT id FROM Recordtype WHERE sobjectType='nm_Centers__c' AND name ='Information Center'];
        nm_Centers__c objCen= new nm_Centers__c();
        
        objCen.Nm_Active__c = false;
        objCen.Name='upGrad';
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = 'upGrad';
        objCen.nm_CenterCity__c = centerName;
        objCen.nm_City__c = centerName;
        objCen.nm_StateProvince__c = centerName;
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objcen.Allow_Degree__c = AllowDegree;
        insert objCen;

        return objCen;
    }

    @isTest 
    static void unitTest1(){
        Test.startTest();
            String myJSON = '{"email" : "upgrads@login.in","password" : "Newuser@123","request" : "auth_token","source": "UpGrad"}';
            String uri = 'getAccessToken';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    /*
    ** For Invalid URL
    */
    @isTest 
    static void unitTest2(){
        Test.startTest();
            String myJSON = '{"email":"","password":""}';
            String uri = 'getAccessToken';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest3(){
        Test.startTest();
            String myJSON = '{"email":"","password":""}';
            String uri = 'getAccessToken2';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest4(){
        Account objAccount = [SELECT id,PersonEmail FROM Account LIMIT 1];
        Test.startTest();
            String myJSON = '{\"authToken\":\"tRN5dk2Jw29bVONwZ28jNdfABZ2orqr7BCr93EG+3san2PBfjI+7WFOHimCgiWEb2wqJJ6PmqjbCqbIVCI4GrQ==\",'+
            '    \"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"phalguni.9999@gmail.com\",'+
            '       \"total_score\":\"78\"'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest5(){
        Test.startTest();
            String myJSON = '{"email" : "upgrads@login.in","password" : "Newuser@1234","request" : "auth_token","source": "UpGrad"}';
            String uri = 'getAccessToken';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest6(){
        Test.startTest();
            String myJSON = '{\"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"phalguni.9999@gmail.com\",'+
            '       \"total_score\":\"78\"'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest7(){
       Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,PersonEmail FROM Account LIMIT 1];
        Test.startTest();
            String myJSON = '{\"authToken\":\"tRN5dk2Jw29bVONwZ28jNdfABZ2orqr7BCr93EG+3san2PBfjI+7WFOHimCgiWEb2wqJJ6PmqjbCqbIVCI4GrQ==\",'+
            '    \"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"'+objAccount.PersonEmail+'\",'+
            '       \"total_score\":\"78\",'+
            '       \"submitted_at\": \"2019-07-17 16:58:10 Asia/Kolkata\",'+
            '       \"time_taken\": \"30m\",'+
            '       \"status\": \"Passed\",'+
            '       \"number_of_retakes\": 0,'+
            '       \"report_url\": \"www.google.com\",'+
            '       \"sectional_score\": [{'+
            '           \"section_name\": \"Quantitative Aptitude\",'+
            '           \"section_score\": 30.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Verbal Reasoning\",'+
            '           \"section_score\": 119.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Logical Reasoning and Data Interpretation\",'+
            '           \"section_score\": -25.00'+
            '       }]'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest8(){
        Test.startTest();
            String myJSON = '{\"authToken\":\"tRN5dk2Jw29bVONwZ28jNdfABZ2oPBfjI+7WFOHimCgiWEb2wqJJ6PmqjbCqbIVCI4GrQ==\",'+
            '    \"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"phalguni.9999@gmail.com\",'+
            '       \"total_score\":\"78\"'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest9(){
        Account objAccount = [SELECT id,PersonEmail FROM Account LIMIT 1];
        Test.startTest();
            String myJSON = '{\"authToken\":\"tRN5dk2Jw29bVONwZ28jNdfABZ2orqr7BCr93EG+3san2PBfjI+7WFOHimCgiWEb2wqJJ6PmqjbCqbIVCI4GrQ==\",'+
            '    \"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"'+objAccount.PersonEmail+'\",'+
            '       \"total_score\":\"78\",'+
            '       \"submitted_at\": \"2019-07-17 16:58:10 Asia/Kolkata\",'+
            '       \"time_taken\": \"30m\",'+
            '       \"status\": \"Passed\",'+
            '       \"number_of_retakes\": 0,'+
            '       \"report_url\": \"www.google.com\",'+
            '       \"sectional_score\": [{'+
            '           \"section_name\": \"Quantitative Aptitude\",'+
            '           \"section_score\": 30.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Verbal Reasoning\",'+
            '           \"section_score\": 119.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Logical Reasoning & Data Interpretation\",'+
            '           \"section_score\": -25.00'+
            '       }]'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest10(){
       Test.setMock(HttpCalloutMock.class, new RestMock());
        Account objAccount = [SELECT id,PersonEmail,nm_StudentStatus__c FROM Account LIMIT 1];
        Test.startTest();
            // objAccount.nm_StudentStatus__c = 'Confirmed';
            update objAccount;
            String myJSON = '{\"authToken\":\"tRN5dk2Jw29bVONwZ28jNdfABZ2orqr7BCr93EG+3san2PBfjI+7WFOHimCgiWEb2wqJJ6PmqjbCqbIVCI4GrQ==\",'+
            '    \"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"'+objAccount.PersonEmail+'\",'+
            '       \"total_score\":\"78\",'+
            '       \"submitted_at\": \"2019-07-17 16:58:10 Asia/Kolkata\",'+
            '       \"time_taken\": \"30m\",'+
            '       \"status\": \"Passed\",'+
            '       \"number_of_retakes\": 0,'+
            '       \"report_url\": \"www.google.com\",'+
            '       \"sectional_score\": [{'+
            '           \"section_name\": \"Quantitative Aptitude\",'+
            '           \"section_score\": 30.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Verbal Reasoning\",'+
            '           \"section_score\": 119.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Logical Reasoning and Data Interpretation\",'+
            '           \"section_score\": -25.00'+
            '       }]'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }

    @isTest 
    static void unitTest11(){
        Test.startTest();
            String myJSON = '{\"authToken\":\"tRN5dk2Jw29bVONwZ28jNdfABZ2orqr7BCr93EG+3san2PBfjI+7WFOHimCgiWEb2wqJJ6PmqjbCqbIVCI4GrQ==\",'+
            '    \"source\":\"UpGrad\",'+
            '   \"request\" : {'+
            '       \"email\":\"phalguni.9999@gmail.com\",'+
            '       \"total_score\":\"78\",'+
            '       \"submitted_at\": \"2019-07-17 16:58:10 Asia/Kolkata\",'+
            '       \"time_taken\": \"30m\",'+
            '       \"status\": \"Passed\",'+
            '       \"number_of_retakes\": 0,'+
            '       \"report_url\": \"www.google.com\",'+
            '       \"sectional_score\": [{'+
            '           \"section_name\": \"Quantitative Aptitude\",'+
            '           \"section_score\": 30.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Verbal Reasoning\",'+
            '           \"section_score\": 119.50'+
            '       },'+
            '       {'+
            '           \"section_name\": \"Logical Reasoning & Data Interpretation\",'+
            '           \"section_score\": -25.00'+
            '       }]'+
            '   }'+
            '}';
            String uri = 'updateScore';
            RequestData(myJSON,uri);
            UpGradAgencyAPI.show();
        Test.stopTest();
    }


    public static void RequestData(String myJson,String uri) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requesturi = 'https://services/apexrest/RestResource/v1/'+uri;
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        RestContext.response = response;
    }
}