/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 08-29-2020
 * @last modified by  : shubhranshu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-25-2020   shubhranshu   Initial Version
**/
@isTest(SeeAllData = false)
public without sharing class EzCredWebServiceTracker {
    public class RestMock implements HttpCalloutMock{
        public Integer statusCode;
        RestMock(){
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"lead_number":"1934","loan_link":"https://web.uat.ezcred.in:443/#/?leadId\u003d1934\u0026mobile\u003d9992000135\u0026entity\u003dcustomer","lead_link":"https://web.uat.ezcred.in:443/#/?leadId\u003d1934\u0026mobile\u003d9992000135\u0026entity\u003dcustomer","return_status":{"status":"SUCCESS"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    public class RestMockII implements HttpCalloutMock{   
        RestMockII(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"loanAccountNumber":"20200824000269336","success":true,"comment":""}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }   

    public class RestMockIII implements HttpCalloutMock{   
        RestMockIII(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"loans_details":[{"customer_account_number":"000013525","customer_information":{"personal_information":{"first_name":"Asfsafsa","last_name":"Fasfasf","date_of_birth":"06-01-1995","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"9967780904"}]},"loan_account_number":"20200824000269317","partner_reference_id":"07160603","status":"SUBMITTED","loan_detail":{"principal":"54000.00","number_of_repayments":6,"emi_amount":"9000.00","downpayment":"27000.00"},"merchant_information":{"merchant_id":"EZNMIMS100"},"return_status":{"status":"SUCCESS"},"lead_number":"1930"}],"return_status":{"status":"SUCCESS"}}';    
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
            String fullJson = '{"return_status":{"status":"SUCCESS"}}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }  

    public class RestMockFail implements HttpCalloutMock{
        public Integer statusCode;
        RestMockFail(){
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"lead_number":"1934","loan_link":"https://web.uat.ezcred.in:443/#/?leadId\u003d1934\u0026mobile\u003d9992000135\u0026entity\u003dcustomer","lead_link":"https://web.uat.ezcred.in:443/#/?leadId\u003d1934\u0026mobile\u003d9992000135\u0026entity\u003dcustomer","return_status":{"status":"SUCCESS"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(500);
            return res;
        }
    }

    public class RestMockFailII implements HttpCalloutMock{   
        RestMockFailII(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"loanAccountNumber":"20200824000269336","success":true,"comment":""}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(500);    
            return resp;    
        }   
    }   

    public class RestMockFailIII implements HttpCalloutMock{   
        RestMockFailIII(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"loans_details":[{"customer_account_number":"000013525","customer_information":{"personal_information":{"first_name":"Asfsafsa","last_name":"Fasfasf","date_of_birth":"06-01-1995","gender":"MALE"},"phones":[{"type":"MOBILE","country_calling_code":"91","number":"9967780904"}]},"loan_account_number":"20200824000269317","partner_reference_id":"07160603","status":"SUBMITTED","loan_detail":{"principal":"54000.00","number_of_repayments":6,"emi_amount":"9000.00","downpayment":"27000.00"},"merchant_information":{"merchant_id":"EZNMIMS100"},"return_status":{"status":"SUCCESS"},"lead_number":"1930"}],"return_status":{"status":"SUCCESS"}}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(500);    
            return resp;    
        }   
    }  

    public class RestMockFailIV implements HttpCalloutMock{   
        RestMockFailIV(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"return_status":{"status":"FAILURE","errors":[{"error_code":120,"message":"Error Message"}]}}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/json'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }  
    
    @isTest
    static void createLeadTest() {
        Test.startTest();
            RestMock rest = new RestMock();
            Test.setMock(HttpCalloutMock.class,rest );
            EzcredWebService.createLead('test','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void cancelLoanTest() {
        Test.startTest();
            RestMockII rest = new RestMockII();
            Test.setMock(HttpCalloutMock.class,rest);
            EzcredWebService.cancelLoan('123','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void getLoanDetailsTest() {
        Test.startTest();
            RestMockIII rest = new RestMockIII();
            Test.setMock(HttpCalloutMock.class,rest);
            EzcredWebService.getLoanDetails('1924','123','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void disburseApproveTest() {
        Test.startTest();
            RestMockIV rest = new RestMockIV();
            Test.setMock(HttpCalloutMock.class,rest);
            EzcredWebService.approvedLoan('123','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void createLeadFailTest() {
        Test.startTest();
            RestMockFail rest = new RestMockFail();
            Test.setMock(HttpCalloutMock.class,rest );
            EzcredWebService.createLead('test','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void cancelLoanFailTest() {
        Test.startTest();
            RestMockFailII rest = new RestMockFailII();
            Test.setMock(HttpCalloutMock.class,rest);
            EzcredWebService.cancelLoan('123','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void getLoanDetailsFailTest() {
        Test.startTest();
            RestMockFailIII rest = new RestMockFailIII();
            Test.setMock(HttpCalloutMock.class,rest);
            EzcredWebService.getLoanDetails('1924','123','006O0000008HHGV','Lead');
        Test.stopTest();
    }

    @isTest
    static void disburseApproveFailTest() {
        Test.startTest();
            RestMockFailIV rest = new RestMockFailIV();
            Test.setMock(HttpCalloutMock.class,rest);
            EzcredWebService.approvedLoan('123','006O0000008HHGV','Lead');
        Test.stopTest();
    }
}