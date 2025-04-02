/**
 * @File Name          : PaymentCheckBatchPaytmTransFailed_Test.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 11/2/2020, 6:49:23 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    11/2/2020   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class PaymentCheckBatchPaytmTransFailed_Test{

    @TestSetup
    public static void makeData(){ 
        nm_Payment_Initiated__c initiatedPayment = new nm_Payment_Initiated__c();
        initiatedPayment.nm_Merchant_Track_Id__c = '2015101253010087';
        initiatedPayment.nm_PaymentGatewayName__c = 'Paytm GateWay';
        initiatedPayment.nm_PaymentStatus__c = 'Transaction Failed';
        insert initiatedPayment;

        nm_Payment_Initiated__c initiatedPaymentRecord = new nm_Payment_Initiated__c();
        initiatedPaymentRecord.nm_Merchant_Track_Id__c = '2015101253010086';
        initiatedPaymentRecord.nm_PaymentGatewayName__c = 'Paytm GateWay';
        initiatedPaymentRecord.nm_PaymentStatus__c = 'Payment Initiated';
        insert initiatedPaymentRecord;
    }
    
    @isTest 
    static void testUnit1() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchPaytmTransactionFailed batchClass = new PaymentCheckBatchPaytmTransactionFailed();
            batchClass.start(null);
            batchClass.execute(null, scope);
            batchClass.finish(null);
        Test.stopTest();
    }
    
    @isTest
    static void testUnit2() {
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        // Insert payment record.
        nm_Payment__c paymentRecord = new nm_Payment__c();
        paymentRecord.nm_PaymentStatus__c = 'Payment Made';
        paymentRecord.nm_Merchant_Track_Id__c = '2015101253010087';
        paymentRecord.nm_PaymentType__c = 'Additional Charge';
        insert paymentRecord;

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchPaytmTransactionFailed batchClass = new PaymentCheckBatchPaytmTransactionFailed();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }
    
    @isTest
    static void testUnit3() {
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'pending';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchPaytmTransactionFailed batchClass = new PaymentCheckBatchPaytmTransactionFailed();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }

    @isTest
    static void testUnit4() {
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'failed';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchPaytmTransactionFailed batchClass = new PaymentCheckBatchPaytmTransactionFailed();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        public String method;
        public String orderId;

        RestMock() {
            method ='';
            orderId = '2015101253010087';
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"TXN_SUCCESS","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0"}';
            if(method == 'pending') {
                fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"PENDING","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0"}';
            } else if(method == 'failed') {
                fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"TXN_FAILURE","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0"}';
            }
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    /* --------------------------------------- For PaymentCheckBatchForPaytm class ------------------------------------*/

    private class RestMockForInitiation implements HttpCalloutMock {
        
        public String method;

        RestMockForInitiation() {
            method ='';
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"2015101253010086","TXNAMOUNT":"100.12","STATUS":"TXN_SUCCESS","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0"}';
            if(method == 'pending') {
                fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"2015101253010086","TXNAMOUNT":"100.12","STATUS":"PENDING","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0"}';
            } else if(method == 'failed') {
                fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"2015101253010086","TXNAMOUNT":"100.12","STATUS":"TXN_FAILURE","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0"}';
            }
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit5() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMockForInitiation rest = new RestMockForInitiation();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForPaytm batchClass = new PaymentCheckBatchForPaytm();
            batchClass.start(null);
            batchClass.execute(null, scope);
            batchClass.finish(null);
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit6() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        // Insert payment record.
        nm_Payment__c paymentRecord = new nm_Payment__c();
        paymentRecord.nm_PaymentStatus__c = 'Payment Made';
        paymentRecord.nm_Merchant_Track_Id__c = '2015101253010086';
        paymentRecord.nm_PaymentType__c = 'Additional Charge';
        insert paymentRecord;

        Test.startTest();
            //  Establish the mock response, 
            RestMockForInitiation rest = new RestMockForInitiation();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForPaytm batchClass = new PaymentCheckBatchForPaytm();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit7() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMockForInitiation rest = new RestMockForInitiation();
            rest.method = 'pending';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForPaytm batchClass = new PaymentCheckBatchForPaytm();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit8() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
            
        Test.startTest();
            //  Establish the mock response, 
            RestMockForInitiation rest = new RestMockForInitiation();
            rest.method = 'failed';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForPaytm batchClass = new PaymentCheckBatchForPaytm();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }
    
  }