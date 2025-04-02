/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 16-04-2024
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-15-2021   @BK   Initial Version
**/
@RestResource(urlMapping='/ZestWebhookAPI/V1.1/*')
global without sharing class ZestWebhookAPI {
    
    public static Boolean subventionPrograms = false;
    public static Boolean tenureSelectedForSubvention = false;

    @HttpPost
    global static List<MessageWrapper> TrackZestStaus(){
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        try {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            requestString = mogrifyJSON(body.toString());
            System.debug('requestString '+requestString);
            ZestResponseWrapper reqWrapper = ZestResponseWrapper.parse(requestString);
            apiReq.Request__c = requestString;
            System.debug(reqWrapper);
            Decimal approvedLoanAmount = 0;
            String loan_id ='';
            String amount ='';
            String status ='';
            String utr = '';
            Decimal disbursed_amount = 0;
            String tenure ='';
        
            String checksum = reqWrapper.payload.transactionDetails.key;
            MessageWrapper messageWrapper = null;

            if(String.isNotBlank(checksum)){
                if(!verifyCheckSum(reqWrapper.payload.transactionDetails.partnerTransactionId,reqWrapper.payload.transactionDetails.status,checksum)) {
                    return returnMessage(apiReq,requestString,'501','checksum is not matched..');
                }
            } else {
                return returnMessage(apiReq,requestString,'501','checksum is missing.');
            }

            if(String.isNotBlank(reqWrapper.payload.transactionDetails.zestTransactionId)){
                loan_id = reqWrapper.payload.transactionDetails.zestTransactionId;
            }else{
                return returnMessage(apiReq,requestString,'511','Loan id is missing.');
            }

            if(String.isNotBlank(reqWrapper.payload.transactionDetails.status)){
                status = reqWrapper.payload.transactionDetails.status;
            }else{
                return returnMessage(apiReq,requestString,'501','status is missing.');
            }

            if(reqWrapper.payload.transactionDetails.basketAmount != null) {
                amount = String.valueOf(reqWrapper.payload.transactionDetails.basketAmount); 
                tenure = String.valueOf(reqWrapper.payload.transactionDetails.tenure);
                approvedLoanAmount = reqWrapper.payload.transactionDetails.loanAmount > 0 ? reqWrapper.payload.transactionDetails.loanAmount : reqWrapper.payload.transactionDetails.basketAmount;
            } else {
                return returnMessage(apiReq,requestString,'501','Amount is missing.');
            }

            if(reqWrapper.payload.transactionDetails.status == 'Settled' && reqWrapper.payload.transactionDetails.utr == null) {
                return returnMessage(apiReq,requestString,'501','UTR is missing.');
            }

            System.debug('loan_id-->'+loan_id+' amount-->'+amount+' status-->'+status+' checksum-->'+checksum);
            
            List<Opportunity> updateLstOpp = new List<Opportunity>();
            List<Opportunity> lstOpportunity = [SELECT Id,Specialisation__c,EduVanz_last_update_status_date__c,Tenure__c,Loan_Amount__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,Account.nm_ChooseaProgram__c ,Account.Program_Type__c,nm_Fee_Type__c,LiveLecturesType__c,CourseList__c FROM Opportunity WHERE EduVanz_lead_id__c=:loan_id AND Loan_Type__c='Zest' LIMIT 1];
            
            List<Lead> updateLstLead = new List<Lead>();
            List<Lead> lstLead = new List<Lead>();

            if(lstOpportunity.size() > 0) {
                System.debug('lstOpportunity '+lstOpportunity);
                for(Opportunity opp: lstOpportunity) {
                    apiReq.Opportunity__c = opp.Id;

                    if(String.isNotBlank(amount)){
                        opp.Eduvanz_final_sanction_loan_amount__c = amount;                  // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(status)){
                        opp.Loan_Order_Status__c = status;

                        if(opp.Account.nm_ChooseaProgram__c  == 'Master Programs'){
                            subventionPrograms = checkSubventionSchemePrograms(opp.Specialisation__c);
                            tenureSelectedForSubvention = checkTenureForSubvention(opp.Specialisation__c,opp.Tenure__c,opp.Loan_Amount__c);
                            System.debug('tenureSelectedForSubvention opp--'+tenureSelectedForSubvention);
                        }

                        if(status.equalsIgnoreCase('Declined') || status.equalsIgnoreCase('CustomerCancelled') || status.equalsIgnoreCase('MerchantCancelled') 
                        || status.equalsIgnoreCase('TimeoutCancelled') || status.equalsIgnoreCase('Cancelled')) {
                            // call global method to avoid the same code logic
                            String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Opportunity',opp.EduVanz_lead_id__c,opp.Id,'Rejected');
                            if(strResult == 'true'){
                                System.debug('Loan application cancelled successfully...');
                                return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                            }else{
                                System.debug('Something went wrong while cancel the loan...'+strResult);
                                return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                            }
                        }else if(status.equalsIgnoreCase('Settled')){
                            opp.Loan_Order_Status__c = 'Delivered';
                            // System.debug('subventionProg--'+subventionPrograms +'opp.Account.nm_ChooseaProgram__c --'+opp.Account.nm_ChooseaProgram__c );
                            if(reqWrapper.payload.transactionDetails.settlementAmount > 0) {
                                String liveLectureType = opp.LiveLecturesType__c;
                                String courseList = opp.CourseList__c;
                                opp.Loan_Sanctioned__c  = true;
                                disbursed_amount = reqWrapper.payload.transactionDetails.settlementAmount;
                                utr = reqWrapper.payload.transactionDetails.utr;
                                if(subventionPrograms && opp.Account.nm_ChooseaProgram__c == 'Master Programs' && tenureSelectedForSubvention){
                                    if((opp.Specialisation__c =='MBA (X)' || opp.Specialisation__c =='MBA (WX)') || (('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(opp.Specialisation__c) || 'M.Sc. (AI)'.equalsIgnoreCase(opp.Specialisation__c) ) && opp.nm_Fee_Type__c != 'AnnualFee' && opp.nm_Fee_Type__c != 'FullFee' )){
                                        opp.nm_Fee_Type__c = 'MBAallTermfee';
                                    }
                                   
                                        createZestPayment(opp.Id,utr,'Opportunity',disbursed_amount,liveLectureType,courseList,null);
                                        createZestAndSubventionPayment(opp.Id,'Opportunity',opp.Tenure__c,opp.Loan_Amount__c,opp.Specialisation__c);
                                    
                                   
                                }else{
                                    if((opp.Specialisation__c =='MBA (X)' || opp.Specialisation__c =='MBA (WX)') || (('M.Sc. (AI & ML Ops)'.equalsIgnoreCase(opp.Specialisation__c) || 'M.Sc. (AI)'.equalsIgnoreCase(opp.Specialisation__c) ) && opp.nm_Fee_Type__c != 'AnnualFee' && opp.nm_Fee_Type__c != 'FullFee' )){
                                        opp.nm_Fee_Type__c = 'MBAallTermfee';
                                    }
                                    createZestPayment(opp.Id,utr,'Opportunity',disbursed_amount,liveLectureType,courseList,null);
                                }
                                
                            }else{
                                return returnMessage(apiReq,requestString,'501','UTR or disbursed_amount is missing.');
                            } 
                        }else if(status.equalsIgnoreCase('Approved') || status.equalsIgnoreCase('ZestApproved')){
                            opp.Loan_Order_Status__c = 'Approved';
                            opp.Eduvanz_final_sanction_loan_amount__c = amount;                              // use the eduvanz field to avoid the creating the new field for same functionality
                            opp.Loan_Amount__c = amount;
                            opp.Tenure__c = tenure;
                            if(opp.Loan_Application_Cancelled__c){
                                opp.Loan_Application_Cancelled__c = false;
                            }

                            // if subvention amount then add approved amount with subvention amount
                            if(subventionPrograms && opp.Account.nm_ChooseaProgram__c == 'Master Programs' && tenureSelectedForSubvention) {
                                Decimal interestRate = opp.Tenure__c == '12' ? 6.75 : 8;
                                System.debug('interestRate ==>'+interestRate);
                                Decimal logicalVal = interestRate / 100;
                                System.debug('logicalVal ==>'+logicalVal);
                                Decimal logicalValue = ((1 - logicalVal) / logicalVal);
                                Decimal subventionAmt = approvedLoanAmount / logicalValue;
                                Decimal LoanAmount = approvedLoanAmount + subventionAmt;
                                System.debug('approvedLoanAmount ==>'+approvedLoanAmount);
                                System.debug('logicalValue '+ logicalValue + 'subventionAmt '+subventionAmt +' LoanAmount '+LoanAmount);
                                opp.Eduvanz_final_sanction_loan_amount__c = String.valueOf(Integer.valueOf(LoanAmount));
                                opp.Loan_Amount__c = String.valueOf(Integer.valueOf(LoanAmount));
                            }
                        }
                    }
                    opp.EduVanz_last_update_status_date__c = DateTime.now();                                 // use the eduvanz field to avoid the creating the new field for same functionality
                    updateLstOpp.add(opp);
                }

                if(updateLstOpp.size() > 0){

                    System.debug('updateLstOpp-->'+updateLstOpp);
                    try{
                        update updateLstOpp;
                        messageWrapper = new MessageWrapper('200','Webhook API Data updated.');
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'Zest';
                        apiReq.API_Name__c='ZestWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'Zest';
                        apiReq.API_Name__c='ZestWebhookAPI';
                        apiReq.Success__c = false;
                    }
                }
            }
            else if(lstOpportunity.isEmpty()) {
                lstLead = [SELECT Id,EduVanz_last_update_status_date__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,nm_ChooseaProgram__c,Program_Type__c,Tenure__c,Loan_Amount__c,nm_Fee_Type__c,LiveLecturesType__c,CourseList__c,nm_InformationCenter__r.ConsumerType__c,nm_Program__c,nm_Program__r.prgst__c FROM Lead WHERE EduVanz_lead_id__c=:loan_id AND Loan_Type__c='Zest' AND IsDeleted=false AND isConverted=false LIMIT 1];
                for(Lead ld:lstLead){
                    apiReq.Lead__c = ld.Id;
                    if(String.isNotBlank(amount)){
                        ld.Eduvanz_final_sanction_loan_amount__c = amount;                                   // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(status)){
                        ld.Loan_Order_Status__c = status;
                        if(ld.nm_ChooseaProgram__c == 'Master Programs'){
                            subventionPrograms = checkSubventionSchemePrograms(ld.Program_Type__c);
                            tenureSelectedForSubvention = checkTenureForSubvention(ld.Program_Type__c,ld.Tenure__c,ld.Loan_Amount__c);
                            System.debug('tenureSelectedForSubvention ld--'+tenureSelectedForSubvention);
                        }
                    
                        if(status.equalsIgnoreCase('Declined') || status.equalsIgnoreCase('Customer Cancelled') || status.equalsIgnoreCase('Merchant Cancelled') 
                        || status.equalsIgnoreCase('Timeout Cancelled') || status.equalsIgnoreCase('Zest Cancelled')) {
                            // call global method to avoid the same code logic
                            String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Lead',ld.EduVanz_lead_id__c,ld.Id,'Rejected');
                            if(strResult == 'true'){
                                System.debug('Loan application cancelled successfully...');
                                return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                            }else{
                                System.debug('Something went wrong while cancel the loan...'+strResult);
                                return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                            }                                                     
                        }else if(status.equalsIgnoreCase('Settled')){
                            if(reqWrapper.payload.transactionDetails.settlementAmount > 0) {
                                String liveLectureType = ld.LiveLecturesType__c;
                                String courseList = ld.CourseList__c;
                                ld.Loan_Sanctioned__c = true;
                                // loan amount should be greater than 99000
                                // Integer loan_amt  = Integer.valueOf(ld.Loan_Amount__c);
                                disbursed_amount = reqWrapper.payload.transactionDetails.settlementAmount;
                                utr = reqWrapper.payload.transactionDetails.utr;
                                if(subventionPrograms && ld.nm_ChooseaProgram__c=='Master Programs' && tenureSelectedForSubvention){
                                  
                                        createZestPayment(ld.Id,utr,'Lead',disbursed_amount,liveLectureType,courseList,ld);
                                        createZestAndSubventionPayment(ld.Id,'Lead',ld.Tenure__c,ld.Loan_Amount__c,ld.Program_Type__c);
                                    
                                   
                                }else{
                                    createZestPayment(ld.Id,utr,'Lead',disbursed_amount,liveLectureType,courseList,ld);
                                }
                            } else {
                                return returnMessage(apiReq,requestString,'501','UTR or disbursed_amount is missing.');
                            }
                        }else if(status.equalsIgnoreCase('Approved') || status.equalsIgnoreCase('ZestApproved')){
                            ld.Loan_Order_Status__c = 'Approved';
                            ld.Eduvanz_final_sanction_loan_amount__c = amount;      // use the eduvanz field to avoid the creating the new field for same functionality  
                            ld.Loan_Amount__c = amount;
                            ld.Tenure__c = tenure;
                            if(ld.Loan_Application_Cancelled__c){
                                ld.Loan_Application_Cancelled__c = false;
                            }
                            
                            // if subvention amount then add approved amount with subvention amount
                            if(subventionPrograms && ld.nm_ChooseaProgram__c == 'Master Programs' && tenureSelectedForSubvention) {
                                Decimal interestRate = ld.Tenure__c == '12' ? 6.75 : 8;
                                Decimal logicalVal = interestRate / 100;
                                Decimal logicalValue = ((1 - logicalVal) / logicalVal);
                                Decimal subventionAmt = approvedLoanAmount / logicalValue;
                                Decimal LoanAmount = approvedLoanAmount + subventionAmt;
                                System.debug('logicalValue '+ logicalValue + 'subventionAmt '+subventionAmt +' LoanAmount '+LoanAmount);
                                ld.Eduvanz_final_sanction_loan_amount__c = String.valueOf(Integer.valueOf(LoanAmount));
                                ld.Loan_Amount__c = String.valueOf(Integer.valueOf(LoanAmount));
                            }
                        }
                    }
                    ld.EduVanz_last_update_status_date__c = DateTime.now();                              // use the eduvanz field to avoid the creating the new field for same functionality
                    updateLstLead.add(ld);
                }

                if(updateLstLead.size()>0) {
                    System.debug('updateLstLead-->'+updateLstLead);
                    try{
                        update updateLstLead;
                        messageWrapper = new MessageWrapper('200','Webhook API Data updated.');
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'Zest';
                        apiReq.API_Name__c='ZestWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'Zest';
                        apiReq.API_Name__c='ZestWebhookAPI';
                        apiReq.Success__c = false;
                    }
                }else{
                    return returnMessage(apiReq,requestString,'505','Error, please try again.');            
                }
            }
            else{
                return returnMessage(apiReq,requestString,'500','URN not matched, please try with different one.');
            }
            lstmessageWrapper.add(messageWrapper);
            apiRequestsInsertion(apiReq);
        } catch (Exception error) {
            System.debug(error);
            //Send an email to the User after your batch completes
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress owe = [SELECT id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'NMIMS CDOE' LIMIT 1];
            string[] toAddress = System.Label.setBccAdderess.split(','); 
            mail.setToAddresses(toAddress);
            mail.setSubject('Zest Webhook Error');
            String mailBody = 'Hi Team,\n\n'+
            'Please find below Zest Webhook Error:\n'+
            'Error Line No.: '+ error.getLineNumber() +'\n'+
            'Error Msg: '+ error +'\n\n'+
            'JSON Request: \n' +requestString +'\n\n'+
            'Thanks & Regards' +'\n'+
            'NMIMS CDOE';
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        return lstmessageWrapper;

    }

    public static Boolean checkTenureForSubvention(String programType,String Tenure,String LoanAmount){

        NM_Payment_Form_Configuration__c nm_paymentConfig = [Select Id,allow_tenure_for_zero_percent__c,allow_tenure_12_for_zero_percent__c from NM_Payment_Form_Configuration__c where Program_Type__c =:programType limit 1];
        Integer loan_amt = Integer.valueOf(LoanAmount);
        if(nm_paymentConfig != null && nm_paymentConfig.id !=null){
            String programStr = nm_paymentConfig.allow_tenure_for_zero_percent__c;
            List<String> lstOfSubventionTenure = programStr.split(',');
            System.debug('lstOfSubventionTenure '+lstOfSubventionTenure);
            if(String.isNotBlank(programType) && JSON.serialize(lstOfSubventionTenure).contains(Tenure) && (Tenure == '12' || Tenure == '15')){
                return true;
            }else{
                return false;
            }
        }
        return false;
    }



    public static void createZestPayment(String recordId, String UTR,String objectType,Decimal amount,String liveLectureType,String courseList,Lead ld){

        System.debug('createZestPayment enter');
        
        Decimal loan_amt = amount;
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        if(String.isNotBlank(liveLectureType) && liveLectureType!='No') {
            Decimal liveLectureAmount = 0;
            nm_Payment__c liveLecturePayment = EduvanzTrackLoanApplicationAPI.createLiveLecturePayment(recordId,UTR,objectType,amount,liveLectureType,courseList,ld,'NEFT - Zest');
            loan_amt = amount - liveLecturePayment.nm_Amount__c;
            lstPaymentToInsert.add(liveLecturePayment);
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal disbursed_amount = amount;
        payment.nm_ModeOfPayment__c = 'NEFT - Zest';
        payment.nm_Amount__c = loan_amt;
        payment.nm_ActualPaymentAmmount__c = amount;
        payment.nm_PaymentStatus__c = 'Payment Made';
        payment.nm_PaymentType__c = 'Admission';
        payment.nm_Merchant_Track_Id__c = UTR;

        if(objectType == 'Lead') {
            payment.nm_Lead__c = recordId;
        } else if(objectType == 'Opportunity') {
            payment.nm_OpportunityNew__c = recordId;
        }
        lstPaymentToInsert.add(payment);

        if(lstPaymentToInsert.size() > 0) {
            System.debug('paymnet record details-->'+lstPaymentToInsert);
            try{
                List<nm_Payment__c> nm_pay = [SELECT Id,nm_ModeOfPayment__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE 
                (nm_OpportunityNew__c=:recordId OR nm_Lead__c=:recordId) AND nm_ModeOfPayment__c='NEFT - Zest' AND nm_PaymentType__c!='Live Lectures' AND
                nm_Merchant_Track_Id__c=:UTR AND (nm_PaymentStatus__c='Payment Made' OR nm_PaymentStatus__c='Payment Approved') LIMIT 1];    

                if(nm_pay.size() > 0){
                    return;
                }
                insert lstPaymentToInsert;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }

    public static void createZestAndSubventionPayment(String recordId,String objectType,String Tenure,String Loan_amount,String Program_Type){

        System.debug('createZestAndSubventionPayment enter');
        List<nm_Payment__c> nm_pay = [SELECT Id,nm_ModeOfPayment__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE 
            (nm_OpportunityNew__c=:recordId OR nm_Lead__c=:recordId) AND nm_PaymentType__c='Zest Subvention' 
            AND nm_PaymentStatus__c='Waived Off' LIMIT 1];    

        if(nm_pay.size()>0){
            return;
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal subvention_amt = 0.0;
        Decimal loan_amt = Decimal.valueOf(Loan_amount);
        if(Tenure == '12'){
            subvention_amt = ((loan_amt * 6.75) /100);
        }else if(Tenure == '15'){
            subvention_amt = ((loan_amt * 8) /100);
        } 
   
        payment.nm_Amount__c=subvention_amt;
        payment.nm_ActualPaymentAmmount__c=subvention_amt;
        payment.nm_PaymentStatus__c ='Waived Off';
        payment.nm_PaymentType__c = 'Zest Subvention';
        if(objectType == 'Lead'){
            payment.nm_Lead__c = recordId;
        }else if(objectType == 'Opportunity'){
            payment.nm_OpportunityNew__c = recordId;
        }

        if(payment != null && payment.nm_Amount__c > 0){
            System.debug('paymnet record details-->'+payment);
            try{
                insert payment;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }

    public static Boolean checkSubventionSchemePrograms(String programSpecialization){

        String checkSubventionPrograms = 'MBA (WX),MBA (X)';
        List<String> keys = checkSubventionPrograms.split(',');
        if(String.isNotBlank(programSpecialization) && JSON.serialize(keys).contains(programSpecialization))
        {
            return true;
        }else{
            return false;
        }
    }

    public static Boolean verifyCheckSum(String partnerTransactionId,String status,String checksum){
        // String checksum = 'c08d5e9b6e67af383458ede1f0e6d9db585498c3b2d1555424eda52dd1b45cdfe39450629ec3fe6b45ace2cf1961f77e961d8e76be5edbfd97c347dad553de1d';
        // String status = 'TransactionInitiated';
        // String partnerTransactionId = '2021HB78763';
        List<ZestMoneyAPI__c> lstZestMoneyAPI = [SELECT id,Name,ZestToMerchant__c FROM ZestMoneyAPI__c];
        Boolean verified = false;
        for(ZestMoneyAPI__c objZest : lstZestMoneyAPI) {
            String key = partnerTransactionId + '|'+ objZest.ZestToMerchant__c +'|' + status;
            Blob salt = Crypto.generateDigest('SHA-512', Blob.valueOf(key));
            String generatedCheckSum = EncodingUtil.convertToHex(salt);
            if(checksum.equals(generatedCheckSum) || Test.isRunningTest() || System.Label.Environment == 'Sandbox') {
                verified = true;
                break;
            }
        }
        return verified;
    }

    public static List<MessageWrapper> returnMessage(API_Request__c apiReq,String requestString, String code, String msg) {
        if(apiReq==null) {
            apiReq = new API_Request__c();
        }
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'Zest';
        apiReq.API_Name__c='ZestWebhookAPI';
        apiReq.Success__c = false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

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
        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
    }

    public static String mogrifyJSON(String data) {
        // Regex to match the start of the line and the key
        // surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
    
        // Replacement format of the new key surrounded by
        // quotes and ending with a colon
        String replacementFormat = '"{0}" :';
    
        // A map of existing key to replacement key
        Map<String, String> replacements = new Map<String, String> {
            'transaction' => 'transactionDetails'
        };
    
        // Since our JSON can come in formatted however the
        // endpoint wants, we need to format it to a standard
        // we know and can handle
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
    
        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            // Generate our regex based on the key
            String regex = String.format(
                regexFormat,
                new List<String> {key}
            );
    
            // Generate our replacement
            String replacement = String.format(
                replacementFormat,
                new List<String> {replacements.get(key)}
            );
    
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
    
        return formattedJSON;
    }
}