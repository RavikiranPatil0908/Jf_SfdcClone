/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 30-12-2024
 * @last modified by  : @BK
**/
@istest(SeeAllData=false)
public class AsyncTOCLinkTriggerHandlerTracker {
 
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
    @testSetup
    public static void setUpData()
    {
        List<TOC__c> lstTOC = new List<TOC__c>();
        TOC__c obj = new TOC__C();
        obj.Block_Name__c = 'Customer Value & Customer Behavior';
        obj.Subject__c = 'Strategic Management';
        obj.Unit_Name__c = 'Analysing the Marketing Environment';
        obj.Topic_Name__c = '';
        obj.Sub_Topic_Name__c = '';
        obj.Program__c = 'MBA-WX';
        obj.Block_Number__c = '4';
        obj.Id__c = '1';
        obj.Unit_Number__c = '4';
        lstTOC.add(obj);
        
        TOC__c obj2 = new TOC__C();
        obj2.Block_Name__c = 'Customer Value & Customer Behavior';
        obj2.Subject__c = 'Strategic Management';
        obj2.Unit_Name__c = 'Analysing the Marketing Environment';
        obj2.Topic_Name__c = '';
        obj2.Sub_Topic_Name__c = '';
        obj2.Program__c = 'MBA-WX';
        obj2.Block_Number__c = '4';
        obj2.Id__c = '2';
        obj2.Unit_Number__c = '4';
        lstTOC.add(obj2);
        insert lstTOC;

        Async_Shoot_Post_Production__c ob = new Async_Shoot_Post_Production__c(); 
        ob.Subject__c='Business Communication';
        ob.Chapter_Name__c='Chap 1';
        ob.Shoot_Date__c=Date.Today();
        ob.Faculty_Name__c='Anurag Garg';
        ob.Faculty_Email__c='anuraggarg@gmail.com';
        ob.Editor_Name__c='Aman';
        ob.Editor_Email_Id__c='amanmishra2326@gmail.com';
        ob.Recording_Format__c='Zoom';
        ob.Recording_Platform__c='Zoom';
        ob.Post_Production_Minutes__c = 10;
        ob.Partner__c = 'Devendra Sharma';
        ob.Editor_Name__c = 'Devendra Sharma';
        ob.Editor_Email_Id__c = 'devendrasuthra750@gmail.com';
        ob.Video_Link_Version_1__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        ob.Program__c = 'UG';
        insert ob;


        
    }

    @isTest 
    static void TestMethod1()
    {
        List<Async_Shoot_Post_Production__c > lst = [select Id from Async_Shoot_Post_Production__c LIMIT 1];
        List<TOC__c> lstTOC = [select Id from TOC__c LIMIT 2];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            List<AsyncTOCLink__c> lstLinks = new List<AsyncTOCLink__c>();
            AsyncTOCLink__c aObj = new AsyncTOCLink__c();
            aObj.TOC__c = lstTOC[0].Id;
            aObj.Async_Shoot_Post_Production__c = lst[0].Id;
            lstLinks.add(aObj);
            
            AsyncTOCLink__c bObj = new AsyncTOCLink__c();
            bObj.TOC__c = lstTOC[1].Id;
            bObj.Async_Shoot_Post_Production__c = lst[0].Id;
            lstLinks.add(bObj);
            
            insert lstLinks;
    AsyncTOCLinkPortal.callApiObj(lst[0].Id);
        Test.stopTest();

    }
    @isTest 
    static void TestMethod2()
    {
        List<Async_Shoot_Post_Production__c > lst = [select Id,Video_Link_Version_1__c from Async_Shoot_Post_Production__c LIMIT 1];
        List<TOC__c> lstTOC = [select Id from TOC__c LIMIT 2];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<AsyncTOCLink__c> lstLinks = new List<AsyncTOCLink__c>();
        AsyncTOCLink__c aObj = new AsyncTOCLink__c();
        aObj.TOC__c = lstTOC[0].Id;
        aObj.Async_Shoot_Post_Production__c = lst[0].Id;
        lstLinks.add(aObj);
        
        AsyncTOCLink__c bObj = new AsyncTOCLink__c();
        bObj.TOC__c = lstTOC[1].Id;
        bObj.Async_Shoot_Post_Production__c = lst[0].Id;
        lstLinks.add(bObj);
        insert lstLinks;
        
        Async_Shoot_Post_Production__c ob = lst[0];
        ob.Video_Link_Version_1__c = 'http://www.youtube.com/watch?v=S7oJo';    
    	update ob;
        Test.stopTest();

    }
}