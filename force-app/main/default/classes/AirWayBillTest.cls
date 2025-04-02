@isTest
private class AirWayBillTest {
  private class RestMock implements HttpCalloutMock {
        RestMock() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            // Can assert that the request is correct here
            // Generate a typical response
            String fullJson = '{"Message":"Number of Post office(s) found: 6","Status":"Success","PostOffice":[{"Name":"Alpha Greater Noida","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Noida","Circle":"Noida","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Ghori","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Kasna","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"Dadri","Circle":"Dadri","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Knowledge Park-I","Description":"","BranchType":"Sub Post Office","DeliveryStatus":"Delivery","Taluk":"Gautam Budh Nagar","Circle":"Gautam Budh Nagar","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Maicha","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Delivery","Taluk":"Maicha","Circle":"Maicha","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"},{"Name":"Tugalpur","Description":"","BranchType":"Branch Post Office","DeliveryStatus":"Non-Delivery","Taluk":"A.g.nioda","Circle":"A.g.nioda","District":"Gautam Buddha Nagar","Division":"Ghaziabad","Region":"Lucknow  HQ","State":"Uttar Pradesh","Country":"India"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest static void testBatchExecution() {
        // Create test Dispatch_Order__c records
            RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center'];

        List<Dispatch_Order__c> testOrders = new List<Dispatch_Order__c>();
             Stock_Keeping_Units__c stockUnit = new Stock_Keeping_Units__c();

         
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        
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
           
    nm_Centers__c    centerInformationCenter = new nm_Centers__c();
        centerInformationCenter.Name='Transit Center';
        centerInformationCenter.Nm_Active__c = true;
        centerInformationCenter.nm_CenterCode__c = 'abcd234';
        centerInformationCenter.nm_City__c = 'Mumbai - Mira Road East';
        centerInformationCenter.Contact_No_1__c = '9867167685';
        centerInformationCenter.nm_Country__c = 'India';
        centerInformationCenter.nm_StateProvince__c = 'Maharashtra';
        centerInformationCenter.nm_LearningCenter__c = centerLearningCenter.id;
        centerInformationCenter.nm_Street__c = 'Altmount Road';
        centerInformationCenter.nm_PostalCode__c = '400601';
     //   centerInformationCenter.RecordTypeID = informationCenter.id;
        
        insert centerInformationCenter;
        
         Stock__c stockFromCenter = new Stock__c();
        stockFromCenter.Centers__c = centerLearningCenter.id;
        stockFromCenter.Incoming_Quantity__c = 0;
        stockFromCenter.Outgoing_Quantity__c = 0;
        stockFromCenter.Quantity__c = 500;
        stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockFromCenter;
        
          Stock__c stockFromCenter2 = new Stock__c();
        stockFromCenter2.Centers__c = centerInformationCenter.id;
        stockFromCenter2.Incoming_Quantity__c = 0;
        stockFromCenter2.Outgoing_Quantity__c = 0;
        stockFromCenter2.Quantity__c = 500;
        stockFromCenter2.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockFromCenter2;


 Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Admission form & documents Approved');


        for (Integer i = 0; i < 5; i++) {
            testOrders.add(new Dispatch_Order__c(
                Generate_AirwayBill__c = true,
                Airway_Bill_Image__c = '',
                Order_Type__c = 'Student Order',
                Quantity__c = 1,
                Status_Of_Dispatch__c = 'Study Kit assigned',
                Stock_Keeping_Unit__c = stockUnit.id,
                Fed_Ex_Shipment_Created__c=true,
                From_Centers__c = centerLearningCenter.id,
                To_Student__c=objAccount.id
            ));
        }
        insert testOrders;

        // Mock the FedExWebService.createShipment callout
        Test.setMock(HttpCalloutMock.class, new RestMock());

        // Enqueue the batch job
        Test.startTest();
        AirWayBill batchInstance = new AirWayBill();
        Database.executeBatch(batchInstance);
        Test.stopTest();
    }
}