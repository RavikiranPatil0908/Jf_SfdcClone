/**
 * @description       : 
 * @author            : Ravi
 * @group             : 
 * @last modified on  : 10--03--2025
 * @last modified by  : @Ravi
**/
@isTest(SeeAllData=false)
public with sharing class UpdateInternalCaseOwnerTracker {
 
    @testSetup
    public static void setUpData() {
        // Create a test user record
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         String internalticket = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId();
        User objUser = new User(
            Alias = 'newUser', 
            Email = 'ravikiran088@gmail.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'new505user@testorg.com'
        );
        insert objUser;
        // Create a test center record
        //nm_Centers__c center = new nm_Centers__c(Name = 'Banglore', RegistrationClosed__c = false);
        //insert center;
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        objAccount.nm_StudentNo__c='12345678901';
        update objAccount;
        nm_Centers__c objCenter = nmGenericTracker.CreateCenter('Mira Road');
        nm_UserMapping__c testUserMapping = new nm_UserMapping__c(
            nm_User__c = objUser.Id,
            nm_Centers__c = objCenter.Id
        );
        insert testUserMapping;

        // Create test case records
        List<Case> caseRecords = new List<Case>{
            new Case(
                purpose__c = 'Enquiry',
                InternalCategory__c = 'Product',
                InternalSub_Category__c = 'test',
                Status = 'Escalated',
                Description = 'test',
                Subject = 'Product-test',
                CreatedById = objUser.Id,
                recordTypeId =internalticket
            ),
            new Case(
                
                purpose__c = 'Enquiry',
                InternalCategory__c = 'Marketing',
                InternalSub_Category__c = 'Loan Query',
                Status = 'Escalated',
                Description = 'test',
                Subject = 'Marketing-Loan Query',
                CreatedById = objUser.Id,
                recordTypeId =internalticket
            )
        };
        insert caseRecords;

        // Case Round Robin Logic
        Group testGroup = new Group(Name='Admissions Team', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        Map<String,Id> mapOfUserNameVsID = getUserNameVsId();
        List<String> userNames = new List<String>(mapOfUserNameVsID.keySet());
        List<String> userIds = mapOfUserNameVsID.values();

        List<Case_Routing__c> lstCR = new List<Case_Routing__c>();
        Case_Routing__c objCR = new Case_Routing__c();
        objCR.Admission_Sub_Category__c = 'Program Change';
        objCR.isActive__c = true;
        objCR.Queue_Name__c = 'Admissions Team';
        objCR.User__c = String.join(userNames, ';');
        lstCR.add(objCR);

        Case_Routing__c objCR2 = new Case_Routing__c();
        objCR2.Admission_Sub_Category__c = 'Program Change';
        objCR2.isActive__c = true;
        objCR2.Queue_Name__c = 'Admissions Team';
        objCR2.User__c = String.join(userNames, ';');
        lstCR.add(objCR2);

        Case_Routing__c objCR3 = new Case_Routing__c();
        objCR3.isActive__c = true;
        objCR3.Queue_Name__c = 'Admissions Team';
        objCR3.User__c = String.join(userNames, ';');
        lstCR.add(objCR3);
        insert lstCR;

        System.runAs(objUser) {
            // The following code runs as user 'u' 
            Test.startTest();
            String name=UpdateInternalCaseOwner.getLCName();
            System.assertEquals(objUser.Name, name,'LC name match' );
            Test.stopTest();
        }
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

    /**
    * @description 
    * @author Ravi | 07-19-2024 
    **/
    @isTest
    static void testCaseTransfer(){
        // Fetch the case 
        List<Case> CaseRecords = [SELECT Id, InternalCategory__c FROM Case LIMIT 1]; 
        List<Account> lstAcc = [SELECT Id, nm_StudentNo__c FROM Account LIMIT 1]; 
        Test.startTest();
            UpdateInternalCaseOwner.caseTransfer(CaseRecords[0].Id , false , lstAcc[0].nm_StudentNo__c );       
        Test.stopTest();
    }

    
    /**
    * @description 
    * @author Ravi | 07-19-2024 
    **/
    @isTest
    static void testGetProductUser() {
        Test.startTest();
        String result = UpdateInternalCaseOwner.getProductUser('Product', 'Ngasce Exams');
        System.assertEquals('Bhaumik', result, 'The category should be Likesh');
        Test.stopTest();
    }

    @isTest
    static void testCaseTransferAdmissions(){
        // Fetch the case 
        
        Test.startTest();
            user usr = [Select Id from user limit 1]; 
            String internaltkt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId();     
            Case caseRecords1 =  new Case(
                    purpose__c = 'Enquiry',
                    InternalCategory__c = 'Admissions',
                    InternalSub_Category__c = 'test',
                    Status = 'Escalated',
                    Description = 'test',
                    Subject = 'Product-test',
                    CreatedById = usr.Id,
                    recordTypeId =internaltkt
                );
                insert caseRecords1;
            UpdateInternalCaseOwner.caseTransfer(caseRecords1.Id , false , null );       
        Test.stopTest();
    }

    /**
    * @description 
    * @author Ravi | 07-19-2024 
    **/
    @isTest
    static void  testCreateCase(){ 
            user usr = [Select Id from user limit 1]; 
            String internaltkt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Ticket').getRecordTypeId();     
        Case caseRecords1 =  new Case(
                purpose__c = 'Enquiry',
                InternalCategory__c = 'Product',
                InternalSub_Category__c = 'test',
                Status = 'Escalated',
                Description = 'test',
                Subject = 'Product-test',
                CreatedById = usr.Id,
                recordTypeId =internaltkt
            );
                     
        Test.startTest();
        UpdateInternalCaseOwner.createCase(caseRecords1);
        Test.stopTest();
    }   


      /**
    * @description 
    * @author Ravi | 07-19-2024 
    **/
    @isTest
    static void testGetLcName() {
        Test.startTest();
        UpdateInternalCaseOwner.getLCName();
        Test.stopTest();
    }
   
    /**
    * @description 
    * @author @Ravi | 09-11-2024 
    **/
    @isTest
    static void testverifyStudentAccount() {
        List<Account> lstAcc = [SELECT Id, nm_StudentNo__c FROM Account LIMIT 1]; 
        Test.startTest();
        String result = UpdateInternalCaseOwner.verifyStudentAccount(lstAcc[0].nm_StudentNo__c , false);
        UpdateInternalCaseOwner.verifyStudentAccount(lstAcc[0].nm_StudentNo__c , true); 
        Test.stopTest();
    }
    
    /**
    * @description 
    * @author @Ravi | 09-11-2024 
    **/
    @isTest
    static void testtransferAEPReqtoRespectiveLC() {
      Case CaseRecords = [SELECT Id, InternalCategory__c FROM Case LIMIT 1]; 
        List<Account> lstAcc = [SELECT Id, nm_StudentNo__c FROM Account LIMIT 1];
        Test.startTest();
        UpdateInternalCaseOwner.transferAEPReqtoRespectiveLC(CaseRecords, true, lstAcc[0].nm_StudentNo__c );
        UpdateInternalCaseOwner.transferAEPReqtoRespectiveLC(CaseRecords, false, lstAcc[0].nm_StudentNo__c );
        Test.stopTest();
    }
   
}