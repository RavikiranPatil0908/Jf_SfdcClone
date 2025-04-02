/**
 * @File Name          : RefundWebServiceTracker.cls
 * @Description        : 
 * @Author             : Balakrishnan
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 10-06-2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    29/3/2019, 6:45:25 PM           @BK                    Initial Version
**/
@isTest(SeeAllData=false)
public class RefundWebServiceTracker {
    public static Opportunity objopp;

    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
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
    
    public class RestMock implements HttpCalloutMock{
        public String method;
        public string gatewayVersion = null;
        RestMock(){
          method ='';
        }
        
        public HttpResponse respond(HttpRequest req)
        {
            String fullJson = '';
            if(method == 'BillDesk GateWay' && String.isBlank(gatewayVersion)){
                fullJson = '0410|NMIMS|JCMP5627902091|NA|20179117157492800|NA|0799|0799|0799|0799|ERR_REF011|Invalid source|N|9EAD4885EBAC5605352826CA0FFCD16CB7498751B8D1960692C23F45034307CB';
            }else if(method == 'HDFC GateWay'){
                fullJson  = '{"status":1,"msg":" Cancel Request Queued","txn_update_id":"REF098776","bank_ref_num":"DFGCV","mihpayid":"000989789"}';
            }else if(method == 'Paytm GateWay'){
                fullJson  = '{"MID":"rxazcv89315285244163","TXNID":"20180404111212800110168881700011032","ORDERID":"order1","TXNAMOUNT":"100.12","REFUNDAMOUNT":"10.12","TXNDATE":"2018-04-04 13:50:38.0","RESPCODE":"10","RESPMSG":"Refund Successfull","STATUS":"TXN_SUCCESS","REFID":"reforder1","CARD_ISSUER":"","BANKTXNID":"5584052","PAYMENTMODE":"PPI","TOTALREFUNDAMT":"10.12","REFUNDDATE":"2018-05-04 15:57:00.0","REFUNDTYPE":"REFUND","REFUNDID":"20180504111212801300168300400006844"}';
            }else if(method == 'PayPal GateWay'){
                fullJson  = '{"id":"0P209507D6694645N","create_time":"2017-05-06T22:11:51Z","update_time":"2017-05-06T22:11:51Z","state":"completed","amount":{"total":"110.54","currency":"USD"},"capture_id":"8F148933LY9388354","parent_payment":"PAY-8PT597110X687430LKGECATA","invoice_number":"INV-1234567","links":[{"href":"https://api-m.sandbox.paypal.com/v1/payments/refund/0P209507D6694645N","rel":"self","method":"GET"},{"href":"https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-8PT597110X687430LKGECATA","rel":"parent_payment","method":"GET"},{"href":"https://api-m.sandbox.paypal.com/v1/payments/capture/8F148933LY9388354","rel":"capture","method":"GET"}]}';
            }else if(method == 'Razorpay Gateway') {
                fullJson  = '{"id":"rfnd_FP8QHiV938haTz","entity":"refund","amount":500100,"receipt":null,"currency":"INR","payment_id":"pay_29QQoUBi66xm2f","notes":[],"acquirer_data":{"arn":null},"created_at":1597078866,"batch_id":null,"status":"processed","speed_processed":"normal","speed_requested":"normal"}';
            }else if(method == 'ICICI GateWay') {
                fullJson  = '{"cf_payment_id":885640635,"cf_refund_id":"refund_47608","created_at":"2022-10-06T12:08:50+05:30","entity":"refund","metadata":null,"order_id":"221696757309202210112447391813","processed_at":null,"refund_amount":1,"refund_arn":null,"refund_charge":0,"refund_currency":"INR","refund_id":"REF0922079496418852022971858204489233","refund_mode":"STANDARD","refund_note":null,"refund_splits":[],"refund_status":"PENDING","refund_type":"MERCHANT_INITIATED","status_description":"In Progress"}';
            }else if(method == 'BillDesk GateWay' && gatewayVersion == 'v2') {
                fullJson ='{ "objectid":"refund", "refundid":"U12300000380611", "transactionid":"U1230000038061", "orderid":"ORDER28102020005", "mercid":"BDMERCID", "transaction_date":"2020-10-28T01:03:56+05:30", "txn_amount":"500.00", "refund_amount":"250.00", "currency":"356", "refund_date":"2020-11-03T18:11:45+05:30", "merc_refund_ref_no":"NBREF0001", "refund_status":"0799" }';
                fullJson = getBilldeskV2EncodedBody(fullJson);
            }
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type','application/x-form-urlencoded');
            resp.setBody(fullJson );
            resp.setStatusCode(200);
            return resp;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        nmSerialNo__c objSerial = new nmSerialNo__c();
        objSerial.nm_MaxGenratedNo__c=122355;
        objSerial.nm_name__c= 'Reference Number';
        insert objSerial;
        
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');
        objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        system.debug('objopp --> ' + objopp.Id);

        
        // nm_Payment__c objPayment2 = insertPayment(objopp.Id,'HDFC GateWay');
        // nm_Payment__c objPayment3 = insertPayment(objopp.Id,'Paytm GateWay');
        // // nm_Payment__c objPayment4 = insertPayment(objopp.Id,'PayPal GateWay');
        // nm_Payment__c objPayment5 = insertPayment(objopp.Id,'RazorPay Gateway');
        // // nm_Payment__c objPayment6 = insertPayment(objopp.Id,'CCAvenue Gateway');
        // nm_Payment__c objPayment7 = insertPayment(objopp.Id,'ICICI GateWay');

        nmRefund_Payment__c objRefund = new nmRefund_Payment__c();
        objRefund.nm_Amount__c = 200;
        objRefund.nm_Payment_Status__c = 'Refund Initiated';      
        objRefund.Opportunity__c = objopp.id;
        objRefund.Description_for_addition_Deduction__c = 'test';
        objRefund.nm_Transaction_Date__c = System.today();
        insert objRefund;
    }

