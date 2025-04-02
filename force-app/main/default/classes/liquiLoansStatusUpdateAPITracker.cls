/**
 * @File Name          : liquiLoansStatusUpdateAPITracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 08-27-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/7/2019   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public class liquiLoansStatusUpdateAPITracker {
    
    public static Account objAccount;
    public static lead objLead;
	public static Opportunity objOpp;
    
    private class RestMock implements HttpCalloutMock {
        public Integer statusCode;
        RestMock(){
            statusCode = 200;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Generate a typical response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status": true,"message": "Loan status updated!","data": 1,"code": 200,"checksum": null}');
            response.setStatusCode(200);
            return response; 
        }
    }  

     private class RestMock1 implements HttpCalloutMock {
        public Integer statusCode;
        RestMock1(){
            statusCode = 200;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Generate a typical response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":true,"message":"Data found!","data":{"status":{"loanId":31829,"loanCode":"CL00031829","status":"Approved","orderId":"01200939013","amount":81000,"productAmount":81000,"disbursedAmount":0,"utr":"","last_status_timestamp":"2020-04-20T07:05:01.000000Z"}},"code":200,"checksum":null}{"status":false,"message":"Service Unavailable.","data":[],"code":400,"checksum":null}');
            response.setStatusCode(200);
            return response; 
        }
    }  

    @testSetup
    public static void setUpData(){
		Test.setMock(HttpCalloutMock.class, new RestMock());
		nmGenericTracker.InsertSerialNo();
        objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Loan_Order_Id__c ='07181977383';
        objLead.Loan_Type__c ='LiquiLoans';
        update objLead;
		objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Confirmed');
		objAccount.nm_StudentNo__c = '77214000953';
		update objAccount;
		objOpp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'PGAllSemFee');
        objOpp.Loan_Order_Id__c ='07181977381';
        objOpp.Loan_Type__c = 'LiquiLoans';
        update objOpp;
    }

    /**
    * @description 
    call liquiLoansStatusUpdateAPI for updating approved status for liquiloans 
    * @author shubhranshu | 12/7/2019 
    * @return testmethod 
    **/
    public static testmethod void testPostCallout(){
        Opportunity opp = [select Id from Opportunity limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock());
        liquiLoansStatusUpdateAPI.statusUpdateForLoan('30054','Y',opp.Id,'Opportunity');
        Test.stopTest();
    }

    public static testmethod void testPostCallout1(){
        Opportunity opp = [select Id from Opportunity limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new RestMock1());
        liquiLoansStatusUpdateAPI.CheckStatus('30054',opp.Id,'Opportunity');
        Test.stopTest();
    }
}