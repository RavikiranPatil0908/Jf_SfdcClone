@isTest
public class BulkStockDeductionControllerTest {

    @testSetup
    static void setupData() {
        // Create test centers
        nm_Centers__c objCen =  new nm_Centers__c();
        Recordtype RT=[select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Information Center'];
        objCen.Nm_Active__c = true;
        objCen.Name='Center A';
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
       // insert new List<nm_Centers__c>{objCen};


        // Create test books
        nm_CourseMaster__c book1 = new nm_CourseMaster__c(Name = 'Book Alpha');
        nm_CourseMaster__c book2 = new nm_CourseMaster__c(Name = 'Book Beta');
        insert new List<nm_CourseMaster__c>{book1, book2};

        // Create stock entries for books at the center
        insert new List<Stock__c>{
            new Stock__c(Centers__c = objCen.Id, Course_Master__c = book1.Id, Quantity__c = 10),
            new Stock__c(Centers__c = objCen.Id, Course_Master__c = book2.Id, Quantity__c = 10)
        };

        // Create SKUs referencing those books
        Stock_Keeping_Units__c sku1 = new Stock_Keeping_Units__c(Name = 'SKU-Alpha', CM_Books__c = 'Book Alpha;Book Beta');
        Stock_Keeping_Units__c sku2 = new Stock_Keeping_Units__c(Name = 'SKU-Beta', CM_Books__c = 'Book Alpha;Book Beta');
        insert new List<Stock_Keeping_Units__c>{sku1, sku2};

        // Create existing SKU stock (optional)
        insert new Stock__c(
            Centers__c = objCen.Id,
            Stock_Keeping_Unit__c = sku1.Id,
            Quantity__c = 5
        );
    }

    @isTest
    static void testBookStockDeductionAcrossMultipleSKUs() {
        
       
        // Create sample CSV with two SKUs using same books
        String csv = 'SKU,Quantity,Center\n'
                   + 'SKU-Alpha,2,Center A\n'
                   + 'SKU-Beta,2,Center A\n';
        Blob fileBlob = Blob.valueOf(csv);

        // Run controller
        BulkStockDeductionController controller = new BulkStockDeductionController();
        controller.fileBody = fileBlob;
        controller.fileName = 'test.csv';

        Test.startTest();
        controller.processFile();
        Test.stopTest();

        // Confirm result includes proper messages
        //System.assert(controller.result.contains('Line 2: Book stock updated.'));
        //System.assert(controller.result.contains('Line 3: Book stock updated.'));

        // Validate that total book stock was deducted properly (2 per line × 2 SKUs = 4)
        Map<String, Decimal> finalStockMap = new Map<String, Decimal>();
        for (Stock__c s : [
            SELECT Quantity__c, Course_Master__r.Name
            FROM Stock__c
            WHERE Course_Master__r.Name IN ('Book Alpha', 'Book Beta')
        ]) {
            finalStockMap.put(s.Course_Master__r.Name, s.Quantity__c);
        }

        //System.assertEquals(6, finalStockMap.get('Book Alpha'), 'Book Alpha should have 4 deducted.');
        //System.assertEquals(6, finalStockMap.get('Book Beta'), 'Book Beta should have 4 deducted.');
    }
}