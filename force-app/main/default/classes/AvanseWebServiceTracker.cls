/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : @vickysahu
**/
@isTest(SeeAllData = false)
public class AvanseWebServiceTracker {
    
    //Create Lead
    public class RestMock implements HttpCalloutMock{
        RestMock(){
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"status":true,"information":{"code":"201","message":"Created successfully"},"data":{"application_no":"AVTESTP8642","application_status":"In-Progress","link":"https://avanseuat.kelltontech.net/create-user?ct=eyJjdCI6IktpQ3BOaGwzWjlYTjlaTWJLU1QrRkRwRldOa3ZQTVh2VHB1K1ZBR0NTQ3gxSGROUWxNTFpQbXNPYzEwUVwvNXVMYXhyTVdEZWlcL21PcnJSMnFudFViVVdpOWRGTHJFWlorXC83N250RUlselJEcFFzVEhzcHM4Y3g3eERKaGFucjFUdjlSWjN2T1wvTWkwVlVNQmxGR0tqdE94V1A5RlY2N1VvT0EyN1wvK1MrSlZ3bzNRUlFyRDZJODhBTzFRR0F0djMwVXdDdzJORjE0aUs5YjNiXC91N3RqQWJ3TXNJRzJRelpxMmgzYWxHRlwvNTdmU2NqY1VcLzRkc1JMNFRwK2UwN3NBM0NiTkF1N3FTYXZEaFJ3T1lJMWJNUVdPbERiVjZEWmdRK05qZkhyb1wvdm56OUJvK1ppSTNOYWFQcEZycDlNcStrTlZ1MG9JdEdIRGE0M1dpREk2TVV4Wkh3bkg0bHJUODc2bm50bk5KNGFpd1EyMHRsRTA4WnZOd040VUFJenp6cSIsIml2IjoiNDQ4OTI4YWYxNjk2YWNlNDEwZjQyMjFmZjI5YjdlYzciLCJzIjoiZTFjYmRlMmQzY2U2NGY4OSJ9","applicant_data":{"loan_amount":50000,"discount":100000,"down_payment_value":0}}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(201);
            return res;
        }
    }

    //Cancel Lead
    public class RestMockII implements HttpCalloutMock{   
        RestMockII(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"status":true,"information":{"code":"204","message":"Resource updated successfully"},"data":[]}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }

    public class RestMockIV implements HttpCalloutMock{   
        RestMockIV(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"status":true,"information":{"code":"201","message":"Created successfully"},"data":{"dsa_code":"dsa1234"}}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }

    //List Of Course Code
    // public class RestMockIII implements HttpCalloutMock{   
    //     RestMockIII(){ 
    //     }   
    //     public HttpResponse respond(HttpRequest req)    
    //     {   
    //         String fullJson = '{"status":true,"information":{"code":"200","message":"Data fetch successfully"},"data":[{"course_code":"AVCC1056","course_name":"Course name","course_fees":98001,"description":"test MBA course mapped with test","course_duration":12,"partner_name":"dhirajY"}]}';    
    //         HttpResponse resp = new HttpResponse(); 
    //         resp.setHeader('Content-Type','application/json'); 
    //         resp.setBody(fullJson);    
    //         resp.setStatusCode(200);    
    //         return resp;    
    //     }   
    // }

    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Registered');
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }
    
    @isTest
    static void createNewLoanApplication() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        String id = objLead.Id;
        Test.startTest();
            RestMock rest = new RestMock();
            Test.setMock(HttpCalloutMock.class,rest );
            AvanseWebService objAvanseWebService = new AvanseWebService();
            objAvanseWebService.createNewLead('2882992919','test123@gmail.com','Test','9659944848',50000.00,'9',id,'Lead','1234','9876','5674');
        Test.stopTest();
    }

    @isTest
    static void cancelAvanseLoan() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];
        String id = objLead.Id;
        Test.startTest();
            RestMockII rest1 = new RestMockII();
            Test.setMock(HttpCalloutMock.class,rest1 );
            AvanseWebService objAvanseWebService = new AvanseWebService();
            objAvanseWebService.cancelAvanseLoan('53356636','Lead',id);
        Test.stopTest();
    }

    @isTest
    static void updateAvanseLoan() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];        
        String id = objLead.Id;
        Test.startTest();
            RestMockII rest2 = new RestMockII();
            Test.setMock(HttpCalloutMock.class,rest2 );
            AvanseWebService objAvanseWebService = new AvanseWebService();
            objAvanseWebService.updateAvanseLoanStatus('AVTESTP8687','Lead',id);
        Test.stopTest();
    }

    @isTest
    static void createDSATest() {
        Lead objLead = [SELECT Id FROM Lead LIMIT 1];        
        String id = objLead.Id;
        Test.startTest();
            RestMockIV rest4 = new RestMockIV();
            Test.setMock(HttpCalloutMock.class,rest4 );
            AvanseWebService objAvanseWebService = new AvanseWebService();
            objAvanseWebService.createAEPCode('test123@gmail.com','9284511528','test');
        Test.stopTest();
    }


    // @isTest
    // static void getListOfCourseCode() {
    //     Lead objLead = [SELECT Id FROM Lead LIMIT 1];        
    //     String id = objLead.Id;
    //     Test.startTest();
    //         RestMockIII rest3 = new RestMockIII();
    //         Test.setMock(HttpCalloutMock.class,rest3 );
    //         AvanseWebService objAvanseWebService = new AvanseWebService();
    //         objAvanseWebService.getListOfProgramCode('5443456','Lead',id);
    //     Test.stopTest();
    // }


}