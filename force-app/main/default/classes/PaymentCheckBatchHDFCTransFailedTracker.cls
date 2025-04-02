/**
 * @File Name          : PaymentCheckBatchHDFCTransFailedTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 11/2/2020, 6:49:49 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    23/9/2019   @BK     Initial Version
**/
@isTest
public class PaymentCheckBatchHDFCTransFailedTracker{

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
            String fullJson = '{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"'+orderId+'":{"mihpayid":"403993715519893164","request_id":"","bank_ref_num":"201926617890566","amt":"1200.00","transaction_amount":"1200.00","txnid":"07192363746201992316156969114","additional_charges":"0.00","productinfo":"Registration","firstname":"Bala Krishna","bankcode":"CC","udf1":"Registration_00QO0000009pAsJMAU_0_PostPaymentPage_false_NA_","udf3":null,"udf4":null,"udf5":null,"field2":"000000","field9":null,"error_code":"E000","addedon":"2019-09-23 16:15:06","payment_source":"payu","card_type":"VISA","error_Message":"NO ERROR","net_amount_debit":1200,"disc":"0.00","mode":"CC","PG_TYPE":"HDFCPG","card_no":"401200XXXXXX1112","name_on_card":"Bala","udf2":null,"status":"success","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}';
            if(method == 'pending') {
                fullJson = '{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"'+orderId+'":{"mihpayid":"403993715519893164","request_id":"","bank_ref_num":"201926617890566","amt":"1200.00","transaction_amount":"1200.00","txnid":"07192363746201992316156969114","additional_charges":"0.00","productinfo":"Registration","firstname":"Bala Krishna","bankcode":"CC","udf1":"Registration_00QO0000009pAsJMAU_0_PostPaymentPage_false_NA_","udf3":null,"udf4":null,"udf5":null,"field2":"000000","field9":null,"error_code":"E000","addedon":"2019-09-23 16:15:06","payment_source":"payu","card_type":"VISA","error_Message":"NO ERROR","net_amount_debit":1200,"disc":"0.00","mode":"CC","PG_TYPE":"HDFCPG","card_no":"401200XXXXXX1112","name_on_card":"Bala","udf2":null,"status":"pending","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}';
            } else if(method == 'failed') {
                fullJson = '{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"'+orderId+'":{"mihpayid":"403993715519893164","request_id":"","bank_ref_num":"201926617890566","amt":"1200.00","transaction_amount":"1200.00","txnid":"07192363746201992316156969114","additional_charges":"0.00","productinfo":"Registration","firstname":"Bala Krishna","bankcode":"CC","udf1":"Registration_00QO0000009pAsJMAU_0_PostPaymentPage_false_NA_","udf3":null,"udf4":null,"udf5":null,"field2":"000000","field9":null,"error_code":"E001","addedon":"2019-09-23 16:15:06","payment_source":"payu","card_type":"VISA","error_Message":"Failed","net_amount_debit":1200,"disc":"0.00","mode":"CC","PG_TYPE":"HDFCPG","card_no":"401200XXXXXX1112","name_on_card":"Bala","udf2":null,"status":"Error","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}';
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
        initiatedPayment.nm_PaymentGatewayName__c = 'HDFC GateWay';
        initiatedPayment.nm_PaymentStatus__c = 'Transaction Failed';
        insert initiatedPayment;

        nm_Payment_Initiated__c initiatedPaymentRecord = new nm_Payment_Initiated__c();
        initiatedPaymentRecord.nm_Merchant_Track_Id__c = '2015101253010086';
        initiatedPaymentRecord.nm_PaymentGatewayName__c = 'HDFC GateWay';
        initiatedPaymentRecord.nm_PaymentStatus__c = 'Payment Initiated';
        insert initiatedPaymentRecord;
    }

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit1() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);

            PaymentCheckBatchHDFCTransactionFailed batchClass = new PaymentCheckBatchHDFCTransactionFailed();
            batchClass.start(null);
            batchClass.execute(null, scope);
            batchClass.finish(null);

        Test.stopTest();
    }

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit2() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        // Insert payment record.
        nm_Payment__c paymentRecord = new nm_Payment__c();
        paymentRecord.nm_PaymentStatus__c = 'Payment Made';
        paymentRecord.nm_Merchant_Track_Id__c = '07192363746201992316156969114';
        paymentRecord.nm_PaymentType__c = 'Initial Payment';
        insert paymentRecord;

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchHDFCTransactionFailed batchClass = new PaymentCheckBatchHDFCTransactionFailed();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
   @isTest
    static void testUnit3() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
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

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit4() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
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

    /* --------------------------------------- For PaymentCheckBatchForHDFC class ------------------------------------*/
    
    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit5() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForHDFC batchClass = new PaymentCheckBatchForHDFC();
            batchClass.start(null);
            batchClass.execute(null, scope);
            batchClass.finish(null);
        Test.stopTest();
    }

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit6() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        // Insert payment record.
        nm_Payment__c paymentRecord = new nm_Payment__c();
        paymentRecord.nm_PaymentStatus__c = 'Payment Made';
        paymentRecord.nm_Merchant_Track_Id__c = '2015101253010086';
        paymentRecord.nm_PaymentType__c = 'Initial Payment';

        insert paymentRecord;

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'success';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForHDFC batchClass = new PaymentCheckBatchForHDFC();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/    
    @isTest
    static void testUnit7() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'pending';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForHDFC batchClass = new PaymentCheckBatchForHDFC();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit8() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.method = 'failed';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatchForHDFC batchClass = new PaymentCheckBatchForHDFC();
            batchClass.execute(null, scope);
        Test.stopTest();
    }
    
}