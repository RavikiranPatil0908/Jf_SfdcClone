@isTest(SeeAllData=false)
public  class SendEmailToPortalConfirmedAccountTracker {
    private class RestMockII implements HttpCalloutMock {
        RestMockII() {
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson ='{"status":"success","message":[{"Response":"success"}]}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Registration Done','1',objAccount,'admission');
        Stock_Keeping_Units__c  stockUnit = new Stock_Keeping_Units__c();
        stockUnit.Name = 'PGDBFM-S3-KIT';
        stockUnit.Cost__c = 100;
        stockUnit.Launch_Year__c = 'JUL2009';
        stockUnit.Number_of_Pages__c = 50;
        stockUnit.Type_Of_SKU__c = 'Kit';
        stockUnit.Program__c = 'PGDBFM';
        stockUnit.Semester__c='3';
        
        insert stockUnit;
        
        RecordType learningCenter = [select id from Recordtype where sobjectType='nm_Centers__c' AND name ='Learning Center']; 
          
        nm_Centers__c  centerLearningCenter = new nm_Centers__c();
        centerLearningCenter.Name='Transit Center';
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
        
         Stock__c stockFromCenter = new Stock__c();
        stockFromCenter.Centers__c = centerLearningCenter.id;
        stockFromCenter.Incoming_Quantity__c = 0;
        stockFromCenter.Outgoing_Quantity__c = 0;
        stockFromCenter.Quantity__c = 500;
        stockFromCenter.Stock_Keeping_Unit__c = stockUnit.id;
        
        insert stockFromCenter;
    
        Dispatch_Order__c objDsipatch = new Dispatch_Order__c();
       
        objDsipatch.Order_Type__c = 'Student Order';
        objDsipatch.Quantity__c = 1;
        objDsipatch.Status_Of_Dispatch__c = 'Transit';
        objDsipatch.From_Centers__c = centerLearningCenter.id;
        // objDsipatch.To_Centers__c = objAccount.nm_Centers__c;
        objDsipatch.Stock_Keeping_Unit__c = stockUnit.id;
        objDsipatch.To_Student__c=objAccount.id;
        objDsipatch.Tracking_Number__c ='abcdefgh';
        objDsipatch.Name_Of_Other_Courier_Service__c='Indian Post';
        objDsipatch.To_Student__c = objAccount.id;
        objDsipatch.Opportunity__c =objopp.id;
        objDsipatch.In_Transit__c =Date.Today().AddDays(-15); 
        
        insert objDsipatch;

    }

	@isTest
    static void testUnit2() {
        EmailTemplate obj = [SELECT Id, Name FROM EmailTemplate Where Name = 'dispatches of study kits of Sem -1 through India Post-1' LIMIT 1];
        Dispatch_Order__c objDispatch = [SELECT Id,To_Student__c from Dispatch_Order__c];
        Account objAcc = [SELECT Id from Account limit 1];
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        SendEmailToPortalConfirmedAccount.FlowInputs testFlowInput = new SendEmailToPortalConfirmedAccount.FlowInputs();
        testFlowInput.templateName = obj.Name;
        testFlowInput.recordId = objDispatch.To_Student__c;///objDispatch.Id;
        testFlowInput.type = 'what';
        testFlowInput.parentId = objAcc.Id;
        testFlowInput.mailId = 'test@example.com';
        testFlowInput.fromEmailId = 'fromtest@example.com';

        List<SendEmailToPortalConfirmedAccount.FlowInputs> testFlowInputsList = new List<SendEmailToPortalConfirmedAccount.FlowInputs>();
        testFlowInputsList.add(testFlowInput);

        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"status":"success"}');
        mockResponse.setStatusCode(200);
        Test.startTest();
        SendEmailToPortalConfirmedAccount.callSaveEmailToPortalAPI(testFlowInputsList);
        Test.stopTest();
    }
    @isTest
    static void testUnit1() {
        EmailTemplate obj = [SELECT Id, Name FROM EmailTemplate Where Name = 'dispatches of study kits of Sem -1 through India Post-1' LIMIT 1];
        Dispatch_Order__c objDispatch = [SELECT Id,To_Student__c from Dispatch_Order__c];
        Test.setMock(HttpCalloutMock.class, new RestMockII());
        SendEmailToPortalUsingTemplate.FlowInputs testFlowInput = new SendEmailToPortalUsingTemplate.FlowInputs();
        testFlowInput.templateName = obj.Name;
        testFlowInput.recordId = objDispatch.To_Student__c;///objDispatch.Id;
        testFlowInput.type = 'what';
        testFlowInput.sapId = '77848949849';
        testFlowInput.toMailId = 'test@example.com';
        testFlowInput.fromMailId = 'fromtest@example.com';

        List<SendEmailToPortalUsingTemplate.FlowInputs> testFlowInputsList = new List<SendEmailToPortalUsingTemplate.FlowInputs>();
        testFlowInputsList.add(testFlowInput);

        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"status":"success"}');
        mockResponse.setStatusCode(200);
        Test.startTest();
        SendEmailToPortalUsingTemplate.callSaveEmailToPortalAPI(testFlowInputsList);
        Test.stopTest();
    }
}