    @isTest 
    static void UnitTestBillDesk() {
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        system.debug('objopp u1 --> ' + objopp.Id);
        nm_Payment__c objPayment = insertPayment(objopp.Id,'BillDesk GateWay');
        objPayment.Payment_Gateway_Version__c = 'v2';
        objPayment.nm_ActualPaymentAmmount__c = 1000;
        objPayment.Transaction_DateTime__c = Datetime.now();
        update objPayment;
        nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
        Test.startTest();
            RestMock mock = new RestMock();
            mock.method = 'BillDesk GateWay';
            mock.gatewayVersion= 'v2';
            Test.setMock(HttpCalloutMock.class, mock);
            RefundWebService obj = new RefundWebService();
            RefundWebService.inititateRefund(objPayment.id, 100);
            RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
        Test.stopTest();
    }

    @isTest 
    static void UnitTestBillDesk1() {
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        system.debug('objopp u1 --> ' + objopp.Id);
        nm_Payment__c objPayment = insertPayment(objopp.Id,'BillDesk GateWay');
        nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
        Test.startTest();
            RestMock mock = new RestMock();
            mock.method = 'BillDesk GateWay';
            Test.setMock(HttpCalloutMock.class, mock);
            RefundWebService obj = new RefundWebService();
            RefundWebService.inititateRefund(objPayment.id, 100);
            RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
        Test.stopTest();
    }

    @isTest 
    static void UnitTestHDFCDesk() {
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        nm_Payment__c objPayment = insertPayment(objopp.Id,'HDFC GateWay');
        Test.startTest();
        nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
            RestMock mock = new RestMock();
            mock.method = 'HDFC GateWay';
            Test.setMock(HttpCalloutMock.class, mock);
            RefundWebService obj = new RefundWebService();
            RefundWebService.inititateRefund(objPayment.id, 100);
            RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
        Test.stopTest();
    }

    @isTest 
    static void UnitTestRazorPayDesk() {
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        nm_Payment__c objPayment = insertPayment(objopp.Id,'RazorPay Gateway');
        Test.startTest();
        nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
            RestMock mock = new RestMock();
            mock.method = 'RazorPay Gateway';
            Test.setMock(HttpCalloutMock.class, mock);
            RefundWebService obj = new RefundWebService();
            RefundWebService.inititateRefund(objPayment.id, 100);
            RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
        Test.stopTest();
    }

