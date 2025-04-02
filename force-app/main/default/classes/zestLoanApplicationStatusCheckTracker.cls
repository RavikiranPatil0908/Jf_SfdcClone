/**
 * @File Name          : zestLoanApplicationStatusCheckTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 01-21-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/11/2020   shubhranshu     Initial Version
**/
@IsTest(SeeAllData = false)
public class zestLoanApplicationStatusCheckTracker{
    
    
    public class RestMock implements HttpCalloutMock{
        public Integer statusCode;
        RestMock(){
            statusCode = 200;
        }
        public HttpResponse respond(HttpRequest req){
            String fullJson ='{"ApplicationId":"d419d0eb-2bf1-4a7d-8e24-1871056ef04b","OrderStatus":"Approved","DeliveryPinCode":"345123","BasketAmount":76500.00,"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkEwRWVYbXAxNl9YSnRGUW85WGZjVFNHV3BkTSIsImtpZCI6IkEwRWVYbXAxNl9YSnRGUW85WGZjVFNHV3BkTSJ9.eyJpc3MiOiJodHRwOi8vc3RhZ2luZy56ZXN0bW9uZXkuaW4iLCJhdWQiOiJodHRwOi8vc3RhZ2luZy56ZXN0bW9uZXkuaW4vcmVzb3VyY2VzIiwiZXhwIjoxNTc4OTg4MDcxLCJuYmYiOjE1Nzg5ODQ0NzEsImNsaWVudF9pZCI6IjkzODYzOTE3LWQ5YzYtNGU3MS04YmQ0LTFiMGIzYTQxY2FlYyIsImNsaWVudF9NZXJjaGFudElkIjoiOTM4NjM5MTctZDljNi00ZTcxLThiZDQtMWIwYjNhNDFjYWVjIiwic2NvcGUiOiJtZXJjaGFudF9hcGlfc2Vuc2l0aXZlIn0.SmhNqNfLLVt_amMeSQIcDPwS4GUwh__IKNw1wrqY45BCGXRD8xNqsVintPdBi9l2KSqFF0QsURtGLRNah6_2ZwP2kLD0MPt6gcSt7GrbS38-5ENXLUGWfpd_By_UIEwRHn8U2xPX3mzyz97_p7HKASqzER2R4FSNYHvJG1Ke_zCyv6fW7LOo0Rd-vNqDY2tYN9aEi48nYTwegyG0xiD3MHU8kO8oFUe44rni5e6gKOkkXcb_oyqpHxp_qGUgJrExvn-NsJbfrLyEK4bSaklzNoQCc5ZE190tZnjtbPtmUoVIp0WgbglXZt7oddw6JqwE33I0eYDoy_9JBxL88b755w","expires_in": 3600,"token_type": "Bearer"}';
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type','application/json');
            resp.setBody(fullJson );
            resp.setStatusCode(statusCode);
            return resp;
        }
    }
   
    public class RestMock1 implements HttpCalloutMock{
        public Integer statusCode;
        RestMock1(){
            statusCode = 200;
        }
        public HttpResponse respond(HttpRequest req){
            String fullJson ='{"ApplicationId":"d419d0eb-2bf1-4a7d-8e24-1871056ef04b","OrderStatus":"Cancelled","DeliveryPinCode":"345123","BasketAmount":76500.00,"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkEwRWVYbXAxNl9YSnRGUW85WGZjVFNHV3BkTSIsImtpZCI6IkEwRWVYbXAxNl9YSnRGUW85WGZjVFNHV3BkTSJ9.eyJpc3MiOiJodHRwOi8vc3RhZ2luZy56ZXN0bW9uZXkuaW4iLCJhdWQiOiJodHRwOi8vc3RhZ2luZy56ZXN0bW9uZXkuaW4vcmVzb3VyY2VzIiwiZXhwIjoxNTc4OTg4MDcxLCJuYmYiOjE1Nzg5ODQ0NzEsImNsaWVudF9pZCI6IjkzODYzOTE3LWQ5YzYtNGU3MS04YmQ0LTFiMGIzYTQxY2FlYyIsImNsaWVudF9NZXJjaGFudElkIjoiOTM4NjM5MTctZDljNi00ZTcxLThiZDQtMWIwYjNhNDFjYWVjIiwic2NvcGUiOiJtZXJjaGFudF9hcGlfc2Vuc2l0aXZlIn0.SmhNqNfLLVt_amMeSQIcDPwS4GUwh__IKNw1wrqY45BCGXRD8xNqsVintPdBi9l2KSqFF0QsURtGLRNah6_2ZwP2kLD0MPt6gcSt7GrbS38-5ENXLUGWfpd_By_UIEwRHn8U2xPX3mzyz97_p7HKASqzER2R4FSNYHvJG1Ke_zCyv6fW7LOo0Rd-vNqDY2tYN9aEi48nYTwegyG0xiD3MHU8kO8oFUe44rni5e6gKOkkXcb_oyqpHxp_qGUgJrExvn-NsJbfrLyEK4bSaklzNoQCc5ZE190tZnjtbPtmUoVIp0WgbglXZt7oddw6JqwE33I0eYDoy_9JBxL88b755w","expires_in": 3600,"token_type": "Bearer"}';
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type','application/json');
            resp.setBody(fullJson );
            resp.setStatusCode(statusCode);
            return resp;
        }
    }
    
