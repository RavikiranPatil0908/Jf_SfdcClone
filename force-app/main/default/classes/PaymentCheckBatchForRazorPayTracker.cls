/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-30-2022
 * @last modified by  : @BK
**/
@isTest
public class PaymentCheckBatchForRazorPayTracker {

    public class RestMock implements HttpCalloutMock {
        public String method;
        public String orderId;
        RestMock() {
            method ='';
            orderId = '07192363746201992316156969114';
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"captured","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
            if(method == 'pending') {
                fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"authorized","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
            } else if(method == 'failed') {
                fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"failed","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
            }
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        nm_Payment_Initiated__c initiatedPayment = new nm_Payment_Initiated__c();
        initiatedPayment.nm_Merchant_Track_Id__c = '07192363746201992316156969114';
        initiatedPayment.OrderId__c = '07192363746201992316156969114';
        initiatedPayment.nm_PaymentGatewayName__c = 'Razorpay GateWay';
        initiatedPayment.nm_PaymentStatus__c = 'Transaction Failed';
        insert initiatedPayment;

        nm_Payment_Initiated__c initiatedPaymentRecord = new nm_Payment_Initiated__c();
        initiatedPaymentRecord.nm_Merchant_Track_Id__c = '2015101253010086';
        initiatedPayment.OrderId__c = '2015101253010086';
        initiatedPaymentRecord.nm_PaymentGatewayName__c = 'Razorpay GateWay';
        initiatedPaymentRecord.nm_PaymentStatus__c = 'Payment Initiated';
        insert initiatedPaymentRecord;
    }

    @isTest
    static void testUnit1() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c  FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Razorpay GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);

            PaymentCheckBatchForRazorPay batchClass = new PaymentCheckBatchForRazorPay();
            batchClass.start(null);
            batchClass.execute(null, scope);
            batchClass.finish(null);

        Test.stopTest();
    }

   @isTest
    static void testUnit2() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Razorpay GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'pending';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchHDFCTransactionFailed batchClass = new PaymentCheckBatchHDFCTransactionFailed();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    @isTest
    static void testUnit3() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Razorpay GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'failed';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchHDFCTransactionFailed batchClass = new PaymentCheckBatchHDFCTransactionFailed();
            batchClass.execute(null, scope);
        Test.stopTest();
    }
}