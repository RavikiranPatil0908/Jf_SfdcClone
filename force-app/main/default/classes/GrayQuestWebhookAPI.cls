/**
 * @description       : 
 * @author            : phalguni
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : @vickysahu
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-16-2021   phalguni   Initial Version
**/
@RestResource(urlMapping='/GrayQuestWebhookAPI/V1.1/*')
global without sharing class GrayQuestWebhookAPI {
    
    /**
    * @description To Tracking the loan status for GrayQuest loan application
    * @author phalguni | 08-21-2020 
    * @return List<MessageWrapper> 
    **/
    @HttpPost
    global static List<MessageWrapper> TrackGrayQuestLoanStatus() {
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        MessageWrapper messageWrapper;
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        try {
            GrayQuestWrapper reqWrapper = GrayQuestWrapper.parse(requestString);
            apiReq.Request__c = requestString;
        
            if (reqWrapper.entity != 'monthly-emi') {
                return returnMessage(apiReq, requestString, '501', 'Only Loan EMI is Processed');
            }
        
            // Validate essential fields upfront
            String applicationId = getStringValue(reqWrapper.application_details?.ID);
            if (String.isBlank(applicationId)) {
                return returnMessage(apiReq, requestString, '511', 'application_id is missing.');
            }
        
            String referenceId = getStringValue(reqWrapper.reference_id);
            if (String.isBlank(referenceId)) {
                return returnMessage(apiReq, requestString, '511', 'reference_id is missing.');
            }
        
            String amount = getStringValue(reqWrapper.fee_details?.amount);
            if (String.isBlank(amount)) {
                return returnMessage(apiReq, requestString, '501', 'Loan amount is missing.');
            }

            String amount2 = getStringValue(reqWrapper.notes?.loan_amount);
            if(String.isNotBlank(amount2) && amount != amount2) {
                amount = amount2;
            }
        
            String status = reqWrapper.event;
            if (String.isBlank(status)) {
                return returnMessage(apiReq, requestString, '501', 'event is missing.');
            }
        
            String tenure = getStringValue(reqWrapper.fee_details?.tenure);
            String interest_rate = getStringValue(reqWrapper.fee_details?.interest_rate);
        
            // Query Opportunities and Leads in bulk
            List<Opportunity> lstOpportunity = [SELECT Id, ChooseProgram__c, Specialisation__c, EduVanz_last_update_status_date__c,
                                                Tenure__c, Loan_Amount__c, Loan_Application_Cancelled__c, Loan_Order_Status__c,Loan_Sanctioned__c,
                                                EduVanz_lead_id__c, Loan_Order_Id__c, Account.nm_ChooseaProgram__c, Account.Program_Type__c,
                                                Loan_Account_number__c, nm_Fee_Type__c, ActualPendingAmount__c, LiveLecturesType__c, CourseList__c
                                                FROM Opportunity
                                                WHERE (EduVanz_lead_id__c = :applicationId OR Loan_Order_Id__c = :referenceId)
                                                AND Loan_Type__c = 'GrayQuest' LIMIT 1];
                                                
            
            if (!lstOpportunity.isEmpty()) {
                if(lstOpportunity[0].EduVanz_lead_id__c!=applicationId && lstOpportunity[0].EduVanz_lead_id__c!=referenceId) {
                    return returnMessage(apiReq, requestString, '500', 'application_id does not matched, please try with different one.');
                }
                messageWrapper = processOpportunities(lstOpportunity[0], reqWrapper, status, amount, tenure, interest_rate, apiReq);
            } else {
                // Query Leads if no Opportunity is found
                List<Lead> lstLead = [SELECT Id, EduVanz_last_update_status_date__c, Loan_Application_Cancelled__c, Loan_Order_Status__c,
                                    EduVanz_lead_id__c, Loan_Order_Id__c, nm_ChooseaProgram__c, Program_Type__c, Tenure__c, Loan_Amount__c,Loan_Sanctioned__c,
                                    nm_Fee_Type__c, LiveLecturesType__c, CourseList__c, nm_InformationCenter__r.ConsumerType__c, nm_Program__r.prgst__c
                                    FROM Lead
                                    WHERE ((EduVanz_lead_id__c != null AND EduVanz_lead_id__c != '' AND EduVanz_lead_id__c = :applicationId) OR Loan_Order_Id__c = :referenceId)
                                    AND Loan_Type__c = 'GrayQuest' AND IsDeleted = false LIMIT 1];
                if (!lstLead.isEmpty()) {
                    if(lstLead[0].EduVanz_lead_id__c!=applicationId && lstLead[0].EduVanz_lead_id__c!=referenceId) {
                        return returnMessage(apiReq, requestString, '500', 'application_id does not matched, please try with different one.');
                    }
                    messageWrapper = processLeads(lstLead[0], reqWrapper, status, amount, tenure, interest_rate, apiReq);
                } else {
                    return returnMessage(apiReq, requestString, '500', 'application_id does not matched, please try with different one.');
                }
            }
        } catch (Exception e) {
            System.debug('Error ==>'+e.getMessage());
            messageWrapper = new MessageWrapper('501', e.getMessage());
        }
    
        return returnMessage(apiReq, requestString, messageWrapper.errorCode, messageWrapper.message); // Log the API request
    }
    
    private static String getStringValue(Object value) {
        return value != null ? String.valueOf(value) : '';
    }

    // ------------------------------------------------------------ Opporutnity ------------------------------------------------------------
    /**
    * @description Process Opportunity records
    * @author @BK | 12-11-2024 
    * @param List<Opportunity> lstOpportunity 
    * @param GrayQuestWrapper reqWrapper 
    * @param String status 
    * @param String amount 
    * @param String tenure 
    * @param String interest_rate 
    * @param API_Request__c apiReq 
    * @return MessageWrapper 
    **/
    private static MessageWrapper processOpportunities(Opportunity opp, GrayQuestWrapper reqWrapper, String status,
                                                       String amount, String tenure, String interest_rate, API_Request__c apiReq) {
        List<Opportunity> updateLstOpp = new List<Opportunity>();
        apiReq.Opportunity__c = opp.Id;

        // Update Opportunity fields
        opp.Loan_Order_Status__c = status;
        String applicationId = getStringValue(reqWrapper.application_details?.ID);
        if(opp.EduVanz_lead_id__c!=applicationId) {
            opp.EduVanz_lead_id__c = applicationId;
        }
        
        if (status.equalsIgnoreCase('emi.rejected')) {
            handleRejectedLoan(opp, apiReq);
        } else if (status.equalsIgnoreCase('emi.disbursed')) {
            DisbursmentDetails obj = handleDisbursedLoan(opp, reqWrapper, apiReq);
            opp = obj.opp;
            if(!opp.Loan_Sanctioned__c) {
                return obj.messageWrapper;
            }
        } else if (status.equalsIgnoreCase('emi.process.completed')) {
            handleApprovedLoan(opp, amount, tenure, interest_rate);
        }

        opp.EduVanz_last_update_status_date__c = DateTime.now();
    
        try {
            update opp;
            return new MessageWrapper('200', 'Webhook API Data updated.');
        } catch (Exception e) {
            System.debug('Error ==>'+e.getMessage());
        }
        return new MessageWrapper('505', 'Error, please try again.');
    }
    
    /**
    * @description Handle Rejected loan stage
    * @author @BK | 12-11-2024 
    * @param Opportunity opp 
    * @param API_Request__c apiReq 
    * @return MessageWrapper 
    **/
    private static MessageWrapper handleRejectedLoan(Opportunity opp, API_Request__c apiReq) {
        String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Opportunity', opp.EduVanz_lead_id__c, opp.Id, 'Rejected');
        if (strResult == 'true') {
            return new MessageWrapper('200', 'Loan application cancelled successfully.');
        } else {
            return new MessageWrapper('504', 'Internal Error Occurred.');
        }
    }

    /**
    * @description Handle Disbursed loan stage
    * @author @BK | 12-11-2024 
    * @param Opportunity opp 
    * @param GrayQuestWrapper reqWrapper 
    * @param API_Request__c apiReq 
    * @return DisbursmentDetails 
    **/
    private static DisbursmentDetails handleDisbursedLoan(Opportunity opp, GrayQuestWrapper reqWrapper, API_Request__c apiReq) {
        DisbursmentDetails obj = new DisbursmentDetails();
        obj.opp = opp;
        if (reqWrapper.disbursement_details != null && String.isNotBlank(reqWrapper.disbursement_details.utr) 
            && reqWrapper.disbursement_details.disbursed_amount > 0) {

            String utr = reqWrapper.disbursement_details.utr;
            Decimal disbursedAmount = reqWrapper.disbursement_details.disbursed_amount;
            String liveLectureType = opp.LiveLecturesType__c;
            String courseList = opp.CourseList__c;
            opp.Loan_Sanctioned__c = true;

            Tenure__c objTenure = getTenureForSubvention(opp.nm_Fee_Type__c, opp.Account.nm_ChooseaProgram__c, opp.Specialisation__c, opp.Tenure__c);
            List<String> lstallTermfeeProgram = new List<String>{'MBA - X', 'MBA (WX)', 'M.Sc. (AI & ML Ops)', 'M.Sc. (AI)'};
            if(String.isNotBlank(opp.Specialisation__c) && lstallTermfeeProgram.contains(opp.Specialisation__c) && opp.nm_Fee_Type__c != 'AnnualFee' && opp.nm_Fee_Type__c != 'FullFee'){
                opp.nm_Fee_Type__c = 'MBAallTermfee';
            }
            // Check if the program qualifies for subvention
            if (objTenure != null && objTenure.Subvention_Value__c > 0) {
                createGQPayment(opp.Id, utr, 'Opportunity', disbursedAmount, liveLectureType, courseList, null); // Regular payment
                createGQAndSubventionPayment(utr, opp.Id, 'Opportunity', opp.Loan_Amount__c, opp.ActualPendingAmount__c, disbursedAmount, objTenure); // Payment with subvention
            } else {
                createGQPayment(opp.Id, utr, 'Opportunity', disbursedAmount, liveLectureType, courseList, null); // Regular payment
            }
            obj.opp = opp;
            obj.messageWrapper = new MessageWrapper('200', 'Loan disbursed successfully.');
        } else {
            obj.messageWrapper = new MessageWrapper('501', 'UTR or disbursed_amount is missing.');
        }
        return obj;
    }

    /**
    * @description Handle Approved loan stage
    * @author @BK | 12-11-2024 
    * @param Opportunity opp 
    * @param String amount 
    * @param String tenure 
    * @param String interest_rate 
    **/
    private static void handleApprovedLoan(Opportunity opp, String amount, String tenure, String interest_rate) {
        opp.Eduvanz_final_sanction_loan_amount__c = amount;  // use the eduvanz field to avoid the creating the new field for same functionality
        opp.Loan_Amount__c = amount;
        opp.Tenure__c = tenure;
        opp.Interest_Rate__c= interest_rate;
        if (opp.Loan_Application_Cancelled__c) {
            opp.Loan_Application_Cancelled__c = false;
            opp.Down_Payment_Made__c = true;
        }
    }
    
    // ------------------------------------------------------------ Lead ------------------------------------------------------------
    /**
    * @description Process Lead records (similar to Opportunities)
    * @author @BK | 12-11-2024 
    * @param List<Lead> lstLead 
    * @param GrayQuestWrapper reqWrapper 
    * @param String status 
    * @param String amount 
    * @param String tenure 
    * @param String interest_rate 
    * @param API_Request__c apiReq 
    * @return MessageWrapper 
    **/
    private static MessageWrapper processLeads(Lead ld, GrayQuestWrapper reqWrapper, String status,
                                               String amount, String tenure, String interest_rate, API_Request__c apiReq) {
        apiReq.Lead__c = ld.Id;
        ld.Loan_Order_Status__c = status;
        ld.Eduvanz_final_sanction_loan_amount__c = amount;
        ld.Loan_Amount__c = amount;
        ld.Tenure__c = tenure;
        String applicationId = getStringValue(reqWrapper.application_details?.ID);
        if(ld.EduVanz_lead_id__c!=applicationId) {
            ld.EduVanz_lead_id__c = applicationId;
        }

        if (status.equalsIgnoreCase('emi.rejected')) {
            handleRejectedLoan(ld, apiReq);
        } else if (status.equalsIgnoreCase('emi.disbursed')) {
            DisbursmentDetails obj = handleDisbursedLoan(ld, reqWrapper, apiReq);
            ld = obj.ld;
            if(!ld.Loan_Sanctioned__c) {
                return obj.messageWrapper;
            }
        } else if (status.equalsIgnoreCase('emi.process.completed')) {
            handleApprovedLoan(ld, amount, tenure, interest_rate);
        }

        ld.EduVanz_last_update_status_date__c = DateTime.now();

        try {
            update ld;
            return new MessageWrapper('200', 'Webhook API Data updated.');
        } catch (Exception e) {
            System.debug('Error ==>'+e.getMessage());
        }
        return new MessageWrapper('505', 'Error, please try again.');
    }

    /**
    * @description Handle Rejected loan stage
    * @author @BK | 12-11-2024 
    * @param Lead ld 
    * @param API_Request__c apiReq 
    * @return MessageWrapper 
    **/
    private static MessageWrapper handleRejectedLoan(Lead ld, API_Request__c apiReq) {
        String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Lead', ld.EduVanz_lead_id__c, ld.Id, 'Rejected');
        if (strResult == 'true') {
            return new MessageWrapper('200', 'Loan application cancelled successfully.');
        } else {
            return new MessageWrapper('504', 'Internal Error Occurred.');
        }
    }

    
    /**
    * @description Handle Disbursed loan stage
    * @author @BK | 12-11-2024 
    * @param Lead ld 
    * @param GrayQuestWrapper reqWrapper 
    * @param API_Request__c apiReq 
    * @return DisbursmentDetails 
    **/
    private static DisbursmentDetails handleDisbursedLoan(Lead ld, GrayQuestWrapper reqWrapper, API_Request__c apiReq) {
        DisbursmentDetails obj = new DisbursmentDetails();
        obj.ld = ld;
        if (reqWrapper.disbursement_details != null && String.isNotBlank(reqWrapper.disbursement_details.utr) 
            && reqWrapper.disbursement_details.disbursed_amount > 0) {

            String utr = reqWrapper.disbursement_details.utr;
            Decimal disbursedAmount = reqWrapper.disbursement_details.disbursed_amount;
            String liveLectureType = ld.LiveLecturesType__c;
            String courseList = ld.CourseList__c;
            Decimal actualPendingAmount = 0;
            ld.Loan_Sanctioned__c = true;

            Tenure__c objTenure = getTenureForSubvention(ld.nm_Fee_Type__c, ld.nm_ChooseaProgram__c, ld.Program_Type__c, ld.Tenure__c);
            List<String> lstallTermfeeProgram = new List<String>{'MBA - X', 'MBA (WX)', 'M.Sc. (AI & ML Ops)', 'M.Sc. (AI)'};
            if(String.isNotBlank(ld.Program_Type__c) && lstallTermfeeProgram.contains(ld.Program_Type__c) && ld.nm_Fee_Type__c != 'AnnualFee' && ld.nm_Fee_Type__c != 'FullFee'){
                ld.nm_Fee_Type__c = 'MBAallTermfee';
            }
            // Check if the program qualifies for subvention
            if (objTenure != null && objTenure.Subvention_Value__c > 0) {
                createGQPayment(ld.Id, utr, 'Lead', disbursedAmount, liveLectureType, courseList, ld); // Regular payment
                createGQAndSubventionPayment(utr, ld.Id, 'Lead', ld.Loan_Amount__c, actualPendingAmount, disbursedAmount, objTenure); // Payment with subvention
            } else {
                createGQPayment(ld.Id, utr, 'Lead', disbursedAmount, liveLectureType, courseList, ld); // Regular payment
            }

            obj.ld = ld;
            obj.messageWrapper = new MessageWrapper('200', 'Loan disbursed successfully.');
        } else {
            obj.messageWrapper = new MessageWrapper('501', 'UTR or disbursed_amount is missing.');
        }
        return obj;
    }

    
    /**
    * @description Handle Approved loan stage
    * @author @BK | 12-11-2024 
    * @param Lead ld 
    * @param String amount 
    * @param String tenure 
    * @param String interest_rate 
    **/
    private static void handleApprovedLoan(Lead ld, String amount, String tenure, String interest_rate) {
        ld.Eduvanz_final_sanction_loan_amount__c = amount;  // use the eduvanz field to avoid the creating the new field for same functionality
        ld.Loan_Amount__c = amount;
        ld.Tenure__c = tenure;
        if (ld.Loan_Application_Cancelled__c) {
            ld.Loan_Application_Cancelled__c = false;
            ld.Down_Payment_Made__c = true;
        }
    }
    
    
    /**
    * @description To create the NEFT Record
    * @author phalguni | 08-21-2020 
    * @param Id recordId 
    * @param String UTR 
    * @param String objectType 
    * @param Decimal amount 
    * @param String liveLectureType 
    * @param String courseList 
    * @param Lead ld 
    **/
    public static void createGQPayment(Id recordId, String UTR, String objectType, Decimal amount, String liveLectureType, String courseList, Lead ld){
        Boolean paymentCreated = false;
        System.debug('createGrayQuestPayment enter');
        Decimal loan_amt = amount;
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        if(String.isNotBlank(liveLectureType) && liveLectureType!='No') {
            Decimal liveLectureAmount = 0;
            nm_Payment__c liveLecturePayment = EduvanzTrackLoanApplicationAPI.createLiveLecturePayment(recordId,UTR,objectType,amount,liveLectureType,courseList,ld,'NEFT - GrayQuest');
            loan_amt = amount - liveLecturePayment.nm_Amount__c;
            lstPaymentToInsert.add(liveLecturePayment);
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal disbursed_amount= amount;
        if(objectType == 'Lead' && loan_amt > 0){
            payment.nm_ModeOfPayment__c = 'NEFT - GrayQuest';
            payment.nm_Amount__c= loan_amt;
            payment.nm_ActualPaymentAmmount__c = loan_amt;
            payment.nm_PaymentStatus__c ='Payment Made';
            payment.nm_PaymentType__c = 'Admission';
            payment.nm_Merchant_Track_Id__c = UTR;
            payment.nm_Lead__c = recordId;
           
        }else if(objectType == 'Opportunity' && loan_amt > 0){
            payment.nm_ModeOfPayment__c = 'NEFT - GrayQuest';
            payment.nm_Amount__c = loan_amt;
            payment.nm_ActualPaymentAmmount__c = loan_amt;
            payment.nm_PaymentStatus__c ='Payment Made';
            payment.nm_PaymentType__c = 'Admission';
            payment.nm_Merchant_Track_Id__c = UTR;
            payment.nm_OpportunityNew__c = recordId;
        }
        if(payment != null && payment.nm_Amount__c > 0){        
            lstPaymentToInsert.add(payment);
        }
        System.debug('paymentCreated '+paymentCreated+' payment '+lstPaymentToInsert.size());
        if(lstPaymentToInsert.size() > 0 && paymentCreated == false){
            System.debug('paymnet record details-->'+payment+'paymentCreated '+paymentCreated);
            try {
                List<nm_Payment__c> nm_pay = [SELECT Id,nm_ModeOfPayment__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE (nm_OpportunityNew__c=:recordId OR nm_Lead__c=:recordId) AND nm_ModeOfPayment__c='NEFT - GrayQuest' AND nm_PaymentType__c!='Live Lectures' AND (nm_PaymentStatus__c='Payment Made' OR nm_PaymentStatus__c='Payment Approved') LIMIT 1];
                if(nm_pay.size()>0){
                    paymentCreated = true;
                }
                insert lstPaymentToInsert;
            } catch(DmlException e) {
                System.debug(e.getMessage());
            }
        } else {
            System.debug('payment already created --'+paymentCreated);
        }
    }

    /**
    * @description 
    * @author @BK | 12-11-2024 
    * @param String UTR 
    * @param String recordId 
    * @param String objectType 
    * @param String Loan_amount 
    * @param Decimal actualPendingAmount 
    * @param Decimal disbursed_amount 
    * @param Tenure__c objTenure 
    **/
    public static void createGQAndSubventionPayment(String UTR, Id recordId, String objectType, String Loan_amount, Decimal actualPendingAmount, Decimal disbursed_amount, Tenure__c objTenure){
        System.debug('createGrayQuestAndSubventionPayment enter '+' objectType  '+objectType);
        Boolean paymentCreated = false;
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'GrayQuest Subvention' and nm_PaymentStatus__c = 'Waived Off' limit 1];    
        if(nm_pay.size()>0){
            paymentCreated = true;
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal subvention_amt = 0.0;
        Decimal loan_amt= Decimal.ValueOf(Loan_amount);
        if(objTenure!=null) {
            subvention_amt = ((loan_amt * objTenure.Subvention_Value__c) /100);
        }
        
        // to avoid 3 decimal values in payment 
        String s = String.valueOf(subvention_amt); 
        if(s.contains('.')){
            String afterDecimal = s.substringAfter('.');
            if(Integer.valueOf(afterDecimal)>0.0){
                subvention_amt = subvention_amt.round(System.RoundingMode.UP);
            }
        }
   
        if(objectType == 'Lead'){
            payment.nm_Amount__c=subvention_amt;
            payment.nm_ActualPaymentAmmount__c=subvention_amt;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'GrayQuest Subvention';
            payment.nm_Lead__c=recordId;

        }else if(objectType == 'Opportunity'){
            payment.nm_Amount__c=subvention_amt;
            payment.nm_ActualPaymentAmmount__c=subvention_amt;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'GrayQuest Subvention';
            payment.nm_OpportunityNew__c=recordId;
        }

        if(payment != null && paymentCreated == false && payment.nm_Amount__c > 0){
            System.debug('paymnet record details-->'+payment+'paymentCreated '+paymentCreated);
            try{
                insert payment;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            System.debug('payment already created --'+paymentCreated);
        }

        if(objTenure!=null && objTenure.Tranche_Payment__c && actualPendingAmount >0){
            createAdditionalPaymentRecord(actualPendingAmount, recordId, objectType, disbursed_amount);
        }
    }

    /**
    * @description 
    * @author @BK | 12-11-2024 
    * @param Decimal actualPendingAmount 
    * @param String recordId 
    * @param String objectType 
    * @param Decimal disbursed_amount 
    **/
    public static void createAdditionalPaymentRecord(Decimal actualPendingAmount,String recordId,String objectType,Decimal disbursed_amount){
        Boolean paymentCreated = false;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        if(objectType == 'Opportunity'){
            lstOpportunity = [select Id,Account.Program_Type__c,ActualPendingAmount__c from Opportunity where Id=:recordId and Loan_Type__c='GrayQuest' limit 1];
        }
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'Additional Charge' and nm_PaymentStatus__c = 'Waived Off' limit 1];    
        if(nm_pay.size()>0){
            paymentCreated = true;
        }

        nm_Payment__c payment = new nm_Payment__c();
        if(objectType == 'Lead'){
            payment.nm_Amount__c= actualPendingAmount;
            payment.nm_ActualPaymentAmmount__c=actualPendingAmount;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_Lead__c=recordId; 

        }else if(objectType == 'Opportunity'){
            payment.nm_Amount__c= disbursed_amount;
            payment.nm_ActualPaymentAmmount__c= disbursed_amount;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_OpportunityNew__c=recordId;
        }

        if(payment != null && paymentCreated == false && payment.nm_Amount__c > 0){
            System.debug('paymnet record details-->'+payment+'paymentCreated '+paymentCreated);
            try{
                insert payment;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            System.debug('payment already created --'+paymentCreated);
        }
    }

    /**
    * @description 
    * @author @BK | 12-11-2024 
    * @param String feeType 
    * @param String chooseProgram 
    * @param String programType 
    * @param String tenure 
    * @return Tenure__c 
    **/
    public static Tenure__c getTenureForSubvention(String feeType,String chooseProgram,String programType,String tenure) {
        feeType = feeType == 'MBAallTermfee' || feeType == 'ReRegistrationPayment' ? 'Admission' : feeType;
        if((tenure == '23' || tenure == '17') && feeType == 'FullFeeLoan') {
            tenure = tenure == '23' ? '24' : '18';
        }
        String key = chooseProgram+'-'+programType+'-GrayQuest-'+feeType;
        List<Tenure__c> lstTenures = [SELECT id,Subvention_Value__c,Tranche_Payment__c FROM Tenure__c WHERE Key__c=:key AND Tenure__c=:tenure AND IsActive__c=true LIMIT 1];
        if(lstTenures.size() > 0 && lstTenures[0].Subvention_Value__c > 0) {
            return lstTenures[0];
        }
        return null;
    }

    /**
    * @description 
    To get the return message 
    * @author phalguni | 08-21-2020 
    * @param requestString 
    * @param code 
    * @param msg 
    * @return List<MessageWrapper> 
    **/
    public static List<MessageWrapper> returnMessage(API_Request__c apiReq,String requestString, String code, String msg) {
        if(apiReq==null) {
            apiReq = new API_Request__c();
        }
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'GrayQuest';
        apiReq.API_Name__c='GrayQuestWebhookAPI';
        apiReq.Success__c = false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    /**
    * @description 
    to save the logs for GrayQuest webhokk api
    * @author phalguni | 08-21-2020 
    * @param apiRequest 
    **/
    public static void apiRequestsInsertion(API_Request__c apiRequest){
        if(apiRequest != null){
            try {
                insert apiRequest;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }

    global class MessageWrapper{
        public String errorCode;
        public String message;
        global MessageWrapper(String errorCode,String message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }

    public class DisbursmentDetails {
        public MessageWrapper messageWrapper;
        public Opportunity opp;
        public Lead ld;
    }
}