@isTest
private class nmDocVerificationTracker {
    
    public static Opportunity objopp;
    public static Account objAccount;
    public static nm_LinksForDocuments__c  objDoc;
    
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
    public static testmethod void testMethod1() 
    {
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        nmDocVerification obj = new nmDocVerification();
        obj.ChangeDocumentsStatus();
        obj.save();
        obj.Back();
        obj.getLstOptionStatus();
    }
     public static testmethod void testMethod2() 
     {
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        ObjDoc.nm_Status__c = 'Disapproved';
        update ObjDoc;
        nmDocVerification obj = new nmDocVerification();
        obj.ChangeDocumentsStatus();
    }
    public static testmethod void testMethod3() 
    {
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        ObjDoc.nm_Status__c = 'Admission Form & Documents Provisional';
        update ObjDoc;
        nmDocVerification obj = new nmDocVerification();
        obj.ChangeDocumentsStatus();
    }
    public static testmethod void testMethod4() 
    {
        LoadData();
        ApexPages.currentPage().getParameters().put('id',objAccount.id);
        ObjDoc.nm_Status__c = 'Re-Submited';
        update ObjDoc;
        nmDocVerification obj = new nmDocVerification();
        obj.ChangeDocumentsStatus();
    } 
    public static void LoadData()
    {   
         Test.setMock(HttpCalloutMock.class, new RestMock());
         nmGenericTracker.InsertSerialNo();
         objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents submitted');  
         objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
         nmGenericTracker.CreateOpportunityLineItem(objopp);   
         objDoc = nmGenericTracker.CreateDocumentforAccount(objAccount,'Aadhaar Card');
    }
}