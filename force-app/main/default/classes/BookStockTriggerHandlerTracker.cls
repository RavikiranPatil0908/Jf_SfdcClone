/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  : @BK
**/
@isTest(SeeAllData=false)
public class BookStockTriggerHandlerTracker {

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

    @testSetup
    public static void setUpData(){  
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
        centerLearningCenter.Name='Mumbai';
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

        for (String bookName : lstBooks) {
            nm_CourseMaster__c obj = new nm_CourseMaster__c(
                Name = bookName,
                nm_CourseID__c = 'Test_'+bookName,
                Book_Code__c = 'Test_'+bookName,
                Number_Of_pages__c = 318,
                Publisher__c = 'Wiley'
            );
            lstCourseMaster.add(obj);
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
        insert nmcom;

        List<Book_Stock__c> bookList = new List<Book_Stock__c>();
        for (Stock__c obj : lstSK) {
            if(obj.Course_Master__c!=null) {
                Book_Stock__c bSTK = new Book_Stock__c();
                bSTK.Course_Master__c = obj.Course_Master__c;
                bSTK.Stock__c = obj.Id;
                bSTK.Book_Stock__c = obj.Quantity__c;
                bSTK.Final_Requirment__c = 100;
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
    }
    
    @isTest 
    static void unitTest1() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
            List<Book_Stock__c> lstSKU = [SELECT id,Final_Requirment__c,Additional__c FROM Book_Stock__c];
            for (Integer i = 0; i < lstSKU.size(); i++) {
                if(i==0) {
                    lstSKU[i].Final_Requirment__c = 50;
                } else if(i==1) {
                    lstSKU[i].Final_Requirment__c = 250;
                } else if(i==2) {
                    lstSKU[i].Final_Requirment__c = 350;
                } else if(i==3) {
                    lstSKU[i].Final_Requirment__c = 550;
                } else if(i==4) {
                    lstSKU[i].Final_Requirment__c = 1550;
                } else if(i==5) {
                    lstSKU[i].Final_Requirment__c = 2550;
                } else {
                    lstSKU[i].Final_Requirment__c = 3550;
                }
                lstSKU[i].Additional__c = 20;
            }
            update lstSKU;
        Test.stopTest();
    }

    @isTest 
    static void unitTest2() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
            List<Book_Stock__c> lstSKU = [SELECT id,Final_Requirment__c,Additional__c FROM Book_Stock__c];
            for (Integer i = 0; i < lstSKU.size(); i++) {
                if(i==0) {
                    lstSKU[i].Final_Requirment__c = 700;
                } else if(i==1) {
                    lstSKU[i].Final_Requirment__c = 2500;
                } else if(i==2) {
                    lstSKU[i].Final_Requirment__c = 3500;
                } else if(i==3) {
                    lstSKU[i].Final_Requirment__c = 0;
                } 
                lstSKU[i].Additional__c = 20;
            }
            update lstSKU;
        Test.stopTest();
    }
    
}