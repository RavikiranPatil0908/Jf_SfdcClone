@istest(SeeAllData=true)
public class ValidityExtensionPaymentTracker {

    public static Account objAccount;
    public static nm_Payment__c objPayment2;
    public static Validity_Extension__c objValEx;
    public static Opportunity objopp;
    
    private class RestMock implements HttpCalloutMock {
        RestMock() {
            
        }
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private static testmethod void unitTest1()
        {
            Test.setMock(HttpCalloutMock.class, new RestMock());
            objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Admission form & documents submitted');
            objopp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Payment Made','1','Post Graduate Diploma Programs',objAccount,'admission');
            
            objPayment2 = new nm_Payment__c();
            nm_Payment__c objPaymnt2 = new nm_Payment__c(); 
            objPaymnt2.nm_PaymentType__c='Admission';
            objPaymnt2.nm_ModeOfPayment__c='Demand Draft';
            objPaymnt2.nm_DemandDraftNumber__c='234234';
            objPayment2.nm_Amount__c=17000;
            objPaymnt2.nm_ModeOfPayment__c ='Demand Draft';
            objPaymnt2.nm_OpportunityNew__c =objopp.id;
            objPaymnt2.nm_BankLocation__c='noida';
            objPaymnt2.nm_DispatchDate__c=system.today();
            //insert objPaymnt2; 
            
            objValEx = new Validity_Extension__c();
            objValEx.Batch_Name__c='JUL2015';
            objValEx.Expiry_Date_Of_Program__c='2020';
            objValEx.Mobile_Number__c='242343254326534';
            objValEx.Name_Of_Account__c='Fagu Babu';
            objValEx.Student_Number_Of_Account__c='77115000170';
            objValEx.Student_Program_Validity__c='Post Graduate Diploma in Supply Chain Management';
            objValEx.Related_Account__c=objAccount.id;
            insert objValEx;
            
            ApexPages.currentPage().getParameters().put('id',objAccount.Id);
            PageReference pgURL = new PageReference('/apex/nmSubmitToBillDesk');
            Blob beforeblob = Blob.valueOf('22225');
            ValidityExtensionPaymentController obj = new ValidityExtensionPaymentController();
            obj.GetStudentNumber(objAccount.Id);
            obj.MakePayment();
            obj.MakeOnlinePaymentForExtension(17000);
            obj.SaveDD();
            
        }
}