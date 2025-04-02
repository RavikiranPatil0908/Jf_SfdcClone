/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class MassBankVerificationBatchClassTracker {

    private class RestMockRequest implements HttpCalloutMock {
        public String type = '';

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"type":"Bank","token":"test","success":"success","error":null}';
            if(type == 'bulkStatus') {
                fullJson ='{"status":"SUCCESS","subCode":"200","data":{"bulkValidationId":"test","entries":{"000000000000001_IDB00000001":{"bankAccount":"000000000000001","ifsc":"IDB00000001","name":"Chandra kumar","phone":"88503454354345232891","nameAtBank":"Mr. Chandra kumar","accountExists":"YES","utr":"31921335345345345656355152","refId":"645575231","message":"Amount Deposited Successfully","nameMatchScore":"90.00","nameMatchResult":"GOOD_PARTIAL_MATCH"}}}}';
            } else if(type == 'bulkRequest') {
                fullJson ='{"status":"SUCCESS","subCode":"200","message":"Bulk Validation requested successfully. Please check later for processing status.","data":{"bulkValidationId":"test"}}';
            }
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){ 
        List<nmRefund_Payment__c> lstRP = new List<nmRefund_Payment__c>();

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
        objRefund.Refund_transfer_Mode__c = 'NEFT';
        objRefund.Type_of_Refund__c = 'Admission Rejected';
        objRefund.Status__c = 'Refund Submitted to Finance';
        objRefund.Account_Holder_name__c = 'Chandra kumar';
        objRefund.Account_Number__c = '000000000000001';
        objRefund.IFSC_Code__c = 'IDB00000001';
        objRefund.nm_Name_of_the_Bank__c = 'Test Bank';
        objRefund.nm_Bank_Location__c = 'Test';
        objRefund.Relationship__c = 'Self';
        lstRP.add(objRefund);

        insert lstRP;
        
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
        insert objCal;
    }


    @isTest     
    static void unitTest1(){ 
        String query = getQueryAllFieldSql('nmRefund_Payment__c', 'Status__c=\'Refund Submitted to Finance\' AND Refund_transfer_Mode__c=\'NEFT\' AND Bank_Verification_API_Called__c=FALSE AND Avoid_Batch__c=FALSE AND Bank_Validation_Id__c=null', 'Account__r.PersonMobilePhone,Account__r.Name,Account__r.Father_Name__c,Account__r.Mother_Name__c,Account__r.nm_SpouseName__c');
        List<nmRefund_Payment__c> lstRP = DataBase.query(query);
        Test.startTest();
            MassBankVerificationBatchClass batchClass = new MassBankVerificationBatchClass();
            batchClass.callStatusAPI = false;
            batchClass.bulkValidationId = 'test';
            batchClass.bearerAuthToken = 'test';
            batchClass.tokenExpiryTime = System.now().addHours(1);

            RestMockRequest objRequest = new RestMockRequest();
            objRequest.type = 'bulkRequest';
            Test.setMock(HttpCalloutMock.class, objRequest);

            batchClass.start(null);
            batchClass.execute(null, lstRP);
            batchClass.finish(null);
        Test.stopTest();
    }

    @isTest     
    static void unitTest2(){ 
        String query = getQueryAllFieldSql('nmRefund_Payment__c', 'Status__c=\'Refund Submitted to Finance\' AND Refund_transfer_Mode__c=\'NEFT\' AND Bank_Verification_API_Called__c=FALSE AND Avoid_Batch__c=FALSE AND Bank_Validation_Id__c=null', 'Account__r.PersonMobilePhone,Account__r.Name,Account__r.Father_Name__c,Account__r.Mother_Name__c,Account__r.nm_SpouseName__c');
        List<nmRefund_Payment__c> lstRP = DataBase.query(query);
        Test.startTest();
            MassBankVerificationBatchClass batchClass = new MassBankVerificationBatchClass();
            batchClass.callStatusAPI = false;
            batchClass.bulkValidationId = 'test';
            batchClass.bearerAuthToken = 'test';
            batchClass.tokenExpiryTime = null;

            RestMockRequest objRequest = new RestMockRequest();
            Test.setMock(HttpCalloutMock.class, objRequest);

            batchClass.start(null);
            batchClass.execute(null, lstRP);
            batchClass.finish(null);
        Test.stopTest();
    }

    @isTest     
    static void unitTest3(){ 
        String query = getQueryAllFieldSql('nmRefund_Payment__c', 'Status__c=\'Refund Submitted to Finance\' AND Refund_transfer_Mode__c=\'NEFT\' AND Bank_Verification_API_Called__c=FALSE AND Avoid_Batch__c=FALSE AND Bank_Validation_Id__c=null', 'Account__r.PersonMobilePhone,Account__r.Name,Account__r.Father_Name__c,Account__r.Mother_Name__c,Account__r.nm_SpouseName__c');
        List<nmRefund_Payment__c> lstRP = DataBase.query(query);
        lstRP[0].Bank_Verification_API_Called__c = true;
        lstRP[0].Bank_Validation_Id__c = 'test';
        update lstRP;
        Test.startTest();
            MassBankVerificationBatchClass batchClass = new MassBankVerificationBatchClass();
            batchClass.callStatusAPI = true;
            batchClass.bulkValidationId = 'test';
            batchClass.bearerAuthToken = 'test';
            batchClass.tokenExpiryTime = System.now().addHours(1);

            RestMockRequest objRequest = new RestMockRequest();
            objRequest.type = 'bulkStatus';
            Test.setMock(HttpCalloutMock.class, objRequest);

            batchClass.start(null);
            batchClass.execute(null, lstRP);
            batchClass.finish(null);
        Test.stopTest();
    }

    

    /**
    * @description 
    * @author @BK | 07-13-2023 
    * @param sObjectAPIName 
    * @param conditionString 
    * @param relatedFields 
    * @return String 
    **/
    public static String getQueryAllFieldSql(String sObjectAPIName, String conditionString, String relatedFields) {
        Map<String, schema.SObjectType> scemapMap = schema.getGlobalDescribe();
        Map<String, schema.SObjectField> fieldMap = scemapMap.get(sObjectAPIName).getDescribe().fields.getMap();
        List<String> fieldNames = new  List<String>(fieldMap.keySet());
        if(String.isNotBlank(relatedFields)) {
            fieldNames.add(relatedFields);
        }
        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + sObjectAPIName + ' WHERE ' + conditionString;
        return query;
    }
}