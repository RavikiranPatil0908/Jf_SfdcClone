/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-12-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class FacultyVideoReviewControllerTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }


    @TestSetup
    static void makeData(){ 
        Async_Shoot_Post_Production__c obj = new Async_Shoot_Post_Production__c();
        obj.Subject__c = 'Business Analytics';
        obj.Chapter_Name__c = 'Test';
        obj.Faculty_Email__c = 'Test@test.com';
        obj.Shoot_Date__c = System.today();
        obj.Faculty_Name__c = 'Anurag Garg';
        obj.Recording_Format__c = 'Zoom';
        obj.Recording_Platform__c = 'Zoom';
        obj.Post_Production_Minutes__c = 10;
        obj.Partner__c = 'Devendra Sharma';
        obj.Editor_Name__c = 'Devendra Sharma';
        obj.Editor_Email_Id__c = 'devendrasuthra750@gmail.com';
        obj.Video_Link_Version_1__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        obj.Video_Link_Version_2__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        obj.Program__c = 'UG';
        obj.Internal_Video_Remarks__c = 'test';
        insert obj;

        TOC__c objToc = new TOC__c();
        objToc.Subject__c = 'Business Analytics';
        objToc.Block_Name__c = 'Test';
        objToc.Block_Number__c = 'Test';
        objToc.Id__c = '1234';
        objToc.Sub_Topic_Name__c = 'Test';
        objToc.Sub_Topic_Number__c = 'Test';
        objToc.Topic_Name__c = 'Test';
        objToc.Topic_Number__c = 'Test';
        objToc.Unit_Name__c = 'Test';
        objToc.Unit_Number__c = 'Test';
        objToc.Program__c = 'UG';
        insert objToc;
    }

    @isTest
    static void unitTest1() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Program__c,Subject__c FROM Async_Shoot_Post_Production__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FacultyVideoReviewController.FilterWrapper objWrapper = new FacultyVideoReviewController.FilterWrapper();
            objWrapper.program = lstPP[0].Program__c;
            objWrapper.subject = lstPP[0].Subject__c;
        	objWrapper.getPendingList = false;
            FacultyVideoReviewController.getListAsyncRecords(objWrapper);
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Program__c,Subject__c FROM Async_Shoot_Post_Production__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FacultyVideoReviewController.FilterWrapper objWrapper = new FacultyVideoReviewController.FilterWrapper();
            objWrapper.search = lstPP[0].Program__c;
        	objWrapper.getPendingList = false;
            FacultyVideoReviewController.getListAsyncRecords(objWrapper);
        Test.stopTest();
    }

    @isTest
    static void unitTest3() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Program__c,Subject__c FROM Async_Shoot_Post_Production__c LIMIT 1];
        List<TOC__c> lst = [SELECT id FROM TOC__c];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            List<AsyncTOCLink__c> lstInsert = new List<AsyncTOCLink__c>();
            for (TOC__c obj : lst) {
                AsyncTOCLink__c objLink = new AsyncTOCLink__c(TOC__c=obj.Id, Async_Shoot_Post_Production__c=lstPP[0].Id);
                lstInsert.add(objLink);
            }
            insert lstInsert;
            FacultyVideoReviewController.FilterWrapper objWrapper = new FacultyVideoReviewController.FilterWrapper();
            objWrapper.recordId = lstPP[0].Id;
        	objWrapper.getPendingList = false;
            FacultyVideoReviewController.getListAsyncRecords(objWrapper);
        Test.stopTest();
    }

    @isTest
    static void unitTest4() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Program__c,Subject__c FROM Async_Shoot_Post_Production__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FacultyVideoReviewController.getTOCRecords('Business Analytics','UG',lstPP[0].Id);
        Test.stopTest();
    }

    @isTest
    static void unitTest5() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Program__c,Subject__c FROM Async_Shoot_Post_Production__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FacultyVideoReviewController.updateAsyncwithTOC(lstPP[0]);
        Test.stopTest();
    }

    @isTest
    static void unitTest6() {
        List<Async_Shoot_Post_Production__c> lstPP = [SELECT Id,Program__c,Subject__c FROM Async_Shoot_Post_Production__c LIMIT 1];
        List<TOC__c> lstTOC = [SELECT id FROM TOC__c LIMIT 1];
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            FacultyVideoReviewController.updateTocWithAsync(lstTOC[0].Id,lstPP[0].Id,true);
        Test.stopTest();
    }

}