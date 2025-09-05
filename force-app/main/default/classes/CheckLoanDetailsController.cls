/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 13--05--2025
 * @last modified by  : @Ravi
**/
public without sharing class CheckLoanDetailsController {
    public String oppId {get;set;}
    public List<nm_LinksForDocuments__c> lstDocumentNotApproved {get;set;}
    public List<nm_LinksForDocuments__c> lstDocument {get;set;}
    public LoanApprovalWrapper objWrapper {get;set;}
    public Opportunity objOpp {get;set;}
    public Tenure__c objTenure {get;set;}

    public CheckLoanDetailsController() {
        oppId = '';
        lstDocumentNotApproved = new List<nm_LinksForDocuments__c>();
        lstDocument = new List<nm_LinksForDocuments__c>();
        objWrapper = new LoanApprovalWrapper();
        objOpp = new Opportunity();
        if (ApexPages.currentPage() != null) {
            oppId = ApexPages.currentPage().getParameters().get('recordId');
        }
        if (String.isNotBlank(oppId)) {
            checkForDocumentApproval();
            checkForInterview();
            checkDEBVerification();
            checkVVCCompleted();
            checkLoanStatus();
            checkTenureAndSubvention();
            checkTenureMatch();
            checkLoanEligibility();
            checkLateFeePayment();
        }
    }

    public void checkLateFeePayment() {
        List<nm_Payment__c> lstPayment = new List<nm_Payment__c>();
        List<Calender__c> lstCalender = new List<Calender__c>();
        List<Late_Fee__c> lstLateFee = new List<Late_Fee__c>();
        List<OpportunityLineItem> lstLineItem = new List<OpportunityLineItem>();
        Date closedWonDate = objOpp.ClosedWonDateTime__c != null ? objOpp.ClosedWonDateTime__c.date() : null;
        //Boolean isLateFeeApplicable = false;
         //Boolean isProductAdded = false;
         //Boolean isLateFeePending = false;

        // Integer productLateFee = 0;
        // Integer totalAmount = 0;
        // Integer lateFeeApplicableAmount = 0;
        Integer lateFeeAmount = 0;
        
        String category = objOpp.Is_Re_Registration_Payment__c ? 'Re-Registration' : 'Admission';
        lstPayment = [SELECT Id,nm_TransactionDate__c,nm_Amount__c FROM nm_Payment__c WHERE nm_OpportunityNew__c =:oppId AND (nm_PaymentStatus__c = 'Payment Approved' OR nm_PaymentStatus__c = 'Payment Made') AND nm_PaymentType__c = 'Late Fees' order by CreatedDate ASC];
        lstCalender = [SELECT Id,Session_Start_Date__c,Session_End_Date__c FROM Calender__c WHERE Session__c=:objOpp.nm_Session__c AND Year__c=:objOpp.nm_Year__c AND Category__c=:category AND nm_Type__c=:objOpp.ChooseProgram__c AND nm_Semester__c=:objOpp.nm_Semester__c AND Specialisation__c=:objOpp.Specialisation__c LIMIT 1];
        lstLateFee = [SELECT Id,Start_Date__c,End_Date__c,Late_Fees__c FROM Late_Fee__c WHERE Session__c=:objOpp.nm_Session__c AND Year__c=:String.valueOf(objOpp.nm_Year__c) AND Category__c=:category AND nm_Type__c=:objOpp.ChooseProgram__c AND Program_Type__c=:objOpp.Specialisation__c order by Start_Date__c ASC];
        lstLineItem = [SELECT Id,ActualSalePrice__c FROM OpportunityLineItem WHERE Opportunity.Id=:oppId AND Product_Name__c='Late Fee' AND IsDeleted=false];
        if (lstLineItem.size() > 0) {
            for (OpportunityLineItem objLineItem : lstLineItem) {
                Integer intUnitPrice = objLineItem.ActualSalePrice__c != null ? Integer.valueOf(objLineItem.ActualSalePrice__c) : 0;
                objWrapper.productLateFee += intUnitPrice;
                // objWrapper.productLateFee += Integer.valueOf(objLineItem.ActualSalePrice__c);
            }
        }

        for ( nm_Payment__c objPayment : lstPayment) {
            objWrapper.totalAmount += Integer.valueOf(objPayment.nm_Amount__c);
            for (Late_Fee__c objLateFee : lstLateFee) {
                if (objPayment.nm_TransactionDate__c >= objLateFee.Start_Date__c && objPayment.nm_TransactionDate__c <= objLateFee.End_Date__c) {
                    lateFeeAmount = Integer.valueOf(objLateFee.Late_Fees__c) > lateFeeAmount ? Integer.valueOf(objLateFee.Late_Fees__c) : lateFeeAmount;
                    break;
                }
            }
        }

        for (Late_Fee__c obj : lstLateFee) {
            // if (obj.Start_Date__c <= objOpp.Account.Account_Confirm_Date__c && obj.End_Date__c >= objOpp.Account.Account_Confirm_Date__c) {
            //     lateFeeApplicableAmount = obj.Late_Fees__c > lateFeeApplicableAmount ? obj.Late_Fees__c : lateFeeApplicableAmount;
            // }
            // if (objOpp.StageName != 'Closed Won' && obj.Start_Date__c <= Date.today() && obj.End_Date__c >= Date.today()) {
            //     lateFeeApplicableAmount = obj.Late_Fees__c > lateFeeApplicableAmount ? obj.Late_Fees__c : lateFeeApplicableAmount;
            // }
            Boolean isWithinAccountConfirmDate = closedWonDate != null ? (obj.Start_Date__c <= closedWonDate &&
                                          obj.End_Date__c >= closedWonDate && objOpp.StageName == 'Closed Won') : false;
                                          System.debug('obj.Start_Date__c--->' + obj.Start_Date__c);
                                          System.debug('obj.End_Date__c--->' + obj.End_Date__c);
                                          System.debug('closedWonDate--->' + closedWonDate);
    
            Boolean isWithinTodayDate = (objOpp.StageName != 'Closed Won' &&
                                        obj.Start_Date__c <= Date.today() &&
                                        obj.End_Date__c >= Date.today());

            if (isWithinAccountConfirmDate || isWithinTodayDate) {
                objWrapper.lateFeeApplicableAmount = Math.max(objWrapper.lateFeeApplicableAmount, Integer.valueOf(obj.Late_Fees__c));
            }
        }

        if (objWrapper.lateFeeApplicableAmount == 0 && objOpp.StageName != 'Closed Won') {
            List<Late_Fee__c> lstLateFeeForCheck = new List<Late_Fee__c>();
            lstLateFeeForCheck = [SELECT Id,Start_Date__c,End_Date__c,Late_Fees__c FROM Late_Fee__c WHERE Session__c=:objOpp.nm_Session__c AND Year__c=:String.valueOf(objOpp.nm_Year__c) AND Category__c=:category AND nm_Type__c=:objOpp.ChooseProgram__c AND Program_Type__c=:objOpp.Specialisation__c AND End_Date__c < TODAY ORDER BY End_Date__c DESC LIMIT 1];

            if (lstLateFeeForCheck.size() > 0) {
                objWrapper.lateFeeApplicableAmount = Integer.valueOf(lstLateFeeForCheck[0].Late_Fees__c);
            }
        }
        
        if (objOpp.StageName == 'Closed Won') {
            objWrapper.isLateFeeApplicable = lstPayment.size() > 0 || objWrapper.lateFeeApplicableAmount > 0 ? true : false;
            // objWrapper.isProductAdded = objWrapper.totalAmount == objWrapper.productLateFee && objWrapper.totalAmount == objWrapper.lateFeeApplicableAmount ? true : false;
            objWrapper.isProductAdded = objWrapper.productLateFee == objWrapper.lateFeeApplicableAmount ? true : false;
            objWrapper.isLateFeePending = (objWrapper.lateFeeApplicableAmount - objWrapper.totalAmount) > 0 ? true : false;
        }
        else {
            objWrapper.isLateFeeApplicable = lstPayment.size() > 0 || objWrapper.lateFeeApplicableAmount > 0 ? true : false;
            objWrapper.isLateFeePending = (objWrapper.lateFeeApplicableAmount - objWrapper.totalAmount) > 0 ? true : false;
            //objWrapper.isProductAdded = objWrapper.totalAmount == objWrapper.productLateFee && objWrapper.totalAmount == objWrapper.lateFeeApplicableAmount ? true : false;
            objWrapper.isProductAdded = objWrapper.lateFeeApplicableAmount > 0 && objWrapper.productLateFee == objWrapper.lateFeeApplicableAmount ? true : false;
        }
    }

    public void checkForDocumentApproval() {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id,Account.Interview_Status__c,Is_Re_Registration_Payment__c,Specialisation__c,StageName,ClosedWonDateTime__c,nm_Session__c,nm_Year__c,ChooseProgram__c,nm_Semester__c,Interest_Rate__c,nm_Program__r.Specialisation__c,Account.DEBID__c,Account.is_Deb_verified__c,Account.nm_DateOfBirth__c,Account.BatchStartD__c,Loan_Type__c,Loan_Order_Status__c,ActualPendingAmount__c,Loan_Amount__c,Account.Program_Type__c,Account.nm_ProgramType__c,nm_Fee_Type__c,Subvention_Value__c,Tenure__c,Account.is_Video_Call_Verified__c,Account.nm_IsEmailVerified__c,Account.Is_Mobile_Verified__c,Account.nm_Domicile__c,Account.nm_Nationality__c,Loan_Approved__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
        if (lstOpportunity.size() > 0) {
            objOpp = lstOpportunity[0];
            lstDocument = [SELECT Id,nm_Status__c,nm_DocumentName__c FROM nm_LinksForDocuments__c WHERE nm_Status__c != 'Not Applicable' AND nm_Account__c =:objOpp.AccountId];
        }
        for (nm_LinksForDocuments__c objDocument : lstDocument) {
            if (objDocument.nm_Status__c != 'Approved' && objDocument.nm_Status__c != 'Admission Form & Documents Provisional') {
                lstDocumentNotApproved.add(objDocument);
            }
        }
        objWrapper.isDocumentApproved = lstDocument.size() > 0 && lstDocumentNotApproved.size() == 0 ? true : false;
    }

    public void checkForInterview() {
        if (objOpp != null) {
            objWrapper.isInterviewStatusSelected = objOpp.Account.Interview_Status__c == 'Selected' ? true : false;
            objWrapper.isInterviewApplicable = objOpp.nm_Program__r.Specialisation__c == 'MBA (WX)' ? true : false;
        }
    }

    public void checkDEBVerification() {
        List<DEB_Detail__c> lstDebDetails = new List<DEB_Detail__c>();
        Date dt = Date.newInstance(2024, 7, 1);
        lstDebDetails = [SELECT Id,Date_of_Birth__c,Is_Active__c FROM DEB_Detail__c WHERE Is_Active__c =: true AND Account__c =:objOpp.AccountId ORDER BY CreatedDate DESC LIMIT 1];
         if(objOpp.Account.BatchStartD__c != null && objOpp.Account.BatchStartD__c < dt){
             objWrapper.isDEBApplicable = false;
          }
        if ((objOpp.Account.nm_Nationality__c == 'Indian' || objOpp.Account.nm_Nationality__c == 'India') && (objOpp.Account.BatchStartD__c == null || objOpp.Account.BatchStartD__c >= dt) ) {
            objWrapper.isDEBApplicable = true;
            if (lstDebDetails.size() > 0) {
                objWrapper.isDEBVerified = lstDebDetails.size() > 0 && String.isNotBlank(objOpp.Account.DEBID__c) && objOpp.Account.is_Deb_verified__c && objOpp.Account.nm_DateOfBirth__c == lstDebDetails[0].Date_of_Birth__c ? true : false;
            }
            else {
                objWrapper.isDEBVerified = false;
            }
            //objWrapper.isDEBVerified = lstDebDetails.size() > 0 && String.isNotBlank(objOpp.Account.DEBID__c) && objOpp.Account.is_Deb_verified__c && objOpp.Account.nm_DateOfBirth__c == lstDebDetails[0].Date_of_Birth__c ? true : false;
        }
    }

   public void checkVVCCompleted(){
          Date dt = Date.newInstance(2024, 7, 1);
          if(objOpp.Account.BatchStartD__c != null && objOpp.Account.BatchStartD__c < dt ){
             objWrapper.isVVCApplicable = false;
             objWrapper.isVVCCompleted =true;
          }
           if(objOpp.Account.is_Video_Call_Verified__c == true ) {
             objWrapper.isVVCCompleted =true;
           }
    }

    public void checkLoanStatus() {
        if (objOpp.Loan_Type__c == 'LiquiLoans' && objOpp.Loan_Order_Status__c == 'Ready To Disbursed') {
            objWrapper.isLoanReadyForDisbursement = true;
        }
        else if (objOpp.Loan_Type__c == 'Propelld' && objOpp.Loan_Order_Status__c == 'DISBURSAL_REQUESTED') {
            objWrapper.isLoanReadyForDisbursement = true;
        }
        else if (objOpp.Loan_Type__c == 'GrayQuest' && objOpp.Loan_Order_Status__c == 'emi.process.completed') {
            objWrapper.isLoanReadyForDisbursement = true;
        }
        else if (objOpp.Loan_Type__c == 'Avanse' && objOpp.Loan_Order_Status__c == 'Ops Under Approval') {
            objWrapper.isLoanReadyForDisbursement = true;
        }
        Integer loanAmount = objOpp.Loan_Amount__c != null ? Integer.valueOf(objOpp.Loan_Amount__c) : 0;
        objWrapper.isLoanAmountAndActualPending = objOpp.ActualPendingAmount__c == loanAmount && loanAmount > 0 ? true : false;
    }

    public void checkTenureAndSubvention() {
        List<Tenure__c> lstTenure = new List<Tenure__c>();
        String feeType = objOpp.nm_Fee_Type__c;
        List<String> programs = new List<String>{'Master Programs','MBA (Online) Programs'};
        String programType = String.isNotBlank(objOpp.Account.Program_Type__c) && programs.contains(objOpp.Account.nm_ProgramType__c) ? objOpp.Account.Program_Type__c : null;
        List<String> admissionFeeTypeLst = new List<String>{'MBAallTermfee','admission','registration','InitialAdmissionFee','ReRegistrationPayment'};
        if(admissionFeeTypeLst.contains(feeType)) {
            feeType = 'Admission';
        }
        //String programType = String.isNotBlank(objOpp.Account.Program_Type__c) ? objOpp.Account.Program_Type__c : 'null';
        String key = objOpp.Account.nm_ProgramType__c + '-' + programType +'-'+ objOpp.Loan_Type__c +'-'+ feeType;
        System.debug('key---->' + key);
        lstTenure = [SELECT Id,Key__c,Tenure__c,Subvention_Value__c,Interest_Rate__c FROM Tenure__c WHERE Key__c =: key AND IsActive__c = true AND Tenure__c =: objOpp.Tenure__c LIMIT 1];
        if (lstTenure.size() > 0) {
            objTenure = lstTenure[0];
        }
    }

    public void checkTenureMatch() {
        if (objTenure != null) {
            objWrapper.isInterestMatch = Decimal.valueOf(objOpp.Interest_Rate__c) == objTenure.Interest_Rate__c ? true : false;
            objWrapper.isSubventionMatch = objOpp.Subvention_Value__c == objTenure.Subvention_Value__c ? true : false;
        }
        else {
            objWrapper.isInterestMatch = false;
            objWrapper.isSubventionMatch = false;
        }
    }

    public void checkLoanEligibility() {
        if (objWrapper.isDocumentApproved && objWrapper.isVVCCompleted && objOpp.Account.nm_IsEmailVerified__c
            && objOpp.Account.Is_Mobile_Verified__c && objWrapper.isLoanReadyForDisbursement && objWrapper.isLoanAmountAndActualPending
            && objWrapper.isInterestMatch && objWrapper.isSubventionMatch) {
                if (objWrapper.isInterviewApplicable) {
                    objWrapper.isEligiableForloan = objWrapper.isInterviewStatusSelected;
                } 
                else {
                    objWrapper.isEligiableForloan = true;
                }
            objWrapper.isEligiableForloan = !objWrapper.isDEBApplicable || (objWrapper.isDEBApplicable && objWrapper.isDEBVerified) ? objWrapper.isEligiableForloan : false;
            objWrapper.isEligiableForloan = objWrapper.lateFeeApplicableAmount == objWrapper.totalAmount && objWrapper.totalAmount == objWrapper.productLateFee ? objWrapper.isEligiableForloan : false;
        }
        // else if (objOpp.Loan_Approved__c) {
        //     objWrapper.isEligiableForloan = true;
        // }
    }

    public class LoanApprovalWrapper {
        public Boolean isDocumentApproved {get;set;}
        public Boolean isInterviewStatusSelected {get;set;}
        public Boolean isDEBVerified {get;set;}
        public Boolean isVVCCompleted {get;set;}
        public Boolean isVVCApplicable{get;set;}
        public Boolean isInterviewApplicable {get;set;}
        public Boolean isLoanReadyForDisbursement {get;set;}
        public Boolean isLoanAmountAndActualPending {get;set;}
        public Boolean isEligiableForloan {get;set;}
        public Boolean isInterestMatch {get;set;}
        public Boolean isDEBApplicable {get;set;}
        public Boolean isSubventionMatch {get;set;}
        public Boolean isLateFeeApplicable {get;set;}
        public Boolean isProductAdded {get;set;}
        public Boolean isLateFeePending {get;set;}
        public Integer lateFeeApplicableAmount {get;set;}
        public Integer productLateFee {get;set;}
        public Integer totalAmount {get;set;}

        public LoanApprovalWrapper () {
            isDocumentApproved = false;
            isInterviewApplicable = false;
            isDEBVerified = false;
            isVVCCompleted = false;
            isVVCApplicable = true;
            isInterviewApplicable = false;
            isLoanReadyForDisbursement = false;
            isLoanAmountAndActualPending = false;
            isEligiableForloan = false;
            isInterestMatch = false;
            isDEBApplicable = false;
            isSubventionMatch = false;
            isLateFeeApplicable = false;
            isProductAdded = false;
            isLateFeePending = false;
            lateFeeApplicableAmount = 0;
            productLateFee = 0;
            totalAmount = 0;
        }
    }
}