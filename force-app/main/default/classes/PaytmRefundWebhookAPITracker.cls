/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-10-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)  
public class PaytmRefundWebhookAPITracker {
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
        RestMock(){ 
        }   
        public HttpResponse respond(HttpRequest req)    
        {   
            String fullJson = '{"head":{"clientId":"C11","responseTimestamp":"1580802623249","signature":"HgTcjTUYc5FeuV8NnbbYCzQjiQOOeSZD76usCiQd2Nei7JjMXDKDyrDK05XxwsZ2nO8/0taToRukUFwT2JGrhMN/7K7NYdFtuDA7SNiFIvY=","version":"v1"},"body":{"orderId":"071905958932019451429126607","userCreditInitiateStatus":"SUCCESS","mid":"SVKMst48062445833229","merchantRefundRequestTimestamp":"2020-02-04 12:42:47.0","source":"MERCHANT","resultInfo":{"resultStatus":"TXN_SUCCESS","resultCode":"10","resultMsg":"Refund Successfull"},"txnTimestamp":"2019-04-05 14:29:41.0","acceptRefundTimestamp":"2020-02-04 12:42:47.0","acceptRefundStatus":"SUCCESS","refundDetailInfoList":[{"refundType":"TO_SOURCE","payMethod":"BALANCE","userCreditExpectedDate":"2020-02-05","userMobileNo":"91-******7777","refundAmount":"1.00"}],"userCreditInitiateTimestamp":"2020-02-04 12:42:49.0","totalRefundAmount":"208.00","refId":"REF07190595893201945142912660736","txnAmount":"800.00","refundId":"20200204111212801300168306502048187","txnId":"20190405111212800110168757700382741","refundAmount":"1.00"}}';    
            HttpResponse resp = new HttpResponse(); 
            resp.setHeader('Content-Type','application/x-form-urlencoded'); 
            resp.setBody(fullJson);    
            resp.setStatusCode(200);    
            return resp;    
        }   
    }

    @TestSetup    
    public static void makeData(){  
        Test.setMock(HttpCalloutMock.class, new RestMockII());  
        nmSerialNo__c objSerial = new nmSerialNo__c();  
        objSerial.nm_MaxGenratedNo__c=122355;   
        objSerial.nm_name__c= 'Reference Number';   
        insert objSerial;   
            
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');   
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');   
        nm_Payment__c objPayment = insertPayment(objopp.Id,'Paytm GateWay');
        nmRefund_Payment__c objRefund = new nmRefund_Payment__c();  
        objRefund.nm_Amount__c = 200;   
        objRefund.nm_Payment_Status__c = 'Refund Initiated';        
        objRefund.Opportunity__c = objopp.id;   
        objRefund.Description_for_addition_Deduction__c = 'test';   
        objRefund.nm_Transaction_Date__c = System.today();  
        insert objRefund;
        
        objPayment.Refund_Payment__c = objRefund.id;
        update objPayment;
    } 

    @isTest     
    static void UnitTestPaytmDeskSuccess() {   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
            
        Test.startTest();
        String myJSON = '{"head":{"signature":"AuCS57JOdq62oSPsxLCWTQupUuN1PPMbe7Gf1BIvO6FK7JnfzDzSm4HCBftanrpPPpT9EAIOWiNZ8LsvwFrTnonldx2qzHfAzizoi1ndhNQ=","version":"v1"},"body":{"source":"MERCHANT","txnId":"202005081112128XXXXXX68470101509706","orderId":"'+scope[0].nm_Merchant_Track_Id__c+'","txnAmount":"1.00","mid":"INTEGR7769XXXXXX9383","refundAmount":"1.00","txnTimestamp":"2020-09-03 16:51:41.0","totalRefundAmount":"1.00","acceptRefundTimestamp":"2020-09-03 16:52:10.0","refId":"'+scope[0].RefundId__c+'","merchantRefundRequestTimestamp":"2020-09-03 16:52:08.0","userCreditInitiateTimestamp":"2020-09-03 16:52:10.0","refundId":"20200903XXXXXX801300168821700215705","status":"SUCCESS","refundDetailInfoList":[{"refundType":"TO_SOURCE","payMethod":"CREDIT_CARD","refundAmount":"1.00","rrn":"1735XXXX84","issuingBankName":"HDFC Bank","maskedCardNumber":"5242********3040","cardScheme":"MASTER","userCreditExpectedDate":"2020-09-13"}],"agentInfo":{"employeeId":"Emp-001","name":"Lalit","phoneNo":"7777777777","email":"customer@example.com"}}}';
            RequestData(myJSON,'POST');
            PaytmRefundWebhookAPI.updateRefundStatus();
        Test.stopTest();    
    }

    @isTest     
    static void UnitTestPaytmDeskFailed() {   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
            
        Test.startTest();
            String myJSON = '{"head":{"signature":"Ec4jwawWFcsOS4lZJ5aClcatsJ8c55CJDW0MA9gp37MwQ8bcXsMT1mmlbDrefundIdwgGOzxzba5kADe7UiALEtZQvKVQ5YrYSpcQtZ0gghKLWc=","version":"v1"},"body":{"source":"MERCHANT","txnId":"20210511111212809100168651600043304","orderId":"'+scope[0].nm_Merchant_Track_Id__c+'","txnAmount":"5.00","mid":"216820000005799438682","refundAmount":"1.00","txnTimestamp":"2021-05-11 16:40:51.0","totalRefundAmount":"0.00","acceptRefundTimestamp":"2021-05-11 16:52:38.0","merchantRefundRequestTimestamp":"2021-05-11 16:52:30.0","refId": "'+scope[0].RefundId__c+'","refundId":"20210511111212809800168652200008826","refundDetailInfoList":[{"refundType":"TO_SOURCE","payMethod":"NET_BANKING","refundAmount":"1.00","issuingBankName":"ICICI"}],"refundReason":"InitiateRefund","gatewayInfo":"{\"MID\":\"aGJueP32200647102461\",\"TXNID\":\"20210511111212800100168366001423248\",\"ORDERID\":\"Test6783\",\"REFUNDAMOUNT\":\"10.00\",\"RESPCODE\":\"619\",\"RESPMSG\":\"Invalid refund amount.\",\"STATUS\":\"TXN_FAILURE\",\"REFID\":\"REF6986\"}","status":"FAILED","rejectRefundReasonCode":"501","rejectRefundReasonMessage":"Refund Failed"}}';
            RequestData(myJSON,'POST');
            PaytmRefundWebhookAPI.updateRefundStatus();
        Test.stopTest();    
    }

    @isTest     
    static void UnitTestPaytmDeskInCorrectRequest() {   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
            
        Test.startTest();
            String myJSON = '{"head":{"version":"v1"},"body":{"txnTimestamp":"2020-09-03 16:51:41.0","orderId":"'+scope[0].nm_Merchant_Track_Id__c+'","refundAmount":"1.00","refundId":"20200903XXXXXX801300168821700215705","txnAmount":"1.00","txnId":"202005081112128XXXXXX68470101509706","merchantRefundRequestTimestamp":"2020-09-03 16:52:08.0","acceptRefundTimestamp":"2020-09-03 16:52:09.0","refId":"'+scope[0].RefundId__c+'","refundReason":"Sample Refund Reason ","agentInfo":{"employeeId":"Emp-001","name":"Lalit","phoneNo":"7777777777","email":"customer@example.com"},"status":"FAILED","rejectRefundReasonCode": "1","rejectRefundReasonMessage": "Insufficient balance in your settlement account"}}';
            RequestData(myJSON,'POST');
            PaytmRefundWebhookAPI.updateRefundStatus();
        Test.stopTest();    
    }
    
    public static nm_Payment__c insertPayment(String objOppId, String paymentGateway) { 
        nm_Payment__c objPayment = new nm_Payment__c();     
        objPayment.nm_TransactionID__c = 'Tran0003';    
        objPayment.nm_ModeOfPayment__c = 'Online';  
        objPayment.nm_RefNo__c = '1285484'; 
        objPayment.nm_Amount__c = 1100; 
        objPayment.nm_OpportunityNew__c = objOppId; 
        objPayment.nm_PaymentStatus__c = 'Payment  Approved';   
        objPayment.nm_Merchant_Track_Id__c = '071905958932019451429126607'; 
        objPayment.nm_PaymentGatewayName__c = paymentGateway;   
        objPayment.nm_PaymentType__c = 'Registration';  
        objPayment.nm_TransactionDate__c = System.today();  
        objPayment.Refund_Process_Status__c = 'PENDING';    
        objPayment.Refund_Initiated_Error_Message__c = 'Refund request was raised for this transaction. But it is pending state.';  
        objPayment.Refund_Error_Code__c = '601';    
        objPayment.RefundId__c = 'REF07190595893201945142912660736';    
        insert objPayment;  
            
        return objPayment;  
    }

    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/PaytmRefundWebhookAPI/V1.1/';
        request.requestBody = Blob.valueof(myJSON);
        request.httpMethod = requestMethod;
        RestContext.request = request;
        RestContext.response = response;
    }
}