/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 20-12-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)  
public class CallBackUrlWebhookTracker {

    @TestSetup    
    public static void makeData(){  

        List<Case__c> lstTat = new List<Case__c>();
        Case__c objTAT = new Case__c();
        objTAT.Name = 'Admissions';
        objTAT.TAT__c = 3;
        lstTat.add(objTAT);

        Case__c objTAT2 = new Case__c();
        objTAT2.Name = 'Academics';
        objTAT2.TAT__c = 2;
        lstTat.add(objTAT2);
        insert lstTat;
        
        nm_Program__c prog = new nm_Program__c(Name='MBA(WX) - DM', nm_TotalSemesters__c=5, PVM__c=30);
        insert prog;
        Id personAccRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acc = new Account(FirstName='Test123', LastName='abc', RecordTypeId = personAccRecordTypeId, nm_StudentNo__c='77119958556', nm_Program__c=prog.Id , PersonMobilePhone='8652532023',PersonEmail='priyankakorade22@gmail.com');
        insert acc;
    	String ticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
    
        Case c1 = new Case(Subject='Test', Status='New', Tech_Issue__c='No', Student_Category__c='Admissions', Student_No__c='77119958556', Escalation_Level__c=0, RecordTypeId=ticket);
        insert c1;
        CaseComment cc = new CaseComment(CommentBody='Test', ParentId=c1.Id);
        insert cc;
        ContentVersion cvf = new ContentVersion(Title='Doc1', FirstPublishLocationId=c1.Id, Comment_Id__c=cc.Id, PathOnClient='Doc1.pdf', VersionData=Blob.valueOf('Test Content Version Data'));
        insert cvf;

        Task objTask = new Task(Subject='Call Scheduling',Status='Not Started',Priority='Normal',Escalation_Level__c='1',WhatId=c1.id,Call_date__c=System.today(),Customer_number__c='8800000000',Student_Name__c='Test',Case__c=c1.id,Student_Email__c='test@gmail.com');
        insert objTask;
    } 

    @isTest     
    static void unitTestSuccess(){   
        List<Task> scope = [SELECT id,Customer_number__c FROM Task LIMIT 1];
        System.debug('scope ==>'+scope[0]);
        Test.startTest();
            CallBackUrlWebhook.lstCampaigns = (List<Call_Campaign__mdt>) JSON.deserialize(getMetaData(), List<Call_Campaign__mdt>.class);
            Map<String,String> mapOfResponse = new Map<String,String>();
            mapOfResponse.put('CallerID',scope[0].Customer_number__c);
            mapOfResponse.put('Status','Answered');
            mapOfResponse.put('CallDuration','01:24:10');
            mapOfResponse.put('Duration','00:30:00');
            mapOfResponse.put('UserName',scope[0].id);
            mapOfResponse.put('Type','Outbound');
            mapOfResponse.put('UUI',scope[0].id);
            mapOfResponse.put('StartTime',String.valueOf(System.now()));
            mapOfResponse.put('CampaignName', CallBackUrlWebhook.lstCampaigns[0].MasterLabel);
            mapOfResponse.put('AgentName','abc');
            mapOfResponse.put('CampaignStatus','ONLINE');
            mapOfResponse.put('DialStatus','answered');
            mapOfResponse.put('Location','akc');
            mapOfResponse.put('Skill','xyz');
            mapOfResponse.put('TransferredTo','abs');
            mapOfResponse.put('ConfDuration','01:30:10');
            mapOfResponse.put('EndTime','2017-05-25 15:46:05');
            String myJSON=JSON.serialize(mapOfResponse);
            System.debug('myJSON--'+myJSON);    
            requestData(myJSON,'POST');
            CallBackUrlWebhook.callDetails();
        Test.stopTest();    
    }

    @isTest     
    static void unitTestFail(){   
        List<Task> scope = [SELECT id,Customer_number__c FROM Task LIMIT 1];
        Test.startTest();
            CallBackUrlWebhook.lstCampaigns = (List<Call_Campaign__mdt>) JSON.deserialize(getMetaData(), List<Call_Campaign__mdt>.class);
            Map<String,String> mapOfResponse = new Map<String,String>();
            mapOfResponse.put('CallerID',scope[0].Customer_number__c);
            mapOfResponse.put('callDateTime',String.valueOf(System.now()));
            mapOfResponse.put('Status','Answered');
            mapOfResponse.put('CallDuration','00:24:00');
            mapOfResponse.put('Duration','00:30:00');
            mapOfResponse.put('UUI','');
            mapOfResponse.put('CampaignName', CallBackUrlWebhook.lstCampaigns[0].MasterLabel);
            mapOfResponse.put('AgentName','abc');
            mapOfResponse.put('CampaignStatus','ONLINE');
            mapOfResponse.put('DialStatus','answered');
            mapOfResponse.put('Location','akc');
            mapOfResponse.put('Skill','xyz');
            mapOfResponse.put('TransferredTo','abs');
            mapOfResponse.put('ConfDuration','01:30:10');
            mapOfResponse.put('EndTime','2017-05-25 15:46:05');
            String myJSON=JSON.serialize(mapOfResponse);
            System.debug('myJSON--'+myJSON);    
            requestData(myJSON,'POST');
            CallBackUrlWebhook.callDetails();
        Test.stopTest();    
    }

    static void unitTestFail2(){   
        List<Task> scope = [SELECT id,Customer_number__c FROM Task LIMIT 1];
        Test.startTest();
            Map<String,String> mapOfResponse = new Map<String,String>();
            mapOfResponse.put('CallerID','000000000');
            mapOfResponse.put('callDateTime',String.valueOf(System.now()));
            mapOfResponse.put('Status','Answered');
            mapOfResponse.put('CallDuration','00:24:00');
            mapOfResponse.put('Duration','00:30:00');
            mapOfResponse.put('Type','Outbound');
            mapOfResponse.put('UUI','');
            mapOfResponse.put('AgentName','abc');
            mapOfResponse.put('CampaignStatus','ONLINE');
            mapOfResponse.put('DialStatus','answered');
            mapOfResponse.put('Location','akc');
            mapOfResponse.put('Skill','xyz');
            mapOfResponse.put('TransferredTo','abs');
            mapOfResponse.put('ConfDuration','01:30:10');
            mapOfResponse.put('EndTime','2017-05-25 15:46:05');
            String myJSON=JSON.serialize(mapOfResponse);
            System.debug('myJSON--'+myJSON);    
            requestData(myJSON,'POST');
            CallBackUrlWebhook.callDetails();
        Test.stopTest();    
    }

    public static void requestData(String myJson,String requestMethod) {
        RestResponse response = new RestResponse();
        RestRequest request = new RestRequest();
        request.requestURI = System.Label.Site_Url+'services/apexrest/callDetails/';
        request.requestBody = Blob.valueof(myJSON);
        request.httpMethod = requestMethod;
        RestContext.request = request;
        RestContext.response = response;
    }

    public static String getMetaData() { 
        return '[{"MasterLabel":"Test_Test_Campaign"}]';
    }

}