/**
 * @description       : 
 * @author            : shubhranshu
 * @group             : 
 * @last modified on  : 03-01-2023
 * @last modified by  : @BK
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   08-20-2020   shubhranshu   Initial Version
**/
@RestResource(urlMapping='/EzcredWebhookAPI/V1.1/*')
global without sharing class EzcredWebhookAPI {
    /**
    * @description 
    To Tracking the loan status for ezcred loan application
    * @author shubhranshu | 08-21-2020 
    * @return List<MessageWrapper> 
    **/
    @HttpPost
    global static List<MessageWrapper> TrackEzcredLoanStaus(){
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('requestString '+requestString);
        requestString  = requestString.replace('"number"','"mnumber"');
        EzCredWebhookWrapper reqWrapper = EzCredWebhookWrapper.parse(requestString);
        apiReq.Request__c = requestString;
        System.debug(reqWrapper);
        Decimal approvedLoanAmount = 0;
        String lead_number ='';
        String loan_account_number = '';
        String partner_reference_id = '';
        String amount ='';
        String submitted_on_date = '';
        String status ='';
        Decimal disbursal_amount = 0;
        String tenure ='';
        String emi ='';
        String utr;

        MessageWrapper messageWrapper = null;

        if(String.isNotBlank(reqWrapper.lead_number) && String.isNotBlank(reqWrapper.loan_account_number)){
            lead_number = reqWrapper.lead_number;
            loan_account_number = reqWrapper.loan_account_number;
        }else{
            return returnMessage(apiReq,requestString,'511','lead_number or loan_account_number is missing.');
        }

        if(reqWrapper.loan_detail.principal > 0){
            amount = String.valueOf(reqWrapper.loan_detail.principal);
        }else{
            return returnMessage(apiReq,requestString,'501','amount is missing.');
        }

        if(String.isNotBlank(reqWrapper.status)){
            status =reqWrapper.status;
        }else{
            return returnMessage(apiReq,requestString,'501','status is missing.');
        }

        if(String.isNotBlank(reqWrapper.partner_reference_id)){
            partner_reference_id =reqWrapper.partner_reference_id;
        }else{
            return returnMessage(apiReq,requestString,'501','partner_reference_id is missing.');
        }

        if(String.isNotBlank(reqWrapper.submitted_on_date)){
            submitted_on_date =reqWrapper.submitted_on_date;
        }

        if(reqWrapper.loan_detail.number_of_repayments > 0){
            tenure=String.valueOf(reqWrapper.loan_detail.number_of_repayments);
        }
        if(reqWrapper.loan_detail.emi_amount > 0) {
            emi = String.valueOf(reqWrapper.loan_detail.emi_amount);
        }

        List<Opportunity> updateLstOpp = new List<Opportunity>();
        List<Opportunity> lstOpportunity = [SELECT Id,Specialisation__c,EduVanz_last_update_status_date__c,Tenure__c,Loan_Amount__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,Account.nm_ChooseaProgram__c ,Account.Program_Type__c,Loan_Account_number__c FROM Opportunity WHERE EduVanz_lead_id__c=:lead_number AND Loan_Type__c='EzCred' LIMIT 1];
        
        List<Lead> updateLstLead = new List<Lead>();
        List<Lead> lstLead = new List<Lead>();

        if(lstOpportunity.size() > 0) {
            System.debug('lstOpportunity '+lstOpportunity);
            for(Opportunity opp: lstOpportunity) {
                apiReq.Opportunity__c = opp.Id;

                if(String.isNotBlank(amount)){
                    opp.Eduvanz_final_sanction_loan_amount__c = amount;                  // use the eduvanz field to avoid the creating the new field for same functionality
                }
                if(String.isNotBlank(loan_account_number)){
                    opp.Loan_Account_number__c = loan_account_number;                  // use the eduvanz field to avoid the creating the new field for same functionality
                }
                
                if(String.isNotBlank(status)){
                    opp.Loan_Order_Status__c = status;

                    if(status.equalsIgnoreCase('REJECTED')){
                        // call global method to avoid the same code logic
                        String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Opportunity',opp.EduVanz_lead_id__c,opp.Id,'Rejected');
                        if(strResult == 'true'){
                            System.debug('Loan application cancelled successfully...');
                            return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                        }else{
                            System.debug('Something went wrong while cancel the loan...'+strResult);
                            return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                        }
                    }else if(status.equalsIgnoreCase('DISBURSED')){
                        System.debug('reqWrapper.disbursal_data '+reqWrapper.disbursal_data);
                        if(reqWrapper.disbursal_data != null){
                            if(string.isNotBlank(reqWrapper.disbursal_data.disbursal_utr) && reqWrapper.disbursal_data.disbursal_amount > 0){
                                opp.Loan_Sanctioned__c  = true;
                                disbursal_amount = reqWrapper.disbursal_data.disbursal_amount;
                                utr = reqWrapper.disbursal_data.disbursal_utr;
                                createEzCredPayment(opp.Id,utr,'Opportunity',disbursal_amount); 
                            }else{
                                return returnMessage(apiReq,requestString,'501','disbursal_utr or disbursal_amount is missing.');
                            }    
                        }else{
                            return returnMessage(apiReq,requestString,'509','disbursal_data is missing.');
                        }
                    }else if(status.equalsIgnoreCase('APPROVED')){
                        opp.Eduvanz_final_sanction_loan_amount__c = amount;                              // use the eduvanz field to avoid the creating the new field for same functionality
                        opp.Loan_Amount__c = amount;
                        opp.Tenure__c = tenure;
                        opp.EMI_Amount__c = emi;
                        if(opp.Loan_Application_Cancelled__c){
                            opp.Loan_Application_Cancelled__c = false;
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
                    apiReq.Type_of_Request__c= 'EzCred';
                    apiReq.API_Name__c='EzCredWebhookAPI';
                    apiReq.Success__c = true;
                }catch(Exception e){
                    messageWrapper = new MessageWrapper('504',e.getMessage());
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EzCred';
                    apiReq.API_Name__c='EzCredWebhookAPI';
                    apiReq.Success__c = false;
                }
            }
        } else if(lstOpportunity.isEmpty()) {
            System.debug('lstLead '+lstLead);
            lstLead = [SELECT Id,EduVanz_last_update_status_date__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,nm_ChooseaProgram__c,Program_Type__c,Tenure__c,Loan_Amount__c FROM Lead WHERE EduVanz_lead_id__c=:lead_number AND Loan_Type__c='EzCred' AND IsDeleted=false LIMIT 1];
            for(Lead ld:lstLead){
                apiReq.Lead__c = ld.Id;
                if(String.isNotBlank(amount)){
                    ld.Eduvanz_final_sanction_loan_amount__c = amount;                                   // use the eduvanz field to avoid the creating the new field for same functionality
                }
                if(String.isNotBlank(loan_account_number)){
                    ld.Loan_Account_number__c = loan_account_number;                 
                }
                if(String.isNotBlank(status)){
                    ld.Loan_Order_Status__c = status;
                    if(status.equalsIgnoreCase('REJECTED')){
                        // call global method to avoid the same code logic
                        String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Lead',ld.EduVanz_lead_id__c,ld.Id,'Rejected');
                        if(strResult == 'true'){
                            System.debug('Loan application cancelled successfully...');
                            return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                        }else{
                            System.debug('Something went wrong while cancel the loan...'+strResult);
                            return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                        }                                                                   
                    }else if(status.equalsIgnoreCase('DISBURSED')){
                        System.debug('reqWrapper.disbursal_data '+reqWrapper.disbursal_data);
                        if(reqWrapper.disbursal_data != null){
                            if(string.isNotBlank(reqWrapper.disbursal_data.disbursal_utr) && reqWrapper.disbursal_data.disbursal_amount > 0){
                                ld.Loan_Sanctioned__c  = true;
                                disbursal_amount = reqWrapper.disbursal_data.disbursal_amount;
                                utr = reqWrapper.disbursal_data.disbursal_utr;
                                createEzCredPayment(ld.Id,utr,'Opportunity',disbursal_amount); 
                            }else{
                                return returnMessage(apiReq,requestString,'501','disbursal_utr or disbursal_amount is missing.');
                            }    
                        }else{
                            return returnMessage(apiReq,requestString,'509','disbursal_data is missing.');
                        }
                    }else if(status.equalsIgnoreCase('APPROVED')){
                        ld.Eduvanz_final_sanction_loan_amount__c = amount;      // use the eduvanz field to avoid the creating the new field for same functionality  
                        ld.Loan_Amount__c = amount;
                        ld.Tenure__c = tenure;
                        if(ld.Loan_Application_Cancelled__c){
                            ld.Loan_Application_Cancelled__c = false;
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
                    apiReq.Type_of_Request__c= 'EzCred';
                    apiReq.API_Name__c='EzCredWebhookAPI';
                    apiReq.Success__c = true;
                }catch(Exception e){
                    messageWrapper = new MessageWrapper('504',e.getMessage());
                    apiReq.Response__c = messageWrapper.toString();
                    apiReq.Type_of_Request__c= 'EzCred';
                    apiReq.API_Name__c='EzCredWebhookAPI';
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
        return lstmessageWrapper;
    }
    
    /**
    * @description 
    To create the NEFT Record
    * @author shubhranshu | 08-21-2020 
    * @param recordId 
    * @param UTR 
    * @param objectType 
    * @param amount 
    **/
    public static void createEzCredPayment(String recordId, String UTR,String objectType,Decimal amount){

        
        Decimal loan_amt = amount;
        nm_Payment__c payment = new nm_Payment__c();
        Decimal disbursed_amount = amount;
        payment.nm_ModeOfPayment__c = 'NEFT - EzCred';
        payment.nm_Amount__c = loan_amt;
        payment.nm_ActualPaymentAmmount__c = loan_amt;
        payment.nm_PaymentStatus__c = 'Payment Made';
        payment.nm_PaymentType__c = 'Admission';
        payment.nm_Merchant_Track_Id__c = UTR;

        if(objectType == 'Lead') {
            payment.nm_Lead__c = recordId;
        } else if(objectType == 'Opportunity') {
            payment.nm_OpportunityNew__c = recordId;
        }

        if(payment != null) {
            System.debug('paymnet record details-->'+payment);
            try{
                List<nm_Payment__c> nm_pay = [SELECT Id,nm_ModeOfPayment__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE 
                (nm_OpportunityNew__c=:recordId OR nm_Lead__c=:recordId) AND nm_ModeOfPayment__c='NEFT - EzCred' AND 
                nm_Merchant_Track_Id__c=:UTR AND (nm_PaymentStatus__c='Payment Made' OR nm_PaymentStatus__c='Payment Approved') LIMIT 1];    

                if(nm_pay.size() > 0){
                    return;
                }

                insert payment;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }
    
    /**
    * @description 
    To get the return message 
    * @author shubhranshu | 08-21-2020 
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
        apiReq.Type_of_Request__c= 'EzCred';
        apiReq.API_Name__c='EzCredWebhookAPI';
        apiReq.Success__c = false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    /**
    * @description 
    to save the logs for ezcred webhokk api
    * @author shubhranshu | 08-21-2020 
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

        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
    }
}