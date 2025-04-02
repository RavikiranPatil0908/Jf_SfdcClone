/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 07-29-2021
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-13-2021   @BK   Initial Version
**/
@isTest(SeeAllData=false)
public class GetLoanDetailsServiceTracker {
    
    @testSetup 
    public static void setUpData(){ 
        List<Tenure__c> lstSS = new List<Tenure__c>();

        Tenure__c objSS1 = new Tenure__c();
        objSS1.Choose_Program__c = 'Master Programs';
        objSS1.Fee_Type__c = 'FullFee';
        objSS1.Interest_Rate__c = 0.0;
        objSS1.Loan_Type__c = 'Zest';
        objSS1.Program_Type__c = 'MBA (WX)';
        objSS1.Subvention_Value__c = 8;
        objSS1.Tenure__c = '15';
        objSS1.IsActive__c = true;
        lstSS.add(objSS1);

        Tenure__c objSS2 = objSS1.clone();
        objSS2.Tenure__c = '12';
        lstSS.add(objSS2);

        Tenure__c objSS3 = objSS1.clone();
        objSS1.Interest_Rate__c = 0.95;
        lstSS.add(objSS3);

        insert lstSS;
    }


    @isTest
	static void unitTest1() {

        Test.startTest();
            String chooseProgram = 'Master Programs';
            GetLoanDetailsService.getLoanDetails(chooseProgram);
            GetLoanDetailsService.generateChecksumForSession('test');
        Test.stopTest();
    }
}