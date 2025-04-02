@isTest()
public class DispatchTrackingOrderTracker {

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
   // Dispatch_Order__c objDsipatch =  nmGenericTracker.DispatchOrder(stockUnit);
    
     Dispatch_Order__c objDsipatch = new Dispatch_Order__c();
       
         objDsipatch.Order_Type__c = 'Student Order';
         objDsipatch.Quantity__c = 1;
         objDsipatch.Status_Of_Dispatch__c = 'Transitgdggd';
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
    @IsTest
    static void SelectedNo(){
        Test.startTest();
        PageReference pg = new PageReference('/apex/nmPrintAdmissionForm');
        Test.setCurrentPage(pg);apexpages.currentpage().getparameters().put('trackingNo','abcdefgh');
        Test.setCurrentPage(pg);apexpages.currentpage().getparameters().put('isOrderReceived','Yes');
        DispatchTrackingOrder dis = new DispatchTrackingOrder();
        dis.updateStudentResponse();
        Test.stopTest();
        
    }
}