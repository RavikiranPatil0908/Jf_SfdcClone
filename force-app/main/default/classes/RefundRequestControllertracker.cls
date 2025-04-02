/**
 * @File Name          : RefundRequestControllertracker (Sandbox).cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 08-17-2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    10/8/2019, 1:19:30 PM   @BK     Initial Version
**/
@isTest(SeeAllData=false)
public class RefundRequestControllertracker{
   
    @TestSetUp
    public static void setUpData(){
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('BillDeskRefundResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Counsellor_Profile__c objcounselorprofile = new Counsellor_Profile__c();
        objcounselorprofile.First_Name__c = 'fagu';
        objcounselorprofile.Middle_Name__c = 'dsafdsf';
        objcounselorprofile.Employee_Image_URL__c='www.gmail.com';
        objcounselorprofile.Employee_Sign_URL__c='www.gmail.com';
        objcounselorprofile.Linked_URL__c='https://www.linkedin.com/in/steve-brett-79534517?trk=org-employees';
        insert objcounselorprofile;
        
        nmSerialNo__c objSerial = new nmSerialNo__c();
        objSerial.nm_MaxGenratedNo__c=122355;
        objSerial.nm_name__c= 'Reference Number';
        insert objSerial;
         
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        objopp.nm_Year__c = 2017;
        objopp.nm_Session__c = 'January';
        update objOpp;
        nmRefund_Payment__c objRefund = new nmRefund_Payment__c();
        objRefund.nm_Amount__c = 200;
        objRefund.nm_Payment_Status__c = 'Refund Initiated';      
        objRefund.Opportunity__c = objopp.id;
        objRefund.Account__c = objAccount.id;
        objRefund.nm_Transaction_Date__c = system.today();
        objRefund.Reason_For_Refund__c = 'Test';
        objRefund.Refund_transfer_Mode__c = 'Same A/c from which payment was made';
        objRefund.Type_of_Refund__c = 'Admission Rejected';
        objRefund.Status__c = 'Application Send to Student';
        insert objRefund;
        
        nm_Payment__c payment1 = nmGenericTracker.CreatePaymentRecordForOpportunity(objOpp,'Registration');
        nm_Payment__c payment2 = nmGenericTracker.CreatePaymentRecordForOpportunity(objOpp,'Admission');
        
        Blob b = Blob.valueOf('Test Data');
        Attachment attach = new Attachment();
        attach.ParentId = objRefund.id;
        attach.name = 'Refund_'+objAccount.nm_RegistrationNumber__c+'.pdf';
        attach.body = b;
        attach.description = 'Refund Request';
        attach.OwnerId = UserInfo.getUserId();
        attach.IsPrivate = false;
        insert attach;
        
        Blob b2 = Blob.valueOf('Test Data');
        Attachment attach2 = new Attachment();
        attach2.ParentId = objcounselorprofile.id;
        attach2.name = 'Profile image';
        attach2.IsPrivate = false;
        attach2.body = b2;
        insert attach2;

        Calender__c objCal = new Calender__c();
        objCal.Category__c = 'Admission';
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2017;
        objCal.Session_End_Date__c = system.today()+1;
        objCal.Last_Date_for_Cancellation__c = system.today()+1;
        objCal.FinalDateForCancellation__c = system.today()+2;
        // objCal.nm_Type__c = 'Certificate Programs';
        insert objCal;
    }
    
    public static testmethod void unitTest(){   
         
        List<Counsellor_Profile__c> lstCounsellor = [select id from Counsellor_Profile__c where First_Name__c = 'fagu'];
        List<nmRefund_Payment__c> lstRefund = [select id from nmRefund_Payment__c where nm_Payment_Status__c = 'Refund Initiated'];
        List<Attachment> lstAttachment = [select id,body,Name,description,ParentId from Attachment where Description = 'Refund Request'];
        List<Attachment> lstAttachment2 =  [select id,body,Name,description,ParentId from Attachment where name = 'Profile Image'];
        
        Test.startTest();
            PageReference pageRef = Page.Refund;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Profileid',lstCounsellor[0].id);
            ApexPages.currentPage().getParameters().put('id',lstRefund[0].id);
            RefundRequestController controller = new RefundRequestController();
            controller.attachment =  lstAttachment[0];
            controller.getReason();
            controller.SaveDetail();
            controller.closePopup();
            controller.showPopup();
            // controller.uploadSignature();
            controller.upload();
            update new nmRefund_Payment__c(Id = lstRefund[0].id, Status__c = 'Application Send to Student');
            controller.saveNEFTDetails();
        Test.stopTest();
    }
    
    public static testMethod void unitTest2() {
        Calender__c objCalendar = [SELECT id, nm_Type__c FROM Calender__c WHERE Session__c = 'January' LIMIT 1];
        objCalendar.nm_Type__c = 'Certificate Programs';
        update objCalendar;
        List<Counsellor_Profile__c> lstCounsellor = [select id from Counsellor_Profile__c where First_Name__c = 'fagu'];
        List<nmRefund_Payment__c> lstRefund = [select id from nmRefund_Payment__c where nm_Payment_Status__c = 'Refund Initiated'];
        List<Attachment> lstAttachment = [select id,body,Name,description,ParentId from Attachment where name = 'Profile image'];
        
        Test.startTest();
            PageReference pageRef = Page.CounselorProfileImage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Profileid',lstCounsellor[0].id);
            ApexPages.currentPage().getParameters().put('id',lstRefund[0].id);
            RefundRequestController controller = new RefundRequestController();
            controller.attachment = lstAttachment[0];
            controller.attachment.id = null;
            controller.attachment.ParentId = null;
            controller.studentSignatureDocument = 'www.google.com';
            controller.NameOfAccountHolder = 'www.google.com';
            controller.uploadCounselor();
            controller.saveStudentSignature();
            controller.switchButtonName();
            controller.showModalPopupHandler();
            controller.hideModalPopupHandler();
            controller.getBearToken();
            controller.nocAgreed();
            controller.onHandleVerifyBankDetails();
        Test.stopTest();
    }

    public static testMethod void unitTest31() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        RefundRequestController controller = new RefundRequestController();
        controller.getBankVerification('a', 'b', 'c', 'd');
        Test.stopTest();
    }

