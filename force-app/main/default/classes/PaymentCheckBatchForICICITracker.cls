/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-01-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class PaymentCheckBatchForICICITracker {
    
    public class RestMock implements HttpCalloutMock {
        public String method;
        public String orderId;
        RestMock() {
            method = '';
            orderId = '07192363746201992316156969114';
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = null;
            HTTPResponse res = new HTTPResponse();
            fullJson = '{"cf_order_id":1258136582,"created_at":"2022-08-09T15:11:24+05:30","customer_details":{"customer_id":"072209885686893","customer_name":"Pragya Chirania","customer_email":"pragyachirania602@gmail.com","customer_phone":"7878138486"},"entity":"order","order_amount":6200,"order_currency":"INR","order_expiry_time":"2022-08-09T15:41:22+05:30","order_id":"'+orderId+'","order_meta":{"return_url":"https://ngasce.secure.force.com/nmICICIPayResponse?order_id={order_id}&order_token={order_token}","notify_url":null,"payment_methods":null},"order_note":null,"order_splits":[],"order_status":"PAID","order_tags":{"udf1":"Registration_00Q2j00000DOcrm_0_PostPaymentPage_false_NA","udf2":"false_No_null_false"},"order_token":"kBenN3gNcFrOuRsCIQkX","payment_link":"https://payments.cashfree.com/order/#kBenN3gNcFrOuRsCIQkX","payments":{"url":"https://api.cashfree.com/pg/orders/'+orderId+'/payments"},"refunds":{"url":"https://api.cashfree.com/pg/orders/'+orderId+'/refunds"},"settlements":{"url":"https://api.cashfree.com/pg/orders/'+orderId+'/settlements"}}';
            if(method == 'pending') {
                fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"authorized","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
            } else if(method == 'failed') {
                fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"failed","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
            }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        List<nm_Payment_Initiated__c> lstPayments = new List<nm_Payment_Initiated__c>();
        nm_Payment_Initiated__c initiatedPayment5 = new nm_Payment_Initiated__c();
        initiatedPayment5.nm_Merchant_Track_Id__c = '07192363746201992316';
        initiatedPayment5.OrderId__c = '07192363746201992316';
        initiatedPayment5.nm_PaymentGatewayName__c = 'ICICI GateWay';
        initiatedPayment5.nm_PaymentStatus__c = 'Transaction Failed';
        lstPayments.add(initiatedPayment5);

        insert lstPayments;
    }

    @isTest
    static void testUnit1() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c,nm_PaymentGatewayName__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='ICICI GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            rest.orderId = '07192363746201992316';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForICICI batchClass = new PaymentCheckBatchForICICI();
            Database.executeBatch(batchClass,100);
        Test.stopTest();
    }
}