/**
 * @description       :
 * @author            : @Ravi
 * @group             :
 * @last modified on  : 29--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   28--01--2026   @Ravi   Initial Version
**/
@isTest(seeAllData=false)
public with sharing class MobileAppPaymentAPIHandlerTracker {

    @TestSetup
    public static void makeData() {
        nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
        nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    @isTest
    public static void unitTest1() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('getPaymentDetails',new Map<String,Object>{'recordId'=>led.Id});
    }

    @isTest
    public static void unitTest2() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('proceedWithLoanApplicaation',new Map<String,Object>{'recordId'=>led.Id,'resTrackId'=>'1234567890123','loanProvider'=>'Avanse'});
    }

    @isTest
    public static void unitTest3() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('makeOnlinePayment',new Map<String,Object>{'recordId'=>led.Id,'paymentFor'=>'Admission','paymentGateWayName'=>'ICICI GateWay'});
    }

    @isTest
    public static void unitTest4() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('handlePaymentResponse',new Map<String,Object>{'recordId'=>led.Id});
    }

    @isTest
    public static void unitTest5() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('cancelLoanApplication',new Map<String,Object>{'recordId'=>led.Id,'resTrackId'=>'1234567890123'});
    }

    @isTest
    public static void unitTest6() {
        Test.startTest(); MobileAppPaymentService.invalidURI(); Test.stopTest();
    }

    @isTest
    public static void unitTest7() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('applyForLoan',new Map<String,Object>{'recordId'=>led.Id,'paymentFor'=>'DownPayment-admission','objLoanDetails'=>'{"Tenure":"6","showEMIOption":null,"processingFee":null,"LoanType":"Avanse","loanSanctioned":false,"loanPaymentTrackId":"","loanApproved":false,"loanAmount":0}'});
    }

    @isTest
    public static void unitTest8() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('getPaymentDetails',new Map<String,Object>{'recordd'=>led.Id});
    }

    @isTest
    public static void unitTest9() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('proceedWithLoanApplicaation',new Map<String,Object>{'recordId'=>led.Id,'loanProvider'=>'Avanse'});
    }

    @isTest
    public static void unitTest10() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('makeOnlinePayment',new Map<String,Object>{'recordId'=>led.Id,'paymentFor'=>'Admission'});
    }

    @isTest
    public static void unitTest11() {
        Lead led=[SELECT Id,nm_RegistrationNo__c FROM Lead LIMIT 1];
        callAPI('cancelLoanApplication',new Map<String,Object>{'recordId'=>led.Id});
    }

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res=new HTTPResponse(); 
            res.setHeader('Content-Type','application/x-www-form-urlencoded');
             res.setBody(''); 
             res.setStatusCode(200); return res;
        }
    }

    public static void callAPI(String action,Map<String,Object> body) {
        RestRequest req=new RestRequest(); 
        RestResponse res=new RestResponse();
        req.httpMethod='POST';
        req.requestURI='/services/apexrest/api/PaymentService/'+action;
        req.requestBody=Blob.valueOf(JSON.serialize(body));
        RestContext.request=req;
        RestContext.response=res;
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class,new RestMock());
        MobileAppPaymentService.handlePayment(); 
        Test.stopTest();
    }
}
