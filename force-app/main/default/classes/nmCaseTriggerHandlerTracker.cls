/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-04-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class nmCaseTriggerHandlerTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    public static void setUpData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Case> lstCase = loadData();
        insert lstCase;
    }

    @isTest 
    static void unitTest1(){ 
        List<Account> lstAccount = [SELECT id,PersonEmail FROM Account LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new RestMock());
            // nmCaseTriggerHandler.lstKeyWords = (List<Case_Keyword__mdt>) JSON.deserialize(getMetaData(), List<Case_Keyword__mdt>.class);
            Case objcase = new Case();
            objcase.StudentZone_QueryId__c ='2261';
            objcase.SuppliedEmail = lstAccount[0].PersonEmail;
            objcase.Description = 'Zero Books Admission';
            // objcase.nm_Category__c = 'Academics';
            // objcase.sub_categories__c = 'Acknowledgement';
            insert objcase;
            CaseComment  caseComment1 = new CaseComment(ParentId = objcase.Id, CommentBody = 'test');
            insert caseComment1;
            update new CaseComment(Id = caseComment1.Id, CommentBody = 't');
            delete new CaseComment(Id = caseComment1.Id);
            objcase.Response_To_Post_My_Query__c = 'Testing';
            update objcase;
        Test.stopTest();
    }

    @isTest 
    static void unitTest2(){ 
        List<Account> lstAccount = [SELECT id,PersonEmail FROM Account LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new RestMock());
            // nmCaseTriggerHandler.lstKeyWords = (List<Case_Keyword__mdt>) JSON.deserialize(getMetaData(), List<Case_Keyword__mdt>.class);
            List<Case> lstCase = new List<Case>();

            Case objcase = new Case();
            objcase.StudentZone_QueryId__c ='2261';
            objcase.SuppliedEmail = lstAccount[0].PersonEmail;
            objcase.Description = 'Zero Assignment';
            lstCase.add(objcase);

            Case objcase2 = new Case();
            objcase2.StudentZone_QueryId__c ='2261';
            objcase2.SuppliedEmail = lstAccount[0].PersonEmail;
            objcase2.Description = 'Books';
            lstCase.add(objcase2);
            insert lstCase;

            List<Case> lstCa = [SELECT Id, nm_Category__c, Student_Category__c, Description FROM Case];
            nmCaseTriggerHandler nmCaseTriggerHandler1 = new nmCaseTriggerHandler();

            // nmCaseTriggerHandler1.setCategory(lstCa);   
            nmCaseTriggerHandler.updatePostMyQueryAnsOnStuentZone(String.valueOf(lstCa[0].Id) );
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        List<Case> lstCase = [SELECT id,OwnerId FROM Case WHERE StudentZone_QueryId__c='2261' LIMIT 1];
        Test.startTest();
            if(lstCase.size() > 0) {
                Group testGroup = [SELECT id FROM Group WHERE Name='test group' AND Type='Queue' LIMIT 1];
                // To update.
                lstCase[0].OwnerId = testGroup.Id;
                update lstCase[0];
            }
        Test.stopTest();
    }

    @isTest
    static void unitTest4() {
        List<Case> lstCase = [SELECT id,OwnerId FROM Case WHERE StudentZone_QueryId__c='2264' LIMIT 1];
        Test.startTest();
            if(lstCase.size() > 0) {
                Test.setMock(HttpCalloutMock.class,new RestMock());
                lstCase[0].Response_To_Post_My_Query__c = 'test';
                update lstCase[0];
            }
        Test.stopTest();
    }

    @isTest 
    static void unitTest5(){ 
        List<Lead> lstLead = [SELECT id,Email FROM Lead LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class,new RestMock());
            Case objcase = new Case();
            objcase.StudentZone_QueryId__c ='2261';
            objcase.SuppliedEmail = lstLead[0].Email;
            objcase.Description = 'Zero Books Admission';
            insert objcase;
        Test.stopTest();
    }

    @isTest 
    static void unitTest6(){ 
        List<Lead> lstLead = [SELECT id,Email FROM Lead LIMIT 1];
        List<Account> lstAccount = [SELECT Id,PersonContactId,PersonEmail FROM Account LIMIT 1];
        // List<Case__c> lstTat = [SELECT id,]
        List<Case> lstCase = new List<Case>();
        Test.startTest();
            String ticketing = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Tool').getRecordTypeId();
            Case objcase = new Case();
            objcase.Expected_Close_Date__c = null;
            objcase.recordTypeId = ticketing;
            objcase.StudentZone_QueryId__c ='2261';
            objcase.SuppliedEmail = lstLead[0].Email;
            objcase.Description = 'Zero Books Admission';
            objcase.Student_Category__c='Admissions';
            objcase.Student_Sub_Categories__c ='Program Change';
            // objcase.Subject='Test';
            lstCase.add(objcase);

            // objcase.nm_Category__c='Admissions'; 
            // objcase.sub_categories__c='Admission - Payment issue';
            // objcase.Status='New'; 
            // objcase.Tech_Issue__c='No'; 
            // objcase.Student_No__c='77119958556'; 
            // objcase.Escalation_Level__c=0;

            Case objcase2 = new Case();
            objcase2.Expected_Close_Date__c = null;
            objcase2.recordTypeId = ticketing;
            objcase2.StudentZone_QueryId__c ='2261';
            objcase2.SuppliedEmail = lstLead[0].Email;
            objcase2.Description = 'Zero Books Admission';
            objcase2.Student_Category__c='Academics';
            objcase2.Student_Sub_Categories__c = 'Faculty feedback';
            objcase2.Subject='Test';
            lstCase.add(objcase2);

            Case objcase3 = new Case();
            objcase3.Expected_Close_Date__c = null;
            objcase3.AccountId = lstAccount[0].Id;
            objcase3.ContactId = lstAccount[0].PersonContactId;
            objcase3.recordTypeId = ticketing;
            objcase3.StudentZone_QueryId__c ='2261';
            objcase3.SuppliedEmail = lstAccount[0].PersonEmail;
            objcase3.Description = 'Zero Books Admission';
            objcase3.Student_Category__c='Academics';
            objcase3.Student_Sub_Categories__c = 'Faculty feedback';
            objcase3.Subject='Test';
            System.debug('insert Case');
            System.debug(objcase3);
            lstCase.add(objcase3);

            insert lstCase;
            System.debug('inserted Case');
            System.debug(lstCase);
        Test.stopTest();
    }

    @isTest
    static void unitTest7() {
        List<Case> lstCase = [SELECT id,OwnerId FROM Case WHERE StudentZone_QueryId__c='2265' LIMIT 1];
        Test.startTest();
            if(lstCase.size() > 0) {
                Group testGroup = [SELECT id FROM Group WHERE Name='test group' AND Type='Queue' LIMIT 1];
                // To update.
                lstCase[0].OwnerId = testGroup.Id;
                update lstCase[0];
            }
        Test.stopTest();
    }

    public static Map<String,Id> getUserNameVsId() {
        Map<String,Id> mapOfNameVsUserId = new Map<String,Id>();
        List<User> lstUsers = [SELECT Id,Name,IsActive FROM User WHERE ((Profile.Name='Head Office Community' AND Profile.UserLicense.Name='Partner Community') OR Profile.Name='Head Office') AND IsActive=true];
        for (User objUser : lstUsers) {
            String userName = objUser.Name == 'Admission Dept.' ? 'Manasvi Malve' : objUser.Name;
            mapOfNameVsUserId.put(userName,objUser.Id);
        }
        return mapOfNameVsUserId;
    }

    public static List<Case> loadData() {
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('Mumbai');
        
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);

        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_Tagged_Pricebook__c = null;
        objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
        objopp.Down_Payment_Made__c = true;
        objopp.Loan_Type__c = 'Propelld';
        update objopp;

        nmGenericTracker.CreateOpportunityLineItem(objopp);
        Product2 semesterproduct = nmGenericTracker.CreateSemesterProduct(objopp);
        Product2 productvs1 = nmGenericTracker.CreateSemesterProductvs2(objopp.nm_Program__c,1);
        
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

        // Case Round Robin Logic
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        // nmCaseTriggerHandler objHandler = new nmCaseTriggerHandler();
        Map<String,Id> mapOfUserNameVsID = getUserNameVsId();
        List<String> userNames = new List<String>(mapOfUserNameVsID.keySet());
        List<String> userIds = mapOfUserNameVsID.values();

        List<Case_Routing__c> lstCR = new List<Case_Routing__c>();
        Case_Routing__c objCR = new Case_Routing__c();
        objCR.Admission_Sub_Category__c = 'Program Change';
        objCR.isActive__c = true;
        objCR.Queue_Name__c = 'test group';
        objCR.User__c = String.join(userNames, ';');
        lstCR.add(objCR);

        Case_Routing__c objCR2 = new Case_Routing__c();
        objCR2.Admission_Sub_Category__c = 'Program Change';
        objCR2.isActive__c = true;
        objCR2.Queue_Name__c = 'test group';
        objCR2.User__c = String.join(userNames, ';');
        lstCR.add(objCR2);

        Case_Routing__c objCR3 = new Case_Routing__c();
        objCR3.isActive__c = true;
        objCR3.Queue_Name__c = 'test group';
        objCR3.User__c = String.join(userNames, ';');
        lstCR.add(objCR3);
        insert lstCR;

        
        List<Case> lstCase = new List<Case>();
        // To insert
        Case objcase = new Case();
        objcase.StudentZone_QueryId__c ='2261';
        objcase.SuppliedEmail = objAccount.PersonEmail;
        objcase.Description = 'Zero Books Admission';
        objcase.nm_Category__c = 'Admissions';
        objcase.sub_categories__c = 'Program Change';
        lstCase.add(objcase);

        Case objcase2 = objcase.clone();
        objcase2.OwnerId = userIds[0];
        objcase2.StudentZone_QueryId__c ='2262';
        lstCase.add(objcase2);

        Case objcase3 = objcase.clone();
        objcase3.StudentZone_QueryId__c ='2263';
        objcase3.OwnerId = userIds[1];
        lstCase.add(objcase3);

        Case objcase4 = objcase.clone();
        objcase4.nm_Category__c = 'Student Support';
        objcase4.sub_categories__c = 'Others';
        objcase4.OwnerId = userIds[0];
        objcase4.StudentZone_QueryId__c ='2264';
        lstCase.add(objcase4);

        Case objcase5 = objcase.clone();
        objcase5.nm_Category__c = 'Student Support';
        objcase5.sub_categories__c = 'Others';
        objcase5.OwnerId = userIds[0];
        objcase5.Previous_Owner__c = userIds[1];
        objcase5.StudentZone_QueryId__c ='2265';
        lstCase.add(objcase5);

        return lstCase;
    }
}