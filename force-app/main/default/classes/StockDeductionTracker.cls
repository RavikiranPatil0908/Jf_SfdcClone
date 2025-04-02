/**
 * @File Name          : StockDeductionTracker.cls
 * @Description        : 
 * @Author             : shubhranshu
 * @Group              : 
 * @Last Modified By   : shubhranshu
 * @Last Modified On   : 23/1/2020, 11:37:58 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    22/1/2020   shubhranshu     Initial Version
**/
@isTest(SeeAllData=false)
public without sharing class StockDeductionTracker {

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
        nm_Centers__c objCen =  new nm_Centers__c();
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        objCen.Nm_Active__c = true;
        objCen.Name='Mumbai';
        objCen.RecordTypeID = RT.id;         
        objCen.nm_CenterCode__c = '002';
        objCen.nm_CenterCity__c = 'test';
        objCen.nm_City__c = 'test';
        objCen.nm_StateProvince__c = 'test';
        objCen.nm_Street__c = 'Krishna Nagar';
        objCen.nm_PostalCode__c = '110051'; 
        objCen.Sync_with_Portal__c =false;
        objcen.Allow_Degree__c = true;
        objcen.Allow_MBA_WX__c = true;
        insert objCen;
        
        Stock_Keeping_Units__c sku = new Stock_Keeping_Units__c();
        sku.Program_Type__c = 'Certificate Programs';
        sku.Launch_Year__c = 'JUL2009';
        sku.CM_Books__c = 'Advanced Supply Chain Management; Business Communication';
        insert sku;

        nm_CourseMaster__c cm = new nm_CourseMaster__c();
        cm.Name = 'Advanced Supply Chain Management';
        insert cm;

        nm_CourseMaster__c cm1 = new nm_CourseMaster__c();
        cm1.Name = 'Business Communication';
        insert cm1;

        Stock__c st = new Stock__c();
        st.Centers__c = objcen.Id;
        st.Course_Master__c = cm.Id;
        st.Quantity__c = 1000;
        insert st;

        Stock__c st1 = new Stock__c();
        st1.Centers__c = objcen.Id;
        st1.Course_Master__c = cm1.Id;
        st1.Quantity__c = 1000;
        insert st1; 
    }

    static testMethod void testStockDeductionForBooks(){

        nm_Centers__c center = [SELECT Id,Name FROM nm_Centers__c LIMIT 1];
        Stock_Keeping_Units__c sku = [SELECT Id , Name, CM_Books__c FROM Stock_Keeping_Units__c LIMIT 1];
        Stock__c st = [SELECT Id,Centers__c,Course_Master__c,Quantity__c FROM Stock__c LIMIT 1];
        Test.startTest();
        StoockDeduction.stockDeductionForBooks(sku.Id, 20, center.Id);
        Test.stopTest();
    }

    static testMethod void testStockDeductionForBooks1(){

        nm_Centers__c center = [SELECT Id,Name FROM nm_Centers__c LIMIT 1];
        Stock_Keeping_Units__c sku = [SELECT Id , Name, CM_Books__c FROM Stock_Keeping_Units__c LIMIT 1];
        Stock__c st = [SELECT Id,Centers__c,Course_Master__c,Quantity__c FROM Stock__c LIMIT 1];
        st.Quantity__c = 10;
        update st;
        Test.startTest();
        StoockDeduction.stockDeductionForBooks(sku.Id, 20, center.Id);
        Test.stopTest();
    }

    static testMethod void testStockDeductionForBooks2(){

        nm_Centers__c center = [SELECT Id,Name FROM nm_Centers__c LIMIT 1];
        Stock_Keeping_Units__c sku = [SELECT Id , Name, CM_Books__c FROM Stock_Keeping_Units__c LIMIT 1];
        Stock__c st = [SELECT Id,Centers__c,Course_Master__c,Quantity__c FROM Stock__c LIMIT 1];
        Stock__c stk = new Stock__c();
        stk.Centers__c = center.Id;
        stk.Stock_Keeping_Unit__c = sku.Id;
        stk.Outgoing_Quantity__c = 0;
        stk.Incoming_Quantity__c = 0;
        stk.Quantity__c = 10;
        insert stk;
        Test.startTest();
        StoockDeduction.stockDeductionForBooks(sku.Id, 20, center.Id);
        Test.stopTest();
    }
}