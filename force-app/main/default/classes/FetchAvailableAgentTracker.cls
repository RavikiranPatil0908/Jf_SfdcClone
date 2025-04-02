/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 10-05-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class FetchAvailableAgentTracker {

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

    @TestSetup
    static void makeData(){ 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Case> lstCase = loadData();
        insert lstCase;
    }

    @isTest
    static void unitTest1(){
        List<Case> lst = [SELECT id FROM Case LIMIT 1];
        Id currentUserId = UserInfo.getUserId();
        List<User> lstUsers = [SELECT id FROM User WHERE Id!=:currentUserId AND isActive=TRUE LIMIT 1];
        Test.StartTest();
            FetchAvailableAgent.OmniChannelRequest requestParam = new FetchAvailableAgent.OmniChannelRequest();
            requestParam.caseId = lst[0].id;
            List<FetchAvailableAgent.OmniChannelRequest> requestParamlst = new List<FetchAvailableAgent.OmniChannelRequest>{requestParam};
            List<FetchAvailableAgent.OmniChannelResponse> responseParamlst = FetchAvailableAgent.getLeastOwnerId(requestParamlst);
            FetchAvailableAgent.getAlreadyOwnerId(null);
            Set<Id> setOfId1 = new Set<Id>{currentUserId, lstUsers[0].Id};
            Set<Id> setOfId2 = new Set<Id>{currentUserId};
            Map<String,Object> obj = new Map<String,Object>{'UserId' => currentUserId};
            FetchAvailableAgent.getUserId(setOfId1, new List<Map<String,Object>>{obj});
            FetchAvailableAgent.getUserId(setOfId2, new List<Map<String,Object>>{obj});
		Test.StopTest();
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

    public static Map<String,Id> getUserNameVsId() {
        Map<String,Id> mapOfNameVsUserId = new Map<String,Id>();
        List<User> lstUsers = [SELECT Id,Name,IsActive FROM User WHERE ((Profile.Name='Head Office Community' AND Profile.UserLicense.Name='Partner Community') OR Profile.Name='Head Office') AND IsActive=true];
        for (User objUser : lstUsers) {
            String userName = objUser.Name == 'Admission Dept.' ? 'Manasvi Malve' : objUser.Name;
            mapOfNameVsUserId.put(userName,objUser.Id);
        }
        return mapOfNameVsUserId;
    }
}