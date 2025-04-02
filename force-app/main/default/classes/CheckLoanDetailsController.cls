/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : @vickysahu
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
            checkLoanStatus();
            checkTenureAndSubvention();
            checkTenureMatch();
            checkLoanEligibility();
        }
    }

    public void checkForDocumentApproval() {
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity = [SELECT Id,Account.Interview_Status__c,Interest_Rate__c,nm_Program__r.Specialisation__c,Account.DEBID__c,Account.is_Deb_verified__c,Account.nm_DateOfBirth__c,Loan_Type__c,Loan_Order_Status__c,ActualPendingAmount__c,Loan_Amount__c,Account.Program_Type__c,Account.nm_ProgramType__c,nm_Fee_Type__c,Subvention_Value__c,Tenure__c,Account.is_Video_Call_Verified__c,Account.nm_IsEmailVerified__c,Account.Is_Mobile_Verified__c,Account.nm_Domicile__c,Account.nm_Nationality__c,Loan_Approved__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
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
        lstDebDetails = [SELECT Id,Date_of_Birth__c,Is_Active__c FROM DEB_Detail__c WHERE Is_Active__c =: true AND Account__c =:objOpp.AccountId ORDER BY CreatedDate DESC LIMIT 1];
        if (objOpp.Account.nm_Nationality__c == 'Indian' || objOpp.Account.nm_Nationality__c == 'India') {
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
        objWrapper.isLoanAmountAndActualPending = objOpp.ActualPendingAmount__c == Integer.valueOf(objOpp.Loan_Amount__c) ? true : false;
    }

    public void checkTenureAndSubvention() {
        List<Tenure__c> lstTenure = new List<Tenure__c>();
        String programType = String.isNotBlank(objOpp.Account.Program_Type__c) ? objOpp.Account.Program_Type__c : 'null';
        String key = objOpp.Account.nm_ProgramType__c + '-' + programType +'-'+ objOpp.Loan_Type__c +'-'+ objOpp.nm_Fee_Type__c;
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
        if (objWrapper.isDocumentApproved && objOpp.Account.is_Video_Call_Verified__c && objOpp.Account.nm_IsEmailVerified__c
            && objOpp.Account.Is_Mobile_Verified__c && objWrapper.isLoanReadyForDisbursement && objWrapper.isLoanAmountAndActualPending
            && objWrapper.isInterestMatch && objWrapper.isSubventionMatch) {
                if (objWrapper.isInterviewApplicable) {
                    objWrapper.isEligiableForloan = objWrapper.isInterviewStatusSelected;
                } 
                else {
                    objWrapper.isEligiableForloan = true;
                }
            objWrapper.isEligiableForloan = objWrapper.isDEBApplicable ? objWrapper.isDEBVerified : objWrapper.isEligiableForloan;
        }
        // else if (objOpp.Loan_Approved__c) {
        //     objWrapper.isEligiableForloan = true;
        // }
    }

    public class LoanApprovalWrapper {
        public Boolean isDocumentApproved {get;set;}
        public Boolean isInterviewStatusSelected {get;set;}
        public Boolean isDEBVerified {get;set;}
        public Boolean isInterviewApplicable {get;set;}
        public Boolean isLoanReadyForDisbursement {get;set;}
        public Boolean isLoanAmountAndActualPending {get;set;}
        public Boolean isEligiableForloan {get;set;}
        public Boolean isInterestMatch {get;set;}
        public Boolean isDEBApplicable {get;set;}
        public Boolean isSubventionMatch {get;set;}

        public LoanApprovalWrapper () {
            isDocumentApproved = false;
            isInterviewApplicable = false;
            isDEBVerified = false;
            isInterviewApplicable = false;
            isLoanReadyForDisbursement = false;
            isLoanAmountAndActualPending = false;
            isEligiableForloan = false;
            isInterestMatch = false;
            isDEBApplicable = false;
            isSubventionMatch = false;
        }
    }
}