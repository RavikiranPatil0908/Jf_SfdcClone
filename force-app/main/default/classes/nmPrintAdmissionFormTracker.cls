@istest(SeeAllData=false)
public class nmPrintAdmissionFormTracker { 
	@testSetup static void setup(){
		nmGenericTracker.InsertSerialNo();
		nmGenericTracker.CreateCenter('MumbaiIT');
		Account objAccount = nmGenericTracker.CreateAccountWithCenterAndECForGivenDefenceAndLateralAndStatus('Yes',false,'Confirmed');
		objAccount.nm_DateOfBirth__c =system.today();
		update objAccount;    
		Opportunity objopp = nmGenericTracker.CreatePGOpportunityWithAccountAndProgramForGivenStageAndSem('Pending Payment','1',objAccount,'admission');
    }
  	static  testmethod  void unitTest1() {     
		PageReference pg = new PageReference('/apex/nmPrintAdmissionForm');
		List<Account> objAccount1 = [Select Id From Account LIMIT 1];
		Test.setCurrentPage(pg);apexpages.currentpage().getparameters().put('id',objAccount1[0].id);
		nmPrintAdmissionForm objnmPrint=new nmPrintAdmissionForm();
		objnmPrint.OtpCode = '1111';
		objnmPrint.Otp = '1111';
		objnmPrint.PrintForm();
		objnmPrint.sendOTP();
		objnmPrint.VerifyOTP();
		objnmPrint.generateOTPMSG();
		objnmPrint.sendEmail();
		objnmPrint.showEmailContentToFalse();
    }
}