    public static testMethod void unitTest3() {
        List<Counsellor_Profile__c> lstCounsellor = [select id from Counsellor_Profile__c where First_Name__c = 'fagu'];
        List<nmRefund_Payment__c> lstRefund = [select id from nmRefund_Payment__c where nm_Payment_Status__c = 'Refund Initiated'];
        List<Attachment> lstAttachment = [select id,body,Name,description,ParentId from Attachment where Description = 'Refund Request'];
        List<Attachment> lstAttachment2 =  [select id,body,Name,description,ParentId from Attachment where name = 'Profile Image'];
        
        Test.startTest();
            PageReference pageRef = Page.Refund;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Profileid',lstCounsellor[0].id);
            ApexPages.currentPage().getParameters().put('id',lstRefund[0].id);
            RefundRequestController controller = new RefundRequestController();

            // controller.uploadSignature();
            
            controller.attachment =  lstAttachment[0];
            controller.refund.Status__c = 'Application Rejected';
            // controller.uploadSignature();

            controller.attachment =  lstAttachment[0];
            controller.refund.Status__c = 'Application Accepted';
            // controller.uploadSignature();

            controller.selectedReport = 'test';
            controller.ChooseProgram = 'Diploma Programs';
            controller.Session = 'July';
            controller.Year = '2021';
            controller.getVFPageName();

        Test.stopTest();
        
    }


    public static testMethod void unitTest4() {
        List<nmRefund_Payment__c> lstRefund = [select id from nmRefund_Payment__c where nm_Payment_Status__c = 'Refund Initiated'];
        List<Attachment> lstAttachment = [select id,body,Name,description,ParentId from Attachment where Description = 'Refund Request'];
        
        Test.startTest();
            PageReference pageRef = Page.RefundUploader;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstRefund[0].id);
            RefundRequestController controller = new RefundRequestController();

            controller.upload();
            
            controller.attachment =  lstAttachment[0];
            controller.refund.Status__c = 'Application Rejected';
            controller.upload();

            controller.attachment =  lstAttachment[0];
            controller.refund.Status__c = 'Application Accepted';
            controller.upload();
        Test.stopTest();
        
    }

    public static testMethod void unitTest5() {
        List<nmRefund_Payment__c> lstRefund = [select id from nmRefund_Payment__c where nm_Payment_Status__c = 'Refund Initiated'];
        // List<Attachment> lstAttachment = new List<Attachment>();
        List<Attachment> lstAttachment = [select id,body,Name,description,ParentId from Attachment where Description = 'Refund Request'];
        Test.startTest();
            PageReference pageRef = Page.RefundUploader;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstRefund[0].id);
            RefundRequestController controller = new RefundRequestController();

            controller.upload();
            
            controller.attachment =  lstAttachment[0];
            controller.refund.Status__c = 'Application Rejected';
            controller.upload();

            controller.attachment =  lstAttachment[0];
            controller.refund.Status__c = 'Application Accepted';
            controller.upload();
        Test.stopTest();
    }

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"status":"SUCCESS","subCode":"200","message":"Bank Account details verified successfully","accountStatus":"VALID","accountStatusCode":"ACCOUNT_IS_VALID","data":{"nameAtBank":"NISHA JESWANI","refId":"647003964","bankName":"HDFC BANK","utr":"319317281654","city":"MUMBAI","branch":"TULSIANI CHMBRS - NARIMAN PT","micr":0,"nameMatchScore":"0","nameMatchResult":"-"}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}