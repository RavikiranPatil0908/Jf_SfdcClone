/**
 * @File Name          : ZestWebServiceTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 01-31-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    26/8/2019, 4:41:37 PM   @BK     Initial Version
**/
@IsTest(SeeAllData = true)
public class ZestWebServiceTracker{
    
    public class RestMock implements HttpCalloutMock{
        public Integer statusCode;
        RestMock(){
            statusCode = 200;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"LogonUrl" :"https://staging-app.zestmoney.in/?LoanApplicationId=e9229f74-dbe5-4884-88d9-61ec1f8a9f5f&merchantid=93863917-d9c6-4e71-8bd4-1b0b3a41caec&basketamount=76000&returnurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&approvedurl=http:%2f%2fsandbox-ngasce.cs5.force.com%2fZestMoneyThankYou&downpaymentamount=6200","access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlB1dnJEaTloWU1ucVlUSzQxb3gyYlNDbjlKbyIsImtpZCI6IlB1dnJEaTloWU1ucVlUSzQxb3gyYlNDbjlKbyJ9.eyJpc3MiOiJodHRwczovL2FwcC56ZXN0bW9uZXkuaW4iLCJhdWQiOiJodHRwczovL2FwcC56ZXN0bW9uZXkuaW4vcmVzb3VyY2VzIiwiZXhwIjoxNjQyNTc5NTE4LCJuYmYiOjE2NDI1NzU5MTgsImNsaWVudF9pZCI6IjkzNWM1NzZlLTIzM2YtNGI5My04N2E2LTU1N2Q2ZmZhYzVjNSIsImNsaWVudF9NZXJjaGFudElkIjoiOTM1YzU3NmUtMjMzZi00YjkzLTg3YTYtNTU3ZDZmZmFjNWM1Iiwic2NvcGUiOiJtZXJjaGFudF9hcGlfc2Vuc2l0aXZlIn0.iUALKB8urvpkb21T64T-vHbWKkmkq2NrqsLdfXJmkkp-uHLkaCONvqFAvPWd4j3caAWtJ94JjJtmH-XTPkh8O42G2h1fjG1D1ekscOXqIHqXSnBhng5GOpSivTXP4_Z8YUqR_29KX6XdrW83q9MK-OGMAQQucclQcX1wz7Y8m5BJCFKDIbBNEPv0gehr3IB5T35Qxo24qr6HHiLvvhuZo2MqrHP7uDEzvs66U2MW_Et5jR0w7JBW9nAP9hlxWMkgdBohFaw-ZY8XV4ce3lSUl-zYjen_R4UN6cMYrR7LErE3dzdNbN7x7HTYXR_LzGE9wtcjFBlWlcz_HhogDgO2SA","expires_in":3600,"token_type":"Bearer"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    public static testmethod void createNewLoanApplicationUnitTest(){
        Test.startTest();
        RestMock rest = new RestMock();
        rest.statusCode = 201;
        Test.setMock(HttpCalloutMock.class,rest );
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.createNewLoanApplication('41500','006O0000008HHGV','400043','Sachinmohite927@gmail.com','SachinMohite','Mumbai','Mankhurd1','Mankhurd2','8652603545','https://ngasce.force.com/PostPaymentPage',false,6200,'006O0000008HHGV','Test Product','1',41500,'AnnualFee',false);
        test.stopTest();
    }
    
    public static testmethod void getLoanApplicationStatusByOrderIdUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.getLoanApplicationStatusByOrderId('77217917034',false);
        Test.stopTest();
    }
    
    public static testmethod void CancelledLoanApplicationByOrderIdUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.CancelledLoanApplicationByOrderId('011636019','Test',false);
        Test.stopTest();
    }
    
    public static testmethod void getUpdatedOrderStatusUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.getUpdatedOrderStatus('011636019','dfae5fb8-04e1-440a-9f8e-dc896e1344a5',false);
        Test.stopTest();
    }
    
    public static testmethod void RefundsZestLoanUnitTest(){
        Test.startTest();
        RestMock rest = new RestMock();
        rest.statusCode = 201;
        Test.setMock(HttpCalloutMock.class,rest );
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.RefundsZestLoan('77217917034','77217917034','BuyerRemorse',false,null,'2018-03-01',false);
        Test.stopTest();
    }
    
    public static testmethod void getOrderDeliveryReportByOrderIdUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.getOrderDeliveryReportByOrderId('011636019','Delivered',false,null,'Opportunity');
        Test.stopTest();
    }
    
    public static testmethod void getEMIAmountBasedUponLoanAndDownPaymentUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.getEMIAmountBasedUponLoanAndDownPayment(76000,6200,false);
        Test.stopTest();
    }
    
    public static testmethod void updateOldOderIdByNewOrderIdUnitTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        ZestWebService objZestWebService = new ZestWebService();
        objZestWebService.updateOldOderIdByNewOrderId('011636019','011636018',false);
        Test.stopTest();
    }
}