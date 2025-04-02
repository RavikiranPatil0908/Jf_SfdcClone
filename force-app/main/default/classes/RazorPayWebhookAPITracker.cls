/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 04-12-2022
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)  
public class RazorPayWebhookAPITracker {
   
    @TestSetup    
    public static void makeData(){  
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);   
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered'); 
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission'); 
        nm_Payment_Initiated__c objPayment = insertPayment(objopp.Id,'Razorpay GateWay'); 
   
    }

    @isTest     
    static void UnitTestRazorPay() {  
 List<nm_Payment_Initiated__c> lstList = [SELECT id,nm_Merchant_Track_Id__c,nm_Fee_Type__c,nm_Lead__c,nm_PaymentStatus__c,nm_OpportunityNew__c,nm_Amount__c,
        payment_Transaction_Mode__c,OrderId__c,nm_ModeOfPayment__c,Online_Payment_Id__c
         FROM nm_Payment_Initiated__c Limit 1]; 
      
        Test.startTest();
            String myJSON = '{"entity":"event","account_id":"acc_BFQ7uQEaa7j2z7","event":"order.paid","contains":["payment","order"],"payload":{"payment":{"entity":{"id":"pay_JBKuasWBImt3EN","entity":"payment","amount":2354280,"currencyCode":"INR","status":"captured","order_id":"order_JBKuKKN4aNRUXT","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":true,"description":null,"card_id":null,"bank":"HDFC","wallet":null,"vpa":null,"email":"gaurav.kumar@example.com","contact":"+919876543210","notes":{"udf2":"false_No_null","udf1":"Additional Charge - Admission_006O000000GOYe4_0_PostPaymentPage_false_006O000000GOYe4IAH"},"fee":54280,"tax":8280,"error_code":null,"error_description":null,"created_at":1567674599}},"order":{"entity":{"id":"order_JBKuKKN4aNRUXT","entity":"order","amount":23000,"amount_paid":23000,"amount_due":0,"currencyCode":"INR","receipt":"'+lstList[0].nm_Merchant_Track_Id__c+'","offer_id":null,"status":"paid","attempts":1,"notes":{"udf2":"false_No_null","udf1":"Additional Charge - Admission_006O000000GOYe4_0_PostPaymentPage_false_006O000000GOYe4IAH"},"created_at":1567674581}}},"created_at":1567674606}';
            RequestData(myJSON,'POST');
            RazorPayWebhookAPI.UpdatePaymentStatus();
        Test.stopTest();    
    }


    public static nm_Payment_Initiated__c insertPayment(String objOppId, String paymentGateway) { 
        nm_Payment_Initiated__c objPayment = new nm_Payment_Initiated__c();
        objPayment.Online_Payment_Id__c = 'pay_JBKuasWBImt3EN';
        objPayment.OrderId__c = 'order_JBKuKKN4aNRUXT';
        objPayment.nm_Amount__c = 2354280;
        objPayment.nm_PaymentGatewayName__c = paymentGateway; 
        objPayment.nm_Merchant_Track_Id__c = '012321323881202232518506764853';
        objPayment.nm_PaymentStatus__c = 'Payment Made';

        insert objPayment; 
        return objPayment;
    }

    public static void RequestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/RazorPayWebhookAPI/V1.1';
        request.requestBody = Blob.valueof(myJSON);
        request.httpMethod = requestMethod;
        RestContext.request = request;
        RestContext.response = response;
    }

}