    public class RestMock2 implements HttpCalloutMock{
        public Integer statusCode;
        RestMock2(){
            statusCode = 200;
        }
        public HttpResponse respond(HttpRequest req){
            String fullJson ='{"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkEwRWVYbXAxNl9YSnRGUW85WGZjVFNHV3BkTSIsImtpZCI6IkEwRWVYbXAxNl9YSnRGUW85WGZjVFNHV3BkTSJ9.eyJpc3MiOiJodHRwOi8vc3RhZ2luZy56ZXN0bW9uZXkuaW4iLCJhdWQiOiJodHRwOi8vc3RhZ2luZy56ZXN0bW9uZXkuaW4vcmVzb3VyY2VzIiwiZXhwIjoxNTc4OTg4MDcxLCJuYmYiOjE1Nzg5ODQ0NzEsImNsaWVudF9pZCI6IjkzODYzOTE3LWQ5YzYtNGU3MS04YmQ0LTFiMGIzYTQxY2FlYyIsImNsaWVudF9NZXJjaGFudElkIjoiOTM4NjM5MTctZDljNi00ZTcxLThiZDQtMWIwYjNhNDFjYWVjIiwic2NvcGUiOiJtZXJjaGFudF9hcGlfc2Vuc2l0aXZlIn0.SmhNqNfLLVt_amMeSQIcDPwS4GUwh__IKNw1wrqY45BCGXRD8xNqsVintPdBi9l2KSqFF0QsURtGLRNah6_2ZwP2kLD0MPt6gcSt7GrbS38-5ENXLUGWfpd_By_UIEwRHn8U2xPX3mzyz97_p7HKASqzER2R4FSNYHvJG1Ke_zCyv6fW7LOo0Rd-vNqDY2tYN9aEi48nYTwegyG0xiD3MHU8kO8oFUe44rni5e6gKOkkXcb_oyqpHxp_qGUgJrExvn-NsJbfrLyEK4bSaklzNoQCc5ZE190tZnjtbPtmUoVIp0WgbglXZt7oddw6JqwE33I0eYDoy_9JBxL88b755w","expires_in": 3600,"token_type": "Bearer"}';
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type','application/json');
            resp.setBody(fullJson );
            resp.setStatusCode(statusCode);
            return resp;
        }
    }
    
    @testSetup
    public static void setUpData(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');

        //registration Account
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        
        objopp.Loan_Type__c ='Zest';
        objopp.Loan_Sanctioned__c = false;
        objopp.Down_Payment_Made__c = true;
        objopp.Loan_Order_Id__c='8876534';
        update objopp;
        
        nmGenericTracker.CreatePaymentRecords(objopp.id,'Zest-DownPayment','Opportunity','DownPayment-Admission');
        ZestMoneyAPI__c objZest = new ZestMoneyAPI__c ();
        objZest.Authentication_API__c ='http://staging-auth.zestmoney.in/connect/token';
        objZest.client_id__c='93863917-d9c6-4e71-8bd4-1b0b3a41caec';
        objZest.client_secret__c='eetwe5Anun8fGOwyk3Cu';
        objZest.scope__c='merchant_api_sensitive';
        objZest.grant_type__c ='client_credentials';
        objZest.Name='Loan Application Data';
        objZest.Refunds_API__c='http://staging-app.zestmoney.in/Refunds/Refunds';
        
        insert objZest ;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
    }
    public static testmethod void UnitTest1(){
        
        Opportunity objOpportunity = [select id ,Refund_Loan_Payment__c,Loan_Cancellation_Reason__c,AccountId,Loan_Order_Id__c,Loan_Order_Status__c,Loan_Approved__c,Loan_Type__c ,Loan_Application_Cancelled__c,Loan_Sanctioned__c ,Down_Payment_Made__c,Interest_Rate__c  from Opportunity  limit 1];
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        ZestMoneyAPI__c  objZest = [select id,name,Authentication_API__c , client_id__c,client_secret__c,scope__c,grant_type__c  from ZestMoneyAPI__c  limit 1];
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.setMock(HttpCalloutMock.class, new RestMock());
        zestLoanApplicationStatusCheckBatch  batchClass = new zestLoanApplicationStatusCheckBatch();
        Database.executeBatch(batchClass,1);    
        batchClass.callGetLoanApplicationStatusByOrderIdAPI(objOpportunity);
        Test.stopTest();
    }

