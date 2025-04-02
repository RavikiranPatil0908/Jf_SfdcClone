@isTest(SeeAllData = TRUE)

public class testClassICPayment
{
    static testMethod void iCPaymentTestMethod()
    {

       // User u = [select id from User where Profile.Name='System Administrator' LIMIT 1];
           Profile p = [SELECT Id FROM Profile where name='System Administrator']; 
       User u = new User(Alias = 'standtss', Email='standarduser1231@testorg.com', 
       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id, IsActive = true,
       TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1232@testorg.com');
       
      
        
        insert u;
        System.runAs(u)
        {
        
         /*
         Account objAct = [select id,LastName,Account_Confirm_Date__c,nm_Centers__c from Account where nm_StudentStatus__c = 'Confirmed' LIMIT 1];
         
      
         Opportunity objopp = new Opportunity();
         objopp.accountid= objAct.Id;
         objOpp.StageName = 'Payment received -Finance approval given';
         objOpp.Name='Test Opp';
         objOpp.CloseDate = System.Today();  
         objOpp.Processed__c = FALSE;
         objOpp.nm_Year__c = 2014.0;
         objOpp.nm_Session__c  = 'July';
      
         insert objOpp;
     
      
         OpportunityLineItem objOppLnItm = new OpportunityLineItem();
         Pricebook2 pb2 = [select id from Pricebook2 where name = 'Standard Price Book' LIMIT 1];
         Product2 pd2 = [select id,Name from Product2 where name Like 'Semester%' LIMIT 1];
         
         //PricebookEntry pbe = [select id from PricebookEntry LIMIT 1];
         
         //[select Product_Name__c,UnitPrice,Opportunity.ID from OpportunityLineItem where Product_Name__c LIKE 'Semester%' LIMIT 1];
         
         PricebookEntry pbe = new PricebookEntry();
         pbe.Pricebook2Id = pb2.Id;
         pbe.Product2Id = pd2.Id;
         pbe.UnitPrice = 18000.00;
         pbe.IsActive = TRUE;
         insert pbe;
         
         objOppLnItm.OpportunityId = objOpp.Id;
         objOppLnItm.UnitPrice = 18000.00;
         objOppLnItm.Quantity = 1.00;
         objOppLnItm.PriceBookEntryID = pbe.Id;
         
         insert objOppLnItm;
         
      
        */
        
   
         Opportunity objopp; 
         List<Opportunity>  opptyList = [select StageName,Id,nm_DemandDraftNumber__c,nm_TransactionID__c,Account.Name,Account.Account_Confirm_Date__c,Account.nm_StudentStatus__c,Account.nm_Centers__c,BB_Admission_Date__c,nm_Session__c,nm_Year__c,
        (select Product_Name__c, UnitPrice from OpportunityLineItems where Product_Name__c LIKE 'Semester%') 
        from Opportunity where StageName = 'Payment received -Finance approval given' and processed__C = TRUE LIMIT 1];
        
        if(!opptyList.isEmpty()){
            objopp =  opptyList.get(0);
            objOpp.Name = 'New Opp';
            objopp.processed__C = FALSE;
            update objOpp;
        }
        
        
        opptyList = [select StageName,Id,nm_DemandDraftNumber__c,nm_TransactionID__c,Account.Name,Account.Account_Confirm_Date__c,Account.nm_StudentStatus__c,Account.nm_Centers__c,BB_Admission_Date__c,nm_Session__c,nm_Year__c,
        (select Product_Name__c, UnitPrice from OpportunityLineItems where Product_Name__c LIKE 'Semester%') 
        from Opportunity where StageName = 'Payment received -Finance approval given' and processed__C = FALSE LIMIT 1];
        
        if(!opptyList.isEmpty()){
            objopp =  opptyList.get(0);
            objOpp.Name = 'New Opp';
            objopp.processed__C = FALSE;
            update objOpp;
        }
        
        opptyList = [select StageName,Id,nm_DemandDraftNumber__c,nm_TransactionID__c,Account.Name,Account.Account_Confirm_Date__c,Account.nm_StudentStatus__c,Account.nm_Centers__c,BB_Admission_Date__c,nm_Session__c,nm_Year__c,
        (select Product_Name__c, UnitPrice from OpportunityLineItems where Product_Name__c LIKE 'Semester%') 
        from Opportunity where StageName = 'Payment received -Finance approval given' and processed__C = TRUE LIMIT 1];
        
        if(!opptyList.isEmpty()){
            objopp =  opptyList.get(0);
            objOpp.Name = 'New Opp';
            objopp.processed__C = FALSE;
            update objOpp;
        }
        
        
        opptyList = [select StageName,Id,nm_DemandDraftNumber__c,nm_TransactionID__c,Account.Name,Account.Account_Confirm_Date__c,Account.nm_StudentStatus__c,Account.nm_Centers__c,BB_Admission_Date__c,nm_Session__c,nm_Year__c,
        (select Product_Name__c, UnitPrice from OpportunityLineItems where Product_Name__c LIKE 'Semester%') 
        from Opportunity where StageName = 'Payment received -Finance approval given' and processed__C = FALSE LIMIT 1];
        
        if(!opptyList.isEmpty()){
            objopp =  opptyList.get(0);
            objOpp.Name = 'New Opp';
            objopp.processed__C = FALSE;
            update objOpp;
        }
        
        
        }
    }   
    
}