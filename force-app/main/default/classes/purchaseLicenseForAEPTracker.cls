/**
 * @File Name          : purchaseLicenseForAEPTracker.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 03-11-2023
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    21/3/2020   shubhranshu     Initial Version
**/
@isTest
public without sharing class purchaseLicenseForAEPTracker {

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
        nm_Centers__c center = nmGenericTracker.CreateCenter('Mumbai');
        nm_UserMapping__c usermapping = new nm_UserMapping__c();
        usermapping.nm_User__c = UserInfo.getUserId();
        usermapping.nm_Centers__c = center.id;
        usermapping.nm_Head__c  = true;
        insert usermapping;
        Counsellor_Profile__c cp = new Counsellor_Profile__c();
        cp.First_Name__c = 'test';
        cp.Last_Name__c = 'test';
        cp.Employee_Image_URL__c = 'www.google.com';
        cp.Email__c = 'test@gmail.com';
        cp.MobilePhone__c = '8888111123';
        cp.AEP_Name__c = center.id;
        insert cp;
        IC_Payment__c icpay = new IC_Payment__c ();
        icpay.Payment_Month__c = 'November';
        icpay.Payment_Year__c = '2020';
        icpay.Amount__c = 288955.00;
        icpay.Payment_Due_Date__c = Date.today();
        icpay.Centers__c = center.id;
        icpay.Share_Processed__c = false;
        insert icpay;
        IC_Payment_Transaction__c ip = new IC_Payment_Transaction__c ();        
        ip.Amount__c = 500000;
        ip.Narration__c = 'test';
        ip.IC_Payment__c = icpay.Id;   
        ip.Transaction_Type__c = 'Admission Commision - Credit';
        ip.Due_Date__c = icpay.Payment_Due_Date__c;
        ip.Date__c = Date.today();
        insert ip;
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Case objCase = new Case();
        objCase.Subject = 'Complaint regarding Revised book of CRM';
        objCase.Description = 'Dear Sir/Madam, This is a complaint regarding Revised book of CRM ';
        objCase.Account = objAccount;
        objCase.SuppliedEmail = objAccount.PersonEmail;
        insert objCase;
       
    }

    public static testMethod void purchaseLicenseForAEPTest(){

        
        Account objAccount = [SELECT Id,nm_RegistrationNumber__c FROM Account LIMIT 1];      
        nm_Centers__c center = [select Id,Name,SAP_vendor_code__c,SAP_Customer_Code__c,Password__c,Email__c from nm_Centers__c where recordtype__c='Information Center' limit 1];
        nm_UserMapping__c usermapping = [select Id ,Name ,nm_User__c , nm_Centers__c ,nm_Head__c from  nm_UserMapping__c LIMIT 1];
        Counsellor_Profile__c cp = [select Id,Name, Salutation__c, First_Name__c, Middle_Name__c, Last_Name__c,Counselor_Image__c,Employee_Image_URL__c,Email__c,MobilePhone__c FROM  Counsellor_Profile__c LIMIT 1];
        IC_Payment__c icp = [select id,Payment_Month__c,Payment_Year__c,Amount__c,Payment_Due_Date__c,Centers__c,nm_CenterName__c ,Net_Amount__c,Payment_Month_and_Year_to_Date__c from IC_Payment__c LIMIT 1];
        Case objCase = [Select id from Case limit 1];
        Test.startTest();
        purchaseLicenseForAEPController.getCenterUserData(UserInfo.getUserId());
        purchaseLicenseForAEPController.getCenterUserDatav2(UserInfo.getUserId());
        purchaseLicenseForAEPController.getAEPCenterData(center.Id);
        purchaseLicenseForAEPController.getCPDetails(center.Id);
        purchaseLicenseForAEPController.getCPDetails(center.Id);
        Contact contact = new Contact();
        contact.FirstName = cp.First_Name__c;
        contact.LastName = cp.Last_Name__c;
        contact.AccountId = null;
        contact.Email = cp.Email__c;
        contact.Phone = cp.MobilePhone__c;
        contact.LeadSource = 'Web';
        contact.Counselor_Profile__c = cp.id;
        List<Contact> lstContactInsert = new List<Contact>();
        lstContactInsert.add(contact);
        purchaseLicenseForAEPController.saveContacts(lstContactInsert);
        purchaseLicenseForAEPController.saveCentersDetails(3,center.Id);
        // purchaseLicenseForAEPController.rollbackCentersDetails(0,center.Id);
        purchaseLicenseForAEPController.DebitShareEntry(center.Id,18990);
        purchaseLicenseForAEPController.rollbackDebitShareEntry(center.Id);
        String cpJson = '{"a1jO0000001HpwBIAS":"Manager"}';
        purchaseLicenseForAEPController.saveCentersDetailsForOnline(3,202.05,cpJson,center.Id);
        purchaseLicenseForAEPController.getNoOfMonths();
        purchaseLicenseForAEPController.sendNotificationEmail(center.Name, '3','18990','10.72',lstContactInsert,'www.google.com','IC share');
        purchaseLicenseForAEPController.getDeletedLeads();
        purchaseLicenseForAEPController.getEmailMessage(objCase.id);
        purchaseLicenseForAEPController.getLeads();
        Test.stopTest();
    }

    public static testMethod void aepShares() {
        nm_Centers__c center = [select Id,Name,SAP_vendor_code__c,SAP_Customer_Code__c,Password__c,Email__c from nm_Centers__c where recordtype__c='Information Center' limit 1];
        nm_UserMapping__c usermapping = [select Id ,Name ,nm_User__c , nm_Centers__c ,nm_Head__c from  nm_UserMapping__c LIMIT 1];
        IC_Payment__c icp = [select id,Payment_Month__c,Payment_Year__c,Amount__c,Payment_Due_Date__c,Centers__c,nm_CenterName__c ,Net_Amount__c,Payment_Month_and_Year_to_Date__c from IC_Payment__c LIMIT 1];
        Test.startTest();
            purchaseLicenseForAEPController.PaymentValueWrapper objWrapper = new purchaseLicenseForAEPController.PaymentValueWrapper();
            objWrapper.fromMonthYear = '2020-11';
            objWrapper.toMonthYear = '2020-11';
            objWrapper.centerId = center.Id;
            purchaseLicenseForAEPController.getPaymentDetails(objWrapper);
            purchaseLicenseForAEPController.getArchiveLinkforDocuments(icp.Id);
        Test.stopTest();
    }

}