/**
  @description       : 
  @author            : @MonikaC
  @group             : 
  @last modified on  : 21-03-2024
  @last modified by  : @MonikaC

**/
@isTest(SeeAllData=false)
private class StockSkuJunctionCSVControllerTracker {

    @testSetup
    public static void setUpData(){ 
        nm_Centers__c objCen =  new nm_Centers__c();
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        objCen.Nm_Active__c = true;
        objCen.Name='Repro - Bhiwandi';
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

        List<String> lstBooks = new List<String>{'Commercial Banking System & Role of RBI','Corporate Finance; Cost & Management Accounting','Marketing of Financial Services','Retail Banking','Taxation - Direct and Indirect'};
        List<nm_CourseMaster__c> lstCourseMaster = new List<nm_CourseMaster__c>();
        List<Stock__c> lstSK = new List<Stock__c>();


        for (String bookName : lstBooks) {
            nm_CourseMaster__c obj = new nm_CourseMaster__c(
                Name = bookName,
                nm_CourseID__c = 'Test_'+bookName,
                Book_Code__c = 'Test_'+bookName,
                Number_Of_pages__c = 318,
                Publisher__c = 'Wiley'
                // Final_Order__c = 100
            );
            lstCourseMaster.add(obj);
        }
        insert lstCourseMaster;
        
        for (nm_CourseMaster__c obj : lstCourseMaster) {
            Stock__c sk = new Stock__c();
            sk.Quantity__c = 10;
            sk.Stock_Quantity_history__c = '';
            sk.Course_Master__c=obj.id;
            sk.Centers__c=objcen.id;
            lstSK.add(sk);
        }


        Stock_Keeping_Units__c  stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'Jul2019';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        stockUnit.CM_Books__c = String.join(lstBooks,';');
        insert stockUnit;

        
        Stock__c st = new Stock__c();
        st.Quantity__c = 10;
        st.Stock_Quantity_history__c = '';
        st.Stock_Keeping_Unit__c=stockUnit.id;
        st.Centers__c=objcen.id;
        insert st;
        
        // lstSK.add(st);

        insert lstSK;
        
        nmGenericTracker.CreateCalender();

        StockSkuJunction__c nmcom = new StockSkuJunction__c();
        nmcom.Stock_Keeping_Units__c=stockUnit.Id;
        nmcom.Stock__c=st.id;
        nmcom.Base_Count__c = 2000;
        insert nmcom;

        List<Book_Stock__c> bookList = new List<Book_Stock__c>();
        for (Stock__c obj : lstSK) {
            if(obj.Course_Master__c!=null) {
                Book_Stock__c bSTK = new Book_Stock__c();
                bSTK.Course_Master__c = obj.Course_Master__c;
                bSTK.Stock__c = obj.Id;
                bSTK.Book_Stock__c = obj.Quantity__c;
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
    static void testConstructor() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        controller.submitSessionYear();
        List<SelectOption> options = controller.getSessionOptions();
        System.assertEquals(true, controller.showModal, 'is true');
        System.assertEquals(true, (options.size() > 0), 'is true');
        // System.assertEquals(false, controller.showStockSkuJunctions);
    }
    
    @isTest
    static void testFilterRecords_Success() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        controller.session = 'January';
        controller.year = '2024';
        
        Test.startTest();
        controller.filterRecords();
        Test.stopTest();
        
        // System.assertEquals(true, controller.showCSVUpload);
        // System.assertEquals(false, controller.showStockSkuJunctions);
    }
    
    @isTest
    static void testFilterRecords_Error() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        controller.session = 'December';
        controller.year = '2025';
        
        Test.startTest();
        controller.filterRecords();
        Test.stopTest();
        
        // System.assertEquals(false, controller.showCSVUpload);
        // System.assertEquals(false, controller.showStockSkuJunctions);
        // System.assertNotEquals(0, ApexPages.getMessages().size());
    }
    
    @isTest
    static void testImportCSVFile_Success() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        controller.session = 'January';
        controller.year = '2024';
        controller.csvFileBody = Blob.valueOf('Stock Keeping Units, Assumption\nSKU1, 10\nSKU2, 20\n');
        
        Test.startTest();
        controller.importCSVFile();
        Test.stopTest();
        
        // System.assertEquals(false, controller.showCSVUpload);
        // System.assertEquals(true, controller.showStockSkuJunctions);
        // System.assertNotEquals(null, controller.stockSkuJunctionList);
    }
    
    @isTest
    static void testImportCSVFile_Error() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        controller.session = 'January';
        controller.year = '2024';
        controller.csvFileBody = Blob.valueOf('Invalid CSV Data');
        
        Test.startTest();
        controller.importCSVFile();
        Test.stopTest();
        
        // System.assertEquals(true, ApexPages.getMessages().size() > 0);
    }
    
    @isTest
    static void testRefreshPage() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        
        Test.startTest();
        PageReference pageRef = controller.refreshPage();
        Test.stopTest();
        
        // System.assertEquals(true, pageRef.getRedirect());
    }
    
    @isTest
    static void testBackSessionYearPage() {
        StockSkuJunctionCSVController controller = new StockSkuJunctionCSVController();
        
        Test.startTest();
        PageReference pageRef = controller.backSessionYearPage();
        Test.stopTest();
        
        // System.assertEquals(true, pageRef.getRedirect());
    }

    // @isTest
    // static void stockSkuJunctionTest() {
    //     // Create a Stock_Keeping_Units__c record
    //     Stock_Keeping_Units__c objSku = new Stock_Keeping_Units__c(
    //         Program__c = 'PGDSCM', 
    //         Program_Type__c = 'Post Graduate Diploma Programs'
    //     );
    //     insert objSku; // Insert the Stock_Keeping_Units__c record into the database

    //     // Query for the inserted Stock_Keeping_Units__c record
    //     objSku = [SELECT Id FROM Stock_Keeping_Units__c WHERE Id = :objSku.Id LIMIT 1];
    
    //     // Create a StockSkuJunction__c record
    //     StockSkuJunction__c objSSJ = new StockSkuJunction__c(
    //         Year__c = '2024',
    //         Session__c = 'January',
    //         Assumption__c = 50.0, 
    //         Stock_Keeping_Units__c = objSku.Id 
    //     );
    //     insert objSSJ; // Insert the StockSkuJunction__c record into the database
    
    //     Test.startTest();
    //     // Now proceed with testing your controller
    //     StockSkuJunctionCSVController obj = new StockSkuJunctionCSVController();
    //     obj.submitSessionYear();           
    //     obj.filterRecords();
    //     obj.importCSVFile();
    //     obj.refreshPage();
    //     obj.backSessionYearPage();
    //     Test.stopTest();
    // }
}