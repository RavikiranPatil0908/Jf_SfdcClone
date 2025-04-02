@isTest(SeeAllData=false)
public class CheckLoanDetailsControllerTracker {
    @TestSetup
    static void makeData(){
        Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',false,'Registered');
        Opportunity objOpp = nmGenericTracker.CreateOpportunityWithAccountAndProgram('Pending Payment - Loan','1','Bachelor Programs',objAccount,'Admission');
        objOpp.Loan_Type__c = 'LiquiLoans';
        objOpp.Account = objAccount;
        objOpp.Loan_Order_Status__c = 'Ready To Disbursed';
        objOpp.Tenure__c = '18';
        objOpp.Interest_Rate__c = '4.50';
        objOpp.Subvention_Value__c = 0.0;
        objOpp.Loan_Amount__c = '50000';
        update objOpp;

        objAccount.nm_Program__c = objOpp.nm_Program__c;
        objAccount.DEBID__c = '46377272';
        objAccount.is_Deb_verified__c = true;
        objAccount.Interview_Status__c = '';
        objAccount.Is_Mobile_Verified__c = true;
        objAccount.nm_IsEmailVerified__c = true;
        objAccount.is_Video_Call_Verified__c = true;
        update objAccount;
        nm_LinksForDocuments__c objDocument = nmGenericTracker.CreateDocumentforAccount(objAccount,'10th Marksheet');
        
        DEB_Detail__c objDeb = new DEB_Detail__c();
        objDeb.Date_of_Birth__c = date.newInstance(1990, 12, 9);
        objDeb.Is_Active__c = true;
        objDeb.Account__c = objAccount.Id;
        insert objDeb;

        Tenure__c objTenure = new Tenure__c();
        objTenure.Tenure__c = '18';
        objTenure.Subvention_Value__c = 0.0;
        objTenure.Interest_Rate__c = 4.50;
        objTenure.Loan_Type__c = 'LiquiLoans';
        objTenure.Choose_Program__c = 'Bachelor Programs';
        objTenure.Fee_Type__c = 'Admission';
        insert objTenure;
    }

    @isTest
    static void testMethod1() {
        Opportunity objOpp = [SELECT Id,Account.nm_Nationality__c FROM Opportunity LIMIT 1];
        Test.startTest();
        ApexPages.currentPage().getParameters().put('recordId',objOpp.id);
        CheckLoanDetailsController objLoan = new CheckLoanDetailsController();
        Test.stopTest();
    }
}