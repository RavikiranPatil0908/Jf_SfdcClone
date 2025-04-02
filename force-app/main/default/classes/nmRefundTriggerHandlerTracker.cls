/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @BK
**/
@istest(SeeAllData=false)
public class nmRefundTriggerHandlerTracker{
     @testSetup
    public static void setUpData(){
         Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('No',true,'Registered');
        Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Payment Made','1',objAccount,'admission');
        List<nmRefund_Payment__c> lstRP = new List<nmRefund_Payment__c>();
         nmRefund_Payment__c objRefund = new nmRefund_Payment__c();
        objRefund.nm_Amount__c = 200;
        objRefund.nm_Payment_Status__c = 'Refund Initiated';      
        objRefund.Opportunity__c = objopp.id;
        objRefund.Account__c = objAccount.id;
        objRefund.nm_Transaction_Date__c = system.today();
        objRefund.Reason_For_Refund__c = 'Test';
        objRefund.Refund_transfer_Mode__c = 'Same A/c from which payment was made';
        objRefund.Type_of_Refund__c = 'Admission Rejected';
        objRefund.Name_of_loan_provider__c  ='EduVanz';
		lstRP.add(objRefund);

		nmRefund_Payment__c objRefund2 = objRefund.clone();
		objRefund2.Refund_to_Loan_Provider__c = true;
		lstRP.add(objRefund2);
        
		insert lstRP;
        
      /*  Loan_Provider_NEFT__mdt objloanProvider = new Loan_Provider_NEFT__mdt ();
        
        objloanProvider.Account_Holder_name__c = 'tes';
        objloanProvider.Account_Number__c ='awrd';
        objloanProvider.Bank_Location__c ='waerq';
        objloanProvider.IFSC_Code__c = 'qwrqw';
        objloanProvider.Name_of_the_Bank__c = 'qweqw';
        objloanProvider.DeveloperName = 'EduVanz';
        
        insert objloanProvider; */
        
        
    }
        public static testmethod void unitTest(){   
        
          nmRefund_Payment__c objRefund = [select id,Account_Number__c,Refund_to_Loan_Provider__c ,Account_Holder_name__c,IFSC_Code__c,nm_Bank_Location__c,nm_Name_of_the_Bank__c,Name_of_loan_provider__c  from nmRefund_Payment__c  limit 1];
          
          Loan_Provider_NEFT__mdt objloanProvider = [select id,Account_Holder_name__c,Account_Number__c,Bank_Location__c,IFSC_Code__c,Name_of_the_Bank__c,DeveloperName from Loan_Provider_NEFT__mdt limit 1 ];  
          
            Test.startTest();
            objRefund.Refund_to_Loan_Provider__c  =true;
            
            update objRefund;
            //objRefund2.Name_of_loan_provider__c  ='EduVanz';
            
          //  getQueryAllFieldSql.('nmRefund_Payment__c' ,'','Account_Number__c');

            Test.stopTest();

        }
}