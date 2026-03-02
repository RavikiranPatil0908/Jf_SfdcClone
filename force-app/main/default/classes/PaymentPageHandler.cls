/**
 * @description       : 
 * @author            : @vickysahu
 * @group             : 
 * @last modified on  : 11-24-2025
 * @last modified by  : @vickysahu
**/
public without sharing class PaymentPageHandler {
    private static final Set<String> GATEWAY_ERRORS = new Set<String>{
        'Acquirer risk validation failure',
        'Acquirer timeout',
        'API TIMEDOUT',
        'High response time for beneficiary bank',
        'High response time for remitter bank',
        'High response time for beneficiary/remitter bank',
        'Internal error',
        'Internal server error',
        'Invalid bank response',
        'Invalid PG response',
        'Payment processing error',
        'PSP not available',
        'Service unavailable. Please try later.',
        'Sorry we are unable to process your request',
        'System malfunction or certain field error conditions',
        'Technical error occured',
        'Unable to process the transaction',
        'Unable to process transaction',
        'Unprocessable Entity',
        'UNABLE_TO_GENERATE_ALT_ID',
        'Null Error Code::Transaction Failed'
    };

    public static String getGatewayMessage() {
        String gatewayMessages = '';
        Map<String, Integer> failureCounts = new Map<String, Integer>();
        Datetime cutoff = System.now().addMinutes(-10);
        AggregateResult[] groupedResults = [SELECT nm_PaymentGatewayName__c, COUNT(Id) failCount FROM nm_Payment__c WHERE nm_PaymentStatus__c = 'Transaction Failed' AND nm_PaymentGatewayName__c!='' AND  Online_Response_Error__c IN :GATEWAY_ERRORS AND CreatedDate >=: cutoff GROUP BY nm_PaymentGatewayName__c];
        
        for (AggregateResult ar : groupedResults) {
            String gatewayName = ar.get('nm_PaymentGatewayName__c') == 'ICICI GateWay' ? 'CashFree' : (String)ar.get('nm_PaymentGatewayName__c');
            failureCounts.put(gatewayName, (Integer)ar.get('failCount'));
        }

        Integer count = 0;
        for (String gateway : failureCounts.keySet()) {
            if (failureCounts.get(gateway) >= 5 && failureCounts.get(gateway) > count) { 
                count = failureCounts.get(gateway);
                gatewayMessages= gateway + ' transaction success rate is currently low. Please try another payment option.';
            }
        } 
        return gatewayMessages;
    }

    public String checkForLateFee(Account objAccount) {
        String paymentUrl = '';
        List<NM_Payment_Form_Configuration__c> lstPaymentFormConfiguration = new List<NM_Payment_Form_Configuration__c>();
        List<Opportunity> lstOpp = [SELECT id,ActualPendingAmount__c ,Account.Is_Lateral__c,Account.nm_ChooseaProgram__c,
                                    Loan_Type__c,Is_Re_Registration_Payment__c, nm_Session__c, nm_Year__c ,Accountid,StageName,Processed__c,
                                    nm_Fee_Type__c, nm_PendingAmount__c,Loan_Amount__c,Sem__c,nm_Semester__c,Account.Program_Type__c 
                                    FROM Opportunity WHERE Accountid=:objAccount.id AND (StageName = 'Pending Payment - Loan' OR StageName = 'Pending Payment - Instalment') AND Down_Payment_Made__c = true order by nm_Semester__c desc];
        if (lstOpp.size() > 0) {
            String paymentType = lstOpp[0].Is_Re_Registration_Payment__c ? 'Re-Registration' : 'Admission';
            lstPaymentFormConfiguration = [SELECT Id, Is_Late_Fee_Applicable__c FROM NM_Payment_Form_Configuration__c WHERE Session__c=:lstOpp[0].nm_Session__c AND Current_Admission_Year__c=:String.valueOf(lstOpp[0].nm_Year__c) AND Program_Category__c =: lstOpp[0].Account.nm_ChooseaProgram__c AND Program_Type__c =: lstOpp[0].Account.Program_Type__c AND Payment_Type__c=:paymentType LIMIT 1];
        }

        if (lstOpp.size() > 0 && lstPaymentFormConfiguration.size() > 0 && lstPaymentFormConfiguration[0].Is_Late_Fee_Applicable__c && !lstOpp[0].Processed__c) {
            Decimal lateFeePaidAmount = 0;
            Opportunity objOpp = lstOpp[0];
            Boolean programValidity = checkProgramValidity(objOpp,objAccount);
            if (!programValidity && objOpp.Is_Re_Registration_Payment__c) {
                return paymentUrl;
            }
            Set<String> paymentStatus = new Set<String>{'Payment Made','Payment Approved','Waived Off'};
            List<nm_Payment__c> lstOppsRelatedPayment = [select id,nm_Amount__c,nm_Merchant_Track_Id__c ,nm_OpportunityNew__c,nm_OpportunityNew__r.IC__c,nm_OpportunityNew__r.Accountid,nm_OpportunityNew__r.nm_Semester__c,nm_TransactionDate__c,nm_OpportunityNew__r.StageName,nm_PaymentStatus__c,nm_PaymentType__c,nm_OpportunityNew__r.nm_Fee_Type__c from nm_Payment__c where nm_OpportunityNew__c=:objOpp.Id AND nm_PaymentType__c='Late Fees' AND nm_PaymentStatus__c in: paymentStatus];
            for (nm_Payment__c objPayment : lstOppsRelatedPayment) {
                lateFeePaidAmount =+ objPayment.nm_Amount__c;
            }
            Decimal applicableLateFee = getLateFeeAmount(objOpp,lateFeePaidAmount);
            if (applicableLateFee <= 0 || String.isBlank(objOpp.Loan_Amount__c)) {
                return paymentUrl;
            }

            if (!objOpp.Is_Re_Registration_Payment__c) {
                List<VVC_Junction__c> lstVVC = [SELECT Id FROM VVC_Junction__c WHERE Opportunity__c=:objOpp.Id AND Status__c='In Progress' AND Call_Date__c = TODAY LIMIT 1];
                // isVVCScheduled = lstVVC.size() > 0 ? true : false;
                if (lstVVC.size() > 0) {
                    return paymentUrl;
                }
            }
            Decimal pendingAmount = Decimal.valueOf(objOpp.Loan_Amount__c) >= objOpp.ActualPendingAmount__c ? Decimal.valueOf(objOpp.Loan_Amount__c) - objOpp.ActualPendingAmount__c : objOpp.ActualPendingAmount__c - Decimal.valueOf(objOpp.Loan_Amount__c);
            System.debug('pendingAmount--->' + pendingAmount);
            System.debug('loan Amount---> '+ objOpp.Loan_Amount__c);
            System.debug('Actual pending amount---->'+ objOpp.ActualPendingAmount__c);
            System.debug('lateFeePaidAmount--->' + lateFeePaidAmount);
            System.debug('applicableLateFee--->' + applicableLateFee);
            System.debug(applicableLateFee > lateFeePaidAmount && applicableLateFee >= pendingAmount);
            if (applicableLateFee > lateFeePaidAmount && applicableLateFee >= pendingAmount) {
                paymentUrl = System.Label.Site_Url + 'apex/nmAdditonalCharge?id=' + objOpp.Id;
            }
        }
        return paymentUrl;
    }

    public Boolean checkProgramValidity(Opportunity objOpportunity, Account objAccount) {
        if (objOpportunity.Is_Re_Registration_Payment__c) {
            ValidityForStudentLogin checkStudent = new ValidityForStudentLogin();
            String validitymon = (objAccount.Extend_Validity_upto_Month__c!='' && objAccount.Extend_Validity_upto_Month__c!=null) ?objAccount.Extend_Validity_upto_Month__c.left(3):objAccount.Validity_Month__c.left(3);
            Integer validyear = objAccount.Extend_Validity_Upto_Year__c!=null ? Integer.valueof(objAccount.Extend_Validity_Upto_Year__c) :  Integer.valueof(objAccount.Validity_Year__c);
            Integer driveYear = getDriveYear(objAccount.Batch__c);
            String validityStatus = checkStudent.checkValidityForPGforLogin(objOpportunity.nm_Session__c,Integer.valueOf(objOpportunity.nm_Year__c),validyear,validitymon,objOpportunity.nm_Semester__c);
            if(validityStatus == 'RedirectPG'){
                if(!objAccount.Provisional_With_Hold__c || driveYear > 2023) {
                    List<String> batchNotAllowed = Label.ReReg_Batch_Not_Allowed.split(';');
                    if (batchNotAllowed.contains(objAccount.Batch__c)) {
                        system.debug('<--Error Block For ReReg Not allowed for -> ' + objAccount.Batch__c);
                        return false;
                    }
                    return true;
                } 
            }
            return false;
        }
        return true;
    }

    private Integer getDriveYear(String batch) {
        Integer driveYear = 0;
        try {
            if(String.isNotBlank(batch)) {
                driveYear = Integer.valueOf(batch.split(' ')[1]);
            }
        } catch (Exception error) {
            System.debug(error.getMessage());
            driveYear = 0;
        }
        return driveYear;
    }

    private Decimal getLateFeeAmount(Opportunity objOpp,Decimal lateFeePaidAmount) {
        Decimal lateFeeAmount = 0;
        String programType = objOpp.Is_Re_Registration_Payment__c ? 'Re-Registration' : 'Admission';
        String lateFeeCategory = determineLateFeeCategory(programType,objOpp.Account.Is_Lateral__c);
        // Check for admission late fee
        // if (objDetails.DaysPendingforAdmissionPayment == -1) {
        //     lateFeeAmount += getDecimalValue(System.Label.AdmissionLatefeeMBAWX);
        // }
    
        // Query late fees from database
        lateFeeAmount += fetchLateFeeFromDatabase(lateFeeCategory,objOpp);
    
        // Adjust late fee amount based on already paid late fees
        lateFeeAmount = adjustLateFeeForAlreadyPaidAmount(lateFeeAmount,lateFeePaidAmount,objOpp);
    
        // Ensure late fee amount is non-negative
        return Math.max(lateFeeAmount, 0);
    }

    private String determineLateFeeCategory(String programType, Boolean isLateral) {
        return isLateral && programType == 'Admission' ? 'Is Lateral' : programType;
    }

    private Decimal adjustLateFeeForAlreadyPaidAmount(Decimal lateFeeAmount,Decimal lateFeePaidAmount, Opportunity objOpp) {
        if (lateFeeAmount > 0 && lateFeePaidAmount > 0) {
            if (isCertificateOrExecutiveProgram(objOpp)) {
                lateFeeAmount += lateFeeAmount * getDecimalValue(System.Label.Service_Tax);
            }
            lateFeeAmount -= lateFeePaidAmount;
        } else if (isCertificateOrExecutiveProgram(objOpp)) {
            lateFeeAmount += lateFeeAmount * getDecimalValue(System.Label.Service_Tax);
        }
    
        return lateFeeAmount;
    }

    private Decimal getDecimalValue(String label) {
        return Decimal.valueOf(label).setScale(2);
    }

    private Boolean isCertificateOrExecutiveProgram(Opportunity objOpp) {
        return 'Certificate Programs'.equalsIgnoreCase(objOpp.Account.nm_ChooseaProgram__c) || 'Executive Programs'.equalsIgnoreCase(objOpp.Account.nm_ChooseaProgram__c);
    }

    private Decimal fetchLateFeeFromDatabase(String lateFeeCategory, Opportunity objOpp) {
        List<Late_Fee__c> lateFeeRecords = [
            SELECT Late_Fees__c, Start_Date__c
            FROM Late_Fee__c
            WHERE Category__c = :lateFeeCategory
              AND nm_Type__c = :objOpp.Account.nm_ChooseaProgram__c
              AND Program_Type__c = :objOpp.Account.Program_Type__c
              AND Session__c = :objOpp.nm_Session__c
              AND Year__c = :String.valueOf(objOpp.nm_year__c)
              AND Start_Date__c <= TODAY
              AND End_Date__c >= TODAY
        ];

        if (lateFeeRecords.isEmpty() || objOpp.Processed__c) {
            return 0;
        }
    
        // Set start date for late fee
        //objDetails.lateFeeStartDate = lateFeeRecords[0].Start_Date__c;
        return lateFeeRecords[0].Late_Fees__c;
    }

}