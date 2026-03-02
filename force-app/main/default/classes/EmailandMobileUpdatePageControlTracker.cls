/**
 * @description       : 
 * @author            : @Shailesh
 * @group             : 
 * @last modified on  : 16-12-2025
 * @last modified by  : @Shailesh
**/
@isTest(SeeAllData = false)
public without sharing class EmailandMobileUpdatePageControlTracker {
    public EmailandMobileUpdatePageControlTracker() { 

    }

@TestSetup
static void makeData(){
    Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.Status = 'Admission Fee Paid';
        update objLead ;
       
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
}


@IsTest
static void test1(){
     Lead testLead = [SELECT Id, Name, MobilePhone, Email, nm_RegistrationNo__c,nm_InformationCenter__c  FROM Lead LIMIT 1];
    Test.startTest();
    EmailandMobileUpdatePageController obj = new EmailandMobileUpdatePageController();
    obj.setObjectType('Lead');
    obj.setRecordId(testLead.Id);
    //obj.setOptions();
    obj.doUpdatefield();
    obj.getRecordId();
    obj.getObjectType();
    obj.objOTP.isSuccess = true;
    obj.getOtpSendStatus();
    obj.sendOTP();
    obj.verifyOTP();
    Test.stopTest();
    
}
@IsTest
static void test2(){
     Account testAcc = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c FROM Account LIMIT 1];
    Test.startTest();
    EmailandMobileUpdatePageController obj = new EmailandMobileUpdatePageController();
    obj.objectType = 'Account';
    obj.setObjectType('Account');
    obj.recordId = testAcc.Id;
    obj.setRecordId(testAcc.Id);
    //obj.setOptions();
    obj.selectedOption = 'Email';
    obj.doUpdatefield();
    obj.objOTP.isSuccess = true; 
    obj.sendOTP();
    obj.verifyOTP();
    Test.stopTest();
    
}
    @IsTest
static void test3(){
     Account testAcc = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c FROM Account LIMIT 1];
    Test.startTest();
    EmailandMobileUpdatePageController obj = new EmailandMobileUpdatePageController();
    //obj.updateFieldvalue = 'amit.kumar@saasfocus.com';
    obj.emailFieldvalue = 'amit.kumar@saasfocus.com';
    obj.objectType = 'Lead';
    obj.setObjectType('Lead');
    obj.selectedOption = 'Email';
    obj.doUpdatefield();
    obj.recordId = testAcc.Id;
    obj.setRecordId(testAcc.Id);
    //obj.setOptions();
    obj.objOTP.isSuccess = true;
    obj.sendOTP();
    obj.verifyOTP();
    Test.stopTest();
    
}
        @IsTest
static void test4(){
     Account testAcc = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c FROM Account LIMIT 1];
    Test.startTest();
    EmailandMobileUpdatePageController obj = new EmailandMobileUpdatePageController();
    //obj.updateFieldvalue = '1234567890';
    obj.mobileFieldvalue = '1234567890';
    obj.objectType = 'Account';
    obj.setObjectType('Account');
    obj.selectedOption = 'Mobile';
    obj.recordId = testAcc.Id;
    obj.setRecordId(testAcc.Id);
    //obj.setOptions();
    obj.doUpdatefield();
    obj.objOTP.isSuccess = true;
    obj.sendOTP();
    obj.verifyOTP();
    //SendEmailForOTP.callEmailAlertFlow('hf54h655hg','15fg5h56hfh');
    Test.stopTest();
    
}
            @IsTest
static void test5(){
     Account testAcc = [SELECT Id, Name, PersonContactId, PersonMobilePhone, PersonEmail, nm_RegistrationNumber__c,nm_Centers__c FROM Account LIMIT 1];
    Test.startTest();
    EmailandMobileUpdatePageController obj = new EmailandMobileUpdatePageController();
    obj.mobileFieldvalue = '1234567890';
    obj.objectType = 'Account';
    obj.setObjectType('Account');
    obj.selectedOption = 'Mobile';
    obj.recordId = testAcc.Id;
    obj.setRecordId(testAcc.Id);
    obj.doUpdatefield();
    obj.objOTP.isSuccess = true;
    obj.objOTP.isEmailMobileChange =false;
    obj.sendOTP();
    obj.verifyOTP();
    //SendEmailForOTP.callEmailAlertFlow('hf54h655hg','15fg5h56hfh');
    Test.stopTest();
    
}
}