    // @isTest 
    // static void UnitTestCCAvenueDesk() {
    //     nm_Payment__c objPayment = [SELECT id FROM nm_Payment__c WHERE nm_PaymentGatewayName__c='CCAvenue Gateway' LIMIT 1];
    //     nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
    //     Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
    //     Test.startTest();
    //         RestMock mock = new RestMock();
    //         mock.method = 'CCAvenue Gateway';
    //         Test.setMock(HttpCalloutMock.class, mock);
    //         RefundWebService obj = new RefundWebService();
    //         RefundWebService.inititateRefund(objPayment.id, 100);
    //         RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
    //     Test.stopTest();
    // }


    @isTest 
    static void UnitTestPaytmDesk() {
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        nm_Payment__c objPayment3 = insertPayment(objopp.Id,'Paytm GateWay');
        Test.startTest();
        nm_Payment__c objPayment = [SELECT id FROM nm_Payment__c WHERE nm_PaymentGatewayName__c='Paytm GateWay' LIMIT 1];
        nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
            RestMock mock = new RestMock();
            mock.method = 'Paytm GateWay';
            Test.setMock(HttpCalloutMock.class, mock);
            RefundWebService obj = new RefundWebService();
            RefundWebService.inititateRefund(objPayment.id, 100);
            RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
        Test.stopTest();
    }

    @isTest 
    static void UnitTestICICIDesk() {
        Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
        nm_Payment__c objPayment = insertPayment(objopp.Id,'ICICI GateWay');
        Test.startTest();
        nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
            RestMock mock = new RestMock();
            mock.method = 'ICICI GateWay';
            Test.setMock(HttpCalloutMock.class, mock);
            RefundWebService obj = new RefundWebService();
            RefundWebService.inititateRefund(objPayment.id, 100);
            RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
        Test.stopTest();
    }

    // @isTest 
    // static void UnitTestPayPalDesk() {
    //     nm_Payment__c objPayment = [SELECT id FROM nm_Payment__c WHERE nm_PaymentGatewayName__c='PayPal GateWay' LIMIT 1];
    //     nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1];
    //     Opportunity objOpp = [SELECT id FROM Opportunity LIMIT 1];
    //     Test.startTest();
    //         RestMock mock = new RestMock();
    //         mock.method = 'PayPal GateWay';
    //         Test.setMock(HttpCalloutMock.class, mock);
    //         RefundWebService obj = new RefundWebService();
    //         RefundWebService.inititateRefund(objPayment.id, 100);
    //         RefundWebService.updateRefundPaymentRecord(objRefund.id,'1234',100);
    //     Test.stopTest();
    // }
    
    public static nm_Payment__c insertPayment(String objOppId, String paymentGateway) {
        
        nm_Payment__c objPayment = new nm_Payment__c(); 
        objPayment.nm_TransactionID__c = 'Tran0003';
        objPayment.nm_ModeOfPayment__c = 'Online';
        objPayment.nm_RefNo__c = '1285484';
        objPayment.nm_Amount__c = 1100;
        objPayment.nm_OpportunityNew__c = objOppId;
        objPayment.nm_PaymentStatus__c = 'Payment  Approved';
        objPayment.nm_Merchant_Track_Id__c = '2233098';
        objPayment.nm_PaymentGatewayName__c = paymentGateway;
        objPayment.nm_PaymentType__c = 'Registration';
        objPayment.nm_TransactionDate__c = System.today();
        insert objPayment; 
        
        return objPayment;
    }

    public static string getBilldeskV2EncodedBody(String jsonBodyParam) {
        API_Key__mdt BilldeskV2 = [SELECT Id, Label, Client_ID__c, Merchant_ID__c, Base_Url__c, Secret_Key__c FROM API_Key__mdt WHERE MasterLabel = 'BillDesk V2' LIMIT 1];
        String headerJWS = '{"alg":"HS256","clientid":"' + BilldeskV2.Client_ID__c + '"}';
        string jwt = nmBillDeskHelper.base64URLencode(blob.valueof(headerJWS)) + '.' +nmBillDeskHelper.base64URLencode(blob.valueof(jsonBodyParam));
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),blob.valueof(BilldeskV2.Secret_Key__c));
        return jwt + '.' +nmBillDeskHelper.base64URLencode(signature);
    }
}