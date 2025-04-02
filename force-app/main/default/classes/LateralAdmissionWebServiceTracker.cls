@isTest
private class LateralAdmissionWebServiceTracker{

    private static Set<Id> accountIds = new Set<Id>();
    private static Set<Id> leadId = new Set<Id>();
    private static Set<String> setofEmail = new Set<String>();
    private static Set<String> setofCurrentMobile = new Set<String>();

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup static void setup(){
        nmGenericTracker.InsertSerialNo();
        nmGenericTracker.CreateCenter('MumbaiIT');
       /* Calender__c objCal = new Calender__c();
        objCal.Session_Start_Date__c = system.today();
        objCal.Session__c = 'January';
        objCal.Year__c = 2021;
        objCal.Session_End_Date__c = system.today()+1;
        insert objCal;
        Lead objLead = nmGenericTracker.CreateLeadWithProgramAndCenterAndECForGivenDefenceAndLateral('No',false);
        objLead.nm_Year__c = 2021;
        update objLead;
*/
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
        objAccount.nm_Tagged_Pricebook__c = null;
       // objAccount.nm_LeadId__c = String.valueOf(objLead.id).left(17)+'A';
        objAccount.nm_DateOfBirth__c =system.today();
        update objAccount;

        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','1',objAccount,'admission');
        nmGenericTracker.CreateOpportunityLineItem(objopp);
        Opportunity objopp1 = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Closed Won','2',objAccount,'admission');
        objopp1.nm_Session__c = 'July';
        objopp1.nm_Year__c = 2021;
        objopp1.Is_Re_Registration_Payment__c = true;
        nmGenericTracker.CreateOpportunityLineItem(objopp1);
        update objopp1;

        nm_Payment__c objPayment =nmGenericTracker.CreatePaymentRecordForOpportunity(objopp, 'Admission');
        objPayment.nm_PaymentStatus__c = 'Payment Approved';
        update objPayment;
        // nm_Payment__c objPayment1 =nmGenericTracker.CreatePaymentRecordForOpportunity(objopp1, 'Admission');
        // objPayment1.nm_PaymentStatus__c = 'Payment Approved';
        // update objPayment1;
        
    }

    static testMethod void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // code_block   
        Test.startTest();
        List<Account> acc = [SELECT id,PersonEmail, PersonMobilePhone,nm_RegistrationNumber__c,nm_StudentNo__c, nm_LeadId__c from Account];
        LateralAdmissionWebService.createLateralAdmission(acc[0], '', '');
        Test.stopTest();

    }
    static testMethod void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // code_block   
        Test.startTest();
        Map<String, String> result = new Map<String, String>();
        // result.put(oppss[0].id, 'admission');
        result.put('aaaaa', 'admission');
        String jsonstring = System.JSON.serialize(result);
        LateralAdmissionWebService.sendEmailToFinanceDepartmentOnPaymentCreation('asasda', 'asdasdas', 'asdasdasd');
        
        // Map<String, String> result1 = new Map<String, String>();
        // result1.put(oppss[0].id, '{Id: sasda}');
        
        
        // String jsonstring1 = System.JSON.serialize(result1);

        LateralAdmissionWebService.dummy(jsonstring);   
        Test.stopTest();

    }

    // @isTest static void testMethod2() {
    //  // code_block   
    // }
}