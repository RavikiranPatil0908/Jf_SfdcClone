/**
 * @description       : 
 * @author            : @Ravi
 * @group             : 
 * @last modified on  : 29--01--2026
 * @last modified by  : @Ravi
 * Modifications Log
 * Ver   Date           Author   Modification
 * 1.0   29--01--2026   @Ravi   Initial Version
**/
@IsTest(seeAllData=false)
public with sharing class MobileAppVideoCallAPIHandlerTracker {

    @TestSetup
    static void makeData(){
        Account acc = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatusvs2('Yes',false,'Registered');
        // nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
    }

    @IsTest
    static void unitTest1(){
      Account acc =[SELECT Id FROM Account LIMIT 1];
        Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => acc.Id};
        callAPI('getCallDetails',jsonMap);
    }

    @IsTest
    static void unitTest2(){
        Account acc =[SELECT Id FROM Account LIMIT 1];
        Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => acc.Id,'CallDate'=>System.today(),'CallRange'=> null};
        callAPI('getSlotDetails',jsonMap);
    }

    @IsTest
    static void unitTest4(){
        Account acc =[SELECT Id FROM Account LIMIT 1];
        Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => acc.Id,'CallDate'=>System.today(),'CallRange'=> '10:00 AM - 11:00 AM'};
        callAPI('getSlotDetails',jsonMap);
    }

    @IsTest
    static void unitTest3(){
        Account acc =[SELECT Id FROM Account LIMIT 1];
        Map<String ,Object> datamap= new Map<String, Object>{'meetingDate'=> System.today(),'meetingTimeRange'=>'10:00 AM - 11:00 AM','meetingTime'=>'10:00 AM','phoneNumber'=>'9370182303','firstName'=>'Ravi','lastName'=>'patil','email'=>'ravi00@gmail.com' };
        Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => acc.Id,'wrapper'=> datamap};
        callAPI('saveSlotDetails',jsonMap);
    }

    @IsTest
    static void unitTest5(){
        Account acc =[SELECT Id FROM Account LIMIT 1];
        Map<String ,Object> jsonMap= new Map<String, Object>{'recordId' => acc.Id};
        callAPI('rescheduleCall',jsonMap);
    }

    @IsTest
    static void unitTest6(){
     Test.startTest();
     MobileAppVideoCallAPIService.invalidURI();
     Test.stopTest();
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
        MobileAppVideoCallAPIService.handleVVC(); 
        Test.stopTest();
    }
}