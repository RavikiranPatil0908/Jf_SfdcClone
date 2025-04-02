/**
 * @File Name          : liquiLoansWebhookAPI.cls
 * @Description        :
 * @Author             : shubhranshu
 * @Group              :
 * @Last Modified By   : @BK
 * @Last Modified On   : 09-10-2024
 * @Modification Log   :
 * Ver       Date            Author          Modification
 * 1.0    12/3/2019   shubhranshu     Initial Version
**/

@RestResource(urlMapping='/liquiLoansWebhookAPI/V1.1/*')
global without sharing class liquiLoansWebhookAPI {
   
    public static Boolean subventionPrograms = false;
    public static Boolean TenureSelectedForSubvention = false;

    /**
    * @description post method for liquiLoansWebhookAPI
    * @author shubhranshu | 12/3/2019
    * @return List<MessageWrapper>
    **/
    @HttpPost
    global static List<MessageWrapper> TrackLiquiLoansStaus(){

        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>();
        API_Request__c apiReq = new API_Request__c();
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String requestString = body.toString();
        System.debug('requestString '+requestString);
        LiquiLoansRequestWrapper reqWrapper = LiquiLoansRequestWrapper.parse(requestString);
        apiReq.Request__c = requestString;
        System.debug(reqWrapper);
        String loan_id ='';
        String amount ='';
        String status ='';
        String urn ='';
        String utr = '';
        String disbursed_amount = '';
        String tenure ='';
        String emi = '';
        String roi = '';
       
        String timestamp ='';
        String checksum ='';
        String generatedChecksum = '';
        MessageWrapper messageWrapper = null;
       
        if(String.isNotBlank(reqWrapper.loan_id)){
            loan_id =reqWrapper.loan_id;
        }else{
            RestContext.response.statusCode = 400;
            return returnMessage(apiReq,requestString,'501','Loan id is missing');
        }
        if(String.isNotBlank(reqWrapper.amount)){
            amount =reqWrapper.amount;
        }else{
            RestContext.response.statusCode = 400;
            return returnMessage(apiReq,requestString,'501','amount is missing.');
        }
        if(String.isNotBlank(reqWrapper.status)){
            status =reqWrapper.status;
        }else{
            RestContext.response.statusCode = 400;
            return returnMessage(apiReq,requestString,'501','status is missing.');
        }
        if(String.isNotBlank(reqWrapper.urn)){
            urn =reqWrapper.urn;
        }else{
            RestContext.response.statusCode = 400;
            return returnMessage(apiReq,requestString,'501','URN is missing.');
        }
        if(String.isNotBlank(reqWrapper.timestamp)){
            timestamp=reqWrapper.timestamp;
        }
        if(String.isNotBlank(reqWrapper.utr)) {
            utr = reqWrapper.utr;
        }
        if(String.isNotBlank(reqWrapper.disbursed_amount)) {
            disbursed_amount = reqWrapper.disbursed_amount;
        }
        if(String.isNotBlank(reqWrapper.tenure)){
            tenure=reqWrapper.tenure;
        }
        if(String.isNotBlank(reqWrapper.emi)) {
            emi = reqWrapper.emi;
        }
        if(String.isNotBlank(reqWrapper.roi)) {
            roi = reqWrapper.roi;
        }
       
        if(String.isNotBlank(reqWrapper.checksum)){
            checksum=reqWrapper.checksum;
        }else{
            RestContext.response.statusCode = 400;
            return returnMessage(apiReq,requestString,'501','checksum is missing.');
        }      

        System.debug('loan_id-->'+loan_id+' amount-->'+amount+' status-->'+status+' urn-->'+urn+' utr-->'+utr+' timestamp-->'+timestamp+' checksum-->'+checksum);

        if(String.isNotBlank(loan_id) && String.isNotBlank(amount) && String.isNotBlank(status) && String.isNotBlank(urn) && String.isNotBlank(timestamp)){
            generatedChecksum = generateChecksum(loan_id,amount,urn,status,timestamp);
        }
        if(generatedChecksum == checksum || Test.isRunningTest()){
            if(String.isNotBlank(reqWrapper.product_amount)){
                amount = reqWrapper.product_amount;
            }
            List<Opportunity> updateLstOpp=new List<Opportunity>();
            List<Opportunity> lstOpportunity = [select Id,Specialisation__c,Is_Re_Registration_Payment__c,nm_Year__c,ChooseProgram__c,nm_Fee_Type__c,nm_Session__c,EduVanz_last_update_status_date__c,Tenure__c,Loan_Amount__c,Loan_Application_Cancelled__c,Loan_Approved__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,Account.nm_ChooseaProgram__c ,Account.Program_Type__c,ActualPendingAmount__c,LiveLecturesType__c,CourseList__c from Opportunity where Loan_Order_Id__c=:urn and Loan_Type__c='LiquiLoans' limit 1];
           
            List<Lead> updateLstLead=new List<Lead>();
            List<Lead> lstLead = new List<Lead>();

            if(lstOpportunity.size()>0){

                System.debug('lstOpportunity '+lstOpportunity);
                for(Opportunity opp: lstOpportunity){
                    apiReq.Opportunity__c = opp.Id;
                    if(String.isNotBlank(loan_id)){
                        opp.EduVanz_lead_id__c = loan_id;                                    // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(amount)){
                        opp.Eduvanz_final_sanction_loan_amount__c = amount;                  // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(status)){
                        opp.Loan_Order_Status__c = status;
                        
                        if(status == 'Rejected' && !opp.Loan_Approved__c){
                            // call global method to avoid the same code logic
                            String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Opportunity',opp.EduVanz_lead_id__c,opp.Id,'Rejected');
                            if(strResult == 'true'){
                                System.debug('Loan application cancelled successfully...');
                                return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                            }else{
                                System.debug('Something went wrong while cancel the loan...'+strResult);
                                return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                            }
                        }else if(status == 'Disbursed'){
                            System.debug('subventionProg--'+subventionPrograms +'opp.Account.nm_ChooseaProgram__c --'+opp.Account.nm_ChooseaProgram__c );

                            if(String.isNotBlank(utr) && String.isNotBlank(disbursed_amount)){
                                opp.Loan_Sanctioned__c  = true;
                                String liveLectureType = opp.LiveLecturesType__c;
                                String courseList = opp.CourseList__c;
                                integer loan_amt  = Integer.valueOf(opp.Loan_Amount__c);
                                
                                Tenure__c objTenure = getTenureForSubvention(opp.nm_Fee_Type__c,opp.Account.nm_ChooseaProgram__c,opp.Specialisation__c,opp.Tenure__c);
                                List<String> lstallTermfeeProgram = new List<String>{'MBA - X','MBA (WX)','M.Sc. (AI & ML Ops)','M.Sc. (AI)'}; 
                                if(String.isNotBlank(opp.Specialisation__c) && lstallTermfeeProgram.contains(opp.Specialisation__c) && opp.nm_Fee_Type__c != 'AnnualFee' && opp.nm_Fee_Type__c != 'FullFee'){
                                    opp.nm_Fee_Type__c = 'MBAallTermfee';
                                }
                                System.debug('loan_amt '+loan_amt);
                                if(objTenure!=null && objTenure.Subvention_Value__c > 0){
                                    createLiquiLoansPayment(opp.Id,utr,'Opportunity',disbursed_amount,liveLectureType,courseList,null);
                                    createLiquiLoansAndSubventionPayment(utr,opp.Id,'Opportunity',opp.Loan_Amount__c,opp.ActualPendingAmount__c,disbursed_amount,objTenure); 
                                }else{
                                    createLiquiLoansPayment(opp.Id,utr,'Opportunity',disbursed_amount,liveLectureType,courseList,null);
                                }
                            }else{
                                return returnMessage(apiReq,requestString,'501','UTR or disbursed_amount is missing.');
                            }    
                        }else if(status =='Approved'){
                            opp.Eduvanz_final_sanction_loan_amount__c = amount;                              // use the eduvanz field to avoid the creating the new field for same functionality
                            opp.Loan_Amount__c = amount;
                            // opp.Interest_Rate__c = roi;
                            // opp.EMI_Amount__c = emi;
                            opp.Tenure__c = tenure;
                            LiquiLoansHandlecancelLoan LiquiLoansHandlecancelLoan = checkForLoanApprovedAfterCancelled(urn, opp.Id, 'Opportunity');
                            if (LiquiLoansHandlecancelLoan.isNeedToUpdateOpp) {
                                opp.Loan_Application_Cancelled__c = false;
                                opp.Down_Payment_Made__c = true;
                            }
                            if (LiquiLoansHandlecancelLoan.isNeedToBlockOppUpdate) {
                                return returnMessage(apiReq,requestString,'501','Loan Id Doesnt match or loan already cancelled by student');
                            }
                        }
                    }
                    opp.EduVanz_last_update_status_date__c = DateTime.now();                                 // use the eduvanz field to avoid the creating the new field for same functionality
                    updateLstOpp.add(opp);
                }

                if(updateLstOpp.size()>0){

                    System.debug('updateLstOpp-->'+updateLstOpp);
                    try{

                        update updateLstOpp;
                        messageWrapper = new MessageWrapper('200','Webhook API Data updated.');
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'LiquiLoans';
                        apiReq.API_Name__c='liquiLoansWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        RestContext.response.statusCode = 400;
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'LiquiLoans';
                        apiReq.API_Name__c='liquiLoansWebhookAPI';
                        apiReq.Success__c = false;
                    }
                }
            }else if(lstOpportunity.isEmpty() || lstOpportunity.size() ==0) {
                lstLead = [select Id,EduVanz_last_update_status_date__c,nm_Year__c,nm_Session__c,nm_Fee_Type__c,Loan_Application_Cancelled__c,Loan_Order_Status__c,EduVanz_lead_id__c,Loan_Order_Id__c,nm_ChooseaProgram__c,Program_Type__c,Tenure__c,Loan_Amount__c,LiveLecturesType__c,CourseList__c,nm_InformationCenter__r.ConsumerType__c,nm_Program__c,nm_Program__r.prgst__c from Lead where Loan_Order_Id__c=:urn and Loan_Type__c='LiquiLoans' and IsDeleted = false limit 1];
                for(Lead ld:lstLead){

                    apiReq.Lead__c= ld.Id;
                    if(String.isNotBlank(loan_id)){
                        ld.EduVanz_lead_id__c = loan_id;                                                     // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(amount)){
                        ld.Eduvanz_final_sanction_loan_amount__c = amount;                                   // use the eduvanz field to avoid the creating the new field for same functionality
                    }
                    if(String.isNotBlank(status)){
                        ld.Loan_Order_Status__c = status;
                        if(status == 'Rejected'){
                            // call global method to avoid the same code logic
                            String strResult = EduvanzTrackLoanApplicationAPI.cancelLoanApplication('Lead',ld.EduVanz_lead_id__c,ld.Id,'Rejected');
                            if(strResult == 'true'){
                                System.debug('Loan application cancelled successfully...');
                                return returnMessage(apiReq,requestString,'200','Webhook API Data updated.');
                            }else{
                                System.debug('Something went wrong while cancel the loan...'+strResult);
                                return returnMessage(apiReq,requestString,'504','Internal Error Occured.');
                            }                                                  
                        }else if(status == 'Disbursed'){
                            if(String.isNotBlank(utr) && String.isNotBlank(disbursed_amount)){
                                Tenure__c objTenure = getTenureForSubvention(ld.nm_Fee_Type__c,ld.nm_ChooseaProgram__c,ld.Program_Type__c,ld.Tenure__c);
                                ld.Loan_Sanctioned__c = true;
                                String liveLectureType = ld.LiveLecturesType__c;
                                String courseList = ld.CourseList__c;

                                integer loan_amt  = Integer.valueOf(ld.Loan_Amount__c);
                                if(objTenure!=null && objTenure.Subvention_Value__c > 0){
                                    createLiquiLoansPayment(ld.Id,utr,'Lead',disbursed_amount,liveLectureType,courseList,ld);
                                    createLiquiLoansAndSubventionPayment(utr,ld.Id,'Lead',ld.Loan_Amount__c,0,disbursed_amount,objTenure);
                                }else{
                                    createLiquiLoansPayment(ld.Id,utr,'Lead',disbursed_amount,liveLectureType,courseList,ld);
                                }
                            }else{
                                return returnMessage(apiReq,requestString,'501','UTR or disbursed_amount is missing.');
                            }
                        }else if(status =='Approved'){
                            ld.Eduvanz_final_sanction_loan_amount__c = amount;      // use the eduvanz field to avoid the creating the new field for same functionality  
                            ld.Loan_Amount__c = amount;
                            // ld.Interest_Rate__c = roi;
                            // ld.EMI_Amount__c = emi;
                            ld.Tenure__c = tenure;
                            LiquiLoansHandlecancelLoan LiquiLoansHandlecancelLoan = checkForLoanApprovedAfterCancelled(urn, ld.Id, 'Lead');
                            if (LiquiLoansHandlecancelLoan.isNeedToUpdateOpp) {
                                ld.Loan_Application_Cancelled__c = false;
                                ld.Down_Payment_Made__c = true;
                            }
                            if (LiquiLoansHandlecancelLoan.isNeedToBlockOppUpdate) {
                                return returnMessage(apiReq,requestString,'501','Loan Id Doesnt match or loan already cancelled by student');
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
                        apiReq.Type_of_Request__c= 'LiquiLoans';
                        apiReq.API_Name__c='liquiLoansWebhookAPI';
                        apiReq.Success__c = true;
                    }catch(Exception e){
                        messageWrapper = new MessageWrapper('504',e.getMessage());
                        RestContext.response.statusCode = 400;
                        apiReq.Response__c = messageWrapper.toString();
                        apiReq.Type_of_Request__c= 'LiquiLoans';
                        apiReq.API_Name__c='liquiLoansWebhookAPI';
                        apiReq.Success__c = false;
                    }
                }else{
                    RestContext.response.statusCode = 401;
                    return returnMessage(apiReq,requestString,'505','Error, please try again.');
                }
            }else{
                RestContext.response.statusCode = 400;
                return returnMessage(apiReq,requestString,'500','URN not matched, please try with different one.');
            }
        }else{
            RestContext.response.statusCode = 400;
            return returnMessage(apiReq,requestString,'511','checksum is not matched.');
        }
        lstmessageWrapper.add(messageWrapper);
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    /**
    * @description for log generation in API Request .
    * @author shubhranshu | 12/3/2019
    * @param apiRequest
    * @return void
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


    /**
    * @description 
    * @author @BK | 06-04-2023 
    * @param recordId 
    * @param UTR 
    * @param objectType 
    * @param amount 
    * @param liveLectureType 
    * @param courseList 
    * @param ld 
    **/
    public static void createLiquiLoansPayment(String recordId,String UTR ,String objectType,String amount,String liveLectureType,String courseList,Lead ld){
        Boolean paymentCreated = false;
        System.debug('createLiquiLoansPayment enter');
        Decimal loan_amt= Decimal.ValueOf(amount);
        List<nm_Payment__c> lstPaymentToInsert = new List<nm_Payment__c>();
        if(String.isNotBlank(liveLectureType) && liveLectureType!='No') {
            Decimal liveLectureAmount = 0;
            nm_Payment__c liveLecturePayment = EduvanzTrackLoanApplicationAPI.createLiveLecturePayment(recordId,UTR,objectType,Decimal.valueOf(amount),liveLectureType,courseList,ld,'NEFT - LiquiLoans');
            loan_amt = Decimal.valueOf(amount) - liveLecturePayment.nm_Amount__c;
            lstPaymentToInsert.add(liveLecturePayment);
        }

        nm_Payment__c payment = new nm_Payment__c();
        Decimal disbursed_amount= Decimal.ValueOf(amount);
        if(objectType == 'Lead' && loan_amt > 0){
            payment.nm_ModeOfPayment__c = 'NEFT - LiquiLoans';
            payment.nm_Amount__c= loan_amt;
            payment.nm_ActualPaymentAmmount__c = loan_amt;
            payment.nm_PaymentStatus__c ='Payment Made';
            payment.nm_PaymentType__c = 'Admission';
            payment.nm_Merchant_Track_Id__c = UTR;
            payment.nm_Lead__c=recordId;
           
        }else if(objectType == 'Opportunity' && loan_amt > 0){
            payment.nm_ModeOfPayment__c = 'NEFT - LiquiLoans';
            payment.nm_Amount__c = loan_amt;
            payment.nm_ActualPaymentAmmount__c = loan_amt;
            payment.nm_PaymentStatus__c ='Payment Made';
            payment.nm_PaymentType__c = 'Admission';
            payment.nm_Merchant_Track_Id__c = UTR;
            payment.nm_OpportunityNew__c=recordId;
        }
        if(payment != null && payment.nm_Amount__c > 0){        
            lstPaymentToInsert.add(payment);
        }
        System.debug('paymentCreated '+paymentCreated+' payment '+lstPaymentToInsert.size());
        if(lstPaymentToInsert.size() > 0 && paymentCreated == false){
            System.debug('paymnet record details-->'+payment+'paymentCreated '+paymentCreated);
            try{
                List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_ModeOfPayment__c ='NEFT - LiquiLoans' and nm_PaymentType__c!='Live Lectures' and ( nm_PaymentStatus__c ='Payment Made' or nm_PaymentStatus__c ='Payment Approved' ) limit 1];    
                if(nm_pay.size()>0){
                    paymentCreated = true;
                }
                insert lstPaymentToInsert;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }else{
            System.debug('payment already created --'+paymentCreated);
        }
    }


    /**
    * @description 
    * @author @BK | 06-04-2023 
    * @param UTR 
    * @param recordId 
    * @param objectType 
    * @param Loan_amount 
    * @param ActualPendingAmount 
    * @param disbursed_amount 
    * @param objTenure 
    **/
    public static void createLiquiLoansAndSubventionPayment(String UTR,String recordId,String objectType,String Loan_amount,Decimal ActualPendingAmount,String disbursed_amount,Tenure__c objTenure){
        System.debug('createLiquiLoansAndSubventionPayment enter '+' objectType  '+objectType);
        Boolean paymentCreated = false;
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'LiquiLoans Subvention' and nm_PaymentStatus__c = 'Waived Off' limit 1];    
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
            payment.nm_PaymentType__c = 'LiquiLoans Subvention';
            payment.nm_Lead__c=recordId;

        }else if(objectType == 'Opportunity'){
            payment.nm_Amount__c=subvention_amt;
            payment.nm_ActualPaymentAmmount__c=subvention_amt;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'LiquiLoans Subvention';
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

        if(objTenure!=null && objTenure.Tranche_Payment__c && ActualPendingAmount >0){
            createAdditionalPaymentRecord(ActualPendingAmount,recordId,objectType,disbursed_amount);
        }
    }

    /**
    * @description 
    * @author @BK | 06-04-2023 
    * @param ActualPendingAmount 
    * @param recordId 
    * @param objectType 
    * @param disbursed_amount 
    **/
    public static void createAdditionalPaymentRecord(Decimal ActualPendingAmount,String recordId,String objectType,String disbursed_amount){
        Boolean paymentCreated = false;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        if(objectType == 'Opportunity'){
            lstOpportunity = [select Id,Account.Program_Type__c,ActualPendingAmount__c from Opportunity where Id=:recordId and Loan_Type__c='LiquiLoans' limit 1];
        }
        List<nm_Payment__c> nm_pay = [select Id , nm_ModeOfPayment__c , nm_PaymentStatus__c , nm_PaymentType__c from nm_Payment__c where (nm_OpportunityNew__c =: recordId or nm_Lead__c =:recordId) and nm_PaymentType__c = 'Additional Charge' and nm_PaymentStatus__c = 'Waived Off' limit 1];    
        if(nm_pay.size()>0){
            paymentCreated = true;
        }

        nm_Payment__c payment = new nm_Payment__c();
        if(objectType == 'Lead'){
            payment.nm_Amount__c= ActualPendingAmount;
            payment.nm_ActualPaymentAmmount__c=ActualPendingAmount;
            payment.nm_PaymentStatus__c ='Waived Off';
            payment.nm_PaymentType__c = 'Additional Charge';
            payment.nm_Lead__c=recordId; 

        }else if(objectType == 'Opportunity'){
           // payment.nm_Amount__c= lstOpportunity[0].ActualPendingAmount__c;
           // payment.nm_ActualPaymentAmmount__c= lstOpportunity[0].ActualPendingAmount__c;
            payment.nm_Amount__c= Integer.valueof(disbursed_amount);
            payment.nm_ActualPaymentAmmount__c=  Integer.valueof(disbursed_amount);
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
    * @author @BK | 06-04-2023 
    * @param feeType 
    * @param chooseProgram 
    * @param programType 
    * @param tenure 
    * @return Tenure__c 
    **/
    public static Tenure__c getTenureForSubvention(String feeType,String chooseProgram,String programType,String tenure) {
        feeType = feeType == 'MBAallTermfee' || feeType == 'ReRegistrationPayment' ? 'Admission' : feeType;
        if((tenure == '23' || tenure == '17') && feeType == 'FullFeeLoan') {
            tenure = tenure == '23' ? '24' : '18';
        }
        String key = chooseProgram+'-'+programType+'-LiquiLoans-'+feeType;
        List<Tenure__c> lstTenures = [SELECT id,Subvention_Value__c,Tranche_Payment__c FROM Tenure__c WHERE Key__c=:key AND Tenure__c=:tenure AND IsActive__c=true LIMIT 1];
        if(lstTenures.size() > 0 && lstTenures[0].Subvention_Value__c > 0) {
            return lstTenures[0];
        }
        return null;
    }

    /**
    * @description
       this method first create the string with pipe sepeated value then using HmacSHA256 and key it generate the cheksum value
      at last return the hex value of this checksum
    * @author shubhranshu | 12/4/2019
    * @param loan_id
    * @param amount
    * @param urn
    * @param status
    * @param timestamp
    * @return String
    **/
    public static String generateChecksum(String loan_id,String amount,String urn,String status,String timestamp){
        String salt = loan_id+'|'+amount+'|'+urn+'|'+status+'|'+timestamp;
        System.debug('salt value '+salt);
        String key = System.Label.LiquiLoans_Api_Key;
        Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
        System.debug('checksum ==>'+ EncodingUtil.convertToHex(data));
        return  EncodingUtil.convertToHex(data);
    }

    global class MessageWrapper{

        public String responseCode;
        public String message;        
        global MessageWrapper(String responseCode,String message){
            this.responseCode = responseCode;
            this.message = message;
        }
    }

    public static List<MessageWrapper> returnMessage(API_Request__c apiReq, String requestString, String code, String msg) {
        if(apiReq==null) {
            apiReq = new API_Request__c();
        }
        MessageWrapper messageWrapper = new MessageWrapper(code,msg);
        List<MessageWrapper> lstmessageWrapper = new List<MessageWrapper>{messageWrapper};
        apiReq.Request__c = requestString;
        apiReq.Response__c = messageWrapper.toString();
        apiReq.Type_of_Request__c= 'LiquiLoans';
        apiReq.API_Name__c='liquiLoansWebhookAPI';
        apiReq.Success__c = code == '200' ? true : false;
        apiRequestsInsertion(apiReq);
        return lstmessageWrapper;
    }

    public static LiquiLoansHandlecancelLoan checkForLoanApprovedAfterCancelled(String urnId, String recordId, String objectType) {
        Boolean isNeedToBlockOppUpdate = false;
        Boolean isNeedToUpdateOpp = false;
        if (objectType == 'Opportunity' || objectType == 'Lead' ) {
            String query = 'SELECT Id, Request__c, Response__c, Success__c, API_Name__c FROM API_Request__c WHERE';
            if (objectType == 'Opportunity') {
                query += ' Opportunity__c = :recordId ';
            } else if (objectType == 'Lead') {
                query += ' Lead__c = :recordId ';
            }
            query += 'AND Type_of_Request__c = \'LiquiLoans\' AND API_Name__c != \'liquiLoansCreationFormData\' Order by CreatedDate DESC';
            for(API_Request__c objApiReq : Database.query(query)){
                Map<String, Object> mapOfObject = (Map<String, Object>) JSON.deserializeUntyped(objApiReq.Request__c.unescapeHtml4());
                if (objApiReq.Response__c.contains('responseCode=200') && (String) mapOfObject.get('status') == 'Rejected' && objApiReq.API_Name__c == 'liquiLoansWebhookAPI') {
                    String apiLoanId =(String) mapOfObject.get('urn');
                    if (urnId == apiLoanId) {
                        isNeedToUpdateOpp = true;
                    } else {
                        LoanCancellationRequestFailedController loanFailed = new LoanCancellationRequestFailedController();
                        loanFailed.loanCancellation(recordId,objectType, 'Loan Id doesnt match', 'Loan Id doesnt match');
                        isNeedToBlockOppUpdate = true;
                    }
                    break;
                } else if (objApiReq.API_Name__c == 'liquiLoansStatusUpdateAPI' && objApiReq.Success__c == true && (String) mapOfObject.get('application_status') == 'N') {
                    LoanCancellationRequestFailedController loanFailed = new LoanCancellationRequestFailedController();
                    loanFailed.loanCancellation(recordId,objectType, 'Loan Already Cancelled by student', 'Loan Already Cancelled by student');
                    isNeedToBlockOppUpdate = true;
                    break;
                }
            }

        }

        if (isNeedToUpdateOpp) {
            String payQuery = 'SELECT Id, nm_Installment_Payment_Ref__c FROM nm_Payment__c WHERE';
            if (objectType == 'Opportunity') {
                payQuery += ' nm_OpportunityNew__c = :recordId ';
            } else if (objectType == 'Lead') {
                payQuery += ' nm_Lead__c = :recordId ';
            } 
            payQuery += 'AND nm_PaymentType__c = \'Installment\' AND nm_PaymentStatus__c != \'Transaction Failed\' LIMIT 1';
            for (nm_Payment__c objPay : Database.query(payQuery)) {
                if (objPay.nm_Installment_Payment_Ref__c.contains('Installment')) {
                    objPay.nm_Installment_Payment_Ref__c = 'DownPayment-' + objPay.nm_Installment_Payment_Ref__c.split('-')[1];
                    objPay.nm_PaymentType__c = 'LiquiLoans-DownPayment';
                    update objPay;
                }
            }
        }
        LiquiLoansHandlecancelLoan LiquiLoansHandlecancelLoan = new LiquiLoansHandlecancelLoan();
        LiquiLoansHandlecancelLoan.isNeedToBlockOppUpdate = isNeedToBlockOppUpdate;
        LiquiLoansHandlecancelLoan.isNeedToUpdateOpp = isNeedToUpdateOpp;
        return LiquiLoansHandlecancelLoan;
    }

    // public Boolean isLoanAlreadyRejected(API_Request__c objApiReq) {

    // }

    public class LiquiLoansHandlecancelLoan {
        public Boolean isNeedToBlockOppUpdate {get;set;}
        public Boolean isNeedToUpdateOpp {get;set;}

        public LiquiLoansHandlecancelLoan() {
            isNeedToUpdateOpp = false;
            isNeedToUpdateOpp = false;
        }
    }

}