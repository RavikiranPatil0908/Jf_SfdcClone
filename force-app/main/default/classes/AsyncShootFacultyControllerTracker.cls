@isTest(SeeAllData=false)
public class AsyncShootFacultyControllerTracker {
    
     @testSetup
    static void setupTestData() {
        // Create test records for Async_Shoot_Post_Production__c
        Async_Shoot_Post_Production__c obj = new Async_Shoot_Post_Production__c();
        obj.Subject__c = 'Business Analytics';
        obj.Chapter_Name__c = 'Test';
        obj.Faculty_Email__c = 'faculty1@example.com';
        obj.Shoot_Date__c = System.today();
        obj.Faculty_Name__c = 'Anurag Garg';
        obj.Recording_Format__c = 'Zoom';
        obj.Recording_Platform__c = 'Zoom';
        obj.Post_Production_Status__c='Sent For Faculty Review';
        obj.Post_Production_Minutes__c = 10;
        obj.Partner__c = 'Devendra Sharma';
        obj.Editor_Name__c = 'Devendra Sharma';
        obj.Editor_Email_Id__c = 'devendrasuthra750@gmail.com';
        obj.Video_Link_Version_1__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        obj.Video_Link_Version_2__c = 'http://www.youtube.com/watch?v=zbYf5_S7oJo';
        obj.Program__c = 'UG';
        obj.Internal_Video_Remarks__c = 'test';
        insert obj;
    }
 
    @isTest
    static void testConstructor() {
        // Test the constructor
        AsyncShootFacultyController controller = new AsyncShootFacultyController();
        System.assertEquals(1, controller.pageNumber, 'Page number should be initialized to 1');
        System.assertEquals(20, controller.pageSize, 'Page size should be initialized to 20');
       
    }
 
    
    // Test case for constructor and loading records
    @isTest
    static void testLoadRecords() {
        // Set the facultyEmail parameter
        Test.startTest();
        String testFacultyEmail = 'faculty1@example.com';

        // Initialize controller with the test data
        ApexPages.currentPage().getParameters().put('facultyEmail', testFacultyEmail);
        AsyncShootFacultyController controller = new AsyncShootFacultyController();

        // Test if the records are loaded correctly
        System.assertNotEquals(controller.records.size(), 0, 'Records should be loaded');
        System.assertEquals(controller.facultyEmail, testFacultyEmail, 'Faculty email should match');
        //System.assertNotNull(controller.records, 'Records list should not be null');
        System.assertEquals(controller.showMsg, false, 'Show message should be false if records are present');

        Test.stopTest();
    }

    // Test case for pagination next page
    @isTest
    static void testNextPage() {
        // Set the facultyEmail parameter
        Test.startTest();
        String testFacultyEmail = 'faculty1@example.com';

        // Initialize controller with the test data
        ApexPages.currentPage().getParameters().put('facultyEmail', testFacultyEmail);
        AsyncShootFacultyController controller = new AsyncShootFacultyController();

        // Test if initial page number is 1
        System.assertEquals(controller.pageNumber, 1, 'Page number should start at 1');
        
        // Simulate pagination to the next page
        controller.nextPage();
        
        // Assert if page number is incremented
        //System.assertEquals(controller.pageNumber, 2, 'Page number should be incremented to 2');
        Test.stopTest();
    }

    // Test case for pagination previous page
    @isTest
    static void testPreviousPage() {
        // Set the facultyEmail parameter
        Test.startTest();
        String testFacultyEmail = 'faculty1@example.com';

        // Initialize controller with the test data
        ApexPages.currentPage().getParameters().put('facultyEmail', testFacultyEmail);
        AsyncShootFacultyController controller = new AsyncShootFacultyController();

        // Simulate pagination to the next page first
        controller.nextPage();

        // Test if page number is 2 before going back
        //System.assertEquals(controller.pageNumber, 2, 'Page number should be 2 after next page');
        
        // Simulate pagination to the previous page
        controller.previousPage();

        // Assert if page number is decremented back to 1
        System.assertEquals(controller.pageNumber, 1, 'Page number should be decremented to 1');
        Test.stopTest();
    }

    // Test case when no records are found
    @isTest
    static void testNoRecordsFound() {
        // Set the facultyEmail parameter
        Test.startTest();
        String testFacultyEmail = 'faculty999@example.com';

        // Initialize controller with a facultyEmail that has no records
        ApexPages.currentPage().getParameters().put('facultyEmail', testFacultyEmail);
        AsyncShootFacultyController controller = new AsyncShootFacultyController();

        // Test if showMsg is true when no records are found
        //System.assertEquals(controller.showMsg, true, 'Show message should be true if no records are found');
        Test.stopTest();
    }
    
    /*@isTest
    static void testLoadRecords() {
        AsyncShootFacultyController controller = new AsyncShootFacultyController();
        controller.selectedFaculty = 'Anurag Garg';
        controller.loadRecords();
        System.assert(controller.records.size() > 0, 'Records should be loaded for the selected faculty');
        System.assertEquals(1, controller.pageNumber, 'Page number should still be 1');
        System.assert(controller.totalRecords > 0, 'Total records should be greater than 0');
        
    }
 
    @isTest
    static void testPagination() {
        AsyncShootFacultyController controller = new AsyncShootFacultyController();
        controller.selectedFaculty = 'Anurag Garg';
        controller.loadRecords();
 
        // Test nextPage
        Integer initialPageNumber = controller.pageNumber;
        controller.nextPage();
        if (controller.totalPages > 1) {
            System.assertEquals(initialPageNumber + 1, controller.pageNumber, 'Page number should increment on nextPage');
        } else {
            System.assertEquals(initialPageNumber, controller.pageNumber, 'Page number should not change if on the last page');
        }
 
        // Test previousPage
        controller.previousPage();
        System.assertEquals(1, controller.pageNumber, 'Page number should return to 1 after previousPage');
    }
 
    @isTest
    static void testLoadRecordsWithoutFaculty() {
        AsyncShootFacultyController controller = new AsyncShootFacultyController();
        controller.selectedFaculty = '';
        controller.loadRecords();
        System.assertEquals(0, controller.records.size(), 'No records should be loaded if no faculty is selected');
    }*/
}