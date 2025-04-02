/** 
 * @File Name          : RefundStatusBatchForICICITracker.cls   
 * @Description        :    
 * @Author             : @BK    
 * @Group              :    
 * @Last Modified By   : @BK
 * @Last Modified On   : 04-13-2023
 * @Modification Log   :    
 * Ver       Date            Author                 Modification    
 * 1.0    4/2/2020   @BK     Initial Version    
**/ 
@isTest(SeeAllData=false)    
public class RefundStatusBatchForICICITracker {

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
            String fullJson = '[{"cf_payment_id":1409018785,"cf_refund_id":"refund_25425004","created_at":"2023-04-11T11:15:33+05:30","entity":"refund","metadata":null,"order_id":"","processed_at":"2023-04-11T11:25:36+05:30","refund_amount":200,"refund_arn":"310150964959","refund_charge":0,"refund_currency":"INR","refund_id":"REF07190595893201945142912660736","refund_mode":null,"refund_note":null,"refund_splits":[],"refund_status":"SUCCESS","refund_type":"MERCHANT_INITIATED","status_description":"Refund processed successfully"}]';
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
        nmRefund_Payment__c objRefund = new nmRefund_Payment__c();  
        objRefund.nm_Amount__c = 200;   
        objRefund.nm_Payment_Status__c = 'Refund Initiated';        
        objRefund.Opportunity__c = objopp.id;   
        objRefund.Description_for_addition_Deduction__c = 'test';   
        objRefund.nm_Transaction_Date__c = System.today();  
        insert objRefund;
        nm_Payment__c objPayment = insertPayment(objopp.Id,'ICICI GateWay',objRefund.id);    

    }   
    @isTest     
    static void UnitTestICICIDesk() {   

        List<nm_Payment__c> scope = [SELECT id,IC_Name__c,nm_Merchant_Track_Id__c,Opps_ID__c,Refund_Process_Status__c,Refund_Error_Code__c,
                Refund_Initiated_Error_Message__c,RefundId__c,Refunded_Amount__c,Refund_Paid_Date__c,nm_OpportunityNew__c,Refund_Payment__c 
                FROM nm_Payment__c WHERE Refund_Process_Status__c='PENDING' AND nm_Merchant_Track_Id__c!=null AND RefundId__c!=null];
        // nmRefund_Payment__c objRefund = [SELECT id FROM nmRefund_Payment__c WHERE nm_Payment_Status__c='Refund Initiated' LIMIT 1]; 
            
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            // to call the start method
            RefundStatusBatchForICICI objRefundBatch = new RefundStatusBatchForICICI();
            objRefundBatch.start(null);
            //  to call the execute method
            objRefundBatch.execute(null, scope);
            // to call the finish method
            Set<String> setOfRecordId = new Set<String>{scope[0].id};
            objRefundBatch.mapOfRecordTypeVsRecords.put('nmRefund_Payment__c', setOfRecordId);
            objRefundBatch.mapOfRecordTypeVsRecords.put('nm_Payment__c', setOfRecordId);
            objRefundBatch.finish(null);
        Test.stopTest();    
    }

    public static nm_Payment__c insertPayment(String objOppId, String paymentGateway,String refundID) { 
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
        objPayment.Refund_Payment__c = refundID;
        insert objPayment;  
            
        return objPayment;  
    }   
}