     public static testmethod void UnitTest2(){

        Opportunity objOpportunity = [select id ,Refund_Loan_Payment__c,Loan_Cancellation_Reason__c,AccountId,Loan_Order_Id__c,Loan_Order_Status__c,Loan_Approved__c,Loan_Type__c ,Loan_Application_Cancelled__c,Loan_Sanctioned__c ,Down_Payment_Made__c,Interest_Rate__c  from Opportunity  limit 1];
        objOpportunity.Loan_Approved__c = true;
        update objOpportunity;
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        ZestMoneyAPI__c  objZest = [select id,name,Authentication_API__c , client_id__c,client_secret__c,scope__c,grant_type__c  from ZestMoneyAPI__c  limit 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        zestLoanApplicationStatusCheckBatch  batchClass = new zestLoanApplicationStatusCheckBatch();
        Database.executeBatch(batchClass,1);
        batchClass.callDeliveredLoanApplicationAPI(objOpportunity);
        Test.stopTest();
    }

    public static testmethod void UnitTest3(){
        
        Opportunity objOpportunity = [select id ,Refund_Loan_Payment__c,Loan_Cancellation_Reason__c,AccountId,Loan_Order_Id__c,Loan_Order_Status__c,Loan_Approved__c,Loan_Type__c ,Loan_Application_Cancelled__c,Loan_Sanctioned__c ,Down_Payment_Made__c,Interest_Rate__c  from Opportunity  limit 1];
        objOpportunity.Loan_Application_Cancelled__c = true;
        objOpportunity.Loan_Cancellation_Reason__c = 'test';
        objOpportunity.Loan_Order_Status__c = 'test';
        update objOpportunity;

        Test.startTest();
        
        
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        ZestMoneyAPI__c  objZest = [select id,name,Authentication_API__c , client_id__c,client_secret__c,scope__c,grant_type__c  from ZestMoneyAPI__c  limit 1];
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        zestLoanApplicationStatusCheckBatch  batchClass = new zestLoanApplicationStatusCheckBatch();
        Database.executeBatch(batchClass,1);
        batchClass.callCancelledLoanApplicationAPI(objOpportunity);
        Test.stopTest();
    }

    public static testmethod void UnitTest4(){

        Opportunity objOpportunity = [select id ,Refund_Loan_Payment__c,Loan_Cancellation_Reason__c,AccountId,Loan_Order_Id__c,Loan_Order_Status__c,Loan_Approved__c,Loan_Type__c ,Loan_Application_Cancelled__c,Loan_Sanctioned__c ,Down_Payment_Made__c,Interest_Rate__c  from Opportunity  limit 1];
        objOpportunity.Refund_Loan_Payment__c = true;
        update objOpportunity;
        nm_Payment__c objpayment = [select id ,nm_Merchant_Track_Id__c,nm_PaymentStatus__c,nm_PaymentType__c  from nm_Payment__c where nm_OpportunityNew__c!=null limit 1];
        ZestMoneyAPI__c  objZest = [select id,name,Authentication_API__c , client_id__c,client_secret__c,scope__c,grant_type__c  from ZestMoneyAPI__c  limit 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock()); 
        zestLoanApplicationStatusCheckBatch  batchClass = new zestLoanApplicationStatusCheckBatch();
        Database.executeBatch(batchClass,1);
        batchClass.callRefundAPI(objOpportunity);
        Test.stopTest();
    }
}