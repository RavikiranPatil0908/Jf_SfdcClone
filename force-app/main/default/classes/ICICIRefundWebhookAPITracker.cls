/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-10-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)  
public with sharing class ICICIRefundWebhookAPITracker {
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

    @TestSetup    
    public static void makeData(){  
        Test.setMock(HttpCalloutMock.class, new RestMockII());  
        nmSerialNo__c objSerial = new nmSerialNo__c();  
        objSerial.nm_MaxGenratedNo__c=122355;   
        objSerial.nm_name__c= 'Reference Number';   
        insert objSerial;   
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);      
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');   
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');   
        nm_Payment__c objPayment = insertPayment(objopp.Id,'ICICI GateWay');    
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
    static void UnitTestICICISuccess(){   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
            
        Test.startTest();
        String myJSON = '{ "data": { "refund": { "cf_refund_id": 11325632, "cf_payment_id": 789727431, "refund_id":"'+scope[0].RefundId__c+'", "order_id": "'+scope[0].nm_Merchant_Track_Id__c+'", "refund_amount": 2, "refund_currency": "INR", "entity": "Refund", "refund_type": "MERCHANT_INITIATED", "refund_arn": "205907014017", "refund_status": "SUCCESS", "status_description": "Refund processed successfully", "created_at": "2022-02-28T12:54:25+05:30", "processed_at": "2022-02-28T13:04:27+05:30", "refund_charge": 0, "refund_note": "Test", "refund_splits": null, "metadata": null, "refund_mode": "STANDARD" } }, "event_time": "2022-02-28T13:04:28+05:30", "type": "REFUND_STATUS_WEBHOOK" }';
        System.debug('myJSON--'+myJSON);    
        RequestData(myJSON,'POST');
            ICICIRefundWebhookAPI.updateRefundStatus();
            ICICIRefundWebhookAPI.returnMessage('12356','abcde','xyz',true,scope[0].id);
        Test.stopTest();    
    }


    @isTest     
    static void UnitTestICICIkFailed() {   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
            
        Test.startTest();
    String myJSON = '{ "data": { "refund": { "cf_refund_id": 11325632, "cf_payment_id": 789727431, "refund_id":"'+scope[0].RefundId__c+'", "order_id": "'+scope[0].nm_Merchant_Track_Id__c+'", "refund_amount": 2, "refund_currency": "INR", "entity": "Refund", "refund_type": "MERCHANT_INITIATED", "refund_arn": "205907014017", "refund_status": "FAILED", "status_description": "Refund processed successfully", "created_at": "2022-02-28T12:54:25+05:30", "processed_at": "2022-02-28T13:04:27+05:30", "refund_charge": 0, "refund_note": "Test", "refund_splits": null, "metadata": null, "refund_mode": "STANDARD" } }, "event_time": "2022-02-28T13:04:28+05:30", "type": "REFUND_STATUS_WEBHOOK" }';
            RequestData(myJSON,'POST');
            ICICIRefundWebhookAPI.updateRefundStatus();
        Test.stopTest();    
    }

    @isTest     
    static void UnitTestICICIInCorrectRequest() {   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
            
        Test.startTest();
    String myJSON = '{ "data": { "refund": { "cf_refund_id": 11325632, "cf_payment_id": 789727431, "refund_id":"'+scope[0].RefundId__c+'", "order_id": "'+scope[0].nm_Merchant_Track_Id__c+'", "refund_amount": 2, "refund_currency": "INR", "entity": "Refund", "refund_type": "MERCHANT_INITIATED", "refund_arn": "205907014017", "refund_status": "FAILED", "status_description": "Refund processed successfully", "created_at": "2022-02-28T12:54:25+05:30", "processed_at": "2022-02-28T13:04:27+05:30", "refund_charge": 0, "refund_note": "Test", "refund_splits": null, "metadata": null, "refund_mode": "STANDARD" } }, "event_time": "2022-02-28T13:04:28+05:30", "type": "REFUND_STATUS_WEBHOOK" }';
            RequestData(myJSON,'POST');
            ICICIRefundWebhookAPI.updateRefundStatus();
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
        request.requestURI = System.Label.Site_Url+'services/apexrest/ICICIRefundWebhookAPI/V1.1/';
        request.requestBody = Blob.valueof(myJSON);
        request.httpMethod = requestMethod;
        request.headers.put('x-webhook-signature','test');
        request.headers.put('x-webhook-timestamp','test');
        RestContext.request = request;
        RestContext.response = response;
    }

}