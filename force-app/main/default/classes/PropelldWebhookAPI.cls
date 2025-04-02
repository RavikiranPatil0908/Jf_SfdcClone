/**
 * @File Name          : PropelldWebhookAPI.cls
 * @Description        : 
 * @Author             : @BK
 * @Group              : 
 * @Last Modified By   : @BK
 * @Last Modified On   : 21-09-2024
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/4/2020   @BK     Initial Version
**/
@RestResource(urlMapping='/PropelldWebhookAPI/V1.1/*')
global without sharing class PropelldWebhookAPI {

    public static Boolean subventionPrograms = false;
    public static Boolean tenureSelectedForSubvention = false;

    @HttpPost
    global static List<MessageWrapper> TrackPropelldStaus(){
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        String requestString = '';
        try {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String propelldPayLoad = RestContext.request.requestBody.toString();
            requestString = body.toString();
            System.debug('requestString '+requestString);
            PropelledResponseWrapper reqWrapper = PropelledResponseWrapper.parse(requestString);
            apiReq.Request__c = requestString;
            System.debug(reqWrapper);
            Decimal approvedLoanAmount = 0;
            String loan_id ='';
            String amount ='';
            String status ='';
            String utr = '';
            Decimal disbursed_amount = 0;
            String tenure ='';
        
            String checksum ='';
            MessageWrapper messageWrapper = null;

            // if(String.isNotBlank(req.headers.get('X-Propelld-Signature'))){
            //     checksum = req.headers.get('X-Propelld-Signature');
            // } else {
            //     return returnMessage(requestString,'501','checksum is missing.');
            // }

            // if(!verifyCheckSum(body,checksum)) {
            //     return returnMessage(requestString,'501','checksum is not matched..');
            // }

            if(String.isNotBlank(reqWrapper.Payload.Application.QuoteId)){
                loan_id = reqWrapper.Payload.Application.QuoteId;
            }else{
                return returnMessage(apiReq,requestString,'511','Loan id is missing.');
            }

            if(String.isNotBlank(reqWrapper.Payload.Application.Status)){
                status = reqWrapper.Payload.Application.Status;
            }else{
                return returnMessage(apiReq,requestString,'501','status is missing.');
            }

            if(reqWrapper.Entities.contains('Loan')) {
                if(reqWrapper.Payload.Loan != null && reqWrapper.Payload.Loan.LoanAmount > 0){
                    amount = String.valueOf(reqWrapper.Payload.Loan.AppliedLoanAmount);
                    tenure = String.valueOf(reqWrapper.Payload.Loan.TotalTenor);
                    approvedLoanAmount = reqWrapper.Payload.Loan.AppliedLoanAmount;
                }else{
                    return returnMessage(apiReq,requestString,'501','Amount is missing.');
                }
            }

            if(reqWrapper.Entities.contains('Disbursement') && reqWrapper.Payload.Disbursement.size() == 0) {
                return returnMessage(apiReq,requestString,'501','UTR is missing.');
            }

            System.debug('loan_id-->'+loan_id+' amount-->'+amount+' status-->'+status+' checksum-->'+checksum);
            
            List<Opportunity> updateLstOpp = new List<Opportunity>();
            List<Opportunity> lstOpportunity = [SELECT Id,Specialisation__c,EduVanz_last_update_status_date__c,Tenure__c,Loan_Amount__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,Account.nm_ChooseaProgram__c ,Account.Program_Type__c,nm_Fee_Type__c,ChooseProgram__c,ActualPendingAmount__c,LiveLecturesType__c,CourseList__c FROM Opportunity WHERE EduVanz_lead_id__c=:loan_id AND Loan_Type__c='Propelld' LIMIT 1];
            
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
                        if(status.equalsIgnoreCase('REJECTED') || status.equalsIgnoreCase('DROPPED')){
                            // call global method to avoid the same code logic
                            String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Opportunity',opp.EduVanz_lead_id__c,opp.Id,'Rejected');
                            if(strResult == 'true'){
                                System.debug('Loan application cancelled successfully...');
                                return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                            }else{
                                System.debug('Something went wrong while cancel the loan...'+strResult);
                                return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                            }
                        }else if(status.equalsIgnoreCase('DISBURSED') && reqWrapper.Entities.contains('Disbursement')){
                            // System.debug('subventionProg--'+subventionPrograms +'opp.Account.nm_ChooseaProgram__c --'+opp.Account.nm_ChooseaProgram__c );
                            List<PropelledResponseWrapper.Disbursement> lstDisbursment = reqWrapper.Payload.Disbursement;
                            if(lstDisbursment.size() > 0){
                                Tenure__c objTenure = getTenureForSubvention(opp.nm_Fee_Type__c,opp.Account.nm_ChooseaProgram__c,opp.Specialisation__c,opp.Tenure__c);
                                opp.Loan_Sanctioned__c  = true;
                                String liveLectureType = opp.LiveLecturesType__c;
                                String courseList = opp.CourseList__c;
                                for (PropelledResponseWrapper.Disbursement objDisbursment : lstDisbursment) {
                                    disbursed_amount = objDisbursment.DisbursementAmount;
                                    utr = objDisbursment.DisbursementReference;
                                    System.debug('opp.Account.nm_ChooseaProgram__c --> ' + opp.Account.nm_ChooseaProgram__c);
                                    System.debug('opp.nm_Fee_Type__c --> ' + opp.nm_Fee_Type__c);
                                    System.debug('objTenure ==>'+objTenure);
                                    List<String> lstallTermfeeProgram = new List<String>{'MBA - X','MBA (WX)','M.Sc. (AI & ML Ops)','M.Sc. (AI)'}; 
                                    if(String.isNotBlank(opp.Specialisation__c) && lstallTermfeeProgram.contains(opp.Specialisation__c) && opp.nm_Fee_Type__c != 'AnnualFee' && opp.nm_Fee_Type__c != 'FullFee'){
                                        opp.nm_Fee_Type__c = 'MBAallTermfee';
                                    }
                                    if(objTenure!=null && objTenure.Subvention_Value__c > 0){
                                        if(decimal.valueOf(amount)> 0){
                                            createPropelldPayment(opp.Id,utr,'Opportunity',disbursed_amount,liveLectureType,courseList,null);
                                            createPropelldAndSubventionPayment(opp.Id,'Opportunity',opp.Loan_Amount__c,disbursed_amount,objTenure);
                                        }
                                    } else  {
                                        createPropelldPayment(opp.Id,utr,'Opportunity',disbursed_amount,liveLectureType,courseList,null);
                                    }
                                }
                            }else{
                                return returnMessage(apiReq,requestString,'501','UTR or disbursed_amount is missing.');
                            }    
                        }else if(status.equalsIgnoreCase('APPROVED')){
                            opp.Eduvanz_final_sanction_loan_amount__c = amount;                              // use the eduvanz field to avoid the creating the new field for same functionality
                            opp.Loan_Amount__c = amount;
                            opp.Tenure__c = tenure;
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
                        apiReq.Type_of_Request__c= 'Propelld';
                        apiReq.API_Name__c='PropelldWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'Propelld';
                        apiReq.API_Name__c='PropelldWebhookAPI';
                        apiReq.Success__c = false;
                    }
                }
            }
            else if(lstOpportunity.isEmpty()) {
                lstLead = [SELECT Id,EduVanz_last_update_status_date__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,nm_ChooseaProgram__c,Program_Type__c,Tenure__c,Loan_Amount__c,nm_Fee_Type__c,LiveLecturesType__c,CourseList__c,nm_InformationCenter__r.ConsumerType__c,nm_Program__c,nm_Program__r.prgst__c FROM Lead WHERE EduVanz_lead_id__c=:loan_id AND Loan_Type__c='Propelld' AND IsDeleted=false LIMIT 1];
                for(Lead ld:lstLead){
                    apiReq.Lead__c = ld.Id;
                    if(String.isNotBlank(amount)){
                        ld.Eduvanz_final_sanction_loan_amount__c = amount;                                   // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(status)){
                        ld.Loan_Order_Status__c = status;
                        if(status.equalsIgnoreCase('REJECTED') || status.equalsIgnoreCase('DROPPED')){
                            // call global method to avoid the same code logic
                            String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Lead',ld.EduVanz_lead_id__c,ld.Id,'Rejected');
                            if(strResult == 'true'){
                                System.debug('Loan application cancelled successfully...');
                                return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                            }else{
                                System.debug('Something went wrong while cancel the loan...'+strResult);
                                return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                            }                                                        
                        }else if(status.equalsIgnoreCase('DISBURSED') && reqWrapper.Entities.contains('Disbursement')){
                            List<PropelledResponseWrapper.Disbursement> lstDisbursment = reqWrapper.Payload.Disbursement;
                            if(lstDisbursment.size() > 0){
                                Tenure__c objTenure = getTenureForSubvention(ld.nm_Fee_Type__c,ld.nm_ChooseaProgram__c,ld.Program_Type__c,ld.Tenure__c);
                                String liveLectureType = ld.LiveLecturesType__c;
                                String courseList = ld.CourseList__c;
                                ld.Loan_Sanctioned__c = true;
                                for (PropelledResponseWrapper.Disbursement objDisbursment : lstDisbursment) {
                                    disbursed_amount = objDisbursment.DisbursementAmount;
                                    utr = objDisbursment.DisbursementReference;
                                    if(objTenure!=null && objTenure.Subvention_Value__c > 0){
                                        if(decimal.valueOf(amount) > 0){
                                            createPropelldPayment(ld.Id,utr,'Lead',disbursed_amount,liveLectureType,courseList,ld);
                                            createPropelldAndSubventionPayment(ld.Id,'Lead',ld.Loan_Amount__c,disbursed_amount,objTenure);
                                        }
                                    }else{
                                        createPropelldPayment(ld.Id,utr,'Lead',disbursed_amount,liveLectureType,courseList,ld);
                                    }
                                }
                            }else{
                                return returnMessage(apiReq,requestString,'501','UTR or disbursed_amount is missing.');
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
                        apiReq.Type_of_Request__c= 'Propelld';
                        apiReq.API_Name__c='PropelldWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'Propelld';
                        apiReq.API_Name__c='PropelldWebhookAPI';
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
            mail.setSubject('Propelld Webhook Error');
            String mailBody = 'Hi Team,\n\n'+
            'Please find below Propelld Webhook Error:\n'+
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

    /**
    * @description 
    * @author @BK | 10-04-2023 
    * @param feeType 
    * @param chooseProgram 
    * @param Program_Type 
    * @param Tenure 
    * @return Tenure__c 
    **/
    public static Tenure__c getTenureForSubvention(String feeType,String chooseProgram,String Program_Type,String Tenure) {
        feeType = feeType == 'MBAallTermfee' || feeType == 'ReRegistrationPayment' ? 'Admission' : feeType;
        String key = chooseProgram+'-'+Program_Type+'-Propelld-'+feeType;
        List<Tenure__c> lstTenures = [SELECT id,Subvention_Value__c,Tranche_Payment__c FROM Tenure__c WHERE Key__c=:key AND Tenure__c=:Tenure AND IsActive__c=true LIMIT 1];
        if(lstTenures.size() > 0 && lstTenures[0].Subvention_Value__c > 0) {
            return lstTenures[0];
        }
        return null;
    }

    /**
    * @description 
    * @author @BK | 10-04-2023 
    * @param recordId 
    * @param UTR 
    * @param objectType 
    * @param amount 
    * @param liveLectureType 
    * @param courseList 
    * @param ld 
    **/
    public static void createPropelldPayment(String recordId, String UTR,String objectType,Decimal amount,String liveLectureType,String courseList,Lead ld){

        System.debug('createPropelldPayment enter');

        System.debug(amount);
        Decimal loan_amt = amount;
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        if(String.isNotBlank(liveLectureType) && liveLectureType!='No') {
            Decimal liveLectureAmount = 0;
            nm_Payment__c liveLecturePayment = EduvanzTrackLoanApplicationAPI.createLiveLecturePayment(recordId,UTR,objectType,amount,liveLectureType,courseList,ld,'NEFT - Propelld');
            loan_amt = amount - liveLecturePayment.nm_Amount__c;
            lstPaymentToInsert.add(liveLecturePayment);
        }

        nm_Payment__c payment = new nm_Payment__c();
        payment.nm_ModeOfPayment__c = 'NEFT - Propelld';
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
        if(payment.nm_Amount__c > 0 ){
            lstPaymentToInsert.add(payment);
        }
        
        if(lstPaymentToInsert.size() > 0) {
            System.debug('paymnet record details-->'+lstPaymentToInsert);
            try{
                List<nm_Payment__c> nm_pay = [SELECT Id,nm_ModeOfPayment__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE 
                (nm_OpportunityNew__c=:recordId OR nm_Lead__c=:recordId) AND nm_ModeOfPayment__c='NEFT - Propelld' AND nm_PaymentType__c!='Live Lectures' AND
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

    /**
    * @description 
    * @author @BK | 10-04-2023 
    * @param recordId 
    * @param objectType 
    * @param Loan_amount 
    * @param disbursed_amount 
    * @param objTenure 
    **/
    public static void createPropelldAndSubventionPayment(String recordId,String objectType,String Loan_amount, Decimal disbursed_amount, Tenure__c objTenure){

        System.debug('createPropelldAndSubventionPayment enter');
        Boolean paymentCreated = false;
        List<nm_Payment__c> nm_pay = [SELECT Id,nm_ModeOfPayment__c,nm_PaymentStatus__c,nm_PaymentType__c FROM nm_Payment__c WHERE 
            (nm_OpportunityNew__c=:recordId OR nm_Lead__c=:recordId) AND nm_PaymentType__c='Propelld Subvention' 
            AND nm_PaymentStatus__c='Waived Off' LIMIT 1];    

        if(nm_pay.size()>0){
            paymentCreated = true;
        }
        nm_Payment__c payment = new nm_Payment__c();
        Decimal subvention_amt = 0.0;
        Decimal loan_amt = Decimal.valueOf(Loan_amount);
        if(objTenure!=null) {
            subvention_amt = ((loan_amt * objTenure.Subvention_Value__c) /100);
        }
   
        payment.nm_Amount__c=subvention_amt;
        payment.nm_ActualPaymentAmmount__c=subvention_amt;
        payment.nm_PaymentStatus__c ='Waived Off';
        payment.nm_PaymentType__c = 'Propelld Subvention';
        if(objectType == 'Lead'){
            payment.nm_Lead__c=recordId;
        }else if(objectType == 'Opportunity'){
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
        
        
        if(objTenure!=null && objTenure.Tranche_Payment__c){
            Decimal pendingAmount = loan_amt - subvention_amt;
            Decimal waviedOffAmount = pendingAmount / 2;
            System.debug('waviedOffAmount ----> ' + waviedOffAmount);
            createAdditionalPaymentRecord(recordId,objectType,waviedOffAmount);
        }
    }


    /**
    * @description // Code addded by suyog for additional charge
    * @author @BK | 10-04-2023 
    * @param recordId 
    * @param objectType 
    * @param disbursal_amount 
    **/
    public static void createAdditionalPaymentRecord(String recordId,String objectType,Decimal disbursal_amount){
        Boolean paymentCreated = false;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        if(objectType == 'Opportunity'){
            lstOpportunity = [select Id,Account.Program_Type__c,ActualPendingAmount__c from Opportunity where Id=:recordId and Loan_Type__c='Propelld' limit 1];
        }
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'Additional Charge' and nm_PaymentStatus__c = 'Waived Off' limit 1];

        if(nm_pay.size()>0){
            paymentCreated = true;
        }

        nm_Payment__c payment = new nm_Payment__c();
     
        if(objectType == 'Lead'){
            payment.nm_Amount__c= disbursal_amount;
            payment.nm_ActualPaymentAmmount__c=disbursal_amount;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_Lead__c=recordId; 

        }else if(objectType == 'Opportunity'){
            payment.nm_Amount__c = disbursal_amount;
            payment.nm_ActualPaymentAmmount__c = disbursal_amount;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_OpportunityNew__c=recordId;
     
        }

        if(payment != null && paymentCreated == false && payment.nm_Amount__c > 0 ){
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

    public static Boolean verifyCheckSum(Blob salt,String checksum){
        Boolean verified = false;
        String key = System.Label.Propelld_Api_Key;
        Blob data = crypto.generateMac('HmacSHA256', salt, Blob.valueOf(key));
        String generatedCheckSum = EncodingUtil.convertToHex(data);
        if(checksum.equals(generatedCheckSum)) {
            verified = true;
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
        apiReq.Type_of_Request__c= 'Propelld';
        apiReq.API_Name__c='PropelldWebhookAPI';
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
}