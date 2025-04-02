/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 08-12-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class PaymentCheckBatchTracker {

    public class RestMock implements HttpCalloutMock {
        public String method;
        public String gatewayName = null;
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
            if(gatewayName == 'HDFC GateWay') {
                fullJson = '{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"'+orderId+'":{"mihpayid":"403993715519893164","request_id":"","bank_ref_num":"201926617890566","amt":"1200.00","transaction_amount":"1200.00","txnid":"07192363746201992316156969114","additional_charges":"0.00","productinfo":"Registration","firstname":"Bala Krishna","bankcode":"CC","udf1":"Registration_00QO0000009pAsJMAU_0_PostPaymentPage_false_NA_","udf3":null,"udf4":null,"udf5":null,"field2":"000000","field9":null,"error_code":"E000","addedon":"2019-09-23 16:15:06","payment_source":"payu","card_type":"VISA","error_Message":"NO ERROR","net_amount_debit":1200,"disc":"0.00","mode":"CC","PG_TYPE":"HDFCPG","card_no":"401200XXXXXX1112","name_on_card":"Bala","udf2":null,"status":"success","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}';
                if(method == 'pending') {
                    fullJson = '{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"'+orderId+'":{"mihpayid":"403993715519893164","request_id":"","bank_ref_num":"201926617890566","amt":"1200.00","transaction_amount":"1200.00","txnid":"07192363746201992316156969114","additional_charges":"0.00","productinfo":"Registration","firstname":"Bala Krishna","bankcode":"CC","udf1":"Registration_00QO0000009pAsJMAU_0_PostPaymentPage_false_NA_","udf3":null,"udf4":null,"udf5":null,"field2":"000000","field9":null,"error_code":"E000","addedon":"2019-09-23 16:15:06","payment_source":"payu","card_type":"VISA","error_Message":"NO ERROR","net_amount_debit":1200,"disc":"0.00","mode":"CC","PG_TYPE":"HDFCPG","card_no":"401200XXXXXX1112","name_on_card":"Bala","udf2":null,"status":"pending","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}';
                } else if(method == 'failed') {
                    fullJson = '{"status":1,"msg":"1 out of 1 Transactions Fetched Successfully","transaction_details":{"'+orderId+'":{"mihpayid":"403993715519893164","request_id":"","bank_ref_num":"201926617890566","amt":"1200.00","transaction_amount":"1200.00","txnid":"07192363746201992316156969114","additional_charges":"0.00","productinfo":"Registration","firstname":"Bala Krishna","bankcode":"CC","udf1":"Registration_00QO0000009pAsJMAU_0_PostPaymentPage_false_NA_","udf3":null,"udf4":null,"udf5":null,"field2":"000000","field9":null,"error_code":"E001","addedon":"2019-09-23 16:15:06","payment_source":"payu","card_type":"VISA","error_Message":"Failed","net_amount_debit":1200,"disc":"0.00","mode":"CC","PG_TYPE":"HDFCPG","card_no":"401200XXXXXX1112","name_on_card":"Bala","udf2":null,"status":"Error","unmappedstatus":"captured","Merchant_UTR":null,"Settled_At":"0000-00-00 00:00:00"}}}';
                }
                res.setHeader('Content-Type', 'application/json');
            } else if(gatewayName == 'BillDesk GateWay') {
                fullJson ='0300|NMIMS|'+orderId+'|WSM21125180438|431763|6200.00|SM2|510372|03|INR|MDDIRECT|NA-431763|NA|00000000.00|05-05-2022 11:10:42|0300|NA|nitingoswami2102@yahoo.com|8209743426|Registration_00Q2j00000AXRUrEAP_0_PostPaymentPage_false_NA|00Q2j00000AXRUrEAP|6200.00|NA|false_No_null|NA|PGS10001-Success|D50386ECA990B151CAB6D6AB411F3E6725EAD7FA4515B450DCF6D6B741DE6D66';
                if(method =='pending') {
                    fullJson = '0002|NMIMS|'+orderId+'|WSM21125180438|431763|6200.00|SM2|510372|03|INR|MDDIRECT|NA-431763|NA|00000000.00|05-05-2022 11:10:42|0300|NA|nitingoswami2102@yahoo.com|8209743426|Registration_00Q2j00000AXRUrEAP_0_PostPaymentPage_false_NA|00Q2j00000AXRUrEAP|6200.00|NA|false_No_null|NA|PGS10001-Success|D50386ECA990B151CAB6D6AB411F3E6725EAD7FA4515B450DCF6D6B741DE6D66';
                } else if(method == 'failed') {
                    fullJson = '0399|NMIMS|'+orderId+'|WSM21125180438|431763|6200.00|SM2|510372|03|INR|MDDIRECT|NA-431763|NA|00000000.00|05-05-2022 11:10:42|0300|NA|nitingoswami2102@yahoo.com|8209743426|Registration_00Q2j00000AXRUrEAP_0_PostPaymentPage_false_NA|00Q2j00000AXRUrEAP|6200.00|NA|false_No_null|NA|PGS10001-Success|D50386ECA990B151CAB6D6AB411F3E6725EAD7FA4515B450DCF6D6B741DE6D66';
                }
                res.setHeader('Content-Type','application/x-form-urlencoded');
            } else if(gatewayName == 'Paytm GateWay') {
                fullJson = '{"TXNID":"20180926111212800110168766100018551","BANKTXNID":"5583250","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"TXN_SUCCESS","TXNTYPE":"SALE","GATEWAYNAME":"WALLET","RESPCODE":"01","RESPMSG":"Txn Success","BANKNAME":"WALLET","MID":"'+Label.Paytm_Merchant_Key+'","PAYMENTMODE":"PPI","REFUNDAMT":"0.00","TXNDATE":"2018-09-26 13:50:57.0","MERC_UNQ_REF": "DownPayment-AnnualFee_00Q2j00000DOxiBEAT_6700_PostPaymentPage_false_NA_false_No_null_false"}';
                if(method == 'pending') {
                    fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"PENDING","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0","MERC_UNQ_REF": "DownPayment-AnnualFee_00Q2j00000DOxiBEAT_6700_PostPaymentPage_false_NA_false_No_null_false"}';
                } else if(method == 'failed') {
                    fullJson = '{"TXNID":"20180927111212800110168666800020875","BANKTXNID":"","ORDERID":"'+orderId+'","TXNAMOUNT":"100.12","STATUS":"TXN_FAILURE","TXNTYPE":"SALE","RESPCODE":"810","RESPMSG":"Txn Failed","MID":"'+Label.Paytm_Merchant_Key+'","REFUNDAMT":"0.0","TXNDATE":"2018-09-27 10:07:15.0","MERC_UNQ_REF": "DownPayment-AnnualFee_00Q2j00000DOxiBEAT_6700_PostPaymentPage_false_NA_false_No_null_false"}';
                }
                res.setHeader('Content-Type', 'application/json');
            } else if(gatewayName == 'Razorpay GateWay') {
                fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"captured","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
                if(method == 'pending') {
                    fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"authorized","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
                } else if(method == 'failed') {
                    fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"failed","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
                }
                res.setHeader('Content-Type', 'application/json');
            } else if(gatewayName == 'ICICI GateWay') {
                fullJson = '{"cf_order_id":1258136582,"created_at":"2022-08-09T15:11:24+05:30","customer_details":{"customer_id":"072209885686893","customer_name":"Pragya Chirania","customer_email":"pragyachirania602@gmail.com","customer_phone":"7878138486"},"entity":"order","order_amount":6200,"order_currency":"INR","order_expiry_time":"2022-08-09T15:41:22+05:30","order_id":"'+orderId+'","order_meta":{"return_url":"https://ngasce.secure.force.com/nmICICIPayResponse?order_id={order_id}&order_token={order_token}","notify_url":null,"payment_methods":null},"order_note":null,"order_splits":[],"order_status":"PAID","order_tags":{"udf1":"Registration_00Q2j00000DOcrm_0_PostPaymentPage_false_NA","udf2":"false_No_null_false"},"order_token":"kBenN3gNcFrOuRsCIQkX","payment_link":"https://payments.cashfree.com/order/#kBenN3gNcFrOuRsCIQkX","payments":{"url":"https://api.cashfree.com/pg/orders/'+orderId+'/payments"},"refunds":{"url":"https://api.cashfree.com/pg/orders/'+orderId+'/refunds"},"settlements":{"url":"https://api.cashfree.com/pg/orders/'+orderId+'/settlements"}}';
                if(method == 'pending') {
                    fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"authorized","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
                } else if(method == 'failed') {
                    fullJson = '{"entity":"collection","count":1,"items":[{"id":"pay_JaFyoZMDbdGgam","entity":"payment","amount":4600000,"currency":"INR","status":"failed","order_id":"'+orderId+'","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":"NMIMS Global Access","card_id":null,"bank":"CBIN","wallet":null,"vpa":null,"email":"ninad.jalgaonkar@gmail.com","contact":"+919823481485","notes":{"udf2":"false_No_null","udf1":"AnnualFee_00Q2j00000685I6EAI_0_PostPaymentPage_false_0062j00000AOxqSAAT"},"fee":944,"tax":144,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"303405763"},"created_at":1653655567}]}';
                }
                res.setHeader('Content-Type', 'application/json');
            }
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        List<nm_Payment_Initiated__c> lstPayments = new List<nm_Payment_Initiated__c>();
        nm_Payment_Initiated__c initiatedPaymentRecord = new nm_Payment_Initiated__c();
        initiatedPaymentRecord.nm_Merchant_Track_Id__c = '2015101253010086';
        initiatedPaymentRecord.nm_PaymentGatewayName__c = 'HDFC GateWay';
        initiatedPaymentRecord.nm_PaymentStatus__c = 'Payment Initiated';
        lstPayments.add(initiatedPaymentRecord);

        nm_Payment_Initiated__c initiatedPaymentRecord2 = new nm_Payment_Initiated__c();
        initiatedPaymentRecord2.nm_Merchant_Track_Id__c = '2015101253010088';
        initiatedPaymentRecord2.nm_PaymentGatewayName__c = 'BillDesk GateWay';
        initiatedPaymentRecord2.nm_PaymentStatus__c = 'Payment Initiated';
        lstPayments.add(initiatedPaymentRecord2);

        nm_Payment_Initiated__c initiatedPaymentRecord3 = new nm_Payment_Initiated__c();
        initiatedPaymentRecord3.nm_Merchant_Track_Id__c = '2015101253010089';
        initiatedPaymentRecord3.nm_PaymentGatewayName__c = 'Paytm GateWay';
        initiatedPaymentRecord3.nm_PaymentStatus__c = 'Payment Initiated';
        lstPayments.add(initiatedPaymentRecord3);


        nm_Payment_Initiated__c initiatedPayment4 = new nm_Payment_Initiated__c();
        initiatedPayment4.nm_Merchant_Track_Id__c = '07192363746201992316156969114';
        initiatedPayment4.OrderId__c = '07192363746201992316156969114';
        initiatedPayment4.nm_PaymentGatewayName__c = 'Razorpay GateWay';
        initiatedPayment4.nm_PaymentStatus__c = 'Transaction Failed';
        lstPayments.add(initiatedPayment4);

        nm_Payment_Initiated__c initiatedPayment5 = new nm_Payment_Initiated__c();
        initiatedPayment5.nm_Merchant_Track_Id__c = '07192363746201992316';
        initiatedPayment5.OrderId__c = '07192363746201992316';
        initiatedPayment5.nm_PaymentGatewayName__c = 'ICICI GateWay';
        initiatedPayment5.nm_PaymentStatus__c = 'Transaction Failed';
        lstPayments.add(initiatedPayment5);

        insert lstPayments;
    }

    /* --------------------------------------- For PaymentCheckBatch For HDFC------------------------------------*/
    
    /**
    * @description 
    * @author @BK | 23/9/2019 
    * @return void 
    **/
    @isTest
    static void testUnit1() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
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
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
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
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
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
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'pending';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
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
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='HDFC GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'failed';
            rest.orderId = '2015101253010086';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    @isTest
    static void testUnit5() {
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
        nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='BillDesk GateWay' AND 
        nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '2015101253010088';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.start(null);
            batchClass.execute(null, scope);
            batchClass.finish(null);
        Test.stopTest();
    }

    static void testUnit6() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='BillDesk GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        // Insert payment record.
        nm_Payment__c paymentRecord = new nm_Payment__c();
        paymentRecord.nm_PaymentStatus__c = 'Payment Made';
        paymentRecord.nm_Merchant_Track_Id__c = '2015101253010088';
        paymentRecord.nm_PaymentType__c = 'Initial Payment';

        insert paymentRecord;

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '2015101253010088';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
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
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='BillDesk GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'pending';
            rest.orderId = '2015101253010088';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
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
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='BillDesk GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'failed';
            rest.orderId = '2015101253010088';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    @isTest
    static void testUnit9() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '2015101253010089';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit10() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        // Insert payment record.
        nm_Payment__c paymentRecord = new nm_Payment__c();
        paymentRecord.nm_PaymentStatus__c = 'Payment Made';
        paymentRecord.nm_Merchant_Track_Id__c = '2015101253010089';
        paymentRecord.nm_PaymentType__c = 'Additional Charge';
        insert paymentRecord;

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '2015101253010089';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit11() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'pending';
            rest.orderId = '2015101253010089';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }

    /**
    * @description
    * @author Bala | 11/4/2019
    * @return testmethod
    */
    @isTest
    static void testUnit12() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,CreatedDate,nm_PaymentGatewayName__c,IC_Name__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' AND 
            nm_PaymentStatus__c = 'Payment Initiated' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
            
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'failed';
            rest.orderId = '2015101253010089';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            
            batchClass.execute(null, scope);
            
        Test.stopTest();
    }

    @isTest
    static void testUnit13() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c,nm_PaymentGatewayName__c  FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Razorpay GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];

        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = scope[0].OrderId__c;
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);

        Test.stopTest();
    }

   @isTest
    static void testUnit14() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c,nm_PaymentGatewayName__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Razorpay GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'pending';
            rest.orderId = scope[0].OrderId__c;
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    @isTest
    static void testUnit15() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c,nm_PaymentGatewayName__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='Razorpay GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = scope[0].OrderId__c;
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
        Test.stopTest();
    }

    @isTest
    static void testUnit16() {
        //  Insert test data before Test.startTest()
        List<nm_Payment_Initiated__c> scope = [SELECT nm_Merchant_Track_Id__c,IC_Name__c,OrderId__c,nm_PaymentStatus__c,nm_PaymentGatewayName__c FROM 
            nm_Payment_Initiated__c WHERE nm_PaymentGatewayName__c='ICICI GateWay' AND 
            nm_PaymentStatus__c = 'Transaction Failed' AND createdDate = LAST_N_DAYS:15 ORDER BY nm_Merchant_Track_Id__c];
        Test.startTest();
            //  Establish the mock response, 
            RestMock rest = new RestMock();
            rest.gatewayName = scope[0].nm_PaymentGatewayName__c;
            rest.method = 'success';
            rest.orderId = '07192363746201992316';
            Test.setMock(HttpCalloutMock.class, rest);
            PaymentCheckBatch batchClass = new PaymentCheckBatch();
            batchClass.execute(null, scope);
        Test.stopTest();
    }
}