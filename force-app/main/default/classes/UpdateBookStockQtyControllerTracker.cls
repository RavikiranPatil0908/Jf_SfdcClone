@isTest(SeeAllData=false)
private class UpdateBookStockQtyControllerTracker {

    @isTest
    static void testConstructor_NoRecordsSelected() {
        // Simulate no records selected scenario
        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(new List<Book_Stock__c>());
        Test.startTest();
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
        Test.stopTest();  
    }

    @isTest
    static void testConstructor_WithRecordsSelected() {
        // Simulate records selected scenario
        List<Book_Stock__c> selectedRecords = [SELECT Id FROM Book_Stock__c LIMIT 5];
        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(selectedRecords);
        Test.startTest();
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
        Test.stopTest();
       
    }

    @isTest
    static void testGetStep() {
        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(new List<Book_Stock__c>());

        // Instantiate your class
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
       
        Test.startTest();
        // Call the getStep method
        String step = controller.getStep();
        Test.stopTest();

    }

    @isTest
    static void testCancel() {

        // Create a mock StandardSetController
        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(new List<Book_Stock__c>());
        
        // Instantiate the controller
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
        Test.startTest();
        // Test cancel method
        PageReference cancelPageRef = controller.cancel();
        Test.stopTest();
    }

    @isTest
    static void testStep1() {
 
        // Create a mock StandardSetController
        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(new List<Book_Stock__c>());  
        // Instantiate the controller
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
        Test.startTest();
        // Test step1 method
        PageReference pageRef = controller.step1();
        Test.stopTest();
    }

    @isTest
    static void testStep2() {
        // Create a mock StandardSetController
        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(new List<Book_Stock__c>());
        
        // Instantiate the controller
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
        
        Test.startTest();
        // Test step2 method
        PageReference pageRef = controller.step2();
        Test.stopTest();
    }

    @isTest
    static void testUpdateBookStock() {
        // Create mock data
        List<Stock__c> mockStocks = new List<Stock__c>();
        for(Integer i = 0; i < 5; i++) {
            mockStocks.add(new Stock__c(Quantity__c = i)); // You can adjust the data as needed
        }
        insert mockStocks;

        List<Book_Stock__c> lstOfSelectedRecords = new List<Book_Stock__c>();
        for(Stock__c stock : mockStocks) {
            lstOfSelectedRecords.add(new Book_Stock__c(Stock__c = stock.Id)); // Assuming Stock__c is a lookup field on Book_Stock__c
        }
        insert lstOfSelectedRecords;

        ApexPages.StandardSetController mockController = new ApexPages.StandardSetController(new List<Book_Stock__c>());
        // Instantiate your class
        UpdateBookStockQtyController controller = new UpdateBookStockQtyController(mockController);
        controller.lstOfSelectedRecords = lstOfSelectedRecords;

   
        Test.startTest();
        // Call the updateBookStock method
        PageReference result = controller.updateBookStock();
        Test.stopTest();

        // Assert that the list of selected records is updated
        for(Book_Stock__c record : lstOfSelectedRecords) {
            for(Stock__c stock : mockStocks) {
                if(record.Stock__c == stock.Id) {
                    System.assertEquals(stock.Quantity__c, record.Book_Stock__c, 'Book stock quantity is not updated correctly.');
                }
            }
        }
    }
}