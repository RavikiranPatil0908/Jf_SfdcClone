/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 05-11-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class AddStockQuantityTracker {

    private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
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
        RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];
        List<String> lstBooks = new List<String>{'Commercial Banking System & Role of RBI','Corporate Finance; Cost & Management Accounting','Marketing of Financial Services','Retail Banking','Taxation - Direct and Indirect'};

        Stock_Keeping_Units__c stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        stockUnit.CM_Books__c = String.join(lstBooks,';');
        insert stockUnit;
        
        nm_Centers__c centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Name='Repro - Bhiwandi';
        centerLearningCenter.Nm_Active__c = true;
        centerLearningCenter.nm_CenterCode__c = 'abcd';
        centerLearningCenter.nm_City__c = 'Mumbai';
        centerLearningCenter.Contact_No_1__c = '9867167685';
        centerLearningCenter.nm_Country__c = 'India';
        centerLearningCenter.nm_StateProvince__c = 'Maharashtra';
        centerLearningCenter.nm_Street__c = 'Altmount Road';
        centerLearningCenter.nm_PostalCode__c = '400601';
        centerLearningCenter.RecordTypeID = learningCenter.id;
        insert centerLearningCenter;
        
        List<nm_CourseMaster__c> lstCourseMaster = new List<nm_CourseMaster__c>();
        List<Stock__c> lstSK = new List<Stock__c>();

        Integer i = 1;
        for (String bookName : lstBooks) {
            nm_CourseMaster__c obj = new nm_CourseMaster__c(
                Name = bookName,
                nm_CourseID__c = 'Test_'+bookName,
                Book_Code__c = 'Test_'+bookName,
                Number_Of_pages__c = 318,
                Publisher__c = 'Wiley',
                ISBN__c = '44444' + i
            );
            lstCourseMaster.add(obj);
            i++;
        }
        insert lstCourseMaster;
        
        for (nm_CourseMaster__c obj : lstCourseMaster) {
            Stock__c sk = new Stock__c();
            sk.Quantity__c = 10;
            sk.Stock_Quantity_history__c = '';
            sk.Course_Master__c=obj.id;
            sk.Centers__c=centerLearningCenter.id;
            lstSK.add(sk);
        }

        Stock__c stockFromCenter = new Stock__c();
        stockFromCenter.Centers__c = centerLearningCenter.id;
        stockFromCenter.Incoming_Quantity__c = 0;
        stockFromCenter.Outgoing_Quantity__c = 0;
        stockFromCenter.Quantity__c = 500;
        stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
        lstSK.add(stockFromCenter);

        insert lstSK;
        
        StockSkuJunction__c nmcom = new StockSkuJunction__c();
        nmcom.Stock_Keeping_Units__c=stockUnit.Id;
        nmcom.Stock__c=stockFromCenter.id;
        nmcom.Base_Count__c = 2000;
        nmcom.Session__c = 'January';
        nmcom.Year__c = '2024';
        nmcom.Assumption__c = 100;
        nmcom.Base_Count__c = 2000;
        insert nmcom;

        List<Book_Stock__c> bookList = new List<Book_Stock__c>();
        for (Stock__c obj : lstSK) {
            if(obj.Course_Master__c!=null) {
                Book_Stock__c bSTK = new Book_Stock__c();
                bSTK.Course_Master__c = obj.Course_Master__c;
                bSTK.Stock__c = obj.Id;
                bSTK.Book_Stock__c = obj.Quantity__c;
                bSTK.Session__c = 'January';
                bSTK.Year__c = '2024';
                bSTK.Final_Requirment__c = 600;
                bookList.add(bSTK);
            }
        }
        insert bookList;

        List<Book_SKU_Junction__c> lst = new List<Book_SKU_Junction__c> ();
        for (Book_Stock__c obj : bookList) {
            Book_SKU_Junction__c bsk = new Book_SKU_Junction__c();
            bsk.Book_Stock_Junction__c=obj.Id;
            bsk.StockSkuJunction__c=nmcom.Id;
            lst.add(bsk);
        }
        insert lst;

        Order_Book__c objOB = new Order_Book__c();
        objOB.Order_Status__c = 'Created';
        objOB.Publisher__c = 'Wiley; Pearson';
        objOB.Session__c = 'January';
        objOB.Year__c = '2024';
        objOB.Type__c = 'New';
        insert objOB;
        Order_Book__c objOBKit = new Order_Book__c();
        objOBKit.Order_Status__c = 'Created';
        objOBKit.Publisher__c = 'Wiley; Pearson';
        objOBKit.Session__c = 'January';
        objOBKit.Year__c = '2024';
        objOBKit.Type__c = 'New';
        insert objOBKit;
		Id recordTypeIdBook = Schema.SObjectType.OrderLineItem__c.getRecordTypeInfosByName().get('Book').getRecordTypeId();
        Id recordTypeIdKit = Schema.SObjectType.OrderLineItem__c.getRecordTypeInfosByName().get('Kit').getRecordTypeId();
        OrderLineItem__c objOL = new OrderLineItem__c(
            Order_Book__c = objOB.Id,
            Status__c = 'Created',
            Book_Quantity__c = 200,
            RecordtypeId = recordTypeIdBook
        );
        insert objOL;
        OrderLineItem__c objOLkit = new OrderLineItem__c(
            Order_Book__c = objOBKit.Id,
            Status__c = 'Created',
            Book_Quantity__c = 200,
            RecordtypeId = recordTypeIdKit
        );
        insert objOLkit;
        createAttachments(objOL.Id);
        createAttachmentsPDF(objOLkit.Id);
    }

    @isTest
    static void unitTest1() {
        List<OrderLineItem__c> lst = [SELECT Id,Order_Book__c FROM OrderLineItem__c LIMIT 1];
        Test.startTest();
            AddStockQuantity.StockWrapperRequest request = new AddStockQuantity.StockWrapperRequest();
            request.orderLineItemId = lst[0].Id;
            request.orderBookId = lst[0].Order_Book__c;
            List<AddStockQuantity.StockWrapperRequest> lstRequest = new List<AddStockQuantity.StockWrapperRequest>{request};
            List<AddStockQuantity.StockWrapperResponse> lstReposne = AddStockQuantity.addStockQuantity(lstRequest);
            System.assertEquals(true, lstReposne[0].isSuccess, 'Quantity Update Failed.');
        Test.stopTest();
    }

    @isTest
    static void unitTest2() {
        Test.startTest();
            AddStockQuantity.StockWrapperRequest request = new AddStockQuantity.StockWrapperRequest();
            request.orderLineItemId = null;
            request.orderBookId = null;
            List<AddStockQuantity.StockWrapperRequest> lstRequest = new List<AddStockQuantity.StockWrapperRequest>{request};
            List<AddStockQuantity.StockWrapperResponse> lstReposne = AddStockQuantity.addStockQuantity(lstRequest);
            System.assertEquals(false, lstReposne[0].isSuccess, 'Quantity Update Success.');
        Test.stopTest();
    }

    public static void createAttachments(String recordId) {
        Attachment obj = new Attachment();
        obj.Name = 'Order_Details.csv';
        String body = 'Quantity, ISBN\n '+
            '20,444441\n' +
            '20,444442\n' +
            '20,444443\n' +
            '20,444444\n' +
            '20,444445\n' +
            '20,444446\n' +
            '20,444447\n' +
            '20,444448\n' +
            '20,444449\n' +
            '20,4444410\n' +
            '20,4444411\n' +
            '20,4444412';
        Blob fileBody = Blob.valueOf(body);
        obj.Body = fileBody;
        obj.ParentId = recordId;
        insert obj;
    }
    public static void createAttachmentsPDF(String recordId) {
        Attachment obj = new Attachment();
        obj.Name = 'Order_Details.csv';
        String body = 'Quantity, SKUName\n '+
            '20,PGDBFM-S3-KIT';
        Blob fileBody = Blob.valueOf(body);
        obj.Body = fileBody;
        obj.ParentId = recordId;
        insert obj;
    }
}